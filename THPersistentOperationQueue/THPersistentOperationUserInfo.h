//
//  THPersistentOperationUserInfo.h
//  THPersistentOperationQueueExample
//
//  Created by Thomas Heß on 26.5.14.
//  Copyright (c) 2014 Thomas Heß. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface THPersistentOperationUserInfo : NSObject <NSCoding, NSCopying>

@property (nonatomic, copy) NSString *workerClass;
@property (nonatomic, copy) NSString *workerSelector;
@property (nonatomic, copy) NSObject<NSCoding, NSCopying> *firstWorkerObject;
@property (nonatomic, copy) NSObject<NSCoding, NSCopying> *secondWorkerObject;

- (instancetype)initWithWorkerClass:(NSString *)workerClass
                     workerSelector:(NSString *)workerSelector
                  firstWorkerObject:(NSObject<NSCoding, NSCopying> *)firstWorkerObject
                 secondWorkerObject:(NSObject<NSCoding, NSCopying> *)secondWorkerObject;

@end
