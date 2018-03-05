#import <UIKit/UIKit.h>

@interface UIImage (RGBAAtPixel)

- (BOOL)rgbaAtPixel:(CGPoint)point
                red:(CGFloat*)red
              green:(CGFloat*)green
               blue:(CGFloat*)blue;

- (BOOL)rgbaAverage:(CGFloat*)red
              green:(CGFloat*)green
               blue:(CGFloat*)blue;

@end
