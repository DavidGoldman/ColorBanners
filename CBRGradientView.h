#import <CoreGraphics/CoreGraphics.h>

@interface CBRGradientView : UIView {
  NSArray *_colors;
}

- (instancetype)initWithFrame:(CGRect)frame colors:(NSArray *)colors;
- (void)setColors:(NSArray *)colors;

@end
