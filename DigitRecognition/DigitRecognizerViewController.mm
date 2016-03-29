//
//  DigitRecognizerViewController.m
//  DigitRecognition
//
//  Created by Kevin on 16/1/26.
//  Copyright © 2016年 Wolf. All rights reserved.
//

#import "DigitRecognizerViewController.h"
#include "opencv2/highgui/ios.h"
#include "opencv2/opencv.hpp"

/**
 *  获取当前设备的宽/高/坐标
 */

float kLineMinY = 100;
float kLineMaxY = 200;
float kReaderViewWidth = 200;
float kReaderViewHeight = 100;

//#define kDeviceWidth [UIScreen mainScreen].bounds.size.width
//#define KDeviceHeight [UIScreen mainScreen].bounds.size.height
//#define KDeviceFrame [UIScreen mainScreen].bounds

@interface DigitRecognizerViewController ()

@end

@implementation DigitRecognizerViewController

@synthesize TxtUnit;
@synthesize TxtResult;

int kDeviceWidth, KDeviceHeight;
CGRect KDeviceFrame;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    KDeviceFrame = self.cameraView.bounds;
    kDeviceWidth = KDeviceFrame.size.width;
    KDeviceHeight = KDeviceFrame.size.height;
    
    [self initialize];
    
    _preview = [AVCaptureVideoPreviewLayer layerWithSession: _session];
    _preview.frame = CGRectMake(0, 0, self.cameraView.frame.size.width, self.cameraView.frame.size.height);
    //_preview.videoGravity = AVLayerVideoGravityResizeAspect;
    
    [self.cameraView.layer addSublayer:_preview];
    bcameraStatue = false;
    
    photoView = [VIPhotoView alloc];
    UIImage *image;
    photoView = [photoView initWithFrame:self.cameraView.bounds andImage:image scaleMode:0];
    [self.cameraView    addSubview:photoView];
    photoView.hidden = true;
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if (( [[[UIDevice currentDevice] systemVersion] floatValue] < 8) && UIInterfaceOrientationIsLandscape(orientation))
    {
        Screen_W = [[UIScreen mainScreen] bounds].size.height;
        Screen_H = [[UIScreen mainScreen] bounds].size.width;
    }
    else
    {
        Screen_W = [[UIScreen mainScreen] bounds].size.width;
        Screen_H = [[UIScreen mainScreen] bounds].size.height;
    }
    
    //    [_session startRunning];
    //    bcameraStatue = true;
    
    [self setOverlayPickerView];
    [self startCodeReading];
    
    // create the array of data
    NSMutableArray* bandArray = [[NSMutableArray alloc] init];
    
    // add some sample data
    [bandArray addObject:@"mmol/L"];
    [bandArray addObject:@"mg/dL"];
    
    // bind yourTextField to DownPicker
    self.downPicker = [[DownPicker alloc] initWithTextField:self.TxtUnit withData:bandArray];
    [self.downPicker setValueAtIndex:0];
    TxtResult.delegate = self;
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveViewWithGestureRecognizer:)];
    [scanCropView addGestureRecognizer:panGestureRecognizer];
    
    RMPinchGestureRecognizer *pinchGestureRecognizer = [[RMPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchWithGestureRecognizer:)];
    [self.cameraView addGestureRecognizer:pinchGestureRecognizer];
    
    m_nUnit = 0;
    
    NSLog(@"viewDidLoad");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"viewDidAppear");
    m_pOCREngine = Engine_Create();
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    NSLog(@"viewDidDisappear");
    Engine_Destroy(m_pOCREngine);
}

