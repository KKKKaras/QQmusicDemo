//
//  Musiclrc.m
//  QQmusicDEMO
//
//  Created by invoker on 15/9/25.
//  Copyright © 2015年 invoker. All rights reserved.
//

#import "Musiclrc.h"

@implementation Musiclrc
- (instancetype)init
{
    self = [super init];
    if (self) {
        _timeArray = [NSMutableArray array];
        _wordArray = [NSMutableArray array];
    }
    return self;
}

/**
 歌词路径
 */
- (NSString *)getLrcPath{
    return [[NSBundle mainBundle] pathForResource:@"gala" ofType:@"lrc"];
}

/**
 解析歌词
 */
- (void)parselrc{
    NSString *content = [NSString stringWithContentsOfFile:[self getLrcPath] encoding:NSUTF8StringEncoding error:nil];
    
    NSArray *sepArray = [content componentsSeparatedByString:@"["];
    for (int i = 5; i < sepArray.count; i ++) {
        //有两个元素，一个是时间，一个是歌词
        NSArray *arr = [sepArray[i] componentsSeparatedByString:@"]"];
        //NSLog(@"%@",sepArray[i]);
        
        [_timeArray addObject:arr[0]];
        [_wordArray addObject:arr[1]];
        
    }
    
    //NSLog(@"%@",content);
}


@end
