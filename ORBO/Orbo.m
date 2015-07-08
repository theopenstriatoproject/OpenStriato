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





/*
 
 
 - (BOOL) isLECapableHardware  /// CHECK THE CAPABILITIES IN PLIST FILE VF PAGE 75 MYLOCATION
 {
 NSString * state = nil;
 
 switch ([self.manager state])
 {
 case CBCentralManagerStateUnsupported:
 state = @"The platform/hardware doesn't support Bluetooth Low Energy.";
 break;
 case CBCentralManagerStateUnauthorized:
 state = @"The app is not authorized to use Bluetooth Low Energy.";
 break;
 case CBCentralManagerStatePoweredOff:
 state = @"Bluetooth is currently powered off.";
 break;
 case CBCentralManagerStatePoweredOn:
 [self startScan];
 return TRUE;
 case CBCentralManagerStateUnknown:
 default:
 return FALSE;
 
 }
 
 */

#import "Orbo.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface Orbo () {
  //--------------------------------------------------------------------------------------------
  // Variables
  //--------------------------------------------------------------------------------------------
 
    CBCentralManager      *_theCentralManager;

 
    CBUUID              *_kLightBlueScratchServiceUUID;
    CBUUID              *_kLightBlueScratch1CharacteristicUUID;
    CBUUID              *_kLightBlueScratch2CharacteristicUUID;
    CBUUID              *_kLightBlueScratch3CharacteristicUUID;
    CBUUID              *_kLightBlueScratch4CharacteristicUUID;
    CBUUID              *_kLightBlueScratch5CharacteristicUUID;
    
    CBUUID              *_kAdafruitUARTServiceUUID;
    CBUUID              *_kAdafruitTXCharacteristicUUID;
    CBUUID              *_kAdafruitRXCharacteristicUUID;
    
    CBUUID              *_theRFIDNumberCharacteristic;
    
    NSArray             *_theServicesToCheck;
    NSArray             *_theCharacteristicsToFind;
    //NSMutableArray      *_theDiscoveredDevicesArray;
    NSMutableArray      *_theListOfDiscoveredDevicesArray;
    
    NSString            *_theDetectedCardNumber;
    
    CBPeripheral        *_thePeripheralToWorkWith;
    
    bool                _isConnected;
    bool                _isScanning;
    bool                _bluetoothIsEnabled;
    int                 _theMaxTimeAllowedForScanning;
    
    
 
}

//--------------------------------------------------------------------------------------------

@end

@implementation Orbo

//--------------------------------------------------------------------------------------------
# pragma mark - Initialization
//--------------------------------------------------------------------------------------------

-(id) init {
    
    if ( self =[super init] ) {

    //--------------------------------------------------------------------------------------------
    // Max time setup for discovering devices
    //--------------------------------------------------------------------------------------------
    _theMaxTimeAllowedForScanning   = 2; // seconds


    //--------------------------------------------------------------------------------------------
    // Light Blue Bean Constants
    //--------------------------------------------------------------------------------------------

        _kLightBlueScratchServiceUUID         = [CBUUID UUIDWithString:@"A495FF20-C5B1-4B44-B512-1370F02D74DE"];
        _kLightBlueScratch1CharacteristicUUID = [CBUUID UUIDWithString:@"A495FF21-C5B1-4B44-B512-1370F02D74DE"];
        _kLightBlueScratch2CharacteristicUUID = [CBUUID UUIDWithString:@"A495FF22-C5B1-4B44-B512-1370F02D74DE"];
        _kLightBlueScratch3CharacteristicUUID = [CBUUID UUIDWithString:@"A495FF23-C5B1-4B44-B512-1370F02D74DE"];
        _kLightBlueScratch4CharacteristicUUID = [CBUUID UUIDWithString:@"A495FF24-C5B1-4B44-B512-1370F02D74DE"];
        _kLightBlueScratch5CharacteristicUUID = [CBUUID UUIDWithString:@"A495FF25-C5B1-4B44-B512-1370F02D74DE"];

    //--------------------------------------------------------------------------------------------
    // ADAFRUIT BTLE  Constants
    //--------------------------------------------------------------------------------------------

        _kAdafruitUARTServiceUUID             = [CBUUID UUIDWithString:@"6E400001-B5A3-F393-E0A9-E50E24DCCA9E"];
        _kAdafruitTXCharacteristicUUID        = [CBUUID UUIDWithString:@"6E400002-B5A3-F393-E0A9-E50E24DCCA9E"];
        _kAdafruitRXCharacteristicUUID        = [CBUUID UUIDWithString:@"6E400003-B5A3-F393-E0A9-E50E24DCCA9E"];

    //--------------------------------------------------------------------------------------------
    // Airboard Constants
    //--------------------------------------------------------------------------------------------
    //........

    //--------------------------------------------------------------------------------------------
    // Array of services corresponding to te BLE boards used in the device
    //--------------------------------------------------------------------------------------------

        _theServicesToCheck = @[_kAdafruitUARTServiceUUID, _kLightBlueScratchServiceUUID];
      
    //--------------------------------------------------------------------------------------------
    // Array of discovered devices
    //--------------------------------------------------------------------------------------------
    
        self.theListOfDiscoveredDevicesArray  = [[NSMutableArray alloc] initWithCapacity:5];
        
    //--------------------------------------------------------------------------------------------
    // Connection initialization
    //--------------------------------------------------------------------------------------------
    
        _isConnected        = false;
        _theCentralManager  = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:@{CBCentralManagerOptionShowPowerAlertKey: @(NO)}];
        
        return self;
            
        } else {
            return nil;
        }
}


