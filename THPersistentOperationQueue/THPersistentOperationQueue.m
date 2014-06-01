//
//  THPersistentOperationQueue.m
//  THPersistentOperationQueueExample
//
//  Created by Thomas Heß on 26.5.14.
//  Copyright (c) 2014 Thomas Heß. All rights reserved.
//

#import "THPersistentOperationQueue.h"

@interface THPersistentOperationQueue ()

@property (nonatomic, readwrite, copy) NSString *operationsArchivePath;
@property (nonatomic, strong) NSMutableArray *mutableOperations;
@property (nonatomic, strong) dispatch_queue_t mutableOperationsAccessQueue;
@property (nonatomic, strong) dispatch_queue_t diskWritesQueue;

@end

@implementation THPersistentOperationQueue

static const NSString *PersistentOperationIDKey = @"PersistentOperationIDKey";
static const NSString *PersistentOperationUserInfoKey = @"PersistentOperationUserInfoKey";

static THPersistentOperationQueue *sharedQueue = nil;

+ (instancetype)sharedQueue
{
    if (! sharedQueue) {
        sharedQueue = [[THPersistentOperationQueue alloc] init];
    }
    return sharedQueue;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.maxConcurrentOperationCount = 1;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:)
                                                     name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    [self setSuspended:NO];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

#pragma mark - NSOperationQueue

- (void)cancelAllOperations
{
    if (! self.mutableOperations) {
        return;
    }
    [super cancelAllOperations];
    dispatch_barrier_async(self.mutableOperationsAccessQueue, ^{
        [self.mutableOperations removeAllObjects];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self enqueuedOperationsChanged];
        });
    });
}

- (void)setSuspended:(BOOL)b {
    if ([self isSuspended] == b) return;
    [super setSuspended:b];
    if (! [self isSuspended]) {
        // start the first operation
        THPersistentOperation *firstOperation = [self.operations firstObject];
        if (firstOperation && ! firstOperation.isCancelled && ! firstOperation.isExecuting) {
            [firstOperation start];
        }
    }
}

#pragma mark - Public

- (void)startWithOperationsArchivePath:(NSString *)operationsArchivePath
                    operationsDelegate:(id<THPersistentOperationDelegate>)operationsDelegate
{
    if (self.mutableOperations) {
        // operations already initialized
        return;
    }
    
    self.operationsArchivePath = operationsArchivePath;
    
    // init operations from disk
    NSArray *operations = [NSKeyedUnarchiver unarchiveObjectWithFile:self.operationsArchivePath];
    if (operations) {
        // add operations
        for (NSDictionary *dict in operations) {
            THPersistentOperation *op = [[THPersistentOperation alloc] initWithOperationID:dict[PersistentOperationIDKey]
                                                                                  userInfo:dict[PersistentOperationUserInfoKey]];
            op.delegate = operationsDelegate;
            [self addOperation:op];
        }
    } else {
        operations = @[];
    }
    self.mutableOperations = [operations mutableCopy];
    self.mutableOperationsAccessQueue = dispatch_queue_create("name.thomashess.THPersistentOperationQueue.operationsAccess",
                                                              DISPATCH_QUEUE_CONCURRENT);
}

- (THPersistentOperation *)enqueueOperationWithUserInfo:(THPersistentOperationUserInfo *)userInfo
{
    if (! self.mutableOperations) {
        NSLog(@"queue not started");
        return nil;
    }
    
    // generate operation
    NSString *operationID = [[[NSProcessInfo processInfo] globallyUniqueString] copy];
    THPersistentOperation *op = [[THPersistentOperation alloc] initWithOperationID:operationID userInfo:userInfo];
    if (! op) {
        NSAssert(NO, @"unable to generate operation from userInfo %@", userInfo);
        return nil;
    }
    
    // persist
    NSDictionary *dict = @{ PersistentOperationIDKey : operationID,
                            PersistentOperationUserInfoKey : userInfo };
    dispatch_barrier_async(self.mutableOperationsAccessQueue, ^{
        [self.mutableOperations addObject:dict];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self enqueuedOperationsChanged];
        });
    });
    
    // add operation
    [self addOperation:op];
    [self setSuspended:NO]; // try to resume
    
    return op;
}

- (void)operationFinishedWithID:(NSString *)operationID
{
    if (! self.mutableOperations) {
        return;
    }
    
    __block NSDictionary *dict = nil;
    dispatch_sync(self.mutableOperationsAccessQueue, ^{
        for (NSDictionary *d in self.mutableOperations) {
            if (! [d[PersistentOperationIDKey] isEqualToString:operationID]) continue;
            dict = d;
            break;
        }
    });
    if (dict) {
        dispatch_barrier_async(self.mutableOperationsAccessQueue, ^{
            [self.mutableOperations removeObject:dict];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self enqueuedOperationsChanged];
            });
        });
    }
}

#pragma mark - Persistence

- (void)enqueuedOperationsChanged
{
    // coalesce save requests
    NSAssert([NSThread isMainThread], @"call from main thread to assure that we are still alive after the performSelector delay");
    SEL selector = @selector(saveOperations);
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:selector object:nil];
	[self performSelector:selector withObject:nil afterDelay:0.3f];
}

- (void)saveOperations
{
    if (! self.mutableOperations || ! self.operationsArchivePath) {
        return;
    }
    
    if (! self.diskWritesQueue) {
        self.diskWritesQueue = dispatch_queue_create("name.thomashess.THPersistentOperationQueue.diskWrites", DISPATCH_QUEUE_SERIAL);
        dispatch_set_target_queue(self.diskWritesQueue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0));
    }
    
    dispatch_async(self.diskWritesQueue, ^{
        dispatch_async(self.mutableOperationsAccessQueue, ^{
            [NSKeyedArchiver archiveRootObject:self.mutableOperations toFile:self.operationsArchivePath];
        });
    });
}

@end
