//
//  TweetViewCell.m
//  WeiboPlus
//
//  Created by junmin liu on 12-10-20.
//  Copyright (c) 2012年 idfsoft. All rights reserved.
//

#import "TweetViewCell.h"

@interface TweetViewCell() {
}

@property (nonatomic, retain) UIImage *tweetAuthorImage;
@property (nonatomic, retain) UIImage *retweetAuthorImage;
@property (nonatomic, retain) UIImage *tweetImage;
@property (nonatomic, retain) UIImage *drawedImage;

@end

@implementation TweetViewCell
@synthesize delegate = _delegate;
@synthesize layout = _layout;
@synthesize drawedImage = _drawedImage;
@synthesize tweetAuthorImage = _tweetAuthorImage;
@synthesize retweetAuthorImage = _retweetAuthorImage;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        contentView.backgroundColor = [UIColor whiteColor];
        _downloader = [ImageDownloader profileImagesDownloader];
        _tweetAuthorImageDownloadReceiver = [[ImageDownloadReceiver alloc]init];
        _tweetAuthorImageDownloadReceiver.completionBlock = ^(NSData *imageData, NSString *url, NSError *error) {
            [self receiver:_tweetAuthorImageDownloadReceiver didDownloadWithImageData:imageData url:url error:error];
        };
        
        _tweetImageDownloadReceiver = [[ImageDownloadReceiver alloc]init];
        _tweetImageDownloadReceiver.completionBlock = ^(NSData *imageData, NSString *url, NSError *error) {
            [self receiver:_tweetImageDownloadReceiver didDownloadWithImageData:imageData url:url error:error];
        };
        
        _retweetAuthorImageDownloadReceiver = [[ImageDownloadReceiver alloc]init];
        _retweetAuthorImageDownloadReceiver.completionBlock = ^(NSData *imageData, NSString *url, NSError *error) {
            [self receiver:_retweetAuthorImageDownloadReceiver didDownloadWithImageData:imageData url:url error:error];
        };
        _tweetAuthorImage = nil;
        _tweetImage = nil;
        _retweetAuthorImage = nil;
        
        
        _tweetAuthorProfileImageLayer = [self profileImageLayer];
        _retweetAuthorProfileImageLayer = [self profileImageLayer];
        _tweetImageLayer = [self profileImageLayer];
        [contentView.layer addSublayer:_tweetAuthorProfileImageLayer];
        [contentView.layer addSublayer:_retweetAuthorProfileImageLayer];
        [contentView.layer addSublayer:_tweetImageLayer];
    }
    return self;
}

- (void)dealloc {
    [_layout release];
    _tweetAuthorImageDownloadReceiver.completionBlock = nil;
    [_tweetAuthorImageDownloadReceiver release];
    _retweetAuthorImageDownloadReceiver.completionBlock = nil;
    [_retweetAuthorImageDownloadReceiver release];
    [_tweetAuthorImage release];
    [_retweetAuthorImage release];
    [_drawedImage release];
    
    [super dealloc];
}

- (CALayer *)profileImageLayer {
    CALayer *layer = [CALayer layer];
    layer.shouldRasterize = YES;
    //layer.frame = CGRectMake(10, 10, 34, 34);
    layer.cornerRadius = 3.0;
    layer.masksToBounds = YES;
    layer.rasterizationScale = [[UIScreen mainScreen] scale];
    //layer.drawsAsynchronously = YES;
    NSDictionary *actions = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNull null], @"contents", nil];
    layer.actions = actions;
    [actions release];
    return layer;
}

- (void)resetProfileImageLayers {
    _tweetAuthorProfileImageLayer.contents = (id)[self profileHolderImage].CGImage;
    _retweetAuthorProfileImageLayer.contents = (id)[self profileHolderImage].CGImage;
}

- (void)setLayout:(TweetViewCellLayout *)layout {
    if (_layout != layout) {
        [_downloader removeDelegate:_tweetAuthorImageDownloadReceiver forURL:_layout.status.user.profileImageUrl];
        if (_layout.status.retweetedStatus) {
            [_downloader removeDelegate:_retweetAuthorImageDownloadReceiver forURL:_layout.status.retweetedStatus.user.profileImageUrl];
        }
        if (_layout.status.thumbnailImageUrl) {
            [_downloader removeDelegate:_tweetImageDownloadReceiver forURL:_layout.status.thumbnailImageUrl];
        }
        self.tweetAuthorImage = nil;
        self.retweetAuthorImage = nil;
        self.tweetImage = nil;
        _isDrawing = NO;
        self.drawedImage = nil;
        [self performSelectorInBackground:@selector(resetProfileImageLayers) withObject:nil];
        [_layout release];
        _layout = [layout retain];
        
        [CATransaction begin];
        [CATransaction setAnimationDuration:0];
        _tweetAuthorProfileImageLayer.frame = _layout.tweetAuthorProfileImageRect;
        _retweetAuthorProfileImageLayer.frame = _layout.retweetAuthorProfileImageRect;
        _tweetImageLayer.frame = _layout.tweetImageRect;
        [CATransaction commit];
         
        [_downloader activeRequest:_layout.status.user.profileImageUrl delegate:_tweetAuthorImageDownloadReceiver];
        if (_layout.status.retweetedStatus) {
            [_downloader activeRequest:_layout.status.retweetedStatus.user.profileImageUrl delegate:_retweetAuthorImageDownloadReceiver];
        }
        if (_layout.status.thumbnailImageUrl) {
            [_downloader activeRequest:_layout.status.thumbnailImageUrl delegate:_tweetImageDownloadReceiver];
        }
        [self setNeedsDisplay];
        [self setNeedsLayout];
    }
}


