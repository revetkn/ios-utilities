//
// PagingScrollView.m
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

#import "PagingScrollView.h"

static NSTimeInterval const PageTransitionAnimationDuration = 0.3;

@interface PagingScrollView()<UIScrollViewDelegate>
@end

@implementation PagingScrollView  {
  NSMutableDictionary *_scrolledViewsByPageNumbers;
  NSMutableDictionary *_scrolledViewControllersByPageNumbers;
  NSUInteger _pageNumber;
  UIViewController *_parentViewController;
  BOOL _recalculating;
  BOOL _dataSourceUsesViews;
  BOOL _dataSourceUsesViewControllers;
  BOOL _busyRotating;
  NSUInteger _preRotationPageNumber;
}

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

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  if(_recalculating || _busyRotating)
    return;
  
  [self loadViewsForCurrentPosition];
  
  CGFloat xContentOffset = scrollView.contentOffset.x;
  
  if(xContentOffset < 0)
    xContentOffset = 0;
  
  NSUInteger pageNumber = roundf(xContentOffset / self.scrollView.bounds.size.width);
  if(pageNumber != _pageNumber) {
    _pageNumber = pageNumber;
    
    if(!_busyRotating)
      [_delegate pagingScrollView:self didMoveToPageNumber:pageNumber];
  }
}

#pragma mark - PagingScrollView

- (void)initialize {
  _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
  _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  _scrollView.pagingEnabled = YES;
  _scrollView.delegate = self;
  _scrollView.showsVerticalScrollIndicator = NO;
  _scrollView.showsHorizontalScrollIndicator = NO;
  _pageNumber = 0;
  _recalculating = NO;
  _busyRotating = NO;
  _preRotationPageNumber = 0;
  _scrolledViewsByPageNumbers = [[NSMutableDictionary alloc] initWithCapacity:5];
  _scrolledViewControllersByPageNumbers = [[NSMutableDictionary alloc] initWithCapacity:5];
  [self addSubview:_scrollView];
}

- (void)reloadData {
  for(NSNumber *pageNumber in _scrolledViewControllersByPageNumbers) {
    UIViewController *viewController = _scrolledViewControllersByPageNumbers[pageNumber];
    
    [viewController willMoveToParentViewController:nil];
    [viewController.view removeFromSuperview];
    [viewController removeFromParentViewController];
  }
  
  for(NSNumber *pageNumber in _scrolledViewsByPageNumbers) {
    UIView *view = _scrolledViewsByPageNumbers[pageNumber];        
    [view removeFromSuperview];
  }
  
  [_scrolledViewControllersByPageNumbers removeAllObjects];  
  [_scrolledViewsByPageNumbers removeAllObjects];  
  
  _parentViewController = [self.dataSource respondsToSelector:@selector(parentViewControllerForPagingScrollView:)] ? [self.dataSource parentViewControllerForPagingScrollView:self] : nil;
  
  [self recalculatePositioning];
  [self setPageNumber:0];
  
  if(!_busyRotating)
    [self.delegate pagingScrollView:self didMoveToPageNumber:self.pageNumber];
}

- (void)loadViewsForCurrentPosition {
  [self loadViewsForXContentOffset:self.scrollView.contentOffset.x];
}

- (void)loadViewsForXContentOffset:(CGFloat)xContentOffset {
  NSUInteger numberOfPages = [self.dataSource numberOfPagesInPagingScrollView:self];
  
  if(numberOfPages == 0)
    return;
  
  CGFloat pageWidth = self.scrollView.width;
    
  if(xContentOffset < 0)
    xContentOffset = 0;
  
  NSUInteger centerPageNumber = floorf(xContentOffset / pageWidth);
  NSInteger leftPageNumber = centerPageNumber - 1;
  NSUInteger rightPageNumber = centerPageNumber + 1;
  
  if(leftPageNumber < 0)
    leftPageNumber = 0;
  
  if(rightPageNumber >= numberOfPages)
    rightPageNumber = centerPageNumber;

  UIView *leftPageView = _scrolledViewsByPageNumbers[@(leftPageNumber)];
  UIView *centerPageView = _scrolledViewsByPageNumbers[@(centerPageNumber)];
  UIView *rightPageView = _scrolledViewsByPageNumbers[@(rightPageNumber)];
  
  if(!leftPageView && leftPageNumber != centerPageNumber)
    [self loadPageView:leftPageView forPageWidth:pageWidth atPageNumber:leftPageNumber withReusablePageNumber:rightPageNumber + 3];
  
  if(!centerPageView)
    [self loadPageView:centerPageView forPageWidth:pageWidth atPageNumber:centerPageNumber withReusablePageNumber:rightPageNumber + 2];
  
  if(!rightPageView && centerPageNumber != rightPageNumber)
    [self loadPageView:rightPageView forPageWidth:pageWidth atPageNumber:rightPageNumber withReusablePageNumber:centerPageNumber - 2];
}

