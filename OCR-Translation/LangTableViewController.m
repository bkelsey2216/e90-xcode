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

@property (strong, nonatomic) NSArray *langLabels;
@property (strong, nonatomic) NSArray *langCodes;

@end

@implementation LangTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Language Options";
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"colorCell"];
    [self.tableView setContentInset:UIEdgeInsetsMake(50,0,0,0)];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidAppear:(BOOL)paramAnimated{
    [super viewDidAppear:paramAnimated];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    //#warning Incomplete implementation, return the number of rows
    //return 0;
    return [self.langLabels count];
}

- (NSArray *)langLabels
{
    if (!_langLabels) {
        self.langLabels = @[@"Chinese",
                            @"English",
                            @"French",
                            @"German",
                            @"Italian",
                            @"Japanese",
                            @"Latin",
                            @"Spanish"];
        
    }
    return _langLabels;
}

- (NSArray *)langCodes
{
    if (!_langCodes) {
        self.langCodes = @[@"zh",
                           @"en",
                           @"fr",
                           @"de",
                           @"it",
                           @"ja",
                           @"la",
                           @"es"];
        
    }
    return _langCodes;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    self.selectedLanguage = self.langLabels[indexPath.row];
    self.selectedLangCode = self.langCodes[indexPath.row];
    [self performSegueWithIdentifier:@"langSelected" sender:self];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"colorCell" forIndexPath:indexPath];
    
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.textLabel.text = self.langLabels[indexPath.row];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.textLabel.textAlignment = UITextAlignmentCenter;
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
   if ([segue.destinationViewController isKindOfClass:[ImgProcessController class]]) {
       ImgProcessController *mainViewController = segue.destinationViewController;
       mainViewController.takenImage = [self takenImage];

       if (self.selectedLanguage) {
           mainViewController.destLangLabel = self.selectedLanguage;
           mainViewController.destLangCode = self.selectedLangCode;
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
