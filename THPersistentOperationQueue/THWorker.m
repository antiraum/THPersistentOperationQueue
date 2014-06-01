//
//  THWorker.m
//  THPersistentOperationQueueExample
//
//  Created by Thomas Heß on 26.5.14.
//  Copyright (c) 2014 Thomas Heß. All rights reserved.
//

#import "THWorker.h"

NSString *const THWorkerErrorDomain = @"name.thomashess.THWorker";
NSInteger const THWorkerParameterErrorCode = 123456;

@implementation THWorker

- (instancetype)initWithDelegate:(id<THWorkerDelegate>)delegate
{
    self = [super init];
    if (self)
    {
        _delegate = delegate;
    }
    return self;
}

- (void)cancel
{
    // implement in subclasses
}

@end
