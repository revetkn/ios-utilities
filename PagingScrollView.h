//
// PagingScrollView.h
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

@protocol PagingScrollViewDelegate;
@protocol PagingScrollViewDataSource;

// View that supports horizontal paging of UIViews or UIViewControllers.
// Discards offscreen UIViews/UIViewControllers to keep memory usage at a minimum.
//
// The end result is an "infinitely"-pageable display.
//
// To support rotation, this view must be contained in a UIViewController and that
// controller must call
//
// -willRotateToInterfaceOrientation:
// -willAnimateRotationToInterfaceOrientation:
// -didRotateFromInterfaceOrientation:
//
// at appropriate times.
//
// Using UIScrollView on iOS 5.1 will cause leaks (Apple's bug).
// See https://devforums.apple.com/message/630695
//
// Each leak is 48 bytes and happens maybe every 2 pages scrolled.
// So this is not a big deal, user would have to scroll an awful lot to see problems.
@interface PagingScrollView : UIView

// Forces a requery of the dataSource and delegate.
// You must call this at least once, otherwise this PagingScrollView will be empty.
- (void)reloadData;

// Makes the specified page visible, with an optional transition animation.
- (void)setPageNumber:(NSUInteger)pageNumber animated:(BOOL)animated completionBlock:(void (^)(void))completionBlock;

// The in-memory view for the given page number.
// Returns nil if not managing UIViews or if no view is available for the specified page.
- (UIView *)viewForPageNumber:(NSUInteger)pageNumber;

// The in-memory view controller for the given page number.
// Returns nil if not managing UIViewControllers or if no view controller is available for the specified page.
- (UIViewController *)viewControllerForPageNumber:(NSUInteger)pageNumber;

// Handling rotation - if you rotate, you must call each of these at the correct time in your UIViewController.
// If you forget to call one, behavior is undefined.
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation;
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation;

// Current page number
@property (nonatomic) NSUInteger pageNumber;

// All in-memory views being paged over
@property (nonatomic, readonly) NSArray *views;

// All in-memory view controllers being paged over
@property (nonatomic, readonly) NSArray *viewControllers;

@property (nonatomic, readonly) UIScrollView *scrollView;

@property (nonatomic, weak) IBOutlet id<PagingScrollViewDelegate> delegate;
@property (nonatomic, weak) IBOutlet id<PagingScrollViewDataSource> dataSource;

@end

@protocol PagingScrollViewDelegate<NSObject>

- (void)pagingScrollView:(PagingScrollView *)pagingScrollView didMoveToPageNumber:(NSUInteger)pageNumber;

@end

@protocol PagingScrollViewDataSource<NSObject>

- (NSUInteger)numberOfPagesInPagingScrollView:(PagingScrollView *)pagingScrollView;

@optional

// One of these two must be implemented, but not both.
// You can page over either regular views or view controllers.

// This variant is used if you're paging over views.
- (UIView *)pagingScrollView:(PagingScrollView *)pagingScrollView viewForPageNumber:(NSUInteger)pageNumber reusableView:(UIView *)reusableView;

// This variant is used if you're paging over view controllers.  Both methods must be implemented.
- (UIViewController *)pagingScrollView:(PagingScrollView *)pagingScrollView viewControllerForPageNumber:(NSUInteger)pageNumber reusableViewController:(UIViewController *)reusableViewController;
- (UIViewController *)parentViewControllerForPagingScrollView:(PagingScrollView *)pagingScrollView;

@end