#import "ColorBadges.h"
#import "PrivateHeaders.h"

#define UIColorFromRGBWithAlpha(rgb, a) [UIColor colorWithRed:GETRED(rgb)/255.0 green:GETGREEN(rgb)/255.0 blue:GETBLUE(rgb)/255.0 alpha:a]

static BOOL suppressBackgroundColorChanges = NO;

// TODO(DavidGoldman): Either use ColorBadges's isDarkColor or improve this.
static BOOL isWhitish(int rgb) {
  int r = GETRED(rgb);
  int g = GETGREEN(rgb);
  int b = GETBLUE(rgb);
  return r > 200 && g > 200 && b > 200;
}

%hook SBLockScreenNotificationListView

- (void)_setContentForTableCell:(SBLockScreenBulletinCell *)cell withItem:(id)item atIndexPath:(id)path {
  %orig;

  if ([cell isMemberOfClass:%c(SBLockScreenBulletinCell)]) {
    Class cb = %c(ColorBadges);
    UIImage *image = [item iconImage];
    int color = [[cb sharedInstance] colorForImage:image];

    BOOL isWhite = isWhitish(color);

    cell.backgroundColor = UIColorFromRGBWithAlpha(color, ((isWhite) ? 1 : 0.65));
    if (isWhite) {
      cell.eventDateLabel.layer.compositingFilter = nil;
      cell.relevanceDateLabel.layer.compositingFilter = nil;
      MSHookIvar<UILabel *>(cell, "_unlockTextLabel").layer.compositingFilter = nil;

      UIColor *textColor = [UIColor darkGrayColor];
      cell.primaryTextColor = textColor;
      cell.subtitleTextColor = textColor;
      cell.secondaryTextColor = textColor;
      cell.relevanceDateColor = textColor;
      cell.eventDateColor = textColor;
    }
  }
}

- (void)tableView:(id)arg1 willDisplayCell:(id)arg2 forRowAtIndexPath:(id)arg3 {
  suppressBackgroundColorChanges = YES;
  %orig;
  suppressBackgroundColorChanges = NO;
}

%end

%hook SBLockScreenBulletinCell

- (void)setBackgroundColor:(UIColor *)color {
  if ([self isMemberOfClass:%c(SBLockScreenBulletinCell)] && suppressBackgroundColorChanges) {
    return;
  }
  %orig;
} 

%end

