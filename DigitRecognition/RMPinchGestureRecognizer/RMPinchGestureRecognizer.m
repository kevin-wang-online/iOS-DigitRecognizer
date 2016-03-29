//
//  RMPinchGestureRecognizer.m
//  DigitRecognition
//
//  Created by Wolf on 1/23/16.
//  Copyright (c) 2016 Wolf. All rights reserved.
//

#import "RMPinchGestureRecognizer.h"

@implementation RMPinchGestureRecognizer

@synthesize xScale = _xScale;
@synthesize yScale = _yScale;

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    
    if (self.state == UIGestureRecognizerStateChanged) {
        if ([self numberOfTouches] == 2) {
            CGPoint pntNew[2];
            pntNew[0] = [self locationOfTouch:0 inView:self.view];
            pntNew[1] = [self locationOfTouch:1 inView:self.view];
            
            CGFloat lenX = fabs(pntNew[1].x - pntNew[0].x);
            CGFloat lenY = fabs(pntNew[1].y - pntNew[0].y);
            
            CGFloat dX = fabs(lenX - _lenOrigX);
            CGFloat dY = fabs(lenY - _lenOrigY);
            CGFloat tot = dX + dY;
            
            CGFloat pX = dX / tot;
            CGFloat pY = dY / tot;
            
            CGFloat scale = [self scale];
            CGFloat dscale = scale - 1.0;
            _xScale = dscale * pX + 1;
            _yScale = dscale * pY + 1;
        }
    }
}

- (void)setState:(UIGestureRecognizerState)state {
    if (state == UIGestureRecognizerStateBegan) {
        if ([self numberOfTouches] == 2) {
            _pntOrig[0] = [self locationOfTouch:0 inView:self.view];
            _pntOrig[1] = [self locationOfTouch:1 inView:self.view];
        } else {
            _pntOrig[0] = [self locationInView:self.view];
            _pntOrig[1] = _pntOrig[0];
        }
        _lenOrigX = fabs(_pntOrig[1].x - _pntOrig[0].x);
        _lenOrigY = fabs(_pntOrig[1].y - _pntOrig[0].y);
        _xScale = 1.0;
        _yScale = 1.0;
    }
    
    [super setState:state];
}

@end
