#include "RNGetPixel.h"
#import "React/RCTImageLoader.h"
#import "React/RCTBridge.h"
#import "UIImage+RGBAAtPixel.h"
#import <math.h>

@implementation RNPixelColor

@synthesize bridge = _bridge;

static CGFloat rotation = M_PI / 2;

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(getPixelRGBAofImage:(NSString *)filePath
                  atX:(CGFloat)x
                  atY:(CGFloat)y
                  callback:(RCTResponseSenderBlock)callback) {
    UIImage *image;
    if ([filePath hasPrefix:@"data:"] || [filePath hasPrefix:@"file:"]) {
        NSURL *imageUrl = [[NSURL alloc] initWithString:filePath];
        image = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageUrl]];
    }
    else {
        image = [[UIImage alloc] initWithContentsOfFile:filePath];
    }

    if (image == nil) {
        return callback(@[@"Could not create image from given path.", @""]);
    }
    [self getPixelColorFromImage:image atX:x atY:y callback:callback];
}

RCT_EXPORT_METHOD(getPixelRGBAverageOfImage:(NSString *)filePath
                  callback:(RCTResponseSenderBlock)callback) {
    UIImage *image;
    if ([filePath hasPrefix:@"data:"] || [filePath hasPrefix:@"file:"]) {
        NSURL *imageUrl = [[NSURL alloc] initWithString:filePath];
        image = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageUrl]];
    }
    else {
        image = [[UIImage alloc] initWithContentsOfFile:filePath];
    }

    if (image == nil) {
        return callback(@[@"Could not create image from given path.", @""]);
    }
    [self getAverageColorFromImage:image callback:callback];
}

RCT_EXPORT_METHOD(getPixelRGBAPolarOfImage:(NSString *)filePath
                  angle:(CGFloat)angle
                  radius:(CGFloat)radius
                  callback:(RCTResponseSenderBlock)callback) {
    UIImage *image;
    if ([filePath hasPrefix:@"data:"] || [filePath hasPrefix:@"file:"]) {
        NSURL *imageUrl = [[NSURL alloc] initWithString:filePath];
        image = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageUrl]];
    }
    else {
        image = [[UIImage alloc] initWithContentsOfFile:filePath];
    }

    if (image == nil) {
        return callback(@[@"Could not create image from given path.", @""]);
    }

    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    CGFloat rotatedAngle = angle + rotation;
    
    CGPoint center = CGPointMake(width * 0.5, height * 0.5);
    
    CGFloat x = center.x + radius * cosf(rotatedAngle);
    CGFloat y = center.y + radius * sinf(rotatedAngle);
    [self getPixelColorFromImage:image atX:x atY:y callback:callback];
}

RCT_EXPORT_METHOD(findAngleOfNearestColor:(NSString *)filePath
                  minAngle:(CGFloat)minAngle
                  maxAngle:(CGFloat)maxAngle
                  radius:(CGFloat)radius
                  targetColor:(NSArray*)targetColor
                  callback:(RCTResponseSenderBlock)callback) {
    UIImage *image;
    if ([filePath hasPrefix:@"data:"] || [filePath hasPrefix:@"file:"]) {
        NSURL *imageUrl = [[NSURL alloc] initWithString:filePath];
        image = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageUrl]];
    }
    else {
        image = [[UIImage alloc] initWithContentsOfFile:filePath];
    }

    if (image == nil) {
        return callback(@[@"Could not create image from given path.", @""]);
    }

    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    CGPoint center = CGPointMake(width * 0.5, height * 0.5);
    CGFloat angle = minAngle;
    
    CGFloat targetRed = [targetColor[0] floatValue];
    CGFloat targetGreen = [targetColor[1] floatValue];
    CGFloat targetBlue = [targetColor[2] floatValue];
    
    CGFloat minDistance = CGFLOAT_MAX;
    CGFloat resultAngle = CGFLOAT_MAX;

    while (angle <= maxAngle) {
        CGFloat rotatedAngle = angle + rotation;
        CGFloat x = center.x + radius * cosf(rotatedAngle);
        CGFloat y = center.y + radius * sinf(rotatedAngle);
        
        CGFloat red;
        CGFloat green;
        CGFloat blue;
        [image rgbaAtPixel:CGPointMake(x, y) red:&red green:&green blue:&blue];
        
        CGFloat distance = powf(targetRed - red, 2) + powf(targetGreen - green, 2) + powf(targetBlue - blue, 2);
        
        if (distance < minDistance) {
            minDistance = distance;
            resultAngle = angle;
        }

        angle += M_PI / 180;
    }
    callback(@[[NSNull null], @(resultAngle)]);
}

- (void)getPixelColorFromImage:(UIImage*)image atX:(CGFloat)x atY:(CGFloat)y callback:(RCTResponseSenderBlock)callback {
    CGPoint point = CGPointMake(x, y);
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    BOOL success = [image rgbaAtPixel:point red:&red green:&green blue:&blue];
    if (success) {
        callback(@[[NSNull null], @[@(red), @(green), @(blue)]]);
    } else {
        callback(@[@"Could not create image from given path.", @""]);
    }
}

- (void)getAverageColorFromImage:(UIImage*)image callback:(RCTResponseSenderBlock)callback {
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    BOOL success = [image rgbaAverage:&red green:&green blue:&blue];
    if (success) {
        callback(@[[NSNull null], @[@(red), @(green), @(blue)]]);
    } else {
        callback(@[@"Could not create image from given path.", @""]);
    }
}

@end
