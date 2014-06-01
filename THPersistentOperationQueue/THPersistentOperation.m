//
//  THPersistentOperation.m
//  THPersistentOperationQueueExample
//
//  Created by Thomas Heß on 26.5.14.
//  Copyright (c) 2014 Thomas Heß. All rights reserved.
//

#import "THPersistentOperation.h"
#import "THPersistentOperationUserInfo.h"
#import "THPersistentOperationQueue.h"
#import "THWorker.h"

@interface THPersistentOperation () <THWorkerDelegate>

@property (nonatomic, readwrite, copy) NSString *operationID;
@property (nonatomic, readwrite, assign) Class workerClass;
@property (nonatomic, readwrite, assign) SEL workerSelector;
@property (nonatomic, readwrite, strong) id firstWorkerObject;
@property (nonatomic, readwrite, strong) id secondWorkerObject;
@property (nonatomic, strong) THWorker *worker;
@property (nonatomic, assign) BOOL executing;
@property (nonatomic, assign) BOOL finished;
@property (nonatomic, assign) CGFloat queuePauseInterval;

@end

@implementation THPersistentOperation

static const CGFloat InitialQueuePauseInterval = 5.0f;
static const CGFloat QueuePauseIntervalMultiplier = 1.5f;

- (instancetype)initWithOperationID:(NSString*)operationID userInfo:(THPersistentOperationUserInfo *)userInfo
{
    self = [super init];
    if (self) {
        _operationID = operationID;
        _workerClass = NSClassFromString(userInfo.workerClass);
        NSParameterAssert(_workerClass && [_workerClass isSubclassOfClass:[THWorker class]]);
        _workerSelector = NSSelectorFromString(userInfo.workerSelector);
        NSParameterAssert(_workerSelector);
        _firstWorkerObject = userInfo.firstWorkerObject;
        _secondWorkerObject = userInfo.secondWorkerObject;
        _finished = NO;
        _executing = NO;
        _queuePauseInterval = InitialQueuePauseInterval;
    }
    return self;
}

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@"self.operationID=%@", self.operationID];
    [description appendFormat:@", self.workerClass=%@", self.workerClass];
    [description appendFormat:@", self.workerSelector=%p", self.workerSelector];
    [description appendFormat:@", self.firstWorkerObject=%@", self.firstWorkerObject];
    [description appendFormat:@", self.secondWorkerObject=%@", self.secondWorkerObject];
    [description appendFormat:@", self.delegate=%@", self.delegate];
    [description appendFormat:@", self.executing=%d", self.executing];
    [description appendFormat:@", self.finished=%d", self.finished];
    [description appendString:@">"];
    return description;
}

#pragma mark - NSOperation

- (void)start {
    @autoreleasepool {
        if (self.isCancelled || self.isExecuting) {
            return;
        }
        self.executing = YES;
        if (! self.worker) {
            self.worker = [[self.workerClass alloc] initWithDelegate:self];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            if (self.firstWorkerObject && self.secondWorkerObject) {
                [self.worker performSelector:self.workerSelector withObject:self.firstWorkerObject
                                  withObject:self.secondWorkerObject];
            } else if (self.firstWorkerObject) {
                [self.worker performSelector:self.workerSelector withObject:self.firstWorkerObject];
            } else {
                [self.worker performSelector:self.workerSelector];
            }
#pragma clang diagnostic pop
        });
    }
}

- (BOOL)isConcurrent {
    return YES;
}

- (BOOL)isFinished {
    return self.finished;
}

- (void)setFinished:(BOOL)finished {
    [self willChangeValueForKey:@"isFinished"];
    _finished = finished;
    [self didChangeValueForKey:@"isFinished"];
}

- (BOOL)isExecuting {
    return self.executing;
}

- (void)setExecuting:(BOOL)executing {
    [self willChangeValueForKey:@"isExecuting"];
    _executing = executing;
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)cancel {
    [super cancel];
    [[THPersistentOperationQueue sharedQueue] operationFinishedWithID:self.operationID];
    [self.worker cancel];
}

#pragma mark - THWorkerDelegate

- (void)worker:(THWorker *)worker completedWithReturnValue:(id)returnValue
{
    self.executing = NO;
    
    if (self.isCancelled) {
        // already cancelled
        self.finished = YES;
        return;
    }
    
    // the delegate decides if the operation is finished or should be retried
    BOOL operationFinished = YES;
    if ([self.delegate respondsToSelector:@selector(persistentOperation:completedWithReturnValue:)]) {
        operationFinished = [self.delegate persistentOperation:self completedWithReturnValue:returnValue];
    }
    if (operationFinished) {
        [[THPersistentOperationQueue sharedQueue] operationFinishedWithID:self.operationID];
        self.finished = YES;
    } else {
        [self workerWasNotSuccessful];
    }
}

- (void)worker:(THWorker *)worker failedWithError:(NSError *)error
{
    self.executing = NO;
    
    if (self.isCancelled) {
        // already cancelled
        self.finished = YES;
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(persistentOperation:failedWithError:)]) {
        // notify delegate
        [self.delegate persistentOperation:self failedWithError:error];
    }
    
    if ([error.domain isEqualToString:THWorkerErrorDomain] && error.code == THWorkerParameterErrorCode) {
        // retrying won't change the outcome
        [[THPersistentOperationQueue sharedQueue] operationFinishedWithID:self.operationID];
        self.finished = YES;
        return;
    }
    
    [self workerWasNotSuccessful];
}

- (void)workerWasNotSuccessful
{
    // pause the queue / the queue will execute the operation again when it resumes
    [[THPersistentOperationQueue sharedQueue] setSuspended:YES];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.queuePauseInterval * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.queuePauseInterval *= QueuePauseIntervalMultiplier;
        [[THPersistentOperationQueue sharedQueue] setSuspended:NO];
    });
}

@end
