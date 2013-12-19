//
//  ViewController.m
//  FaceDetectorDemo
//
//  Created by Cendy on 12/19/13.
//  Copyright (c) 2013 com.cendy. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreImage/CoreImage.h>

#define MaxImageCount 7

@interface ViewController ()
{
    CGAffineTransform transform;
}
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    transform = CGAffineTransformMakeScale(1, -1);
    transform = CGAffineTransformTranslate(transform, 0, -imageScrollView.bounds.size.height);
    
    for (int i = 0; i != MaxImageCount; ++i) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%d.jpg", i]];
        CGRect rect = CGRectMake(i * imageScrollView.frame.size.width, 0, imageScrollView.frame.size.width, imageScrollView.frame.size.height);
        image = [self resizeImageWithImage:image Size:rect.size];
        
        [imageScrollView addSubview:[self getImageViewWithRect:rect Image:image]];
    }
    
    imageScrollView.contentSize = CGSizeMake(MaxImageCount * imageScrollView.frame.size.width, imageScrollView.frame.size.height);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIImageView *)getImageViewWithRect:(CGRect)rect Image:(UIImage *)image
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:rect];
    imageView.image = image;
    
    NSArray *features = [self detectFaceWithImage:image];
    
    for (CIFaceFeature *feature in features) {
        const CGRect faceRect = CGRectApplyAffineTransform(feature.bounds, transform);
        UIView *faceView = [[UIView alloc] initWithFrame:faceRect];
        NSLog(@"face rect : %@", NSStringFromCGRect(faceView.frame));
        faceView.backgroundColor = [UIColor clearColor];
        faceView.layer.borderWidth = 3.0f;
        faceView.layer.borderColor = [UIColor purpleColor].CGColor;
        [imageView addSubview:faceView];
        
        if (feature.hasFaceAngle) {
            NSLog(@"face angle : %f", feature.faceAngle);
        }
        
        if (feature.hasLeftEyePosition) {
            const CGPoint leftEyePoint = CGPointApplyAffineTransform(feature.leftEyePosition, transform);
            NSLog(@"left eye position : (%f, %f)", leftEyePoint.x, leftEyePoint.y);
            
            [self addAViewWithPoint:leftEyePoint To:imageView];
        }
        
        if (feature.hasRightEyePosition) {
            const CGPoint rightEyePoint = CGPointApplyAffineTransform(feature.rightEyePosition, transform);
            NSLog(@"right eye position : (%f, %f)", rightEyePoint.x, rightEyePoint.y);
            
            [self addAViewWithPoint:rightEyePoint To:imageView];
        }
        
        if (feature.hasMouthPosition) {
            const CGPoint mouthPoint = CGPointApplyAffineTransform(feature.mouthPosition, transform);
            NSLog(@"mouth position : (%f, %f)", mouthPoint.x, mouthPoint.y);
            
            [self addAViewWithPoint:mouthPoint To:imageView];
        }
        
        NSLog(@"smile : %@", feature.hasSmile ? @"YES" : @"NO");
    }
    
    return imageView;
}

- (void)addAViewWithPoint:(CGPoint)point To:(UIView *)view
{
    CGFloat signWidth = 30.0f, signHeight = 30.0f;
    UIView *temp = [[UIView alloc] initWithFrame:CGRectMake(0, 0, signWidth, signHeight)];
    temp.center = point;
    temp.backgroundColor = [UIColor clearColor];
    temp.layer.borderColor = [UIColor purpleColor].CGColor;
    temp.layer.borderWidth = 2.0f;
    [view addSubview:temp];
}

- (UIImage *)resizeImageWithImage:(UIImage *)image Size:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *new = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return new;
}

- (NSArray *)detectFaceWithImage:(UIImage *)image
{
    CIImage *ciImage = [CIImage imageWithCGImage:image.CGImage];
    
    NSDictionary *options = [NSDictionary dictionaryWithObject:CIDetectorAccuracyHigh forKey:CIDetectorAccuracy];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace
                                              context:nil
                                              options:options];
    
    NSArray *features = [detector featuresInImage:ciImage];
    NSLog(@"features count : %d", features.count);
    return features;
}

@end
