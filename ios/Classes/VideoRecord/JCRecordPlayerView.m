//
//  JCRecordPlayerView.m
//  Pods
//
//  Created by zhengjiacheng on 2017/8/31.
//
//

#import "JCRecordPlayerView.h"
#import "UIView+JCAddition.h"
@interface JCRecordPlayerView() 
@property (nonatomic, strong) CALayer *playerLayer;
@property (nonatomic, strong) AVPlayer *player;


@end

@implementation JCRecordPlayerView

- (CALayer *)playerLayer{
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    playerLayer.frame = self.bounds;
    playerLayer.videoGravity = AVLayerVideoGravityResize;
    return playerLayer;
}

- (void)playerButtons{
    CGFloat deta = [UIScreen mainScreen].bounds.size.width/375.0;
    CGFloat width = 65.0*deta;
    
    _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_cancelButton setBackgroundImage:[self at_imageName:@"record_video_cancel"] forState:UIControlStateNormal];
    _cancelButton.frame = CGRectMake((self.width - width)/2, self.height - 130*deta, width, width);
    [_cancelButton addTarget:self action:@selector(clickCancel) forControlEvents:UIControlEventTouchUpInside];
    
    _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_confirmButton setBackgroundImage:[self at_imageName:@"record_video_confirm"] forState:UIControlStateNormal];
    _confirmButton.frame = CGRectMake((self.width - width)/2, _cancelButton.frame.origin.y , width, width);
    [_confirmButton addTarget:self action:@selector(clickConfirm) forControlEvents:UIControlEventTouchUpInside];
    _confirmButton.alpha = 0;
    _cancelButton.alpha = 0;
    
    [self addSubview:_confirmButton];
    [self addSubview:_cancelButton];
}

- (void)clickConfirm{
    if (self.confirmBlock) {
        self.confirmBlock();
    }
    [self.player pause];
//    [self removeFromSuperview];
}

- (void)clickCancel{
    if (self.cancelBlock) {
        self.cancelBlock();
    }
    [self.player pause];
    [self removeFromSuperview];
}

- (void)showPlayerButtons{
    CGFloat deta = [UIScreen mainScreen].bounds.size.width/375.0;
    CGFloat width = 60.0*deta;
    CGRect cancelRect = _cancelButton.frame;
    CGRect confirmRect = _confirmButton.frame;
    cancelRect.origin.x = 60*deta;
    confirmRect.origin.x = self.width - 60*deta - width;
    [UIView animateWithDuration:0.2 animations:^{
        self.cancelButton.frame = cancelRect;
        self.confirmButton.frame = confirmRect;
        self.confirmButton.alpha = 1;
        self.cancelButton.alpha = 1;
    }];
}

- (void)setPlayUrl:(NSURL *)playUrl{
    _playUrl = playUrl;
    if (!self.player) {
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:self.playUrl];
        _player = [AVPlayer playerWithPlayerItem:playerItem];
        [self addObserverToPlayerItem:playerItem];
    }
    [self.layer addSublayer:self.playerLayer];
    if (!_confirmButton) {
        [self playerButtons];
    }
    [self showPlayerButtons];
    [self.player play];
}

- (void)playbackFinished:(NSNotification *)notification{
    [self.player seekToTime:kCMTimeZero];
    [self.player play];
}

- (void)addObserverToPlayerItem:(AVPlayerItem *)playerItem{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
}

- (void)dealloc{
    [self.player pause];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(UIImage*) at_imageName:(NSString*)name{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    UIImage *image = [UIImage imageNamed:name inBundle:bundle compatibleWithTraitCollection:nil];
    return image;
}

@end
