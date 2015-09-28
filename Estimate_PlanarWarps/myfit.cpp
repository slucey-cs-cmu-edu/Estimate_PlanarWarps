//
//  myfit.cpp
//  Estimate_Homography
//
//  Created by Simon Lucey on 9/21/15.
//  Copyright (c) 2015 CMU_16432. All rights reserved.
//

#include "myfit.h"

// Use the Armadillo namespace
using namespace arma;

//-----------------------------------------------------------------
// Function to return the affine warp between 3D points on a plane
//
// <in>
// X = concatenated matrix of 2D projected points in the image (2xN)
// W = concatenated matrix of 3D points on the plane (3XN)
//
// <out>
// A = 2x3 matrix of affine parameters
fmat myfit_affine(fmat &X, fmat &W) {

    // Fill in the answer here.....
    fmat A; return A;
}
//-----------------------------------------------------------------
// Function to project points using the affine transform
//
// <in>
// W = concatenated matrix of 3D points on the plane (3XN)
// A = 2x3 matrix of affine parameters
//
// <out>
// X = concatenated matrix of 2D projected points in the image (2xN)
fmat myproj_affine(fmat &W, fmat &A) {

    // Fill in the answer here.....
    fmat X; return X;
}

//-----------------------------------------------------------------
// Function to return the affine warp between 3D points on a plane
//
// <in>
// X = concatenated matrix of 2D projected points in the image (2xN)
// W = concatenated matrix of 3D points on the plane (3XN)
//
// <out>
// H = 3x3 homography matrix
fmat myfit_homography(fmat &X, fmat &W) {
    
    // Fill in the answer here.....
    fmat H; return H;
}

//-----------------------------------------------------------------
// Function to project points using the affine transform
//
// <in>
// W = concatenated matrix of 3D points on the plane (3XN)
// H = 3x3 homography matrix
//
// <out>
// X = concatenated matrix of 2D projected points in the image (2xN)
fmat myproj_homography(fmat &W, fmat &H) {
    
    // Fill in the answer here.....
    fmat X; return X;
}