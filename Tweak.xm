#import "ColorBadges.h"
#import "PrivateHeaders.h"
#import "CBRGradientView.h"
#import "UIColor+ColorBanners.h"

#define UIColorFromRGBWithAlpha(rgb, a) [UIColor colorWithRed:GETRED(rgb)/255.0 green:GETGREEN(rgb)/255.0 blue:GETBLUE(rgb)/255.0 alpha:a]
#define VIEW_TAG 0xDAE1DEE

// TODO(DavidGoldman): Either use ColorBadges's isDarkColor or improve this.
static BOOL isWhitish(int rgb) {
  int r = GETRED(rgb);
  int g = GETGREEN(rgb);
  int b = GETBLUE(rgb);
  return r > 200 && g > 200 && b > 200;
}

static NSAttributedString * copyAttributedStringWithColor(NSAttributedString *str, UIColor *color) {
  NSMutableAttributedString *copy = [str mutableCopy];
  [copy addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, [copy length])];
  return copy;
}

// TODO(DavidGoldman): Handle case where no icon is present.
%group LockScreen
%hook SBLockScreenNotificationListView

- (void)_setContentForTableCell:(SBLockScreenBulletinCell *)cell withItem:(id)item atIndexPath:(id)path {
  %orig;

  if ([cell isMemberOfClass:%c(SBLockScreenBulletinCell)]) {
    Class cb = %c(ColorBadges);
    UIImage *image = [item iconImage];
    int color = [[cb sharedInstance] colorForImage:image];
    [cell colorize:color];
  }
}

%end

%hook SBLockScreenBulletinCell

%new
- (void)colorizeBackground:(int)color {
  CBRGradientView *gradientView = (CBRGradientView *)[self.realContentView viewWithTag:VIEW_TAG];
  UIColor *color1 = UIColorFromRGBWithAlpha(color, ((isWhitish(color)) ? 1 : 0.7));
  UIColor *color2 = ([%c(ColorBadges) isDarkColor:color]) ? [color1 cbr_lighten:0.2] : [color1 cbr_darken:0.2];
  NSArray *colors = @[ (id)color1.CGColor, (id)color2.CGColor ];

  if (!gradientView) {
    gradientView = [[CBRGradientView alloc] initWithFrame:self.frame colors:colors];
    gradientView.tag = VIEW_TAG;
    [self.realContentView insertSubview:gradientView atIndex:0];
    [gradientView release];
  } else {
    [gradientView setColors:colors];
  }
}

%new
- (void)colorizeText:(int)color {
  if (isWhitish(color)) {
    self.eventDateLabel.layer.compositingFilter = nil;
    self.relevanceDateLabel.layer.compositingFilter = nil;
    MSHookIvar<UILabel *>(self, "_unlockTextLabel").layer.compositingFilter = nil;

    UIColor *textColor = [UIColor darkGrayColor];
    self.primaryTextColor = textColor;
    self.subtitleTextColor = textColor;
    self.secondaryTextColor = textColor;
    self.relevanceDateColor = textColor;
    self.eventDateColor = textColor;
  } else {
    NSString *compositingFilter = @"colorDodgeBlendMode";
    self.eventDateLabel.layer.compositingFilter = compositingFilter;
    self.relevanceDateLabel.layer.compositingFilter = compositingFilter;
    MSHookIvar<UILabel *>(self, "_unlockTextLabel").layer.compositingFilter = compositingFilter;

    Class BulletinCell = %c(SBLockScreenBulletinCell);
    self.primaryTextColor = [BulletinCell defaultColorForPrimaryText];
    self.subtitleTextColor = [BulletinCell defaultColorForSubtitleText];
    self.secondaryTextColor = [BulletinCell defaultColorForSecondaryText];

    UIColor *vibrantColor = [self _vibrantTextColor];
    self.relevanceDateColor = vibrantColor;
    self.eventDateColor = vibrantColor;
  }
}

