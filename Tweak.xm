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
  UIColor *color1 = UIColorFromRGBWithAlpha(color, ((isWhitish(color)) ? 1 : 0.7));
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

- (void)setBannerContext:(SBUIBannerContext *)context withReplaceReason:(int)replaceReason {
  %orig;

  SBDefaultBannerView *view = MSHookIvar<SBDefaultBannerView *>(self, "_contentView");
  if ([view isMemberOfClass:%c(SBDefaultBannerView)]) {
    Class cb = %c(ColorBadges);
    SBBulletinBannerItem *item = [context item];
    UIImage *image = [item iconImage];
    int color = [[cb sharedInstance] colorForImage:image];
    [self colorizeBackground:color];
  }
}

- (void)layoutSubviews {
  %orig;

  CBRGradientView *gradientView = (CBRGradientView *)[self viewWithTag:VIEW_TAG];
  gradientView.frame = self.bounds;
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

%ctor {
  %init(LockScreen);
  %init(Banners);
}