//--------------------------------------------------------------------------------------------
# pragma mark - CB Delegate methods
//--------------------------------------------------------------------------------------------

- (void) centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI {
    //--------------------------------------------------------------------------------------------
    
   // NSInteger testIndexValue = [_theDiscoveredDevicesArray indexOfObject:peripheral];
    NSInteger testIndexValue = [self.theListOfDiscoveredDevicesArray indexOfObject:peripheral];
    
    //if ((NSNotFound == testIndexValue) && ( _theDiscoveredDevicesArray.count < _theMaxDevicesNumberAllowed)) {
    
    if (NSNotFound == testIndexValue) {
      
      if ( peripheral.name != nil ) {
      
        NSLog(@"Discovered device name : %@", peripheral.name);
        NSLog(@"Discovered device UUID : %@", peripheral.identifier);
        NSLog(@"Discovered device RSSI : %i", [RSSI intValue]);
        
        [self.theListOfDiscoveredDevicesArray addObject:peripheral];
        
        NSLog(@"Number of discovered devices : %lu", (unsigned long)self.theListOfDiscoveredDevicesArray.count);
       //   NSLog(@"Number of discovered devices : %i", self.theListOfDiscoveredDevicesArray.count);
          // generate an error message

        
      } else {
        // device name returns null ( Apple TV ! )
        
        [self.theListOfDiscoveredDevicesArray removeLastObject];
        NSLog(@"Unamed base removed ! ");
        }
        
    }
    
}

- (void) centralManagerDidUpdateState: (CBCentralManager *)central  {
    //--------------------------------------------------------------------------------------------
    
    _bluetoothIsEnabled =  (([central state] == CBCentralManagerStatePoweredOn));
    
    
}

- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    //--------------------------------------------------------------------------------------------
    
    peripheral.delegate = self;
    _isConnected    = true;
    NSLog(@"Searching services......");
    [_thePeripheralToWorkWith discoverServices: _theServicesToCheck];
}

- (void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    //--------------------------------------------------------------------------------------------
    
    for (CBService *service in peripheral.services) {
        NSLog(@"Service : %@", service.UUID);
        [peripheral discoverCharacteristics:_theCharacteristicsToFind forService:service];
        
    }
}

- (void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    //--------------------------------------------------------------------------------------------
    
    for (CBCharacteristic *characteristic in service.characteristics) {
        
        NSLog(@"Characteristic : %@", characteristic.UUID);
        // Subscribing to the RX characteristic only. Normally there is only one due to the array used in precedent function, but
        // just to be certain, the if....
        if ( [characteristic.UUID isEqual:_kLightBlueScratch1CharacteristicUUID] || [characteristic.UUID isEqual:_kAdafruitRXCharacteristicUUID] ) {
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            _isConnected = true;
            
            // Broadcast the connection confirmation
            // this confirmation is sent when :
            // - device has been connected
            // - (the services have been discovered) AND ( the characteristic has been checked)
            //-----------------------------------------------------------------
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"connectionConfirmed"
                                                                object:self
                                                              userInfo:nil];
          
        }
    }
}

