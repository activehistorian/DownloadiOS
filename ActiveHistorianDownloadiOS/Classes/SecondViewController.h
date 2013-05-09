//
//  SecondViewController.h
//  ActiveHistorianDownloadiOS
//
//  Created by Panayiotis Stylianou on 10/01/2013.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//


@class DBRestClient;

@interface SecondViewController : UIViewController {
    UIImageView* imageView;
    UIButton* nextButton;
    UIActivityIndicatorView* activityIndicator;
    
    NSArray* videoPaths;
    NSString* videosHash;
    NSString* currentvideoPath;
    BOOL working;
    DBRestClient* restClient;
}

@property (nonatomic, retain) IBOutlet UIImageView* imageView;
@property (nonatomic, retain) IBOutlet UIButton* nextButton;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView* activityIndicator;

@end
