//
// GridView.m
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

#import "GridView.h"

static CGFloat const DefaultGridPadding = 8;

@implementation GridView

@synthesize minimumHorizontalGridPadding = _minimumHorizontalGridPadding;
@synthesize verticalGridPadding = _verticalGridPadding;
@synthesize gridViews = _gridViews;

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

- (void)layoutSubviews {
  [super layoutSubviews];
  
  UIView *firstViewForGrid = self.gridViews.count == 0 ? nil : self.gridViews[0];
  
  // Figure out the number of views to display per row...
  NSUInteger numberOfViewsPerRow = firstViewForGrid ? floorf(self.width / firstViewForGrid.width) : 0;
  
  // ...and take padding into account, forcing an absolute minimum.
  if(firstViewForGrid.width * numberOfViewsPerRow + (numberOfViewsPerRow + 1) * self.minimumHorizontalGridPadding > self.width)
    --numberOfViewsPerRow;
  
  CGFloat rowPadding = floorf((self.width - numberOfViewsPerRow * firstViewForGrid.width) / (numberOfViewsPerRow + 1));
  
  // Figure out where to start from the top.
  // There is probably a nicer way to do this, no time to work on that now.
  CGFloat rowHeight = 0;
  
  for(;;) {
    CGFloat newRowHeight = rowHeight + firstViewForGrid.height;
    
    if(newRowHeight >= self.height)
      break;
    
    rowHeight = newRowHeight;
    newRowHeight = rowHeight + self.verticalGridPadding;
    
    if(newRowHeight + firstViewForGrid.height >= self.height)
      break;
    
    rowHeight = newRowHeight;
  }
    
  CGFloat topOffset = floorf((self.height - rowHeight) / 2);
  
  // Figure out where to start on the left.
  // There is probably a nicer way to do this, no time to work on that now.
  CGFloat rowWidth = 0;
  
  for(;;) {
    CGFloat newRowWidth = rowWidth + firstViewForGrid.width;
    
    if(newRowWidth >= self.width)
      break;
    
    rowWidth = newRowWidth;
    newRowWidth = rowWidth + rowPadding;
    
    if(newRowWidth + firstViewForGrid.width >= self.width)
      break;
    
    rowWidth = newRowWidth;
  }
  
  CGFloat leftOffset = floorf((self.width - rowWidth) / 2);
  
  NSInteger numberOfViewsInCurrentRow = 0;
  
  //LOG(@"Grid will be %dx%d (%.0fx%.0f views) with row padding %.0f and column padding %.0f", numberOfViewsPerRow, numberOfViewsPerColumn, firstViewForGrid.width, firstViewForGrid.height, rowPadding, columnPadding);
  
  for(UIView *view in self.gridViews) {
    CGRect currentViewFrame = CGRectMake(leftOffset, topOffset, view.width, view.height);
    view.frame = currentViewFrame;
    
    if(view.superview != self)
      [self addSubview:view];
    
    if(++numberOfViewsInCurrentRow == numberOfViewsPerRow) {
      numberOfViewsInCurrentRow = 0;
      leftOffset = rowPadding;
      topOffset += view.height + self.verticalGridPadding;
    } else {
      leftOffset += view.width + rowPadding;
    }
  }
}

#pragma mark - GridView

- (void)initialize {
  self.minimumHorizontalGridPadding = DefaultGridPadding;
  self.verticalGridPadding = DefaultGridPadding;
}

- (CGFloat)heightThatFitsWidth:(CGFloat)width {
  // Trivial case shortcut
  if(self.gridViews.count == 0)
    return 0;
  
  UIView *firstViewForGrid = self.gridViews[0];
  
  // Figure out the number of views to display per row...
  NSUInteger numberOfViewsPerRow = firstViewForGrid ? floorf(width / firstViewForGrid.width) : 0;
  
  // ...and take padding into account, forcing an absolute minimum.
  if(firstViewForGrid.width * numberOfViewsPerRow + (numberOfViewsPerRow + 1) * self.minimumHorizontalGridPadding > width)
    --numberOfViewsPerRow;
  
  NSUInteger numberOfRows = ceilf((CGFloat)self.gridViews.count / (CGFloat)numberOfViewsPerRow);
  CGFloat height = (numberOfRows * firstViewForGrid.height) + (numberOfRows * self.verticalGridPadding) + self.verticalGridPadding;
  
  return height;
}

- (void)setGridViews:(NSArray *)gridViews {
  if(_gridViews == gridViews)
    return;
  
  [self removeAllSubviews];
  
  _gridViews = gridViews;
  
  [self setNeedsLayout];
}

- (void)setMinimumHorizontalGridPadding:(CGFloat)minimumHorizontalGridPadding {
  if(minimumHorizontalGridPadding == self.minimumHorizontalGridPadding)
    return;
  
  _minimumHorizontalGridPadding = minimumHorizontalGridPadding;
  [self setNeedsLayout];
}

- (void)setVerticalGridPadding:(CGFloat)verticalGridPadding {
  if(verticalGridPadding == self.verticalGridPadding)
    return;
  
  _verticalGridPadding = verticalGridPadding;
  [self setNeedsLayout];
}

@end