- (void)setOverlayPickerView
{
    // 画中间的基准线
    line = [[UIImageView alloc] initWithFrame:CGRectMake((kDeviceWidth - 300) / 2.0, kLineMinY, 300, 12 * 300 / 320.0)];
    [line setImage:[UIImage imageNamed:@"QRCodeLine"]];
    
    [self.cameraView addSubview:line];
    
    // 最上部view
    upView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kDeviceWidth, kLineMinY)];//80
    upView.alpha = 0.3;
    upView.backgroundColor = [UIColor blackColor];
    
    [self.cameraView addSubview:upView];
    
    // 左侧的view
    leftView = [[UIView alloc] initWithFrame:CGRectMake(0, kLineMinY, (kDeviceWidth - kReaderViewWidth) / 2.0, kReaderViewHeight)];
    leftView.alpha = 0.3;
    leftView.backgroundColor = [UIColor blackColor];
    
    [self.cameraView addSubview:leftView];
    
    // 右侧的view
    rightView = [[UIView alloc] initWithFrame:CGRectMake(kDeviceWidth - CGRectGetMaxX(leftView.frame), kLineMinY, CGRectGetMaxX(leftView.frame), kReaderViewHeight)];
    rightView.alpha = 0.3;
    rightView.backgroundColor = [UIColor blackColor];
    
    [self.cameraView addSubview:rightView];
    
    CGFloat space_h = KDeviceHeight - kLineMaxY;
    
    // 底部view
    downView = [[UIView alloc] initWithFrame:CGRectMake(0, kLineMaxY, kDeviceWidth, space_h)];
    downView.alpha = 0.3;
    downView.backgroundColor = [UIColor blackColor];
    
    [self.cameraView addSubview:downView];
    
    // 四个边角
    UIImage *cornerImage = [UIImage imageNamed:@"QRCodeTopLeft"];
    
    // 左侧的view
    leftView_image = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(leftView.frame) - cornerImage.size.width / 2.0, CGRectGetMaxY(upView.frame) - cornerImage.size.height / 2.0, cornerImage.size.width, cornerImage.size.height)];
    leftView_image.image = cornerImage;
    
    [self.cameraView addSubview:leftView_image];
    
    cornerImage = [UIImage imageNamed:@"QRCodeTopRight"];
    
    // 右侧的view
    rightView_image = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(rightView.frame) - cornerImage.size.width / 2.0, CGRectGetMaxY(upView.frame) - cornerImage.size.height / 2.0, cornerImage.size.width, cornerImage.size.height)];
    rightView_image.image = cornerImage;
    
    [self.cameraView addSubview:rightView_image];
    
    cornerImage = [UIImage imageNamed:@"QRCodebottomLeft"];
    
    // 底部view
    downView_image = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(leftView.frame) - cornerImage.size.width / 2.0, CGRectGetMinY(downView.frame) - cornerImage.size.height / 2.0, cornerImage.size.width, cornerImage.size.height)];
    downView_image.image = cornerImage;
    
    [self.cameraView addSubview:downView_image];
    
    cornerImage = [UIImage imageNamed:@"QRCodebottomRight"];
    
    downViewRight_image = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(rightView.frame) - cornerImage.size.width / 2.0, CGRectGetMinY(downView.frame) - cornerImage.size.height / 2.0, cornerImage.size.width, cornerImage.size.height)];
    downViewRight_image.image = cornerImage;
    
    [self.cameraView addSubview:downViewRight_image];
    
    // 说明label
    labIntroudction = [[UILabel alloc] init];
    labIntroudction.backgroundColor = [UIColor clearColor];
    labIntroudction.frame = CGRectMake(CGRectGetMaxX(leftView.frame), CGRectGetMinY(downView.frame) + 25, kReaderViewWidth, 20);
    labIntroudction.textAlignment = NSTextAlignmentCenter;
    labIntroudction.font = [UIFont boldSystemFontOfSize:13.0];
    labIntroudction.textColor = [UIColor whiteColor];
    labIntroudction.text = @"将数字置于框内";
    
    [self.cameraView addSubview:labIntroudction];
    
    scanCropView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(leftView.frame) - 1,kLineMinY,self.view.frame.size.width - 2 * CGRectGetMaxX(leftView.frame) + 2, kReaderViewHeight + 2)];
    scanCropView.layer.borderColor = [UIColor greenColor].CGColor;
    scanCropView.layer.borderWidth = 2.0;
    
    [self.cameraView addSubview:scanCropView];
}

#pragma mark - 初始化UI

- (void) initialize
{
    NSLog(@"initialize");
    
    //1.创建会话层
    _session = [[AVCaptureSession alloc] init];
    [_session setSessionPreset:AVCaptureSessionPreset640x480];
    
    //2.创建、配置输入设备
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    for (AVCaptureDevice *device in devices)
    {
        if (device.position == AVCaptureDevicePositionBack)
        {
            _device = device;
            break;
        }
    }
    
    [_device lockForConfiguration:nil];
    //    [_device setFlashMode:AVCaptureFlashModeOn];
    
    [_device unlockForConfiguration];
    
    NSError *error;
    
    _captureInput = [AVCaptureDeviceInput deviceInputWithDevice:_device error:&error];
    
    if (!_captureInput)
    {
        NSLog(@"Error: %@", error);
        return;
    }
    
    [_session addInput:_captureInput];
    
    ///out put
    captureVideo = [[AVCaptureVideoDataOutput alloc] init];
    captureVideo.alwaysDiscardsLateVideoFrames = YES;
    //captureOutput.minFrameDuration = CMTimeMake(1, 10);
    
    dispatch_queue_t queue;
    queue = dispatch_queue_create("cameraQueue", NULL);
    [captureVideo setSampleBufferDelegate:self queue:queue];
    
    //dispatch_release(queue);
    NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey;
    NSNumber* value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA];
    NSDictionary* videoSettings = [NSDictionary dictionaryWithObject:value forKey:key];
    
    [captureVideo setVideoSettings:videoSettings];
    [_session addOutput:captureVideo];
    
    //3.创建、配置输出
    _captureOutput = [[AVCaptureStillImageOutput alloc] init];
    
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey,nil];
    
    [_captureOutput setOutputSettings:outputSettings];
    [_session addOutput:_captureOutput];
}

