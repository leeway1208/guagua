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

@interface selectCharacterViewController ()<UIGestureRecognizerDelegate>
/* background image */
@property (strong,nonatomic) UIImageView *backgroundImage;

@property(strong,nonatomic) NSMutableArray *allCharactersAy;
@property(strong,nonatomic) MainController *mianView;

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
    
    [self.view removeFromSuperview];
    
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


@end
