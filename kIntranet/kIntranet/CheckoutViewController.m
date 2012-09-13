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

#pragma mark - Table view data source

/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    
    return cell;
}
 */

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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

#pragma mark - Table view delegate

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
    else if (indexPath.section > 0)
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
    }
    
    [self.delegate checkoutViewControllerDidSave:self];
}

- (void)dealloc {
    [locationTextField release];
    [locations release];
    [temporaryLocation release];
    [super dealloc];
}
@end
