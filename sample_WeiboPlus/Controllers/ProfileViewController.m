//
//  ProfileViewController.m
//  ZhiWeiboPhone
//
//  Created by junmin liu on 12-9-1.
//  Copyright (c) 2012年 idfsoft. All rights reserved.
//

#import "ProfileViewController.h"
#import "TweetLable.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Me";
        self.tabBarItem.title = @"Me";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    TweetLable *lable = [[TweetLable alloc] initWithMessage:@"我是haha中文[/20]aa测我是haha中文[/30]aa测试我是haha中文[/40]aa测试"];
    lable.backgroundColor = [UIColor colorWithRed:222/255.f green:235/255.f blue:244/255.f alpha:0.3f];
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(100.0f,100.0f, 150, 100)];
//    view.backgroundColor = [UIColor redColor];
//    [view addSubview:lable];
    [self.view addSubview:lable];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
