//
//  ImageProcessor.h
//  InfojobOCR
//
//  Created by Paolo Tagliani on 06/06/12.
//  Copyright (c) 2012 26775. All rights reserved.
//

//
//  OCR-Translation
//  Modified on 05/06/16 by Brooke Kelsey and Gibson Cook
//

#ifndef InfojobOCR_ImageProcessor_h
#define InfojobOCR_ImageProcessor_h

class ImageProcessor {
    
    typedef struct{
        int contador;
        double media;
    }cuadrante;

    
public:
    /*
     To test the implementation I perform a canny on a black white image
     */
    cv::Mat processImage(cv::Mat source, float height);
    
    /*
     Histogram equalization on 1 channel image
     */
    cv::Mat equalize(const cv::Mat&source);
    
    /*
     Binarization made using Adaptive Thresholding
     */
    cv::Mat binarize(const cv::Mat&source);
    
    /*
     Detect if an image is rotated and correct to the proper orientation
     of the text
     */
    int correctRotation (cv::Mat &image, cv::Mat &output, float height);
    
    /*
     Implements the rotation of the image according to the angle passed
     as parameter
     */
    cv::Mat rotateImage(const cv::Mat& source, double angle);
    

};

#endif
