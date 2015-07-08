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



#import "ViewController.h"
//#import <CoreBluetooth/CoreBluetooth.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "SelectionDeviceTableView.h"
#import "Orbo.h"

#import <MediaPlayer/MediaPlayer.h>




@interface ViewController () {
  //--------------------------------------------------------------------------------------------
  // Variables
  //--------------------------------------------------------------------------------------------
    AVAudioPlayer       *_theBingPlayer;
    
    UIImage             *_theButtonIsWaiting;
    UIImage             *_theButtonHasReceivedRFID;
    UIImage             *_theButtonIsOff;
    UIImage             *_theButtonIsSearching;
    
    Orbo                *_theOrboDevice;
    
    NSTimer            *_theProgressTimer;
    int                 _theProgressTimerCount;
    
    bool                _accidentalDisconnectionWarning;
  
    MPMusicPlayerController* musicPlayer;
    NSArray             *itemsFromMusicQuery;
  
}
//--------------------------------------------------------------------------------------------

@end


@implementation ViewController

//-----------------------------------------------------------------
#pragma mark initialization 
//-----------------------------------------------------------------

- (void)viewDidLoad {
  //--------------------------------------------------------------------------------------------
  [super viewDidLoad];
    
    [self setAllNotifications];
  
    musicPlayer = [MPMusicPlayerController applicationMusicPlayer];
  


    //--------------------------------------------------------------------------------------------
    // Button images init
    //--------------------------------------------------------------------------------------------

    _theButtonIsOff                = [UIImage imageNamed:@"upButton"];
    _theButtonIsWaiting            = [UIImage imageNamed:@"downButtonWaiting"];
    _theButtonHasReceivedRFID      = [UIImage imageNamed:@"downButtonRFIDReceived"];
    _theButtonIsSearching          = [UIImage imageNamed:@"searchButton"];
  
    //--------------------------------------------------------------------------------------------
    // Orbo device initialization
    //--------------------------------------------------------------------------------------------
    
    _theOrboDevice = [[Orbo alloc] init];
    

    //--------------------------------------------------------------------------------------------
    // Read the local musics
    //--------------------------------------------------------------------------------------------
    
    NSNumber *musicTypeNum = [NSNumber numberWithInteger:MPMediaTypeMusic];
    
    // Make the predicate for the music files
    MPMediaPropertyPredicate *musicPredicate = [MPMediaPropertyPredicate predicateWithValue:musicTypeNum forProperty:MPMediaItemPropertyMediaType];
    // Creat ethe Query
    MPMediaQuery *musicQuery = [[MPMediaQuery alloc] init];
    // apply the predicate to filter the results
    [musicQuery addFilterPredicate: musicPredicate];
    
    
    //NSLog(@"Logging items from a generic query...");
    itemsFromMusicQuery = [musicQuery items];
    
    if ( itemsFromMusicQuery.count >0) {
        self.theBaseNameLabel.text = @"Loading music directory";
        
        int index =0;
        
        for (MPMediaItem *aMusic in itemsFromMusicQuery) {
            NSString *aMusicTitle = [aMusic valueForProperty: MPMediaItemPropertyTitle];
            NSLog (@"Number : %i - %@", index,aMusicTitle);
            index++;
        }
    } else {
        NSLog(@"No music found on this device...");
    }
    self.theBaseNameLabel.text = @"No base connected";
    
    
}

- (void)viewDidAppear:(BOOL)animated {
  
  


}



- (void)didReceiveMemoryWarning {
  //--------------------------------------------------------------------------------------------
    [super didReceiveMemoryWarning];

}

//-----------------------------------------------------------------
#pragma mark Actions functions
//-----------------------------------------------------------------


-(IBAction) didModifiedButton:(UIButton*)sender {
  //--------------------------------------------------------------------------------------------
  // connect or disconnect the device from the current base

    
  //NSLog(@"Button pushed");
    
    if (_theOrboDevice.bluetoothIsEnabled) {
    
        if ( _theOrboDevice.isConnected ) {
            // if status connected -> disconnect
            
            [self.theButton setImage:_theButtonIsOff forState:UIControlStateNormal];
            
            [self disconnectTheDevice];
        
        } else {
            // if status disconnect -> connect
            
            // re add set notification for scanEnded which is deactivated when the scan is ended
            //--------------------------------------------------------------------------------------------
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(scanEnded)
                                                         name:@"scanEnded"
                                                       object:_theOrboDevice];
            
            _accidentalDisconnectionWarning =  true;
          
            NSLog(@"Scanning...");
            [self.theProgressView setProgress:0.0 animated:NO];
            self.theProgressView.hidden = false;
          
            [self.theButton setImage:_theButtonIsSearching forState:UIControlStateDisabled];
            self.theButton.enabled              = NO;
            self.theInfomationButton.enabled    = NO;
            self.theWebsiteButton.enabled       = NO;
        
            self.theBaseNameLabel.text          = @"Searching base...";
            self.theCardNumberLabel.text        = @"Searching base...";
          
            // Timer for the progress view
            //-----------------------------------------------------------------
            
            _theProgressTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(updateTheProgressView:) userInfo:nil repeats:YES];

            
            // Scanning
            //-----------------------------------------------------------------
        
            [_theOrboDevice startScanning];
            
      }
      
    } else {
        
        [self playSound:@"button-33a"];
      
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Bluetooth not enabled"
                                                                     message:@"Enable Bluetooth on your settings and try again..."
                                                              preferredStyle:UIAlertControllerStyleAlert];
      
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * action) {}];
      
            /*
            UIAlertAction* action = [UIAlertAction actionWithTitle:@"first action" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {}];
            
            UIAlertAction* action2 = [UIAlertAction actionWithTitle:@"second action" style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action) {}];
          
            alert addAction:action];
            [alert addAction:action2];
             */
           [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];

    }
  
}

