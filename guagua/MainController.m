//
//  ViewController.m
//  guagua
//
//  Created by liwei wang on 11/6/15.
//  Copyright (c) 2015 leeway. All rights reserved.
//

#import "MainController.h"
#import "PLLScrathView.h"
#import "selectCharacterViewController.h"
#import <AVFoundation/AVFoundation.h>

#define BROADCAST_SCORE @"score"

@interface MainController ()<UIGestureRecognizerDelegate,AVAudioPlayerDelegate>{
    int startGameSecondsCountDown;
    int endGameSecondsCountDown;
    SystemSoundID shortSound;
    AVAudioPlayer *audioPlayer;
}

/* back button */
@property (strong,nonatomic) UIButton *backBtn;
/* start game timer */
@property (strong,nonatomic) NSTimer *startGameCountDownTimer;
/* end game timer */
@property (strong,nonatomic) NSTimer *endGameCountDownTimer;
/* game start time */
@property (strong,nonatomic) UILabel *startTimeLbl;
/* game end time */
@property (strong,nonatomic) UILabel *endTimeLbl;
/* block view */
@property (strong,nonatomic) UIScrollView *blockView;
/* game score */
@property (strong,nonatomic) UILabel * gameScoreLbl;

/* pop view */
@property (strong,nonatomic) UIImageView * gameOverLogoView;
@property (strong,nonatomic) UIButton *backToSelectedBtn;
@property (strong,nonatomic) UIButton *resumeGameBtn;

///* next view */
//@property (strong,nonatomic) selectCharacterViewController *selectView;

@end

@implementation MainController



#pragma mark - ui load
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self loadParameter];
    [self loadWidget];
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    //can cancel swipe gesture
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    
    
    //    if (_selectView != nil) {
    //        _selectView = nil;
    //    }
}

-(void)viewDidDisappear:(BOOL)animated{
    [_backBtn removeFromSuperview];
    [_startTimeLbl removeFromSuperview];
    [_endTimeLbl removeFromSuperview];
    [_blockView removeFromSuperview];
    [_gameScoreLbl removeFromSuperview];
    [_gameOverLogoView removeFromSuperview];
    [_backToSelectedBtn removeFromSuperview];
    [_resumeGameBtn removeFromSuperview];
    [self.view removeFromSuperview];
    
    [self setStartTimeLbl:nil];
    [self setEndTimeLbl:nil];
    [self setBackBtn:nil];
    [self setBlockView:nil];
    [self setGameScoreLbl:nil];
    [self setGameOverLogoView:nil];
    [self setBackToSelectedBtn:nil];
    [self setResumeGameBtn:nil];
    [self setView:nil];
    [super viewDidDisappear:animated];
    
}

// gesture to cancel swipe (use for ios 8)
-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if([gestureRecognizer isEqual:self.navigationController.interactivePopGestureRecognizer]){
        return  NO;
        
    }else{
        return YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)loadParameter{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameBroadcast:) name:nil object:nil ];
    
    
    //start timer
    startGameSecondsCountDown = 5;
    _startGameCountDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(startGameTimer) userInfo:nil repeats:YES];
    
    
    //background music
    NSString *musicPath = [[NSBundle mainBundle]  pathForResource:[NSString stringWithFormat:@"%@%d",@"game",_selectedNum + 1]    ofType:@"mp3"];
    
    if (musicPath) {
        
        NSURL *musicURL = [NSURL fileURLWithPath:musicPath];
        
        audioPlayer = [[AVAudioPlayer alloc]  initWithContentsOfURL:musicURL  error:nil];
        
        [audioPlayer setDelegate:self];
        
    }
    
    
    if ([audioPlayer isPlaying]) {
        
        // Stop playing audio and change text of button
        
        [audioPlayer stop];
    }    else {
        // Start playing audio and change text of button so
        // user can tap to stop playback
        [audioPlayer play];
        
        
    }
    
    
    
}

