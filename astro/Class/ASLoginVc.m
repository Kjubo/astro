//
//  ASLoginVc.m
//  astro
//
//  Created by kjubo on 14-1-6.
//  Copyright (c) 2014年 kjubo. All rights reserved.
//

#import "ASLoginVc.h"

@interface ASLoginVc ()
@property (nonatomic, strong) UIScrollView *contentView;
@property (nonatomic, strong) UITextField *tfName;
@property (nonatomic, strong) UITextField *tfPsw;
@property (nonatomic, strong) UIButton *btnSumbit;
@property (nonatomic, strong) UIButton *btnRegister;
@property (nonatomic, strong) UIButton *btnForgot;
@end

@implementation ASLoginVc

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self changeTitle:@"登录"];
    [self changeRightButtonTitle:@"分享"];
    
    //添加键盘监听事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardEvent:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardEvent:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // Do View Layout
    //添加手指点击事件
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.contentView addGestureRecognizer:tap];
    
    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_dl_logo"]];
    icon.centerX = self.view.width * 0.5;
    icon.top = 15;
    [self.contentView addSubview:icon];
    
    CGFloat left = icon.left - 20;
    self.tfName = [self newTextField:CGRectMake(left, icon.bottom + 10, icon.width + 40, 36)];
    self.tfName.placeholder = @"Email/手机号";
    self.tfName.returnKeyType = UIReturnKeyNext;
    self.tfName.keyboardType = UIKeyboardTypeEmailAddress;
    [self.contentView addSubview:self.tfName];
    
    self.tfPsw = [self newTextField:CGRectMake(left, self.tfName.bottom + 10, icon.width + 40, 36)];
    self.tfPsw.secureTextEntry = YES;
    self.tfPsw.placeholder = @"请输入密码";
    self.tfPsw.returnKeyType = UIReturnKeyDone;
    [self.contentView addSubview:self.tfPsw];
    
    self.btnSumbit = [[UIButton alloc] initWithFrame:CGRectMake(self.tfPsw.left, self.tfPsw.bottom + 10, self.tfPsw.width, 40)];
    [self.btnSumbit setBackgroundImage:[[UIImage imageNamed:@"btn_red"] stretchableImageWithLeftCapWidth:10 topCapHeight:10] forState:UIControlStateNormal];
//    [self.btnSumbit setBackgroundImage:[[UIImage imageNamed:@"btn_red_hl"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]  forState:UIControlStateHighlighted];
    self.btnSumbit.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [self.btnSumbit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnSumbit setTitle:@"登录" forState:UIControlStateNormal];
    [self.btnSumbit addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.btnSumbit];
    
    self.btnRegister = [[UIButton alloc] initWithFrame:CGRectMake(self.btnSumbit.left, self.btnSumbit.bottom + 10, self.btnSumbit.width, 40)];
    [self.btnRegister setBackgroundImage:[[UIImage imageNamed:@"btn_mm"] stretchableImageWithLeftCapWidth:10 topCapHeight:10] forState:UIControlStateNormal];
