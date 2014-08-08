//
//  MasterViewController.m
//  Craveit
//
//  Created by Ashis Poddar on 5/28/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import <AddressBook/AddressBook.h>

#import <objc/runtime.h>

@interface UIAlertView (Private)
@property (nonatomic, strong) id context;
@end

@implementation UIAlertView (Private)
@dynamic context;
-(void)setContext:(id)context {
    objc_setAssociatedObject(self, @selector(context), context, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(id)context {
    return objc_getAssociatedObject(self, @selector(context));
}
@end




@interface MasterViewController () {
    NSMutableArray *_objects;
}
@end

@implementation MasterViewController

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //okay chefs are loaded, check whether any of them are in your contact book and then set the flag
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied ||
        ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusRestricted){
        NSLog(@"Denied");
    } else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized){
        NSLog(@"Authorized");
    } else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        NSLog(@"Not determined");
    }else {
        NSLog(@"Unknown");
    }
    //lets' ask permission
    ABAddressBookRequestAccessWithCompletion(
        ABAddressBookCreateWithOptions(NULL, nil), ^(bool granted, CFErrorRef error) {
        if (!granted){
            NSLog(@"Just denied");
            return;
        }
        NSLog(@"Just authorized");
    });
    //create a reference of address books to be used down below
    CFErrorRef *error1 = nil;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error1);
                                             
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    //load the chefs details here
    NSString *restCallString = @"http://ec2-54-183-7-127.us-west-1.compute.amazonaws.com:7878/foodliciouzz/chefs";
    
    NSURL *restURL = [NSURL URLWithString:restCallString];
    NSURLRequest* request = [NSURLRequest requestWithURL:restURL];
    NSURLResponse* response = nil;
    NSError* errors = nil;
    
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
            NSLog(@"Address.City:%@",chef[@"address"][@"city"]);
            NSLog(@"Address.State:%@",chef[@"address"][@"state"]);
            NSLog(@"Address.Zip:%@",chef[@"address"][@"zip"]);
            
            if(!_objects) {
                _objects = [[NSMutableArray alloc] init];
            }
            [_objects addObject:chefName];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            index++;
            
            //read the address and seach for user, if find match , make them bold
            // Fetch the address book
            // Search for the person named "Appleseed" in the address book
            NSArray *people = (__bridge NSArray *)ABAddressBookCopyPeopleWithName(addressBook, (__bridge CFStringRef)chefName);
            if(people == nil || people.count <= 0){
                
                NSString * message = [NSString stringWithFormat:@"Would you like to add '%@' to your Contact ?", chefName];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Contact"
                                        message:message
                                        delegate:self
                                        cancelButtonTitle:@"Cancel"
                                        otherButtonTitles:nil];
                [alert setContext:chefName];
                [alert addButtonWithTitle:@"Yes"];
                [alert show];
            }
        }
        CFRelease(addressBook);
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender
{
    if (!_objects) {
        _objects = [[NSMutableArray alloc] init];
    }
    NSUInteger len = _objects.count;
    [_objects insertObject:[NSDate date] atIndex:len];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:len inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    NSDate *object = _objects[indexPath.row];
    cell.textLabel.text = [object description];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    BOOL editable= (indexPath.item % 2) ? TRUE :FALSE;
    return editable;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        NSDate *object = _objects[indexPath.row];
        self.detailViewController.detailItem = object;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDate *object = _objects[indexPath.row];
        [[segue destinationViewController] setDetailItem:object];
    }
}
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        
        NSString *chefName = [alertView context];
        NSLog(@"Adding to Contacts, Chef=%@",chefName);
        
        NSArray *tokens = [chefName componentsSeparatedByString:@" "];
        
        NSString *firstName =nil;
        NSString *lastName = nil;
        
        if(tokens.count > 1) {
            firstName = tokens[0];
            lastName= tokens[1];
        }else {
            firstName = chefName;
        }
        
        //create the record.
        ABRecordRef chef = ABPersonCreate();
        
        if(firstName != nil)
            ABRecordSetValue(chef, kABPersonFirstNameProperty, (__bridge CFStringRef)firstName, nil);
        if(lastName != nil)
            ABRecordSetValue(chef, kABPersonLastNameProperty, (__bridge CFStringRef)lastName, nil);
        
        if(firstName != nil) {
            ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, nil);
            ABAddressBookAddRecord(addressBookRef, chef, nil);
            ABAddressBookSave(addressBookRef, nil);
        }
        
    }
}

@end
