//
//  ListViewController.m
//  ZhiWeiboPhone
//
//  Created by junmin liu on 12-8-25.
//  Copyright (c) 2012年 idfsoft. All rights reserved.
//

#import "ListViewController.h"

@interface ListViewController ()

@end

@implementation ListViewController
@synthesize statuses = _statuses;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"List";
        self.tabBarItem.title = @"List";
        _statuses = [[NSMutableArray alloc]init];
    }
    return self;
}

- (void)dealloc {
    [_statuses release];
    [super dealloc];
}

- (void)viewDidAppear:(BOOL)animated {
    
    TimelineQuery *query = [TimelineQuery query];
    query.completionBlock = ^(WeiboRequest *request, NSMutableArray *statuses, NSError *error) {
        if (error) {
            //
            NSLog(@"TimelineQuery error: %@, sessionDidExpire: %d", error, request.sessionDidExpire);
        }
        else {
            [_statuses removeAllObjects];
            for (Status *status in statuses) {
                //NSLog(@"status: %@", status.text);
                TweetViewCellLayout *layout = [[[TweetViewCellLayout alloc] init] autorelease];
                layout.status = status;
                [_statuses addObject:layout];
            }
            [self.tableView reloadData];
        }
    };
    
    [query queryTimeline:StatusTimelineFriends count:200];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[Images textureBackgroundImage]];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _statuses.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    TweetViewCellLayout *layout = [_statuses objectAtIndex:indexPath.row];
    if (CGSizeEqualToSize(layout.size, CGSizeZero)) {
        [layout layoutForWidth:self.tableView.bounds.size.width];
    }
    return layout.size.height;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    TweetViewCell *cell = (TweetViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[[TweetViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier]autorelease];
    }
    
    //cell.tweetTextLayer.delegate = self;
    
    TweetViewCellLayout *layout = [_statuses objectAtIndex:indexPath.row];
    cell.layout = layout;
    
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

- (void)didSelectLinkWithTweetLink:(TweetLink *)tweetLink {
    
    NSLog(@"didSelectLinkWithTweetLink: %@, %u", tweetLink.url, tweetLink.linkType);
    
    switch (tweetLink.linkType) {
        case TweetLinkTypeURL:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:tweetLink.url]];
            break;
        case TweetLinkTypeUser:
                        
            //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:tweetLink.url]];
            break;
        case TweetLinkTypeHash:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:tweetLink.url]];
            break;
        case TweetLinkTypeEmail:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:tweetLink.url]];
            break;
            
        default:
            break;
    }
    
    if (tweetLink.linkType == TweetLinkTypeUser) {
        ProfileViewController *profileViewController = [[ProfileViewController alloc]initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:profileViewController animated:YES];
        [profileViewController release];
    }
    
    
    //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.baidu.com"]];
    
    //[[[UIActionSheet alloc] initWithTitle:[url absoluteString] delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Open Link in Safari", nil), nil] showInView:self.view];
}

@end
