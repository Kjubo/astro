//
//  DateEntity.m
//  astro
//
//  Created by kjubo on 14-3-4.
//  Copyright (c) 2014年 kjubo. All rights reserved.
//

#import "DateEntity.h"

@implementation DateEntity

+ (Class)classForJsonObjectByKey:(NSString *)key {
    if([key isEqualToString:@"Date"]){
        return [NSDate class];
    }
    return nil;
}

+ (Class)classForJsonObjectsByKey:(NSString *)key {
    if([key isEqualToString:@"BeginMonth"]){
        return [NSDate class];
    } else if([key isEqualToString:@"BeginZodiac"]){
        return [NSDate class];
    }
    return nil;
}

- (id)copyWithZone:(NSZone *)zone{
    DateEntity *entity = [[[self class] allocWithZone:zone] init];
    [entity setDate:[self.Date copy]];
    [entity setBeginMonth:[self.BeginMonth copy]];
    [entity setBeginZodiac:[self.BeginZodiac copy]];
    entity.NongliDay = self.NongliDay;
    entity.NongliDZ = self.NongliDZ;
    entity.NongliHour = self.NongliHour;
    entity.NongliMonth = self.NongliMonth;
    entity.NongliTG = self.NongliTG;
    return entity;
}

@end
