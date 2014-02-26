//
//  ASGlobal.h
//  astro
//
//  Created by kjubo on 14-2-25.
//  Copyright (c) 2014年 kjubo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASUsr_Customer.h"
@interface ASGlobal : NSObject
@property (nonatomic, strong) ASUsr_Customer *user;
@property (nonatomic, strong) NSString *deviceNumber;
+ (ASGlobal *)shared;
@end
