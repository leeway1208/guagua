//
//  PLLScrathView.h
//  Rubber
//
//  Created by liwei wang on 11/6/15.
//  Copyright (c) 2015 crazypoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
@interface PLLScrathView : UIView
@property (nonatomic, assign) float sizeBrush;
@property (nonatomic, strong) UIView *hideView;

- (void)setHideView:(UIView *)hideView;
- (void)setAutomaticScratchCurve:(UIBezierPath *)curvePath duration:(float)duration;
@end
