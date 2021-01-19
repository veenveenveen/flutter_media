//
//  MPictureDisplayView.m
//  qyx_flutter_media
//
//  Created by huangqiming on 2020/6/29.
//

#import "MPictureDisplayView.h"
#import "UIView+JCAddition.h"
@interface MPictureDisplayView()
@property (nonatomic, strong) UIImageView *imageView;


@end

@implementation MPictureDisplayView

- (UIImageView *)imageView {
    if(!_imageView){
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [_imageView setContentMode:UIViewContentModeScaleAspectFit];
    }
    return _imageView;
    
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
}

- (void)clickCancel{
    if (self.cancelBlock) {
        self.cancelBlock();
    }
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
    self.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:playUrl]];
    [self addSubview:self.imageView];
    if (!_confirmButton) {
        [self playerButtons];
    }
    [self showPlayerButtons];
}

-(UIImage*) at_imageName:(NSString*)name{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    UIImage *image = [UIImage imageNamed:name inBundle:bundle compatibleWithTraitCollection:nil];
    return image;
}

@end
