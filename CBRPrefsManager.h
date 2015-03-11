
@interface CBRPrefsManager : NSObject {

}

@property(nonatomic, assign, getter=areBannersEnabled) BOOL bannersEnabled;
@property(nonatomic, assign, getter=isLSEnabled) BOOL lsEnabled;

@property(nonatomic, assign, getter=shouldUseBannerGradient) BOOL useBannerGradient;
@property(nonatomic, assign, getter=shouldUseLSGradient) BOOL useLSGradient;

@property(nonatomic, assign) CGFloat bannerAlpha;
@property(nonatomic, assign) CGFloat lsAlpha;

@property(nonatomic, assign, getter=shouldRemoveLSBlur) BOOL removeLSBlur;

@property(nonatomic, assign, getter=shouldRemoveBannersBlur) BOOL removeBannersBlur;
@property(nonatomic, assign, getter=shouldHideQRRect) BOOL hideQRRect;
@property(nonatomic, assign, getter=shouldHideGrabber) BOOL hideGrabber;
// Adaptive vs. fixed color.
// Gradient vs non-gradient.
// Alpha levels.

+ (instancetype)sharedInstance;

- (void)reload;

@end
