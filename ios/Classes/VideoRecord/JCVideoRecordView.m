//
//  JCVideoRecordView.m
//  Pods
//
//  Created by zhengjiacheng on 2017/8/31.
//
//

#import "JCVideoRecordView.h"
#import "JCVideoRecordManager.h"
#import "JCRecordPlayerView.h"
#import "JCVideoRecordProgressView.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "ATShowAlertView.h"
#import "MPictureDisplayView.h"
#define TUIScreenWidth                              [UIScreen mainScreen].bounds.size.width
#define TRGB(r,g,b)  [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1.0f];
#define TUIScreenHeight                             [UIScreen mainScreen].bounds.size.height
#define TiPhoneX (TUIScreenWidth == 375.f && TUIScreenHeight == 812.f ? YES : NO)
@interface JCVideoRecordView()<JCVideoRecordManagerDelegate>
@property (nonatomic, strong)JCVideoRecordManager *recorderManager;
@property (nonatomic, strong) UIView *recordBtn;
@property (nonatomic, strong) UIView *recordBackView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) UIImageView *focusImageView;
@property (nonatomic, strong) UIButton *switchCameraButton;
@property (nonatomic, strong) JCVideoRecordProgressView *progressView;
@property (nonatomic, weak) UIWindow *originKeyWindow;
@property (nonatomic, strong) NSURL *recordVideoUrl;
@property (nonatomic, strong) NSURL *recordVideoOutPutUrl;
@property (nonatomic, assign) BOOL videoCompressComplete;
@property(nonatomic,strong) NSString * videoFileName;
@property(nonatomic,strong)JCRecordPlayerView *playView;
@property(nonatomic,strong) MPictureDisplayView *picDisplayView;

@end

@implementation JCVideoRecordView

-(void)initCachePath{
    NSString *tmpPath = NSTemporaryDirectory();
    
    _VIDEO_OUTPUTFILE = [NSURL fileURLWithPath:[tmpPath stringByAppendingPathComponent:@"tmp.mp4"]];
    _IMAGE_OUTPUTFILE = [NSURL fileURLWithPath:[tmpPath stringByAppendingPathComponent:@"tmp.jpeg"]];
}
-(void)viewDidLoad{
    [super viewDidLoad];
    [self initCachePath];
    [self initSubViews];
    self.view.backgroundColor = TRGB(9, 6, 8);
    [self permissionSetting];
}
#pragma mark----权限设置
-(void)permissionSetting{
    ATShowAlertView * showAlertView  =  [[ATShowAlertView alloc]init];
    if ([showAlertView requesetRecordPermission]) {
        //        [showAlertView requestAuthorizationPhotoPermissionCompletion:^(BOOL permission) {
        //            if (!permission) {
        //                [self dismissViewControllerAnimated:YES completion:nil];
        //            }
        //        }];
        [showAlertView requesetVideoPermissionCompletion:^(BOOL permission) {
            if (!permission) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }];
    }
    showAlertView.subTitleAction = ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    };
}

#pragma mark - 视图
- (void)initSubViews{
    _contentView = [[UIView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:_contentView];
    _recorderManager = [[JCVideoRecordManager alloc]init];
    _recorderManager.delegate = self;
    [_contentView.layer addSublayer:self.recorderManager.preViewLayer];
    _recorderManager.preViewLayer.frame = self.view.bounds;
    [_contentView addSubview:self.recordBackView];
    [_contentView addSubview:self.backButton];
    [_contentView addSubview:self.tipLabel];
    [_contentView addSubview:self.switchCameraButton];
    [_contentView addSubview:self.progressView];
    [_contentView addSubview:self.recordBtn];
    [_contentView addSubview:self.focusImageView];
    [_contentView bringSubviewToFront:_recordBtn];
    [self addFocusGensture];
    _recorderManager.videoPath = _VIDEO_OUTPUTFILE;
}

#pragma mark - 点按时聚焦
- (void)addFocusGensture{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapScreen:)];
    [_contentView addGestureRecognizer:tapGesture];
}

