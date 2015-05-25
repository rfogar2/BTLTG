//
//  AppDelegate.m
//  MacMiniCentralSide
//
//  Created by Lukasz Stempniewicz on 5/14/15.
//  Copyright (c) 2015 Lukasz Stempniewicz. All rights reserved.
//

#import "AppDelegate.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface AppDelegate () <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (strong, nonatomic) CBCentralManager      *myCentralManager;
@property (strong, nonatomic) CBPeripheral          *discoveredPeripheral;
@property (strong, nonatomic) NSMutableData         *data;

@end

@implementation AppDelegate

@synthesize myCentralManager = _myCentralManager, discoveredPeripheral = _discoveredPeripheral, data = _data;

/*****************************************\
|*---------core bluetooth methods--------*|
\*****************************************/

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    // Determine the state of the peripheral
    if ([central state] == CBCentralManagerStatePoweredOff) {
        NSLog(@"CoreBluetooth BLE hardware is powered off");
    }
    else if ([central state] == CBCentralManagerStatePoweredOn) {
        NSLog(@"CoreBluetooth BLE hardware is powered on and ready");
        
        NSLog(@"Scanning for advertising peripheral devices..");
        //Will scan for peripheral devices that are advertising
        [_myCentralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:@"4732CA16-1009-4E0A-AC8E-9E8CC2A68A24"]] options:nil];
    }
    else if ([central state] == CBCentralManagerStateUnauthorized) {
        NSLog(@"CoreBluetooth BLE state is unauthorized");
    }
    else if ([central state] == CBCentralManagerStateUnknown) {
        NSLog(@"CoreBluetooth BLE state is unknown");
    }
    else if ([central state] == CBCentralManagerStateUnsupported) {
        NSLog(@"CoreBluetooth BLE hardware is unsupported on this platform");
    }
}

-(void)startInitialization;
{
    NSLog(@"Creating myCentralManager..");
    _myCentralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
    
}

-(void)centralManager:(CBCentralManager *)central
didDiscoverPeripheral:(CBPeripheral *)peripheral
    advertisementData:(NSDictionary *)advertisementData
                 RSSI:(NSNumber *)RSSI
{
    NSLog(@"Discovered %@ at %@", peripheral.name, RSSI);
    
    [_myCentralManager stopScan];
    NSLog(@"Scanning Stopped, Ipad air was found!");
    
    if (self.discoveredPeripheral != peripheral) {
        
        // Save a local copy of the peripheral, so CoreBluetooth doesn't get rid of it
        self.discoveredPeripheral = peripheral;
        
        // And connect
        NSLog(@"Connecting to peripheral %@", peripheral);
        
        
        
        [self.myCentralManager connectPeripheral:peripheral options:nil];
    }
    
}

/** If the connection fails for whatever reason, we need to deal with it.
 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Failed to connect to %@. (%@)", peripheral, [error localizedDescription]);
}

/** We've connected to the peripheral, now we need to discover the services and characteristics to find the 'transfer' characteristic.
 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"Peripheral Connected");
    
    NSLog(@"Scanning stopped");
    
    // Clear the data that we may already have
    [self.data setLength:0];
    
    // Make sure we get the discovery callbacks
    peripheral.delegate = self;
    
    // Search only for services that match our UUID
    [peripheral discoverServices:@[[CBUUID UUIDWithString:@"4732CA16-1009-4E0A-AC8E-9E8CC2A68A24"]]];
}


/** The Service was discovered
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error) {
        NSLog(@"Error discovering services: %@", [error localizedDescription]);
        return;
    }
    
    // Discover the characteristic we want...
    NSLog(@"Discovered some service");
    // Loop through the newly filled peripheral.services array, just in case there's more than one.
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:@"E4AE0854-E6F7-46BD-99DE-51A9B9049E8B"]] forService:service];
        //
    }
}

/** The characteristic was discovered.
 *  Once this has been found, we want to subscribe to it, which lets the peripheral know we want the data it contains
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    NSLog(@"Discovering characteristics");
    
    // Deal with errors (if any)
    if (error) {
        NSLog(@"Error discovering characteristics: %@", [error localizedDescription]);
        return;
    }
    
    // Again, we loop through the array, just in case.
    for (CBCharacteristic *characteristic in service.characteristics) {
        
        // And check if it's the right one
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"E4AE0854E6F7-46BD-99DE-51A9B9049E8B"]])
        {
            NSLog(@"Found a desired Characteristic!!!!!!!!");
            // If it is, subscribe to it
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
    }
    
    // Once this is complete, we just need to wait for the data to come in.
}





/*****************************************\
|*------Default app delegate methods-----*|
\*****************************************/

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    [self startInitialization];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
