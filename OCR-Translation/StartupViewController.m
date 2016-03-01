//
//  ViewControllerStartup.m
//  OCR-Translation
//
//  Created by Brooke Kelsey on 2/28/16.
//  Copyright © 2016 26775. All rights reserved.
//

#import "StartupViewController.h"
#import "ImgProcVController.h"
#import "UIImage+operation.h"

@interface StartupViewController ()
    @property (strong, nonatomic) UIImage* takenImage;
@end

@implementation StartupViewController

@synthesize takenImage;

// Use button to get to next view - save incase we want to do this later


- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    
    self.title = @"Choose Photo";

// Respond to displayNextView button press - save incase we want to do this later
//    [self.displayNextView
//     addTarget:self action:@selector(performDisplayNextView:)forControlEvents:UIControlEventTouchUpInside];
//    
//    [self.view addSubview:self.displayNextView];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)TakePhoto:(id)sender {
    mediaPicker = [[UIImagePickerController alloc] init];
    mediaPicker.delegate=self;
    mediaPicker.allowsEditing = YES;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:
                                      @"Take a photo or choose existing, and use the control to center the announce"
                                                                 delegate: self                                                        cancelButtonTitle:@"Cancel"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"Take photo", @"Choose Existing", nil];
        [actionSheet showInView:self.view];
    } else {
        mediaPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentModalViewController:mediaPicker animated:YES];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if(buttonIndex != actionSheet.cancelButtonIndex)
    {
        if (buttonIndex == 0) {
            mediaPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        } else if (buttonIndex == 1) {
            mediaPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        
        [self presentModalViewController:mediaPicker animated:YES];
    }
    
    else [self dismissModalViewControllerAnimated:YES];
    
    
}

- (UIView*)CreateOverlay{
    
    UIView *overlay= [[UIView alloc]
                      initWithFrame:CGRectMake
                      (0, 0, self.view.frame.size.width, self.view.frame.size.height*0.10)];//width equal and height 15%
    overlay.backgroundColor=[UIColor blackColor];
    overlay.alpha=0.5;
    
    return overlay;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    [picker dismissModalViewControllerAnimated:YES];
    
    //I take the coordinate of the cropping
    CGRect croppedRect=[[info objectForKey:UIImagePickerControllerCropRect] CGRectValue];
    
    UIImage *original=[info objectForKey:UIImagePickerControllerOriginalImage];
    
    UIImage *rotatedCorrectly;
    
    if (original.imageOrientation!=UIImageOrientationUp)
        rotatedCorrectly=[original rotate:original.imageOrientation];
    else rotatedCorrectly=original;
    
    CGImageRef ref = CGImageCreateWithImageInRect(rotatedCorrectly.CGImage, croppedRect);
    
    self.takenImage = [UIImage imageWithCGImage:ref];
    
    if(self.takenImage == nil)
        NSLog(@"image picker is nil");
    
    // send the selected photo to the image processing view controller.
    [self performSegueWithIdentifier:@"loadViewController1" sender:self];
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
  //   Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"loadViewController1"]){

        ImgProcessController *imgProcView = segue.destinationViewController;
        imgProcView.takenImage = self.takenImage;
//        imgProcView.resultView.image=[self takenImage];
//        imgProcView.processedImage=[self takenImage ];
    }
}


@end
