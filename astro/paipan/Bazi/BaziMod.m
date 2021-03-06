//
//  BaziMod.m
//  astro
//
//  Created by kjubo on 14-3-4.
//  Copyright (c) 2014年 kjubo. All rights reserved.
//

#import "BaziMod.h"
#import <CoreText/CoreText.h>
#import "NSDate+Addition.h"
#import "Paipan.h"

#define __BaziFullPanSize CGSizeMake(320, 460)
#define __BaziSimplePanSize CGSizeMake(320, 300)

@implementation BaziMod
- (id)initWithDateEntity:(DateEntity *)entity{
    if (self = [super init]) {
        self.BirthTime = [entity copy];
        NSInteger year = self.BirthTime.Date.year;
        NSInteger mon = self.BirthTime.Date.month;
        NSInteger day = self.BirthTime.Date.day;
        NSInteger hour = self.BirthTime.Date.hour;
        
        NSInteger daytemp = day;
        if(hour == 23)
        {
            daytemp--;
        }
        self.DayTG = _GetDayTG(year, mon, daytemp);
        self.DayDZ = _GetDayDZ(year, mon, daytemp);
        
        self.HourTG = _GetHourTG(self.DayTG, hour);
        self.HourDZ = _GetHourDZ(hour);
        
        NSInteger montemp = [self checkMon:self.BirthTime];
        self.MonthTG = _GetMonthTG(year, montemp);
        self.MonthDZ = _GetMonthDZ(montemp);
        
        NSInteger yeartemp = [self checkYear:self.BirthTime];
        self.YearTG = _GetYearTG(yeartemp);
        self.YearDZ = _GetYearDZ(yeartemp);
        
        [self calXunKongDay];
        [self calYinYang];
        [self calNayin];
        [self calCangGan];
        [self calWangShuai];
        
    }
    return self;
}

#pragma mark - Year Month Day TG & DZ
int _GetDayTG(NSInteger year, NSInteger mon, NSInteger day){
    NSInteger c = year / 100;
    NSInteger y = year % 100;
    if(mon <= 2){
        mon = mon + 12;
        y = y - 1;
    }
    NSInteger tmp = 4 * c + (c / 4) + 5 * y + (y / 4) + (3 * (mon + 1) / 5) + day - 4;
    return tmp % 10;
}

NSInteger _GetDayDZ(NSInteger year, NSInteger mon, NSInteger day){
    NSInteger c = year / 100;
    NSInteger y = year % 100;
    NSInteger i = 0;
    if(mon <= 2){
        mon = mon + 12;
        y = y - 1;
    }
    if(mon % 2 == 0){
        i = 6;
    }
    NSInteger tmp = 8 * c + (c / 4) + 5 * y + (y / 4) + (3 * (mon + 1) / 5) + day + i + 6;
    return tmp % 12;
}

NSInteger _GetHourTG(NSInteger dayTG, NSInteger hour){
    int flag = dayTG % 5 * 2;
    return (flag + (hour + 1)/2)%10;
}

NSInteger _GetHourDZ(NSInteger hour){
    return (hour + 1) / 2 % 12;
}

NSInteger _GetMonthTG(NSInteger year, NSInteger mon){
    return (year * 12 + mon + 2) % 10;
}

NSInteger _GetMonthDZ(NSInteger mon){
    return mon % 12;
}

NSInteger _GetYearTG(NSInteger year){
    return  (year + 6) % 10;
}

NSInteger _GetYearDZ(NSInteger year){
    return (year + 8) % 12;
}

- (NSInteger)checkMon:(DateEntity *)entity{
    NSInteger mon = entity.Date.month;
    long entityDate = [entity.Date timeIntervalSince1970];
    if(entityDate < [entity.BeginMonthShow[mon - 1] longLongValue]){
        mon--;
    }
    if(mon == 0){
        mon = 12;
    }
    return mon;
}