- (UIImage *)profileHolderImage {
    static UIImage *profileHolderImage = nil;
    if (!profileHolderImage) {
        UIImage *image = [Images profilePlaceholderOverWhiteImage];
        if (image) {
            CGRect rect = _layout.tweetAuthorProfileImageRect;
            CGRect bounds = rect;
            bounds.origin = CGPointZero;
            UIGraphicsBeginImageContextWithOptions(bounds.size, NO, 0);
            //CGContextRef c = UIGraphicsGetCurrentContext();
            //CGContextScaleCTM(c, scale, scale);
            
            [image drawInRect:bounds];
            profileHolderImage = [UIGraphicsGetImageFromCurrentImageContext() retain];
            
            UIGraphicsEndImageContext();
        }

    }
    return profileHolderImage;
    
}


- (void)displayImage:(UIImage *)image inLayer:(CALayer *)layer {
    if (!_isDrawing) {
//        CGRect bounds = rect;
//        bounds.origin = CGPointZero;
//        UIGraphicsBeginImageContextWithOptions(bounds.size, YES, 0);
//        [image drawInRect:bounds];

        [layer performSelectorInBackground:@selector(setContents:) withObject:(id)image.CGImage];
    }
    
}


- (void)receiver:(ImageDownloadReceiver *)receiver didDownloadWithImageData:(NSData *)imageData
             url:(NSString *)url error:(NSError *) error {
    
    if (error) {
        NSLog(@"imageDownloadFailed: %@, %@", url, [error localizedDescription]);
        return;//
    }
    if (receiver == _tweetAuthorImageDownloadReceiver) {
        self.tweetAuthorImage = [UIImage imageWithData:imageData];
        [self displayImage:self.tweetAuthorImage inLayer:_tweetAuthorProfileImageLayer];
        //[self performSelectorInBackground:@selector(processTweetAuthorImageData:) withObject:imageData];
    }
    else if (receiver == _retweetAuthorImageDownloadReceiver) {
        self.retweetAuthorImage = [UIImage imageWithData:imageData];
        [self displayImage:self.retweetAuthorImage inLayer:_retweetAuthorProfileImageLayer];
        //[self performSelectorInBackground:@selector(processRetweetAuthorImageData:) withObject:imageData];
    }
    else if (receiver == _tweetImageDownloadReceiver) {
        self.tweetImage = [UIImage imageWithData:imageData];
        [self displayImage:self.tweetImage inLayer:_tweetImageLayer];
    }
}



- (void)drawContentInContext:(CGContextRef)context {
    [[Images tweetOuterBackgroundImage]drawInRect:self.bounds];
    if (_layout.status.retweetedStatus) {
        [[Images tweetInnerBackgroundImage] drawInRect:_layout.retweetRect];
    }
    CGContextSaveGState(context);
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    
    CGContextTranslateCTM(context, 0.0f, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0f, -1.0f);
    
    [_layout.tweetDocument drawTextInRect:self.bounds textRect:_layout.tweetTextRect context:context];
    [_layout.tweetAuthorDocument drawTextInRect:self.bounds textRect:_layout.tweetAuthorTextRect context:context];
    if (_layout.status.retweetedStatus) {
        [_layout.retweetDocument drawTextInRect:self.bounds textRect:_layout.retweetTextRect context:context];
        [_layout.retweetAuthorDocument drawTextInRect:self.bounds textRect:_layout.retweetAuthorTextRect context:context];
    }
    CGContextRestoreGState(context);
    
    CGContextSaveGState(context);
    CGContextSetRGBFillColor(context, 187/255.f, 187/255.f, 187/255.f, 1.f);
    
    NSString *timeText = [NSString stringWithFormat:@"%@・%@", [_layout.status statusTimeString], [_layout.status source]];
    [timeText drawInRect:_layout.tweetTimeTextRect withFont:[Fonts statusTimeFont]];
    //UIImage *profileImage = self.tweetAuthorImage ? self.tweetAuthorImage : [self profileHolderImage];
    //[profileImage drawInRect:_layout.tweetAuthorProfileImageRect];
    if (_layout.status.retweetedStatus) {
        timeText = [NSString stringWithFormat:@"%@・%@", [_layout.status.retweetedStatus statusTimeString], [_layout.status.retweetedStatus source]];
        [timeText drawInRect:_layout.retweetTimeTextRect withFont:[Fonts statusTimeFont]];
        //profileImage = self.retweetAuthorImage ? self.retweetAuthorImage : [self profileHolderImage];
        //[profileImage drawInRect:_layout.retweetAuthorProfileImageRect];
    }
    CGContextRestoreGState(context);
}

