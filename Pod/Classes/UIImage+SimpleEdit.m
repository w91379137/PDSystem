//
//  UIImage+SimpleEdit.m
//
//  Created by w91379137 on 2014/12/18.
//

#import "UIImage+SimpleEdit.h"

@implementation UIImage (SimpleEdit)

#pragma mark - 做純色圖
+(UIImage *)makePureColorImage:(CGSize)size
                         Color:(UIColor *)color
{
    UIImage *aPureColorImage = nil;
    
    if (color != nil) {
        CGSize imageSize = size;
        UIGraphicsBeginImageContextWithOptions(imageSize, 0, [UIScreen mainScreen].scale);
        [color set];
        UIRectFill(CGRectMake(0, 0, imageSize.width, imageSize.height));
        aPureColorImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    return aPureColorImage;
}

#pragma mark - 做漸層圖
+(UIImage *)makeGradientImage:(CGSize)size
                   StartPoint:(CGPoint)startPoint
                     EndPoint:(CGPoint)endPoint
                       Colors:(NSArray *)colorArray
                     Location:(NSArray *)locationArray
{
    //使用RGB顏色模型
    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
    
    //取出顏色的資訊
    NSMutableArray *valuesArray = [UIImage valuesFromColors:colorArray];
    
    //漸層中所包含的關鍵顏色 RGBA
    CGFloat components[[valuesArray count]];
    for (int i = 0; i < [valuesArray count]; i++) {
        components[i] = [[valuesArray objectAtIndex:i] floatValue];
    }
    
    //關鍵顏色所出現的位置
    CGFloat locations[[locationArray count]];
    for (int i = 0; i < [locationArray count]; i++) {
        locations[i] = [[locationArray objectAtIndex:i] floatValue];
    }
    
    //關鍵顏色的個數
    size_t count = colorArray.count;
    
    //製作漸層顏色模型
    CGGradientRef gradient = CGGradientCreateWithColorComponents(rgb, components, locations, count);
    CGColorSpaceRelease(rgb);
    
    //開始繪圖
    UIGraphicsBeginImageContextWithOptions(size, 0, [UIScreen mainScreen].scale);
    
    //指定畫布
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //繪製漸層線條
    CGContextDrawLinearGradient(context, gradient, CGPointMake(0.0, 0.0), CGPointMake(size.width, size.height), 0);
    
    //將畫布指定給Image
    UIImage *aGradientImage = UIGraphicsGetImageFromCurrentImageContext();
    CGGradientRelease(gradient);
    
    //結束繪圖
    UIGraphicsEndImageContext();
    return aGradientImage;
}

#pragma mark - 貼圖
-(UIImage *)addImage:(UIImage *)image
             atPoint:(CGPoint)point
{
    //畫布設定
    UIGraphicsBeginImageContextWithOptions(self.size, NO, [UIScreen mainScreen].scale);
    
    //畫上背景
    [self drawAtPoint:CGPointMake(0, 0)];
    
    //畫上增加圖
    [image drawAtPoint:point];
    
    //將影像傳回
    UIImage *completeImage = UIGraphicsGetImageFromCurrentImageContext();
    
    //結束繪圖
    UIGraphicsEndImageContext();
    return completeImage;
}

-(UIImage *)addImageCenter:(UIImage *)image
{
    CGPoint point = CGPointMake((self.size.width - image.size.width) / 2,
                                (self.size.height - image.size.height) / 2);
    return [self addImage:image atPoint:point];
}

#pragma mark - 貼字
-(UIImage *)addString:(NSString *)string
             withfont:(NSDictionary *)fontDictionary
              atPoint:(CGPoint)point
{
    //畫布設定
    UIGraphicsBeginImageContextWithOptions(self.size, NO, [UIScreen mainScreen].scale);
    
    //畫上背景
    [self drawAtPoint:CGPointMake(0, 0)];
    
    //寫上文字
    [string drawAtPoint:point withAttributes:fontDictionary];
    
    //將影像傳回
    UIImage *completeImage = UIGraphicsGetImageFromCurrentImageContext();
    
    //結束繪圖
    UIGraphicsEndImageContext();
    return completeImage;
}

#pragma mark - 混合
-(UIImage *)makeTexture:(UIImage *)textureImage
{
    return [UIImage makeTexture:self Texture:textureImage];
}

+(UIImage *)makeTexture:(UIImage *)iconImage
                Texture:(UIImage *)textureImage
{
    return [self makeTexture:iconImage Texture:textureImage mode:kCGBlendModeOverlay];
}

+(UIImage *)makeTexture:(UIImage *)iconImage
                Texture:(UIImage *)textureImage
                   mode:(CGBlendMode)mode
{
    UIImage *iconImageWithTexture = nil;
    
    if (iconImage != nil && textureImage != nil) {
        UIGraphicsBeginImageContextWithOptions(iconImage.size, 0, [UIScreen mainScreen].scale);
        
        //設定參考範圍
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextScaleCTM(context, 1, -1);
        
        CGRect region = CGRectMake(0, 0, iconImage.size.width, iconImage.size.height);
        CGContextTranslateCTM(context, 0, -region.size.height);
        CGContextSaveGState(context);
        
        //可以有保留透明背景的效果
        CGContextClipToMask(context, region, iconImage.CGImage);
        
        //將材質紋理與原影像混和
        CGContextDrawImage(context, region, textureImage.CGImage);
        CGContextRestoreGState(context);
        CGContextSetBlendMode(context, mode);
        CGContextDrawImage(context, region, iconImage.CGImage);
        
        //將影像指定給image
        iconImageWithTexture = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
    }
    
    return iconImageWithTexture;
}

#pragma mark - 做圓角
-(id)createRoundedRadius:(NSInteger)radius
{
    return [UIImage createRoundedRectImage:self size:self.size radius:radius];
}

-(id)createRoundedAtCorners:(UIRectCorner)corners Radius:(NSInteger)radius
{
    //下面兩個角導角
    UIBezierPath *maskPath;
    //corners >> UIRectCornerBottomLeft | UIRectCornerBottomRight
    maskPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.size.width, self.size.height)
                                     byRoundingCorners:corners
                                           cornerRadii:CGSizeMake(radius, radius)];
    return [self clipImageByPath:maskPath];
}

