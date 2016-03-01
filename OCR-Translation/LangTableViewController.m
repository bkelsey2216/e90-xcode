//
//  LangTableViewController.m
//  OCR-Translation
//
//  Created by Brooke Kelsey on 2/29/16.
//  Copyright © 2016 26775. All rights reserved.
//

#import "LangTableViewController.h"
#import "ImgProcVController.h"

@interface LangTableViewController ()

@property (strong, nonatomic) NSArray *colors;

@end

@implementation LangTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Language Options";
    NSLog(@"inside language table view class");
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"colorCell"];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidAppear:(BOOL)paramAnimated{
    [super viewDidAppear:paramAnimated];
    
    NSLog(@"inside language table view did appear");

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {


//#warning Incomplete implementation, return the number of sections
//    return 0;
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    //#warning Incomplete implementation, return the number of rows
    //return 0;
    return [self.colors count];
}

- (NSArray *)colors
{
    if (!_colors) {
        self.colors = @[[UIColor blueColor],
                        [UIColor lightGrayColor],
                        [UIColor cyanColor],
                        [UIColor yellowColor],
                        [UIColor magentaColor],
                        [UIColor purpleColor],
                        [UIColor brownColor],
                        [UIColor redColor],
                        [UIColor grayColor],
                        [UIColor whiteColor],
                        [UIColor orangeColor]];
    }
    return _colors;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedColor = self.colors[indexPath.row];
    [self performSegueWithIdentifier:@"colorSelected" sender:self];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"colorCell" forIndexPath:indexPath];
    
    cell.contentView.backgroundColor = self.colors[indexPath.row];
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
   if ([segue.destinationViewController isKindOfClass:[ImgProcessController class]]) {
       ImgProcessController *mainViewController = segue.destinationViewController;
       mainViewController.takenImage = [self takenImage];

       if (self.selectedColor) {
            mainViewController.backgroundColor = self.selectedColor;
       }
    }
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
