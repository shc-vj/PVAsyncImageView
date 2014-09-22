//
//  PVAsyncImageView.m
//
//  Created by Pedro Vieira on 7/11/12
//  Copyright (c) 2012 Pedro Vieira. ( https://twitter.com/W1TCH_ )
//  All rights reserved.
//

#import "PVAsyncImageView.h"

@interface PVAsyncImageView ()

@property (readwrite) NSURL *url;
@property (readwrite) BOOL  isLoadingImage;
@property (readwrite) BOOL  userDidCancel;
@property (readwrite) BOOL  didFailLoadingImage;

@end


@implementation PVAsyncImageView

- (void)downloadImageFromURL:(NSURL *)url{
    [self downloadImageFromURL:url withPlaceholderImage:nil errorImage:nil andDisplaySpinningWheel:NO];
}

- (void)downloadImageFromURL:(NSURL *)url withPlaceholderImage:(PVImage *)img{
    [self downloadImageFromURL:url withPlaceholderImage:img errorImage:nil andDisplaySpinningWheel:NO];
}

- (void)downloadImageFromURL:(NSURL *)url withPlaceholderImage:(PVImage *)img andErrorImage:(PVImage *)errorImg{
    [self downloadImageFromURL:url withPlaceholderImage:img errorImage:errorImg andDisplaySpinningWheel:NO];
}

- (void)downloadImageFromURL:(NSURL *)url withPlaceholderImage:(PVImage *)img errorImage:(PVImage *)errorImg andDisplaySpinningWheel:(BOOL)usesSpinningWheel{
    [self cancelDownload];
    
	self.url = url;
	
	void (^completion)(PVImage *image) = ^(PVImage *image) {
		
		dispatch_async(dispatch_get_main_queue(), ^{

			if( image ) {
				self.image = image;
				return;
			}
			
			self.isLoadingImage = YES;
			self.didFailLoadingImage = NO;
			self.userDidCancel = NO;
			
			self.image = img;
			self->errorImage = errorImg;
			self->imageDownloadData = [NSMutableData data];
			
			NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:url] delegate:self];
			self->imageURLConnection = conn;
			
			if(usesSpinningWheel){
				
		#ifdef __MAC_OS_X_VERSION_MIN_REQUIRED
				spinningWheel = [[NSProgressIndicator alloc] init];
				[spinningWheel setStyle:NSProgressIndicatorSpinningStyle];
				[spinningWheel setDisplayedWhenStopped:NO];

				[self addSubview:spinningWheel];

				[spinningWheel startAnimation:self];

		#else
				self->spinningWheel = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
				[self->spinningWheel setHidesWhenStopped:YES];
				
				[self addSubview:self->spinningWheel];

				[self->spinningWheel startAnimating];

		#endif
				
				//If the NSImageView size is 64+ height and 64+ width display Spinning Wheel 32x32
				if (self.frame.size.height >= 64 && self.frame.size.width >= 64){
					
					[self->spinningWheel setFrame: NSMakeRect(self.frame.size.width * 0.5 - 16, self.frame.size.height * 0.5 - 16, 32, 32)];
		#ifdef __MAC_OS_X_VERSION_MIN_REQUIRED
					[spinningWheel setControlSize:NSRegularControlSize];
		#endif
					
				//If not, and size between 63 and 16 height and 63 and 16 width display Spinning Wheel 16x16
				}else if((self.frame.size.height < 64 && self.frame.size.height >= 16) && (self.frame.size.width < 64 && self.frame.size.width >= 16)){

					[self->spinningWheel setFrame: NSMakeRect(self.frame.size.width * 0.5 - 8, self.frame.size.height * 0.5 - 8, 16, 16)];
		#ifdef __MAC_OS_X_VERSION_MIN_REQUIRED
					[spinningWheel setControlSize:NSSmallControlSize];
		#endif
				}
			}
			
		});	// dispatch_async
	};
	
	
	if( self.checkCacheBlock ) {
		self.checkCacheBlock( url, completion );
	} else {
		completion( nil );
	}
}

