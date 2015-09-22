//
//  ViewController.m
//  Estimate_PlanarWarps
//
//  Created by Simon Lucey on 9/21/15.
//  Copyright (c) 2015 CMU_16432. All rights reserved.
//

#import "ViewController.h"

#ifdef __cplusplus
#include <opencv2/opencv.hpp> // Includes the opencv library
#include <stdlib.h> // Include the standard library
#include "armadillo" // Includes the armadillo library
#endif

using namespace std;

@interface ViewController () {
    // Setup the view
    UIImageView *imageView_;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // 3D planar points of the Prince Computer Vision textbook (in cm)
    arma::fmat W;
    W << 0.0 << 18.3 << 18.3 <<  0.0 << arma::endr
      << 0.0 <<  0.0 << 26.1 << 26.1 << arma::endr
      << 0.0 <<  0.0 <<  0.0 << 0.0;
    
    // Corresponding 2D projected points of the book in the image
    arma::fmat X;
    X << 482 << 1688 << 2180 <<  62 << arma::endr
      << 809 <<  782 << 2216 << 2291;
    
    // Intrinsics matrix for the device it was caputured from...
    arma::fmat K;
    K << 1627 <<    0 << 1224 << arma::endr
      <<    0 << 1627 << 1632 << arma::endr
      <<    0 <<    0 <<    1;
    
    // Load the 3D sphere points (dimensions of ball are in cm)
    NSString *str = [[NSBundle mainBundle] pathForResource:@"sphere" ofType:@"txt"];
    const char *SphereName = [str UTF8String]; // Convert to const char *
    arma::fmat sphere; sphere.load(SphereName); // Load the Sphere into memory should be 3xN
    
    // Read in the image
    UIImage *image = [UIImage imageNamed:@"prince_book.jpg"];
    if(image == nil) cout << "Cannot read in the file prince_book.jpg!!" << endl;
    
    // Setup the display
    // Setup the your imageView_ view, so it takes up the entire App screen......
    imageView_ = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
    // Important: add OpenCV_View as a subview
    [self.view addSubview:imageView_];
    // Ensure aspect ratio looks correct
    imageView_.contentMode = UIViewContentModeScaleAspectFit;
    
    // Another way to convert between cvMat and UIImage (using member functions)
    cv::Mat cvImage = [self cvMatFromUIImage:image];
    cv::Mat gray; cv::cvtColor(cvImage, gray, CV_RGBA2GRAY); // Convert to grayscale
    cv::Mat display_im; cv::cvtColor(gray,display_im,CV_GRAY2BGR); // Get the display image
    const cv::Scalar RED = cv::Scalar(0,0,255); // Set the RED color
    display_im = DrawPts(display_im, X, RED);
    display_im = DrawLines(display_im, X, RED);
    
    // PLACE YOUR ASSIGNMENT 1 CODE HERE!!!!!!
    
    
    // Switch colors to account for how UIImage and cv::Mat lay out their color channels differently
    cv::cvtColor(display_im, display_im, CV_BGRA2RGBA);
    
    // Finally setup the view to display
    imageView_.image = [self UIImageFromCVMat:display_im];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//---------------------------------------------------------------------------------------------------------------------
// You should not have to touch these functions below to complete the assignment!!!!
//---------------------------------------------------------------------------------------------------------------------
// Quick function to draw points on an UIImage
cv::Mat DrawPts(cv::Mat &display_im, arma::fmat &pts, const cv::Scalar &pts_clr)
{
   vector<cv::Point2f> cv_pts = Arma2Points2f(pts); // Convert to vector of Point2fs
   for(int i=0; i<cv_pts.size(); i++) {
       cv::circle(display_im, cv_pts[i], 5, pts_clr,5); // Draw the points
   }
    return display_im; // Return the display image
}
// Quick function to draw lines on an UIImage
cv::Mat DrawLines(cv::Mat &display_im, arma::fmat &pts, const cv::Scalar &pts_clr)
{
    vector<cv::Point2f> cv_pts = Arma2Points2f(pts); // Convert to vector of Point2fs
    for(int i=0; i<cv_pts.size(); i++) {
        int j = i + 1; if(j == cv_pts.size()) j = 0; // Go back to first point at the enbd
        cv::line(display_im, cv_pts[i], cv_pts[j], pts_clr, 3); // Draw the line
    }
    return display_im; // Return the display image
}
// Quick function to convert Armadillo to OpenCV Points
vector<cv::Point2f> Arma2Points2f(arma::fmat &pts)
{
 vector<cv::Point2f> cv_pts;
 for(int i=0; i<pts.n_cols; i++) {
 cv_pts.push_back(cv::Point2f(pts(0,i), pts(1,i))); // Add points
 }
 return cv_pts; // Return the vector of OpenCV points
}
// Member functions for converting from cvMat to UIImage
- (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}
// Member functions for converting from UIImage to cvMat
-(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}

@end
