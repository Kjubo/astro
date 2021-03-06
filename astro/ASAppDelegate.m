//
//  ASAppDelegate.m
//  astro
//
//  Created by kjubo on 13-12-15.
//  Copyright (c) 2013年 kjubo. All rights reserved.
//

#import "ASAppDelegate.h"
#import "ASNav.h"
#import "ASTabMainVc.h"
#import "ASShareBindVc.h"
#import "ASLoginVc.h"

@interface ASAppDelegate ()<UIAlertViewDelegate>
//定位的计时器
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSTimer *gpsFetchTimer;
@property (nonatomic, strong) NSTimer *gpsUpdateTimer;
@property (nonatomic) NSInteger locOpenCount;
@property (nonatomic, strong) CLLocation *lastLocation;
@end

@implementation ASAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    //设置状态栏
    UIApplication.sharedApplication.statusBarStyle = UIStatusBarStyleLightContent;
    //可以接收服务器推送消息
    /** 注册推送通知功能,*/
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIRemoteNotificationTypeBadge
                                                                                             |UIRemoteNotificationTypeSound
                                                                                             |UIRemoteNotificationTypeAlert) categories:nil];
        [application registerUserNotificationSettings:settings];
    } else {
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
        [application registerForRemoteNotificationTypes:myTypes];
    }
    
    //设置时区
    NSTimeZone *tzGMT = [[NSTimeZone alloc] initWithName:@"Asia/Shanghai"];
    [NSTimeZone setDefaultTimeZone:tzGMT];
    
    //解析
    if (launchOptions) {
        //推送的消息
        NSDictionary *p1 = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (p1) {
        }
    }
    
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                       [UIFont boldSystemFontOfSize:12], NSFontAttributeName,
                                                       ASColorDarkGray, NSForegroundColorAttributeName,
                                                       nil] forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                       [UIFont boldSystemFontOfSize:12], NSFontAttributeName,
                                                       ASColorBlue, NSForegroundColorAttributeName,
                                                       nil] forState:UIControlStateSelected];
    
    //初始化window
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    
    ASTabMainVc *vc = [[ASTabMainVc alloc] init];
    //配置页面到导航vc
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
    self.nav = nc;
    self.nav.navigationBarHidden = YES;
    
    //设置rootViewController
    self.window.rootViewController = self.nav;
    [self.window makeKeyAndVisible];
    
    [[UINavigationBar appearance] setTitleTextAttributes: @{NSForegroundColorAttributeName : [UIColor whiteColor],
                                                            NSFontAttributeName : [UIFont boldSystemFontOfSize:18],
                                                            }];
    [[UINavigationBar appearance] setBarTintColor:ASColorDarkGray];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    /** 注册推送通知功能,*/
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIRemoteNotificationTypeBadge
                                                                                             |UIRemoteNotificationTypeSound
                                                                                             |UIRemoteNotificationTypeAlert) categories:nil];
        [application registerUserNotificationSettings:settings];
    } else {
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
        [application registerForRemoteNotificationTypes:myTypes];
    }
    
    self.locOpenCount = 0;
    [self handleNextQueryTimerForLm];
    
    return YES;
}

#pragma mark -  解析url
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation{
    NSString *aburl = [url absoluteString];
    if (aburl.length<3) {
        return NO;
    }
    if([aburl hasPrefix:@"sinaweibosso"]) {
        [ASShareBindVc handleOpenURL:url];
        return NO;
    }
    //    else if([aburl hasPrefix:@"xms-alipay"]) {
    //        [[NSNotificationCenter defaultCenter] postNotificationName:kMsgForAppSchemeLinkForAlipay object:url];
    //        return NO;
    //    }
    //    else if ([aburl hasPrefix:@"wx"]) {
    //        [WXApi handleOpenURL:url delegate:self];
    //        return NO;
    //    }
    else {
        //        [SchemePushUtil notifyToProcessAppSchemeUrl:aburl];
        return YES;
    }
}

#pragma mark - DeviceToken

#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    //handle the actions
    if ([identifier isEqualToString:@"declineAction"]){
    }
    else if ([identifier isEqualToString:@"answerAction"]){
    }
}
#endif

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    NSString *token = [NSString stringWithFormat:@"%@", deviceToken];
    if(token){
        [HttpUtil load:@"customer/DeviceToken"
                params:@{@"deviceToken" : token} completion:nil];
    }
}


