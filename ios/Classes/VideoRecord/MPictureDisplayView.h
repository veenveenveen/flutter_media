//
//  MPictureDisplayView.h
//  qyx_flutter_media
//
//  Created by huangqiming on 2020/6/29.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "UIView+JCAddition.h"
typedef void(^JCRecordPlayerViewCancelBlock)(void);
typedef void(^JCRecordPlayerViewConfirmBlock)(void);

NS_ASSUME_NONNULL_BEGIN

@interface MPictureDisplayView : UIView
@property (nonatomic, copy) JCRecordPlayerViewCancelBlock cancelBlock;
@property (nonatomic, copy) JCRecordPlayerViewConfirmBlock confirmBlock;
@property (nonatomic, strong) NSURL *playUrl;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *confirmButton;

@end

NS_ASSUME_NONNULL_END
