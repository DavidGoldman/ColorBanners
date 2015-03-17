#import "ColorBannersPrefs.h"

#import "../UIColor+ColorBanners.h"

#define PREFS_NAME "com.golddavid.colorbanners"

// From ColorBadges.h.
#define GETRED(rgb) ((rgb >> 16) & 0xFF)
#define GETGREEN(rgb) ((rgb >> 8) & 0xFF)
#define GETBLUE(rgb) (rgb & 0xFF)
#define UIColorFromRGB(rgb) [UIColor colorWithRed:GETRED(rgb)/255.0 green:GETGREEN(rgb)/255.0 blue:GETBLUE(rgb)/255.0 alpha:1.0]

#define UIColorFromRGBWithAlpha(rgb, a) [UIColor colorWithRed:GETRED(rgb)/255.0 green:GETGREEN(rgb)/255.0 blue:GETBLUE(rgb)/255.0 alpha:a]
#define UIColorFromGray(gray) [UIColor colorWithRed:gray green:gray blue:gray alpha:1.0]

static void refreshGradient(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
  ColorBannersHeaderCell *cell = (ColorBannersHeaderCell *)observer;
  [cell refreshGradientLayer:YES];
}

@implementation ColorBannersHeaderCell

+ (Class)layerClass {
  return [CAGradientLayer class];
}

- (instancetype)initWithStyle:(int)style reuseIdentifier:(id)reuseIdentifier specifier:(id)specifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier specifier:specifier];
  if (self) {
    self.backgroundColor = [UIColor clearColor];

    CGFloat width = [[UIScreen mainScreen] bounds].size.width;
    CGRect titleFrame = CGRectMake(0, 20, width, 55);
    CGRect subtitleFrame = CGRectMake(0, 75, width, 19);

    _titleLabel = [[UILabel alloc] initWithFrame:titleFrame];
    _titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:48];
    _titleLabel.textColor = [UIColor darkGrayColor];
    _titleLabel.text = @"ColorBanners";
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textAlignment = NSTextAlignmentCenter;

    _subtitleLabel = [[UILabel alloc] initWithFrame:subtitleFrame];
    _subtitleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
    _subtitleLabel.text = @"By David Goldman";
    _subtitleLabel.backgroundColor = [UIColor clearColor];
    _subtitleLabel.textColor = [UIColor grayColor];
    _subtitleLabel.textAlignment = NSTextAlignmentCenter;

    [self addSubview:_titleLabel];
    [self addSubview:_subtitleLabel];

    [self refreshGradientLayer:NO];

    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), 
                                self,
                                &refreshGradient,
                                CFSTR("com.golddavid.colorbanners/refreshheader"),
                                NULL,
                                0);
  }
  return self;
}

- (void)dealloc {
  CFNotificationCenterRemoveObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                     self,
                                     CFSTR("com.golddavid.colorbanners/refreshheader"),
                                     NULL);

  [_titleLabel release];
  [_subtitleLabel release];
  [super dealloc];
}

- (void)refreshGradientLayer:(BOOL)animated {
  Boolean colorExists = false;
  Boolean isWhitishExists = false;

  int color = CFPreferencesGetAppIntegerValue(CFSTR("LastColor"), CFSTR(PREFS_NAME), &colorExists);
  Boolean isWhitish = CFPreferencesGetAppBooleanValue(CFSTR("LastColorIsWhitish"),
                                                   CFSTR(PREFS_NAME),
                                                   &isWhitishExists);
  if (!colorExists || !isWhitishExists) {
    color = 0xFFFFFF;
    isWhitish = true;
  }

  UIColor *tColor = (isWhitish) ? [UIColor darkGrayColor] : [UIColor whiteColor];
  UIColor *sColor = (isWhitish) ? [UIColor grayColor] : [UIColor whiteColor];

  UIColor *colorObj = UIColorFromRGB(color);
  UIColor *lighter = [colorObj cbr_lighten:0.2];
  UIColor *darker = [colorObj cbr_darken:0.1];
  NSArray *gColors = @[ (id)lighter.CGColor, (id)colorObj.CGColor, (id)darker.CGColor ];

  if (animated) {
    [UIView transitionWithView:_titleLabel
                      duration:0.25
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        _titleLabel.textColor = tColor;
                  } completion:nil];
    [UIView transitionWithView:_subtitleLabel
                      duration:0.25
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        _subtitleLabel.textColor = sColor;
                  } completion:nil];

    [UIView animateWithDuration:0.25
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CAGradientLayer *gradientLayer = (CAGradientLayer *)self.layer;

                         CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"colors"];
                         animation.duration = 0.25;
                         animation.fromValue = gradientLayer.colors;
                         animation.toValue = gColors;
                         gradientLayer.colors = gColors;
                         [self.layer addAnimation:animation forKey:@"animateColors"];
                      }
                     completion:nil];
  } else {
    _titleLabel.textColor = tColor;
    _subtitleLabel.textColor = sColor;

    CAGradientLayer *gradientLayer = (CAGradientLayer *)self.layer;
    gradientLayer.colors = gColors;
  }
}

- (instancetype)initWithSpecifier:(PSSpecifier *)specifier {
  return [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CBRHeaderCell" specifier:specifier];
}

- (CGFloat)preferredHeightForWidth:(CGFloat)width {
  return 120.0;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)width inTableView:(id)tableView {
  return [self preferredHeightForWidth:width];
}

@end
