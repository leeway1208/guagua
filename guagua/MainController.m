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
#import <AudioToolbox/AudioToolbox.h>

#define BROADCAST_SCORE @"score"
#define ACCESS @"access"
#define NOT_ACCESS @"not_access"

#define GAME_VIES_UPDATE @"game_view_update"

@interface MainController ()<UIGestureRecognizerDelegate,AVAudioPlayerDelegate>{
    int startGameSecondsCountDown;
    int endGameSecondsCountDown;
    SystemSoundID shortSound;
    AVAudioPlayer *audioPlayer;
    
    int gameLevel;
    
    //game score
    NSString * result;
}

/* back button */
@property (strong,nonatomic) UIButton *backBtn;
/* start game timer */
@property (strong,nonatomic) NSTimer *startGameCountDownTimer;
/* end game timer */
@property (strong,nonatomic) NSTimer *endGameCountDownTimer;
/* game start time */
@property (strong,nonatomic) UIImageView *startTimeImg;
/* game end time */
//@property (strong,nonatomic) UILabel *endTimeLbl;
@property (strong,nonatomic) UIImageView *endTimeSImg;
@property (strong,nonatomic) UIImageView *endTimeGImg;
/* block view */
@property (strong,nonatomic) UIScrollView *blockView;
/* game score */
//@property (strong,nonatomic) UILabel * gameScoreLbl;
@property (strong,nonatomic) UIImageView * gameScoreBImg;
@property (strong,nonatomic) UIImageView * gameScoreSImg;
@property (strong,nonatomic) UIImageView * gameScoreGImg;
@property (strong,nonatomic) UIImageView * gameScoreBFImg;
@property (strong,nonatomic) UIImageView * gameScoreXSImg;
@property (strong,nonatomic) UIImageView * gameScoreDImg;
/* navigation bar */
@property (strong,nonatomic) UIImageView * navigationBarView;

/* pop view */
@property (strong,nonatomic) UIImageView * gameOverLogoView;
@property (strong,nonatomic) UIButton *backToSelectedBtn;
@property (strong,nonatomic) UIButton *resumeGameBtn;

/* take off clother sound timer */
@property (strong,nonatomic) NSTimer *takeOffSoundTimer;
///* next view */
//@property (strong,nonatomic) selectCharacterViewController *selectView;

@end

@implementation MainController

