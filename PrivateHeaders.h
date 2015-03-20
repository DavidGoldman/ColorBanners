// Test notifications (see PriorityHub and TinyBar).

@interface SBLockScreenViewController : UIViewController
@end

@interface SBLockScreenManager : NSObject
@property(readonly, assign, nonatomic) SBLockScreenViewController *lockScreenViewController;

+ (id)sharedInstance;
- (void)lockUIFromSource:(int)arg1 withOptions:(id)arg2;
@end

@interface BBAction : NSObject
+ (id)action;
@end

@interface BBBulletin
@property(copy, nonatomic) NSString *sectionID;
@property(copy, nonatomic) NSString *title;
@property(copy, nonatomic) NSString *subtitle;
@property(copy, nonatomic) NSString *message;
@property(copy, nonatomic) BBAction *defaultAction;
@property(retain, nonatomic) NSDate *date;
@property(copy, nonatomic) NSString *bulletinID;
@end

@interface BBBulletinRequest : BBBulletin
@end

@interface SBLockScreenNotificationListController : NSObject
- (void)observer:(id)arg1 addBulletin:(id)arg2 forFeed:(unsigned long long)arg3 playLightsAndSirens:(BOOL)arg4 withReply:(id)arg5;
@end

@interface SBBulletinBannerController : NSObject
+ (id)sharedInstance;
- (void)observer:(id)arg1 addBulletin:(id)arg2 forFeed:(unsigned long long)arg3;
@end

@interface SBBannerController : NSObject
+ (id)sharedInstance;

- (id)_bannerContext;
- (void)_replaceIntervalElapsed;
- (void)_dismissIntervalElapsed;
@end

// Lockscreen Notifications.

@interface SBAwayBulletinListItem : NSObject
@property(retain) BBBulletin *activeBulletin;

- (id)iconImage;
@end

@interface UITableViewCellDeleteConfirmationView : UIView
@end

@interface SBTableViewCellDismissActionButton : UIView
@end
@interface SBTableViewCellDismissActionButton(ColorBanners)
- (void)colorize:(int)color;
@end

@interface SBLockScreenBulletinCell : UIView
@property(retain, nonatomic) UIColor *eventDateColor;
@property(retain, nonatomic) UIColor *relevanceDateColor;
@property(retain, nonatomic) UIColor *secondaryTextColor;
@property(retain, nonatomic) UIColor *subtitleTextColor;
@property(retain, nonatomic) UIColor *primaryTextColor;

@property(retain, nonatomic) UILabel *eventDateLabel;
@property(retain, nonatomic) UILabel *relevanceDateLabel;
@property(readonly, nonatomic) UIView *realContentView;

+ (id)defaultColorForEventDate;
+ (id)defaultColorForRelevanceDate;
+ (id)defaultColorForSecondaryText;
+ (id)defaultColorForSubtitleText;
+ (id)defaultColorForPrimaryText;

- (id)_vibrantTextColor;
- (UITableViewCellDeleteConfirmationView *)_swipeToDeleteConfirmationView;
@end
@interface SBLockScreenBulletinCell(ColorBanners)
- (void)revertIfNeeded;
- (void)refreshAlphaAndVibrancy;
- (void)colorize:(int)color;
- (void)colorizeBackground:(int)color;
- (void)colorizeText:(int)color;

- (NSNumber *)cbr_color;
- (void)cbr_setColor:(NSNumber *)color;
@end

// Banners.

@interface SBBulletinBannerItem : NSObject
- (id)iconImage;
- (BBBulletin *)seedBulletin;
@end

@interface SBDefaultBannerView : UIView
- (void)setColor:(id)color forElement:(int)element;
- (void)_setRelevanceDateColor:(id)color;
@end

