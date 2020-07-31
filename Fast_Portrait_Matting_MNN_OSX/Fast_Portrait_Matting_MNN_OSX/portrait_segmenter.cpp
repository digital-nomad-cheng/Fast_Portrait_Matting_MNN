//
//  portrait_segmenter.cpp
//  Fast_Portrait_Matting_MNN_OSX
//
//  Created by yuhua.cheng on 2020/7/30.
//  Copyright © 2020 idealabs. All rights reserved.
//

#include "portrait_segmenter.hpp"
PortraitSegmenter::PortraitSegmenter(const std::string &model_path)
{
    this->_Snet = std::shared_ptr<MNN::Interpreter>(MNN::Interpreter::createFromFile(model_path.data()));
    if (this->_Snet == nullptr) {
        std::cout << "Failed to load portrait segmentation model from path " << model_path << std::endl;
    } else {
        std::cout << "Successfully to load model  portrait segmentation model from path" << model_path << std::endl;
    }
    
    MNN::ScheduleConfig config;
    config.type = this->forward_type;
    config.numThread = this->num_threads;
    
    MNN::BackendConfig backend_config;
    backend_config.precision = backend_config.Precision_High;
    backend_config.power = backend_config.Power_High;
    config.backendConfig = &backend_config;
    
    _Snet_sess = _Snet->createSession(config);
    // this->_Snet_input_tensor = this->_Snet->getSessionInput(this->_Snet_sess, "input");
    // this->_Snet_output_tensor = this->_Snet->getSessionOutput(this->_Snet_sess, "output");
    
     this->_Snet_input_tensor = this->_Snet->getSessionInput(this->_Snet_sess, nullptr);
     this->_Snet_output_tensor = this->_Snet->getSessionOutput(this->_Snet_sess, nullptr);
    
    
    // create image preprocessing pipeline
    MNN::CV::ImageProcess::Config config_data;
    config_data.filterType = MNN::CV::BILINEAR;
    ::memcpy(config_data.mean, mean_vals, sizeof(mean_vals));
    ::memcpy(config_data.normal, norm_vals, sizeof(norm_vals));
    config_data.sourceFormat = MNN::CV::BGR;
    config_data.destFormat = MNN::CV::RGB;
    pretreat_data = std::shared_ptr<MNN::CV::ImageProcess>(MNN::CV::ImageProcess::create(config_data));
}

PortraitSegmenter::~PortraitSegmenter()
{
    this->_Snet->releaseModel();
    this->_Snet->releaseSession(this->_Snet_sess);
}


void PortraitSegmenter::segment(const cv::Mat &image, cv::Mat &mask) const
{
    MNN::CV::Matrix trans;
    trans.postScale(1.0f/this->input_width, 1.0f/this->input_height);
    trans.postScale(image.cols, image.rows);
    this->pretreat_data->setMatrix(trans);
    int error_code = this->pretreat_data->convert((uint8_t*)image.data, image.cols, image.rows, 0, this->_Snet_input_tensor);
    if (error_code != 0) {
        return;
    }
    // this->_Snet->resizeSession(_Snet_sess);
    this->_Snet->runSession(this->_Snet_sess);
    int width = this->_Snet_output_tensor->width();
    int height = this->_Snet_output_tensor->height();
    int channels = this->_Snet_output_tensor->channel();
    int batch = this->_Snet_output_tensor->batch();
    auto format = this->_Snet_output_tensor->getDimensionType();
    
    MNN::Tensor host_ouput_tensor(this->_Snet_output_tensor, MNN::Tensor::CAFFE);
    this->_Snet_output_tensor->copyToHostTensor(&host_ouput_tensor);
    mask = cv::Mat(this->input_height, this->input_width, CV_32FC2, host_ouput_tensor.host<float>());
    float *output = this->_Snet_output_tensor->host<float>();
    
    std::vector<cv::Mat> images(2);
    cv::split(mask, images);
    cv::imshow("back", images[1]);
    cv::imshow("fore", images[0]);
}
