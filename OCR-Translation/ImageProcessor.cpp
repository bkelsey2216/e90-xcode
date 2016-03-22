//
//  ImageProcessor.cpp
//  InfojobOCR
//
//  Created by Paolo Tagliani on 06/06/12.
//  Copyright (c) 2012 26775. All rights reserved.
//

#include <iostream>
#include "ImageProcessor.h"

cv::Mat ImageProcessor::processImage(cv::Mat source, float height){

    // rotate and equalize
    
    if (correctRotation(source, source, height)<0) printf("Error in rotation correction");

    cv::Mat result=equalize(source);

    return result;
    
}

// these 2 filters don't get used -- take out later???
cv::Mat ImageProcessor::filterMedianSmoot(const cv::Mat &source){
    
    cv::Mat results;
    cv::medianBlur(source, results, 3);
    return results;
}

cv::Mat ImageProcessor::filterGaussian(const cv::Mat&source){
    
    cv::Mat results;
    cv::GaussianBlur(source, results, cvSize(3, 3), 0);
    return results;
}

cv::Mat ImageProcessor::equalize(const cv::Mat&source){
    
    
    cv::Mat results;
    
    cv::Ptr<cv::CLAHE> clahe = cv::createCLAHE();
    clahe->setClipLimit(1.0);
    clahe->setTilesGridSize(cv::Size(8,8));
    clahe->apply(source,results);

    return results;
}

// don't use this
cv::Mat ImageProcessor::binarize(const cv::Mat&source){
    
    cv::Mat results;
    int blockDim=MIN( source.size().height/4, source.size().width/4);
    if(blockDim % 2 != 1) blockDim++;   //block has to be odd
    
    printf("%s : %d","Block dimension", blockDim);
    
    
    
    cv::adaptiveThreshold(source, results, 255, cv::ADAPTIVE_THRESH_MEAN_C,
                          cv::THRESH_BINARY,blockDim, 0);
    return results;
    
}

int ImageProcessor::correctRotation(cv::Mat &image, cv::Mat &output, float height)
{
	//calculate the optimum image size
	//It must be large enough to detect good lines if we take the image must be 1296 high is calculated
    
	float prop=0;
    
	prop = height/image.cols;
    
	int cols = image.cols*prop;
	int rows = image.rows*prop;
    
	std::vector<cv::Vec4i> lines;
	cv::Mat resized(cols,rows,CV_8UC1,0);
	cv::Mat dst(cols,rows,CV_8UC1,255);
	cv::Mat original = image.clone();;
	cv::Mat kernel(1,2,CV_8UC1,0);
	cv::Mat kernel2(3,3,CV_8UC1,0);
	
	cv::Size si(0,0);
    
	cv::Canny(image,image,0,100);
	cv::HoughLinesP(image, lines, 1, CV_PI/180, 80, 30, 10 );

	double ang=0;
	cuadrante c[4];
	for (int i =0; i < 4;i++){
		c[i].media = 0;
		c[i].contador = 0;
	}	
	for( size_t i = 0; i < lines.size(); i++ ){
		cv::Vec4i l = lines[i];
		cv::line( dst, cv::Point(l[0], l[1]), cv::Point(l[2], l[3]), cv::Scalar(0,0,0), 3, CV_AA);
		ang =atan2(l[1]-l[3],l[0]-l[2]);
		
		if (ang >= 0 && ang <=CV_PI / 3){
			c[0].media += ang;
			c[0].contador++;
		}else if (ang >(2*CV_PI)/3 && ang <= CV_PI){
			c[1].media += ang;
			c[1].contador++;
		}else if (ang > -1*CV_PI && ang < -2*CV_PI/3){
			c[2].media += ang;
			c[2].contador++;
		}else if (ang > CV_PI/3 && ang < 0){
			c[3].media += ang;
			c[3].contador++;	
		}
		
	}	
	int biggest = 0;
	int bi=0;
	double rot =0;
	double aux;
	for (int i =0; i < 4;i++){
		if (c[i].contador > bi)	{
			biggest = i;
			bi = c[i].contador;
		}
	}	
	
	aux = (180*(c[biggest].media/c[biggest].contador)/CV_PI);
	aux = (aux<0)?-1*aux:aux;	
	if (biggest == 1 || biggest == 2){
		rot = 180 - aux; 
	}else{
		rot = aux; 
	}
	
	if (!(biggest == 0 || biggest == 2)){
		rot = rot *-1;
	}
	
    
	if (rot<-3 || rot > 3){
		image = rotateImage(original, rot);
	}else{
		image = original;
	}
    
	output = image.clone();

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
