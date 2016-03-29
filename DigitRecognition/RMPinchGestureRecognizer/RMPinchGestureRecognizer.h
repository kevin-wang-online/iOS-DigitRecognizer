//
//  RMPinchGestureRecognizer.h
//  DigitRecognition
//
//  Created by Wolf on 1/23/16.
//  Copyright (c) 2016 Wolf. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIGestureRecognizerSubclass.h>

@interface RMPinchGestureRecognizer : UIPinchGestureRecognizer
{
    CGPoint _pntOrig[2];
    CGFloat _lenOrigX;
    CGFloat _lenOrigY;
    CGFloat _xScale;
    CGFloat _yScale;
}

@property (nonatomic, readonly) CGFloat xScale;
@property (nonatomic, readonly) CGFloat yScale;

@end