- (void)layoutSubviews {
  %orig;

  CBRGradientView *gradientView = (CBRGradientView *)[self.realContentView viewWithTag:VIEW_TAG];
  gradientView.frame = self.realContentView.bounds;
}

%new
- (void)colorize:(int)color {
  [self colorizeBackground:color];
  [self colorizeText:color];
}

%end
%end

%group Banners
%hook SBBannerContextView

%new
- (void)colorizeBackground:(int)color {
  // Remove background tint.
  _UIBackdropView *backdropView = MSHookIvar<_UIBackdropView *>(self, "_backdropView");
  backdropView.colorSaturateFilter = nil;
  backdropView.tintFilter = nil;
  [backdropView setIsForBannerContextView:YES];
  [backdropView _updateFilters];

  // Create/update gradient.
  CBRGradientView *gradientView = (CBRGradientView *)[self viewWithTag:VIEW_TAG];
  UIColor *color1 = UIColorFromRGBWithAlpha(color, 0.7);
  UIColor *color2 = ([%c(ColorBadges) isDarkColor:color]) ? [color1 cbr_lighten:0.1] : [color1 cbr_darken:0.1];
  NSArray *colors = @[ (id)color1.CGColor, (id)color2.CGColor ];

  if (!gradientView) {
    gradientView = [[CBRGradientView alloc] initWithFrame:self.frame colors:colors];
    gradientView.tag = VIEW_TAG;
    [self insertSubview:gradientView atIndex:1];
    [gradientView release];
  } else {
    [gradientView setColors:colors];
  }
}

%new
- (void)colorizeText:(int)color {
  SBDefaultBannerView *view = MSHookIvar<SBDefaultBannerView *>(self, "_contentView");
  SBDefaultBannerTextView *textView = MSHookIvar<SBDefaultBannerTextView *>(view, "_textView");
  BOOL isWhite = isWhitish(color);
  UIColor *dateColor = (isWhite) ? [UIColor darkGrayColor] : UIColorFromRGB(color);
  if (isWhite) {
    textView.relevanceDateLabel.layer.compositingFilter = nil;
  }
  [view _setRelevanceDateColor:dateColor];

  UIColor *textColor = (isWhite) ? [UIColor darkGrayColor] : [UIColor whiteColor];
  [textView setPrimaryTextColor:textColor];
  [textView setSecondaryTextColor:textColor];
}

- (void)setBannerContext:(SBUIBannerContext *)context withReplaceReason:(int)replaceReason {
  %orig;

  SBDefaultBannerView *view = MSHookIvar<SBDefaultBannerView *>(self, "_contentView");
  if ([view isMemberOfClass:%c(SBDefaultBannerView)]) {
    Class cb = %c(ColorBadges);
    SBBulletinBannerItem *item = [context item];
    UIImage *image = [item iconImage];
    int color = [[cb sharedInstance] colorForImage:image];

    [self colorizeBackground:color];
    [self colorizeText:color];

    id pullDownView = self.pullDownView;
    if ([pullDownView isKindOfClass:%c(SBBannerButtonView)]) {
      [(SBBannerButtonView *)pullDownView colorize:color];
    }
  }
}

- (void)layoutSubviews {
  %orig;

  CBRGradientView *gradientView = (CBRGradientView *)[self viewWithTag:VIEW_TAG];
  gradientView.frame = self.bounds;
}

%end

%hook SBDefaultBannerTextView

%new
- (void)setPrimaryTextColor:(UIColor *)color {
  NSAttributedString *s = MSHookIvar<NSAttributedString *>(self, "_primaryTextAttributedString");
  MSHookIvar<NSAttributedString *>(self, "_primaryTextAttributedString") = copyAttributedStringWithColor(s, color);
  [s release];
  
  s = MSHookIvar<NSAttributedString *>(self, "_primaryTextAttributedStringComponent");
  MSHookIvar<NSAttributedString *>(self, "_primaryTextAttributedStringComponent") = copyAttributedStringWithColor(s, color);
  [s release];
}

