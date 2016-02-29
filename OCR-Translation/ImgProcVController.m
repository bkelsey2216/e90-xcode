//
//  ViewController.m
//  infojobOCR
//
//  Created by Paolo Tagliani on 08/06/12.
//  Copyright (c) 2012 26775. All rights reserved.
//
#import "ImgProcVController.h"
#import "ImageProcessingImplementation.h"
#import "UIImage+operation.h"
#import "FGTranslator.h"

@interface ImgProcessController ()

@end

@implementation ImgProcessController


@synthesize takenImage;
@synthesize process;
@synthesize resultView;
@synthesize imageProcessor;
@synthesize read;
@synthesize processedImage;
@synthesize rotateButton;
@synthesize Histogrambutton;
@synthesize FilterButton;
@synthesize BinarizeButton;
@synthesize originalButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
    imageProcessor= [[ImageProcessingImplementation alloc]  init];    
    
    self.title = @"Photo Selection";

    NSLog(@"inside viewDidLoad");

}

// next 2 functions are for switching between 2 view controllers
//- (void)goBack{
//    [self.navigationController popViewControllerAnimated:YES];
//}

- (void)viewDidAppear:(BOOL)paramAnimated{
    [super viewDidAppear:paramAnimated];
    
    NSLog(@"inside viewDidAppear");
    
    self.resultView.image = self.takenImage;
//    NSString *filename = [[NSBundle mainBundle]
//                          pathForResource:@"maine" ofType:@"jpg"];
//    
//    
//    
//    UIImage *input_image = [UIImage imageWithContentsOfFile:filename];
//    resultView.image = input_image;
    
//    [self performSelector:@selector(goBack)
//               withObject:nil
//               afterDelay:5.0f];
}

