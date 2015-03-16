#import "ColorBadges.h"

#import "Defines.h"
#import "PrivateHeaders.h"
#import "CBRAppList.h"
#import "CBRPrefsManager.h"
#import "CBRGradientView.h"
#import "UIColor+ColorBanners.h"

#define UIColorFromRGBWithAlpha(rgb, a) [UIColor colorWithRed:GETRED(rgb)/255.0 green:GETGREEN(rgb)/255.0 blue:GETBLUE(rgb)/255.0 alpha:a]
#define VIEW_TAG 0xDAE1DEE

// TODO(DavidGoldman): Either use ColorBadges's isDarkColor or improve this.
static BOOL isWhitish(int rgb) {
  return ![%c(ColorBadges) isDarkColor:rgb];
}

static NSAttributedString * copyAttributedStringWithColor(NSAttributedString *str, UIColor *color) {
  NSMutableAttributedString *copy = [str mutableCopy];
  [copy addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, [copy length])];
  return copy;
}

// TODO(DavidGoldman): Figure out how to use BBAction so that it will be dismissed properly.
// Thanks to PriorityHub.
static void showTestLockScreenNotification(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
  [[%c(SBLockScreenManager) sharedInstance] lockUIFromSource:1 withOptions:nil];

  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.7 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
    BBBulletin *bulletin = [[[%c(BBBulletinRequest) alloc] init] autorelease];
    bulletin.title = @"ColorBanners";
    bulletin.subtitle = @"This is a test notification!";
    bulletin.sectionID = [CBRAppList randomAppIdentifier];
    bulletin.bulletinID = @"com.golddavid.colorbanners";

    SBLockScreenManager *manager = [%c(SBLockScreenManager) sharedInstance];
    SBLockScreenViewController *vc = manager.lockScreenViewController;
    SBLockScreenNotificationListController *lsNotificationListController = MSHookIvar<id>(vc, "_notificationController");

    if (lsNotificationListController) {
      id observer = MSHookIvar<id>(lsNotificationListController, "_observer");

      // iOS 8.
      if ([lsNotificationListController respondsToSelector:@selector(observer:addBulletin:forFeed:playLightsAndSirens:withReply:)]) {
        [lsNotificationListController observer:observer
                                   addBulletin:bulletin
                                       forFeed:2
                           playLightsAndSirens:NO
                                     withReply:nil];
      }
    }
  });
}

// Thanks for TinyBar (https://github.com/alexzielenski/TinyBar).
static void showTestBanner(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
  SBBannerController *controller = [%c(SBBannerController) sharedInstance];
  if ([controller _bannerContext]) { // Don't do anything if there is already a banner showing.
    return;
  }
  // Not sure if these are needed - see TinyBar.
  [NSObject cancelPreviousPerformRequestsWithTarget:controller
                                           selector:@selector(_replaceIntervalElapsed)
                                             object:nil];
  [NSObject cancelPreviousPerformRequestsWithTarget:controller
                                           selector:@selector(_dismissIntervalElapsed)
                                             object:nil];
  [controller _replaceIntervalElapsed];
  [controller _dismissIntervalElapsed];

  BBBulletin *bulletin = [[[%c(BBBulletinRequest) alloc] init] autorelease];
  bulletin.title = @"ColorBanners";
  bulletin.message = @"This is a test banner!";
  bulletin.sectionID = [CBRAppList randomAppIdentifier];
  bulletin.defaultAction = [%c(BBAction) action];

  SBBulletinBannerController *bc = [%c(SBBulletinBannerController) sharedInstance];
  [bc observer:nil addBulletin:bulletin forFeed:2];
}

%group LockScreen
%hook SBLockScreenNotificationListView

- (void)_setContentForTableCell:(SBLockScreenBulletinCell *)cell withItem:(id)item atIndexPath:(id)path {
  %orig;

  Class sbbc = %c(SBLockScreenBulletinCell);
  CBRPrefsManager *prefsManager = [CBRPrefsManager sharedInstance];
  if (prefsManager.lsEnabled && [cell isMemberOfClass:sbbc]) {
    int color;

    if (prefsManager.lsUseConstantColor) {
      color = prefsManager.lsBackgroundColor;
    } else {
      Class cb = %c(ColorBadges);
      UIImage *image = [item iconImage];
      if (!image) {
        return;
      }
      color = [[cb sharedInstance] colorForImage:image];
    }

    [cell colorize:color];
  }
}

