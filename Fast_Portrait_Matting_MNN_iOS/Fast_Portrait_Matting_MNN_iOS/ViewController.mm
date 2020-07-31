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


#import <GPUImage/GPUImageView.h>
#import <GPUImage/GPUImageVideoCamera.h>
#import <GPUImage/GPUImagePicture.h>

@interface ViewController () <GPUImageVideoCameraDelegate>
{
    PortraitSegmenter *segmenter;
    cv::Mat mask;
}
@property (strong, nonatomic) GPUImageView *gpuImageView;
@property (strong, nonatomic) HSVideoCamera *videoCamera;
@property (strong, nonatomic) GPUImagePicture *background;
@property (strong, nonatomic) GPUImagePicture *alpha;
@property (strong, nonatomic) UIImage *alphaImage;
@property (strong, nonatomic) UIImageView *imageView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createPortraitSegmenter];
    
    
    _gpuImageView = [[GPUImageView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:_gpuImageView];
    
    // setup VideoCamera
    _videoCamera  = [[HSVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionFront useYuv:NO];
    _videoCamera.outputImageOrientation =  UIInterfaceOrientationLandscapeLeft;
    _videoCamera.delegate = self;
    
    [_videoCamera addTarget:_gpuImageView];
    [_videoCamera startCameraCapture];
     
    UIImage *image = [UIImage imageNamed:@"test.jpg"];
    _imageView = [[UIImageView alloc] initWithImage:image];
    _imageView.frame = self.view.frame;
    [self.gpuImageView addSubview:_imageView];
    
    /*
    UIImage *image = [UIImage imageNamed:@"test.jpg"];
    _imageView = [[UIImageView alloc] initWithImage:image];
    _imageView.frame = self.view.frame;
    [self.view addSubview:_imageView];
    
    cv::Mat mask;
    cv::Mat cv_image;
    UIImageToMat(image, cv_image);
    
    NSLog(@"cv_image channel %d", cv_image.channels());
    cv::cvtColor(cv_image, cv_image, cv::COLOR_RGBA2BGR);
    segmenter->segment(cv_image, mask);
    image = MatToUIImage(mask);
    _imageView.image = image;
     */
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