- (void)drawContentView:(CGRect)rect highlighted:(BOOL)highlighted {
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self drawContentInContext:context];
}



- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"This works...");
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    NSLog(@"x=%f, y=%f", point.x, point.y);
    Boolean isProfileImage = [self checkSelectLinkWithProfileImage:point];
    if (isProfileImage) {
        return;
    }
    TweetLink *link = [self linkAtPoint:point];
    
    if (link) {
        NSLog(@"is link...");
        [self didSelectLinkWithTweetLink:@""];
    } else {
        NSLog(@"is not link...");
    }
    //TweetLink *link = [self linkAtPoint:point];
    //[self didSelectLinkWithTweetLink:@""];
//    self.delegate = self;
//    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectLinkWithTweetLink:)]) {
//            //TweetLink *link = self.activeLink;
//            //[self.delegate tweetLayer:self didSelectLinkWithTweetLink:link];
//            NSLog(@"This works2...");
//            [self.delegate didSelectLinkWithTweetLink:@""];
//        }
}

- (Boolean)checkSelectLinkWithProfileImage:(CGPoint)point {
    if (CGRectContainsPoint(self.layout.tweetAuthorProfileImageRect, point) ) {
        NSLog(@"tweetAuthorProfileImageRect click! id=[%@]", self.layout.status.statusIdString);
        return true;
    } else if (CGRectContainsPoint(self.layout.retweetAuthorProfileImageRect, point) ) {
        NSLog(@"retweetAuthorProfileImageRect click!");
        return true;
    }else if (CGRectContainsPoint(self.layout.tweetAuthorTextRect, point) ) {
        NSLog(@"tweetAuthorTextRect click!");
        return true;
    } else if (CGRectContainsPoint(self.layout.retweetAuthorTextRect, point) ) {
        NSLog(@"retweetAuthorTextRect click!");
        return true;
    }
    return false;
}

- (void)didSelectLinkWithTweetLink:(NSString *)url {
    NSLog(@"This works3...");
    //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.baidu.com"]];
    
    //[[[UIActionSheet alloc] initWithTitle:[url absoluteString] delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Open Link in Safari", nil), nil] showInView:self.view];
}

- (TweetLink *)linkAtPoint:(CGPoint)p {
    CFIndex idx = [self characterIndexAtPoint:p];
    return [self linkAtCharacterIndex:idx];
}

- (CFIndex)characterIndexAtPoint:(CGPoint)point {
    if (!self.layout.tweetDocument.attributedText) {
        return NSNotFound;
    }
    
    if (!CGRectContainsPoint(self.bounds, point)) {
        return NSNotFound;
    }
    
    CGPoint p = point;
    CGRect textRect = self.layout.tweetTextRect;
    if (!CGRectContainsPoint(textRect, p)) {
        return NSNotFound;
    }
    
    p = CGPointMake(p.x - textRect.origin.x, p.y - textRect.origin.y);
    p = CGPointMake(p.x, textRect.size.height - p.y);

    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, textRect);
    CTFrameRef frame = CTFramesetterCreateFrame(self.layout.tweetDocument.framesetter, CFRangeMake(0, [self.layout.tweetDocument.attributedText length]), path, NULL);
    if (frame == NULL) {
        CFRelease(path);
        return NSNotFound;
    }
    
    CFArrayRef lines = CTFrameGetLines(frame);
    NSInteger numberOfLines = CFArrayGetCount(lines);
    if (numberOfLines == 0) {
        CFRelease(frame);
        CFRelease(path);
        return NSNotFound;
    }
    
    NSUInteger idx = NSNotFound;
    
    CGPoint lineOrigins[numberOfLines];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, numberOfLines), lineOrigins);
    
    for (CFIndex lineIndex = 0; lineIndex < numberOfLines; lineIndex++) {
        CGPoint lineOrigin = lineOrigins[lineIndex];
        CTLineRef line = CFArrayGetValueAtIndex(lines, lineIndex);
        
        CGFloat ascent, descent, leading, width;
        width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
        CGFloat yMin = floor(lineOrigin.y - descent);
        CGFloat yMax = ceil(lineOrigin.y + ascent);
        
        if (p.y > yMax) {
            break;
        }
        
        if (p.y >= yMin) {
            if (p.x >= lineOrigin.x && p.x <= lineOrigin.x + width) {
                CGPoint relativePoint = CGPointMake(p.x - lineOrigin.x - descent, p.y); // I am not sure whether we need to minus "descent", Jim
                idx = CTLineGetStringIndexForPosition(line, relativePoint);
                //NSLog(@"index: %d", idx);
                break;
            }
        }
    }
    
    CFRelease(frame);
    CFRelease(path);
    
    return idx;
}

- (TweetLink *)linkAtCharacterIndex:(CFIndex)idx {
    for (TweetLink *link in self.layout.tweetDocument.links) {
        NSRange range = link.range;
        if ((CFIndex)range.location <= idx && idx <= (CFIndex)(range.location + range.length - 1)) {
            return link;
        }
    }
    
    return nil;
}

@end