//    [self.btnRegister setBackgroundImage:[[UIImage imageNamed:@"btn_mm_hl"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]  forState:UIControlStateHighlighted];
    self.btnRegister.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [self.btnRegister setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnRegister setTitle:@"注册" forState:UIControlStateNormal];
    [self.btnRegister addTarget:self action:@selector(toRegister) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.btnRegister];
    
    self.btnForgot = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 36)];
    self.btnForgot.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
    self.btnForgot.backgroundColor = [UIColor clearColor];
    self.btnForgot.titleLabel.font = [UIFont systemFontOfSize:14];
    self.btnForgot.right = self.btnRegister.right;
    self.btnForgot.top = self.btnRegister.bottom;
    [self.btnForgot setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.btnForgot setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [self.btnForgot setTitle:@"忘记密码？" forState:UIControlStateNormal];
    [self.btnForgot addTarget:self action:@selector(goForgotPwd) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.btnForgot];
    //下划线
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.btnForgot.width - 4, 1)];
    line.bottom = self.btnForgot.height;
    line.backgroundColor = [UIColor blackColor];
    [self.btnForgot addSubview:line];

    //其他登录分割线
    UILabel *lb = [[UILabel alloc] init];
    lb.backgroundColor = [UIColor clearColor];
    lb.textColor = [UIColor blackColor];
    lb.font = [UIFont systemFontOfSize:14];
    lb.text = @"其他账号登录";
    [lb sizeToFit];
    lb.centerX = self.contentView.width * 0.5;
    lb.top = self.btnForgot.bottom + 15;
    [self.contentView addSubview:lb];
    
    CGFloat lineMargin = 4;
    line = [[UIView alloc] initWithFrame:CGRectMake(self.btnSumbit.left, 0, lb.left - self.btnSumbit.left - lineMargin, 1)];
    line.centerY = lb.centerY;
    line.backgroundColor = [UIColor blackColor];
    [self.contentView addSubview:line];
    
    line = [[UIView alloc] initWithFrame:CGRectMake(lb.right + lineMargin, 0, self.btnSumbit.right - lb.right - lineMargin*2, 1)];
    line.centerY = lb.centerY;
    line.backgroundColor = [UIColor blackColor];
    [self.contentView addSubview:line];

    //其他登录button
    CGFloat buttonLeft = self.btnSumbit.left;
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(buttonLeft, lb.bottom + 10, 40, 60)];
    btn.titleLabel.font = [UIFont systemFontOfSize:10];
    btn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 20, 0);
    [btn setImage:[UIImage imageNamed:@"icon_dl_qq"] forState:UIControlStateNormal];
    
    btn.titleEdgeInsets = UIEdgeInsetsMake(39, -btn.width, 0, 0);
    [btn setTitle:@"腾讯QQ" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(loginByQQ) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:btn];
    
    //其他登录button
    buttonLeft = btn.right + 10;
    btn = [[UIButton alloc] initWithFrame:CGRectMake(buttonLeft, lb.bottom + 10, 40, 60)];
    btn.titleLabel.font = [UIFont systemFontOfSize:10];
    btn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 20, 0);
    [btn setImage:[UIImage imageNamed:@"icon_dl_xl"] forState:UIControlStateNormal];
    
    btn.titleEdgeInsets = UIEdgeInsetsMake(39, -btn.width, 0, 0);
    [btn setTitle:@"新浪微博" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(loginBySina) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:btn];
    
    
}

- (void)login{
    if([self.tfName.text length] == 0){
        [self alert:@"请输入登录Email/手机号"];
        return;
    }
    if([self.tfPsw.text length] == 0){
        [self alert:@"请输入登录密码"];
        return;
    }
    [self hideKeyboard];
}

- (void)loginByQQ{
    [self hideKeyboard];
}

- (void)loginBySina{
    [self hideKeyboard];
}

- (void)toRegister{
    [self hideKeyboard];
}

- (void)goForgotPwd{
    [self hideKeyboard];
}

#pragma mark - KeyBoardEvent Method
- (void)keyboardEvent:(NSNotification *)sender{
    CGSize cSize = self.contentView.contentSize;
    CGRect keyboardFrame;
    [[[sender userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
    if([sender.name isEqualToString:UIKeyboardWillHideNotification]){
        self.contentView.height = self.view.height - self.topView.height;
    }else{
        self.contentView.height = self.view.height + self.topView.height - keyboardFrame.size.height;
        [self.contentView setContentOffset:CGPointMake(0, self.tfName.top - 10) animated:YES];
        
    }
    self.contentView.contentSize = cSize;
}


- (void)hideKeyboard{
    [self.tfName resignFirstResponder];
    [self.tfPsw resignFirstResponder];
}

#pragma mark - UITextFieldDelegate Method
- (UITextField *)newTextField:(CGRect)frame{
    UITextField *tf = [[UITextField alloc] initWithFrame:frame];
    tf.backgroundColor = [UIColor whiteColor];
    tf.borderStyle = UITextBorderStyleBezel;
    tf.layer.borderColor = [UIColor darkGrayColor].CGColor;
    tf.layer.borderWidth = 1;

    tf.textColor = [UIColor blackColor];
    tf.font = [UIFont systemFontOfSize:14];
    tf.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, tf.height)];
    tf.leftViewMode = UITextFieldViewModeAlways;
    tf.clearButtonMode = UITextFieldViewModeAlways;
    tf.delegate = self;
    return tf;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(textField == self.tfName){
        [self.tfPsw becomeFirstResponder];
    }else{
        [self login];
    }
    return YES;
}


@end
