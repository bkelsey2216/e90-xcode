//
//  ImageProcessor.cpp
//  InfojobOCR
//
//  Created by Paolo Tagliani on 06/06/12.
//  Copyright (c) 2012 26775. All rights reserved.
//

//
//  OCR-Translation
//  Modified on 05/06/16 by Brooke Kelsey and Gibson Cook
//

#include <iostream>
#include <math.h>
#include "ImageProcessor.h"

cv::Mat ImageProcessor::processImage(cv::Mat source, float height){

    // rotate and equalize
    
    if (correctRotation(source, source, height)<0) printf("Error in rotation correction");

    cv::Mat result=equalize(source);

    return result;
    
}

cv::Mat ImageProcessor::equalize(const cv::Mat&source){
    
    
    cv::Mat results;
    
    cv::Ptr<cv::CLAHE> clahe = cv::createCLAHE();
    clahe->setClipLimit(1.0);
    clahe->setTilesGridSize(cv::Size(8,8));
    clahe->apply(source,results);

    return results;
}

// used in correct rotation
cv::Mat ImageProcessor::binarize(const cv::Mat&source){
    
    cv::Mat results;
    int blockDim=MIN( source.size().height/4, source.size().width/4);
    if(blockDim % 2 != 1) blockDim++;   //block has to be odd
    
    printf("%s : %d","Block dimension", blockDim);
    
    
    // TODO: make this otsu?
    cv::threshold(source, results, 0, 255, cv::THRESH_BINARY+cv::THRESH_OTSU);
    
    return results;
    
}

int ImageProcessor::correctRotation(cv::Mat &image, cv::Mat &output, float height)
{
   
    cv::Mat text_edges;
    cv::Size si(0,0);
   
    
    float irho = 1.0/8.0;
    int h = image.rows;
    int w = image.cols;
    int num_thetas = 128;
    int cx = w*0.5;
    int cy = h*0.5;
    
    
    // threshold input image
    text_edges = binarize(image);
    cv::Canny(text_edges, text_edges, 10, 100);
    
    int bin_max = ceil(hypot(h, w)*irho);
    
    // create linspace of thetas
    // between -pi/2 to +pi/2,
    float theta_inc = M_PI/num_thetas;
    float* thetas = new float[num_thetas];
    
    for(int i = 0; i < num_thetas; i++)
        thetas[i] = -(M_PI_2)+(i*theta_inc);
    
    // check that we set the theta bounds correctly
    assert(thetas[0] < -M_PI_2+theta_inc);  // can't compare directly to -pi/2 because of precision problems
    assert(thetas[num_thetas-1] <= M_PI_2);
    
    // ROW COUNT: bin_max
    // COL COUNT: num_thetas
    // initialize memory and set everything to 0
    int** hist = new int*[num_thetas];
    for(int i = 0; i < num_thetas; i++){
        hist[i] = new int[bin_max+1];
        for(int j = 0; j < bin_max+1; j++){
            hist[i][j] = 0;
        }
    }

    
    // new method:
    /*
     
     std::vector of <cv::Point>
     for each y
     for each x
     if edges[y, x]:
     push (x, y) -> edge points
     
     for each theta:
     for each (x, y) in edge points
     stuff
     */

    
    // Part 1 - build the histogram
    unsigned char *iter = (unsigned char*)(text_edges.data);

    std::vector<cv::Point2d> edge_pixels;
    int num_pixels = 0;
    for(int i = 0; i < h; i = i + 2){
        for(int j = 0; j < w; j = j + 2){
            unsigned char pixel = iter[text_edges.step * i + j];
            if( ((int)pixel) == 255){
                cv::Point2d* curr = new cv::Point2d();
                curr->x = j;
                curr->y = i;
                edge_pixels.push_back(*curr);
                num_pixels++;
            }
        }
    }
    
    int min_bin;
    int max_bin;
    clock_t t;
    float sum_time = 0.0;
    for(int k = 0; k < num_thetas; k++){
        min_bin = 10000;
        max_bin = 0;
        t = clock();
        printf ("Calculating num theta %d...\n", k);
        for (std::vector<cv::Point2d>::iterator iter = edge_pixels.begin() ; iter != edge_pixels.end(); ++iter){
            int x = iter->x;
            int y = iter->y;
            int bindex = (-(x-cx)*sin(thetas[k]) + (y-cy)*cos(thetas[k]))*irho + 0.5*bin_max;
            if(bindex > max_bin)
                max_bin = bindex;
            if(bindex < min_bin)
                min_bin = bindex;

        // make sure we don't index out of bounds when updating histogram
        // each histogram goes from [0; bin_max], so array length is bin_max+1
        assert(bindex >= 0 && bindex <= bin_max);
        hist[k][bindex]++;
        }
        
        t = clock() - t;
        sum_time = sum_time + ((float)t)/CLOCKS_PER_SEC;
        printf ("It took me %lu clicks (%f seconds).\n", t, ((float)t)/CLOCKS_PER_SEC);
    }
    
    printf("\n\nTotal Preprocessing time: %f\n", sum_time);
    printf("\n\nNumber of Pixels: %d\n", num_pixels);
    
    
    // Part 2 - pick best angle (theta with max num zeros)
    // indexing: hist[k][bin]
    float best_theta;
    int best_num_zeros = 0;
    for(int k = 0; k < num_thetas; k++){
        int num_zeros = 0;
        for(int i = 0; i < bin_max+1; i++){
            if(hist[k][i] == 0)
                num_zeros++;
        }
        if(num_zeros > best_num_zeros){
            best_num_zeros = num_zeros; // keep count of zeros in column with best theta
            best_theta = thetas[k]; // store index of best angle
        }
    }

    
    best_theta = best_theta * (180/M_PI);

    double rot = (double)best_theta;
    output = rotateImage(image, rot);


    // clean up histogram
    for(int i = 0; i < num_thetas; i++)
        delete hist[i];
    delete[] hist;
    
    delete[] thetas;
    
	return 0;
}

cv::Mat ImageProcessor::rotateImage(const cv::Mat& source, double angle)
{
    cv::Point2f src_center(source.cols/2.0F, source.rows/2.0F);
    cv::Mat rot_mat = cv::getRotationMatrix2D(src_center, angle, 1.0);
    cv::Mat dst;
    cv::warpAffine(source, dst, rot_mat, source.size());
    return dst;
}
