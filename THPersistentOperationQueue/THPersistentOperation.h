//
//  THPersistentOperation.h
//  THPersistentOperationQueueExample
//
//  Created by Thomas Heß on 26.5.14.
//  Copyright (c) 2014 Thomas Heß. All rights reserved.
//

#import <Foundation/Foundation.h>

@class THPersistentOperationUserInfo;
@class THPersistentOperation;

@protocol THPersistentOperationDelegate <NSObject>

@optional
- (BOOL)persistentOperation:(THPersistentOperation *)operation completedWithReturnValue:(id)returnValue;
- (void)persistentOperation:(THPersistentOperation *)operation failedWithError:(NSError *)error;

@end

@interface THPersistentOperation : NSOperation

@property (nonatomic, readonly, copy) NSString *operationID;
@property (nonatomic, readonly, assign) Class workerClass;
@property (nonatomic, readonly, assign) SEL workerSelector;
@property (nonatomic, readonly, strong) id firstWorkerObject;
@property (nonatomic, readonly, strong) id secondWorkerObject;
@property (nonatomic, weak) id<THPersistentOperationDelegate> delegate;

- (instancetype)initWithOperationID:(NSString*)operationID userInfo:(THPersistentOperationUserInfo *)userInfo;

@end