//接收到服务器消息
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    //重置软件角标
    [UIApplication.sharedApplication setApplicationIconBadgeNumber:0];
    
    //获得推送数据
    //容错
    if (userInfo==nil) {
        return;
    }
    NSDictionary *param = [userInfo objectForKey:@"acme"];
    //容错
    if (param==nil) {
        return;
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application{
    [self start];
    if([ASGlobal isLogined]){
        [HttpUtil load:@"Customer/GetUserInfo"
                params:@{@"uid" : Int2String([ASGlobal shared].user.SysNo)}
            completion:^(BOOL succ, NSString *message, id json) {
                if(succ){
                    NSError *error;
                    ASCustomer *um = [[ASCustomer alloc] initWithDictionary:json error:&error];
                    if(!error) {
                        [ASGlobal login:um];
                    }
                }
            }];
    }
}

#pragma mark - GPS Method
- (void)start{
    if(!self.locationManager){
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        if(IOS8_OR_LATER){
            [self.locationManager requestWhenInUseAuthorization];
        }
    }
    [self.locationManager startUpdatingLocation];
}

- (void)stop{
    if(self.gpsFetchTimer){
        [self.gpsFetchTimer invalidate];
        self.gpsFetchTimer = nil;
    }
    
    if(self.gpsUpdateTimer){
        [self.gpsUpdateTimer invalidate];
        self.gpsUpdateTimer = nil;
    }
}

- (void)handleNextQueryTimerForLm {
    [self start];
}

//定位成功
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    NSTimeInterval eventAge = [newLocation.timestamp timeIntervalSinceNow];
    if (fabs(eventAge) > 5) {
        return;
    }
    if (newLocation.horizontalAccuracy < 0) {
        return;
    }
    if ([newLocation isEqual:oldLocation]) {
        if (self.gpsUpdateTimer!=nil) {
            [self.gpsUpdateTimer invalidate];
            self.gpsUpdateTimer = nil;
        }
        [self fetchAfterSaveLoc:newLocation succ:YES];
    } else {
        self.lastLocation = [newLocation copy];
        if (self.gpsUpdateTimer == nil) {
            self.gpsUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:3
                                                                   target:self
                                                                 selector:@selector(handleDidUpdateLoc:)
                                                                 userInfo:nil
                                                                  repeats:NO];
        }
    }
}

//更新loc
- (void)handleDidUpdateLoc:(NSTimer *)theTimer {
    //清除timer
    if(self.gpsUpdateTimer){
        [self.gpsUpdateTimer invalidate];
    }
    self.gpsUpdateTimer = nil;
    //保存经纬度
    [self fetchAfterSaveLoc:self.lastLocation succ:YES];
}

//定位失败
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self fetchAfterSaveLoc:nil succ:NO];
}

- (void)fetchAfterSaveLoc:(CLLocation *)loc succ:(BOOL)succTag{
    [self.locationManager stopUpdatingLocation];
    //更新经纬度
    if (succTag) {
        [[GpsData shared] setMKGpsLocation:loc];
    }
    
    //定时器  下一次更新
    if (self.gpsFetchTimer == nil) {
        self.locOpenCount++;
        double interval = 0;
        if (self.locOpenCount >= 2) {
            if (succTag) {
                interval = 60;
            } else {
                interval = 20;
            }
        } else {
            interval = 0.5;
        }
        self.gpsFetchTimer = [NSTimer scheduledTimerWithTimeInterval:interval
                                                              target:self
                                                            selector:@selector(handleNextQueryTimerForLm:)
                                                            userInfo:nil
                                                             repeats:NO];
    }
}

- (void)handleNextQueryTimerForLm:(NSTimer *)theTimer {
    if(self.gpsFetchTimer){
        [self.gpsFetchTimer invalidate];
    }
    self.gpsFetchTimer = nil;
    [self.locationManager startUpdatingLocation];
}

#pragma mark - NeedLogin
- (void)showNeedLoginAlertView{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"登录提示" message:@"请先登录您的账号" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
    alert.tag = 10086;
    [alert show];
}

#pragma mark - alertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 10086){   //需要登录
        if(alertView.cancelButtonIndex != buttonIndex){
            ASLoginVc *vc = [[ASLoginVc alloc] init];
            UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
            [[self.nav.viewControllers firstObject] presentViewController:nc animated:YES completion:nil];
        }
    }
}

@end
