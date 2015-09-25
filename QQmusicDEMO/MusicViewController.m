//
//  MusicViewController.m
//  QQmusicDEMO
//
//  Created by invoker on 15/9/24.
//  Copyright © 2015年 invoker. All rights reserved.
//

#import "MusicViewController.h"
#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import "Musiclrc.h"
@interface MusicViewController ()<UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource,AVAudioPlayerDelegate>
{
    UIScrollView *_allScrollView;
    UIView * middleView;
    UIPageControl *pageControl;
    UIImageView *cdView;
    AVAudioPlayer *avAudioPlayer;   //播放器player
    UIProgressView *_playProgress;  //播放进度
    UISlider *volumeSlider;         //声音控制
    NSTimer *timer;                 //监控音频播放进度
    UILabel *startLbl;
    UILabel *endLbl;
    
    
    //歌词相关
    Musiclrc *lrc;
    UITableView *_rightLrc;
    NSInteger currentRow;
    
}
@property(nonatomic,strong)NSString *musicArticle;

@end

@implementation MusicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString * path = [[NSBundle mainBundle] pathForResource:@"gala" ofType:@"mp3"];
    NSURL * mp3URL = [NSURL fileURLWithPath:path];
    
    avAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:mp3URL error:nil];
    //设置代理
    avAudioPlayer.delegate = self;
    
    //设置初始音量大小
    // avAudioPlayer.volume = 1;
    
    //设置音乐播放次数  -1为一直循环
    avAudioPlayer.numberOfLoops = -1;
    
 
     ///歌词
    lrc = [[Musiclrc alloc] init];
    [lrc parselrc];
   // [avAudioPlayer prepareToPlay];
    timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self
                                           selector:@selector(playProgress)
                                           userInfo:nil repeats:YES];
   
    
   
    
    ///
    
    [self.view setBackgroundColor:[UIColor clearColor]];
    //背景部分
    UIImageView *backImgView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
    [backImgView setImage:[UIImage imageNamed:@"gala.jpg"]];
    [backImgView setClipsToBounds:YES];
    [backImgView setContentMode:UIViewContentModeScaleAspectFill];
    backImgView.alpha=0.7;
    [self.view addSubview:backImgView];
    
    UIView *blackView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
    [blackView setBackgroundColor:[UIColor blackColor]];
    blackView.alpha=0.7;
    [self.view addSubview:blackView];
    
    
    //————————————————以上保证最底层————————————————————
    //歌曲名称
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 20, 20)];
    titleLabel.font = [UIFont systemFontOfSize:18.0f];  //UILabel的字体大小
    titleLabel.numberOfLines = 0;  //必须定义这个属性，否则UILabel不会换行
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentLeft;  //文本对齐方式
    //高度固定不折行，根据字的多少计算label的宽度
    NSString *titleString = @"追梦赤子心";
    CGSize titlesize = [self getLableSizeString:titleString andLable:titleLabel];
    
    [titleLabel setFrame:CGRectMake((WIDTH-titlesize.width)/2, 20, titlesize.width, 20)];
    titleLabel.text = titleString;
    [self.view addSubview:titleLabel];
    
    
    
    //中间随着scroolview互动而透明度变化的view
    //{
    //  包括 歌手姓名  歌词
    //}
    middleView=[[UIView alloc]initWithFrame:CGRectMake(0, 64, WIDTH, WIDTH+44)];
    [self.view addSubview:middleView];
    
    UILabel *artileLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    artileLabel.font = [UIFont systemFontOfSize:14.0f];  //UILabel的字体大小
    artileLabel.numberOfLines = 0;  //必须定义这个属性，否则UILabel不会换行
    artileLabel.textColor = [UIColor whiteColor];
    artileLabel.textAlignment = NSTextAlignmentLeft;  //文本对齐方式
    
    //高度固定不折行，根据字的多少计算label的宽度
    NSString *str = @"— Gala —";
    CGSize artileLabelsize = [self getLableSizeString:str andLable:artileLabel];
    
    [artileLabel setFrame:CGRectMake((WIDTH-artileLabelsize.width)/2, 0, artileLabelsize.width, 20)];
    artileLabel.text = str;
    
    [middleView addSubview:artileLabel];
    
    //中间转盘
    cdView = [[UIImageView  alloc]initWithFrame:CGRectMake(20, 50, WIDTH-40, WIDTH-40)];
    [cdView setImage:[UIImage imageNamed:@"gala.jpg"]];
    [cdView setClipsToBounds:YES];
    [cdView setContentMode:UIViewContentModeTopLeft];
    //将图层的边框设置为圆脚
    cdView.layer.cornerRadius=(WIDTH-40)/2;
    cdView.layer.masksToBounds = YES;
    //给图层添加一个有色边框
    cdView.layer.borderWidth = 5;
    cdView.layer.borderColor = [[UIColor colorWithRed:0.090 green:0.086 blue:0.008 alpha:1.000] CGColor];
    [middleView addSubview:cdView];
    
    _allScrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 64, WIDTH, WIDTH+44)];
    //_allScrollView.backgroundColor = [UIColor redColor];
    // 是否支持滑动最顶端
    //    scrollView.scrollsToTop = NO;
    _allScrollView.delegate = self;
    _allScrollView.pagingEnabled=YES;
    [_allScrollView setContentOffset:CGPointMake(WIDTH, 0)];
    // 设置内容大小
    _allScrollView.contentSize = CGSizeMake( WIDTH*3, WIDTH+44);
    [self.view addSubview:_allScrollView];
    
    UIView *scrollViewLeft= [[UIView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, WIDTH+44)];
    _rightLrc=[[UITableView alloc]initWithFrame:CGRectMake(WIDTH*2, 0, WIDTH, WIDTH+44)];
    [_rightLrc registerClass:[UITableViewCell class] forCellReuseIdentifier:@"CELL"];
    _rightLrc.delegate=self;
    _rightLrc.dataSource=self;
    _rightLrc.backgroundColor=[UIColor clearColor];
    [scrollViewLeft setUserInteractionEnabled:YES];
    [scrollViewLeft setBackgroundColor:[UIColor redColor]];
    [_allScrollView addSubview:scrollViewLeft];
    [_allScrollView addSubview:_rightLrc];
    
    //pagecontrol
    pageControl=[[UIPageControl alloc]initWithFrame:CGRectMake((WIDTH-35)/2, WIDTH+100, 35, 10)];
    pageControl.numberOfPages = 3;// 一共显示多少个圆点（多少页）
    pageControl.backgroundColor = [UIColor clearColor];
    // 设置非选中页的圆点颜色
    pageControl.pageIndicatorTintColor = [UIColor blackColor];
    // 设置选中页的圆点颜色
    pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
    // 禁止默认的点击功能
    pageControl.enabled = NO;
    pageControl.currentPage=1;
    [self. view addSubview:pageControl];
    
    //播放控制面板
    UIView *playControlBar=[[UIView alloc]initWithFrame:CGRectMake(0, WIDTH+120, WIDTH, HEIGHT-WIDTH-120)];
    //playControlBar.backgroundColor=[UIColor redColor];
    [self.view addSubview:playControlBar];
    _playProgress =[[UIProgressView alloc]initWithFrame:CGRectMake(35, 10, WIDTH-70, 10)];
    [playControlBar addSubview:_playProgress];
    startLbl=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 35, 20)];
    endLbl=[[UILabel alloc]initWithFrame:CGRectMake(WIDTH-70+35, 0, 35, 20)];
    startLbl.text=@"00:00";
    endLbl.text=@"00:00";
    startLbl.textColor=[UIColor whiteColor];
    endLbl.textColor=[UIColor whiteColor];
    [startLbl setFont:[UIFont systemFontOfSize:12]];
    [endLbl setFont:[UIFont systemFontOfSize:12]];
    [playControlBar addSubview:startLbl];
    [playControlBar addSubview:endLbl];
    
    UIButton *playBtn=[[UIButton alloc]initWithFrame:CGRectMake((WIDTH-40)/2, 30, 40, 40)];
    [playBtn setBackgroundImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    [playControlBar addSubview:playBtn];
    [playBtn addTarget:self action:@selector(playMusic) forControlEvents:UIControlEventTouchDown];
    
    [_rightLrc reloadData];
    
    
}

