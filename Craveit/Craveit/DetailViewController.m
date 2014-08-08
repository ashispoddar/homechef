//
//  DetailViewController.m
//  Craveit
//
//  Created by Ashis Poddar on 5/28/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "DetailViewController.h"



@interface DetailViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *foodItemView;
@property (strong, nonatomic) IBOutlet UILabel *chefRating;
@property (strong, nonatomic) IBOutlet UILabel *chefLikes;
@property (strong, nonatomic) IBOutlet UILabel *chefSpeciality;
@property (strong, nonatomic) IBOutlet UILabel *chefWorkDistance;

@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end



@implementation DetailViewController
@synthesize foodItemView;
@synthesize chefRating;
@synthesize chefLikes;
@synthesize chefSpeciality;
@synthesize chefWorkDistance;

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
        self.detailDescriptionLabel.text = [self.detailItem description];
    }
    NSMutableArray *imagesArr = [[NSMutableArray alloc] init];
    assert(imagesArr);
    
    [imagesArr addObject:[UIImage imageNamed: @"patishapta.jpg"]];
    [imagesArr addObject:[UIImage imageNamed: @"chanar_jilepi.jpg"]];
    [imagesArr addObject:[UIImage imageNamed: @"jivegaja.jpg"]];
    [imagesArr addObject:[UIImage imageNamed: @"khirkadam.jpg"]];
    [imagesArr addObject:[UIImage imageNamed: @"misti_singara.jpg"]];
    [imagesArr addObject:[UIImage imageNamed: @"rajbhog.jpg"]];
    
    foodItemView.animationImages = imagesArr;
    [foodItemView setAnimationRepeatCount:HUGE_VALF];
    foodItemView.animationDuration = 15.0;
    [foodItemView startAnimating];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    
    NSString * chefName = [self.detailItem description];
    assert(chefName != nil);
    
    NSString *chefId = [chefName stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    assert(chefId != nil);
    
    //TODO:AP: make it real REST by using path variables not query param
    NSString *urlString = [NSString stringWithFormat:@"http://ec2-54-183-7-127.us-west-1.compute.amazonaws.com:7878/foodliciouzz/chefs/%@" ,chefId];

    
    NSURL *restURL = [NSURL URLWithString:urlString];
    NSURLRequest* request = [NSURLRequest requestWithURL:restURL];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    
    if ([response isKindOfClass: [NSHTTPURLResponse class]]) {
        _responseStatus = [(NSHTTPURLResponse*) response statusCode];
    }

    NSLog(@"%s: connection didReceiveData , status code=%ld",__FUNCTION__,(long)_responseStatus);
    
    _responseData = [[NSMutableData alloc] init];
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    NSLog(@"%s: connection didReceiveData , response=%@",__FUNCTION__, data);
    [_responseData appendData:data];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
   
    if(_responseData) {
        
        NSError* parseError = nil;
        NSDictionary* dictionary = [NSJSONSerialization JSONObjectWithData:_responseData options:0 error:&parseError];
        if(!dictionary) {
            NSLog(@"%s: JSONObjectWithData error = %@,data = %@",__FUNCTION__,parseError,_responseData);
        }
        if(_responseStatus == 200) {
            
            NSString *rating = [NSString stringWithFormat:@"%@",dictionary[@"rating"]];
            NSString *likes = [NSString stringWithFormat:@"%@",dictionary[@"like"]];
            
            NSString *speciality = [[NSString alloc] initWithString:dictionary[@"speciality"]];
           
            [chefRating setText:rating];
            [chefLikes setText:likes];
            [chefSpeciality setText:speciality];
            //TODO:AP : need to calculate distance for user's current location
            //should be done back in server.
            [chefWorkDistance setText:@"1.2 miles"];
        
            //add items images and text embeded in the control
            //should we subclass the UIImageView here with data ?
            NSArray *items = dictionary[@"items"];
            if(items) {
                for(NSDictionary* item in items)
                {
                    NSLog(@"-----");
                    NSLog(@"Name:%@",item[@"name"]);
                    NSLog(@"Address:%@",item[@"price"]);
                    NSLog(@"Available:%@",item[@"available"]);
                }
            }
        }else if(_responseStatus >= 400) {
            
            NSUInteger errorCode = dictionary[@"errorCode"];
            NSString* errorDesc = dictionary[@"errorDesc"];
            NSUInteger correlationId = dictionary[@"correlationId"];
            NSString* debugMsg =dictionary[@"debugMsg"];
            
            NSLog(@"-----");
            NSLog(@"errorCode:%@",(long)errorCode);
            NSLog(@"errorDesc:%@",errorDesc);
            
            
            NSString *titleString = @"App Internal Error:";
            NSString *messageString = [NSString stringWithFormat:@"%@. %@", errorDesc, debugMsg];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:titleString
                                                                message:messageString delegate:self
                                                      cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
            [alertView show];
            
            }//end else
    }// response data
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
    NSLog(@"%s: didFailWithError error = %@",__FUNCTION__,error);
    
    NSString *titleString = @"Apologies ! App cannot connect to server.";
    NSString *messageString = [error localizedDescription];
    NSString *moreString = [error localizedFailureReason] ?
    [error localizedFailureReason] :
    NSLocalizedString(@"Please try again later.", nil);
    messageString = [NSString stringWithFormat:@"%@. %@", messageString, moreString];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:titleString
                                                        message:messageString delegate:self
                                              cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
    [alertView show];
    
    
}
- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

@end