- (void)tapScreen:(UITapGestureRecognizer *)tapGesture {
    CGPoint point= [tapGesture locationInView:self.contentView];
    [self setFocusCursorWithPoint:point];
    [self.recorderManager setFoucusWithPoint:point];
}

-(void)setFocusCursorWithPoint:(CGPoint)point {
    self.focusImageView.center = point;
    self.focusImageView.transform = CGAffineTransformMakeScale(1.5, 1.5);
    [UIView animateWithDuration:0.2 animations:^{
        self.focusImageView.alpha = 1;
        self.focusImageView.transform = CGAffineTransformMakeScale(1, 1);
    }completion:^(BOOL finished) {
        [self performSelector:@selector(autoHideFocusImageView) withObject:nil afterDelay:1];
    }];
}

- (void)autoHideFocusImageView {
    self.focusImageView.alpha = 0;
}

-(void)layoutSubviews {
    //    [super layoutSubviews];
    _recorderManager.preViewLayer.frame = self.view.bounds;
}

- (UIImageView *)focusImageView {
    if (!_focusImageView) {
        _focusImageView = [[UIImageView alloc]initWithImage:[self at_imageName:@"record_video_focus"]];
        _focusImageView.alpha = 0;
        _focusImageView.frame = CGRectMake(0, 0, 75, 75);
    }
    return _focusImageView;
}

- (UIButton *)backButton{
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton setImage:[self at_imageName:@"record_video_back"] forState:UIControlStateNormal];
        _backButton.frame = CGRectMake(50, self.recordBtn.centerY - 18, 36, 36);
        [_backButton addTarget:self action:@selector(clickBackButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (JCVideoRecordProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[JCVideoRecordProgressView alloc] initWithFrame:self.recordBackView.frame];
    }
    return _progressView;
}

- (UIButton *)switchCameraButton {
    if (!_switchCameraButton) {
        _switchCameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_switchCameraButton setImage:[self at_imageName:@"record_video_camera"] forState:UIControlStateNormal];
        _switchCameraButton.frame = CGRectMake(TUIScreenWidth-50-30, self.recordBtn.centerY - 13, 30, 22);
        [_switchCameraButton addTarget:self action:@selector(clickSwitchCamera) forControlEvents:UIControlEventTouchUpInside];
    }
    return _switchCameraButton;
}

- (UIView *)recordBackView {
    if (!_recordBackView) {
        CGRect rect = self.recordBtn.frame;
        CGFloat gap = 7.5;
        rect.size = CGSizeMake(rect.size.width + gap*2, rect.size.height + gap*2);
        rect.origin = CGPointMake(rect.origin.x - gap, rect.origin.y - gap);
        _recordBackView = [[UIView alloc]initWithFrame:rect];
        _recordBackView.backgroundColor = [UIColor whiteColor];
        _recordBackView.alpha = 0.6;
        [_recordBackView.layer setCornerRadius:_recordBackView.frame.size.width/2];
    }
    return _recordBackView;
}

- (UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, self.recordBackView.origin.y - 30, TUIScreenWidth, 20)];
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.textColor = [UIColor whiteColor];
        _tipLabel.text = @"长按拍摄";
        _tipLabel.font = [UIFont systemFontOfSize:15.0f];
    }
    return _tipLabel;
}