- (NSInteger)checkYear:(DateEntity *)entity{
    NSInteger year = entity.Date.year;
    long entityDate = [entity.Date timeIntervalSince1970];
    if(entityDate < [entity.BeginMonthShow[1] longLongValue]){
        year--;
    }
    return year;
}

#pragma mark - cal
- (void)calXunKongDay{
    int temp = (9 - self.DayTG + self.DayDZ + 1) % 12;
    self.XunKong0 = temp;
    self.XunKong1 = temp + 1;
}

- (void)calYinYang{
    if(self.YearTG % 2 == 0){
        self.YinYang = 1;
    }else{
        self.YinYang = 0;
    }
}

- (void)calNayin{
    self.NaYin = [[NSMutableArray alloc] init];
    [self.NaYin addObject:@(10000 + self.YearTG * 100 + self.YearDZ)];
    [self.NaYin addObject:@(10000 + self.MonthTG * 100 + self.MonthDZ)];
    [self.NaYin addObject:@(10000 + self.DayTG * 100 + self.DayDZ)];
    [self.NaYin addObject:@(10000 + self.HourTG * 100 + self.HourDZ)];
}

#define __cang @[@"9", @"975", @"024", @"1", @"149", @"624", @"35", @"153", @"468", @"7", @"734", @"08"]
- (void)calCangGan{
    self.CangGanShow = [[NSMutableArray alloc] init];
    for(int i = 0; i < 4; i++){
        [self.CangGanShow addObject:[NSMutableArray array]];
    }
    
    NSString *str = [__cang objectAtIndex:self.YearDZ];
    NSMutableArray *arr = [self.CangGanShow objectAtIndex:0];
    for(int j = 0 ; j < 3; j++){
        if(j < [str length]){
            [arr addObject:@([[str substringWithRange:NSMakeRange(j, 1)] intValue])];
        }else{
            [arr addObject:@0];
        }
    }
    
    str = [__cang objectAtIndex:self.MonthDZ];
    arr = [self.CangGanShow objectAtIndex:1];
    for(int j = 0 ; j < 3; j++){
        if(j < [str length]){
            [arr addObject:@([[str substringWithRange:NSMakeRange(j, 1)] intValue])];
        }else{
            [arr addObject:@0];
        }
    }
    
    str = [__cang objectAtIndex:self.DayDZ];
    arr = [self.CangGanShow objectAtIndex:2];
    for(int j = 0 ; j < 3; j++){
        if(j < [str length]){
            [arr addObject:@([[str substringWithRange:NSMakeRange(j, 1)] intValue])];
        }else{
            [arr addObject:@0];
        }
    }
    
    str = [__cang objectAtIndex:self.HourDZ];
    arr = [self.CangGanShow objectAtIndex:3];
    for(int j = 0 ; j < 3; j++){
        if(j < [str length]){
            [arr addObject:@([[str substringWithRange:NSMakeRange(j, 1)] intValue])];
        }else{
            [arr addObject:@0];
        }
    }
    
}

- (void)calWangShuai{
    self.WangShuai = [[NSMutableArray alloc] init];
    [self.WangShuai addObject:@(_GetWangShuai(self.YearDZ, self.DayTG))];
    [self.WangShuai addObject:@(_GetWangShuai(self.MonthDZ, self.DayTG))];
    [self.WangShuai addObject:@(_GetWangShuai(self.DayDZ, self.DayTG))];
    [self.WangShuai addObject:@(_GetWangShuai(self.HourDZ, self.DayTG))];
}

#define __wsbegin @[@11, @6, @2, @9, @2, @9, @5, @0, @8, @3]
NSInteger _GetWangShuai(NSInteger source, NSInteger riyuan){
    NSInteger begin = [[__wsbegin objectAtIndex:riyuan] intValue];
    if(riyuan % 2 == 0){    //阳干
        return (source - begin + 12) % 12;
    }else{
        return (begin - source + 12) % 12;
    }
}

