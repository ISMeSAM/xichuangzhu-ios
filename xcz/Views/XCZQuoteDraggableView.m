//
//  XCZXCZQuoteDraggableView.m
//  xcz
//
//  Created by hustlzp on 15/10/20.
//  Copyright © 2015年 Zhipeng Liu. All rights reserved.
//

#import "XCZQuoteDraggableView.h"
#import <AVOSCloud.h>

#define ACTION_MARGIN 80 // distance from center where the action applies. Higher = swipe further in order for the action to be called
#define SCALE_STRENGTH 4 // how quickly the card shrinks. Higher = slower shrinking
#define SCALE_MAX .93 // upper bar for how much the card shrinks. Higher = shrinks less
#define ROTATION_MAX 1 // the maximum rotation allowed in radians.  Higher = card can keep rotating longer
#define ROTATION_STRENGTH 320 // strength of rotation. Higher = weaker rotation
#define ROTATION_ANGLE M_PI/8 // Higher = stronger rotation angle

@interface XCZQuoteDraggableView ()

@property (nonatomic) CGFloat xFromCenter;
@property (nonatomic) CGFloat yFromCenter;
@property (nonatomic) CGPoint originalPoint;

@end

@implementation XCZQuoteDraggableView

@dynamic delegate;

- (instancetype)initWithQuote:(XCZQuote *)quote
{
    self = [super initWithQuote:quote];
    if (!self) {
        return nil;
    }
    
    self.userInteractionEnabled = false;
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panned:)];
    [self addGestureRecognizer:panGestureRecognizer];
    
    return self;
}

#pragma mark - User Interaction

- (void)panned:(UIPanGestureRecognizer *)gestureRecognizer
{
    self.xFromCenter = [gestureRecognizer translationInView:self].x;
    self.yFromCenter = [gestureRecognizer translationInView:self].y;
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:{
            self.originalPoint = self.center;
            break;
        };
            
        case UIGestureRecognizerStateChanged:{
            // 更改中心位置
            self.center = CGPointMake(self.originalPoint.x + self.xFromCenter, self.originalPoint.y + self.yFromCenter);
            
            // 旋转
            
            // dictates rotation (see ROTATION_MAX and ROTATION_STRENGTH for details)
            CGFloat rotationStrength = MIN(self.xFromCenter / ROTATION_STRENGTH, ROTATION_MAX);
            
            // degree change in radians
            CGFloat rotationAngel = (CGFloat) (ROTATION_ANGLE * rotationStrength);
            
            // rotate by certain amount
            CGAffineTransform transform = CGAffineTransformMakeRotation(rotationAngel);
            
            // 缩放
            CGFloat scale = MAX(1 - fabs(rotationStrength) / SCALE_STRENGTH, SCALE_MAX);
            CGAffineTransform scaleTransform = CGAffineTransformScale(transform, scale, scale);
            
            self.transform = scaleTransform;
            
            if ([self.delegate respondsToSelector:@selector(dragging:)]) {
                [self.delegate dragging:MIN(1.0, fabs(self.xFromCenter) / ACTION_MARGIN)];
            }
            
            break;
        };
            
        case UIGestureRecognizerStateEnded: {
            [self panEnded];
            break;
        };
        case UIGestureRecognizerStatePossible: break;
        case UIGestureRecognizerStateCancelled: break;
        case UIGestureRecognizerStateFailed: break;
    }
    
}

#pragma mark - Public Methods

/**
 *  程序控制向左滑
 */
- (void)dragLeft
{
    [AVAnalytics event:@"quote_click_left"];
    
    CGPoint finishPoint = CGPointMake(-600, self.center.y - 50);
    [UIView animateWithDuration:0.4
                     animations:^{
                         self.center = finishPoint;
                         self.transform = CGAffineTransformMakeRotation(-1);
                     } completion:^(BOOL complete){
                         [self removeFromSuperview];
                         
                         if (self.delegate) {
                             if ([self.delegate respondsToSelector:@selector(didDragLeft:)]) {
                                 [self.delegate didDragLeft:self];
                             }
                         }
                     }];
}

/**
 *  程序控制向右滑
 */
- (void)dragRight
{
    [AVAnalytics event:@"quote_click_right"];
    
    CGPoint finishPoint = CGPointMake(600, self.center.y - 50);
    [UIView animateWithDuration:0.4
                     animations:^{
                         self.center = finishPoint;
                         self.transform = CGAffineTransformMakeRotation(1);
                     } completion:^(BOOL complete){
                         [self removeFromSuperview];
                         
                         if (self.delegate) {
                             if ([self.delegate respondsToSelector:@selector(didDragRight:)]) {
                                 [self.delegate didDragRight:self];
                             }
                         }
                     }];
}

#pragma mark - Private Helpers

- (void)panEnded
{
    if (self.xFromCenter > ACTION_MARGIN) {
        [AVAnalytics event:@"quote_drag_right"];
        
        CGPoint finishPoint = CGPointMake(500, 2 * self.yFromCenter + self.originalPoint.y);
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.center = finishPoint;
                         } completion:^(BOOL complete){
                             [self removeFromSuperview];
                             
                             if (self.delegate) {
                                 if ([self.delegate respondsToSelector:@selector(didDragRight:)]) {
                                     [self.delegate didDragRight:self];
                                 }
                             }
                         }];
    } else if (self.xFromCenter < -ACTION_MARGIN) {
        [AVAnalytics event:@"quote_drag_left"];
        
        CGPoint finishPoint = CGPointMake(-500, 2 * self.yFromCenter +self.originalPoint.y);
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.center = finishPoint;
                         } completion:^(BOOL complete){
                             [self removeFromSuperview];
                             
                             if (self.delegate) {
                                 if ([self.delegate respondsToSelector:@selector(didDragLeft:)]) {
                                     [self.delegate didDragLeft:self];
                                 }
                             }
                         }];
    } else {
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.center = self.originalPoint;
                             self.transform = CGAffineTransformMakeRotation(0);
                         }];
        if ([self.delegate respondsToSelector:@selector(willBackToCenter:)]) {
            [self.delegate willBackToCenter:MIN(1.0, fabs(self.xFromCenter) / ACTION_MARGIN)];
        }
    }
}

#pragma mark - Getters & Setters

@end
