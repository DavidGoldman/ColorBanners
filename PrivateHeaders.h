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
