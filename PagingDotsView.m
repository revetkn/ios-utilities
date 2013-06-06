//
// PagingDotsView.m
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

#import "PagingDotsView.h"

static CGFloat const DefaultGapBetweenDots = 12;

@implementation PagingDotsView

#pragma mark - NSObject

- (id)initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame]))
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
  CGFloat subviewWidths = 0;
  
  for(UIView *subview in self.subviews)
    subviewWidths += subview.width;
  
  CGFloat leftOffset = floorf((self.width - ((self.subviews.count - 1) * self.gapBetweenDots) - subviewWidths) / 2);
  CGFloat height = self.height;
  
  for(UIView *subview in self.subviews) {
    subview.frame = CGRectMake(leftOffset, floorf((height - subview.height) / 2), subview.width, subview.height);
    leftOffset += subview.width + self.gapBetweenDots;
  }
}

- (CGSize)sizeThatFits:(CGSize)size {
  return [self sizeForPageCount:self.pageCount];
}

#pragma mark - PagingDotsView

- (void)initialize {
  _gapBetweenDots = DefaultGapBetweenDots;
}

- (CGSize)sizeForPageCount:(NSUInteger)pageCount {
  CGFloat maximumWidth = 0;
  CGFloat maximumHeight = 0;
  
  for(NSUInteger i = 0; i < pageCount; ++i) {
    UIImage *selectedDotImage = [self.dataSource pagingDotsView:self selectedDotImageForPageNumber:i];
    UIImage *unselectedDotImage = [self.dataSource pagingDotsView:self unselectedDotImageForPageNumber:i];
    
    if(selectedDotImage.size.width > maximumWidth)
      maximumWidth = selectedDotImage.size.width;
    if(selectedDotImage.size.height > maximumHeight)
      maximumHeight = selectedDotImage.size.height;
    
    if(unselectedDotImage.size.width > maximumWidth)
      maximumWidth = unselectedDotImage.size.width;
    if(unselectedDotImage.size.height > maximumHeight)
      maximumHeight = unselectedDotImage.size.height;
  }
  
  CGFloat widthOfDots = maximumWidth * pageCount;
  CGFloat widthOfGapsBetweenDots = pageCount == 0 ? 0 : self.gapBetweenDots * (pageCount - 1);
  
  return CGSizeMake(widthOfDots + widthOfGapsBetweenDots, maximumHeight);
}

- (NSUInteger)selectedPageNumber {
  NSUInteger selectedPageNumber = 0;
  NSUInteger i = 0;
  
  for(UIControl *subview in self.subviews) {
    if(subview.selected)
      return i;
    
    ++i;
  }
  
  return selectedPageNumber;
}

- (void)setSelectedPageNumber:(NSUInteger)selectedPageNumber {
  NSUInteger i = 0;
  
  for(UIControl *subview in self.subviews) {
    subview.selected = i == selectedPageNumber;
    ++i;
  }
}

- (NSUInteger)pageCount {
  return self.subviews.count;
}

- (void)setPageCount:(NSUInteger)pageCount {
  if(self.pageCount == pageCount)
    return;
  
  [self removeAllSubviews];
  
  for(NSUInteger i = 0; i < pageCount; i++) {
    UIImage *selectedDotImage = [self.dataSource pagingDotsView:self selectedDotImageForPageNumber:i];
    UIImage *unselectedDotImage = [self.dataSource pagingDotsView:self unselectedDotImageForPageNumber:i];
    
    UIButton *dotButton = [UIButton buttonWithType:UIButtonTypeCustom];
    dotButton.frame = CGRectMake(0, 0, unselectedDotImage.size.width, unselectedDotImage.size.height);
    dotButton.tag = i;
    [dotButton setImage:selectedDotImage forState:UIControlStateSelected];
    [dotButton setImage:selectedDotImage forState:UIControlStateHighlighted];
    [dotButton setImage:unselectedDotImage forState:UIControlStateNormal];
    [dotButton addTarget:self action:@selector(didTouchUpInsideDotButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:dotButton];
  }
  
  [self setNeedsLayout];
}

- (void)setGapBetweenDots:(CGFloat)gapBetweenDots {
  if(gapBetweenDots < 0)
    gapBetweenDots = DefaultGapBetweenDots;
  
  if(gapBetweenDots == self.gapBetweenDots)
    return;
  
  _gapBetweenDots = gapBetweenDots;
  [self setNeedsLayout];
}

- (void)didTouchUpInsideDotButton:(UIButton *)dotButton {
  [self.delegate pagingDotsView:self didSelectPageNumber:dotButton.tag];
}

@end