- (UIImage *)paipan:(BOOL)fullTag
{
    NSInteger fontSize = 10;
    
    NSDictionary *prefixAttributes  = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [UIFont boldSystemFontOfSize:fontSize], NSFontAttributeName,nil];
    NSDictionary *textAttributes    = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [UIFont systemFontOfSize:fontSize], NSFontAttributeName,nil];
    NSDictionary *blueAttributes    = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [UIFont systemFontOfSize:fontSize], NSFontAttributeName,
                                       UIColorFromRGB(0x1a85c2), NSForegroundColorAttributeName, nil];
    NSDictionary *redAttributes     = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [UIFont systemFontOfSize:fontSize], NSFontAttributeName,
                                       [UIColor redColor], NSForegroundColorAttributeName,nil];
    NSDictionary *greenAttributes   = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [UIFont systemFontOfSize:fontSize], NSFontAttributeName,
                                       UIColorFromRGB(0x149e11), NSForegroundColorAttributeName,nil];
    NSDictionary *pinkAttributes    = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [UIFont systemFontOfSize:fontSize], NSFontAttributeName,
                                       UIColorFromRGB(0xfe30d9), NSForegroundColorAttributeName,nil];
    
    
    CGSize size = fullTag ? __BaziFullPanSize : __BaziSimplePanSize;
    UIGraphicsBeginImageContextWithOptions(size, YES, 0);
    [UIColorFromRGB(0xf7f4ee) setFill];
    UIRectFill(CGRectMake(0, 0, size.width, size.height));
    
    NSMutableAttributedString *ret = [[NSMutableAttributedString alloc] init];
    // line1
    [ret appendAttributedString:[[NSAttributedString alloc] initWithString:@"姓名:" attributes:prefixAttributes]];
    [ret appendAttributedString:[[NSAttributedString alloc] initWithString:self.Name attributes:textAttributes]];
    [ret appendAttributedString:[[NSAttributedString alloc] initWithString:@"\t\t排盘类型: \t" attributes:prefixAttributes]];
    if(self.RealTime){
        [ret appendAttributedString:[[NSAttributedString alloc] initWithString:@"真太阳时" attributes:textAttributes]];
    } else {
        [ret appendAttributedString:[[NSAttributedString alloc] initWithString:@"普通排盘" attributes:textAttributes]];
    }
    
    // line2
    [ret appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n出生地:" attributes:prefixAttributes]];
    [ret appendAttributedString:[[NSAttributedString alloc] initWithString:self.AreaName attributes:textAttributes]];
    [ret appendAttributedString:[[NSAttributedString alloc] initWithString:@"\t经度:" attributes:prefixAttributes]];
    [ret appendAttributedString:[[NSAttributedString alloc] initWithString:self.Longitude attributes:textAttributes]];
    
    // line3
    [ret appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n上上签神秘学社区四柱八字系统  http://www.ssqian.com/\n" attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:11], NSFontAttributeName,nil]]];

    // line4
    [ret appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n公历:" attributes:prefixAttributes]];
    NSMutableAttributedString *temp = [[NSMutableAttributedString alloc] initWithString:[self.BirthTime.Date toStrFormat:@"yyyy年MM月dd日hh时mm分"] attributes:textAttributes];
    [temp addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, 4)];
    [temp addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(5, 2)];
    [temp addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(8, 2)];
    [temp addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(11, 2)];
    [temp addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(14, 2)];
    [ret appendAttributedString:temp];

    // line5
    NSInteger nayin = 10000 + self.BirthTime.NongliTG * 100 + self.BirthTime.NongliDZ;
    [ret appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n阴历:" attributes:prefixAttributes]];
    temp = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@年[%@]%@月%@%@时", GetTianGan(self.BirthTime.NongliTG), GetDiZhi(self.BirthTime.NongliDZ), [self getNayin:nayin], GetNongliMonth(self.BirthTime.NongliMonth), GetNongliDay(self.BirthTime.NongliDay), GetDiZhi(self.BirthTime.NongliHour)] attributes:textAttributes];
    [ret appendAttributedString:temp];

    // line6
    NSInteger jieqi = [[self.JieQiName objectAtIndex:0] intValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[self.JieQiShow[0] longLongValue]];
    [ret appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@:", [self getJieQi:jieqi]] attributes:textAttributes]];
    temp = [[NSMutableAttributedString alloc] initWithString:[date toStrFormat:@"yyyy年MM月dd日HH时mm分ss秒(高精度天文算法)"] attributes:textAttributes];
    [temp addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, 4)];
    [temp addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(5, 2)];
    [temp addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(8, 2)];
    [temp addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(11, 2)];
    [temp addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(14, 2)];
    [temp addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(17, 2)];
    [ret appendAttributedString:temp];

    // line7
    jieqi = [[self.JieQiName objectAtIndex:1] intValue];
    date = [NSDate dateWithTimeIntervalSince1970:[self.JieQiShow[1] longLongValue]];
    [ret appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@:", [self getJieQi:jieqi]] attributes:textAttributes]];
    temp = [[NSMutableAttributedString alloc] initWithString:[date toStrFormat:@"yyyy年MM月dd日HH时mm分ss秒"] attributes:textAttributes];
    [temp addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, 4)];
    [temp addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(5, 2)];
    [temp addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(8, 2)];
    [temp addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(11, 2)];
    [temp addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(14, 2)];
    [temp addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(17, 2)];
    [ret appendAttributedString:temp];

    // line8 起运
    [ret appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n\n起运:" attributes:prefixAttributes]];
    temp = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"于出生后%@", [self getAllDayTimeSpan:self.QiYunShow]] attributes:textAttributes];
    [temp addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(4, 4)];
    [temp addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(9, 2)];
    [temp addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(13, 2)];
    [ret appendAttributedString:temp];

    // line9 交运
    [ret appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n交运:" attributes:prefixAttributes]];
    temp = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"于公历%@交运", [self.JiaoYun toStrFormat:@"yyyy年MM月dd日HH时mm分"]] attributes:textAttributes];
    [temp addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(3, 4)];
    [temp addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(8, 2)];
    [temp addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(11, 2)];
    [temp addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(14, 2)];
    [temp addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(17, 2)];
    [ret appendAttributedString:temp];

    // line10
    temp = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n\n\t%@\t\t%@\t\t日主\t\t%@", GetShiChenByTg(self.YearTG, self.DayTG), GetShiChenByTg(self.MonthTG, self.DayTG), GetShiChenByTg(self.HourTG, self.DayTG)] attributes:blueAttributes];
    [ret appendAttributedString:temp];
    
    // line11
    if(self.Gender == 1){
        [ret appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n乾造:\t" attributes:prefixAttributes]];
    } else{
        [ret appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n坤造:\t" attributes:prefixAttributes]];
    }
    NSString *str = [NSString stringWithFormat:@"%@\t\t%@\t\t%@\t\t%@", GetTianGan(self.YearTG), GetTianGan(self.MonthTG), GetTianGan(self.DayTG), GetTianGan(self.HourTG)];
    [ret appendAttributedString:[[NSAttributedString alloc] initWithString:str attributes:redAttributes]];
    temp = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"\t(%@%@空)", GetDiZhi(self.XunKong0), GetDiZhi(self.XunKong1)] attributes:textAttributes];
    [temp addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0xfe30d9) range:NSMakeRange(2, 2)];
    [ret appendAttributedString:temp];
    
    // line12
    str = [NSString stringWithFormat:@"\n\t%@\t\t%@\t\t%@\t\t%@\n", GetDiZhi(self.YearDZ), GetDiZhi(self.MonthDZ), GetDiZhi(self.DayDZ), GetDiZhi(self.HourDZ)];
    [ret appendAttributedString:[[NSAttributedString alloc] initWithString:str attributes:redAttributes]];

    // line13 - 15
    for(int j = 0; j < 3; j++){
        [ret appendAttributedString:[[NSAttributedString alloc] initWithString:@"\t"]];
        for(int i = 0; i < 4; i++){
            NSInteger cg = [self getCangGanByX:i andY:j];
            if(!(j != 0 && cg == 0)){
                NSInteger cgLast = [self getCangGanByX:i andY:j - 1];
                if(!(j != 0 && cg == cgLast)){
                    [ret appendAttributedString:[[NSAttributedString alloc] initWithString:GetTianGan(cg) attributes:textAttributes]];
                    [ret appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\t", GetShiChenByTg(cg,self.DayTG)] attributes:blueAttributes]];
                }
            }
        }
        [ret appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
    }
    
    //line 16 旺衰
    [ret appendAttributedString:[[NSAttributedString alloc] initWithString:@"旺衰:\t" attributes:prefixAttributes]];
    for(int i = 0; i < 4; i++){
        [ret appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\t\t", [self getZiWeiChangSheng:[[self.WangShuai objectAtIndex:i] intValue]]] attributes:textAttributes]];
    }

    //line 17 纳音
    [ret appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n纳音:\t" attributes:prefixAttributes]];
    for(int i = 0; i < 4; i++){
        [ret appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\t", [self getNayin:[[self.NaYin objectAtIndex:i] intValue]]] attributes:greenAttributes]];
    }

    //line 18 纳音 大运
//    [ret appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n纳音:\t" attributes:prefixAttributes]];
//    for(int i = 0; i < 8; i++){
//        BaziDayun *dy = [self.Dayun objectAtIndex:i];
//        [ret appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@  ", [self getNayin:dy.NaYin]] attributes:greenAttributes]];
//    }

    //line 19 旺衰 大运
    [ret appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n\n旺衰:\t" attributes:prefixAttributes]];
    for(int i = 0; i < 8; i++){
        BaziDayun *dy = [self.Dayun objectAtIndex:i];
        [ret appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\t", [self getZiWeiChangSheng:dy.WangShuai]] attributes:textAttributes]];
    }
    
    //line 20 十神 大运
    [ret appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n十神:\t" attributes:prefixAttributes]];
    for(int i = 0; i < 8; i++){
        BaziDayun *dy = [self.Dayun objectAtIndex:i];
        [ret appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\t", GetShiShen(dy.ShiShen)] attributes:blueAttributes]];
    }

    //line 21 大运
    [ret appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n大运:\t" attributes:prefixAttributes]];
    for(int i = 0; i < 8; i++){
        BaziDayun *dy = [self.Dayun objectAtIndex:i];
        [ret appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@\t", GetTianGan(dy.YearTG), GetDiZhi(dy.YearDZ)] attributes:redAttributes]];
    }

    //line 22 岁
    [ret appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n\t " attributes:prefixAttributes]];
    for(int i = 0; i < 8; i++){
        BaziDayun *dy = [self.Dayun objectAtIndex:i];
        [ret appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@岁\t", @(dy.Begin - self.BirthTime.Date.year)] attributes:textAttributes]];
    }

    if(fullTag){
        [ret appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n始于:\t" attributes:prefixAttributes]];
        for(int i = 0; i < 8; i++){
            BaziDayun *dy = [self.Dayun objectAtIndex:i];
            [ret appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\t", @(dy.Begin)] attributes:blueAttributes]];
        }
        
        //流年
        [ret appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n流年:\t" attributes:prefixAttributes]];
        for(int i = 0; i < 10; i++){
            if(i != 0){
                [ret appendAttributedString:[[NSAttributedString alloc] initWithString:@"\t" attributes:prefixAttributes]];
            }
            for(int j = 0; j < 8; j++){
                BaziDayun *dy = [self.Dayun objectAtIndex:j];
                NSInteger tg = [self detailYearTG:dy.Begin + i];
                NSInteger dz = [self detailYearDZ:dy.Begin + i];
                [ret appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", GetTianGan(tg)] attributes:textAttributes]];
                if(dz == self.XunKong0
                   || dz == self.XunKong1){
                    [ret appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\t", GetDiZhi(dz)] attributes:pinkAttributes]];
                }else{
                    [ret appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\t", GetDiZhi(dz)] attributes:textAttributes]];
                }
                
            }
            [ret appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n" attributes:textAttributes]];
        }
        
        [ret appendAttributedString:[[NSAttributedString alloc] initWithString:@"止于:\t" attributes:prefixAttributes]];
        for(int i = 0; i < 8; i++){
            BaziDayun *dy = [self.Dayun objectAtIndex:i];
            [ret appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\t", @(dy.End)] attributes:blueAttributes]];
        }
    }
    
    [ret drawAtPoint:CGPointMake(10, 6)];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)paipanSimple{
    NSInteger fontSize = 12;
    
    NSDictionary *blueAttributes    = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [UIFont systemFontOfSize:fontSize], NSFontAttributeName,
                                       UIColorFromRGB(0x1a85c2), NSForegroundColorAttributeName, nil];
    
    CGSize size = CGSizeMake(280, 36);
    UIGraphicsBeginImageContextWithOptions(size, YES, 0);
    [[UIColor whiteColor] setFill];
    UIRectFill(CGRectMake(0, 0, size.width, size.height));
    
    // line11
    NSMutableAttributedString *ret = [[NSMutableAttributedString alloc] init];
    if(self.Gender == 1){
        [ret appendAttributedString:[[NSAttributedString alloc] initWithString:@"乾造:\t  " attributes:blueAttributes]];
    } else{
        [ret appendAttributedString:[[NSAttributedString alloc] initWithString:@"坤造:\t  " attributes:blueAttributes]];
    }
    NSString *str = [NSString stringWithFormat:@"%@   %@   %@   %@", GetTianGan(self.YearTG), GetTianGan(self.MonthTG), GetTianGan(self.DayTG), GetTianGan(self.HourTG)];
    [ret appendAttributedString:[[NSAttributedString alloc] initWithString:str attributes:blueAttributes]];
    NSMutableAttributedString *temp = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"   (%@%@空)", GetDiZhi(self.XunKong0), GetDiZhi(self.XunKong1)] attributes:blueAttributes];
    [ret appendAttributedString:temp];
    
    // line12
    str = [NSString stringWithFormat:@"\n\t  %@   %@   %@   %@\n", GetDiZhi(self.YearDZ), GetDiZhi(self.MonthDZ), GetDiZhi(self.DayDZ), GetDiZhi(self.HourDZ)];
    [ret appendAttributedString:[[NSAttributedString alloc] initWithString:str attributes:blueAttributes]];
    
    [ret drawAtPoint:CGPointMake(0, 4)];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (NSInteger)detailYearTG:(NSInteger)year{
    return (year + 6) % 10;
}

- (NSInteger)detailYearDZ:(NSInteger)year{
    return (year + 8) % 12;
}

- (NSInteger)getCangGanByX:(NSInteger)x andY:(NSInteger)y{
    if(x < 0 || y < 0)
        return 0;
    NSMutableArray *arr = self.CangGanShow[x];
    return [[arr objectAtIndex:y] intValue];
}

- (NSString *)getZiWeiChangSheng:(NSInteger)tag{
    return [__ZiWeiChangSheng objectAtIndex:tag];
}

- (NSString *)getAllDayTimeSpan:(long)time{
    int day = (int)(time / D_DAY);
    int hour = (time % D_DAY)/D_HOUR;
    int min = (time % D_DAY % D_HOUR)/D_MINUTE;
    return [NSString stringWithFormat:@"%4d天%2d小时%2d分钟", day, hour, min];
}

- (NSString *)getNayin:(NSInteger)tag{
    return [__Nayin objectForKey:[NSNumber numberWithInteger:tag]];
}

- (NSString *)getJieQi:(NSInteger)tag{
    return [__AllJieQi objectAtIndex:tag];
}
@end

