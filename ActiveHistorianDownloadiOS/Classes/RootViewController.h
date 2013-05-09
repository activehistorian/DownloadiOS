//
//  RootViewController.h
//  ActiveHistorianDownloadiOS
//
//  Created by Panayiotis Stylianou on 10/01/2013.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

@class DBRestClient;


@interface RootViewController : UIViewController {
    UIButton* linkButton;
    UIViewController* secondViewController;
	DBRestClient* restClient;
}

- (IBAction)didPressLink;

@property (nonatomic, retain) IBOutlet UIButton* linkButton;
@property (nonatomic, retain) UIViewController* secondViewController;

@end
