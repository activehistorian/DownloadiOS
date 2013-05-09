//
//  SecondViewController.m
//  ActiveHistorianDownloadiOS
//
//  Created by Panayiotis Stylianou on 10/01/2013.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//


#import "SecondViewController.h"
#import <DropboxSDK/DropboxSDK.h>
#import <stdlib.h>


@interface SecondViewController () <DBRestClientDelegate>

- (NSString*)videoPath;
- (void)didPressRandomvideo;
- (void)displayError;
- (void)setWorking:(BOOL)isWorking;

@property (nonatomic, readonly) DBRestClient* restClient;

@end


@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Sync Videos";
    [nextButton addTarget:self action:@selector(didPressRandomvideo) 
            forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidUnload {
    [super viewDidUnload];
   
    self.imageView = nil;
    self.nextButton = nil;
    self.activityIndicator = nil;
}

- (void)dealloc {
    [imageView release];
    [nextButton release];
    [activityIndicator release];
    [videoPaths release];
    [videosHash release];
    [currentvideoPath release];
    [restClient release];
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!working && !imageView.image) {
        [self didPressRandomvideo];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return toInterfaceOrientation == UIInterfaceOrientationPortrait;
    } else {
        return YES;
    }
}

@synthesize imageView;
@synthesize nextButton;
@synthesize activityIndicator;


#pragma mark DBRestClientDelegate methods

- (void)restClient:(DBRestClient*)client loadedMetadata:(DBMetadata*)metadata {
    [videosHash release];
    videosHash = [metadata.hash retain];
    
    NSArray* validExtensions = [NSArray arrayWithObjects:@"jpg", @"jpeg", "mp4", "3gp", nil];
    NSMutableArray* newvideoPaths = [NSMutableArray new];
    for (DBMetadata* child in metadata.contents) {
        NSString* extension = [[child.path pathExtension] lowercaseString];
        if (!child.isDirectory && [validExtensions indexOfObject:extension] != NSNotFound) {
            [newvideoPaths addObject:child.path];
        }
    }
    [videoPaths release];
    videoPaths = newvideoPaths;
}



- (void)restClient:(DBRestClient*)client loadMetadataFailedWithError:(NSError*)error {
    NSLog(@"restClient:loadMetadataFailedWithError: %@", [error localizedDescription]);
    [self displayError];
    [self setWorking:NO];
}

- (void)restClient:(DBRestClient*)client loadedThumbnail:(NSString*)destPath {
    [self setWorking:NO];
    imageView.image = [UIImage imageWithContentsOfFile:destPath];
}

- (void)restClient:(DBRestClient*)client loadThumbnailFailedWithError:(NSError*)error {
    [self setWorking:NO];
    [self displayError];
}


#pragma mark private methods

- (void)didPressRandomvideo {
    
    
    [self setWorking:YES];

    NSString *videosRoot = nil;
    if ([DBSession sharedSession].root == kDBRootDropbox) {
        videosRoot = @"/videos";
    } else {
        videosRoot = @"/";
    }

    [self.restClient loadMetadata:videosRoot withHash:videosHash];
}


- (NSString*)videoPath {
    return [NSTemporaryDirectory() stringByAppendingPathComponent:@"video.jpg"];
}

- (void)displayError {
    
    [[[[UIAlertView alloc] 
       initWithTitle:@"Error Loading video" message:@"There was an error loading your video." 
       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]
      autorelease]
     show];
     
}

- (void)setWorking:(BOOL)isWorking {
    if (working == isWorking) return;
    working = isWorking;
    
    if (working) {
        [activityIndicator startAnimating];
    } else { 
        [activityIndicator stopAnimating];
    }
    nextButton.enabled = !working;
}

- (DBRestClient*)restClient {
    if (restClient == nil) {
        restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
    }
    return restClient;
}

@end