+(id)createRoundedRectImage:(UIImage*)image
                       size:(CGSize)size
                     radius:(NSInteger)radius
{
    // the size of CGContextRef
    int w = size.width;
    int h = size.height;
    
    UIImage *img = image;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
    CGRect rect = CGRectMake(0, 0, w, h);
    
    CGContextBeginPath(context);
    addRoundedRectToPath(context, rect, radius, radius);
    CGContextClosePath(context);
    CGContextClip(context);
    
    CGContextDrawImage(context, CGRectMake(0, 0, w, h), img.CGImage);
    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
    
    img = [UIImage imageWithCGImage:imageMasked];
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(imageMasked);
    
    UIImage *completeImage = [UIImage reSizeImage:img toSize:size];
    return completeImage;
}

static void addRoundedRectToPath(CGContextRef context,
                                 CGRect rect,
                                 float ovalWidth,
                                 float ovalHeight)
{
    float fw, fh;
    if (ovalWidth == 0 || ovalHeight == 0) {
        CGContextAddRect(context, rect);
        return;
    }
    
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextScaleCTM(context, ovalWidth, ovalHeight);
    fw = CGRectGetWidth(rect) / ovalWidth;
    fh = CGRectGetHeight(rect) / ovalHeight;
    
    CGContextMoveToPoint(context, fw, fh/2);  // Start at lower right corner
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);  // Top right corner
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1); // Top left corner
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1); // Lower left corner
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1); // Back to lower right
    
    CGContextClosePath(context);
    CGContextRestoreGState(context);
}

