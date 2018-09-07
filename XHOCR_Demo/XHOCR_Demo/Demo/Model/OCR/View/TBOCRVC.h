//
//  TBOCRVC.h
//  
//
//  Created by  on 08/01/2018.
//  Copyright © 2018 . All rights reserved.
//



@interface TBOCRInfo : NSObject

@property (nonatomic, assign) TBOCRType type; //1:正面  2:反面
@property (nonatomic, copy) NSString *idCardNumber; //身份证号
@property (nonatomic, copy) NSString *name; //姓名
@property (nonatomic, copy) NSString *gender; //性别
@property (nonatomic, copy) NSString *race; //民族
@property (nonatomic, copy) NSString *address; //地址
@property (nonatomic, copy) NSString *issuedBy; //签发机关
@property (nonatomic, copy) NSString *validDate; //有效期
@property (nonatomic, copy) NSString *birthday;
@property (nonatomic,strong)UIImage *cropImage; // 截图；
/** 服务端图片Id */
@property (nonatomic, copy) NSString *imageId;


@property (nonatomic, copy) NSString *bankNo;
@property (nonatomic, copy) NSString *bankName;
@end

@interface TBOCRVC : UIViewController
- (instancetype)initWithOcrType:(TBOCRType)type;

@property (nonatomic , copy)void (^didScanSuc)(TBOCRInfo *info);
@end

