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


- (void)viewDidLoad {
    [super viewDidLoad];
    [self designButton:self.getPhoto];

    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    
    self.title = @"Choose Photo";
}

-(void)designButton:(UIButton*)button{
    [button setTitle:@"Get Photo" forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor clearColor]];
    [button setTitleColor:[UIColor colorWithRed:0 green:1 blue:0.698 alpha:1] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont fontWithName:@"Kohinoor Telugu" size:24.0]];
    button.layer.borderWidth = 3;
    button.layer.borderColor = [[UIColor colorWithRed:0 green:1 blue:0.698 alpha:1] CGColor];
    button.layer.cornerRadius = 10;
    
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
                                      @"Take a photo or choose existing, and center the text in the window."
                                                                 delegate: self                                                  cancelButtonTitle:@"Cancel"
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
                      (0, 0, self.view.frame.size.width, self.view.frame.size.height)];//width equal and height 15%
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
    
    // send the selected photo to the image processing view controller.
    [self performSegueWithIdentifier:@"translateMain" sender:self];
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
  //   Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"translateMain"]){

        ImgProcessController *imgProcView = segue.destinationViewController;
        imgProcView.takenImage = self.takenImage;
    }
}


@end
