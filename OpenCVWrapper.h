//
//  OpenCVWrapper.h
//  lightbox
//
//  Created by Aaron Spitalny on 12/5/18.
//  Copyright © 2018 Aaron Spitalny. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface OpenCVWrapper : NSObject
+(UIImage *) grayScaleIMage:(UIImage *)image;
+(UIImage *) getGrabCut:(UIImage *)image;
@end

