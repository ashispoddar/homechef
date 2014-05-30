//
//  DetailViewController.h
//  Craveit
//
//  Created by Ashis Poddar on 5/28/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import <UIKit/UIKit.h>
//@interface DetailViewController : UIViewController <UISplitViewControllerDelegate>



@interface DetailViewController : UIViewController <UISplitViewControllerDelegate ,NSURLConnectionDelegate>
{
    NSURLConnection* _connection;
    NSMutableData *_responseData;
    NSInteger _responseStatus;
}


@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
