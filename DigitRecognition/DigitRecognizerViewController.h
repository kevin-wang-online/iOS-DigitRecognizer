//
//  DigitRecognizerViewController.h
//  DigitRecognition
//
//  Created by Kevin on 16/1/26.
//  Copyright © 2016年 Wolf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>
#import <Foundation/NSAutoreleasePool.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "DownPicker.h"
#import "VIPhotoView.h"
#import "UIImage+Utilities.h"
#import "UIImage+FixOrientation.h"
#import "RMPinchGestureRecognizer.h"
#include "OcrEngine.h"

@interface DigitRecognizerViewController : UIViewController<UITextFieldDelegate, UIAlertViewDelegate, AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate>

{
    AVCaptureSession *_session;
    AVCaptureDeviceInput *_captureInput;
    AVCaptureStillImageOutput *_captureOutput;
    AVCaptureVideoPreviewLayer *_preview;
    AVCaptureDevice *_device;
    AVCaptureVideoDataOutput *captureVideo;
    
    VIPhotoView *photoView;
    bool bcameraStatue;
    float Screen_W;
    float Screen_H;
    UIImageView *line;//交互线
    UIView* upView;
    UIView *leftView;
    UIView *rightView;
    UIView *downView;
    UIImageView *leftView_image;
    UIImageView *rightView_image;
    UIImageView *downView_image;
    UIImageView *downViewRight_image;
    UILabel *labIntroudction;
    UIView *scanCropView;
    
    void *m_pOCREngine;
    int m_nUnit;
}
@property (nonatomic, strong) NSTimer *lineTimer; //交互线控制

@property (strong, nonatomic) DownPicker *downPicker;

@property (nonatomic, retain) IBOutlet UITextField *TxtUnit;
@property (nonatomic, retain) IBOutlet UITextField *TxtResult;
@property (assign, nonatomic) IBOutlet UIView *cameraView;
@property (weak, nonatomic) IBOutlet UIButton *BtnRecognition;

-(void)moveViewWithGestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer;
-(void)handlePinchWithGestureRecognizer:(RMPinchGestureRecognizer *)pinchGestureRecognizer;



@end
