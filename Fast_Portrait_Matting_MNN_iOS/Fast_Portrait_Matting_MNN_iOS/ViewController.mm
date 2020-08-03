//
//  ViewController.m
//  Fast_Portrait_Matting_MNN_iOS
//
//  Created by yuhua.cheng on 2020/7/31.
//  Copyright © 2020 idealabs. All rights reserved.
//
#import <opencv2/opencv.hpp>
#import <opencv2/core/core.hpp>
#import <opencv2/imgcodecs/ios.h>

#import "ViewController.h"
#import "portrait_segmenter.hpp"
#import "HSVideoCamera.h"
#import "GPUImageBackgroundBlurFilter.h"

#import <GPUImage/GPUImageView.h>
#import <GPUImage/GPUImageVideoCamera.h>
#import <GPUImage/GPUImagePicture.h>
#import <GPUImage/GPUImageAlphaBlendFilter.h>
#import <GPUImage/GPUImageBoxBlurFilter.h>

@interface ViewController () <GPUImageVideoCameraDelegate>
{
    PortraitSegmenter *segmenter;
    cv::Mat mask;
}
@property (strong, nonatomic) GPUImageView *gpuImageView;
@property (strong, nonatomic) GPUImagePicture *gpuImagePicture1;
@property (strong, nonatomic) GPUImagePicture *gpuImagePicture2;
@property (nonatomic, strong) GPUImageAlphaBlendFilter *blendFilter;
@property (nonatomic, strong) GPUImageBoxBlurFilter *boxBlurFilter;
@property (nonatomic, strong) GPUImageBackgroundBlurFilter *backgroundBlurFilter;
@property (strong, nonatomic) GPUImagePicture *background;
@property (strong, nonatomic) GPUImagePicture *alpha;
@property (strong, nonatomic) UIImage *alphaImage;
@property (strong, nonatomic) UIImageView *imageView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createPortraitSegmenter];
    UIImage *image = [UIImage imageNamed:@"4.jpg"];
    
    // segmentation
    cv::Mat mask, cv_image;
    UIImageToMat(image, cv_image, true);
    NSLog(@"cv_image channel %d", cv_image.channels());
    cv::cvtColor(cv_image, cv_image, cv::COLOR_RGBA2BGR);
    segmenter->segment(cv_image, mask);
    UIImage *mask_image = MatToUIImage(mask);
    
    // setup GPUImageView
    _gpuImageView = [[GPUImageView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:_gpuImageView];
    
    // GPUImage filter chain
    _gpuImagePicture1 = [[GPUImagePicture alloc] initWithImage:image];
    _gpuImagePicture2 = [[GPUImagePicture alloc] initWithImage:mask_image];
    _blendFilter = [[GPUImageAlphaBlendFilter alloc] init];
    _boxBlurFilter = [[GPUImageBoxBlurFilter alloc] init];
    _backgroundBlurFilter = [[GPUImageBackgroundBlurFilter alloc] init];
    
    [_gpuImagePicture1 addTarget:_boxBlurFilter];
    [_gpuImagePicture1 addTarget:_backgroundBlurFilter];
    [_boxBlurFilter addTarget:_backgroundBlurFilter];
    [_gpuImagePicture2 addTarget:_backgroundBlurFilter];
    [_backgroundBlurFilter addTarget:_gpuImageView];
    [_gpuImagePicture1 processImage];
    [_gpuImagePicture2 processImage];
    
//    [_blendFilter setMix:0.8];
//    [_gpuImagePicture1 addTarget:_blendFilter];
//    [_gpuImagePicture2 addTarget:_blendFilter];
//    [_blendFilter addTarget:_gpuImageView];
//    [_gpuImagePicture1 processImage];
//    [_gpuImagePicture2 processImage];
}

- (void)createPortraitSegmenter
{
    NSString *model_path = [[NSBundle mainBundle] pathForResource:@"prismanet" ofType:@"mnn"];
    const char *path = [model_path UTF8String];
    segmenter = new PortraitSegmenter(path);
}

- (void)willOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    CVImageBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    OSType type = CVPixelBufferGetPixelFormatType(pixelBuffer);
    void *imgBufAddr = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
    int h = (int)CVPixelBufferGetHeight(pixelBuffer);
    int w = (int)CVPixelBufferGetWidth(pixelBuffer);
    size_t stride = CVPixelBufferGetBytesPerRow(pixelBuffer);
    cv::Mat image = cv::Mat(h, w, CV_8UC4, imgBufAddr, stride);
    cv::Mat imageBGR = image;
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    
    segmenter->segment(imageBGR, mask);
    
    _alphaImage = MatToUIImage(mask);
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        _imageView.image = _alphaImage;
    }];
}

@end
