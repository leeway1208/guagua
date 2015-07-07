//
//  WelcomeViewController.m
//  guagua
//
//  Created by liwei wang on 14/6/15.
//  Copyright (c) 2015 leeway. All rights reserved.
//

#import "WelcomeViewController.h"
#import "selectCharacterViewController.h"
#import <AudioToolbox/AudioToolbox.h>


#define ACCESS @"access"
#define NOT_ACCESS @"not_access"

@interface WelcomeViewController ()<UIGestureRecognizerDelegate>
/* background image */
@property (strong,nonatomic) UIImageView *backgroundImage;
/* logo image */
@property (strong,nonatomic) UIImageView *logoImage;
/* enter button */
@property (strong,nonatomic) UIButton *enterBtn;
/* next view */
@property (strong,nonatomic) selectCharacterViewController *selectView;

@end

static SystemSoundID shake_sound_male_id = 0;

@implementation WelcomeViewController

#pragma mark - ui load
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self loadParameter];
    [self loadWidget];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    //can cancel swipe gesture
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    
    if (_selectView != nil) {
        _selectView = nil;
    }
}

-(void)viewDidDisappear:(BOOL)animated{
    [_backgroundImage removeFromSuperview];
    [_enterBtn removeFromSuperview];
    [_logoImage removeFromSuperview];
    [self.view removeFromSuperview];
    
    [self setLogoImage:nil];
    [self setEnterBtn:nil];
    [self setBackgroundImage:nil];
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

-(void)loadParameter{
    //game init
    [self saveGame:1 access:ACCESS];
    [self saveGame:2 access:NOT_ACCESS];
    [self saveGame:3 access:NOT_ACCESS];
    [self saveGame:4 access:NOT_ACCESS];
}


-(void)loadWidget{
    
    _backgroundImage  = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"start_screen_3"]];
    _backgroundImage.frame = CGRectMake(0, 0, Drive_Wdith, Drive_Height + 20);
    [self.view addSubview:_backgroundImage];
    
    
    
    _logoImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Logo"]];
    _logoImage.frame = CGRectMake(Drive_Wdith / 2 - 140 , Drive_Height / 2 - Drive_Height / 4 - 20, 280, 150);
    [self.view addSubview:_logoImage];
    
    
    _enterBtn = [[UIButton alloc]initWithFrame:CGRectMake(Drive_Wdith / 2 - 100, Drive_Height/2 + 35 + 50, 200, 70)];
    [_enterBtn setBackgroundImage:[UIImage imageNamed:@"start_button"] forState:UIControlStateNormal];
    [_enterBtn addTarget:self action:@selector(enterBtn) forControlEvents:UIControlEventTouchUpInside]; 
    [self.view addSubview:_enterBtn];


    
}

#pragma mark - button action
-(void)enterBtn{
    
    if (_selectView == nil)
        _selectView = [[selectCharacterViewController alloc] init];
    [self playSound];
    
    [self.navigationController pushViewController:_selectView animated:YES];
    
    
}


#pragma mark - save game level

-(void)saveGame:(int)level access:(NSString *)isAccess{
    
    NSUserDefaults *gameLevel = [NSUserDefaults standardUserDefaults];
    switch (level) {
        case 1:
            [gameLevel setObject:isAccess forKey:[NSString stringWithFormat:@"%d",level]];
            [gameLevel synchronize];
            break;
            
        case 2:
            [gameLevel setObject:isAccess forKey:[NSString stringWithFormat:@"%d",level]];
            [gameLevel synchronize];
            break;
            
        case 3:
            [gameLevel setObject:isAccess forKey:[NSString stringWithFormat:@"%d",level]];
            [gameLevel synchronize];
            break;
            
        case 4:
            [gameLevel setObject:isAccess forKey:[NSString stringWithFormat:@"%d",level]];
            [gameLevel synchronize];
            
            break;
    }
    
    
}

#pragma mark - sound 
-(void) playSound

{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"shuqing" ofType:@"wav"];
    if (path) {
        
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path],&shake_sound_male_id);
        AudioServicesPlaySystemSound(shake_sound_male_id);

    }
    AudioServicesPlaySystemSound(shake_sound_male_id);
    //    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);  }
}
@end
