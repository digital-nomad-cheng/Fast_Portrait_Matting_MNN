//
//  main.cpp
//  Fast_Portrait_Matting_MNN_OSX
//
//  Created by yuhua.cheng on 2020/7/30.
//  Copyright © 2020 idealabs. All rights reserved.
//

#include <iostream>
#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/video/video.hpp>
#include <opencv2/videoio/videoio.hpp>

#include "portrait_segmenter.hpp"

int main(int argc, const char * argv[]) {
    // insert code here...
    std::cout << "Hello, World!\n";
    const std::string model_path = "/Users/vincent/Documents/Repo/Fast_Portrait_Matting_MNN/prismanet.mnn";
    
    PortraitSegmenter segmenter(model_path);
    
    cv::VideoCapture cap(0);
    if (!cap.isOpened()) {
        std::cout << "Unable to open camera or load video from file" << std::endl;
        return -1;
    }
    cv::Mat curr_frame;
    cv::Mat mask;
    while (1) {
        cap.read(curr_frame);
        segmenter.segment(curr_frame, mask);
        cv::imshow("frame", curr_frame);
        cv::waitKey(10);
    }
    return 0;
}