-(IBAction) openStriatoWebSite {
    //---------------------------------------------------------------------------------------------------------------------------
    
    
     if ( _theOrboDevice.isConnected) {
     [self disconnectTheDevice];
     }
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://openstriato.weebly.com"]];
}

-(IBAction) showInformation {
    //---------------------------------------------------------------------------------------------------------------------------
    
    if ( _theOrboDevice.isConnected) {
        [self disconnectTheDevice];
    }
    [self performSegueWithIdentifier:@"showInformation" sender:self];
}


//-------------------------------------------------------------------------------------------
#pragma mark selectionTableView delegate
//-------------------------------------------------------------------------------------------

- (void)validateDeviceForRow:(int)rowNumber {
    //-------------------------------------------------------------------------------------------
    // ask connexion to device and display the selected device name
    
    self.theBaseNameLabel.text    = [_theOrboDevice connectDeviceSelectedAtRow: rowNumber];
    self.theCardNumberLabel.text  = @"Waiting for tag...";
}


//--------------------------------------------------------------------------------------------
#pragma mark Notification methods
//--------------------------------------------------------------------------------------------

-(void) scanEnded {
    //--------------------------------------------------------------------------------------------
    
    // remove the notification to avoid interferences... : double detection otherwise
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"scanEnded" object:_theOrboDevice];
    
    NSLog(@"Launch device selection table");
    
    self.theInfomationButton.enabled    = YES;
    self.theWebsiteButton.enabled       = YES;
    
    if ( _theOrboDevice.theListOfDiscoveredDevicesArray.count >0) {
       
        [self playSound:@"button-33a"];
        [self performSegueWithIdentifier:@"DeviceSelection" sender:self];
        
    } else {
        
        [self.theButton setImage:_theButtonIsOff forState:UIControlStateNormal];
        self.theButton.enabled = YES;
      
        [self playSound:@"button-33a"];
      
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Ooopsss..."
                                                                     message:@"No base found... Please check the base and try again"
                                                              preferredStyle:UIAlertControllerStyleAlert];
      
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * action) {}];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
      
        
        self.theBaseNameLabel.text    = @"No base connected...";
        self.theCardNumberLabel.text  = @"No base connected...";
    }
    
}

-(void) deviceDidDisconnect {
    //--------------------------------------------------------

    [self playSound:@"button-33a"];
    [self.theButton setImage:_theButtonIsOff forState:UIControlStateNormal];
    self.theButton.enabled            = YES;
    self.theBaseNameLabel.text        = @"No base connected";
    self.theCardNumberLabel.text      = @"No base connected";
    
    //if status was connected, then disconnect was unexpected by the user, show alert
    //display disconnect alert
    
    if (_accidentalDisconnectionWarning) {
      
      
      UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Communication Failed"
                                                                     message:@"BLE peripheral has disconnected"
                                                              preferredStyle:UIAlertControllerStyleAlert];
      
      UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * action) {}];
      [alert addAction:defaultAction];
      [self presentViewController:alert animated:YES completion:nil];
      
    }
    
}

-(void) newCardDetected {
    //--------------------------------------------------------------------------------------------

    [self.theButton setImage:_theButtonHasReceivedRFID forState:UIControlStateNormal];
    // the timer will reconfiure the button to waiting state
    [NSTimer scheduledTimerWithTimeInterval:0.1
                                     target:self
                                   selector:@selector(restoreButtonImageAfterRFIDReceived)
                                   userInfo:nil
                                    repeats:NO];
    
    self.theCardNumberLabel.text = _theOrboDevice.theLastRFIDCardNumber;
    [self playSound:@"button-33a"];
  
    //--------------------------------------------------------------------------------------------
    // Play a random music from the local library
  
    if ( itemsFromMusicQuery.count >0) {
      [self playRandomMusic];
    }
}

