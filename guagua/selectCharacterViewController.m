//
//  selectCharacterViewController.m
//  guagua
//
//  Created by liwei wang on 12/6/15.
//  Copyright (c) 2015 leeway. All rights reserved.
//

#import "selectCharacterViewController.h"
#import "MainController.h"
#import <AudioToolbox/AudioToolbox.h>

#define ACCESS @"access"
#define NOT_ACCESS @"not_access"

#define GAME_VIES_UPDATE @"game_view_update"

@interface selectCharacterViewController ()<UIGestureRecognizerDelegate>
/* background image */
@property (strong,nonatomic) UIImageView *backgroundImage;

@property(strong,nonatomic) NSMutableArray *allCharactersAy;
@property(strong,nonatomic) MainController *mianView;
/* block view */
@property (strong,nonatomic) UIScrollView *blockView;
/* score */
@end

static SystemSoundID shake_sound_male_id = 0;

@implementation selectCharacterViewController

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
    
    
    if (_mianView != nil) {
        _mianView = nil;
    }
}

-(void)viewDidDisappear:(BOOL)animated{
    [_blockView removeFromSuperview];
    [self.view removeFromSuperview];
    
    [self setBlockView:nil];
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

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

-(void)loadParameter{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameBroadcast:) name:GAME_VIES_UPDATE object:nil ];
    
    
    _allCharactersAy = [NSMutableArray new];
    [_allCharactersAy addObject:@"select_1"];
    [_allCharactersAy addObject:@"select_2"];
    [_allCharactersAy addObject:@"select_3"];
    [_allCharactersAy addObject:@"select_4"];
    //[_allCharactersAy addObject:@"05"];
    

}

-(void)loadWidget{
    //background
    _backgroundImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, Drive_Wdith, Drive_Height + 20)];
    _backgroundImage.image = [UIImage imageNamed:@"select_bg"];
    [self.view addSubview:_backgroundImage];
    
    
    //character
    for (int i = 0; i < _allCharactersAy.count ; i ++) {
        UIButton * mButton = [[UIButton alloc]init];
        
        mButton.frame = CGRectMake( 50 ,  i * Drive_Height / 4 + 35 - 10 * i, Drive_Wdith -  100, Drive_Height / 4 - 20);
        
        
        [mButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@",[_allCharactersAy objectAtIndex:i]]] forState:UIControlStateNormal];
        
        [mButton addTarget:self action:@selector(selectedCharacter:) forControlEvents:UIControlEventTouchUpInside];
        
        [mButton setTag:100 + i];
        
        [self.view addSubview:mButton];
        
        
        
        //score
        
        UIImageView * scoreGImg = [[UIImageView alloc]init];
        scoreGImg.frame = CGRectMake(50 + Drive_Wdith -  100 - 40 ,(i + 1 )* Drive_Height / 4 + 35 - 10 * i - 37, 15, 15);
        scoreGImg.image = [UIImage imageNamed:@"1_b"];
        [self.view addSubview:scoreGImg];
        
        UIImageView * scoreSImg = [[UIImageView alloc]init];
        scoreSImg.frame = CGRectMake(50 + Drive_Wdith -  100 - 27 , (i + 1 )* Drive_Height / 4 + 35 - 10 * i - 37, 15, 15);
        scoreSImg.image = [UIImage imageNamed:[NSString stringWithFormat:@"%d%@", i + 1,@"_b"] ];
        [self.view addSubview:scoreSImg];
        
        UIImageView * scoreDImg = [[UIImageView alloc]init];
        scoreDImg.frame = CGRectMake(50 + Drive_Wdith -  100  -12, (i + 1 )* Drive_Height / 4 + 35 - 10 * i - 37, 5, 5);
        scoreDImg.image = [UIImage imageNamed:@"p_b"];
        [self.view addSubview:scoreDImg];
        
    }
    
    
    NSLog(@"%d",[self loadGame:1]);
    int gameLevelIndex = 0;
    for (int i = 1; i < 5; i ++) {
        
        if([self loadGame:i] == 1){
            gameLevelIndex++;
        }
    }
    
    if(gameLevelIndex > 0 && gameLevelIndex < 4){
        _blockView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, gameLevelIndex * Drive_Height / 4 + 35 - 10 * gameLevelIndex - 5, Drive_Wdith, Drive_Height + 20)];
        _blockView.backgroundColor=[UIColor colorWithRed:0.137 green:0.055 blue:0.078 alpha:0.3];
        [_blockView setHidden:NO];
        [self.view addSubview:_blockView];
        
    }else if(gameLevelIndex == 4){
        _blockView.hidden = YES;
    }
    
    
    
    
}


#pragma mark - button action
-(void)selectedCharacter:(id)sender{
    [self playSound];
    
    UIButton *tempBtn=(UIButton *)sender;
    
    for (int i = 0; i < _allCharactersAy.count ; i ++) {
        if(tempBtn.tag == 100 + i){
            if (_mianView == nil)
                _mianView = [[MainController alloc] init];
            _mianView.selectedNum = i;
            [self.navigationController pushViewController:_mianView animated:YES];
            
            
        }
        
        
    }
    
    
    
}

#pragma mark - sound
-(void) playSound

{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"girl_smile" ofType:@"wav"];
    if (path) {
        
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path],&shake_sound_male_id);
        AudioServicesPlaySystemSound(shake_sound_male_id);
        
    }
    AudioServicesPlaySystemSound(shake_sound_male_id);
    //    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}




#pragma mark - load game level
-(int) loadGame:(int)level{
    NSUserDefaults *gameLevel = [NSUserDefaults standardUserDefaults];
    //    NSLog(@"%@",[gameLevel objectForKey:[NSString stringWithFormat:@"%d",level]]);
    switch (level) {
            
        case 1:
            if ([[gameLevel objectForKey:[NSString stringWithFormat:@"%d",level]]isEqualToString:ACCESS]) {
                return 1;
                
            } else {
                
                return 0;
            }
            
            break;
            
        case 2:
            if ([[gameLevel objectForKey:[NSString stringWithFormat:@"%d",level]]isEqualToString:ACCESS]) {
                return 1;
            } else {
                
                return 0;
            }
            
            break;
            
        case 3:
            if ([[gameLevel objectForKey:[NSString stringWithFormat:@"%d",level]]isEqualToString:ACCESS]) {
                return 1;
            } else {
                return 0;
            }
            
            break;
            
        case 4:
            if ([[gameLevel objectForKey:[NSString stringWithFormat:@"%d",level]]isEqualToString:ACCESS]) {
                return 1;
            } else {
                return 0;
            }
            
            break;
    }
    
    
    return 0;
}


#pragma mark - broadcast
- (void) gameBroadcast:(NSNotification *)notification{
    if ([[notification name] isEqualToString:GAME_VIES_UPDATE]){
        
        
        int gameLevelIndex = 0;
        for (int i = 1; i < 5; i ++) {
            
            if([self loadGame:i] == 1){
                gameLevelIndex++;
            }
        }
        
        NSLog(@"AAAA  -> %d",gameLevelIndex);
        
        
        if(gameLevelIndex > 0 && gameLevelIndex < 4){
            dispatch_async(dispatch_get_main_queue(), ^{
                
                _blockView.frame =CGRectMake(0, gameLevelIndex * Drive_Height / 4 + 35 - 10 * gameLevelIndex - 5, Drive_Wdith, Drive_Height + 20);
            });
            
        }else if(gameLevelIndex == 4){
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                _blockView.hidden = YES;
            });
        }
        
        
    }
}

@end
