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

@interface SBDefaultBannerView : UIView

@end

@interface SBBulletinBannerItem : NSObject
- (id)iconImage;
@end

@interface SBUIBannerContext : NSObject
- (SBBulletinBannerItem *)item;
@end

@interface SBBannerContextView : UIView
@end

@interface SBBannerContextView(ColorBanners)
- (void)colorizeBackground:(int)color;
@end

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
