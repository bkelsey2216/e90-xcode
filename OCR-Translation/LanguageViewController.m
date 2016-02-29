//
//  LanguageViewController.m
//  OCR-Translation
//
//  Created by Brooke Kelsey on 2/29/16.
//  Copyright © 2016 26775. All rights reserved.
//

#import "LanguageViewController.h"
#import "ImgProcVController.h"

@interface LanguageViewController ()

@end

@implementation LanguageViewController

@synthesize takenImage;

- (void)performConfirmLanguage:(id)paramSender{

    [self performSegueWithIdentifier:@"confirmLanguage" sender:self];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    
    self.title = @"Select Language";
    
     //Respond to displayNextView button press - save incase we want to do this later
    [self.confirm
     addTarget:self action:@selector(performConfirmLanguage:)forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:self.confirm];
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString:@"confirmLanguage"]){
    
    ImgProcessController *imgProcView = segue.destinationViewController;
    imgProcView.takenImage = self.takenImage;
    imgProcView.resultView.image=[self takenImage];
    imgProcView.processedImage=[self takenImage ];
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