+ (void)drawRectCornerRadius:(CGRect)rect radius:(int)radius context:(CGContextRef )context
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGPoint pLT = CGPointMake(rect.origin.x + radius,
                              rect.origin.y + radius);
    CGPoint pRT = CGPointMake(rect.origin.x + rect.size.width - radius,
                              rect.origin.y + radius);
    CGPoint pLB = CGPointMake(rect.origin.x + radius,
                              rect.origin.y + rect.size.height - radius);
    CGPoint pRB = CGPointMake(rect.origin.x + rect.size.width - radius,
                              rect.origin.y + rect.size.height - radius);
    
    //[path moveToPoint:p1];
    [path addArcWithCenter:pLT radius:radius startAngle:M_PI endAngle:-M_PI_2 clockwise:YES];
    [path addArcWithCenter:pRT radius:radius startAngle:-M_PI_2 endAngle:0 clockwise:YES];
    [path addArcWithCenter:pRB radius:radius startAngle:0 endAngle:M_PI_2 clockwise:YES];
    [path addArcWithCenter:pLB radius:radius startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
    [path closePath];
    
    /*
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = [path CGPath];
    shapeLayer.strokeColor = [[UIColor blueColor] CGColor];
    shapeLayer.lineWidth = 1.0;
    shapeLayer.fillColor = [[UIColor clearColor] CGColor];
     */
    
    path.lineCapStyle = kCGLineCapRound;
    path.lineWidth = 10.0f;
    [[UIColor blackColor] setStroke];
    [[UIColor redColor] setFill];
    [path stroke];
    [path fill];
    
    //CGContextRef currentContext = UIGraphicsGetCurrentContext();
    //CGContextSetLineWidth(currentContext, 3.0);
    //CGContextSetLineCap(currentContext, kCGLineCapRound);
    //CGContextSetLineJoin(currentContext, kCGLineJoinRound);
    CGContextBeginPath(context);
    CGContextAddPath(context, path.CGPath);
    CGContextDrawPath(context, kCGPathStroke);
}

#pragma mark - 改大小
+(UIImage *)reSizeImage:(UIImage *)image toSize:(CGSize)reSize
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(reSize.width, reSize.height), 0, [UIScreen mainScreen].scale);
    [image drawInRect:CGRectMake(0, 0, reSize.width, reSize.height)];
    UIImage *reSizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return reSizeImage;
}

#pragma mark - 切圖
-(UIImage *)subImageInRect:(CGRect)rect
{
    CGImageRef drawImage = CGImageCreateWithImageInRect(self.CGImage, rect);
    UIImage *newImage = [UIImage imageWithCGImage:drawImage];
    CGImageRelease(drawImage);
    return newImage;
}

-(UIImage *)clipImageByPath:(UIBezierPath *)path
{
    UIGraphicsBeginImageContextWithOptions(self.size, 0, [UIScreen mainScreen].scale);
    
    //path
    //UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight cornerRadii:CGSizeMake(self.cornerRadius, self.cornerRadius)];
    [path addClip];
    
    [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+(UIImage *)changeColor:(UIImage *)image color:(UIColor *)color
{
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    
    UIGraphicsBeginImageContextWithOptions(rect.size, 0, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClipToMask(context, rect, image.CGImage);
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImage *flippedImage = [UIImage imageWithCGImage:img.CGImage
                                                scale:1.0
                                          orientation:UIImageOrientationDownMirrored];
    
    return flippedImage;
}

#pragma mark - 資料處理部
+(NSMutableArray *)valuesFromColors:(NSArray *)colorArray
{
    NSMutableArray *valuesArray = [NSMutableArray array];
    for (int k = 0; k < [colorArray count]; k++) {
        
        UIColor *aColor = colorArray[k];
        const CGFloat *_components = CGColorGetComponents(aColor.CGColor);
        float red = _components[0];
        float green = _components[1];
        float blue = _components[2];
        float alpha = 1;
        
        [valuesArray addObject:@(red)];
        [valuesArray addObject:@(green)];
        [valuesArray addObject:@(blue)];
        [valuesArray addObject:@(alpha)];
    }
    return valuesArray;
}

@end
