//
//  AstroMod.m
//  astro
//
//  Created by kjubo on 14-3-19.
//  Copyright (c) 2014年 kjubo. All rights reserved.
//

#import "AstroMod.h"
#import "AstroStar.h"

CGFloat D2R(CGFloat degrees) {return degrees * M_PI / 180.0;};
CGFloat R2D(CGFloat radians) {return radians * 180.0/M_PI;};

@interface AstroMod ()
@property (nonatomic, strong) NSMutableArray *__gong;
@end

@implementation AstroMod
+ (Class)classForJsonObjectByKey:(NSString *)key {
    return nil;
}

+ (Class)classForJsonObjectsByKey:(NSString *)key {
    if([key isEqualToString:@"Stars"]){
        return [AstroStar class];
    }
    return nil;
}

#define _Size   CGSizeMake(320, 320)
#define _Radius _Size.width/2 - 10
#define _Center CGPointMake(_Size.width/2, _Size.height/2)
#define _ConstellationDegree 30.0

- (UIImage *)paipan
{
    UIGraphicsBeginImageContextWithOptions(_Size, YES, 0);
    [[UIColor blackColor] setFill];
    UIRectFill(CGRectMake(0, 0, _Size.width, _Size.height));

    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetAllowsAntialiasing(ctx, true);
    CGContextSetShouldAntialias(ctx, true);
    
    CGFloat r0 = _Radius;
    CGFloat r1 = r0 - 20;
    CGFloat r2 = r1 - 5;
    CGFloat r3 = r2 - 20;
    
    //四个同心圆
    [self drawArc:ctx radius:r0];
    [self drawArc:ctx radius:r1];
    [self drawArc:ctx radius:r2];
    [self drawArc:ctx radius:r3];
    
    //居中
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    
    //12宫
    CGFloat conStartDegree = [self initDrawData];   //星座开始角度
    for(int i = 0; i < 12; i++){
        double degree = [[self.__gong objectAtIndex:i] doubleValue];
        double nextDegree = 0;
        if(i != 11){
            nextDegree = [[self.__gong objectAtIndex:i + 1] doubleValue];
        }else{
            nextDegree = 540.0;
        }
        //写宫名
        CGFloat cd = (degree + nextDegree)*0.5;
        CGFloat cr = (r3 + r2)*0.5;
        CGPoint ct = CGPointMake(_Center.x + cos(D2R(cd))*cr, _Center.y - sin(D2R(cd))*cr);
        UIColor *color = nil;
        switch (i%4) {
            case 0:
                color = [UIColor redColor];
                break;
            case 1:
                color = [UIColor yellowColor];
                break;
            case 2:
                color = [UIColor greenColor];
                break;
            case 3:
                color = [UIColor blueColor];
                break;
            default:
                break;
        }
        NSAttributedString *gn = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d", i + 1]
                                                                 attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:8],
                                                                              NSForegroundColorAttributeName : color,
                                                                              NSParagraphStyleAttributeName : paragraphStyle}];
        [gn drawInRect:CGRectMake(ct.x - 6, ct.y - 6, 14, 14)];
        
        CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
        [self drawSeparated:ctx degree:degree from:r2 to:r3];
        //连接1-7，4-10宫的起点 （1，1虚线）
        if(i == 0 || i == 3){
            CGFloat dash[] = {1, 1};
            CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
            CGContextSetLineDash(ctx, 0, dash, 2);
            [self drawSeparated:ctx degree:degree from:_Size.width/2 to:-_Size.width/2 lineWidth:0.5];
            CGContextSetLineDash(ctx, 0, NULL, 0);
        }
    }
    
    //12星座
    for(int i = 0; i < 360; i++){
        if(i % 30 == 0){
            [self drawSeparated:ctx degree:(conStartDegree + i) from:r0 to:r2];
        }else if(i % 5 == 0){
            [self drawSeparated:ctx degree:(conStartDegree + i) from:r1 to:r2];
        }else{
            [self drawSeparated:ctx degree:(conStartDegree + i) from:r1 to:r2 lineWidth:0.3];
        }
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)drawArc:(CGContextRef)ctx radius:(CGFloat)radius{
    CGContextAddArc(ctx, _Center.x, _Center.y, radius, 0, M_PI*2, 0);
    CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextDrawPath(ctx, kCGPathStroke);
}

- (void)drawSeparated:(CGContextRef)ctx degree:(CGFloat)degree from:(CGFloat)from to:(CGFloat)to{
    [self drawSeparated:ctx degree:degree from:from to:to lineWidth:1.0];
}

- (void)drawSeparated:(CGContextRef)ctx degree:(CGFloat)degree from:(CGFloat)from to:(CGFloat)to lineWidth:(CGFloat)lineWidth{
    CGPoint begin, end;
    begin = CGPointMake(_Center.x + cos(D2R(degree))*from, _Center.y - sin(D2R(degree))*from);
    end = CGPointMake(_Center.x + cos(D2R(degree))*to, _Center.y - sin(D2R(degree))*to);
    CGContextSetLineWidth(ctx, lineWidth);
    CGContextMoveToPoint(ctx, begin.x, begin.y);
    CGContextAddLineToPoint(ctx, end.x, end.y);
    CGContextStrokePath(ctx);
}

- (CGFloat)initDrawData{
    if(!self.__gong){
        self.__gong = [[NSMutableArray alloc] init];
    }
    [self.__gong removeAllObjects];
    
    CGFloat last = 180.0;
    CGFloat conStart = 0;
    [self.__gong addObject:@(last)];
    for(int i = 20; i < 31; i++){
        AstroStar *star = [self.Stars objectAtIndex:i];
        AstroStar *starNext = [self.Stars objectAtIndex:i + 1];
        
        if(i == 20){
            conStart = last - (star.Constellation - 1)*_ConstellationDegree - star.Degree - star.Cent/60.0;
        }
        
        int cc = 0;
        if(starNext.Constellation >= star.Constellation){
            cc = starNext.Constellation - star.Constellation;
        }else{
            cc = (12 - star.Constellation) + starNext.Constellation;
        }
        last = last + cc*30.0 + (starNext.Degree - star.Degree) + (starNext.Cent - star.Cent)/60.0;
        [self.__gong addObject:@(last)];
    }
    return conStart;
}
@end