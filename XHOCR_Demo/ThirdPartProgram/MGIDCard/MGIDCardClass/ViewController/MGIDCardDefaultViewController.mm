//
//  MGIDCardDefaultViewController.m
//  MGIDCard
//
//  Created by 张英堂 on 16/8/18.
//  Copyright © 2016年 megvii. All rights reserved.
//

#import "MGIDCardDefaultViewController.h"
#import "MGIDCardModel.h"

@implementation MGIDCardDefaultViewController

#pragma mark - Super Detect Result
- (void)detectSucess:(MGIDCardQualityResult *)result{
    [super detectSucess:result];
    
    MGIDCardModel *model = [[MGIDCardModel alloc] initWithResult:result];
    if (self && self.finishBlock){
        self.finishBlock(model);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cancelIDCardDetect{
    [super cancelIDCardDetect];
    
    if (self && self.errorBlcok) {
        self.errorBlcok(MGIDCardErrorCancel);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
