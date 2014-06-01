//
//  THLoaderWorker.m
//  THPersistentOperationQueueExample
//
//  Created by Thomas Heß on 26.5.14.
//  Copyright (c) 2014 Thomas Heß. All rights reserved.
//

#import "THLoaderWorker.h"

NSString *const THLoaderWorkerReturnValueStatusCodeKey = @"THLoaderWorkerReturnValueStatusCodeKey";
NSString *const THLoaderWorkerReturnValueDataKey = @"THLoaderWorkerReturnValueDataKey";

@interface THLoaderWorker () <NSURLConnectionDataDelegate>

@property (nonatomic, assign) NSInteger statusCode;
@property (nonatomic, strong) NSMutableData *loadedData;
@property (nonatomic, strong) NSURLConnection *connection;

@end

@implementation THLoaderWorker

- (void)cancel
{
    [self.connection cancel];
}

- (void)loadDataFromURL:(NSURL *)url
{
    if (! url) {
        [self.delegate worker:self failedWithError:[NSError errorWithDomain:THWorkerErrorDomain code:THWorkerParameterErrorCode
                                                                   userInfo:nil]];
        return;
    }
    
    self.statusCode = -1;
    self.loadedData = [NSMutableData data];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self.delegate worker:self failedWithError:error];
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.loadedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSMutableDictionary *returnDict = [NSMutableDictionary dictionary];
    if (self.statusCode != -1) {
        returnDict[THLoaderWorkerReturnValueStatusCodeKey] = @(self.statusCode);
        returnDict[THLoaderWorkerReturnValueDataKey] = [NSData dataWithData:self.loadedData];
    }
    [self.delegate worker:self completedWithReturnValue:returnDict];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        self.statusCode = [(NSHTTPURLResponse *)response statusCode];
    }
}

@end