-(UIView *)recordBtn {
    if (!_recordBtn) {
        _recordBtn = [[UIView alloc]init];
        CGFloat deta = [UIScreen mainScreen].bounds.size.width/375;
        CGFloat width = 60.0*deta;
        CGFloat bottomPadding = 0.0;
        if (@available(iOS 11.0, *)) {
            UIWindow *window = UIApplication.sharedApplication.keyWindow;
            CGFloat topPadding = window.safeAreaInsets.top;
            bottomPadding = window.safeAreaInsets.bottom;
        }
        _recordBtn.frame = CGRectMake((TUIScreenWidth - width)/2, TUIScreenHeight - 127*deta - bottomPadding, width, width);
        [_recordBtn.layer setCornerRadius:_recordBtn.frame.size.width/2];
        _recordBtn.backgroundColor = [UIColor whiteColor];
        UILongPressGestureRecognizer *press = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(startRecord:)];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(takeCameraPicture:)];
        [_recordBtn addGestureRecognizer:tap];
        [_recordBtn addGestureRecognizer:press];
        _recordBtn.userInteractionEnabled = YES;
    }
    return _recordBtn;
}
#pragma mark - 点击事件
- (void)clickSwitchCamera {
    [self.recorderManager switchCamera];
}
- (void)clickBackButton {
    //    [self dismiss:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - 开始录制

- (void)takeCameraPicture:(UITapGestureRecognizer *)gesture {
    [self.recorderManager takePictureToFile:_IMAGE_OUTPUTFILE];
    self.backButton.hidden = YES;
    self.tipLabel.hidden = YES;
    self.switchCameraButton.hidden = YES;
}

- (void)startRecord:(UILongPressGestureRecognizer *)gesture{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        self.recordVideoUrl = nil;
        self.videoCompressComplete = NO;
        self.recordVideoOutPutUrl = nil;
        [self startRecordAnimate];
        CGRect rect = self.progressView.frame;
        rect.size = CGSizeMake(self.recordBackView.size.width - 3, self.recordBackView.size.height - 3);
        rect.origin = CGPointMake(self.recordBackView.origin.x + 1.5, self.recordBackView.origin.y + 1.5);
        self.progressView.frame = self.recordBackView.frame;
        self.backButton.hidden = YES;
        self.tipLabel.hidden = YES;
        self.switchCameraButton.hidden = YES;
        NSURL *url = _VIDEO_OUTPUTFILE;
        [self.recorderManager startRecordToFile:url];
    }else if(gesture.state >= UIGestureRecognizerStateEnded){
        [self stopRecord];
    }else if(gesture.state >= UIGestureRecognizerStateCancelled){
        [self stopRecord];
    }else if(gesture.state >= UIGestureRecognizerStateFailed){
        [self stopRecord];
    }
}
- (void)startRecordAnimate{
    [UIView animateWithDuration:0.2 animations:^{
        self.recordBtn.transform = CGAffineTransformMakeScale(0.66, 0.66);
        self.recordBackView.transform = CGAffineTransformMakeScale(6.5/5, 6.5/5);
    }];
}
#pragma mark - 停止录制
- (void)stopRecord{
    [self.recorderManager stopCurrentVideoRecording];
}
#pragma mark - 录制结束循环播放视频
- (void)showVideo:(NSURL *)playUrl isImage:(BOOL) isImage {
    // 图片预览
    if(isImage){
        _picDisplayView = [[MPictureDisplayView alloc] initWithFrame:self.view.bounds];
        _picDisplayView.backgroundColor = [UIColor blackColor];
        [_contentView addSubview:_picDisplayView];
        _picDisplayView.playUrl = playUrl;
        __weak typeof(self) instance = self;
        //点击取消还没有让上传操作取消有这个问题
        _picDisplayView.cancelBlock = ^{
            [instance clickCancel];
        };
        __weak typeof(self) selfWeak = self;
        _picDisplayView.confirmBlock = ^{
            [selfWeak sendImageMsg];
            //防止多次点击保存或者取消按钮
            selfWeak.picDisplayView.confirmButton.userInteractionEnabled = NO;
        };
        return;
    }
    // 视频预览
    _playView= [[JCRecordPlayerView alloc]initWithFrame:self.view.bounds];
    _playView.backgroundColor = [UIColor clearColor];
    [_contentView addSubview:_playView];
    _playView.playUrl = playUrl;
    __weak typeof(self) instance = self;
    //点击取消还没有让上传操作取消有这个问题
    _playView.cancelBlock = ^{
        [instance clickCancel];
    };
    __weak typeof(self) selfWeak = self;
    _playView.confirmBlock = ^{
        if (!instance.videoCompressComplete) {
            return ;
        }
        [selfWeak sendVieoMsg];
        //防止多次点击保存或者取消按钮
        selfWeak.playView.confirmButton.userInteractionEnabled = NO;
    };
}

