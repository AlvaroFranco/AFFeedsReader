//
//  MainVC.m
//  AFFeedsReader
//
//  Created by Álvaro Franco on 17/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MainVC.h"
#import "ReaderVC.h"
#import "Element.h"
#import "DocumentRoot.h"
#import "UIImageView+WebCache.h"
#import "ODRefreshControl.h"

@implementation MainVC
@synthesize parseResults = _parseResults;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reloadFeed)];
    self.navigationItem.rightBarButtonItem = refreshButton;

    self.title = @"News";
    self.tableView.rowHeight = 150;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLineEtched;
    
    ODRefreshControl *refreshControl = [[ODRefreshControl alloc] initInScrollView:self.tableView];
    [refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
        
    KMXMLParser *parser = [[KMXMLParser alloc] initWithURL:@"http://cultofmac.com.feedsportal.com/c/33797/f/606249/index.rss" delegate:self];
    _parseResults = [parser posts];
        
}

- (void)reloadFeed {
    KMXMLParser *parser = [[KMXMLParser alloc] initWithURL:@"http://cultofmac.com.feedsportal.com/c/33797/f/606249/index.rss" delegate:self];
    _parseResults = [parser posts];
    [self.tableView reloadData];
}

- (void)dropViewDidBeginRefreshing:(ODRefreshControl *)refreshControl
{
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        [refreshControl endRefreshing];
        [self reloadFeed];
    });
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)stripHTMLFromSummary {
    int i = 0;
    int count = self.parseResults.count;
    //cycles through each 'summary' element stripping HTML
    while (i < count) {
        NSString *tempString = [[self.parseResults objectAtIndex:i] objectForKey:@"summary"];
        NSMutableDictionary *dict = [self.parseResults objectAtIndex:i];
        [dict setObject:tempString forKey:@"summary"];
        [self.parseResults replaceObjectAtIndex:i withObject:dict];
        i++;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.parseResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
	NSString *source = [NSString stringWithFormat:[[self.parseResults objectAtIndex:indexPath.row] objectForKey:@"summary"]];

    DocumentRoot *document = [Element parseHTML: source];
	Element *elements = [document selectElement: @"img"];
    NSString* fooAttr = [elements attribute: @"src"];
        
    NSString *snipet = [elements contentsText];
    snipet = ([snipet length]  > 5) ? [snipet substringToIndex: 5] : fooAttr;
    snipet = [[elements description] stringByAppendingFormat: @"%@", fooAttr];
                                
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        UIView *bg = [[UIView alloc]initWithFrame:CGRectMake(0, 50, 320, 50)];
        bg.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
        [cell.contentView addSubview:bg];
        
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont fontWithName:@"Gotham-Regular" size:13];
    }
        
    cell.textLabel.text = [[self.parseResults objectAtIndex:indexPath.row]objectForKey:@"title"];
    
    postImage = [[UIImageView alloc]init];
    postImage.frame = CGRectMake(0, 0, 320, 100);
    postImage.contentMode = UIViewContentModeScaleAspectFill;
    postImage.clipsToBounds = YES;
    cell.backgroundView = postImage;
    
    [postImage setImageWithURL:[NSURL URLWithString:fooAttr] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ReaderVC *vc = [[ReaderVC alloc]init];
    vc.sharedIndex = indexPath.row;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - KMXMLParser Delegate

- (void)parserDidFailWithError:(NSError *)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not parse feed. Check your network connection." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [alert show];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)parserCompletedSuccessfully {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)parserDidBegin {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

@end