- (void)loadPageView:(UIView *)pageView forPageWidth:(CGFloat)pageWidth atPageNumber:(NSUInteger)pageNumber withReusablePageNumber:(NSUInteger)reusablePageNumber {
  NSNumber *reusableViewKey = @(reusablePageNumber);
  UIView *reusableView = _scrolledViewsByPageNumbers[reusableViewKey];
  UIViewController *reusableViewController = _scrolledViewControllersByPageNumbers[reusableViewKey];
  
  if(reusableView) {        
    if(reusableViewController) {
      [reusableViewController willMoveToParentViewController:nil];
      [reusableViewController.view removeFromSuperview];
      [reusableViewController removeFromParentViewController];
      [_scrolledViewControllersByPageNumbers removeObjectForKey:reusableViewKey];
    } else {
      [reusableView removeFromSuperview];
    }

    [_scrolledViewsByPageNumbers removeObjectForKey:reusableViewKey];
  }
  
  UIViewController *pageViewController = nil;
  
  if(_dataSourceUsesViews) {
    pageView = [self.dataSource pagingScrollView:self viewForPageNumber:pageNumber reusableView:reusableView];
  } else {
    pageViewController = [self.dataSource pagingScrollView:self viewControllerForPageNumber:pageNumber reusableViewController:reusableViewController];
    [pageViewController willMoveToParentViewController:_parentViewController];    
    [_parentViewController addChildViewController:pageViewController];
    _scrolledViewControllersByPageNumbers[@(pageNumber)] = pageViewController;
    pageView = pageViewController.view;
  }
  
  [self.scrollView addSubview:pageView];
  
  pageView.frame = CGRectMake(pageNumber * pageWidth, 0, pageWidth, self.scrollView.height);
  
  if(pageViewController)
    [pageViewController didMoveToParentViewController:_parentViewController];
  
  _scrolledViewsByPageNumbers[@(pageNumber)] = pageView;
}

- (void)setPageNumber:(NSUInteger)pageNumber {
  [self setPageNumber:pageNumber animated:NO completionBlock:^{}];
}

- (void)setPageNumber:(NSUInteger)pageNumber animated:(BOOL)animated completionBlock:(void (^)(void))completionBlock {
  NSUInteger numberOfPages = [self.dataSource numberOfPagesInPagingScrollView:self];
  
  // Can't go past the last page
  if(pageNumber > numberOfPages - 1)
    pageNumber = numberOfPages - 1;
  
  BOOL notifyDelegate = _pageNumber != pageNumber && !_busyRotating;
  CGFloat xContentOffset = pageNumber * self.scrollView.width;
    
  _pageNumber = pageNumber;

  [self loadViewsForXContentOffset:xContentOffset];
  
  void (^scrollToContentOffsetBlock)() = ^{
    [self.scrollView setContentOffset:CGPointMake(xContentOffset, 0) animated:NO];
  };
  
  if(animated) {
    [UIView animateWithDuration:PageTransitionAnimationDuration
                     animations:^{
                       scrollToContentOffsetBlock();
                     }
                     completion:^(BOOL finished) {
                       completionBlock();
                     }];
  } else {
    scrollToContentOffsetBlock();
    completionBlock();
  }
  
  if(notifyDelegate)
    [self.delegate pagingScrollView:self didMoveToPageNumber:pageNumber];
}

