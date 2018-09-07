//
//  OCRExampleTableViewController.m
//  XHOCR_Demo
//
//  Created by MrYeL on 2018/9/7.
//  Copyright © 2018年 MrYeL. All rights reserved.
//

#import "OCRExampleTableViewController.h"

#import "TBOCRVC.h"
#import "RectManager.h"

@interface OCRExampleTableViewController ()
/** 数据Array*/
@property (nonatomic, copy) NSArray * dataArray;


@end

@implementation OCRExampleTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"OCR";
    self.dataArray = @[@"身份证识别",@"银行卡识别"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    
    cell.textLabel.text = self.dataArray[indexPath.row];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.row) {
        case 0://获取身份证信息
            [self getIdCardInfo];
            break;
        case 1://获取银行卡信息
            [self getBankCardInfo];
            break;
        default:
            break;
    }
    
}
#pragma mark - Action
- (void)getIdCardInfo {//获取身份证信息
    
    if (!TARGET_IPHONE_SIMULATOR) {
        
        TBOCRVC *ocrVC;
        __weak typeof(self) weakSelf = self;

        ocrVC = [[TBOCRVC alloc]initWithOcrType:TBOCRTypeFace];
        UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:ocrVC];
        [self presentViewController:navi animated:true completion:nil];
        
        ocrVC.didScanSuc = ^(TBOCRInfo *info) {

            [weakSelf showAlertWithData:info withType:TBOCRTypeFace];
            
        };
        
    }
    
    
}
- (void)getBankCardInfo {//获取银行卡信息
    if (!TARGET_IPHONE_SIMULATOR) {
        
        TBOCRVC *ocrVC;
        __weak typeof(self) weakSelf = self;
        ocrVC = [[TBOCRVC alloc]initWithOcrType:TBOCRTypeBank];
        UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:ocrVC];
        [self presentViewController:navi animated:true completion:nil];
        
        ocrVC.didScanSuc = ^(TBOCRInfo *info) {
            
            [weakSelf showAlertWithData:info withType:TBOCRTypeBank];

            
        };
        
    }
    
}
- (void)showAlertWithData:(TBOCRInfo *)info withType:(TBOCRType)type {
    
    NSString *message = nil;

    if (type == TBOCRTypeFace) {

        message = [NSString stringWithFormat:@"\n正面\n姓名：%@\n性别：%@\n民族：%@\n住址：%@\n公民身份证号码：%@\n\n反面\n签发机关：%@\n有效期限：%@",info.name,info.gender,info.race,info.address,info.idCardNumber,info.issuedBy,info.validDate];
        
    }else if (type == TBOCRTypeBank) {
        
        message = [NSString stringWithFormat:@"\n卡号：%@\n开户行：%@\n",info.bankNo,info.bankName];
    };
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"扫描信息" message:message preferredStyle:UIAlertControllerStyleAlert];

    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    
    [alert addAction:cancelAction];
    __weak typeof(self) weakSelf = self;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
       
        [weakSelf presentViewController:alert animated:YES completion:nil];

    });
}

@end
