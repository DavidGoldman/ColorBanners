
@interface CBRPrefsManager : NSObject {

}

@property(nonatomic, assign, getter=areBannersEnabled) BOOL bannersEnabled;
@property(nonatomic, assign, getter=isLSEnabled) BOOL lsEnabled;

@property(nonatomic, assign, getter=shouldRemoveBlur) BOOL removeBlur;
@property(nonatomic, assign, getter=shouldHideQRRect) BOOL hideQRRect;
// Adaptive vs. fixed color.
// Gradient vs non-gradient.
// Alpha levels.

+ (instancetype)sharedInstance;

- (void)reload;

@end
