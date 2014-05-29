//
//  DetailViewController.m
//  Craveit
//
//  Created by Ashis Poddar on 5/28/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation DetailViewController

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
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    
    
    //load the chefs details here
    NSString *restCallString = @"http://ec2-54-183-28-243.us-west-1.compute.amazonaws.com:7878/foodliciouzz/chefs";
    
    NSURL *restURL = [NSURL URLWithString:restCallString];
    NSURLRequest* request = [NSURLRequest requestWithURL:restURL];
    NSURLResponse* response = nil;
    NSError* errors = nil;
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    /*
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&errors];
    if(!data) {
        NSLog(@"%s:sendSynchronousRequest error:%@",__FUNCTION__,errors);
        return;
    }
    else if( [response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSInteger httpStatus = [(NSHTTPURLResponse *)response statusCode];
        if(httpStatus != 200) {
            NSLog(@"%s: sendSynchronousRequest != 200 , response=%@",__FUNCTION__, response);
        }
    }
    NSError* parseError = nil;
    NSDictionary* dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
    if(!dictionary) {
        NSLog(@"%s: JSONObjectWithData error = %@,data = %@",__FUNCTION__,parseError,data);
    }
    NSArray* chefs = dictionary[@"chefs"];
    if(chefs) {
        NSUInteger index = 0;
        for(NSDictionary* chef in chefs)
        {
            NSLog(@"-----");
            NSString* chefName = chef[@"name"];
            NSLog(@"Name:%@",chef[@"name"]);
            NSLog(@"Address:%@",chef[@"address"][@"address1"]);
        }
    }
    */
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
    _responseData = [[NSMutableData alloc] init];
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    NSLog(@"%s: connection didReceiveData , response=%@",__FUNCTION__, data);
    [_responseData appendData:data];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    
    if(_responseData) {
        
        NSError* parseError = nil;
        NSDictionary* dictionary = [NSJSONSerialization JSONObjectWithData:_responseData options:0 error:&parseError];
        if(!dictionary) {
            NSLog(@"%s: JSONObjectWithData error = %@,data = %@",__FUNCTION__,parseError,_responseData);
        }
        NSArray* chefs = dictionary[@"chefs"];
        if(chefs) {
            NSUInteger index = 0;
            for(NSDictionary* chef in chefs)
            {
                NSLog(@"-----");
                NSString* chefName = chef[@"name"];
                NSLog(@"Name:%@",chef[@"name"]);
                NSLog(@"Address:%@",chef[@"address"][@"address1"]);
            }
        }

    }
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
}
- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

@end
