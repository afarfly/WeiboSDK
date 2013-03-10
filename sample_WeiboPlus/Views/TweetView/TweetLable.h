//
//  TweetLable.h
//  WeiboPlus
//
//  Created by lucas on 13-2-20.
//  Copyright (c) 2013年 idfsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import <QuartzCore/QuartzCore.h>

@interface TweetLable : UIView {
    NSMutableArray  *_textArray;
    NSString *_text;
    
}

-(id)initWithMessage:(NSString *) message;

@end
