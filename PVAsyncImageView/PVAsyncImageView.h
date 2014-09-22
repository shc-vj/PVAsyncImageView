//
//  PVAsyncImageView.h
//
//  Created by Pedro Vieira on 7/11/12
//  Copyright (c) 2012 Pedro Vieira. ( https://twitter.com/W1TCH_ )
//  All rights reserved.
//

#import <Cocoa/Cocoa.h>

#if defined __MAC_OS_X_VERSION_MIN_REQUIRED
// OS X

typedef NSImage PVImage;

@interface PVAsyncImageView : NSImageView {
    NSURLConnection *imageURLConnection;
    NSMutableData *imageDownloadData;
    PVImage *errorImage;
    
    NSProgressIndicator *spinningWheel;
    
    NSTrackingArea *trackingArea;
}

#elif 
// iOS version

typedef UIImage PVImage;

@interface PVAsyncImageView : UIImageView {
	NSURLConnection *imageURLConnection;
	NSMutableData *imageDownloadData;
	PVImage *errorImage;
	
	UIActivityIndicator *spinningWheel;
}

#endif


@property (readonly) BOOL isLoadingImage;
@property (readonly) BOOL userDidCancel;
@property (readonly) BOOL didFailLoadingImage;

#if defined __MAC_OS_X_VERSION_MIN_REQUIRED
@property (readwrite, retain) NSString *toolTipWhileLoading;
@property (readwrite, retain) NSString *toolTipWhenFinished;
@property (readwrite, retain) NSString *toolTipWhenFinishedWithError;
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