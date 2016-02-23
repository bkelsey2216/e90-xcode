//
//  ImageProcessingImplementation.m
//  InfojobOCR
//
//  Created by Paolo Tagliani on 10/05/12.
//  Copyright (c) 2012 26775. All rights reserved.
//

#import "ImageProcessingImplementation.h"
#import "ImageProcessor.h"
#import "UIImage+OpenCV.h"
#import <FGTranslator.h>

@implementation ImageProcessingImplementation


- (NSString*) pathToLangugeFIle{
    
    // Set up the tessdata path. This is included in the application bundle
    // but is copied to the Documents directory on the first run.
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = ([documentPaths count] > 0) ? [documentPaths objectAtIndex:0] : nil;
    
    NSString *dataPath = [documentPath stringByAppendingPathComponent:@"tessdata"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // If the expected store doesn't exist, copy the default store.
    if (![fileManager fileExistsAtPath:dataPath]) {
        // get the path to the app bundle (with the tessdata dir)
        NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
        NSString *tessdataPath = [bundlePath stringByAppendingPathComponent:@"tessdata"];
        if (tessdataPath) {
            [fileManager copyItemAtPath:tessdataPath toPath:dataPath error:NULL];
        }
    }
    
    setenv("TESSDATA_PREFIX", [[documentPath stringByAppendingString:@"/"] UTF8String], 1);
    
    return dataPath;
}


- (UIImage*) processImage:(UIImage*) src{
    
    
    /**
     *  PRE-PROCESSING OF THE IMAGE
     **/
    ImageProcessor processor;
    
    UIImage * processed= [UIImage imageWithCVMat:processor.processImage([src CVGrayscaleMat], src.size.height)];
    
    return processed;

    

}


- (NSString*) OCRImage:(UIImage*)src{
    
    // init the tesseract engine.
    tesseract::TessBaseAPI *tesseract = new tesseract::TessBaseAPI();
    
    tesseract->Init([[self pathToLangugeFIle] cStringUsingEncoding:NSUTF8StringEncoding], "eng");
    
    NSString* path = [[NSBundle mainBundle] pathForResource:@"key"
                                                     ofType:@"txt"];
    NSString* key = [NSString stringWithContentsOfFile:path
                                              encoding:NSUTF8StringEncoding
                                                 error:NULL];
    
    FGTranslator *translator = [[FGTranslator alloc] initWithGoogleAPIKey:key];
    
    
    //Pass the UIIMage to cvmat and pass the sequence of pixel to tesseract

    cv::Mat toOCR=[src CVGrayscaleMat];
    
    NSLog(@"%d", toOCR.channels());
    
    tesseract->SetImage((uchar*)toOCR.data, toOCR.size().width, toOCR.size().height
                        , toOCR.channels(), toOCR.step1());
    
    tesseract->Recognize(NULL);
    
    char* ocr_result = tesseract->GetUTF8Text();
    
    NSString* source_lang = @"en";
    NSString* dest_lang = @"fr";
    NSString* translation_input = [NSString stringWithFormat:@"%s" , ocr_result];
    
    __block NSMutableString* translation_result;
    
    [translator translateText:translation_input
                   withSource:source_lang
                       target:dest_lang
                   completion:^(NSError *error, NSString *translated, NSString *sourceLanguage)
     {if(error){
        
        translation_result = [NSMutableString stringWithString:@"Now we fucked up."];
        NSLog(@"translation failed with error: %@", error);
        }
     else{
        
        translation_result = [NSMutableString stringWithString:@"sup"];
        NSLog(@"translated from %@: %@", sourceLanguage, translated);
     }
     }];

    return [NSString stringWithString:translation_result];
//    return [NSString stringWithUTF8String:ocr_result];
    
}


- (UIImage*) processRotation:(UIImage*)src{
    
    ImageProcessor processor;
    cv::Mat source=[src CVGrayscaleMat];
    processor.correctRotation(source, source, src.size.height);
    UIImage *rotated=[UIImage imageWithCVMat:source];
    return rotated;
    
}

- (UIImage*) processHistogram:(UIImage*)src{
    
    ImageProcessor processor;
    cv::Mat source=[src CVGrayscaleMat];
    cv::Mat output=processor.equalize(source);
    UIImage *equalized=[UIImage imageWithCVMat:output];
    return equalized;
    
}

- (UIImage*) processFilter:(UIImage*)src{
   
    ImageProcessor processor;
    cv::Mat source=[src CVGrayscaleMat];
    cv::Mat output=processor.filterMedianSmoot(source);
    UIImage *filtered=[UIImage imageWithCVMat:output];
    return filtered;
    
}

- (UIImage*) processBinarize:(UIImage*)src{
    
    ImageProcessor processor;
    cv::Mat source=[src CVGrayscaleMat];
    cv::Mat output=processor.binarize(source);
    UIImage *binarized=[UIImage imageWithCVMat:output];
    return binarized;
}


@end