double takeOffSoundTimerInterval = 8.0f;
static SystemSoundID take_off_sound_id = 0;

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
    [_startTimeImg removeFromSuperview];
    [_endTimeSImg removeFromSuperview];
    [_endTimeGImg removeFromSuperview];
    [_blockView removeFromSuperview];
    [_gameScoreBImg removeFromSuperview];
    [_gameScoreSImg removeFromSuperview];
    [_gameScoreGImg removeFromSuperview];
    [_gameScoreBFImg removeFromSuperview];
    [_gameScoreXSImg removeFromSuperview];
    [_gameScoreDImg removeFromSuperview];
    [_gameOverLogoView removeFromSuperview];
    [_backToSelectedBtn removeFromSuperview];
    [_resumeGameBtn removeFromSuperview];
    [_navigationBarView removeFromSuperview];
    [self.view removeFromSuperview];
    
    [self setStartTimeImg:nil];
    [self setEndTimeGImg:nil];
    [self setEndTimeSImg:nil];
    [self setBackBtn:nil];
    [self setBlockView:nil];
    [self setGameScoreBImg:nil];
    [self setGameScoreSImg:nil];
    [self setGameScoreGImg:nil];
    [self setGameScoreDImg:nil];
    [self setGameScoreXSImg:nil];
    [self setGameScoreBFImg:nil];
    [self setGameOverLogoView:nil];
    [self setBackToSelectedBtn:nil];
    [self setResumeGameBtn:nil];
    [self setNavigationBarView:nil];
    [self setView:nil];
    [super viewDidDisappear:animated];
    
    
    //start timer stop
    if (self.startGameCountDownTimer != nil){
        [self.startGameCountDownTimer invalidate];
        self.startGameCountDownTimer = nil;
        NSLog(@"timer stop...");
    }

    //end timer stop
    if (self.endGameCountDownTimer != nil){
        [self.endGameCountDownTimer invalidate];
        self.endGameCountDownTimer = nil;
        NSLog(@"timer stop...");
    }

    
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
    //init game level
    gameLevel = _selectedNum + 1;
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameBroadcast:) name:BROADCAST_SCORE object:nil ];
    
    
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
    UIImageView* viewBack = [[UIImageView alloc]initWithFrame:CGRectMake(0, 40, Drive_Wdith, Drive_Height + 20 - 40)];
    [viewBack setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d%@",_selectedNum + 1,@"B"]]];
    [self.view addSubview:viewBack];
    
    // Set up the STScratchView
    PLLScrathView *myView = [[PLLScrathView alloc] initWithFrame:CGRectMake(0,40,Drive_Wdith, Drive_Height + 20 - 40) ];
    
    //set the brush size
    myView.sizeBrush = 35;
    [self.view addSubview:myView];
    
    UIImageView *viewFront = [[UIImageView alloc] initWithFrame:CGRectMake(0, 40, Drive_Wdith, Drive_Height + 20 - 40)];
    [viewFront setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d%@",_selectedNum  + 1 ,@"F"]]];
    // Define the hide view
    [myView setHideView:viewFront];
    
    
    //naviagation bar image
    _navigationBarView = [[UIImageView alloc]init];
    _navigationBarView.frame = CGRectMake(0, 20, Drive_Wdith, 40);
    _navigationBarView.image = [UIImage imageNamed:@"bar2"];
    [self.view addSubview:_navigationBarView];
    
    
    //game score
    _gameScoreBImg = [[UIImageView alloc]initWithFrame:CGRectMake( (Drive_Wdith - 45) / 2 - 30,  25, 20, 20)];
    [self.view addSubview:_gameScoreBImg];
    
    _gameScoreSImg = [[UIImageView alloc]initWithFrame:CGRectMake( (Drive_Wdith - 45) / 2 + 20 - 30,  25, 20, 20)];
    [self.view addSubview:_gameScoreSImg];
    
    _gameScoreGImg = [[UIImageView alloc]initWithFrame:CGRectMake( (Drive_Wdith - 45) / 2 + 40 - 30,  25, 20, 20)];
    [self.view addSubview:_gameScoreGImg];
    
    _gameScoreDImg = [[UIImageView alloc]initWithFrame:CGRectMake( (Drive_Wdith - 45) / 2 + 60- 30,  25, 20, 20)];
    [self.view addSubview:_gameScoreDImg];
    
    
    _gameScoreXSImg = [[UIImageView alloc]initWithFrame:CGRectMake( (Drive_Wdith - 45) / 2 + 80- 30,  25, 20, 20)];
    [self.view addSubview:_gameScoreXSImg];
    
    
    _gameScoreBFImg = [[UIImageView alloc]initWithFrame:CGRectMake( (Drive_Wdith - 45) / 2 + 100- 30,  25, 20, 20)];
    [self.view addSubview:_gameScoreBFImg];
    
    
    //back btn
    _backBtn = [[UIButton alloc]initWithFrame:CGRectMake(10,  15, 30, 30)];
    [_backBtn setBackgroundImage:[UIImage imageNamed:@"back_4"] forState:UIControlStateNormal];
    [_backBtn addTarget:self action:@selector(backBtn) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_backBtn];
    
    
    //end time label
    _endTimeGImg = [[UIImageView alloc] initWithFrame:CGRectMake(Drive_Wdith - 35, 15, 30, 30)];
    [self.view addSubview:_endTimeGImg];
    
    _endTimeSImg = [[UIImageView alloc] initWithFrame:CGRectMake(Drive_Wdith - 65, 15, 30, 30)];
    [self.view addSubview:_endTimeSImg];
    
    
    //block view
    _blockView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, Drive_Wdith, Drive_Height + 20)];
    _blockView.backgroundColor=[UIColor colorWithRed:0.137 green:0.055 blue:0.078 alpha:0.3];
    [_blockView setHidden:NO];
    [self.view addSubview:_blockView];
    
    
    //game start time
    _startTimeImg = [[UIImageView alloc] initWithFrame:CGRectMake(Drive_Wdith  / 2 - 50 , Drive_Height / 2 - 50, 100, 100)];
