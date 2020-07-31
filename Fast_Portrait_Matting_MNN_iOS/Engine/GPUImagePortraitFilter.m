//
//  GPUImagePortraitFilter.m
//  Fast_Portrait_Matting_MNN_iOS
//
//  Created by yuhua.cheng on 2020/7/31.
//  Copyright © 2020 idealabs. All rights reserved.
//

#import "GPUImagePortraitFilter.h"
/*
NSString *const kGPUImageThreeInputTextureVertexShaderString = SHADER_STRING
(
 attribute vec4 position;
 attribute vec4 inputTextureCoordinate;
 attribute vec4 inputTextureCoordinate2;
 attribute vec4 inputTextureCoordinate3;
 
 varying vec2 textureCoordinate;
 varying vec2 textureCoordinate2;
 varying vec2 textureCoordinate3;
 
 void main()
 {
     gl_Position = position;
     textureCoordinate = inputTextureCoordinate.xy;
     textureCoordinate2 = inputTextureCoordinate2.xy;
     textureCoordinate3 = inputTextureCoordinate3.xy;
 }
);
*/
NSString *const kGPUImagePortraitFilterFragmentShaderString = SHADER_STRING
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
    vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
    vec4 textureColor2 = texture2D(inputImageTexture2, textureCoordinate2);
    float alpha = texture2D(inputImageTexture3, textureCoordinate3);
    
    gl_fragColor = mix(textureColor, textureColor2, alpha);
 }
);

@implementation GPUImagePortraitFilter

- (id)init
{
    if (!(self = [super initWithFragmentShaderFromString:kGPUImagePortraitFilterFragmentShaderString]))
    {
        return nil;
    }
    return self;
}

@end
