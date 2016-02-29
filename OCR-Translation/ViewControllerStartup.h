//
//  ViewControllerStartup.h
//  OCR-Translation
//
//  Created by Brooke Kelsey on 2/28/16.
//  Copyright © 2016 26775. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewControllerStartup : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>{
    UIImagePickerController *mediaPicker;
    UIImage *processedImage;
}

// button for manually switching to next view - save incase we want to do this later
//@property (strong, nonatomic) IBOutlet UIButton *displayNextView;


- (IBAction)TakePhoto:(id)sender;
- (UIView*)CreateOverlay;

@end

