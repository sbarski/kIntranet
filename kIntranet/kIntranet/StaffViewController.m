//
//  StaffViewController.m
//  kIntranet
//
//  Created by Peter Sbarski on 11/09/12.
//  Copyright (c) 2012 Peter Sbarski. All rights reserved.
//

#import "StaffViewController.h"

@interface StaffViewController ()

@end

@implementation StaffViewController

@synthesize employees;
@synthesize selectedCells;

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
    
    [self tableView].allowsMultipleSelection = TRUE;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.employees count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StaffCell"];
    Staff *staff = [self.employees objectAtIndex:indexPath.row];
    cell.textLabel.text = staff.name;
    cell.detailTextLabel.text = staff.location;
    
    if (staff.checkin != nil)
    {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"HH:mm dd/MM/yyyy"];
        
        //Optionally for time zone converstions
        [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];
        
        NSString *stringFromDate = [formatter stringFromDate:staff.checkin];
        
        cell.detailTextLabel.text = [cell.detailTextLabel.text stringByAppendingString:@ " - "];

        cell.detailTextLabel.text = [cell.detailTextLabel.text stringByAppendingString:stringFromDate];
        
        cell.textLabel.textColor = [UIColor redColor];
        //cell.detailTextLabel.textColor = [UIColor redColor];
        
        [formatter release];
    }
    else
    {
        cell.detailTextLabel.textColor = [UIColor darkGrayColor];
    }
    
    if (staff.selected == FALSE)
    {
        cell.imageView.hidden = TRUE;
    }
    
    return cell;
}

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

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView cellForRowAtIndexPath:indexPath].imageView.hidden = TRUE;
    
    selectedCells = [self.tableView indexPathsForSelectedRows];
    
    if (selectedCells.count == 0)
    {
        self.navigationItem.rightBarButtonItem.enabled = FALSE;
        self.navigationItem.leftBarButtonItem.enabled = FALSE;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView cellForRowAtIndexPath:indexPath].imageView.hidden = FALSE;

    Staff *staff = [self.employees objectAtIndex:indexPath.row];
    staff.selected = [tableView cellForRowAtIndexPath:indexPath].imageView.hidden == TRUE;
    
    selectedCells = [self.tableView indexPathsForSelectedRows];
    
    if (selectedCells.count > 0)
    {
        self.navigationItem.rightBarButtonItem.enabled = TRUE;
        self.navigationItem.leftBarButtonItem.enabled = TRUE;
    }
}

#pragma mark - PlayerDetailsViewControllerDelegate

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Checkout"])
    {
        UINavigationController *navigationController = segue.destinationViewController;
        CheckoutViewController *checkoutViewController = [[navigationController viewControllers] objectAtIndex:0];
        checkoutViewController.delegate = self;
    }
}

-(NSArray*)selectedStaff:(CheckoutViewController *)controller
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"selected = FALSE"];
    
    NSArray *selected = [[self employees] filteredArrayUsingPredicate:predicate];
    
    return selected;
}

-(void)checkoutViewControllerDidCancel:(CheckoutViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)checkoutViewControllerDidSave:(CheckoutViewController *)controller
{
    [self.tableView reloadData];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
