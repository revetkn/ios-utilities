//
// FlowLayoutView.m
//
// Created by Mark Allen on 6/5/13.
// Copyright (c) 2013 Transmogrify LLC. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "FlowLayoutView.h"

static CGFloat const DefaultHorizontalSpacing = 8;
static CGFloat const DefaultVerticalSpacing = 8;
static BOOL const DefaultResizesLargeSubviews = YES;

@implementation FlowLayoutView

#pragma mark - NSObject

- (id)initWithFrame:(CGRect)frame {
  if((self = [super initWithFrame:frame]))
    [self initialize];
  
  return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
  if((self = [super initWithCoder:aDecoder]))
    [self initialize];
  
  return self;
}

#pragma mark - UIView

- (void)addSubview:(UIView *)view {  
  if(self.resizesLargeSubviews) {
    CGFloat viewWidth = self.width;
    
    if(view.width > viewWidth)
      view.width = viewWidth;
  }
  
  [super addSubview:view];
}

- (void)layoutSubviews {
  CGFloat subviewTop = 0;
  CGFloat subviewLeft = 0;
  CGFloat horizontalSpacing = self.horizontalSpacing;
  CGFloat verticalSpacing = self.verticalSpacing;
  CGFloat viewWidth = self.width;
  CGFloat heightOfTallestSubviewInRow = 0;
  
  for(UIView *subview in self.subviews) {
    CGFloat subviewHeight = subview.height;
    CGFloat subviewWidth = subview.width;
    CGFloat remainingWidthAvailableInRow = viewWidth - subviewLeft;
    
    if(subviewLeft == 0 && subviewWidth >= viewWidth) {
      // Leftmost element that's wider than the view gets its own row
      subview.frame = CGRectMake(subviewLeft, subviewTop, subviewWidth, subviewHeight);
      subviewTop += subviewHeight + verticalSpacing;
      heightOfTallestSubviewInRow = 0;
    } else if (remainingWidthAvailableInRow < subviewWidth) {
      // This isn't the leftmost view, but it's too big for the remaining space and needs to wrap
      subviewTop += heightOfTallestSubviewInRow + verticalSpacing;      
      subview.frame = CGRectMake(0, subviewTop, subviewWidth, subviewHeight);
      subviewLeft = subviewWidth + horizontalSpacing;
      heightOfTallestSubviewInRow = subviewHeight;
    } else {
      // Just add to the current line
      subview.frame = CGRectMake(subviewLeft, subviewTop, subviewWidth, subviewHeight);      
      subviewLeft += subviewWidth + horizontalSpacing;
      
      if(subviewHeight > heightOfTallestSubviewInRow)
        heightOfTallestSubviewInRow = subviewHeight;
    }
  }
}

- (CGSize)sizeThatFits:(CGSize)size {
  CGFloat subviewTop = 0;
  CGFloat subviewLeft = 0;
  CGFloat horizontalSpacing = self.horizontalSpacing;
  CGFloat verticalSpacing = self.verticalSpacing;
  CGFloat viewWidth = self.width;
  CGFloat heightOfTallestSubviewInRow = 0;
  CGFloat preferredHeight = 0;
  
  for(UIView *subview in self.subviews) {
    CGFloat subviewHeight = subview.height;
    CGFloat subviewWidth = subview.width;
    CGFloat remainingWidthAvailableInRow = viewWidth - subviewLeft;
    
    if(subviewLeft == 0 && subviewWidth >= viewWidth) {
      // Leftmost element that's wider than the view gets its own row
      preferredHeight = subviewTop + subviewHeight;
      subviewTop += subviewHeight + verticalSpacing;
      heightOfTallestSubviewInRow = 0;
    } else if (remainingWidthAvailableInRow < subviewWidth) {
      // This isn't the leftmost view, but it's too big for the remaining space and needs to wrap
      subviewTop += heightOfTallestSubviewInRow + verticalSpacing;
      subviewLeft = subviewWidth + horizontalSpacing;
      heightOfTallestSubviewInRow = subviewHeight;
      preferredHeight = subviewTop + subviewHeight;            
    } else {
      // Just add to the current line
      subviewLeft += subviewWidth + horizontalSpacing;
      
      if(subviewHeight > heightOfTallestSubviewInRow)
        heightOfTallestSubviewInRow = subviewHeight;
      
      preferredHeight = subviewTop + heightOfTallestSubviewInRow;
    }
  }
  
  return CGSizeMake(size.width, preferredHeight);
}

#pragma mark - FlowLayoutView

- (void)initialize {
  self.horizontalSpacing = DefaultHorizontalSpacing;
  self.verticalSpacing = DefaultVerticalSpacing;
  self.resizesLargeSubviews = DefaultResizesLargeSubviews;
}

- (void)setHorizontalSpacing:(CGFloat)horizontalSpacing {
  _horizontalSpacing = horizontalSpacing;
  [self setNeedsLayout];
}

- (void)setVerticalSpacing:(CGFloat)verticalSpacing {
  _verticalSpacing = verticalSpacing;
  [self setNeedsLayout];
}

- (void)setResizesLargeSubviews:(BOOL)resizesLargeSubviews {
  _resizesLargeSubviews = resizesLargeSubviews;
  
  if(resizesLargeSubviews) {
    CGFloat viewWidth = self.width;
    
    for(UIView *subview in self.subviews)
      if(subview.width > viewWidth)
        subview.width = viewWidth;
  }
  
  [self setNeedsLayout];  
}

@end