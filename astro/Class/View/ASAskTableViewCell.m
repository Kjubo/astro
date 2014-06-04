//
//  ASAskTableViewCell.m
//  astro
//
//  Created by kjubo on 14-5-4.
//  Copyright (c) 2014年 kjubo. All rights reserved.
//

#import "ASAskTableViewCell.h"
#import "ASQaMinAstro.h"
#import "ASQaMinBazi.h"
#import "ASQaMinZiWei.h"
#import "ASZiweiGrid.h"
@implementation ASAskTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
        // Initialization code
        self.bg = [[UIView alloc] initWithFrame:CGRectMake(5, 5, 310, 1)];
        self.bg.backgroundColor = [UIColor whiteColor];
        self.bg.layer.borderWidth = 1;
        self.bg.layer.borderColor = [UIColor grayColor].CGColor;
        self.bg.layer.cornerRadius = 8;
        [self.contentView addSubview:self.bg];
        
        self.lbTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 15, 280, 0)];
        self.lbTitle.backgroundColor = [UIColor clearColor];
        self.lbTitle.textColor = ASColorDarkRed;
        self.lbTitle.numberOfLines = 2;
        self.lbTitle.lineBreakMode = NSLineBreakByCharWrapping;
        self.lbTitle.font = [UIFont boldSystemFontOfSize:14];
        [self.contentView addSubview:self.lbTitle];
        
        self.panView = [[ASPanView alloc] initWithFrame:CGRectMake(self.lbTitle.left, 0, self.lbTitle.width, 0)];
        [self.contentView addSubview:self.panView];
        
        self.separated = [[UIView alloc] initWithFrame:CGRectMake(self.lbTitle.left, 0, self.lbTitle.width, 1)];
        self.separated.backgroundColor = ASColorDarkGray;
        [self.contentView addSubview:self.separated];
        
        //-- bottomView SubView
        self.ivReply = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_huifu"]];
        [self.contentView addSubview:self.ivReply];
        
        self.lbReply = [self newBlueLable];
        [self.contentView addSubview:self.lbReply];
        
        self.ivOffer = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_shang"]];
        [self.contentView addSubview:self.ivOffer];
        
        self.lbOffer = [self newBlueLable];
        [self.contentView addSubview:self.lbOffer];
        
        self.lbFrom = [self newBlueLable];
        [self.contentView addSubview:self.lbFrom];
    }
    return self;
}

- (UILabel *)newBlueLable{
    UILabel *lb = [[UILabel alloc] init];
    lb.backgroundColor = [UIColor clearColor];
    lb.font = [UIFont systemFontOfSize:12];
    lb.textColor = ASColorBlue;
    return lb;
}

+ (CGFloat)heightFor:(ASQaBase *)model{
    CGFloat height = 25;
    if([model isKindOfClass:[ASQaMinAstro class]]){
        ASQaMinAstro *obj = (ASQaMinAstro *)model;
        height += 165 *  [obj.Chart count];
    }else if([model isKindOfClass:[ASQaMinBazi class]]){
        ASQaMinBazi *obj = (ASQaMinBazi *)model;
        height += 42 *  [obj.Chart count];
    }else if([model isKindOfClass:[ASQaMinZiWei class]]){
        ASQaMinZiWei *obj = (ASQaMinZiWei *)model;
        if([obj.Chart count] > 0){
            height += __CellSize.height + 8;
        }
    }
    NSString *temp = [NSString stringWithFormat:@"%@\n%@", model.Title, model.Context];
    height += [temp sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(280, CGFLOAT_MAX) lineBreakMode:NSLineBreakByCharWrapping].height;
    height += 40;
    return height;
}

- (void)setModelValue:(id<ASQaProtocol>)model{
    self.lbTitle.text = [model.Title copy];
    self.lbTitle.height = [self.lbTitle.text sizeWithFont:self.lbTitle.font constrainedToSize:CGSizeMake(self.lbTitle.width, 50) lineBreakMode:NSLineBreakByCharWrapping].height;
    CGFloat top = self.lbTitle.bottom + 5;
    
    [self.panView setChart:model.Chart context:[model Context]];
    self.panView.top = top;
    top = self.panView.bottom;
    
    self.separated.top = top;
    top += 5;
    
    self.ivReply.origin = CGPointMake(self.lbTitle.left, top);
    self.lbReply.text = [NSString stringWithFormat:@"%d灵签", model.ReplyCount];
    [self.lbReply sizeToFit];
    self.lbReply.left = self.ivReply.right + 2;
    self.lbReply.centerY = self.ivReply.centerY;
    
    self.ivOffer.origin = CGPointMake(self.lbReply.right + 5, top);
    self.lbOffer.text = [NSString stringWithFormat:@"%d灵签", model.Award];
    [self.lbOffer sizeToFit];
    self.lbOffer.left = self.ivOffer.right + 2;
    self.lbOffer.centerY = self.ivOffer.centerY;
    
    self.lbFrom.text = [NSString stringWithFormat:@"%@ %@", model.CustomerNickName, [model.TS toStrFormat:@"HH:mm"]];
    [self.lbFrom sizeToFit];
    self.lbFrom.right = self.lbTitle.right;
    self.lbFrom.centerY = self.lbReply.centerY;
    
    self.bg.height = self.lbFrom.bottom + 5;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end