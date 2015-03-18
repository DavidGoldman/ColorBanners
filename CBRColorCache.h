@interface CBRColorCache : NSObject {
  NSCache *_cache;
}

+ (instancetype)sharedInstance;
- (int)colorForIdentifier:(NSString *)identifier image:(UIImage *)image;

@end
