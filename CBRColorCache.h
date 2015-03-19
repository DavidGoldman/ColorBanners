@interface CBRColorCache : NSObject {
  NSCache *_cache;
}

+ (instancetype)sharedInstance;
+ (BOOL)isDarkColor:(int)color;

- (int)colorForIdentifier:(NSString *)identifier image:(UIImage *)image;

@end
