#import "CBRGradientView.h"

@implementation CBRGradientView

+ (Class)layerClass {
  return [CAGradientLayer class];
}

// TODO(DavidGoldman): Add support for different gradient directions.
- (instancetype)initWithFrame:(CGRect)frame colors:(NSArray *)colors {
  self = [super initWithFrame:frame];
  if (self) {
    self.opaque = NO;
    _colors = [colors retain];
    [self refreshGradientLayer];
  }
  return self;
}

- (void)setColors:(NSArray *)colors {
  [colors retain];
  [_colors release];
  _colors = colors;
  [self refreshGradientLayer];
}

- (void)refreshGradientLayer {
  CAGradientLayer *gradientLayer = (CAGradientLayer *)self.layer;
  gradientLayer.colors = _colors;
  gradientLayer.startPoint = CGPointMake(0.0, 0.5);
  gradientLayer.endPoint = CGPointMake(1.0, 0.5);
}

- (void)dealloc {
  [_colors release];
  [super dealloc];
}

@end
