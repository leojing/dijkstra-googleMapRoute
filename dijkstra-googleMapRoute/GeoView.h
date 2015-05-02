//
//  GeoView.h
//  KeyAnimationTest
//
//  Created by luojing on 14/11/21.
//  Copyright (c) 2014年 luojing. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GeoView;

@protocol GeoViewDelgate <NSObject>

@optional
- (void)drawRectByCustom:(GeoView *)geoView;

@end

@interface GeoView : UIView

@property (nonatomic, weak) id<GeoViewDelgate> delegate;

@end