-(void)playMusic
{
    [avAudioPlayer play];
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
    [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    rotationAnimation.duration = 10;
    rotationAnimation.RepeatCount = 1000;//你可以设置到最大的整数值
    rotationAnimation.cumulative = NO;
    rotationAnimation.removedOnCompletion = NO;
    rotationAnimation.fillMode = kCAFillModeForwards;
    [cdView.layer addAnimation:rotationAnimation forKey:@"Rotation"];
}
- (void)playProgress
{
    //通过音频播放时长的百分比,给progressview进行赋值;
    _playProgress.progress = avAudioPlayer.currentTime/avAudioPlayer.duration;
    
    startLbl.text=[self timeFormatted:avAudioPlayer.currentTime];
    endLbl.text=[self timeFormatted:avAudioPlayer.duration];
    
    for (int i = 0; i < lrc.timeArray.count; i ++) {
        
        NSArray *arr = [lrc.timeArray[i] componentsSeparatedByString:@":"];
        
        CGFloat compTime = [arr[0] integerValue]*60 + [arr[1] floatValue];
        
        if (avAudioPlayer.currentTime > compTime)
        {
            currentRow = i;
            NSLog(@"%d",currentRow);
        }
        else
        {
            break;
        }
    }
    
    [_rightLrc reloadData];
    [_rightLrc scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:currentRow inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    
    
}

- (NSString *)timeFormatted:(int)totalSeconds
{
    
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    
    return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
}

- (CGSize)getLableSizeString:(NSString *)_string andLable:(UILabel *)_lable
{
    CGSize size = [_string sizeWithFont:_lable.font constrainedToSize:CGSizeMake(MAXFLOAT, _lable.frame.size.height)];
    return size;
}
// scrollView 已经滑动
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSLog(@"%f",scrollView.contentOffset.x);
    if(scrollView.contentOffset.x==WIDTH)
    {
        pageControl.currentPage=1;
        [UIView animateWithDuration:0.5 animations:^{
            middleView.alpha=1;
        }];
    }
    if(scrollView.contentOffset.x>WIDTH)
    {
        pageControl.currentPage=2;
        middleView.alpha=WIDTH/scrollView.contentOffset.x-0.5;
        NSLog(@"%f",middleView.alpha);
    }
    if(scrollView.contentOffset.x<WIDTH)
    {
        pageControl.currentPage=0;
    }
}

#pragma mark - TableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return lrc.wordArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CELL"];
    tableView.separatorStyle = NO;
    if (indexPath.row == currentRow)
    {
        cell.textLabel.textColor = [UIColor colorWithRed:0.252 green:1.000 blue:0.533 alpha:1.000];
    }
    else
    {
        cell.textLabel.textColor = [UIColor whiteColor];
    }
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    cell.textLabel.text = lrc.wordArray[indexPath.row];
    cell.backgroundColor=[UIColor clearColor];
    return cell;
}

@end


