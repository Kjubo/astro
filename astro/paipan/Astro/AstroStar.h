//
//  AstroStar.h
//  astro
//
//  Created by kjubo on 14-3-19.
//  Copyright (c) 2014年 kjubo. All rights reserved.
//

@protocol AstroStar
@end

@interface AstroStar : JSONModel
@property (nonatomic) NSInteger StarName;
@property (nonatomic) NSInteger Gong;
@property (nonatomic) NSInteger Degree;
@property (nonatomic) double Cent;
@property (nonatomic) NSInteger Constellation;
@property (nonatomic) double Progress;
@end

@interface AstroStarHD : NSObject
@property (nonatomic, strong) AstroStar *base;
@property (nonatomic) CGFloat DegreeHD;
@property (nonatomic) CGFloat PanDegree;
@property (nonatomic) CGFloat FixDegree;

- (id)initWithAstro:(AstroStar *)star;
@end
