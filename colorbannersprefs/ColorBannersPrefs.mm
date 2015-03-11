#import "ColorBannersPrefs.h"

#import "../NSDistributedNotificationCenter.h"

#define INTERNAL_NOTIFICATION_NAME @"CBRReloadPreferences"
#define TEST_LS "com.golddavid.colorbanners/test-ls-notification"
#define TEST_BANNER "com.golddavid.colorbanners/test-banner"

static void refreshPrefs(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
  [[NSDistributedNotificationCenter defaultCenter] postNotificationName:INTERNAL_NOTIFICATION_NAME object:nil];
}

static void refreshPrefsVolatile(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
  ColorBannersPrefsListController *controller = (ColorBannersPrefsListController *)observer;
  [controller clearCache];
  [controller reload];
  [[NSDistributedNotificationCenter defaultCenter] postNotificationName:INTERNAL_NOTIFICATION_NAME object:nil];
}

@implementation ColorBannersPrefsListController

- (instancetype)init {
  self = [super init];
  if (self) {
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), 
                                    self,
                                    &refreshPrefs,
                                    CFSTR("com.golddavid.colorbanners/reloadprefs"),
                                    NULL,
                                    0);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), 
                                    self,
                                    &refreshPrefsVolatile,
                                    CFSTR("com.golddavid.colorbanners/reloadprefs-volatile"),
                                    NULL,
                                    0);
  }
  return self;
}

- (void)dealloc {
  CFNotificationCenterRemoveObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                     self,
                                     CFSTR("com.golddavid.colorbanners/reloadprefs"),
                                     NULL);
  CFNotificationCenterRemoveObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                     self,
                                     CFSTR("com.golddavid.colorbanners/reloadprefs-volatile"),
                                     NULL);
  [super dealloc];
}

- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"ColorBannersPrefs" target:self] retain];
	}
	return _specifiers;
}

- (id)getLabelForSpecifier:(PSSpecifier *)specifier {
  NSNumber *value = [self readPreferenceValue:specifier];
  if (value) {
    return ([value boolValue]) ? @"On" : @"Off";
  }

  NSNumber *defaultValue = [specifier propertyForKey:@"default"];
  return ([defaultValue boolValue]) ? @"On" : @"Off";
}

- (void)testLockScreenNotification {
  CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(),
                                       CFSTR(TEST_LS),
                                       nil,
                                       nil,
                                       true);
}

- (void)testBanner {
  CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(),
                                       CFSTR(TEST_BANNER),
                                       nil,
                                       nil,
                                       true); 
}

@end

@implementation ColorBannersBannerPrefsController

- (id)specifiers {
  if(_specifiers == nil) {
    _specifiers = [[self loadSpecifiersFromPlistName:@"Banners" target:self] retain];
  }
  return _specifiers;
}

@end

@implementation ColorBannersLSPrefsController

- (id)specifiers {
  if(_specifiers == nil) {
    _specifiers = [[self loadSpecifiersFromPlistName:@"LockScreen" target:self] retain];
  }
  return _specifiers;
}

@end
