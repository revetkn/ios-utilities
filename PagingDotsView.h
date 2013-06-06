//
// PagingDotsView.h
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

@protocol PagingDotsViewDelegate, PagingDotsViewDataSource;

// Alternate implementation of UIControl that allows you to specify dot images
@interface PagingDotsView : UIView

- (CGSize)sizeForPageCount:(NSUInteger)pageCount;

@property (nonatomic, assign) CGFloat gapBetweenDots;
@property (nonatomic, assign) NSUInteger pageCount;
@property (nonatomic, assign) NSUInteger selectedPageNumber;
@property (nonatomic, assign) IBOutlet id<PagingDotsViewDelegate> delegate;
@property (nonatomic, assign) IBOutlet id<PagingDotsViewDataSource> dataSource;

@end

@protocol PagingDotsViewDelegate<NSObject>

- (void)pagingDotsView:(PagingDotsView *)pagingDotsView didSelectPageNumber:(NSUInteger)pageNumber;

@end

@protocol PagingDotsViewDataSource<NSObject>

- (UIImage *)pagingDotsView:(PagingDotsView *)pagingDotsView selectedDotImageForPageNumber:(NSUInteger)pageNumber;
- (UIImage *)pagingDotsView:(PagingDotsView *)pagingDotsView unselectedDotImageForPageNumber:(NSUInteger)pageNumber;

@end