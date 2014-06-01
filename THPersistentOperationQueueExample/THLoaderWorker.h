//
//  THLoaderWorker.h
//  THPersistentOperationQueueExample
//
//  Created by Thomas Heß on 26.5.14.
//  Copyright (c) 2014 Thomas Heß. All rights reserved.
//

#import "THWorker.h"

extern NSString *const THLoaderWorkerReturnValueStatusCodeKey;
extern NSString *const THLoaderWorkerReturnValueDataKey;

@interface THLoaderWorker : THWorker

- (void)loadDataFromURL:(NSURL *)url;

@end
