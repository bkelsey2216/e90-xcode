//
//  ImageProcessor.cpp
//  InfojobOCR
//
//  Created by Paolo Tagliani on 06/06/12.
//  Copyright (c) 2012 26775. All rights reserved.
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
    std::vector<cv::Vec4i> lines;
    
    float irho = 1.0/8.0;
    int h = image.rows;
    int w = image.cols;
    int num_thetas = 256;
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
    
    unsigned char *iter = (unsigned char*)(text_edges.data);

    
    // Part 1 - build the histogram
    int min_bin;
    int max_bin;
    // j is columns, i is rows
    for(int k = 0; k < num_thetas; k++){
        min_bin = 10000;
        max_bin = 0;
        for(int i = 0; i < h; i++){
            for(int j = 0; j < w; j++){
                unsigned char pixel = iter[text_edges.step * i + j];
                if( ((int)pixel) == 255){
                    int bindex = (-(j-cx)*sin(thetas[k]) + (i-cy)*cos(thetas[k]))*irho + 0.5*bin_max;
                    if(bindex > max_bin)
                        max_bin = bindex;
                    if(bindex < min_bin)
                        min_bin = bindex;
                    
                    // make sure we don't index out of bounds when updating histogram
                    // each histogram goes from [0; bin_max], so array length is bin_max+1
                    assert(bindex >= 0 && bindex <= bin_max);
                    hist[k][bindex]++;
                }
            }
        }
    }
    
    // Part 2 - pick best angle (theta with max num zeros)
    // indexing: hist[k][bin]
    float best_theta;
    int best_num_zeros = 0;
    for(int k = 0; k < num_thetas; k++){
        int num_zeros = 0;
//        printf("\ncurr theta: %f\n", thetas[k]);
        for(int i = 0; i < bin_max+1; i++){
//            printf(" %d", hist[k][i]);
            if(hist[k][i] == 0)
                num_zeros++;
        }
//        printf("\nnum zeros: %d\n", num_zeros);
        if(num_zeros > best_num_zeros){
            best_num_zeros = num_zeros; // keep count of zeros in column with best theta
            best_theta = thetas[k]; // store index of best angle
        }
    }

    
    best_theta = best_theta * (180/M_PI);
//    printf("\nbest num zeros: %d", best_num_zeros);
//    printf("\nbest angle: %f", best_theta);


    //TEMP: DELETE THIS
    double rot = (double)best_theta;
    output = rotateImage(image, rot);


    for(int i = 0; i < num_thetas; i++)
        delete hist[i];
    delete[] hist;
    
    delete[] thetas;
    
	return 0;
}

//int ImageProcessor::correctRotation(cv::Mat &image, cv::Mat &output, float height)
//{
//	//calculate the optimum image size
//	//It must be large enough to detect good lines if we take the image must be 1296 high is calculated
//    
//	float prop=0;
//    
//	prop = height/image.cols;
//    
//	int cols = image.cols*prop;
//	int rows = image.rows*prop;
//    
//	std::vector<cv::Vec4i> lines;
//	cv::Mat resized(cols,rows,CV_8UC1,0);
//	cv::Mat dst(cols,rows,CV_8UC1,255);
//	cv::Mat original = image.clone();;
//	cv::Mat kernel(1,2,CV_8UC1,0);
//	cv::Mat kernel2(3,3,CV_8UC1,0);
//	
//	cv::Size si(0,0);
//    
//	cv::Canny(image,image,0,100);
//	cv::HoughLinesP(image, lines, 1, CV_PI/180, 80, 30, 10 );
//
//	double ang=0;
//	cuadrante c[4];
//	for (int i =0; i < 4;i++){
//		c[i].media = 0;
//		c[i].contador = 0;
//	}	
//	for( size_t i = 0; i < lines.size(); i++ ){
//		cv::Vec4i l = lines[i];
//		cv::line( dst, cv::Point(l[0], l[1]), cv::Point(l[2], l[3]), cv::Scalar(0,0,0), 3, CV_AA);
//		ang =atan2(l[1]-l[3],l[0]-l[2]);
//		
//		if (ang >= 0 && ang <=CV_PI / 3){
//			c[0].media += ang;
//			c[0].contador++;
//		}else if (ang >(2*CV_PI)/3 && ang <= CV_PI){
//			c[1].media += ang;
//			c[1].contador++;
//		}else if (ang > -1*CV_PI && ang < -2*CV_PI/3){
//			c[2].media += ang;
//			c[2].contador++;
//		}else if (ang > CV_PI/3 && ang < 0){
//			c[3].media += ang;
//			c[3].contador++;	
//		}
//		
//	}	
//	int biggest = 0;
//	int bi=0;
//	double rot =0;
//	double aux;
//	for (int i =0; i < 4;i++){
//		if (c[i].contador > bi)	{
//			biggest = i;
//			bi = c[i].contador;
//		}
//	}	
//	
//	aux = (180*(c[biggest].media/c[biggest].contador)/CV_PI);
//	aux = (aux<0)?-1*aux:aux;	
//	if (biggest == 1 || biggest == 2){
//		rot = 180 - aux; 
//	}else{
//		rot = aux; 
//	}
//	
//	if (!(biggest == 0 || biggest == 2)){
//		rot = rot *-1;
//	}
//	
//    
//	if (rot<-3 || rot > 3){
//		image = rotateImage(original, rot);
//	}else{
//		image = original;
//	}
//    
//	output = image.clone();
//
//	return 0;
//}

cv::Mat ImageProcessor::rotateImage(const cv::Mat& source, double angle)
{
    cv::Point2f src_center(source.cols/2.0F, source.rows/2.0F);
    cv::Mat rot_mat = cv::getRotationMatrix2D(src_center, angle, 1.0);
    cv::Mat dst;
    cv::warpAffine(source, dst, rot_mat, source.size());
    return dst;
}
