//
//  RootViewController.m
//  ActiveHistorianDownloadiOS
//
//  Created by Panayiotis Stylianou on 10/01/2013.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//


#import "RootViewController.h"
#import <DropboxSDK/DropboxSDK.h>
#import <Dropbox/Dropbox.h>



@interface RootViewController ()

- (void)updateButtons;

@end


@implementation RootViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        self.title = @"Link Account";
    }
    return self;
}

- (void)didPressLink {
    if (![[DBSession sharedSession] isLinked]) {
		[[DBSession sharedSession] linkFromController:self];
    } else {
        [[DBSession sharedSession] unlinkAll];
        [[[[UIAlertView alloc] 
           initWithTitle:@"Account Unlinked!" message:@"Your dropbox account has been unlinked" 
           delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]
          autorelease]
         show];
        [self updateButtons];
    }
}

- (IBAction)didPressvideos {
    
    [[DBAccountManager sharedManager] linkFromController:self];
    
    [self.navigationController pushViewController:secondViewController animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateButtons];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] 
            initWithTitle:@"Sync" style:UIBarButtonItemStylePlain 
            target:self action:@selector(didPressvideos)] autorelease];
    self.title = @"Link Account";
}

- (void)viewDidUnload {
    [linkButton release];
    linkButton = nil;
}

- (void)dealloc {
    [linkButton release];
    [secondViewController release];
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return toInterfaceOrientation == UIInterfaceOrientationPortrait;
    } else {
        return YES;
    }
}


#pragma mark private methods

@synthesize linkButton;
@synthesize secondViewController;

- (void)updateButtons {
    NSString* title = [[DBSession sharedSession] isLinked] ? @"Unlink Dropbox" : @"Link Dropbox";
    [linkButton setTitle:title forState:UIControlStateNormal];
    
    self.navigationItem.rightBarButtonItem.enabled = [[DBSession sharedSession] isLinked];
}

@end

