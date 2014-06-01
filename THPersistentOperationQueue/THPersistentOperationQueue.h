//
//  THPersistentOperationQueue.h
//  THPersistentOperationQueueExample
//
//  Created by Thomas Heß on 26.5.14.
//  Copyright (c) 2014 Thomas Heß. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "THPersistentOperation.h"

@class THPersistentOperation;
@class THPersistentOperationUserInfo;

@interface THPersistentOperationQueue : NSOperationQueue

@property (nonatomic, readonly, copy) NSString *operationsArchivePath;

+ (instancetype)sharedQueue;
- (void)startWithOperationsArchivePath:(NSString *)operationsArchivePath
                    operationsDelegate:(id<THPersistentOperationDelegate>)operationsDelegate; // call this first
- (THPersistentOperation *)enqueueOperationWithUserInfo:(THPersistentOperationUserInfo *)userInfo; // use this to enqueue new work
- (void)operationFinishedWithID:(NSString *)operationID; // called by the operation

@end
