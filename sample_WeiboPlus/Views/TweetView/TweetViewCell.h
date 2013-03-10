//
//  TweetViewCell.h
//  WeiboPlus
//
//  Created by junmin liu on 12-10-20.
//  Copyright (c) 2012年 idfsoft. All rights reserved.
//

#import "ABTableViewCell.h"
#import "TweetViewCellLayout.h"
#import "ImageDownloader.h"
#import "ImageDownloadReceiver.h"
#import "Images.h"

@protocol TweetViewCellDelegate <NSObject>

@end

@interface TweetViewCell : ABTableViewCell {
    TweetViewCellLayout *_layout;
    ImageDownloader *_downloader;
    ImageDownloadReceiver *_tweetAuthorImageDownloadReceiver;
    ImageDownloadReceiver *_tweetImageDownloadReceiver;
    ImageDownloadReceiver *_retweetAuthorImageDownloadReceiver;
    UIImage *_tweetAuthorImage;
    UIImage *_retweetAuthorImage;
    
    UIImage *_tweetImage;
    
    UIImage *_drawedImage;
    BOOL _isDrawing;
    
    CALayer *_tweetAuthorProfileImageLayer;
    CALayer *_tweetImageLayer;
    CALayer *_retweetAuthorProfileImageLayer;
    
    id<TweetViewCellDelegate> _delegate;
}
@property (nonatomic, retain) TweetViewCellLayout *layout;

@property (nonatomic, assign) id<TweetViewCellDelegate> delegate;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;

- (void)didSelectLinkWithTweetLink:(NSString *)url;

@end
