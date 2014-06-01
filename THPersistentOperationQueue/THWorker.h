//
//  THWorker.h
//  THPersistentOperationQueueExample
//
//  Created by Thomas Heß on 26.5.14.
//  Copyright (c) 2014 Thomas Heß. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const THWorkerErrorDomain;
extern NSInteger const THWorkerParameterErrorCode;

@class THWorker;

@protocol THWorkerDelegate <NSObject>

@required
- (void)worker:(THWorker *)worker completedWithReturnValue:(id)returnValue;
- (void)worker:(THWorker *)worker failedWithError:(NSError *)error;

@end

@interface THWorker : NSObject

@property (nonatomic, weak) id<THWorkerDelegate> delegate;

- (instancetype)initWithDelegate:(id<THWorkerDelegate>)delegate;
- (void)cancel;

@end
