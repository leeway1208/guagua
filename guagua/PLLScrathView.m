//
//  PLLScrathView.m
//  Rubber
//
//  Created by liwei wang on 11/6/15.
//  Copyright (c) 2015 crazypoo. All rights reserved.
//

#import "PLLScrathView.h"
#import <QuartzCore/QuartzCore.h>
#import "MultiMutableArray.h"

#define MAX_SCORE 100
#define BROADCAST_SCORE @"score"

@interface PLLScrathView()


- (void)initScratch;
- (void)refreshAutomaticScratch:(NSTimer *)timer;


@property (strong,nonatomic) NSMutableArray *allLocationPointAy;
@property (strong,nonatomic) NSMutableArray *scratchLocationPointAy;

@end

@implementation PLLScrathView
{
    CGPoint _previousTouchLocation;
    CGPoint _currentTouchLocation;
    
    CGImageRef _hideImage;
    CGImageRef _scratchImage;
    
    CGContextRef _contextMask;
    
    UIView *_refMovementView;
    
    
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setOpaque:NO];
        
        _sizeBrush = 10;
    }
    
    _allLocationPointAy = [NSMutableArray new];
    _scratchLocationPointAy = [NSMutableArray new];
    

    
    [_allLocationPointAy addObject:@"0.0000000.000000"];
   
    
    return self;
}

#pragma mark -
#pragma mark CoreGraphics methods

// Will be called every touch and at the first init
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    UIImage *imageToDraw = [UIImage imageWithCGImage:_scratchImage];
    [imageToDraw drawInRect:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
}

