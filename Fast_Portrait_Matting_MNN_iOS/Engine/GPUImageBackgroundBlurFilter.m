//
//  GPUImageBackgroundBlurFilter.m
//  Fast_Portrait_Matting_MNN_iOS
//
//  Created by yuhua.cheng on 2020/8/3.
//  Copyright © 2020 idealabs. All rights reserved.
//

#import "GPUImageBackgroundBlurFilter.h"

NSString *const kGPUImageBackgroundBlurFilterFragmentShaderString = SHADER_STRING
(
 precision highp float;
 varying vec2 textureCoordinate;
 varying vec2 textureCoordinate2;
 varying vec2 textureCoordinate3;
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 uniform sampler2D inputImageTexture3;
 void main()
 {
    // original image
    vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
    // blur image
    vec4 textureColor2 = texture2D(inputImageTexture2, textureCoordinate2);
    // alpha image
    vec4 textureColor3 = texture2D(inputImageTexture3, textureCoordinate3);
    
    gl_FragColor = mix(textureColor, textureColor2, textureColor3.x);
 }
);


@implementation GPUImageBackgroundBlurFilter

- (id)init
{
    if (!(self = [self initWithFragmentShaderFromString:kGPUImageBackgroundBlurFilterFragmentShaderString]))
    {
        return nil;
    }
    return self;
}

- (id)initWithFragmentShaderFromString:(NSString *)fragmentShaderString {
    if (!(self = [super initWithFragmentShaderFromString:fragmentShaderString])) {
        return nil;
    }
    return self;
}

@end