//    _startTimeLbl.textColor = [UIColor redColor];
//    _startTimeImg.font = [UIFont systemFontOfSize:60];
    [_blockView addSubview:_startTimeImg];
    
    
    /**
     *  pop view
     */
    NSLog(@"%f-----%d",Drive_Height,(int)Drive_Wdith);
    _gameOverLogoView = [[UIImageView alloc] initWithFrame:CGRectMake(Drive_Wdith  / 2  - 150, Drive_Height / 2 - 100, 300, 100)];
    _gameOverLogoView.image = [UIImage imageNamed:@"challenge_succeed1"];
    [_gameOverLogoView setHidden:YES];
    [_blockView addSubview:_gameOverLogoView];
    
    
    if ((int)Drive_Wdith == 320) {
         _backToSelectedBtn = [[UIButton alloc]initWithFrame:CGRectMake(Drive_Wdith / 2 - Drive_Wdith / 4 - 75 , Drive_Height / 2 + 50, 150, 100)];
         _resumeGameBtn = [[UIButton alloc]initWithFrame:CGRectMake(Drive_Wdith / 2 + Drive_Wdith / 4 - 75 , Drive_Height / 2 + 50, 150, 100)];
    }else{
         _backToSelectedBtn = [[UIButton alloc]initWithFrame:CGRectMake(Drive_Wdith / 2 - Drive_Wdith / 4 - 75 , Drive_Height / 2 + 150, 150, 100)];
         _resumeGameBtn = [[UIButton alloc]initWithFrame:CGRectMake(Drive_Wdith / 2 + Drive_Wdith / 4 - 75 , Drive_Height / 2 + 150, 150, 100)];
    }
    

    [_backToSelectedBtn setBackgroundImage:[UIImage imageNamed:@"o_back1"] forState:UIControlStateNormal];
    [_backToSelectedBtn addTarget:self action:@selector(backBtn) forControlEvents:UIControlEventTouchUpInside];
    [_backToSelectedBtn setHidden:YES];
    [_blockView addSubview:_backToSelectedBtn];
    
    
 
    [_resumeGameBtn setBackgroundImage:[UIImage imageNamed:@"rate1"] forState:UIControlStateNormal];
    [_resumeGameBtn addTarget:self action:@selector(restartGameAction) forControlEvents:UIControlEventTouchUpInside];
    [_resumeGameBtn setHidden:YES];
    [_blockView addSubview:_resumeGameBtn];
    
    
    
}

#pragma mark - button action

-(void)backBtn{
    
    [audioPlayer stop];
    AudioServicesDisposeSystemSoundID(take_off_sound_id);
    [self stopTakeOffSoundTimer];
    
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
        
        result = [(NSString *)[notification object]copy];
        NSLog(@"aa  s %@",[result substringWithRange:NSMakeRange(2, 1)]);
             NSLog(@"%@ --",result);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (result.length == 5) {
                     NSString *B = [result substringWithRange:NSMakeRange(0, 1)];
                      _gameScoreBImg.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%@",B,@"_b"]   ];
                
                [self setScorePostion:1];
                
            
            }else if (result.length == 4 ){
                 NSString *S = [result substringWithRange:NSMakeRange(0, 1)];
            
                 NSString *G = [result substringWithRange:NSMakeRange(1, 1)];
                 NSString *XS = [result substringWithRange:NSMakeRange(3, 1)];
                
                         _gameScoreSImg.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%@",S,@"_b"]   ];
                         _gameScoreGImg.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%@",G,@"_b"]   ];
                         _gameScoreXSImg.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%@",XS,@"_b"]   ];
                
                [self setScorePostion:2];
            }else if(result.length == 3 ){
                NSString *G = [result substringWithRange:NSMakeRange(0, 1)];
                NSString *XS = [result substringWithRange:NSMakeRange(2, 1)];
                              _gameScoreGImg.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%@",G,@"_b"]   ];
                              _gameScoreXSImg.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%@",XS,@"_b"]   ];
                
                 [self setScorePostion:3];
            }
       
//            _gameScoreLbl.text = [NSString stringWithFormat:@"%@%@",result , @"%"];


            _gameScoreDImg.image = [UIImage imageNamed:@"d_b"];

            _gameScoreBFImg.image = [UIImage imageNamed:@"p_b"];
            
        });
        
        
        
    }
    
}

