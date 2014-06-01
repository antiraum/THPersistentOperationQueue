//
//  THStringWorker.h
//  THPersistentOperationQueueExample
//
//  Created by Thomas Heß on 26.5.14.
//  Copyright (c) 2014 Thomas Heß. All rights reserved.
//

#import "THWorker.h"

@interface THStringWorker : THWorker

- (void)echoString:(NSString *)string;
- (void)reverseString:(NSString *)string;
- (void)appendString:(NSString *)aString toString:(NSString *)string;

@end
