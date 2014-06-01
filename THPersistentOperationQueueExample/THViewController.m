//
//  THViewController.m
//  THPersistentOperationQueueExample
//
//  Created by Thomas Heß on 26.5.14.
//  Copyright (c) 2014 Thomas Heß. All rights reserved.
//

#import "THViewController.h"
#import "THPersistentOperationQueue.h"
#import "THPersistentOperationUserInfo.h"
#import "THPersistentOperation.h"
#import "THStringWorker.h"
#import "THLoaderWorker.h"

@interface THViewController () <THPersistentOperationDelegate>

@property (nonatomic, strong) UITextView *logView;

@end

@implementation THViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIButton *addStringWorkButton = [UIButton buttonWithType:UIButtonTypeSystem];
    addStringWorkButton.translatesAutoresizingMaskIntoConstraints = NO;
    [addStringWorkButton setTitle:@"Add String Work" forState:UIControlStateNormal];
    [addStringWorkButton addTarget:self action:@selector(addStringWork:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addStringWorkButton];
	
    UIButton *addLoaderWorkButton = [UIButton buttonWithType:UIButtonTypeSystem];
    addLoaderWorkButton.translatesAutoresizingMaskIntoConstraints = NO;
    [addLoaderWorkButton setTitle:@"Add Loader Work" forState:UIControlStateNormal];
    [addLoaderWorkButton addTarget:self action:@selector(addLoaderWork:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addLoaderWorkButton];
	
    self.logView = [[UITextView alloc] init];
    self.logView.translatesAutoresizingMaskIntoConstraints = NO;
    self.logView.text = @"";
    [self.view addSubview:self.logView];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[addStringWorkButton]-[addLoaderWorkButton]-|"
                                                                      options:0 metrics:nil
                                                                        views:@{ @"addStringWorkButton" : addStringWorkButton,
                                                                                 @"addLoaderWorkButton" : addLoaderWorkButton }]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[logView]-|" options:0 metrics:nil
                                                                        views:@{ @"logView" : self.logView }]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[addStringWorkButton]-[logView]-|" options:0 metrics:nil
                                                                        views:@{ @"addStringWorkButton" : addStringWorkButton,
                                                                                 @"logView" : self.logView }]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[addLoaderWorkButton]-[logView]-|" options:0 metrics:nil
                                                                        views:@{ @"addLoaderWorkButton" : addLoaderWorkButton,
                                                                                 @"logView" : self.logView }]];
    
    // start persistent operation queue
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *operationsPath = [documentsPath stringByAppendingPathComponent:@"operations"];
    [[THPersistentOperationQueue sharedQueue] startWithOperationsArchivePath:operationsPath operationsDelegate:self];
}

- (void)addStringWork:(id)sender
{
    THPersistentOperationUserInfo *info1 = [[THPersistentOperationUserInfo alloc] initWithWorkerClass:NSStringFromClass([THStringWorker class])
                                                                                       workerSelector:NSStringFromSelector(@selector(echoString:))
                                                                                    firstWorkerObject:@"hallo echo" secondWorkerObject:nil];
    THPersistentOperation *op1 = [[THPersistentOperationQueue sharedQueue] enqueueOperationWithUserInfo:info1];
    op1.delegate = self;
    THPersistentOperationUserInfo *info2 = [[THPersistentOperationUserInfo alloc] initWithWorkerClass:NSStringFromClass([THStringWorker class])
                                                                                       workerSelector:NSStringFromSelector(@selector(reverseString:))
                                                                                    firstWorkerObject:@"hallo echo" secondWorkerObject:nil];
    THPersistentOperation *op2 = [[THPersistentOperationQueue sharedQueue] enqueueOperationWithUserInfo:info2];
    op2.delegate = self;
    THPersistentOperationUserInfo *info3 = [[THPersistentOperationUserInfo alloc] initWithWorkerClass:NSStringFromClass([THStringWorker class])
                                                                                       workerSelector:NSStringFromSelector(@selector(appendString:toString:))
                                                                                    firstWorkerObject:@"hallo" secondWorkerObject:@"echo "];
    THPersistentOperation *op3 = [[THPersistentOperationQueue sharedQueue] enqueueOperationWithUserInfo:info3];
    op3.delegate = self;
}

- (void)addLoaderWork:(id)sender
{
    THPersistentOperationUserInfo *info1 = [[THPersistentOperationUserInfo alloc] initWithWorkerClass:NSStringFromClass([THLoaderWorker class])
                                                                                       workerSelector:NSStringFromSelector(@selector(loadDataFromURL:))
                                                                                    firstWorkerObject:[NSURL URLWithString:@"http://antiraum.de/THPersistentOperationQueue/astring.txt"]
                                                                                   secondWorkerObject:nil];
    THPersistentOperation *op1 = [[THPersistentOperationQueue sharedQueue] enqueueOperationWithUserInfo:info1];
    op1.delegate = self;
    THPersistentOperationUserInfo *info2 = [[THPersistentOperationUserInfo alloc] initWithWorkerClass:NSStringFromClass([THLoaderWorker class])
                                                                                       workerSelector:NSStringFromSelector(@selector(loadDataFromURL:))
                                                                                    firstWorkerObject:[NSURL URLWithString:@"http://antiraum.de/404.txt"]
                                                                                   secondWorkerObject:nil];
    THPersistentOperation *op2 = [[THPersistentOperationQueue sharedQueue] enqueueOperationWithUserInfo:info2];
    op2.delegate = self;
}

#pragma mark - THPersistentOperationDelegate

- (BOOL)persistentOperation:(THPersistentOperation *)operation completedWithReturnValue:(id)returnValue
{
    if (operation.workerClass == [THStringWorker class])
    {
        [self appendToLog:[NSString stringWithFormat:@"%@\n\n", returnValue]];
        
    } else if (operation.workerClass == [THLoaderWorker class]) {
        
        [self appendToLog:[NSString stringWithFormat:@"%@:\n",
                           operation.firstWorkerObject]];
        if ([returnValue[THLoaderWorkerReturnValueStatusCodeKey] integerValue] == 200)
        {
            NSData *data = returnValue[THLoaderWorkerReturnValueDataKey];
            NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if (! str) {
                return NO;
            }
            [self appendToLog:[NSString stringWithFormat:@"%@ %@\n\n",
                               returnValue[THLoaderWorkerReturnValueStatusCodeKey], str]];
        } else {
            [self appendToLog:[NSString stringWithFormat:@"%@\n\n",
                               returnValue[THLoaderWorkerReturnValueStatusCodeKey]]];
        }
    }
    
    return YES;
}

- (void)persistentOperation:(THPersistentOperation *)operation failedWithError:(NSError *)error
{
    if (error)
    {
        [self appendToLog:[NSString stringWithFormat:@"%@\n\n", error]];
    }
}

#pragma mark - Util

- (void)appendToLog:(NSString *)str
{
    self.logView.text = [self.logView.text stringByAppendingString:str];
    NSRange range = NSMakeRange(self.logView.text.length - 1, 1);
    [self.logView scrollRangeToVisible:range];
}

@end