-(void) connectionConfirmed {
    //--------------------------------------------------------------------------------------------

    self.theButton.enabled = YES;
    [self.theButton setImage:_theButtonIsWaiting forState:UIControlStateNormal];
    
    NSLog(@"Peripheral connected");
    [self playSound:@"button-33a"];
    self.theCardNumberLabel.text  = @"Waiting for tag...";
    
}


//--------------------------------------------------------------------------------------------
#pragma mark Services Functions
//--------------------------------------------------------------------------------------------


-(void) setAllNotifications {
    //--------------------------------------------------------------------------------------------
    
    
    // Notification for end of scan
    //--------------------------------------------------------------------------------------------
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(scanEnded)
                                                 name:@"scanEnded"
                                               object:_theOrboDevice];
    
    
    
    // Notification for device connection
    //--------------------------------------------------------------------------------------------
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(connectionConfirmed)
                                                 name:@"connectionConfirmed"
                                               object:_theOrboDevice];

    
    // Notification for new card detection
    //--------------------------------------------------------------------------------------------
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(newCardDetected)
                                                 name:@"newCardDetected"
                                               object:_theOrboDevice];
    
    // Listen to notification for device disconnetion while connected
    //--------------------------------------------------------------------------------------------
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceDidDisconnect)
                                                 name:@"DeviceDidDisconnect"
                                               object:_theOrboDevice];

    
}

-(void) playSound: (NSString*) theSoundFileName {
  //---------------------------------------------------------------------------------------------------------------------------
    NSError *err;
    NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:theSoundFileName ofType:@"mp3"];
    NSURL *fileURL          = [[NSURL alloc] initFileURLWithPath:soundFilePath];
    _theBingPlayer          = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:&err];
    _theBingPlayer.delegate = self;
    [_theBingPlayer play];
  
}

-(void) disconnectTheDevice {
    //---------------------------------------------------------------------------------------------------------------------------
    
    _accidentalDisconnectionWarning = false;
    [_theOrboDevice disconnectTheDevice];
    
}

-(void) updateTheProgressView :(NSTimer *)time {
    //---------------------------------------------------------------------------------------------------------------------------

    _theProgressTimerCount++;
    if (_theProgressTimerCount <= (_theOrboDevice.theMaxTimeAllowedForScanning/0.05)) {
        self.theProgressView.progress = (float)_theProgressTimerCount/(_theOrboDevice.theMaxTimeAllowedForScanning/0.05);
    } else {
        [_theProgressTimer invalidate];
        _theProgressTimer = nil;
        _theProgressTimerCount=0;
    }
}

-(void) restoreButtonImageAfterRFIDReceived {
    //---------------------------------------------------------------------------------------------------------------------------
    // after a card detection restore the button in blue
    
    [self.theButton setImage:_theButtonIsWaiting forState:UIControlStateNormal];
}

-(void) playRandomMusic {
  //---------------------------------------------------------------------------------------------------------------------------
  
    // Compute a random number between 0 and itemsFromLMusicQuery.count
    int lowLimit    = 0;
    int highLimit   = (int)itemsFromMusicQuery.count;
    int aMusicIndex;
    MPMediaItem *theSelectedMusic;
    
    // Checking if the music is on iCloud : we want only the music on device
    do {
      aMusicIndex        = lowLimit + arc4random() % (highLimit - lowLimit);
      theSelectedMusic   = [itemsFromMusicQuery objectAtIndex: aMusicIndex];
     // NSLog(@"Random music index : %i", aMusicIndex);
    } while ([[theSelectedMusic valueForProperty:MPMediaItemPropertyIsCloudItem] boolValue]);
    NSLog(@"On device Music index: %i", aMusicIndex);
    
    //display the title on the label
    self.theCardNumberLabel.text = [theSelectedMusic valueForProperty: MPMediaItemPropertyTitle];
    
    // create "unique item" collection
    NSArray * theMusicArrayToPlay         = @[theSelectedMusic];
    
    MPMediaItemCollection * theMusicToPlay = [[MPMediaItemCollection alloc] initWithItems:theMusicArrayToPlay];
    [musicPlayer setQueueWithItemCollection:theMusicToPlay];
    [musicPlayer play];

  
}

//--------------------------------------------------------------------------------------------
#pragma mark segue preparation
//--------------------------------------------------------------------------------------------

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //--------------------------------------------------------------------------------------------
    if ([[segue identifier] isEqualToString:@"DeviceSelection"]) {
        
        SelectionDeviceTableView *selectionTableView = [segue destinationViewController];
        if(selectionTableView) {
            selectionTableView.theDiscoveredDevicesArray  = _theOrboDevice.theListOfDiscoveredDevicesArray;
            selectionTableView.delegate                   = self;
            
        }
    }
}

@end