- (void)cancelDownload{
    self.userDidCancel = YES;
    self.isLoadingImage = NO;
    self.didFailLoadingImage = NO;
    
#ifdef __MAC_OS_X_VERSION_MIN_REQUIRED
	[self deleteToolTips];
    
    [spinningWheel stopAnimation:self];
#else
	[spinningWheel stopAnimating];
#endif
	
    [spinningWheel removeFromSuperview];
    
    [imageURLConnection cancel];
    imageURLConnection = nil;
    imageDownloadData = nil;
    errorImage = nil;
    self.image = nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [imageDownloadData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    self.isLoadingImage = NO;
    self.didFailLoadingImage = YES;
    self.userDidCancel = NO;

#ifdef __MAC_OS_X_VERSION_MIN_REQUIRED
    [spinningWheel stopAnimation:self];
#else
	[spinningWheel stopAnimating];
#endif
	
	[spinningWheel removeFromSuperview];
    
    imageDownloadData = nil;
    imageURLConnection = nil;
    
    self.image = errorImage;
    errorImage = nil;
	
	if( self.didFinishBlock ) {
		self.didFinishBlock( nil, error );
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    self.didFailLoadingImage = NO;
    self.userDidCancel = NO;
    
    NSData *data = imageDownloadData;
    PVImage *img = [[PVImage alloc] initWithData:data];
    
    if(img){ //if NSData is from an image
        self.image = img;
        self.isLoadingImage = NO;

#ifdef __MAC_OS_X_VERSION_MIN_REQUIRED
        [spinningWheel stopAnimation:self];
#else
		[spinningWheel stopAnimating];
#endif
        [spinningWheel removeFromSuperview];
        imageDownloadData = nil;
        imageURLConnection = nil;
        errorImage = nil;
		
		if( self.didFinishBlock ) {
			self.didFinishBlock( data, nil );
		}
		
    }else{
        [self connection:nil didFailWithError:nil];
    }
}

#if defined __MAC_OS_X_VERSION_MIN_REQUIRED

-(void)setToolTipWhileLoading:(NSString *)ttip1 whenFinished:(NSString *)ttip2 andWhenFinishedWithError:(NSString *)ttip3{
    self.toolTipWhileLoading = ttip1;
    self.toolTipWhenFinished = ttip2;
    self.toolTipWhenFinishedWithError = ttip3;
}

- (void)deleteToolTips{
    self.toolTip = @"";
    self.toolTipWhileLoading = @"";
    self.toolTipWhenFinished = @"";
    self.toolTipWhenFinishedWithError = @"";
}


#pragma mark Mouse Enter Events to display tooltips
- (void)mouseEntered:(NSEvent *)theEvent{
    if (!self.userDidCancel){ //if the user didn't cancel the operation show the tooltips
        
        if (self.isLoadingImage){ //if is loading image
        
            if(self.toolTipWhileLoading != nil && ![self.toolTipWhileLoading isEqualToString:@""]){
                self.toolTip = self.toolTipWhileLoading;
            }else{
                self.toolTip = @"";
            }
            
        }else if(self.didFailLoadingImage){ //if connection did fail
            
            if(self.toolTipWhenFinishedWithError != nil && ![self.toolTipWhenFinishedWithError isEqualToString:@""]){
                self.toolTip = self.toolTipWhenFinishedWithError;
            }else{
                self.toolTip = @"";
            }
            
        }else if(!self.isLoadingImage){ //if it's not loading image
        
            if(self.toolTipWhenFinished != nil && ![self.toolTipWhenFinished isEqualToString:@""]){
                self.toolTip = self.toolTipWhenFinished;
            }else{
                self.toolTip = @"";
            }
            
        }
        
    }
}

- (void)updateTrackingAreas{
	
	[super updateTrackingAreas];
	
	if(trackingArea != nil) {
        [self removeTrackingArea:trackingArea];
    }
    
    int opts = (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways);
    trackingArea = [ [NSTrackingArea alloc] initWithRect:[self bounds]
                                                 options:opts
                                                   owner:self
                                                userInfo:nil];
    [self addTrackingArea:trackingArea];
}

#endif

@end

