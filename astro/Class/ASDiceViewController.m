//
//  ASDiceViewController.m
//  astro
//
//  Created by kjubo on 15/1/4.
//  Copyright (c) 2015年 kjubo. All rights reserved.
//

#import "ASDiceViewController.h"
#import "ASDiceView.h"
#import "Paipan.h"
#import "CustomIOSAlertView.h"
#import "ASCache.h"

@implementation ASDiceResult
@end


@interface ASDiceViewController ()<ASDiceViewDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITextField *tfQuestion;
@property (nonatomic, strong) ASDiceView *panView;
@property (nonatomic, strong) UIButton *btnStart;
@property (nonatomic, strong) UITableView *tbResult;
@property (nonatomic, strong) NSMutableArray *arr;
@end

@implementation ASDiceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"占星骰子";
    self.contentView.backgroundColor = UIColorFromRGB(0x083951);
    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bj_01"]];
    [self.contentView addSubview:bg];
    
    self.tfQuestion = [[UITextField alloc] initWithFrame:CGRectMake(10, 15, 205, 32)];
    self.tfQuestion.background = [UIImage imageNamed:@"dice_input"];
    self.tfQuestion.clearButtonMode = UITextFieldViewModeAlways;
    self.tfQuestion.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 28, self.tfQuestion.height)];
    self.tfQuestion.font = [UIFont systemFontOfSize:13];
    self.tfQuestion.textColor = UIColorFromRGB(0x00FFFF);
    self.tfQuestion.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入您要占卜的事情~" attributes:@{NSForegroundColorAttributeName: UIColorFromRGB(0x00FFFF)}];
    self.tfQuestion.leftViewMode = UITextFieldViewModeAlways;
    self.tfQuestion.returnKeyType = UIReturnKeyDone;
    self.tfQuestion.delegate = self;
    [self.contentView addSubview:self.tfQuestion];
    
    self.btnStart = [[UIButton alloc] initWithFrame:CGRectMake(0, 15, 91, 32)];
    [self.btnStart setBackgroundImage:[UIImage imageNamed:@"dice_btn"] forState:UIControlStateNormal];
    [self.btnStart setBackgroundImage:[UIImage imageNamed:@"dice_btn_hl"] forState:UIControlStateHighlighted];
    self.btnStart.right = DF_WIDTH - 5;
    [self.btnStart addTarget:self action:@selector(btnClick_start) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.btnStart];
    
    self.panView = [[ASDiceView alloc] initWithFrame:CGRectMake(0, self.tfQuestion.bottom + 4, 320, 320)];
    self.panView.delegate = self;
    [self.contentView addSubview:self.panView];
    
    UIImageView *ivLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dice_logo"]];
    ivLogo.bottom = self.panView.bottom + 5;
    ivLogo.left = 5;
    [self.contentView addSubview:ivLogo];
    
    self.tbResult = [[UITableView alloc] initWithFrame:CGRectMake(0, self.panView.bottom + 20, DF_WIDTH, 120) style:UITableViewStylePlain];
    self.tbResult.backgroundColor = [UIColor clearColor];
    self.tbResult.separatorColor = [UIColor clearColor];
    self.tbResult.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tbResult.scrollEnabled = NO;
    self.tbResult.rowHeight = 115;
    self.tbResult.delegate = self;
    self.tbResult.dataSource = self;
    [self.contentView addSubview:self.tbResult];
    self.contentView.contentSize = CGSizeMake(self.contentView.width, self.tbResult.bottom + 20);
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard)];
    [self.panView addGestureRecognizer:tap];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.arr = [NSMutableArray array];
    ASCacheObject *cf = [[ASCache shared] readDicFiledsWithDir:self.pageKey key:self.pageKey];
    if (cf) {
        //设置登录信息
        NSData *data = [cf.value dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *tmp = [ASDiceResult arrayOfModelsFromData:data error:nil];
        if([tmp count] > 0){
            [self.arr addObjectsFromArray:tmp];
            [self reloadDataTable];
        }
    }
}

- (void)reloadDataTable{
    [self.tbResult reloadData];
    self.tbResult.height = self.tbResult.contentSize.height;
    self.contentView.contentSize = CGSizeMake(DF_WIDTH, self.tbResult.bottom);
}

- (void)hideKeyBoard{
    [self.tfQuestion resignFirstResponder];
}

- (void)btnClick_start{
    [self hideKeyBoard];
    self.tfQuestion.enabled = NO;
    self.contentView.scrollEnabled = NO;
    [self.panView start];
}

