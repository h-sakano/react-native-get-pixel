#import <CoreGraphics/CoreGraphics.h>
#import "UIImage+RGBAAtPixel.h"

@implementation UIImage (RGBAAtPixel)

- (BOOL)rgbaAtPixel:(CGPoint)point
                red:(CGFloat*)red
              green:(CGFloat*)green
               blue:(CGFloat*)blue {
    // Cancel if point is outside image coordinates
    if (!CGRectContainsPoint(CGRectMake(0.0f, 0.0f, self.size.width, self.size.height), point)) {
        return NO;
    }
    
    // Create a 1x1 pixel byte array and bitmap context to draw the pixel into.
    // Reference: http://stackoverflow.com/questions/1042830/retrieving-a-pixel-alpha-value-for-a-uiimage
    NSInteger pointX = point.x;
    NSInteger pointY = point.y;
    CGImageRef cgImage = self.CGImage;
    NSUInteger width = self.size.width;
    NSUInteger height = self.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    int bytesPerPixel = 4;
    int bytesPerRow = bytesPerPixel * 1;
    NSUInteger bitsPerComponent = 8;
    unsigned char pixelData[4] = { 0, 0, 0, 0 };
    CGContextRef context = CGBitmapContextCreate(pixelData,
                                                 1,
                                                 1,
                                                 bitsPerComponent,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    
    CGContextTranslateCTM(context, -pointX, pointY-(CGFloat)height);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, (CGFloat)width, (CGFloat)height), cgImage);
    CGContextRelease(context);
    
    *red = (CGFloat)pixelData[0];
    *green = (CGFloat)pixelData[1];
    *blue = (CGFloat)pixelData[2];
    return YES;
}

- (BOOL)rgbaAverage:(CGFloat*)red
              green:(CGFloat*)green
               blue:(CGFloat*)blue {

    if (self.CGImage != nil) {
        CGSize size = [self.CGImage size];
        uint32_t width = (uint32_t) size.width, height = (uint32_t) size.height, components = 4;
        uint8_t *pixels = (uint8_t *) malloc(size.width * size.height * components);

        if (pixels) {
            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
            CGContextRef bitmapContext = CGBitmapContextCreate(pixels, width, height, 8, components * width, colorSpace, kCGImageAlphaPremultipliedLast);
            CGContextDrawImage(bitmapContext, CGRectMake(0, 0, width, height), [uiImage CGImage]);
            CGContextRelease(bitmapContext);
            CGColorSpaceRelease(colorSpace);

            /* Handle pixels ... */
            CGFloat total_r = 0;
            CGFloat total_g = 0;
            CGFloat total_b = 0;
            for(x = 0; x < width; x++) {
                for(y = 0; y < height; y++) {
                    // 4バイトずつ読み込みalphaは無視する
                    total_r += pixels[4 * (x + width * y) + 0];
                    total_g += pixels[4 * (x + width * y) + 1];
                    total_b += pixels[4 * (x + width * y) + 2];
                }
            }
            *red = total_r / (width * height);
            *green = total_g / (width * height);
            *blue = total_b / (width * height);

            free(pixels);
        }
    }
    
    return YES;
}

@end
