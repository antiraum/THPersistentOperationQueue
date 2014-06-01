//
//  THStringWorker.m
//  THPersistentOperationQueueExample
//
//  Created by Thomas Heß on 26.5.14.
//  Copyright (c) 2014 Thomas Heß. All rights reserved.
//

#import "THStringWorker.h"

@implementation THStringWorker

static const CGFloat Delay = 1.0f;

- (void)echoString:(NSString *)string
{
    if (string == nil || string.length == 0) {
        [self.delegate worker:self failedWithError:[NSError errorWithDomain:THWorkerErrorDomain code:THWorkerParameterErrorCode
                                                                   userInfo:nil]];
        return;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(Delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.delegate worker:self completedWithReturnValue:string];
    });
}

- (void)reverseString:(NSString *)string
{
    if (string == nil || string.length == 0) {
        [self.delegate worker:self failedWithError:[NSError errorWithDomain:THWorkerErrorDomain code:THWorkerParameterErrorCode
                                                                   userInfo:nil]];
        return;
    }
    
    NSMutableArray *chars = [NSMutableArray array];
    for (NSUInteger i = 0; i < string.length; i++) {
        [chars addObject:[string substringWithRange:NSMakeRange(i, 1)]];
    }
    NSMutableString *reverseString = [NSMutableString string];
    [chars enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSString *str, NSUInteger idx, BOOL *stop) {
        [reverseString appendString:str];
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(Delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.delegate worker:self completedWithReturnValue:reverseString];
    });
}

- (void)appendString:(NSString *)aString toString:(NSString *)string
{
    if (string == nil || string.length == 0 || aString == nil || aString.length == 0) {
        [self.delegate worker:self failedWithError:[NSError errorWithDomain:THWorkerErrorDomain code:THWorkerParameterErrorCode
                                                                   userInfo:nil]];
        return;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(Delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.delegate worker:self completedWithReturnValue:[string stringByAppendingString:aString]];
    });
}

@end