- (void)setScorePostion:(int) model{
    
    switch (model) {
        case 1:
            _gameScoreBImg.frame = CGRectMake((Drive_Wdith - 45) / 2  - 50,  25, 20, 20);
            _gameScoreSImg.frame = CGRectMake((Drive_Wdith - 45) / 2 + 20 - 50,  25, 20, 20);
            _gameScoreGImg.frame = CGRectMake((Drive_Wdith - 45) / 2 + 40 - 50,  25, 20, 20);
            _gameScoreDImg.frame = CGRectMake((Drive_Wdith - 45) / 2 + 60 - 50,  25, 20, 20);
            _gameScoreXSImg.frame = CGRectMake((Drive_Wdith - 45) / 2 + 80 - 50,  25, 20, 20);
            _gameScoreBFImg.frame = CGRectMake((Drive_Wdith - 45) / 2 + 100 - 50,  25, 20, 20);
      
            break;
            
            
        case 2:
            _gameScoreSImg.frame = CGRectMake((Drive_Wdith - 45) / 2 + 20 - 40,  25, 20, 20);
            _gameScoreGImg.frame = CGRectMake((Drive_Wdith - 45) / 2 + 40 - 40,  25, 20, 20);
            _gameScoreDImg.frame = CGRectMake((Drive_Wdith - 45) / 2 + 60 - 40,  25, 20, 20);
            _gameScoreXSImg.frame = CGRectMake((Drive_Wdith - 45) / 2 + 80 - 40,  25, 20, 20);
            _gameScoreBFImg.frame = CGRectMake((Drive_Wdith - 45) / 2 + 100 - 40,  25, 20, 20);
            break;
            
        default:
            _gameScoreGImg.frame = CGRectMake((Drive_Wdith - 45) / 2 - 10,  25, 20, 20);
            _gameScoreDImg.frame = CGRectMake((Drive_Wdith - 45) / 2 + 20 - 10,  25, 20, 20);
            _gameScoreXSImg.frame = CGRectMake((Drive_Wdith - 45) / 2 + 40 - 10,  25, 20, 20);
            _gameScoreBFImg.frame = CGRectMake((Drive_Wdith - 45) / 2 + 60 - 10,  25, 20, 20);

            
            break;
    }
    
    
}

#pragma mark - timer
-(void)startGameTimer{
    startGameSecondsCountDown--;
    if(startGameSecondsCountDown==0){
        
        [_blockView setHidden:YES];
        [_startTimeImg setHidden:YES];
        //end timer
        switch (gameLevel) {
            case 1:
                endGameSecondsCountDown = 15;
                break;
                
            case 2:
                endGameSecondsCountDown = 15;
                break;
                
            case 3:
                endGameSecondsCountDown = 15;
                break;
                
                
            case 4:
                endGameSecondsCountDown = 15;
                break;
        }
        
        
        
        //start end game time
        _endGameCountDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(endGameTimer) userInfo:nil repeats:YES];
        
        //start take off sound
        [self startTakeOffSoundTimer];
        
        [_startGameCountDownTimer invalidate];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        _startTimeImg.image = [UIImage imageNamed:[NSString stringWithFormat:@"%d%@",startGameSecondsCountDown,@"_WB"]];
        
        
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
        
       
        //handle the game
        NSLog(@"game over   -> %d",[result intValue]);
        switch (gameLevel) {
            case 1:
                if ([result intValue] >= 11) {
                     _gameOverLogoView.image = [UIImage imageNamed:@"challenge_succeed1"];
                    [self saveGame:1 access:ACCESS];
                    [self saveGame:2 access:ACCESS];
                    [self saveGame:3 access:NOT_ACCESS];
                    [self saveGame:4 access:NOT_ACCESS];
                }else{
                     _gameOverLogoView.image = [UIImage imageNamed:@"challenge_failed1"];
                    [self saveGame:1 access:ACCESS];
                    [self saveGame:2 access:NOT_ACCESS];
                    [self saveGame:3 access:NOT_ACCESS];
                    [self saveGame:4 access:NOT_ACCESS];
                }
                
                break;
                
            case 2:
                if ([result intValue] >= 12) {
                    _gameOverLogoView.image = [UIImage imageNamed:@"challenge_succeed1"];
                    [self saveGame:1 access:ACCESS];
                    [self saveGame:2 access:ACCESS];
                    [self saveGame:3 access:ACCESS];
                    [self saveGame:4 access:NOT_ACCESS];
                }else{
                    _gameOverLogoView.image = [UIImage imageNamed:@"challenge_failed1"];
                    [self saveGame:1 access:ACCESS];
                    [self saveGame:2 access:ACCESS];
                    [self saveGame:3 access:NOT_ACCESS];
                    [self saveGame:4 access:NOT_ACCESS];
                }
                
                break;
                
            case 3:
                if ([result intValue] >= 13) {
                    _gameOverLogoView.image = [UIImage imageNamed:@"challenge_succeed1"];
                    [self saveGame:1 access:ACCESS];
                    [self saveGame:2 access:ACCESS];
                    [self saveGame:3 access:ACCESS];
                    [self saveGame:4 access:ACCESS];
                }else{
                    _gameOverLogoView.image = [UIImage imageNamed:@"challenge_failed1"];
                    [self saveGame:1 access:ACCESS];
                    [self saveGame:2 access:ACCESS];
                    [self saveGame:3 access:ACCESS];
                    [self saveGame:4 access:NOT_ACCESS];
                }
                
                break;
                
                
            case 4:
                if ([result intValue] >= 14) {
                    _gameOverLogoView.image = [UIImage imageNamed:@"challenge_succeed1"];
                }else{
                    _gameOverLogoView.image = [UIImage imageNamed:@"challenge_failed1"];
                }
                
                break;
        }
        
        
        
        [[NSNotificationCenter defaultCenter] postNotificationName:GAME_VIES_UPDATE object:nil];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:BROADCAST_SCORE object:nil];
        
        [audioPlayer stop];
        AudioServicesDisposeSystemSoundID(take_off_sound_id);
        [self stopTakeOffSoundTimer];
        [_endGameCountDownTimer invalidate];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
