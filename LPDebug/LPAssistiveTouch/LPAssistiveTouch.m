//
//  LPAssistiveTouch.m
//  LPAssistiveTouchDemo
//
//  Created by XuYafei on 15/10/29.
//  Copyright © 2015年 loopeer. All rights reserved.
//

#import "LPAssistiveTouch.h"

@interface LPAssistiveTouch () <LPATViewControllerDelegate>

@end

@implementation LPAssistiveTouch {
    CGPoint _assistiveWindowPoint;
    CGPoint _coverWindowPoint;
    LPATRootViewController *_rootViewController;
}

#pragma mark - Initialization

+ (instancetype)shareInstance {
    static id shareInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[self alloc] init];
    });
    return shareInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _rootViewController = [[LPATRootViewController alloc] init];
        _rootViewController.delegate = self;
        _assistiveWindowPoint = [LPATPosition cotentViewShrinkPointInRect:[UIScreen mainScreen].bounds];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    }
    return self;
}

- (void)showAssistiveTouch {
    _assistiveWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, imageViewWidth, imageViewWidth)];
    _assistiveWindow.center = _assistiveWindowPoint;
    _assistiveWindow.windowLevel = powf(10, 7);
    _assistiveWindow.backgroundColor = [UIColor clearColor];
    _assistiveWindow.rootViewController = _rootViewController;
    [self makeVisibleWindow];
}

- (void)makeVisibleWindow {
    UIWindow *keyWindows = [UIApplication sharedApplication].keyWindow;
    [_assistiveWindow makeKeyAndVisible];
    if (keyWindows) {
        [keyWindows makeKeyWindow];
    }
}

#pragma mark - LPATViewControllerDelegate

- (void)touchBegan {
    _coverWindowPoint = CGPointZero;
    _assistiveWindow.frame = [[UIScreen mainScreen] bounds];
    _rootViewController.view.frame = [[UIScreen mainScreen] bounds];
    _rootViewController.shrinkPoint = _assistiveWindowPoint;
}

- (void)shrinkToPoint:(CGPoint)point {
    _assistiveWindowPoint = point;
    _assistiveWindow.frame = CGRectMake(0, 0, imageViewWidth, imageViewWidth);
    _assistiveWindow.center = _assistiveWindowPoint;
    _rootViewController.shrinkPoint = CGPointMake(imageViewWidth / 2, imageViewWidth / 2);
}

#pragma mark - UIKeyboardWillChangeFrameNotification

- (void)keyboardWillChangeFrame:(NSNotification *)notification {
    /*因为动画过程中不能实时修改_assistiveWindowRect,
     *所以如果执行点击操作的话,_assistiveTouchView位置会以动画之前的位置为准.
     *如果执行拖动操作则会有跳动效果.所以需要禁止用户操作.*/
    _assistiveWindow.userInteractionEnabled = NO;
    NSDictionary *info = [notification userInfo];
    CGFloat duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect endKeyboardRect = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    //根据实时位置计算于键盘的间距
    CGFloat yOffset = endKeyboardRect.origin.y - _assistiveWindow.frame.origin.y - _assistiveWindow.frame.size.height;
    
    //如果键盘弹起给_coverWindowPoint赋值
    if (endKeyboardRect.origin.y < CGRectGetHeight([[UIScreen mainScreen] bounds])) {
        _coverWindowPoint = _assistiveWindowPoint;
    }
    
    //根据间距计算移动后的位置viewPoint
    CGPoint viewPoint = _assistiveWindow.center;
    viewPoint.y += yOffset;
    //如果viewPoint在原位置之下,将viewPoint变为原位置
    if (viewPoint.y > _coverWindowPoint.y) {
        viewPoint.y = _coverWindowPoint.y;
    }
    //如果_assistiveWindow被移动,将viewPoint变为移动后的位置
    if (_coverWindowPoint.x == 0 && _coverWindowPoint.y == 0) {
        viewPoint.y = _assistiveWindow.center.y;
    }
    
    //根据计算好的位置执行动画
    [UIView animateWithDuration:duration animations:^{
        _assistiveWindow.center = viewPoint;
    } completion:^(BOOL finished) {
        //将_assistiveWindowRect变为移动后的位置并恢复用户操作
        _assistiveWindowPoint = _assistiveWindow.center;
        _assistiveWindow.userInteractionEnabled = YES;
        //使其遮盖键盘
        [self makeVisibleWindow];
    }];
}

@end
