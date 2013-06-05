//
// GridView.h
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

// Grid layout view - takes a list of views and renders them in a grid.
// All views must be the same size.
@interface GridView : UIView

// How tall must this view be to comfortably arrange its contents in the given width?
- (CGFloat)heightThatFitsWidth:(CGFloat)width;

// Minimum horizontal gap between grid elements.  Defaults to 8 points.
@property (nonatomic) CGFloat minimumHorizontalGridPadding;

// Vertical gap between grid elements.  Defaults to 8 points.
@property (nonatomic) CGFloat verticalGridPadding;

// The views to be displayed in a grid.
@property (nonatomic, retain) NSArray *gridViews;

@end