//
//  ASAskerVc.m
//  astro
//
//  Created by kjubo on 14-2-12.
//  Copyright (c) 2014年 kjubo. All rights reserved.
//

#import "ASAskerVc.h"
#import "ASCategory.h"
#import "ASAskerCell.h"
#import "ASCache.h"
#import "ASPostQuestionVc.h"
#import "ASNav.h"

@interface ASAskerVc ()
@property (nonatomic, strong) NSString *topCateId;
@property (nonatomic, strong) NSMutableArray *catelist;
@property (nonatomic, strong) UITableView *tbList;
@property (nonatomic, strong) UIButton *btnRight;
@property (nonatomic, strong) ASAskerHeaderView *header;
@end

@implementation ASAskerVc

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self setTitle:@"煮酒论命"];
    //导航栏按钮
    self.navigationItem.leftBarButtonItem = nil;
    self.btnRight = [ASControls newDarkRedButton:CGRectMake(0, 0, 80, 28) title:@""];
    [self.btnRight addTarget:self action:@selector(btnClick_post) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.btnRight];
    
    //tableheader view
    self.header = [[ASAskerHeaderView alloc] initWithItems:@[@"小白鼠区", @"学习研究"]];
    self.header.delegate = self;
    
    //table
    self.tbList = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.width, self.contentView.height) style:UITableViewStylePlain];
    self.tbList.backgroundColor = [UIColor clearColor];
    self.tbList.separatorColor = [UIColor clearColor];
    self.tbList.tableHeaderView = self.header;
    self.tbList.delegate = self;
    self.tbList.dataSource = self;
    [self.contentView addSubview:self.tbList];
    
    self.header.selected = 0;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tbList.frame = self.contentView.bounds;
    [self loadRightButtonTitle];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL) hidesBottomBarWhenPushed
{
    return (self.navigationController.topViewController != self);
}

- (void)btnClick_post{
    if([ASGlobal isLogined]){
        [self navTo:vcPostQuestion];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您需要登录后才能发帖！" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"登录", nil];
        alert.tag = NSAlertViewNeedLogin;
        [alert show];
    }
}

- (void)notification_UserLogined:(NSNotification *)sender{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:sender.name object:nil];
    if([ASGlobal isLogined]){
        [self btnClick_post];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag == NSAlertViewNeedLogin
       && alertView.cancelButtonIndex != buttonIndex){
        UINavigationController *nc = [[ASNav shared] newNav:vcLogin];
        [self presentViewController:nc animated:YES completion:^{
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notification_UserLogined:) name:Notification_LoginUser object:nil];
        }];
    }
}

- (void)loadRightButtonTitle{
    if([self.topCateId intValue] == 1){
        [self.btnRight setTitle:@"我要求测" forState:UIControlStateNormal];
    }else if([self.topCateId intValue] == 2){
        [self.btnRight setTitle:@"我要发帖" forState:UIControlStateNormal];
    }
//    else{
//        [self.btnRight setTitle:@"发起咨询" forState:UIControlStateNormal];
//    }
}

#pragma mark - ASAskerHeaderViewDelegate
- (void)askerHeaderSelected:(NSInteger)tag{
    if(tag == 0){
        self.topCateId = @"1";
    }else if(tag == 1){
        self.topCateId = @"2";
    }
//    else{
//        self.topCateId = @"17";
//    }
    [self loadRightButtonTitle];
    
    NSDictionary *params = @{@"parent" : self.topCateId};
    [self showWaiting];
    [HttpUtil load:kUrlGetCates params:params completion:^(BOOL succ, NSString *message, id json) {
        [self hideWaiting];
        if(succ){
            self.catelist = [ASCategory arrayOfModelsFromDictionaries:json];
            [[ASCache shared] storeValue:[self.catelist toJSONString] dir:NSStringFromClass([ASCategory class]) key:self.topCateId];
            [self hideWaiting];
            [self.tbList reloadData];
        }else{
            [self alert:message];
        }
    }];
}

#pragma mark - UITableView Delegate & Data Source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.catelist count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ASAskerCell *cell = [tableView dequeueReusableCellWithIdentifier:self.pageKey];
    if(!cell){
        cell = [[ASAskerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:self.pageKey];
    }
    ASCategory *cate = [self.catelist objectAtIndex:indexPath.row];
    
    [cell.icon load:cate.Pic cacheDir:self.pageKey];
    [cell.lbTitle setText:[NSString stringWithFormat:@"%@（%@）", cate.Name, @(cate.QuestNum)]];
    [cell.lbSummary setText:[NSString stringWithFormat:@"%@", cate.Intro]];
    [cell.lbSummary alignTop];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ASCategory *cate = [self.catelist objectAtIndex:indexPath.row];
    [self navTo:vcAskList params:@{@"topCateId" : self.topCateId,
                                   @"cate"      : Int2String(cate.SysNo),
                                   @"title"     : cate.Name}];
}

@end
