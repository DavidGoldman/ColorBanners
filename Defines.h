// #define DEBUG

#ifdef DEBUG
    #define CBRLOG(fmt, ...) NSLog(@"[ColorBanners]-%d %@", __LINE__, [NSString stringWithFormat:fmt, ##__VA_ARGS__])
#else
    #define CBRLOG(fmt, ...)
#endif

#define INTERNAL_NOTIFICATION_NAME @"CBRReloadPreferences"
#define TEST_LS "com.golddavid.colorbanners/test-ls-notification"
#define TEST_BANNER "com.golddavid.colorbanners/test-banner"