// Method to change the view which will be scratched
- (void)setHideView:(UIView *)hideView
{
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceGray();
    
    float scale = [UIScreen mainScreen].scale;
    
    UIGraphicsBeginImageContextWithOptions(hideView.bounds.size, NO, 0);
    [hideView.layer renderInContext:UIGraphicsGetCurrentContext()];
    hideView.layer.contentsScale = scale;
    _hideImage = UIGraphicsGetImageFromCurrentImageContext().CGImage;
    UIGraphicsEndImageContext();
    
    size_t imageWidth = CGImageGetWidth(_hideImage);
    size_t imageHeight = CGImageGetHeight(_hideImage);
    
    CFMutableDataRef pixels = CFDataCreateMutable(NULL, imageWidth * imageHeight);
    _contextMask = CGBitmapContextCreate(CFDataGetMutableBytePtr(pixels), imageWidth, imageHeight , 8, imageWidth, colorspace, kCGImageAlphaNone);
    CGDataProviderRef dataProvider = CGDataProviderCreateWithCFData(pixels);
    CFRelease(pixels);
    
    CGContextSetFillColorWithColor(_contextMask, [UIColor blackColor].CGColor);
    CGContextFillRect(_contextMask, CGRectMake(0, 0, self.frame.size.width * scale, self.frame.size.height * scale));
    
    
    CGContextSetStrokeColorWithColor(_contextMask, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(_contextMask, _sizeBrush);
    CGContextSetLineCap(_contextMask, kCGLineCapRound);
    
    CGImageRef mask = CGImageMaskCreate(imageWidth, imageHeight, 8, 8, imageWidth, dataProvider, nil, NO);
    _scratchImage = CGImageCreateWithMask(_hideImage, mask);
    CGDataProviderRelease(dataProvider);
    
    CGImageRelease(mask);
    CGColorSpaceRelease(colorspace);
}

- (void)scratchTheViewFrom:(CGPoint)startPoint to:(CGPoint)endPoint
{
    float scale = [UIScreen mainScreen].scale;
    
    CGContextMoveToPoint(_contextMask, startPoint.x * scale, (self.frame.size.height - startPoint.y) * scale);
    CGContextAddLineToPoint(_contextMask, endPoint.x * scale, (self.frame.size.height - endPoint.y) * scale);
    CGContextStrokePath(_contextMask);
    [self setNeedsDisplay];
    
}

#pragma mark -
#pragma mark Touch event

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    UITouch *touch = [[event touchesForView:self] anyObject];
    _currentTouchLocation = [touch locationInView:self];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    
    UITouch *touch = [[event touchesForView:self] anyObject];
    
    
    
    
    
    if (!CGPointEqualToPoint(_previousTouchLocation, CGPointZero))
    {
        _currentTouchLocation = [touch locationInView:self];
        
        //NSLog(@"touch x (%f)  y (%f) ", _currentTouchLocation.x,_currentTouchLocation.y);
    }
    
    _previousTouchLocation = [touch previousLocationInView:self];
    //NSLog(@"---- touch x (%f)  y (%f) ", _previousTouchLocation.x,_previousTouchLocation.y);
    
    
    
    
    for (int i = 0 ; i < _allLocationPointAy.count ; i ++) {
        
//        NSLog(@"- %@ ",[NSString stringWithFormat:@"%@",[_allLocationPointAy objectAtIndex:i]]);
//        
//        NSLog(@"-ss %@ ",[NSString stringWithFormat:@"%f%f",_previousTouchLocation.x,_previousTouchLocation.y]);
//        
        if ([[NSString stringWithFormat:@"%@",[_allLocationPointAy objectAtIndex:i]] isEqualToString:[NSString stringWithFormat:@"%f%f",_previousTouchLocation.x,_previousTouchLocation.y]]) {
            
                 break;
        }else{
            
             if (i == _allLocationPointAy.count - 1) {
                 [_allLocationPointAy addObject:[NSString stringWithFormat:@"%f%f",_previousTouchLocation.x,_previousTouchLocation.y]];
                 
             }
        }
        
      
    }
    
    
    NSLog(@"  ----> %lu", (unsigned long)_allLocationPointAy.count);
    NSLog(@"  ---> %f", _allLocationPointAy.count * _sizeBrush /  Drive_Height / Drive_Wdith);
    
 
    
    if (_allLocationPointAy.count * _sizeBrush /  Drive_Height / Drive_Wdith * 100  > 100) {
            [[NSNotificationCenter defaultCenter] postNotificationName:BROADCAST_SCORE object:[NSString stringWithFormat:@"%d",100]];
    }else{
            [[NSNotificationCenter defaultCenter] postNotificationName:BROADCAST_SCORE object:[NSString stringWithFormat:@"%.1f",_allLocationPointAy.count * _sizeBrush /  Drive_Height / Drive_Wdith * 100 ]];
    }
    
    [self scratchTheViewFrom:_previousTouchLocation to:_currentTouchLocation];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    UITouch *touch = [[event touchesForView:self] anyObject];
    
    if (!CGPointEqualToPoint(_previousTouchLocation, CGPointZero))
    {
        _previousTouchLocation = [touch previousLocationInView:self];
        [self scratchTheViewFrom:_previousTouchLocation to:_currentTouchLocation];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
}

- (void)initScratch
{
    _currentTouchLocation = CGPointZero;
    _previousTouchLocation = CGPointZero;
}

#pragma mark -
#pragma mark Automatic scratch

- (void)setAutomaticScratchCurve:(UIBezierPath *)curvePath duration:(float)duration
{
    [_refMovementView removeFromSuperview];
    _refMovementView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 5.0, 5.0)];
    _refMovementView.alpha = 0.0;
    [self addSubview:_refMovementView];
    
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    pathAnimation.duration = duration;
    pathAnimation.path = curvePath.CGPath;
    pathAnimation.calculationMode = kCAAnimationLinear;
    pathAnimation.removedOnCompletion = YES;
    pathAnimation.autoreverses = NO;
    pathAnimation.fillMode = kCAFillModeForwards;
    [_refMovementView.layer addAnimation:pathAnimation forKey:@"movingAnimation"];
    
    [NSTimer scheduledTimerWithTimeInterval:1.0/30.0 target:self selector:@selector(refreshAutomaticScratch:) userInfo:nil repeats:YES];
}

- (void)refreshAutomaticScratch:(NSTimer *)timer
{
    if (_refMovementView.layer.animationKeys.count == 0)
    {
        return;
    }
    
    CALayer *presentationLayer = _refMovementView.layer.presentationLayer;
    _currentTouchLocation = presentationLayer.position;
    
    if (CGPointEqualToPoint(_currentTouchLocation, _previousTouchLocation))
    {
        [timer invalidate];
    }
    
    [self scratchTheViewFrom:_previousTouchLocation to:_currentTouchLocation];
    _previousTouchLocation = _currentTouchLocation;
}

@end