%end

%hook SBLockScreenBulletinCell

- (void)prepareForReuse {
  %orig;

  // Hide/revert all the things!
  CBRGradientView *gradientView = (CBRGradientView *)[self.realContentView viewWithTag:VIEW_TAG];
  gradientView.hidden = YES;

  [self cbr_setColor:nil];

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

%new
- (void)colorizeBackground:(int)color {
  CBRGradientView *gradientView = (CBRGradientView *)[self.realContentView viewWithTag:VIEW_TAG];
  UIColor *color1 = UIColorFromRGB(color);

  if (!gradientView) {
    gradientView = [[CBRGradientView alloc] initWithFrame:self.frame];
    gradientView.tag = VIEW_TAG;
    [self.realContentView insertSubview:gradientView atIndex:0];
    [gradientView release];
  }
  gradientView.hidden = NO;
  gradientView.alpha = [CBRPrefsManager sharedInstance].lsAlpha;

  if ([CBRPrefsManager sharedInstance].useLSGradient) {
    UIColor *color2 = ([%c(ColorBadges) isDarkColor:color]) ? [color1 cbr_lighten:0.2] : [color1 cbr_darken:0.2];
    NSArray *colors = @[ (id)color1.CGColor, (id)color2.CGColor ];
    [gradientView setColors:colors];
  } else {
    [gradientView setSolidColor:color1];
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
  }
}

- (void)layoutSubviews {
  %orig;

  CBRGradientView *gradientView = (CBRGradientView *)[self.realContentView viewWithTag:VIEW_TAG];
  gradientView.frame = self.realContentView.bounds;
}

%new
- (void)colorize:(int)color {
  [self cbr_setColor:@(color)];
  [self colorizeBackground:color];
  [self colorizeText:color];
}

%new
- (NSNumber *)cbr_color {
  return objc_getAssociatedObject(self, @selector(cbr_color));
}

%new
- (void)cbr_setColor:(NSNumber *)color {
  objc_setAssociatedObject(self, @selector(cbr_color), color, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)_beginSwiping {
  %orig;

  NSNumber *colorObj = [self cbr_color];
  if (colorObj) {
    int color = [colorObj intValue];

    UITableViewCellDeleteConfirmationView *view = [self _swipeToDeleteConfirmationView];
    NSArray *buttons = MSHookIvar<NSArray *>(view, "_actionButtons");
    for (id button in buttons) {
      if ([button isMemberOfClass:%c(SBTableViewCellDismissActionButton)]) {
        SBTableViewCellDismissActionButton *actionButton = button;
        [actionButton colorize:color];
      }
    }
  }
}

%end

%hook SBTableViewCellDismissActionButton

%new
- (void)colorize:(int)color {
  CGFloat alpha = [CBRPrefsManager sharedInstance].lsAlpha * 3 / 4;
  self.backgroundColor = UIColorFromRGBWithAlpha(color, alpha);
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

  // Hide background blur if needed.
  if ([CBRPrefsManager sharedInstance].removeBannersBlur) {
    backdropView.hidden = YES;
  }

  // Create/update gradient.
  CBRGradientView *gradientView = (CBRGradientView *)[self viewWithTag:VIEW_TAG];
  UIColor *color1 = UIColorFromRGB(color);

  if (!gradientView) {
    gradientView = [[CBRGradientView alloc] initWithFrame:self.frame];
    gradientView.tag = VIEW_TAG;
    [self insertSubview:gradientView atIndex:1];
    [gradientView release];
  }
  gradientView.hidden = NO;
  gradientView.alpha = [CBRPrefsManager sharedInstance].bannerAlpha;

  if ([CBRPrefsManager sharedInstance].useBannerGradient) {
    UIColor *color2 = ([%c(ColorBadges) isDarkColor:color]) ? [color1 cbr_lighten:0.1] : [color1 cbr_darken:0.1];
    NSArray *colors = @[ (id)color1.CGColor, (id)color2.CGColor ];
    [gradientView setColors:colors];
  } else {
    [gradientView setSolidColor:color1];
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
    CBRPrefsManager *prefsManager = [CBRPrefsManager sharedInstance];

    if (!prefsManager.bannersEnabled) {
      CBRGradientView *gradientView = (CBRGradientView *)[self viewWithTag:VIEW_TAG];
      gradientView.hidden = YES; // Not sure if needed (probably isn't).
    } else {
      int color;
      if (prefsManager.bannersUseConstantColor) {
        color = prefsManager.bannerBackgroundColor;
      } else {
        Class cb = %c(ColorBadges);
        SBBulletinBannerItem *item = [context item];
        UIImage *image = [item iconImage];
        color = [[cb sharedInstance] colorForImage:image];
      }

      [self colorizeBackground:color];
      [self colorizeText:color];

      // Colorize/hide the grabber.
      UIView *grabberView = MSHookIvar<UIView *>(self, "_grabberView");
      if ([CBRPrefsManager sharedInstance].hideGrabber) {
        grabberView.hidden = YES;
      } else {
        grabberView.layer.compositingFilter = nil;
        grabberView.opaque = NO;
        UIColor *c = (isWhitish(color)) ? [UIColor darkGrayColor] : [UIColorFromRGBWithAlpha(color, 0.6) cbr_darken:0.3];
        [self _setGrabberColor:c];
      }

      // Colorize the buttons.
      id pullDownView = self.pullDownView;
      if ([pullDownView isKindOfClass:%c(SBBannerButtonView)]) {
        [(SBBannerButtonView *)pullDownView colorize:color];
      }
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

  // TinyBar support.
  objc_setAssociatedObject(self, @selector(secondaryTextColor), color, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// TinyBar support.
%new
- (UIColor *)secondaryTextColor {
  return objc_getAssociatedObject(self, @selector(secondaryTextColor));
}

// TinyBar support.
- (id)_newAttributedStringForSecondaryText:(id)secondaryText italicized:(BOOL)italicized {
  NSAttributedString *str = %orig;
  UIColor *secondaryTextColor = [self secondaryTextColor];

  if (secondaryTextColor) {
    NSAttributedString *newStr = copyAttributedStringWithColor(str, secondaryTextColor);
    [str release];
    return newStr;
  }
  return str;
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
  CGFloat alpha = ([CBRPrefsManager sharedInstance].bannerAlpha / 2) + 0.2;
  UIColor *color = UIColorFromRGBWithAlpha(colorInt, alpha);
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
  if ([CBRPrefsManager sharedInstance].removeLSBlur && [requester isEqual:@"NotificationList"]) {
    return;
  }

  %orig;
}

%end
%end

%group QuickReply
%hook CKInlineReplyViewController

- (void)setupView {
  %orig;

  // To hide the rounded-rect altogether.
  if ([CBRPrefsManager sharedInstance].hideQRRect) {
    CKMessageEntryView *entryView = self.entryView;
    _UITextFieldRoundedRectBackgroundViewNeue *view = MSHookIvar<id>(entryView, "_coverView");
    view.hidden = YES;
  }
}

%end

// Eclipse fixes.
// static BOOL shouldOverrideUIBezierPath = NO;

// %hook _UITextFieldRoundedRectBackgroundViewNeue

// - (void)updateView {
//   shouldOverrideUIBezierPath = YES;
//   %orig;
//   shouldOverrideUIBezierPath = NO;
// }

// %end

// %hook UIBezierPath

// - (void)fill {
//   if (shouldOverrideUIBezierPath) {
//     [self fillWithBlendMode:kCGBlendModeNormal alpha:0.2];
//     return;
//   }

//   %orig;
// }

// %end
%end

%ctor {
  NSString *bundle = [NSBundle mainBundle].bundleIdentifier;

  if ([bundle isEqualToString:@"com.apple.springboard"]) {
    %init(LockScreen);
    %init(Banners);
    %init(RemoveUnderlay);

    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                    NULL,
                                    &showTestLockScreenNotification,
                                    CFSTR(TEST_LS),
                                    NULL,
                                    0);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                    NULL,
                                    &showTestBanner,
                                    CFSTR(TEST_BANNER),
                                    NULL,
                                    0);
  }
  else if ([bundle isEqualToString:@"com.apple.mobilesms.notification"]) {
    %init(QuickReply);
  }
}
