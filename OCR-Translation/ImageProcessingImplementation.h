//
//  ImageProcessingImplementation.h
//  InfojobOCR
//
//  Created by Paolo Tagliani on 10/05/12.
//  Copyright (c) 2012 26775. All rights reserved.
//

//
//  OCR-Translation
//  Modified on 05/06/16 by Brooke Kelsey and Gibson Cook
//

#import <Foundation/Foundation.h>
#import "ImageProcessingProtocol.h"



@interface ImageProcessingImplementation : NSObject<ImageProcessingProtocol>
- (UIImage*) processImage:(UIImage*) src;
- (NSString*) OCRImage:(UIImage*)src;
- (NSString*) pathToLangugeFIle;
@end