- (CGRect)getReaderViewBoundsWithSize:(CGSize)asize
{
    return CGRectMake(kLineMinY / KDeviceHeight, ((kDeviceWidth - asize.width) / 2.0) / kDeviceWidth, asize.height / KDeviceHeight, asize.width / kDeviceWidth);
}

#pragma mark - 交互事件
// 开始扫码
- (void)startCodeReading
{
    self.lineTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 / 20 target:self selector:@selector(animationLine) userInfo:nil repeats:YES];
    
    [_session startRunning];
    bcameraStatue = true;
    
    NSLog(@"开始扫码...");
}

// 停止扫码
- (void)stopCodeReading
{
    if (self.lineTimer)
    {
        [self.lineTimer invalidate];
        self.lineTimer = nil;
    }
    
    [_session stopRunning];
    bcameraStatue = false;
    
    NSLog(@"停止扫码...");
}

#pragma mark - 上下滚动交互线

- (void)animationLine
{
    __block CGRect frame = line.frame;
    
    static BOOL flag = YES;
    
    if (flag)
    {
        frame.origin.y = kLineMinY;
        flag = NO;
        
        [UIView animateWithDuration:1.0 / 20 animations:^{
            
            frame.origin.y += 5;
            line.frame = frame;
            
        } completion:nil];
    }
    else
    {
        if (line.frame.origin.y >= kLineMinY)
        {
            if (line.frame.origin.y >= kLineMaxY - 12)
            {
                frame.origin.y = kLineMinY;
                line.frame = frame;
                
                flag = YES;
            }
            else
            {
                [UIView animateWithDuration:1.0 / 20 animations:^{
                    
                    frame.origin.y += 5;
                    line.frame = frame;
                    
                } completion:nil];
            }
        }
        else
        {
            flag = !flag;
        }
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"buttonIndex is : %li", (long)buttonIndex);
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [TxtResult resignFirstResponder];// 让myTextField失去焦点
    return YES;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [TxtResult resignFirstResponder];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    @autoreleasepool {
        // Create a UIImage from the sample buffer data
        CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        CVPixelBufferLockBaseAddress(imageBuffer,0);
        uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
        size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
        size_t width = CVPixelBufferGetWidth(imageBuffer);
        size_t height = CVPixelBufferGetHeight(imageBuffer);
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef newContext = CGBitmapContextCreate(baseAddress,
                                                        width, height, 8, bytesPerRow, colorSpace,
                                                        kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
        CGImageRef newImage = CGBitmapContextCreateImage(newContext);
        
        CGContextRelease(newContext);
        CGColorSpaceRelease(colorSpace);
        
        
        UIImage *image= [UIImage imageWithCGImage:newImage scale:1 orientation:UIImageOrientationLeftMirrored];
        
        CGImageRelease(newImage);
        
        image = [image fixOrientation];
        CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    }
    
    //[pool release];
}

-(void)moveViewWithGestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer{
    CGPoint touchLocation = [panGestureRecognizer locationInView:self.view];
    
    //self.testView.center = touchLocation;
    NSLog(@"%f, %f", touchLocation.x, touchLocation.y);
    kLineMinY = touchLocation.y - kReaderViewHeight / 2.0;
    kLineMaxY = kLineMinY + kReaderViewHeight;
    
    [self resetViews];
}

-(void)handlePinchWithGestureRecognizer:(RMPinchGestureRecognizer *)pinchGestureRecognizer{
    //    self.testView.transform = CGAffineTransformScale(self.testView.transform, pinchGestureRecognizer.scale, pinchGestureRecognizer.scale);
    NSLog(@"%f, %f", pinchGestureRecognizer.xScale, pinchGestureRecognizer.yScale);
    if (0.8 < pinchGestureRecognizer.xScale && pinchGestureRecognizer.xScale < 1.2)
    {
        kReaderViewWidth *= ((pinchGestureRecognizer.xScale - 1) * 0.3 + 1);
        if (kReaderViewWidth > kDeviceWidth - 40) kReaderViewWidth = kDeviceWidth - 40;
    }
    if (0.8 < pinchGestureRecognizer.yScale && pinchGestureRecognizer.yScale < 1.2)
    {
        kReaderViewHeight *= ((pinchGestureRecognizer.yScale - 1) * 0.3 + 1);
        if (kReaderViewHeight > KDeviceHeight - 40) kReaderViewHeight = KDeviceHeight - 40;
    }
    kLineMinY = (kLineMinY + kLineMaxY) / 2 - kReaderViewHeight / 2; if (kLineMinY < 0) kLineMinY = 0;
    kLineMaxY = kLineMinY + kReaderViewHeight;
    [self resetViews];
}

-(void)resetViews
{
    // 画中间的基准线
    line.frame = CGRectMake((kDeviceWidth - kReaderViewWidth) / 2.0, kLineMinY, kReaderViewWidth, 12 * 300 / 320.0);
    
    // 最上部view
    upView.frame = CGRectMake(0, 0, kDeviceWidth, kLineMinY);//80
    
    // 左侧的view
    leftView.frame = CGRectMake(0, kLineMinY, (kDeviceWidth - kReaderViewWidth) / 2.0, kReaderViewHeight);
    
    // 右侧的view
    rightView.frame = CGRectMake(kDeviceWidth - CGRectGetMaxX(leftView.frame), kLineMinY, CGRectGetMaxX(leftView.frame), kReaderViewHeight);
    
    CGFloat space_h = KDeviceHeight - kLineMaxY;
    
    // 底部view
    downView.frame = CGRectMake(0, kLineMaxY, kDeviceWidth, space_h);
    
    // 左侧的view
    UIImage *cornerImage = [UIImage imageNamed:@"QRCodeTopLeft"];
    leftView_image.frame = CGRectMake(CGRectGetMaxX(leftView.frame) - cornerImage.size.width / 2.0, CGRectGetMaxY(upView.frame) - cornerImage.size.height / 2.0, cornerImage.size.width, cornerImage.size.height);
    
    cornerImage = [UIImage imageNamed:@"QRCodeTopRight"];
    // 右侧的view
    rightView_image.frame = CGRectMake(CGRectGetMinX(rightView.frame) - cornerImage.size.width / 2.0, CGRectGetMaxY(upView.frame) - cornerImage.size.height / 2.0, cornerImage.size.width, cornerImage.size.height);
    cornerImage = [UIImage imageNamed:@"QRCodebottomLeft"];
    // 底部view
    downView_image.frame = CGRectMake(CGRectGetMaxX(leftView.frame) - cornerImage.size.width / 2.0, CGRectGetMinY(downView.frame) - cornerImage.size.height / 2.0, cornerImage.size.width, cornerImage.size.height);
    
    cornerImage = [UIImage imageNamed:@"QRCodebottomRight"];
    downViewRight_image.frame = CGRectMake(CGRectGetMinX(rightView.frame) - cornerImage.size.width / 2.0, CGRectGetMinY(downView.frame) - cornerImage.size.height / 2.0, cornerImage.size.width, cornerImage.size.height);
    
    // 说明label
    labIntroudction.frame = CGRectMake(CGRectGetMaxX(leftView.frame), CGRectGetMinY(downView.frame) + 25, kReaderViewWidth, 20);
    
    scanCropView.frame = CGRectMake(CGRectGetMaxX(leftView.frame) - 1, kLineMinY, kDeviceWidth - 2 * CGRectGetMaxX(leftView.frame) + 2, kReaderViewHeight + 2);
}

-(IBAction)click:(id)sender{
    if(sender == self.BtnRecognition)
    {
        if (bcameraStatue == true)
        {
            //get connection
            AVCaptureConnection *videoConnection = nil;
            for (AVCaptureConnection *connection in _captureOutput.connections) {
                for (AVCaptureInputPort *port in [connection inputPorts]) {
                    if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
                        videoConnection = connection;
                        break;
                    }
                }
                if (videoConnection) {
                    [videoConnection setVideoOrientation:AVCaptureVideoOrientationPortrait];
                    break;
                }
            }
            
            //get UIImage
            [_captureOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:
             ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
                 // Continue as appropriate.
                 NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
                 [self stopCodeReading];
                 
                 UIImage *capturedImage = [[UIImage alloc] initWithData:imageData];
                 NSLog(@"%f %f",capturedImage.size.width,capturedImage.size.height);
                 
                 capturedImage = [capturedImage fixOrientation1];
                 
                 [self MainProcess:capturedImage :true];
                 [self hiddenCameraDetails];
             }];
            [self.BtnRecognition setTitle:@"Go to Camera" forState:UIControlStateNormal];
        }
        else
        {
            [self showCameraDetails];
            [self startCodeReading];
            [self.BtnRecognition setTitle:@"Recognition" forState:UIControlStateNormal];
        }
    }
}

