//
//  ASCustomer.h
//  astro
//
//  Created by kjubo on 14-6-6.
//  Copyright (c) 2014年 kjubo. All rights reserved.
//

#import "JSONModel.h"

@protocol ASCustomerProtocol <NSObject>

@required
@property (nonatomic, strong) NSString *BigPhotoShow;
@property (nonatomic) NSInteger Credit;
@property (nonatomic) NSInteger FateType;
@property (nonatomic) NSInteger Gender;
@property (nonatomic, strong) NSString *GradeShow;
@property (nonatomic) NSInteger GradeSysNo;
@property (nonatomic) NSInteger HasNewInfo;
@property (nonatomic) NSInteger IsStar;
@property (nonatomic, strong) NSString *NickName;
@property (nonatomic) NSInteger Point;
@property (nonatomic) NSInteger Status;
@property (nonatomic) NSInteger SysNo;
@property (nonatomic, strong) NSString *smallPhotoShow;
@end

@interface ASCustomer : JSONModel <ASCustomerProtocol>
@property (nonatomic, strong) NSString *BigPhotoShow;
@property (nonatomic) NSInteger Credit;
@property (nonatomic) NSInteger FateType;
@property (nonatomic) NSInteger Gender;
@property (nonatomic, strong) NSString *GradeShow;
@property (nonatomic) NSInteger GradeSysNo;
@property (nonatomic) NSInteger HasNewInfo;
@property (nonatomic) NSInteger IsStar;
@property (nonatomic, strong) NSString *NickName;
@property (nonatomic) NSInteger Point;
@property (nonatomic) NSInteger Status;
@property (nonatomic) NSInteger SysNo;
@property (nonatomic, strong) NSString *smallPhotoShow;
@end
