//
//  UIImage+SimpleEdit.h
//
//  Created by w91379137 on 2014/12/18.
//


#import <UIKit/UIKit.h>

@interface UIImage (SimpleEdit)

#pragma mark - 做純色圖
+(UIImage *)makePureColorImage:(CGSize)size
                         Color:(UIColor *)color;

#pragma mark - 做漸層圖
+(UIImage *)makeGradientImage:(CGSize)size
                   StartPoint:(CGPoint)startPoint
                     EndPoint:(CGPoint)endPoint
                       Colors:(NSArray *)colorArray
                     Location:(NSArray *)locationArray;

#pragma mark - 貼圖
-(UIImage *)addImage:(UIImage *)image
             atPoint:(CGPoint)point;

-(UIImage *)addImageCenter:(UIImage *)image;

#pragma mark - 貼字
-(UIImage *)addString:(NSString *)string
             withfont:(NSDictionary *)fontDictionary
              atPoint:(CGPoint)point;

#pragma mark - 混合
-(UIImage *)makeTexture:(UIImage *)textureImage;

+(UIImage *)makeTexture:(UIImage *)iconImage
                Texture:(UIImage *)textureImage;

+(UIImage *)makeTexture:(UIImage *)iconImage
                Texture:(UIImage *)textureImage
                   mode:(CGBlendMode)mode;

#pragma mark - 做圓角
-(id)createRoundedRadius:(NSInteger)radius;
-(id)createRoundedAtCorners:(UIRectCorner)corners
                     Radius:(NSInteger)radius;

+(id)createRoundedRectImage:(UIImage*)image
                       size:(CGSize)size
                     radius:(NSInteger)radius;

#pragma mark - 改大小
+(UIImage *)reSizeImage:(UIImage *)image toSize:(CGSize)reSize;

#pragma mark - 切圖
-(UIImage *)subImageInRect:(CGRect)rect;
+(UIImage *)changeColor:(UIImage *)image color:(UIColor *)color;

//#pragma mark - 存圖片



@end