- (void)saveVideo{
    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum([self.recordVideoUrl path])) {
        //保存视频到相簿
        UISaveVideoAtPathToSavedPhotosAlbum([self.recordVideoUrl path], self,
                                            @selector(video:didFinishSavingWithError:contextInfo:), nil);
    }
}
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    NSLog(@"保存视频完成");
    if (error == nil) {
    } else {
        if (error){
            ATShowAlertView * showAlertView = [[ATShowAlertView alloc]init];
            [showAlertView showPermissionSetting:@"请在iPhone的“设置-隐私”选项中，允许访问你的相册"];
        }
    }
}
#pragma mark----处理视频

-(void)sendImageMsg {
    NSData * imageData  =[NSData dataWithContentsOfURL:_IMAGE_OUTPUTFILE];
    NSLog(@"videoData-%@",imageData);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createFileAtPath:[self getTmpCoverImgPath] contents:imageData attributes:nil];
    if (self.videoBlock) {
        self.videoBlock([self getTmpCoverImgPath],@"");
    }
}

-(void)sendVieoMsg {
    if (self.videoBlock) {
        self.videoBlock(@"", self.recordVideoUrl.path);
    }
    //    视频预览图
    //    UIImage * fisrtImage = [self getVideoPreViewImage:_VIDEO_OUTPUTFILE];
    //    if (!fisrtImage) {
    //        return;
    //    }
    //    NSData * fisrtImageData  = UIImageJPEGRepresentation(fisrtImage, 0.2f);
    //    NSData * videoData  =[NSData dataWithContentsOfURL:self.recordVideoUrl];
    //    NSLog(@"videoData-%@",videoData);
    //    //    NSData * videoData  =[NSData dataWithContentsOfURL:_VIDEO_OUTPUTFILE];
    //    NSFileManager *fileManager = [NSFileManager defaultManager];
    //    [fileManager createFileAtPath:[self getTmpCoverImgPath] contents:fisrtImageData attributes:nil];
    //    if (self.videoBlock) {
    //        self.videoBlock([self getTmpCoverImgPath], self.recordVideoUrl.path);
    //    }
}

-(NSString*) getTmpCoverImgPath {
    NSString *tmpPath = NSTemporaryDirectory();
    return [tmpPath stringByAppendingPathComponent:@"conver_tmp.jpg"];
}
// 获取视频第一帧
- (UIImage*) getVideoPreViewImage:(NSURL *)path
{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:path options:nil];
    AVAssetImageGenerator *assetGen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    
    assetGen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [assetGen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *videoImage = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    return videoImage;
}
#pragma mark------压缩视频
- (void)compressVideo{
    __weak typeof(self) instance = self;
    [self.recorderManager compressVideo:self.recordVideoUrl complete:^(BOOL success, NSURL *outputUrl) {
        if (success && outputUrl) {
            instance.recordVideoOutPutUrl = outputUrl;
        }
        instance.videoCompressComplete = YES;
    }];
}

#pragma mark - 取消录制的视频
- (void)clickCancel{
    self.recordBtn.transform = CGAffineTransformMakeScale(1, 1);
    self.recordBackView.transform = CGAffineTransformMakeScale(1, 1);
    [self.recorderManager prepareForRecord];
    self.backButton.hidden = NO;
    self.tipLabel.hidden = NO;
    self.switchCameraButton.hidden = NO;
}

#pragma mark - JCVideoRecordManagerDelegate method
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error isImage:(BOOL)isImage {
    [self.progressView setProgress:0];
    if (!error) {
        // 图片
        if(isImage){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showVideo:outputFileURL isImage:YES];
            });
            return;
        }
        
        // 播放视频
        self.recordVideoUrl = outputFileURL;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showVideo:outputFileURL isImage:NO];
        });
        [self compressVideo];
    }
}

- (void)recordTimeCurrentTime:(CGFloat)currentTime totalTime:(CGFloat)totalTime {
    self.progressView.totolProgress = totalTime;
    self.progressView.progress = currentTime;
}

- (void)dealloc {
    
}



-(UIImage*) at_imageName:(NSString*)name{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    UIImage *image = [UIImage imageNamed:name inBundle:bundle compatibleWithTraitCollection:nil];
    return image;
}



@end
