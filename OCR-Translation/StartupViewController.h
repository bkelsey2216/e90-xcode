//
//  ViewControllerStartup.h
//  OCR-Translation
//
//  Created by Brooke Kelsey on 2/28/16.
//  Copyright © 2016 26775. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StartupViewController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>{
    UIImagePickerController *mediaPicker;
    UIImage *processedImage;
}

@property (strong, nonatomic) IBOutlet UIButton *getPhoto;
- (IBAction)TakePhoto:(id)sender;
- (UIView*)CreateOverlay;

@end

