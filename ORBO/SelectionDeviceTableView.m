//
//  ViewController.m
//  OpenStriato
//
//  Created by vincent deyres on 15/04/2015.
//  Released under the MIT licence
//  Copyright (c) 2015
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.




#import "SelectionDeviceTableView.h"
#import <CoreBluetooth/CoreBluetooth.h>


@implementation SelectionDeviceTableView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    //self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
  //--------------------------------------------------------------------------------------------

    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  //--------------------------------------------------------------------------------------------


    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  //--------------------------------------------------------------------------------------------

    return self.theDiscoveredDevicesArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  //--------------------------------------------------------------------------------------------
  
    
  UITableViewCell *cell				= [tableView dequeueReusableCellWithIdentifier:@"DeviceSelectionCell" forIndexPath:indexPath];
  
  CBPeripheral * aPeripheral = [ self.theDiscoveredDevicesArray objectAtIndex:indexPath.row];
  
  [[cell textLabel] setText:aPeripheral.name];
  [[cell detailTextLabel] setText:@""];
  
  return cell;

}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
  //--------------------------------------------------------------------------------------------

    // Return NO if you do not want the specified item to be editable.
    return NO;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  //--------------------------------------------------------------------------------------------

  [self.delegate validateDeviceForRow:(int)indexPath.row];
  [self dismissViewControllerAnimated:YES completion:nil];


}


@end
