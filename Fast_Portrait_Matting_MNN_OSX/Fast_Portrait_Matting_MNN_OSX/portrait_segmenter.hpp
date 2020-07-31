//
//  portrait_segmenter.hpp
//  Fast_Portrait_Matting_MNN_OSX
//
//  Created by yuhua.cheng on 2020/7/30.
//  Copyright © 2020 idealabs. All rights reserved.
//

#ifndef portrait_segmenter_hpp
#define portrait_segmenter_hpp

#include <string>

#include <MNN/Interpreter.hpp>
#include <MNN/Tensor.hpp>
#include <MNN/ImageProcess.hpp>
#include <opencv2/opencv.hpp>

class PortraitSegmenter
{
public:
    PortraitSegmenter(const std::string &model_path);
    ~PortraitSegmenter();
    
    void segment(const cv::Mat &image, cv::Mat &mask) const;
private:
    std::shared_ptr<MNN::Interpreter> _Snet;
    MNN::Session *_Snet_sess;
    MNN::Tensor *_Snet_input_tensor = nullptr;
    MNN::Tensor *_Snet_output_tensor = nullptr;
    
    std::shared_ptr<MNN::CV::ImageProcess> pretreat_data;
    const float mean_vals[3] = {127.5f, 127.5f, 127.5f};
    const float norm_vals[3] = {0.0078125f, 0.0078125f, 0.0078125f};
    
    const int input_width = 256;
    const int input_height = 256;
    
    const int num_threads = 2;
    const MNNForwardType forward_type = MNN_FORWARD_CPU;
};

#endif /* portrait_segmenter_hpp */
