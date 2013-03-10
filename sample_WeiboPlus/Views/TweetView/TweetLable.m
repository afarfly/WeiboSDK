//
//  TweetLable.m
//  WeiboPlus
//
//  Created by lucas on 13-2-20.
//  Copyright (c) 2013年 idfsoft. All rights reserved.
//

#import "TweetLable.h"

@implementation TweetLable

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#define BEGIN_FLAG @"[/"
#define END_FLAG @"]"

#define KFacialSizeWidth  18
#define KFacialSizeHeight 18
#define MAX_WIDTH 150

-(id)initWithMessage:(NSString *) message {
    self = [super initWithFrame:CGRectZero];
    [self setText:message];
    return self;
}

- (void)setText:(NSString *)text {
    if (_text != text) {
        _text = text;
        [self explainText:text];
    }
    
}

- (void)explainText:(NSString *)text {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [self getImageRange:_text :array];
    //TweetLable *returnView = [[TweetLable alloc] initWithFrame:CGRectZero];
    NSArray *data = array;
    UIFont *fon = [UIFont systemFontOfSize:13.0f];
    CTFontRef font = CTFontCreateWithName(CFSTR("Helvetica"), 13.0f, NULL);
    CGFloat upX = 0;
    CGFloat X = 0;
    CGFloat Y = 0;
    if (data) {
        for (int i=0;i < [data count];i++) {
            NSString *str=[data objectAtIndex:i];
            NSLog(@"str--->%@",str);
            if ([str hasPrefix: BEGIN_FLAG] && [str hasSuffix: END_FLAG])
            {
                if (upX + KFacialSizeWidth >= MAX_WIDTH) {
                    Y += KFacialSizeHeight;
                    upX = 0;
                    X = MAX_WIDTH;
                }
                NSLog(@"str(image)---->%@",str);
                NSString *imageName=[str substringWithRange:NSMakeRange(2, str.length - 3)];
                UIImageView *img=[[UIImageView alloc]initWithImage:[UIImage imageNamed:imageName]];
                img.frame = CGRectMake(upX, Y, KFacialSizeWidth, KFacialSizeHeight);
                [self addSubview:img];
                [img release];
                upX += KFacialSizeWidth;
                
            } else {
                for (int j = 0; j < [str length]; j++) {
                    NSString *temp = [str substringWithRange:NSMakeRange(j, 1)];
                    CGSize size=[temp sizeWithFont:fon constrainedToSize:CGSizeMake(MAX_WIDTH, 9999)];
                    
                    if (upX + size.width  >= MAX_WIDTH) {
                        Y += KFacialSizeHeight;
                        upX = 0;
                        X = MAX_WIDTH;
                    }
                    
                    CATextLayer *layer = [CATextLayer layer];
                    layer.string = temp;
                    layer.font = font;
                    layer.fontSize = 13.0f;
                    layer.backgroundColor = [UIColor clearColor].CGColor;
                    layer.frame = CGRectMake(upX,Y+2.5,size.width,size.height);
                    [self.layer addSublayer:layer];
                    upX += size.width;
                    //                    UILabel *la = [[UILabel alloc] initWithFrame:CGRectMake(upX,upY,size.width,size.height)];
                    //                    la.font = fon;
                    //                    la.text = temp;
                    //                    la.backgroundColor = [UIColor clearColor];
                    //                    [self addSubview:la];
                    //                    [la release];
                }
            }
        }
    }
    if (X < MAX_WIDTH) X = upX;
    Y += KFacialSizeHeight;
    self.frame = CGRectMake(0.0f,0.0f, X, Y); //@ 需要将该view的尺寸记下，方便以后使用
    NSLog(@"%.1f %.1f", X, Y);
}

-(void)getImageRange:(NSString*)message : (NSMutableArray*)array {
    NSRange range=[message rangeOfString: BEGIN_FLAG];
    NSRange range1=[message rangeOfString: END_FLAG];
    //判断当前字符串是否还有表情的标志。
    if (range.length>0 && range1.length>0) {
        if (range.location > 0) {
            [array addObject:[message substringToIndex:range.location]];
            [array addObject:[message substringWithRange:NSMakeRange(range.location, range1.location+1-range.location)]];
            NSString *str=[message substringFromIndex:range1.location+1];
            [self getImageRange:str :array];
        }else {
            NSString *nextstr=[message substringWithRange:NSMakeRange(range.location, range1.location+1-range.location)];
            //排除文字是“”的
            if (![nextstr isEqualToString:@""]) {
                [array addObject:nextstr];
                NSString *str=[message substringFromIndex:range1.location+1];
                [self getImageRange:str :array];
            }else {
                return;
            }
        }
        
    } else if (message != nil) {
        [array addObject:message];
    }
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    
    NSLog(@"drawRect, %f,%f,%f,%f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
    // Drawing code
}


@end