-(void)loadWidget{
    
    
    
    
    
    
    // set the background view
    UIImageView* viewBack = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, Drive_Wdith, Drive_Height + 20)];
    [viewBack setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d%@",_selectedNum + 1,@"B"]]];
    [self.view addSubview:viewBack];
    
    // Set up the STScratchView
    PLLScrathView *myView = [[PLLScrathView alloc] initWithFrame:CGRectMake(0,0,Drive_Wdith, Drive_Height + 20) ];
    
    //set the brush size
    myView.sizeBrush = 35;
    [self.view addSubview:myView];
    
    UIImageView *viewFront = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, Drive_Wdith, Drive_Height + 20)];
    [viewFront setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d%@",_selectedNum  + 1 ,@"F"]]];
    // Define the hide view
    [myView setHideView:viewFront];
    
    
    
    //game score
    _gameScoreLbl = [[UILabel alloc]initWithFrame:CGRectMake( (Drive_Wdith - 45) / 2 ,  20, 90, 50)];
    _gameScoreLbl.text = [NSString stringWithFormat:@"%@%@",@"0.0" , @"%"];
    _gameScoreLbl.textColor = [UIColor redColor];
    _gameScoreLbl.font = [UIFont systemFontOfSize:24];
    [self.view addSubview:_gameScoreLbl];
    
    
    
    //back btn
    _backBtn = [[UIButton alloc]initWithFrame:CGRectMake(5,  20, 50, 50)];
    [_backBtn setBackgroundImage:[UIImage imageNamed:@"1B"] forState:UIControlStateNormal];
    [_backBtn addTarget:self action:@selector(backBtn) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_backBtn];
    
    
    //end time label
    _endTimeLbl = [[UILabel alloc] initWithFrame:CGRectMake(Drive_Wdith - 30, 20, 30, 50)];
    _endTimeLbl.textColor = [UIColor redColor];
    _endTimeLbl.font = [UIFont systemFontOfSize:30];
    [self.view addSubview:_endTimeLbl];
    
    
    //block view
    _blockView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, Drive_Wdith, Drive_Height + 20)];
    _blockView.backgroundColor=[UIColor colorWithRed:0.137 green:0.055 blue:0.078 alpha:0.3];
    [_blockView setHidden:NO];
    [self.view addSubview:_blockView];
    
    
    //game start time
    _startTimeLbl = [[UILabel alloc] initWithFrame:CGRectMake((Drive_Wdith - 40) / 2 , Drive_Height / 2 - 25, 80, 50)];
    _startTimeLbl.textColor = [UIColor redColor];
    _startTimeLbl.font = [UIFont systemFontOfSize:60];
    [_blockView addSubview:_startTimeLbl];
    
    
    /**
     *  pop view
     */
    
    _gameOverLogoView = [[UIImageView alloc] initWithFrame:CGRectMake(Drive_Wdith  / 2  - 100, Drive_Height / 2 - 100, 200, 100)];
    _gameOverLogoView.image = [UIImage imageNamed:@"3F"];
    [_gameOverLogoView setHidden:YES];
    [_blockView addSubview:_gameOverLogoView];
    
    
    _backToSelectedBtn = [[UIButton alloc]initWithFrame:CGRectMake(Drive_Wdith / 2 - Drive_Wdith / 4 - 50 , Drive_Height / 2 + 150, 100, 50)];
    [_backToSelectedBtn setBackgroundImage:[UIImage imageNamed:@"4F"] forState:UIControlStateNormal];
    [_backToSelectedBtn addTarget:self action:@selector(backBtn) forControlEvents:UIControlEventTouchUpInside];
    [_backToSelectedBtn setHidden:YES];
    [_blockView addSubview:_backToSelectedBtn];
    
    
    _resumeGameBtn = [[UIButton alloc]initWithFrame:CGRectMake(Drive_Wdith / 2 + Drive_Wdith / 4 - 50 , Drive_Height / 2 + 150, 100, 50)];
    [_resumeGameBtn setBackgroundImage:[UIImage imageNamed:@"4F"] forState:UIControlStateNormal];
    [_resumeGameBtn addTarget:self action:@selector(restartGameAction) forControlEvents:UIControlEventTouchUpInside];
    [_resumeGameBtn setHidden:YES];
    [_blockView addSubview:_resumeGameBtn];
    
    
    
}

#pragma mark - button action

-(void)backBtn{
    
    [audioPlayer stop];
    
    for (int i = 0; i < [self.navigationController.viewControllers count]; i ++)
    {
        if([[self.navigationController.viewControllers objectAtIndex: i] isKindOfClass:[selectCharacterViewController class]]){
            [self.navigationController popToViewController: [self.navigationController.viewControllers objectAtIndex:i] animated:YES];
        }
    }
    
}

-(void)restartGameAction{
    
    NSString *str = [NSString stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=391945719?mt=8" ];
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)){
        str = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id391945719?mt=8"];
    }
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    
}


#pragma mark - broadcast
- (void) gameBroadcast:(NSNotification *)notification{
    if ([[notification name] isEqualToString:BROADCAST_SCORE]){
        NSLog(@"BROADCAST_SCORE");
        
        NSString * result = [(NSString *)[notification object]copy];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            _gameScoreLbl.text = [NSString stringWithFormat:@"%@%@",result , @"%"];
        });
        
        
    }
    
}

#pragma mark - timer
-(void)startGameTimer{
    startGameSecondsCountDown--;
    if(startGameSecondsCountDown==0){
        
        [_blockView setHidden:YES];
        [_startTimeLbl setHidden:YES];
        //end timer
        endGameSecondsCountDown = 3;
        _endGameCountDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(endGameTimer) userInfo:nil repeats:YES];
        
        [_startGameCountDownTimer invalidate];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        _startTimeLbl.text = [NSString stringWithFormat:@"%d",startGameSecondsCountDown];
    });
    
    
    
    NSLog(@"startGameSecondsCountDown --> %d",startGameSecondsCountDown);
}


-(void)endGameTimer{
    endGameSecondsCountDown--;
    if(endGameSecondsCountDown==0){
        [_gameOverLogoView setHidden:NO];
        [_backToSelectedBtn setHidden:NO];
        [_resumeGameBtn setHidden:NO];
        [_blockView setHidden:NO];
        
        //        [UIView animateWithDuration:1.0F animations:^{
        //            _resumeGameBtn.frame = CGRectMake(Drive_Wdith / 2 + Drive_Wdith / 4 - 50 , Drive_Height / 2 + 150 + 300, 100, 50);
        //        }];
        [audioPlayer stop];
        [_endGameCountDownTimer invalidate];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        _endTimeLbl.text = [NSString stringWithFormat:@"%d",endGameSecondsCountDown];
    });
    
    
    
    NSLog(@"endGameSecondsCountDown --> %d",endGameSecondsCountDown);
}


@end
