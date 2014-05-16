//
//  AstroMod.h
//  astro
//
//  Created by kjubo on 14-3-19.
//  Copyright (c) 2014年 kjubo. All rights reserved.
//

#import "AstroStar.h"
@protocol AstroMod
@end

@interface AstroMod : JSONModel
@property (nonatomic, strong) NSArray<AstroStar> *Stars;
@property (nonatomic) NSInteger Gender;
@property (nonatomic) NSInteger Gender1;
@property (nonatomic, strong) NSDate<NSDate> *birth;
@property (nonatomic, strong) NSDate<NSDate> *birth1;
@property (nonatomic) NSNumber<Ignore> *constellationStart;

- (UIImage *)paipan;
+ (CGPoint)pointByRadius:(CGFloat)radius andDegree:(CGFloat)degree;
@end
