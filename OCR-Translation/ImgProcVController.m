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

@property (strong, nonatomic) NSArray *errorList;

@end

@implementation ImgProcessController


@synthesize takenImage;
@synthesize process;
@synthesize resultView;
@synthesize imageProcessor;
@synthesize read;
@synthesize processedImage;
@synthesize confirmLanguage;
@synthesize takeNewPhoto;


- (void)viewDidLoad
{
    [super viewDidLoad];
    imageProcessor= [[ImageProcessingImplementation alloc]  init];    
    
    self.title = @"Process Image";
    [self designButton:read NSString:@"Translate"];
    [self designButton:process NSString:@"Pre-Process"];
    [self designButton:confirmLanguage NSString:@"Change Language"];
    [self designButton:takeNewPhoto NSString:@"New Photo"];
    
    
    if (self.destLangLabel == nil){
        self.destLangLabel = @"English";
        self.destLangCode = @"en";
    }
        
    self.destLanguage.text = self.destLangLabel;
    self.resultView.image = self.takenImage;
    self.processedImage=[self takenImage ];

}

- (void)viewDidAppear:(BOOL)paramAnimated{
    [super viewDidAppear:paramAnimated];

}

- (void)viewDidUnload
{
    // Release any retained subviews of the main view.
    [self setResultView:nil];
    [self setProcess:nil];
    [self setRead:nil];
    [super viewDidUnload];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    
    if(interfaceOrientation == UIInterfaceOrientationPortrait) return YES;
    else return NO;
}


-(void)designButton:(UIButton*)button
           NSString:label{
    [button setTitle:label forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor clearColor]];
    [button setTitleColor:[UIColor colorWithRed:0 green:1 blue:0.698 alpha:1] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont fontWithName:@"Kohinoor Telugu" size:24.0]];
    button.layer.borderWidth = 3;
    button.layer.borderColor = [[UIColor colorWithRed:0 green:1 blue:0.698 alpha:1] CGColor];
    button.layer.cornerRadius = 10;
    
}


- (IBAction)Pre:(id)sender {
    
    //NSLog(@"Dimension taken image: %f x %f",takenImage.size.width, takenImage.size.height);
    self.processedImage=[imageProcessor processImage:[self takenImage]];
    self.resultView.image=[self processedImage];
    //NSLog(@"Dimension processed image: %f x %f",takenImage.size.width, takenImage.size.height);

    
}

- (NSArray *)errorList
{
    if (!_errorList) {
        self.errorList = @[@"Translation Error\n Unable to Translate - maybe the source and destination languages are the same?",
                           @"Translation Error\n Network error.",
                           @"Translation Error\n Same - maybe the source and destination languages are the same?",
                           @"Translation Error\n Another translation is already in progress.",
                           @"Translation Error\n Already translated.",
                           @"Translation Error\n Invalid credentials - go bug the developers."];
    }
    return _errorList;
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
    
    // preprocess the image
    self.processedImage=[imageProcessor processImage:[self takenImage]];
    
    // run the OCR
    NSString *ocr_result=[imageProcessor OCRImage:[self processedImage]];
    
    NSString* source_lang = nil;
    NSString* dest_lang = self.destLangCode;

    // Google translate gives wrong results for strings that are in all caps -- convert to lowercase
    NSString* translation_input = ocr_result.lowercaseString;
    
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
                                    message:self.errorList[error.code]
                                   delegate:nil
                          cancelButtonTitle:nil
                          otherButtonTitles:@"OK", nil] show]; });
            
                              }
                        else{
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


- (IBAction)confirmLanguage:(id)sender {
    [self performSegueWithIdentifier:@"selectLanguage" sender:self];
}

- (IBAction)takeNewPhoto:(id)sender{
    [self performSegueWithIdentifier:@"newPhoto" sender:self];
}


#pragma mark - Navigation


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    //   Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([segue.identifier isEqualToString:@"selectLanguage"]){
        LangTableViewController *langTableView = segue.destinationViewController;
        langTableView.takenImage = [self takenImage];
        langTableView.view.backgroundColor = [UIColor colorWithRed:0.059 green:0 blue:0.118 alpha:1];
    }
    
    if([segue.identifier isEqualToString:@"newPhoto"]){
        StartupViewController *startView = segue.destinationViewController;
    }
    

}

@end
