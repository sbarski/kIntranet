//
//  CheckoutViewController.h
//  kIntranet
//
//  Created by Peter Sbarski on 11/09/12.
//  Copyright (c) 2012 Peter Sbarski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Staff.h"

@class CheckoutViewController;

@protocol CheckoutViewControllerDelegate <NSObject>
-(void)checkoutViewControllerDidCancel : (CheckoutViewController *)controller;
-(void)checkoutViewControllerDidSave : (CheckoutViewController *)controller;
-(NSArray*)selectedStaff : (CheckoutViewController *)controller;
@end

@interface CheckoutViewController : UITableViewController<UIActionSheetDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, MKMapViewDelegate>

@property (nonatomic, copy) NSString *location;
@property (nonatomic, copy) NSString *temporaryLocation;


@property (nonatomic, copy) NSDate *checkout;
@property (nonatomic, copy) NSDate *checkin;
@property (nonatomic, retain) NSMutableArray *locations;
@property (nonatomic, retain) UIActionSheet *locationPicker;
@property (nonatomic, retain) UIActionSheet *datePicker;

@property (nonatomic, strong) id <CheckoutViewControllerDelegate> delegate;

@property (retain, nonatomic) IBOutlet UITextField *locationTextField;

@property (nonatomic, strong) CLGeocoder *geocoder;

- (IBAction)cancel: (id)sender;
- (IBAction)done: (id)sender;

@property (retain, nonatomic) IBOutlet MKMapView *map;

@end
