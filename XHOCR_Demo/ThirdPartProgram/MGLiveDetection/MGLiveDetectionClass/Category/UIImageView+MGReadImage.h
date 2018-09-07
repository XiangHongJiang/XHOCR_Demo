//
//  UIImageView+ReadImage.h
//  LivenessDetection
//
//  Created by megvii on 15/10/9.
//  Copyright © 2015Year megvii. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (MGReadImage)

- (void)MGSetImageWithBlund:(NSString *)imageName;

- (void)MGSetImageWithImageName:(NSString *)imageName;

@end