- (void) peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    //--------------------------------------------------------------------------------------------

    NSData *newData = characteristic.value;
    
    NSLog(@"Raw data : %@",newData);
    
    //convert data to string & replace characters we can't display - From Adafruit
    int dataLength = (int)newData.length;
    uint8_t data[dataLength];
    
    [newData getBytes:&data length:dataLength];
    
    for (int i = 0; i<dataLength; i++) {
        
        if ((data[i] <= 0x1f) || (data[i] >= 0x80)) {    //null characters
            if ((data[i] != 0x9) && //0x9 == TAB
                (data[i] != 0xa) && //0xA == NL
                (data[i] != 0xd)) { //0xD == CR
                data[i] = 0x20;           // trailings As
            }
        }
    }
    

    _theDetectedCardNumber = [[NSString alloc]initWithBytes:&data length:dataLength encoding:NSUTF8StringEncoding];
    
    NSLog(@"Decoded Data : %@",_theDetectedCardNumber);
    
    
    // Broadcast the new RFID card detection
    //-----------------------------------------------------------------
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"newCardDetected"
                                                        object:self
                                                      userInfo:nil];

    
}

- (void) centralManager:(CBCentralManager*)central didDisconnectPeripheral:(CBPeripheral*)peripheral error:(NSError*)error{
    //----------------------------------------------------------------------
    
    NSLog(@"Did disconnect peripheral %@", peripheral.name);
    
    _isConnected = false;
    [_theCentralManager cancelPeripheralConnection:_thePeripheralToWorkWith];
    
    // Broadcast disconnection
    //--------------------------------------------------------------------
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DeviceDidDisconnect"
                                                        object:self
                                                      userInfo:nil];
    
}

//----------------------------------------------------------------------
#pragma mark - Private  methods
//----------------------------------------------------------------------

-(void) endOfScan {
    //-----------------------------------------------------------------
    
    [_theCentralManager stopScan];
    _isScanning = false;
    NSLog(@"Scanning stopped");
    
    // Broadcast the end of scan notification
    //-----------------------------------------------------------------

    [[NSNotificationCenter defaultCenter] postNotificationName:@"scanEnded"
                                                        object:self
                                                    userInfo:nil];
}


//----------------------------------------------------------------------
#pragma mark - Public methods
//----------------------------------------------------------------------


-(void) startScanning {
    //----------------------------------------------------------------------
    // Scan Bluetooth devices
    
    _isScanning = true;
    
    //Array re initialization
    [self.theListOfDiscoveredDevicesArray  removeAllObjects];
    [_theCentralManager scanForPeripheralsWithServices:nil options:nil];
    
    // Timer for scanning span
    //-----------------------------------------------------------------
    
    NSLog(@"Start timer ");
    [NSTimer scheduledTimerWithTimeInterval:_theMaxTimeAllowedForScanning
                                     target:self
                                   selector:@selector(endOfScan)
                                   userInfo:nil
                                    repeats:NO];
}

-(NSString*) connectDeviceSelectedAtRow: (int) row {
    //----------------------------------------------------------------------
    // Connect to the device selected and return the devices's name
    
    _thePeripheralToWorkWith        = [self.theListOfDiscoveredDevicesArray objectAtIndex:row];
    [_theCentralManager connectPeripheral:_thePeripheralToWorkWith options:nil];
    
    return _thePeripheralToWorkWith.name;
}

-(void) disconnectTheDevice {
    //----------------------------------------------------------------------

    [_theCentralManager cancelPeripheralConnection:_thePeripheralToWorkWith];
}


-(void) startDiscoverServices {
    //------------------------------------------------
    // Services to look for : LightBlueBean, Adafruit
    //------------------------------------------------
    
    [_thePeripheralToWorkWith discoverServices: _theServicesToCheck];
}

/*
-(NSArray*)  listOfDiscoverdDevicesArray {
    //----------------------------------------------------------------------
    return self.theListOfDiscoveredDevicesArray;
}

-(NSString*)readLastRFIDCardNumber {
    //----------------------------------------------------------------------
  
    return _theDetectedCardNumber;
    
}
*/

@end