#pragma mark - UITableView Delegate Method
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    [self hideKeyBoard];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return MAX(1, [self.arr count]);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"DiceCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        
        UIImageView *ivBg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, DF_WIDTH - 10, 100)];
        ivBg.image = [[UIImage imageNamed:@"dice_text_bg"] stretchableImageWithLeftCapWidth:30 topCapHeight:30];
        [cell.contentView addSubview:ivBg];
        
        UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(ivBg.left + 20, ivBg.top + 5, ivBg.width -40, ivBg.height - 10)];
        lb.textAlignment = NSTextAlignmentLeft;
        lb.tag = 100;
        lb.backgroundColor = [UIColor clearColor];
        lb.lineBreakMode = NSLineBreakByCharWrapping;
        lb.numberOfLines = 0;
        [cell.contentView addSubview:lb];
    }
    UILabel *lb = (UILabel *)[cell.contentView viewWithTag:100];
    if(indexPath.row < [self.arr count]){
        ASDiceResult *item = self.arr[indexPath.row];
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] init];
        [str appendAttributedString:[[NSAttributedString alloc] initWithString:@"#占卜结果#\n"
                                                                    attributes:@{NSForegroundColorAttributeName : ASColorBlue,
                                                                                 NSFontAttributeName : [UIFont systemFontOfSize:14]}]];
        if([item.question length] > 0){
            NSString *question = [NSString stringWithFormat:@"%@\n", item.question];
            [str appendAttributedString:[[NSAttributedString alloc] initWithString:question
                                                                        attributes:@{NSForegroundColorAttributeName : ASColorDarkGray,
                                                                                     NSFontAttributeName : [UIFont systemFontOfSize:14]}]];
        }
        [str appendAttributedString:[[NSAttributedString alloc] initWithString:item.info
                                                                    attributes:@{NSForegroundColorAttributeName : ASColorBlue,
                                                                                 NSFontAttributeName : [UIFont boldSystemFontOfSize:16]}]];
        lb.attributedText = str;
    }else{
        lb.attributedText = nil;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ASDiceResult *item = self.arr[indexPath.row];
    if(item){
        NSString *html = [NSString stringWithFormat:@"<body style=\"background-color: transparent;\">%@</body>", item.result];
        CustomIOSAlertView *alert = [[CustomIOSAlertView alloc] init];
        UIWebView *wbView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, DF_WIDTH - 40, 240)];
        wbView.opaque = NO;
        wbView.backgroundColor = [UIColor clearColor];
        [wbView loadHTMLString:html baseURL:nil];
        [alert setContainerView:wbView];
        [alert setButtonTitles:@[@"确定"]];
        [alert setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
            [alertView close];
        }];
        [alert show];
    }
}

- (void)addResult:(ASDiceResult *)result{
    if(!result){
        return;
    }
    [self.arr insertObject:result atIndex:0];
    if([self.arr count] > 10){
        self.arr = [NSMutableArray arrayWithArray:[self.arr subarrayWithRange:NSMakeRange(0, 10)]];
    }
    [self saveToCache];
}


- (void)saveToCache{
    if([self.arr count] > 0){
        [[ASCache shared] storeValue:[self.arr toJSONString] dir:self.pageKey key:self.pageKey];
    }
}

#pragma mark - UITextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(textField == self.tfQuestion){
        [self btnClick_start];
    }
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    //limit the size :
    int limit = 40;
    return !([textField.text length]>limit && [string length] > range.length);
}

#pragma mark - ASDiceViewDelegate
- (void)didFinishedDiceView:(ASDiceView *)dv{
    self.tfQuestion.enabled = YES;
    self.contentView.scrollEnabled = YES;
    NSInteger star = self.panView.star + 1;
    NSInteger gong = self.panView.gong + 1;
    NSInteger constellation = self.panView.constellation + 1;
    [HttpUtil load:@"pp/GetDiceInfo"
            params:@{@"star" : @(self.panView.star),
                     @"house" : @(gong),
                     @"constellation" : @(self.panView.constellation)}
        completion:^(BOOL succ, NSString *message, id json) {
            ASDiceResult *item = [[ASDiceResult alloc] init];
            item.question = [self.tfQuestion.text trim];
            item.info = [NSString stringWithFormat:@"%@ %@宫 %@", __AstroStar[star], @(gong), __Constellation[constellation]];
            item.result = json;
            [self addResult:item];
            [self reloadDataTable];
        }];
}

@end
