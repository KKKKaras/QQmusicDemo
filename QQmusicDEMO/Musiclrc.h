//
//  Musiclrc.h
//  QQmusicDEMO
//
//  Created by invoker on 15/9/25.
//  Copyright © 2015年 invoker. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Musiclrc : NSObject
/**
 时间
 */
@property (nonatomic,strong)NSMutableArray *timeArray;
/**
 歌词
 */
@property (nonatomic,strong)NSMutableArray *wordArray;

/**
 解析歌词
 */
- (void)parselrc;
@end
