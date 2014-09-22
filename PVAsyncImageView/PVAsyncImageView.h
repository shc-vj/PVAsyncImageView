//
//  PVAsyncImageView.h
//
//  Created by Pedro Vieira on 7/11/12
//  Copyright (c) 2012 Pedro Vieira. ( https://twitter.com/W1TCH_ )
//  All rights reserved.
//

#if defined __MAC_OS_X_VERSION_MIN_REQUIRED
// OS X
#import <Cocoa/Cocoa.h>

typedef NSImage PVImage;

@interface PVAsyncImageView : NSImageView {
    NSURLConnection *imageURLConnection;
    NSMutableData *imageDownloadData;
    PVImage *errorImage;
    
    NSProgressIndicator *spinningWheel;
    
    NSTrackingArea *trackingArea;
}

#else
// iOS version
#import <Foundation/Foundation.h>

#define NSMakeRect CGRectMake

typedef UIImage PVImage;

@interface PVAsyncImageView : UIImageView {
	NSURLConnection *imageURLConnection;
	NSMutableData *imageDownloadData;
	PVImage *errorImage;
	
	UIActivityIndicatorView *spinningWheel;
}

#endif

typedef void (^PVAsyncImageViewDidFinishBlock)(NSData *downloadedData, NSError *error);
typedef void (^PVAsyncImageViewCheckCacheBlock)(NSURL *imageUrl, void (^completion)(PVImage *image) );

@property (nonatomic,strong,readonly) NSURL *url;
@property (nonatomic,assign,readonly) BOOL isLoadingImage;
@property (nonatomic,assign,readonly) BOOL userDidCancel;
@property (nonatomic,assign,readonly) BOOL didFailLoadingImage;

@property (nonatomic, copy) PVAsyncImageViewCheckCacheBlock checkCacheBlock;
@property (nonatomic, copy) PVAsyncImageViewDidFinishBlock didFinishBlock;

#if defined __MAC_OS_X_VERSION_MIN_REQUIRED
@property (nonatomic,readwrite, strong) NSString *toolTipWhileLoading;
@property (nonatomic,readwrite, strong) NSString *toolTipWhenFinished;
@property (nonatomic,readwrite, strong) NSString *toolTipWhenFinishedWithError;
#endif

//Loads an image from the web
- (void)downloadImageFromURL:(NSURL *)url;

//Loads an image from the web and displays a placeholder image on the NSImageView
- (void)downloadImageFromURL:(NSURL *)url withPlaceholderImage:(PVImage *)img;

//Loads an image from the web, displays a placeholder image on the NSImageView and displays another image if there's an error while loading
- (void)downloadImageFromURL:(NSURL *)url withPlaceholderImage:(PVImage *)img andErrorImage:(PVImage *)errorImg;

//Loads an image from the web, displays a placeholder image on the NSImageView with a spinning wheel on top of it and displays another image if there's an error while loading
- (void)downloadImageFromURL:(NSURL *)url withPlaceholderImage:(PVImage *)img errorImage:(PVImage *)errorImg andDisplaySpinningWheel:(BOOL)usesSpinningWheel;

//Stops loading the image
- (void)cancelDownload;

#if defined __MAC_OS_X_VERSION_MIN_REQUIRED

//Method to set all tooltips at once. Just to make things fast and easy
-(void)setToolTipWhileLoading:(NSString *)ttip1 whenFinished:(NSString *)ttip2 andWhenFinishedWithError:(NSString *)ttip3;

//Deletes all the ToolTips
-(void)deleteToolTips;

#endif

@end