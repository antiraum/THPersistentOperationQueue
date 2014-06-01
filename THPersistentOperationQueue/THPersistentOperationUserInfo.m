//
//  THPersistentOperationUserInfo.m
//  THPersistentOperationQueueExample
//
//  Created by Thomas Heß on 26.5.14.
//  Copyright (c) 2014 Thomas Heß. All rights reserved.
//

#import "THPersistentOperationUserInfo.h"

@implementation THPersistentOperationUserInfo

- (instancetype)initWithWorkerClass:(NSString *)workerClass
                     workerSelector:(NSString *)workerSelector
                  firstWorkerObject:(NSObject<NSCoding, NSCopying> *)firstWorkerObject
                 secondWorkerObject:(NSObject<NSCoding, NSCopying> *)secondWorkerObject
{
    NSParameterAssert(workerClass && workerSelector);
    self = [super init];
    if (self)
    {
        _workerClass = [workerClass copy];
        _workerSelector = [workerSelector copy];
        _firstWorkerObject = [firstWorkerObject copy];
        _secondWorkerObject = [secondWorkerObject copy];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self)
    {
        self.workerClass = [coder decodeObjectForKey:@"self.workerClass"];
        self.workerSelector = [coder decodeObjectForKey:@"self.workerSelector"];
        self.firstWorkerObject = [coder decodeObjectForKey:@"self.firstWorkerObject"];
        self.secondWorkerObject = [coder decodeObjectForKey:@"self.secondWorkerObject"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.workerClass forKey:@"self.workerClass"];
    [coder encodeObject:self.workerSelector forKey:@"self.workerSelector"];
    [coder encodeObject:self.firstWorkerObject forKey:@"self.firstWorkerObject"];
    [coder encodeObject:self.secondWorkerObject forKey:@"self.secondWorkerObject"];
}

- (id)copyWithZone:(NSZone *)zone
{
    THPersistentOperationUserInfo *copy = [[[self class] allocWithZone:zone] init];
    
    if (copy != nil)
    {
        copy.workerClass = self.workerClass;
        copy.workerSelector = self.workerSelector;
        copy.firstWorkerObject = self.firstWorkerObject;
        copy.secondWorkerObject = self.secondWorkerObject;
    }
    
    return copy;
}

- (BOOL)isEqual:(id)other
{
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;
    
    return [self isEqualToInfo:other];
}

- (BOOL)isEqualToInfo:(THPersistentOperationUserInfo *)info
{
    if (self == info)
        return YES;
    if (info == nil)
        return NO;
    if (self.workerClass != info.workerClass && ![self.workerClass isEqualToString:info.workerClass])
        return NO;
    if (self.workerSelector != info.workerSelector && ![self.workerSelector isEqualToString:info.workerSelector])
        return NO;
    if (self.firstWorkerObject != info.firstWorkerObject && ![self.firstWorkerObject isEqual:info.firstWorkerObject])
        return NO;
    if (self.secondWorkerObject != info.secondWorkerObject && ![self.secondWorkerObject isEqual:info.secondWorkerObject])
        return NO;
    return YES;
}

- (NSUInteger)hash
{
    NSUInteger hash = [self.workerClass hash];
    hash = hash * 31u + [self.workerSelector hash];
    hash = hash * 31u + [self.firstWorkerObject hash];
    hash = hash * 31u + [self.secondWorkerObject hash];
    return hash;
}

- (NSString *)description
{
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@", self.workerClass=%@", self.workerClass];
    [description appendFormat:@", self.workerSelector=%@", self.workerSelector];
    [description appendFormat:@", self.firstWorkerObject=%@", self.firstWorkerObject];
    [description appendFormat:@", self.secondWorkerObject=%@", self.secondWorkerObject];
    [description appendString:@">"];
    return description;
}

@end
