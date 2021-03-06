//
//  FileUtils.m
//  RNOpencv3
//
//  Created by Adam G Freeman on 01/15/19.
//  Copyright © 2019 Adam G Freeman. All rights reserved.
//

#import "MatManager.h"
#import <Foundation/Foundation.h>

// simple opaque object that wraps a cv::Mat or other OpenCV object or other type ...
@implementation MatWrapper
@end

// Ostensibly a Mat is an all-purpose OpenCV opaque object referenced by an index in javascript
// For react-native purposes cv::Mat is an opaque type that is contained in an NSMutableArray and
// accessed by indexing into the array.  Eventually it has to be converted into an image to be useable anyways.
// MatManager: singleton class for retaining the mats for image processing operations
@implementation MatManager

+(id)sharedMgr {
    static MatManager *sharedMatManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMatManager = [[self alloc] init];
    });
    return sharedMatManager;
}

-(id)init {
    if (self = [super init]) {
        self.mats = [[NSMutableArray alloc] init];
    }
    return self;
}

-(int)createEmptyMat {
    Mat emptyMat;
    return ([self addMat:emptyMat]);
}

-(int)createMat:(int)rows cols:(int)cols cvtype:(int)cvtype scalarVal:(NSDictionary*)cvscalar {
    //int matIndex = (int)self.mats.count;
    Mat matToAdd;
    NSArray *scalarVal = [cvscalar objectForKey:@"vals"];
    if (scalarVal != nil) {
        double *demolitionman = new double[4];
        for (int i=0;i < 4;i++) {
            NSNumber *blade = [scalarVal objectAtIndex:i];
            demolitionman[i] = [blade doubleValue];
        }
        Scalar risingsun = {demolitionman[0],demolitionman[1],demolitionman[2],demolitionman[3]};
        Mat junglefever(rows, cols, cvtype, risingsun);
        matToAdd = junglefever;
    }
    else {
        Mat newjackcity(rows, cols, cvtype);
        matToAdd = newjackcity;
    }
    return ([self addMat:matToAdd]);
}

-(int)createMatOfInt:(int)lomatval himatval:(int)himatval {
    if (himatval == -1) {
        himatval = lomatval + 1;
    }
    int matIndex = (int)self.mats.count;
    std::vector<int> vec;
    if (lomatval == himatval) {
        vec.push_back(lomatval);
    }
    else {
        for (int i = lomatval;i < himatval;i++) {
            vec.push_back(i);
        }
    }
    Mat moneytrain(vec);
    [self addMat:moneytrain];
    return matIndex;
}

-(int)createMatOfFloat:(float)lomatval himatval:(float)himatval {
    int matIndex = (int)self.mats.count;
    std::vector<float> vec;
    if (lomatval == himatval) {
        vec.push_back(lomatval);
    }
    else {
        for (int i = lomatval;i < himatval;i++) {
            vec.push_back((float)i);
        }
    }
    Mat bladeII(vec);
    [self addMat:bladeII];
    return matIndex;
}

-(int)addMat:(Mat)matToAdd {
    int matIndex = (int)self.mats.count;
    MatWrapper *MW = [[MatWrapper alloc] init];
    MW.myMat = matToAdd.clone();
    [self.mats addObject:MW];
    return matIndex;
}

-(Mat)matAtIndex:(int)matIndex {
    MatWrapper *MW = (MatWrapper*)self.mats[matIndex];
    return MW.myMat;
}

-(void)setMat:(int)matIndex matToSet:(Mat)matToSet {
    if (matIndex >= 0 && matIndex < self.mats.count) {
        MatWrapper *MW = (MatWrapper*)self.mats[matIndex];
        MW.myMat = matToSet;
    }
}

-(NSArray*)getMatData:(int)matIndex rownum:(int)rownum colnum:(int)colnum {
    MatWrapper *MW = (MatWrapper*)self.mats[matIndex];
    Mat mat = MW.myMat;
    // TODO: check mat type to return different types of data
    NSMutableArray *retArr = [[NSMutableArray alloc] initWithCapacity:(mat.rows*mat.cols)];
    for (int j=0;j < mat.rows;j++) {
        for (int i=0;i < mat.cols;i++) {
            float dFloat = mat.at<float>(i,j);
            NSNumber *num = [NSNumber numberWithFloat:dFloat];
            [retArr addObject:num];
        }
    }
    return retArr;
}

-(void)setToScalar:(int)matIndex cvscalar:(NSDictionary*)cvscalar {
    MatWrapper *MW = (MatWrapper*)self.mats[matIndex];
    Mat mat = MW.myMat;
    NSArray *scalarVal = [cvscalar objectForKey:@"vals"];
    double *scalarDubs = new double[4];
    for (int i=0;i < 4;i++) {
        NSNumber *Vnum = [scalarVal objectAtIndex:i];
        scalarDubs[i] = [Vnum doubleValue];
    }

    Scalar dScalar = {scalarDubs[0],scalarDubs[1],scalarDubs[2],scalarDubs[3]};
    mat = dScalar;
    [self setMat:matIndex matToSet:mat];
}

-(void)putData:(int)matIndex rownum:(int)rownum colnum:(int)colnum data:(NSArray*)data {
    MatWrapper *MW = (MatWrapper*)self.mats[matIndex];
    Mat mat = MW.myMat;
    
    // TODO: check type of mat to put different data types ...
    float* dataVals = new float[data.count];
    for (int i=0;i < data.count;i++) {
        NSNumber *dataVal = [data objectAtIndex:i];
        dataVals[i] = [dataVal floatValue];
    }
    mat.at<float>(rownum, 0) = dataVals[0];
    mat.at<float>(rownum, 1) = dataVals[1];
    mat.at<float>(rownum, 2) = dataVals[2];
    mat.at<float>(rownum, 3) = dataVals[3];
    
    [self setMat:matIndex matToSet:mat];
}

-(void)transposeMat:(int)matIndex {
    MatWrapper *MW = (MatWrapper*)self.mats[matIndex];
    Mat mat = MW.myMat;

    mat.t();
    [self setMat:matIndex matToSet:mat];
}

-(void)deleteMatAtIndex:(int)matIndex {
    MatWrapper *MW = (MatWrapper*)self.mats[matIndex];
    MW.myMat.release();
    [self.mats removeObjectAtIndex:matIndex];
}

-(void)deleteMats {
    for (int i=0;i < self.mats.count;i++) {
        MatWrapper *MW = (MatWrapper*)self.mats[i];
        MW.myMat.release();
    }
    [self.mats removeAllObjects];
}

-(void)dealloc {
    [self.mats removeAllObjects];
    self.mats = nil;
}

@end
