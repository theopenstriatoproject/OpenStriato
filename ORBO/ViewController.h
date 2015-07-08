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




#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "SelectionDeviceTableView.h"
#import <MessageUI/MessageUI.h>

@interface ViewController : UIViewController < AVAudioPlayerDelegate, ORBOSelectionDeviceTableViewDelegate, MFMailComposeViewControllerDelegate>


@property(nonatomic, weak)      IBOutlet UILabel                    *theBaseNameLabel;
@property(nonatomic, weak)      IBOutlet UILabel                    *theCardNumberLabel;
@property(weak, nonatomic)      IBOutlet UIButton                   *theButton;
@property(weak, nonatomic)      IBOutlet UIActivityIndicatorView    *theFirstActivityIndicator;
@property(strong, nonatomic)    IBOutlet UIProgressView             *theProgressView;

@property(weak, nonatomic)      IBOutlet UIButton                   *theInfomationButton;
@property(weak, nonatomic)      IBOutlet UIButton                   *theWebsiteButton;


-(IBAction) openStriatoWebSite;
-(IBAction) showInformation;

@end


