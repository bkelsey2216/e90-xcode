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
#import "FGTranslator.h"

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
    translator.preferSourceGuess = NO;
    
    // remove prior translations - this doesn't need to happen every time
    // maybe we could move it somewhere else for better performance
    [FGTranslator flushCache];
    
    //Pass the UIIMage to cvmat and pass the sequence of pixel to tesseract

    cv::Mat toOCR=[src CVGrayscaleMat];
    
    NSLog(@"num channels for ocr image: %d", toOCR.channels());
    
    tesseract->SetImage((uchar*)toOCR.data, toOCR.size().width, toOCR.size().height
                        , toOCR.channels(), toOCR.step1());
    
    tesseract->Recognize(NULL);
    
    char* ocr_result = tesseract->GetUTF8Text();
    
    // look at casting - this might be a problem
    
    NSString* source_lang = @"en";
    NSString* dest_lang = @"de";
//    NSString* translation_input = @"HEAVY METAL!";
    // Google translate gives wrong results for strings that are in all caps -- convert to lowercase
    NSString* translation_input = [NSString stringWithFormat:@"%s", ocr_result].lowercaseString;
    
    NSLog(@"before calling translator block");

    NSLog(translation_input);
    
    __block NSMutableString* translation_result = [NSMutableString stringWithString:@"I'm empty inside."];
    
    [translator translateText:translation_input
                       withSource:source_lang
                       target:dest_lang
                   completion:^(NSError *error, NSString *translated, NSString *sourceLanguage)
    {
        if (error){
            NSLog(@"translation failed with error: %@", error);
            translation_result = [NSMutableString stringWithString:@"Now we fucked up."];
        }else{
            NSLog(@"translated from %@: %@", sourceLanguage, translated);
            translation_result = [NSMutableString stringWithString:translated];
        }
    }];
    
    // more pausing?? translated gets filled but translation_result doesn't get changed fast enough??
    // while loop.
    
    // THIS GETS PRINTED BEFORE TRANSLATION RESULT RETURNS!!!
    NSLog(@"about to return");
    
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