- (void)viewDidUnload
{
    [self setResultView:nil];
    [self setProcess:nil];
    [self setRead:nil];
    [self setRotateButton:nil];
    [self setRotateButton:nil];
    [self setHistogrambutton:nil];
    [self setFilterButton:nil];
    [self setBinarizeButton:nil];
    [self setOriginalButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    
    if(interfaceOrientation == UIInterfaceOrientationPortrait) return YES;
    else return NO;
}

- (IBAction)Pre:(id)sender {
    
    NSLog(@"Dimension taken image: %f x %f",takenImage.size.width, takenImage.size.height);
    self.processedImage=[imageProcessor processImage:[self takenImage]];
    self.resultView.image=[self processedImage];
    NSLog(@"Dimension processed image: %f x %f",takenImage.size.width, takenImage.size.height);

    
}

- (IBAction)OCR:(id)sender {
    
    NSString* path = [[NSBundle mainBundle] pathForResource:@"key"
                                                     ofType:@"txt"];
    NSString* key = [NSString stringWithContentsOfFile:path
                                              encoding:NSUTF8StringEncoding
                                                 error:NULL];
    
    FGTranslator *translator = [[FGTranslator alloc] initWithGoogleAPIKey:key];
    translator.preferSourceGuess = NO;
    
    [FGTranslator flushCache];
    
    NSString *ocr_result=[imageProcessor OCRImage:[self processedImage]];
    
    NSString* source_lang = @"en";
    NSString* dest_lang = @"de";

    // Google translate gives wrong results for strings that are in all caps -- convert to lowercase
    NSString* translation_input = ocr_result.lowercaseString;
    
    NSLog(@"before calling translator block");
    
    NSLog(translation_input);
    
    __block NSMutableString* translation_result = [NSMutableString stringWithString:@"I'm in main!."];
    
    dispatch_queue_t worker_queue = dispatch_queue_create("My Queue",NULL);
    dispatch_async(worker_queue, ^{
        // Perform long running process
        
        sleep(3);
        translation_result = [NSMutableString stringWithString:@"Now I'm not."];
        
//        [translator translateText:translation_input
//                       withSource:source_lang
//                           target:dest_lang
//                       completion:^(NSError *error, NSString *translated, NSString *sourceLanguage)
//                                      {if (error){
//                                          NSLog(@"translation failed with error: %@", error);
//                                          translation_result = [NSMutableString stringWithString:@"Now we fucked up."];
//                                      }else{
//                                          NSLog(@"translated from %@: %@", sourceLanguage, translated);
//                                          translation_result = [NSMutableString stringWithString:translated];
//                                      }}
//             
//        ];
     
        dispatch_sync(dispatch_get_main_queue(), ^{
            [[[UIAlertView alloc] initWithTitle:@""
                                    message:[NSString stringWithFormat:@"Recognized:\n%@", translation_result]
                                    delegate:nil
                            cancelButtonTitle:nil
                            otherButtonTitles:@"OK", nil] show]; });
        
    });

    
//    [[[UIAlertView alloc] initWithTitle:@""
//                                message:[NSString stringWithFormat:@"Recognized:\n%@", ocr_result]
//                               delegate:nil
//                      cancelButtonTitle:nil
//                      otherButtonTitles:@"OK", nil] show];
}

- (IBAction)PreRotation:(id)sender {
    
    self.processedImage=[imageProcessor processRotation:[self processedImage]];
    self.resultView.image=[self processedImage];
}

- (IBAction)PreHistogram:(id)sender {
    
    self.processedImage=[imageProcessor processHistogram:[self processedImage]];
    self.resultView.image=[self processedImage];
}

- (IBAction)PreFilter:(id)sender {
    
    self.processedImage=[imageProcessor processFilter:[self processedImage]];
    self.resultView.image=[self processedImage];
}

- (IBAction)PreBinarize:(id)sender {
    
    self.processedImage=[imageProcessor processBinarize:[self processedImage]];
    self.resultView.image=[self processedImage];
}

- (IBAction)returnOriginal:(id)sender {
    
    self.processedImage=[self takenImage ];
    self.resultView.image= [self takenImage];
}
                       

// TakePhoto is now handled in ViewControlStartup!!

//- (IBAction)TakePhoto:(id)sender {
//    mediaPicker = [[UIImagePickerController alloc] init];
//    mediaPicker.delegate=self;
//    mediaPicker.allowsEditing = YES;
//    
//    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
//        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:
//                                      @"Take a photo or choose existing, and use the control to center the announce"
//                                                                 delegate: self                                                        cancelButtonTitle:@"Cancel"
//                                                   destructiveButtonTitle:nil
//                                                        otherButtonTitles:@"Take photo", @"Choose Existing", nil];
//        [actionSheet showInView:self.view];
//    } else {
//        mediaPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;     
//        [self presentModalViewController:mediaPicker animated:YES];
//    }
//}
//
//- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
//    
//    if(buttonIndex != actionSheet.cancelButtonIndex)
//    {
//        if (buttonIndex == 0) {
//            mediaPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
//        } else if (buttonIndex == 1) {
//            mediaPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//        }
//        
//        [self presentModalViewController:mediaPicker animated:YES];
//    }
//    
//    else [self dismissModalViewControllerAnimated:YES]; 
//    
//    
//}
//
//- (UIView*)CreateOverlay{
//    
//    UIView *overlay= [[UIView alloc] 
//                      initWithFrame:CGRectMake
//                      (0, 0, self.view.frame.size.width, self.view.frame.size.height*0.10)];//width equal and height 15%
//    overlay.backgroundColor=[UIColor blackColor];
//    overlay.alpha=0.5;
//    
//    return overlay;
//}
//
//- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
//    
//    [picker dismissModalViewControllerAnimated:YES];
//    
//    //I take the coordinate of the cropping
//    CGRect croppedRect=[[info objectForKey:UIImagePickerControllerCropRect] CGRectValue];
//
//    UIImage *original=[info objectForKey:UIImagePickerControllerOriginalImage];
//   
//
//    UIImage *rotatedCorrectly;
//    
//    if (original.imageOrientation!=UIImageOrientationUp)
//    rotatedCorrectly=[original rotate:original.imageOrientation];
//    else rotatedCorrectly=original;
//    
//
//    CGImageRef ref= CGImageCreateWithImageInRect(rotatedCorrectly.CGImage, croppedRect);
//    self.takenImage= [UIImage imageWithCGImage:ref];
//    self.resultView.image=[self takenImage];
//    self.processedImage=[self takenImage ];
//    self.process.hidden=NO;
//    self.BinarizeButton.hidden=NO;
//    self.Histogrambutton.hidden=NO;
//    self.FilterButton.hidden=NO;
//    self.rotateButton.hidden=NO;
//    self.read.hidden=NO;
//    self.originalButton.hidden=NO;
//    
//}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //   Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end
