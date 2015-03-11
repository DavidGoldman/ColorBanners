#import "CBRPrefsManager.h"

#import "Defines.h"
#import "NSDistributedNotificationCenter.h"

#define PREFS_NAME "com.golddavid.colorbanners"

#define BANNERS_KEY @"BannersEnabled"
#define LS_KEY @"LSEnabled"
#define BLUR_KEY @"RemoveBlur"
#define RECT_KEY @"HideQRRect"

// From ColorBadges.h.
#define GETRED(rgb) ((rgb >> 16) & 0xFF)
#define GETGREEN(rgb) ((rgb >> 8) & 0xFF)
#define GETBLUE(rgb) (rgb & 0xFF)
#define UIColorFromRGB(rgb) [UIColor colorWithRed:GETRED(rgb)/255.0 green:GETGREEN(rgb)/255.0 blue:GETBLUE(rgb)/255.0 alpha:1.0]

// Expected format: #<hex int>.
static UIColor * UIColorFromNSString(NSString *str) {
  unsigned hexColor = 0xFFFFFF; // Default to white.
  NSScanner *scanner = [NSScanner scannerWithString:str];
  [scanner setScanLocation:1]; // Skip over the '#'.
  [scanner scanHexInt:&hexColor];
  return UIColorFromRGB(hexColor);
}

@implementation CBRPrefsManager

+ (instancetype)sharedInstance {
  static dispatch_once_t onceToken;
  static CBRPrefsManager *cache;
  dispatch_once(&onceToken, ^{ cache = [[CBRPrefsManager alloc] init]; } );
  return cache;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    [self reload];
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self 
                                                        selector:@selector(reload)
                                                            name:INTERNAL_NOTIFICATION_NAME 
                                                          object:nil];
  }
  return self;
}

- (NSDictionary *)prefsDictionary {
  CFStringRef appID = CFSTR(PREFS_NAME);
  CFArrayRef keyList = CFPreferencesCopyKeyList(appID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
  if (!keyList) {
    CBRLOG(@"Unable to obtain preferences keyList!");
    return nil;
  }
  NSDictionary *dictionary = (NSDictionary *)CFPreferencesCopyMultiple(keyList, appID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
  CFRelease(keyList);
  return [dictionary autorelease];
}

- (void)reload {
  NSDictionary *prefs = [self prefsDictionary];

  _bannersEnabled = [self boolForValue:prefs[BANNERS_KEY] withDefault:YES];
  _lsEnabled = [self boolForValue:prefs[LS_KEY] withDefault:YES];
  _removeBlur = [self boolForValue:prefs[BLUR_KEY] withDefault:NO];
  _hideQRRect = [self boolForValue:prefs[RECT_KEY] withDefault:NO];
}

- (BOOL)boolForValue:(NSNumber *)value withDefault:(BOOL)defaultValue {
  return (value) ? [value boolValue] : defaultValue;
}

- (UIColor *)colorForNSString:(NSString *)string withDefault:(UIColor *)defaultColor {
  return (string) ? UIColorFromNSString(string) : defaultColor;
}

- (void)dealloc {
  [[NSDistributedNotificationCenter defaultCenter] removeObserver:self name:INTERNAL_NOTIFICATION_NAME object:nil];
  [super dealloc];
}

@end
