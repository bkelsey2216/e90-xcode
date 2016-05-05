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
    return [self.langLabels count];
}

- (NSArray *)langLabels
{
    if (!_langLabels) {
        self.langLabels = @[@"Arabic",
                            @"Chinese",
                            @"English",
                            @"French",
                            @"German",
                            @"Italian",
                            @"Japanese",
                            @"Korean",
                            @"Latin",
                            @"Polish",
                            @"Spanish",
                            @"Welsh"];
    }
    
    return _langLabels;
}

- (NSArray *)langCodes
{
    if (!_langCodes) {
        self.langCodes = @[@"ar",
                           @"zh",
                           @"en",
                           @"fr",
                           @"de",
                           @"it",
                           @"ja",
                           @"ko",
                           @"la",
                           @"pl",
                           @"es",
                           @"cy"];
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
    
    cell.contentView.backgroundColor = [UIColor colorWithRed:0.059 green:0 blue:0.118 alpha:1];
    cell.textLabel.text = self.langLabels[indexPath.row];
    cell.textLabel.textColor = [UIColor colorWithRed:0 green:1 blue:0.698 alpha:1];
    cell.textLabel.font = [UIFont fontWithName:@"Kohinoor Telugu" size:18.0];
    cell.textLabel.backgroundColor = [UIColor colorWithRed:0.059 green:0 blue:0.118 alpha:1];
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

@end
