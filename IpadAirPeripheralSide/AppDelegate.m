//
//  AppDelegate.m
//  IpadAirPeripheralSide
//
//  Created by Lukasz Stempniewicz on 5/10/15.
//  Copyright (c) 2015 Lukasz Stempniewicz. All rights reserved.
//

#import "AppDelegate.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface AppDelegate () <CBPeripheralManagerDelegate>

@property (strong, nonatomic) CBPeripheralManager* myPeripheralManager;
@property (strong, nonatomic) CBUUID* ipadServiceUUID;         //4732CA16-1009-4E0A-AC8E-9E8CC2A68A24
@property (strong, nonatomic) CBUUID* ipadCharacteristic1UUID; //E4AE0854-E6F7-46BD-99DE-51A9B9049E8B
@property (strong, nonatomic) CBUUID* ipadCharacteristic2UUID; //351AE866-1B8D-433D-A95E-6AA2BC3A3451
@property (strong, nonatomic) CBMutableService* ipadService;
@property (strong, nonatomic) CBMutableCharacteristic* ipadCharacteristic1;
@property (strong, nonatomic) CBMutableCharacteristic* ipadCharacteristic2;

@property (strong, nonatomic) NSData* myData1;
@property (strong, nonatomic) NSData* myData2;

@end

@implementation AppDelegate

@synthesize myPeripheralManager = _myPeripheralManager;

/*****************************************\
|*---------core bluetooth methods--------*|
\*****************************************/

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    if([peripheral state] == CBPeripheralManagerStateUnknown)
    {
        NSLog(@"CoreBluetooth BLE state is unknown");
    }
    else if([peripheral state] == CBPeripheralManagerStateResetting)
    {
        NSLog(@"CoreBluetooth BLE state is resetting");
    }
    else if([peripheral state] == CBPeripheralManagerStateUnsupported)
    {
        NSLog(@"CoreBluetooth BLE state is unsupported");
    }
    else if([peripheral state] == CBPeripheralManagerStateUnauthorized)
    {
        NSLog(@"CoreBluetooth BLE state is unauthorized");
    }
    else if([peripheral state] == CBPeripheralManagerStatePoweredOff)
    {
        NSLog(@"CoreBluetooth BLE state is powered off");
    }
    else if([peripheral state] == CBPeripheralManagerStatePoweredOn)
    {
        NSLog(@"CoreBluetooth BLE state is powered on and ready");
        //Will start advertising
        NSLog(@"Advertising Data..");
        [_myPeripheralManager startAdvertising:@{ CBAdvertisementDataServiceUUIDsKey : @[_ipadService.UUID] }];
        //Should call peripheralManagerDidStartAdvertising
        
    }
    else {}
}

-(void)startInitialization;
{
    NSLog(@"Creating myData1 and myData2..");
    //Data to be sent
    _myData1 = [@"Hello1" dataUsingEncoding:NSASCIIStringEncoding];
    _myData2 = [@"Hello2" dataUsingEncoding:NSASCIIStringEncoding];
    NSLog(@"Sucess!");
    
    //Creating the peripheral manager,
    //which then automatically calls peripheralManagerDidUpdateState
    NSLog(@"Creating myPeripheralManager..");
    _myPeripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:nil];
    NSLog(@"Sucess!");
    
    //Creating random UUIDs
    NSLog(@"Creating UUIDs for services/characteristics..");
    _ipadServiceUUID = [CBUUID UUIDWithString:@"4732CA16-1009-4E0A-AC8E-9E8CC2A68A24"];
    _ipadCharacteristic1UUID = [CBUUID UUIDWithString:@"E4AE0854-E6F7-46BD-99DE-51A9B9049E8B"];
    _ipadCharacteristic2UUID = [CBUUID UUIDWithString:@"351AE866-1B8D-433D-A95E-6AA2BC3A3451"];
    NSLog(@"Sucess!");
    
    //!!!Will only create and use the first UUID for now!!!
    NSLog(@"Creating characteristics..");
    _ipadCharacteristic1 = [[CBMutableCharacteristic alloc] initWithType:_ipadCharacteristic1UUID properties:CBCharacteristicPropertyRead value:_myData1 permissions:CBAttributePermissionsReadable];
    NSLog(@"Sucess!");
    
    //Creating the ipad service
    NSLog(@"Creating the service..");
    _ipadService = [[CBMutableService alloc] initWithType:_ipadServiceUUID primary:YES];
    
    NSLog(@"Sucess!");
    
    //Setting characteristic values
    NSLog(@"Linking characteristic to service..");
    //!!!Only linking the first characteristic for now!!!
    _ipadService.characteristics = @[_ipadCharacteristic1];
    NSLog(@"Sucess!");
    
    //Adding the service to the device's database
    NSLog(@"Publishing the service/characteristics to device's database..");
    [_myPeripheralManager addService:_ipadService];
    //Should call didAddService method
    NSLog(@"Initialization finished");
    
}

-(void)peripheralManager:(CBPeripheralManager *)peripheral
           didAddService:(CBService *)service
                   error:(NSError *)error
{
    if(error)
    {
        NSLog(@"Error publishing service: %@", [error localizedDescription]);
    }
    else
    {
        NSLog(@"Sucess adding service!");
    }
}

-(void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral
                                      error:(NSError *)error
{
    if(error)
    {
        NSLog(@"Error advertising: %@", [error localizedDescription]);
    }
    else
    {
        NSLog(@"Advertising successfully!");
    }
}

//TO-DO: Implement the rest of the peripheral-side methods
//       -Methods to respond to read, write, and subscription requests



/*****************************************\
|*------Default app delegate methods-----*|
\*****************************************/
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //Entry point for core bluetooth functionality
    [self startInitialization];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
