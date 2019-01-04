//
//  OpenCVWrapper.m
//  lightbox
//
//  Created by Aaron Spitalny on 12/5/18.
//  Copyright © 2018 Aaron Spitalny. All rights reserved.
//
#import <opencv2/opencv.hpp>
#import "OpenCVWrapper.h"
#include "opencv2/imgcodecs.hpp"
#include "opencv2/highgui.hpp"
#include "opencv2/imgproc.hpp"
#import <opencv2/imgcodecs/ios.h>

using namespace std;
@implementation OpenCVWrapper
+(UIImage *) grayScaleIMage:(UIImage *)image
{
    cv::Mat imageMat;
    cv::Mat greyMat;
    UIImageToMat(image, imageMat);
    cv::cvtColor(imageMat, greyMat, cv::COLOR_BGR2GRAY);
    return MatToUIImage(greyMat);
}

+(UIImage *) getGrabCut:(UIImage *)image
{
    cv::Mat imageMat;
    UIImageToMat(image, imageMat);
    cv::resize(imageMat, imageMat, cv::Size(), 0.5, 0.5);
    cv::cvtColor(imageMat , imageMat ,  cv::COLOR_RGBA2RGB);
    cv::Mat mask;
    mask.create( imageMat.size(), CV_8UC1);
    mask.setTo(cv::Scalar::all(cv::GC_BGD));
    cv::Mat bgdModel, fgdModel;
    //set screen size image ratio
    cv::Size s = imageMat.size();
    double widthRatio = s.width/375.0;
    double heightRatio = s.height/647.0;
    int recX = 32.0 - 1;
    int recY = 84.0 - 25;
    cv::Rect rect = cv::Rect( widthRatio*recX,  heightRatio*recY, widthRatio*312.0, heightRatio*461.0);
    cout << imageMat.size() << endl;
    cout << widthRatio << " " << heightRatio << endl;
    cout << rect.x << " " << rect.y << " " << rect.width << " " << rect.height << endl;
    //use grab cut on input image and rect
    //image must have CV_8UC3 type in function 'grabCut'
    cv::grabCut(imageMat, mask, rect, bgdModel, fgdModel, 1, cv::GC_INIT_WITH_RECT );
    cv::Mat res(imageMat.size(),CV_8UC3, cv::Scalar(255,255,255));
    cv::compare(mask,cv::GC_PR_FGD,mask,cv::CMP_EQ);
    cv::Mat foreground(imageMat.size(),CV_8UC3, cv::Scalar(255,255,255));
    imageMat.copyTo(foreground, mask);
    cv::Mat binMask;
    binMask.create( mask.size(), CV_8UC1 );
    binMask = mask & 1;
    imageMat.copyTo( res, binMask );
    //the rectangle can be used to check if we are using the right rect in grabcut
    //cv::rectangle(res,rect,cv::Scalar(255,0,0),3,8,0);
    cout << "done" << endl;
    return MatToUIImage(res);
}
@end