-(void) MainProcess:(UIImage *)imgSrc :(bool) bFlip
{
    cv::Mat matSrc;
    UIImageToMat(imgSrc, matSrc);
    if (bFlip)
        cv::flip(matSrc, matSrc, 1);
    cv::cvtColor(matSrc, matSrc, CV_BGRA2RGB);
    
    float fScaleW = matSrc.cols / (float)kDeviceWidth;
    float fScaleH = matSrc.rows / (float)KDeviceHeight;
    float fScale = min(fScaleW, fScaleH);
    NipRect rtROI;
    rtROI.top = kLineMinY * fScale;
    rtROI.bottom = kLineMaxY * fScale;
    rtROI.left = (kDeviceWidth - kReaderViewWidth) / 2 * fScale;
    rtROI.right = (kDeviceWidth + kReaderViewWidth) / 2 * fScale;
    
cv:rectangle(matSrc, cv::Point(rtROI.left, rtROI.top), cv::Point(rtROI.right, rtROI.bottom), cv::Scalar(255, 0, 0));
    
    cv::Mat matGray; cv::cvtColor(matSrc, matGray,  CV_RGB2GRAY);
    int nROICnt = 1;
    ROIINFO_DATA *pResultROI = new ROIINFO_DATA[nROICnt];
    memset(pResultROI, 0, sizeof(ROIINFO_DATA) * nROICnt);
    NipByte *pbyGray = matGray.data; int nW = matGray.cols, nH = matGray.rows;
    m_nUnit = (int)self.downPicker.selectedIndex;
    Engine_Recognition(m_pOCREngine, pbyGray, nW, nH, &rtROI, nROICnt, pResultROI, m_nUnit);
    NSString* result = [[NSString alloc]initWithUTF8String:pResultROI[0].szDigit];
    TxtResult.text = result;
#if 0
    cv::Mat cropMat = matGray(cv::Rect(rtROI.left, rtROI.top, rtROI.width() + 1, rtROI.height() + 1));
    cv::cvtColor(cropMat, cropMat, CV_GRAY2BGRA);
    UIImage *imageSave = MatToUIImage(cropMat)	;
    UIImageWriteToSavedPhotosAlbum(imageSave, self,
                                   @selector(image:finishedSavingWithError:contextInfo:),
                                   nil);
#endif
    cv::cvtColor(matSrc, matSrc, CV_RGB2BGRA);
    [self displayImage: MatToUIImage(matSrc)];
    delete[] pResultROI;
}

