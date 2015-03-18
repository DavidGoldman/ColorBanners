#import "CBRColorCache.h"

#import "ColorBadges.h"
#import "Defines.h"

#define DEFAULT_COUNT_LIMIT 100

@implementation CBRColorCache

+ (instancetype)sharedInstance {
  static dispatch_once_t onceToken;
  static CBRColorCache *cache;
  dispatch_once(&onceToken, ^{ cache = [[CBRColorCache alloc] init]; } );
  return cache;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _cache = [[NSCache alloc] init];
    [_cache setCountLimit:DEFAULT_COUNT_LIMIT];
  }
  return self;
}

- (int)colorForIdentifier:(NSString *)identifier image:(UIImage *)image {
  if (!identifier) {
    CBRLOG(@"No identifier given for image %@", image);
    return [[%c(ColorBadges) sharedInstance] colorForImage:image];
  }

  NSNumber *colorNum = [_cache objectForKey:identifier];
  if (colorNum) {
    CBRLOG(@"Cache hit for identifier %@", identifier);

    return [colorNum intValue];
  } else {
    CBRLOG(@"Cache miss for identifier %@", identifier);

    int color = [[%c(ColorBadges) sharedInstance] colorForImage:image];
    [_cache setObject:@(color) forKey:identifier];
    return color;
  }
}

- (void)dealloc {
  [_cache release];
  [super dealloc];
}

@end