//        _endTimeLbl.text = [NSString stringWithFormat:@"%d",endGameSecondsCountDown];
        
        if (endGameSecondsCountDown > 9) {
            _endTimeSImg.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%@",[[NSString stringWithFormat:@"%d",endGameSecondsCountDown] substringWithRange:NSMakeRange(0, 1)],@"_NB"]];
            _endTimeGImg.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%@",[[NSString stringWithFormat:@"%d",endGameSecondsCountDown] substringWithRange:NSMakeRange(1, 1)],@"_NB"]];

            
        } else {
            _endTimeSImg.image = [UIImage imageNamed:@""];
            _endTimeGImg.image = [UIImage imageNamed:[NSString stringWithFormat:@"%d%@",endGameSecondsCountDown,@"_NB"]];
            
        }
 
    });
    
    
    
    NSLog(@"endGameSecondsCountDown --> %d",endGameSecondsCountDown);
}


//take off sound
-(void) startTakeOffSoundTimer{
    [[NSRunLoop mainRunLoop] addTimer:self.takeOffSoundTimer forMode:NSRunLoopCommonModes];
    NSLog(@"takeOffSoundTimer start...");
}

- (void) stopTakeOffSoundTimer{
    if (self.takeOffSoundTimer != nil){
        [self.takeOffSoundTimer invalidate];
        self.takeOffSoundTimer = nil;
        NSLog(@"takeOffSoundTimer stop...");
    }
}


- (NSTimer *) takeOffSoundTimer {
    if (!_takeOffSoundTimer) {
        _takeOffSoundTimer = [NSTimer timerWithTimeInterval:takeOffSoundTimerInterval target:self selector:@selector(takeOffSoundSelector:) userInfo:nil repeats:YES];
    }
    return _takeOffSoundTimer;
}

- (void)takeOffSoundSelector:(NSTimer*)timer{
 
    [self playSound];
    
}

#pragma mark - sound
-(void) playSound

{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"takeoff" ofType:@"mp3"];
    if (path) {
        
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path],&take_off_sound_id);
        AudioServicesPlaySystemSound(take_off_sound_id);
        
    }
    AudioServicesPlaySystemSound(take_off_sound_id);
    //    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}



#pragma mark - save game level

-(void)saveGame:(int)level access:(NSString *)isAccess{
    
    NSUserDefaults *saveGameLevel = [NSUserDefaults standardUserDefaults];
    switch (level) {
        case 1:
            [saveGameLevel setObject:isAccess forKey:[NSString stringWithFormat:@"%d",level]];
            [saveGameLevel synchronize];
            break;
            
        case 2:
            [saveGameLevel setObject:isAccess forKey:[NSString stringWithFormat:@"%d",level]];
            [saveGameLevel synchronize];
            break;
            
        case 3:
            [saveGameLevel setObject:isAccess forKey:[NSString stringWithFormat:@"%d",level]];
            [saveGameLevel synchronize];
            break;
            
        case 4:
            [saveGameLevel setObject:isAccess forKey:[NSString stringWithFormat:@"%d",level]];
            [saveGameLevel synchronize];
            
            break;
    }
    
    
}


@end