@interface SBDefaultBannerTextView : UIView
@property(readonly, assign, nonatomic) UILabel *relevanceDateLabel;
@end
@interface SBDefaultBannerTextView(TinyBar)
- (UILabel *)tb_titleLabel;
- (UILabel *)tb_secondaryLabel;
@end
@interface SBDefaultBannerTextView(ColorBanners)
- (void)setPrimaryTextColor:(UIColor *)color;
- (void)setSecondaryTextColor:(UIColor *)color;
- (UIColor *)secondaryTextColor;
@end

@interface SBUIBannerContext : NSObject
- (SBBulletinBannerItem *)item;
@end

@interface SBBannerContextView : UIView
@property(retain, nonatomic) UIView *pullDownView;
- (void)_setGrabberColor:(id)color;
@end
@interface SBBannerContextView(ColorBanners)
- (void)colorizeBackgroundForColor:(int)color alpha:(CGFloat)alpha preferringBlack:(BOOL)wantsBlack;
- (void)colorizeTextForColor:(int)color alpha:(CGFloat)alpha preferringBlack:(BOOL)wantsBlack;
- (void)colorizeGrabberForColor:(int)color alpha:(CGFloat)alpha preferringBlack:(BOOL)wantsBlack;
- (void)colorizePullDownForColor:(int)color alpha:(CGFloat)alpha preferringBlack:(BOOL)wantsBlack;
- (void)colorize:(int)color withBackground:(int)bg;
- (void)colorizeOrDefer:(int)color;

- (NSNumber *)cbr_color;
- (void)cbr_setColor:(NSNumber *)color;
@end

#pragma mark - Banner Buttons

@interface SBBannerButtonView : UIView
@property(retain, nonatomic) NSArray *buttons;
@end
@interface SBBannerButtonView(ColorBanners)
- (void)colorizeWithColor:(int)color alpha:(CGFloat)alpha preferringBlack:(BOOL)wantsBlack;
@end

@interface SBNotificationVibrantButton : UIView
- (id)_buttonImageForColor:(id)color selected:(BOOL)selected;
@end
@interface SBNotificationVibrantButton(ColorBanners)
- (void)colorizeWithColor:(int)color alpha:(CGFloat)alpha preferringBlack:(BOOL)wantsBlack;
- (void)configureButton:(UIButton *)button
          withTintColor:(UIColor *)tintColor
      selectedTintColor:(UIColor *)selectedTintColor
              textColor:(UIColor *)textColor
      selectedTextColor:(UIColor *)selectedtextColor;
@end

#pragma mark - Backdrop

@interface _UIBackdropViewSettings : NSObject
@property double statisticsInterval;
@property BOOL requiresColorStatistics;

@property(retain) UIColor * colorTint;
@property(retain) UIColor * combinedTintColor;

+ (id)settingsForStyle:(int)style;
@end

@interface _UIBackdropEffectView : UIView
@end

@interface _UIBackdropView : UIView
@property(retain) id colorSaturateFilter;
@property(retain) id tintFilter;
- (void)_updateFilters;
- (void)transitionToSettings:(id)arg1;
- (void)setComputesColorSettings:(BOOL)computes;

@property(retain) UIColor * colorMatrixColorTint;
@property(retain) _UIBackdropViewSettings * outputSettings;
@property(retain) _UIBackdropEffectView * backdropEffectView;
@end
@interface _UIBackdropView(ColorBanners)
- (void)setIsForBannerContextView:(BOOL)flag;
- (BOOL)isForBannerContextView;
@end

@interface CABackdropLayer : CALayer
- (id)statisticsValues;
@end

#pragma mark - QuickReply

@interface _UITextFieldRoundedRectBackgroundViewNeue : UIImageView
@property(nonatomic, retain) UIColor * strokeColor;
@property(nonatomic, retain) UIColor * fillColor;
- (void)updateView;
@end

@interface CKMessageEntryView : UIView
@end

@interface CKInlineReplyViewController : UIViewController
@property(nonatomic, retain) CKMessageEntryView * entryView;
@end