%new
- (void)setSecondaryTextColor:(UIColor *)color {
  NSAttributedString *s = MSHookIvar<NSAttributedString *>(self, "_secondaryTextAttributedString");
  MSHookIvar<NSAttributedString *>(self, "_secondaryTextAttributedString") = copyAttributedStringWithColor(s, color);
  [s release];
  
  s = MSHookIvar<NSAttributedString *>(self, "_alternateSecondaryTextAttributedString");
  MSHookIvar<NSAttributedString *>(self, "_alternateSecondaryTextAttributedString") = copyAttributedStringWithColor(s, color);
  [s release];
}

%end

%hook SBBannerButtonView

%new
- (void)colorize:(int)color {
  for (UIButton *button in self.buttons) {
    if ([button isKindOfClass:%c(SBNotificationVibrantButton)]) {
      [(SBNotificationVibrantButton *)button colorize:color];
    }
  }
}

%end

%hook SBNotificationVibrantButton

%new
- (void)configureButton:(UIButton *)button
          withTintColor:(UIColor *)tintColor
      selectedTintColor:(UIColor *)selectedTintColor
              textColor:(UIColor *)textColor
      selectedTextColor:(UIColor *)selectedTextColor {
  UIImage *buttonImage = [self _buttonImageForColor:tintColor selected:NO];
  UIImage *selectedImage = [self _buttonImageForColor:selectedTintColor selected:YES];
  [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
  [button setBackgroundImage:selectedImage forState:UIControlStateHighlighted];
  [button setBackgroundImage:selectedImage forState:UIControlStateSelected];
  [button setTitleColor:textColor forState:UIControlStateNormal];
  [button setTitleColor:selectedTextColor forState:UIControlStateHighlighted];
  [button setTitleColor:selectedTextColor forState:UIControlStateSelected];
}

%new
- (void)colorize:(int)colorInt {
  UIColor *color = UIColorFromRGBWithAlpha(colorInt, 0.5);
  UIColor *darkerColor = [color cbr_darken:0.2];
  UIColor *textColor = (isWhitish(colorInt) ? [UIColor darkGrayColor] : [UIColor whiteColor]);

  UIButton *overlayButton = MSHookIvar<UIButton *>(self, "_overlayButton");
  [self configureButton:overlayButton
          withTintColor:color
      selectedTintColor:darkerColor
              textColor:textColor
      selectedTextColor:textColor];

  UIButton *vibrantButton = MSHookIvar<UIButton *>(self, "_vibrantButton");
  vibrantButton.hidden = YES;
}

%end

// TODO(DavidGoldman): Make this less hacky. Would probably be better if we just set the tintFilter
// to be white (hopefully that will work)/use a light filter instead of the dark one.
%hook _UIBackdropView

%new
- (void)setIsForBannerContextView:(BOOL)flag {
  NSNumber *value = @(flag);
  objc_setAssociatedObject(self, @selector(isForBannerContextView), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

%new
- (BOOL)isForBannerContextView {
  NSNumber *value = objc_getAssociatedObject(self, @selector(isForBannerContextView));
  return [value boolValue];
}

- (void)setTintFilterForSettings:(id)settings {
  if ([self isForBannerContextView]) {
    return;
  }

  %orig;
}

- (void)setSaturationDeltaFactor:(CGFloat)factor {
  if ([self isForBannerContextView]) {
    return;
  }

  %orig;
}

%end
%end

%group RemoveUnderlay
%hook SBLockScreenView

- (void)_addLockContentUnderlayWithRequester:(id)requester {
  if ([requester isEqual:@"NotificationList"]) {
    return;
  }

  %orig;
}

%end
%end

%ctor {
  %init(LockScreen);
  %init(Banners);
  %init(RemoveUnderlay);
}
