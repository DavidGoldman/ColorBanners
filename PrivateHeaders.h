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
@property(copy, nonatomic) NSString * subtitle;
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
- (id)iconImage;
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
@end
@interface SBLockScreenBulletinCell(ColorBanners)
- (void)colorize:(int)color;
- (void)colorizeBackground:(int)color;
- (void)colorizeText:(int)color;
@end

// Banners.

@interface SBBulletinBannerItem : NSObject
- (id)iconImage;
@end

@interface SBDefaultBannerView : UIView
- (void)setColor:(id)color forElement:(int)element;
- (void)_setRelevanceDateColor:(id)color;
@end

@interface SBDefaultBannerTextView : UIView
@property(readonly, assign, nonatomic) UILabel *relevanceDateLabel;
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
- (void)colorizeBackground:(int)color;
- (void)colorizeText:(int)color;
@end

#pragma mark - Banner Buttons

@interface SBBannerButtonView : UIView
@property(retain, nonatomic) NSArray *buttons;
@end
@interface SBBannerButtonView(ColorBanners)
- (void)colorize:(int)color;
@end

@interface SBNotificationVibrantButton : UIView
- (id)_buttonImageForColor:(id)color selected:(BOOL)selected;
@end
@interface SBNotificationVibrantButton(ColorBanners)
- (void)colorize:(int)color;
- (void)configureButton:(UIButton *)button
          withTintColor:(UIColor *)tintColor
      selectedTintColor:(UIColor *)selectedTintColor
              textColor:(UIColor *)textColor
      selectedTextColor:(UIColor *)selectedtextColor;
@end

#pragma mark - Backdrop

@interface _UIBackdropViewSettings : NSObject
@property(retain) UIColor * colorTint;
@property(retain) UIColor * combinedTintColor;
@end

@interface _UIBackdropView : UIView
@property(retain) id colorSaturateFilter;
@property(retain) id tintFilter;
- (void)_updateFilters;

@property(retain) UIColor * colorMatrixColorTint;
@property(retain) _UIBackdropViewSettings * outputSettings;
@end
@interface _UIBackdropView(ColorBanners)
- (void)setIsForBannerContextView:(BOOL)flag;
- (BOOL)isForBannerContextView;
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
