//
//  ASBaiPanVc.h
//  astro
//
//  Created by kjubo on 14-3-6.
//  Copyright (c) 2014年 kjubo. All rights reserved.
//

#import "ASBaseViewController.h"
#import "BaziMod.h"
#import "ZiWeiMod.h"
#import "AstroMod.h"
@interface ASBaziPanVc : ASBaseViewController
@property (nonatomic, strong) BaziMod *bazi;
@property (nonatomic, strong) ZiWeiMod *ziwei;
@property (nonatomic, strong) AstroMod *astro;
@end