- (UIView *)viewForPageNumber:(NSUInteger)pageNumber {
  return _scrolledViewsByPageNumbers[@(pageNumber)];
}

- (UIViewController *)viewControllerForPageNumber:(NSUInteger)pageNumber {
  if(_dataSourceUsesViews)
    return nil;
  
  return _scrolledViewControllersByPageNumbers[@(pageNumber)];
}

- (void)recalculatePositioning {
  _recalculating = YES;
  
  self.scrollView.contentSize = CGSizeMake([self.dataSource numberOfPagesInPagingScrollView:self] * self.scrollView.width, self.scrollView.height);
  
  //NSUInteger pageNumber = self.pageNumber;
  
  for(NSNumber *scrolledViewPageNumber in _scrolledViewsByPageNumbers) {
    UIView *scrolledView = _scrolledViewsByPageNumbers[scrolledViewPageNumber];
    
    int scrolledViewPageNumberAsInt = [scrolledViewPageNumber intValue];
    
    //if(scrolledViewPageNumberAsInt != pageNumber)
    //  scrolledView.hidden = YES;
    
    scrolledView.frame = CGRectMake(scrolledViewPageNumberAsInt * self.scrollView.width, 0, self.scrollView.width, self.scrollView.height);
  }
  
  _recalculating = NO;
}

- (void)setDataSource:(id<PagingScrollViewDataSource>)dataSource {
  if(_dataSource == dataSource)
    return;
  
  BOOL dataSourceUsesViews = [dataSource respondsToSelector:@selector(pagingScrollView:viewForPageNumber:reusableView:)];
  BOOL dataSourceUsesViewControllers = [dataSource respondsToSelector:@selector(pagingScrollView:viewControllerForPageNumber:reusableViewController:)];
  
  if(dataSource) {
    if(dataSourceUsesViews && dataSourceUsesViewControllers)
      @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                     reason:@"You cannot implement both pagingScrollView:viewForPageNumber:reusableView: "
              "and pagingScrollView:viewControllerForPageNumber: - you must pick one."
                                   userInfo:nil];
    
    if(!dataSourceUsesViews && !dataSourceUsesViewControllers)
      @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                     reason:@"You must implement either pagingScrollView:viewForPageNumber:reusableView: "
              "or pagingScrollView:viewControllerForPageNumber:."
                                   userInfo:nil];
    
    if(dataSourceUsesViewControllers && ![dataSource respondsToSelector:@selector(parentViewControllerForPagingScrollView:)])
      @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                     reason:@"You must implement parentViewControllerForPagingScrollView:."
                                   userInfo:nil];
  }
  
  _dataSourceUsesViews = dataSourceUsesViews;
  _dataSourceUsesViewControllers = dataSourceUsesViewControllers;
  _dataSource = dataSource;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
  _busyRotating = YES;
  
  // Hide the left and right offscreen pages so they don't bleed into the rotation animation.
  // These are shown again post-rotation in didRotateFromInterfaceOrientation:
  NSUInteger pageNumber = self.pageNumber;
  [self viewForPageNumber:pageNumber - 1].hidden = YES;
  [self viewForPageNumber:pageNumber + 1].hidden = YES;
  
  _preRotationPageNumber = pageNumber;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  // The scrolling grid needs to reset its offset according to the new rotated dimensions.
  // If we don't do this, rotation will land you on part of a different page.
  [self recalculatePositioning];

  // Make sure the scroll view is on the correct page now that dimensions have changed
  self.pageNumber = _preRotationPageNumber;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
  // Restore the page number and show the pages to the left and right of the current page.
  // Those pages were hidden prior to rotation so they would not bleed into the animation.
  NSUInteger pageNumber = self.pageNumber;
  [self viewForPageNumber:pageNumber - 1].hidden = NO;
  [self viewForPageNumber:pageNumber + 1].hidden = NO;

  _busyRotating = NO;
}

- (NSArray *)views {
  return _dataSourceUsesViews ? _scrolledViewsByPageNumbers.allValues : nil;
}

- (NSArray *)viewControllers {
  return _dataSourceUsesViews ? nil : _scrolledViewControllersByPageNumbers.allValues;
}

@end