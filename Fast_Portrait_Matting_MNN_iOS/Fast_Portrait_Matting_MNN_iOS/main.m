//
//  main.m
//  Fast_Portrait_Matting_MNN_iOS
//
//  Created by yuhua.cheng on 2020/7/31.
//  Copyright © 2020 idealabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

int main(int argc, char * argv[]) {
    NSString * appDelegateClassName;
    @autoreleasepool {
        // Setup code that might create autoreleased objects goes here.
        appDelegateClassName = NSStringFromClass([AppDelegate class]);
    }
    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}
