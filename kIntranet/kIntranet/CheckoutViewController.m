//
//  CheckoutViewController.m
//  kIntranet
//
//  Created by Peter Sbarski on 11/09/12.
//  Copyright (c) 2012 Peter Sbarski. All rights reserved.
//

#import "CheckoutViewController.h"

@interface CheckoutViewController ()

@end

@implementation CheckoutViewController

@synthesize location;
@synthesize temporaryLocation;

@synthesize checkin;
@synthesize checkout;
@synthesize locations;

@synthesize locationPicker;
@synthesize datePicker;

@synthesize delegate;
@synthesize locationTextField;

@synthesize map;
@synthesize geocoder;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   
    self.locations = [[NSMutableArray alloc]init];
    
    [self.locations addObject:@"Cafe"];
    [self.locations addObject:@"Client"];
    [self.locations addObject:@"Boardroom"];
    [self.locations addObject:@"Other"];

    self.location = [self.locations objectAtIndex:0];
    self.checkout = [NSDate date];
    self.checkin = [[NSDate date] dateByAddingTimeInterval:3600];
    
    self.map.delegate = self;
    
    if (!self.geocoder)
        self.geocoder = [[CLGeocoder alloc]init];
    
    [self setUserLocation];
}

-(void)setUserLocation
{
    map.zoomEnabled = TRUE;
    map.showsUserLocation = TRUE;
    
    MKCoordinateRegion newRegion;
    MKUserLocation* usrLocation = map.userLocation;
    
    newRegion.center.latitude = -37.8130;// usrLocation.location.coordinate.latitude;
    newRegion.center.longitude = 144.9559;//usrLocation.location.coordinate.longitude;

    newRegion.span.latitudeDelta = 20.0;
    newRegion.span.longitudeDelta = 28.0;
    [self.map setRegion:newRegion animated:YES];
}

- (void)viewDidUnload
{
    [self setLocationTextField:nil];
    [self setCheckin:nil];
    [self setCheckout:nil];
    [self setLocation:nil];
    [self setLocations:nil];
    [self setTemporaryLocation:nil];
    
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view delegate

-(void) mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    [self.map setCenterCoordinate: userLocation.location.coordinate animated: YES];
  
    [self.geocoder reverseGeocodeLocation:userLocation.location completionHandler:^(NSArray* placemarks, NSError* error){
        
        if ([placemarks count] > 0)
        {
            [self.locations removeAllObjects];
            
            [self.locations addObject:@"Cafe"];
            [self.locations addObject:@"Client"];
            [self.locations addObject:@"Boardroom"];
            [self.locations addObject:@"Other"];
            
            for (int i = 0; i < [placemarks count]; i++)
            {
                CLPlacemark *placemark = [placemarks objectAtIndex:i];
                
                [self.locations addObject:placemark.name];
            }
        }
    }];
}

- (void)mapView:(MKMapView *)mv didAddAnnotationViews:(NSArray *)views {
    for(MKAnnotationView *annotationView in views) {
        if(annotationView.annotation == mv.userLocation) {
            MKCoordinateRegion region;
            MKCoordinateSpan span;
            
            span.latitudeDelta=0.1;
            span.longitudeDelta=0.1;
            
            CLLocationCoordinate2D location=mv.userLocation.coordinate;
            
            region.span=span;
            region.center=location;
            
            [mv setRegion:region animated:TRUE];
            [mv regionThatFits:region];
        }
    }
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selected = FALSE;
    
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            [self showLocationPicker];
        }
        else
        {
       		[self.locationTextField becomeFirstResponder];
        }
    }
    else if (indexPath.section == 1 || indexPath.section == 2)
    {
        [self showDatePicker:indexPath.section];
    }
}

-(void)showLocationPicker
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"OK", nil];
    [actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    
    locationPicker = actionSheet;
    
    CGRect pickerFrame = CGRectMake(0, 40, 0, 0);
    UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:pickerFrame];
    
    [actionSheet addSubview:pickerView];
    [actionSheet showInView:self.view];
    
    pickerView.showsSelectionIndicator = YES;
    pickerView.dataSource = self;
    pickerView.delegate = self;
    
    CGRect menuRect = actionSheet.frame;
    CGFloat orgHeight = menuRect.size.height;
    menuRect.origin.y -= 214;
    menuRect.size.height = orgHeight + 300;
    actionSheet.frame = menuRect;
    
    CGRect pickerRect = pickerView.frame;
    pickerRect.origin.y = 174;
    pickerView.frame = pickerRect;
    
    self.temporaryLocation = [self.locations objectAtIndex:0];
    
    [pickerView release];
    [actionSheet release];
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.locations count];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [self.locations objectAtIndex:row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.temporaryLocation = [self.locations objectAtIndex:row];
}

-(void)showDatePicker:(NSInteger)section
{
    UIActionSheet *menu = [[UIActionSheet alloc] initWithTitle:@"Select date and time" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"OK", nil];
    UIDatePicker *pickerView = [[UIDatePicker alloc]init];
    
    datePicker = menu;
    
    if (section == 1 && checkout != nil)
    {
        [pickerView setDate:[self checkout]];
    }
    
    if (section == 2 && checkin != nil)
    {
        [pickerView setDate:[self checkin] animated:YES];
    }
    
    menu.tag = section;

    pickerView.datePickerMode = UIDatePickerModeDateAndTime;
    [menu addSubview:pickerView];
    [menu showInView:self.view];
    
    CGRect menuRect = menu.frame;
    CGFloat orgHeight = menuRect.size.height;
    menuRect.origin.y -= 214;
    menuRect.size.height = orgHeight + 300;
    menu.frame = menuRect;
    
    CGRect pickerRect = pickerView.frame;
    pickerRect.origin.y = 174;
    pickerView.frame = pickerRect;

    [pickerView release];
    [menu release];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet == datePicker)
    {
        if (buttonIndex == 0)
        {
            UIDatePicker *selection = [[actionSheet subviews] objectAtIndex:3];
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:actionSheet.tag];
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            
            NSDateFormatter *formatter = [[[NSDateFormatter alloc]init]autorelease];
            [formatter setDateFormat:@"HH:mm dd/MM/yyyy"];
            
            //Update the labels and save dates
            switch (actionSheet.tag) {
                case 1:
                    self.checkout = [selection date];
                    
                    cell.textLabel.text = [formatter stringFromDate:checkout];
                    [cell.textLabel sizeToFit];
                    break;
                    
                case 2:
                    self.checkin = [selection date];
                    
                    cell.textLabel.text = [formatter stringFromDate:checkin];
                    [cell.textLabel sizeToFit];
                    break;
                    
                default:
                    break;
            }
        }
    }
    else
    {
        if (buttonIndex == 0)
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            
            cell.textLabel.text = self.location = self.temporaryLocation;
            [cell.textLabel sizeToFit];
        }
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.text.length > 0)
    {
        self.location = textField.text;
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        
        cell.textLabel.text = @"Custom Location";
        [cell.textLabel sizeToFit];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

-(IBAction)cancel:(id)sender
{
    [self.delegate checkoutViewControllerDidCancel:self];
}

-(IBAction)done:(id)sender
{
    for (Staff *staff in [self.delegate selectedStaff:self])
    {
        staff.checkin = self.checkin;
        staff.checkout = self.checkout;
        staff.location = self.location;
        staff.selected = FALSE;
        staff.modified = TRUE;
    }
    
    [self.delegate checkoutViewControllerDidSave:self];
}

- (void)dealloc {
    [locationTextField release];
    [locations release];
    [temporaryLocation release];
    [map release];
    [geocoder release];
    [super dealloc];
}
@end
