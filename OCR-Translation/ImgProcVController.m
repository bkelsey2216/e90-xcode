//
//  ViewController.m
//  infojobOCR
//
//  Created by Paolo Tagliani on 08/06/12.
//  Copyright (c) 2012 26775. All rights reserved.
//
#import "ImgProcVController.h"
#import "StartupViewController.h"
#import "LangTableViewController.h"
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
    
    self.title = @"Process Image";

    
    if (self.destLangLabel == nil){
        self.destLangLabel = @"English";
        self.destLangCode = @"en";
    }
    
    NSLog(self.destLangLabel);
    NSLog(self.destLangCode);
    
    self.destLanguage.text = self.destLangLabel;
    self.resultView.image = self.takenImage;
    self.processedImage=[self takenImage ];
    
    NSLog(@"inside viewDidLoad");
}

- (void)viewDidAppear:(BOOL)paramAnimated{
    [super viewDidAppear:paramAnimated];

    NSLog(@"inside viewDidAppear");
}

- (void)viewDidUnload
{
    // Release any retained subviews of the main view.
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
    translator.preferSourceGuess = YES;
    
    [FGTranslator flushCache];
    
    NSString *ocr_result=[imageProcessor OCRImage:[self processedImage]];
    
    NSString* source_lang = @"en";
    NSString* dest_lang = self.destLangCode;

    // Google translate gives wrong results for strings that are in all caps -- convert to lowercase
    NSString* translation_input = ocr_result.lowercaseString;
    
    NSLog(@"before calling translator block");

    NSLog(self.destLangLabel);
    NSLog(self.destLangCode);
    
//    NSLog(dest_lang);
//    NSLog(translation_input);
    
    dispatch_queue_t worker_queue = dispatch_queue_create("My Queue",NULL);
    dispatch_async(worker_queue, ^{

        [translator translateText:translation_input
                       withSource:source_lang
                           target:dest_lang
                       completion:^(NSError *error, NSString *translated, NSString *sourceLanguage)
                        {if (error){
                                  NSLog(@"translation failed with error: %@", error);
    dispatch_async(dispatch_get_main_queue(), ^{
        [[[UIAlertView alloc] initWithTitle:@""
                                    message:[NSString stringWithFormat:@"Translation Failed\n%@", error]
                                   delegate:nil
                          cancelButtonTitle:nil
                          otherButtonTitles:@"OK", nil] show]; });
            
                              }else{
                                  NSLog(@"translated from %@: %@", sourceLanguage, translated);
          dispatch_async(dispatch_get_main_queue(), ^{
              [[[UIAlertView alloc] initWithTitle:@""
                                          message:[NSString stringWithFormat:@"Translation Successful!\n%@", translated]
                                         delegate:nil
                                cancelButtonTitle:nil
                                otherButtonTitles:@"OK", nil] show]; });
                              }}
         
        ];
        
    });

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

- (IBAction)confirmLanguage:(id)sender {
    [self performSegueWithIdentifier:@"selectLanguage" sender:self];
}

- (IBAction)takeNewPhoto:(id)sender{
    [self performSegueWithIdentifier:@"newPhoto" sender:self];
}


// FOR THE UNWIND DEMO - take out if needed
- (IBAction)unwindFromModalViewController:(UIStoryboardSegue *)segue
{
    if ([segue.sourceViewController isKindOfClass:[LangTableViewController class]]) {
        LangTableViewController *langTableViewConroller = segue.sourceViewController;
        // if the user clicked Cancel, we don't want to change the color
        if (langTableViewConroller.selectedLanguage) {
            self.destLanguage.text = langTableViewConroller.selectedLanguage;
            self.destLangCode = langTableViewConroller.selectedLangCode;
        }
    }
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
              destLanguage:(NSString*)destLanguage
              destLangCode:(NSString*)destLangCode

{
    _backgroundColor = backgroundColor;
    _destLanguage.text = destLanguage;
    _destLangCode = destLangCode;
    self.view.backgroundColor = backgroundColor;

}


#pragma mark - Navigation


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    //   Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([segue.identifier isEqualToString:@"selectLanguage"]){
        LangTableViewController *langTableView = segue.destinationViewController;
        langTableView.takenImage = [self processedImage];
        

    }
    
    if([segue.identifier isEqualToString:@"newPhoto"]){

        StartupViewController *startView = segue.destinationViewController;
        
    }
    

}

@end
