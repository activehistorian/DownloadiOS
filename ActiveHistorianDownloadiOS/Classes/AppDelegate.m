//
//  AppDelegate.h
//  ActiveHistorianDownloadiOS
//
//  Created by Panayiotis Stylianou on 10/01/2013.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//


#import "AppDelegate.h"
#import <DropboxSDK/DropboxSDK.h>
#import "SecondViewController.h"
#import "RootViewController.h"
#import <Dropbox/Dropbox.h>

@interface DBRouletteAppDelegate () <DBSessionDelegate, DBNetworkRequestDelegate>

@end


@implementation DBRouletteAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize rootViewController;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
	// Set these variables before launching the app
    NSString* appKey = @"le2ytsy64bt80ix";
	NSString* appSecret = @"mtpgb0cdzzp6hj4";
	NSString *root = kDBRootAppFolder; 
	
    
    DBAccountManager* accountMgr = [[DBAccountManager alloc] initWithAppKey:appKey secret:appSecret];
    [DBAccountManager setSharedManager:accountMgr];
    DBAccount *account = accountMgr.linkedAccount;
    
    if(account){
        DBFilesystem *filesystem = [[DBFilesystem alloc] initWithAccount:account];
        [DBFilesystem setSharedFilesystem:filesystem];
    }
	
	NSString* errorMsg = nil;
	if ([appKey rangeOfCharacterFromSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]].location != NSNotFound) {
		errorMsg = @"Make sure you set the app key correctly in DBRouletteAppDelegate.m";
	} else if ([appSecret rangeOfCharacterFromSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]].location != NSNotFound) {
		errorMsg = @"Make sure you set the app secret correctly in DBRouletteAppDelegate.m";
	} else if ([root length] == 0) {
		errorMsg = @"Set your root to use either App Folder of full Dropbox";
	} else {
		NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
		NSData *plistData = [NSData dataWithContentsOfFile:plistPath];
		NSDictionary *loadedPlist = 
				[NSPropertyListSerialization 
				 propertyListFromData:plistData mutabilityOption:0 format:NULL errorDescription:NULL];
		NSString *scheme = [[[[loadedPlist objectForKey:@"CFBundleURLTypes"] objectAtIndex:0] objectForKey:@"CFBundleURLSchemes"] objectAtIndex:0];
		if ([scheme isEqual:@"db-APP_KEY"]) {
			errorMsg = @"Set your URL scheme correctly in DBRoulette-Info.plist";
		}
	}
	
	DBSession* session = 
        [[DBSession alloc] initWithAppKey:appKey appSecret:appSecret root:root];
	session.delegate = self; 
	[DBSession setSharedSession:session];
    [session release];
	
	[DBRequest setNetworkRequestDelegate:self];

	if (errorMsg != nil) {
		[[[[UIAlertView alloc]
		   initWithTitle:@"Error Configuring Session" message:errorMsg 
		   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]
		  autorelease]
		 show];
	}
    
    rootViewController.secondViewController = [[SecondViewController new] autorelease];
    if ([[DBSession sharedSession] isLinked]) {
        navigationController.viewControllers = 
            [NSArray arrayWithObjects:rootViewController, rootViewController.secondViewController, nil];
    }
    
    [window addSubview:navigationController.view];
    [window makeKeyAndVisible];
	
	NSURL *launchURL = [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
	NSInteger majorVersion = 
		[[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] integerValue];
	if (launchURL && majorVersion < 4) {

		[self application:application handleOpenURL:launchURL];
		return NO;
	}

    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    
    DBAccount *account = [[DBAccountManager sharedManager] handleOpenURL:url];
    if (account) {
        DBFilesystem *filesystem = [[DBFilesystem alloc] initWithAccount:account];
        [DBFilesystem setSharedFilesystem:filesystem];
        NSLog(@"App linked successfully!");
        return YES;
    }
	if ([[DBSession sharedSession] handleOpenURL:url]) {
		if ([[DBSession sharedSession] isLinked]) {
			[navigationController pushViewController:rootViewController.secondViewController animated:YES];
		}
		return YES;
	}
	
	return NO;
}


#pragma mark -
#pragma mark Memory management



- (void)dealloc {
	[navigationController release];
	[window release];
	[super dealloc];
}


#pragma mark -
#pragma mark DBSessionDelegate methods

- (void)sessionDidReceiveAuthorizationFailure:(DBSession*)session userId:(NSString *)userId {
	relinkUserId = [userId retain];
	[[[[UIAlertView alloc] 
	   initWithTitle:@"Dropbox Session Ended" message:@"Do you want to relink?" delegate:self 
	   cancelButtonTitle:@"Cancel" otherButtonTitles:@"Relink", nil]
	  autorelease]
	 show];
}


#pragma mark -
#pragma mark UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)index {
	if (index != alertView.cancelButtonIndex) {
		[[DBSession sharedSession] linkUserId:relinkUserId fromController:rootViewController];
	}
	[relinkUserId release];
	relinkUserId = nil;
}


#pragma mark -
#pragma mark DBNetworkRequestDelegate methods

static int outstandingRequests;

- (void)networkRequestStarted {
	outstandingRequests++;
	if (outstandingRequests == 1) {
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	}
}

- (void)networkRequestStopped {
	outstandingRequests--;
	if (outstandingRequests == 0) {
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	}
}

@end