-(void) displayImage:(UIImage *)imageDisplay
{
    photoView = [photoView initWithFrame:self.cameraView.bounds andImage:imageDisplay scaleMode:0];
    photoView.autoresizingMask = (1 << 6) -1;
}

-(void)hiddenCameraDetails
{
    line.hidden = true;
    upView.hidden = true;
    leftView.hidden = true;
    rightView.hidden = true;
    downView.hidden = true;
    leftView_image.hidden = true;
    rightView_image.hidden = true;
    downView_image.hidden = true;
    downViewRight_image.hidden = true;
    labIntroudction.hidden = true;
    scanCropView.hidden = true;
    _preview.hidden = true;
    photoView.hidden = false;
}
-(void)showCameraDetails
{
    line.hidden = false;
    upView.hidden = false;
    leftView.hidden = false;
    rightView.hidden = false;
    downView.hidden = false;
    leftView_image.hidden = false;
    rightView_image.hidden = false;
    downView_image.hidden = false;
    downViewRight_image.hidden = false;
    labIntroudction.hidden = false;
    scanCropView.hidden = false;
    _preview.hidden = false;
    photoView.hidden = true;
}

-(void)image:(UIImage *)image
finishedSavingWithError:(NSError *)
error contextInfo:(void *)contextInfo
{
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Save failed"
                              message: @"Failed to save image"
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Success"
                              message: @"Saved Image."
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        
    }
}

@end
