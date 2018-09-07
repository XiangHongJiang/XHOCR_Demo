//
//  OCRExampleTableViewController.m
//  XHOCR_Demo
//
//  Created by MrYeL on 2018/9/7.
//  Copyright © 2018年 MrYeL. All rights reserved.
//

#import "OCRExampleTableViewController.h"

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
        case 0:
            break;
        case 1:
            break;
        default:
            break;
    }
    
}
@end
