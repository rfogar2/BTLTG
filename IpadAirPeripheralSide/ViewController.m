//
//  ViewController.m
//  IpadAirPeripheralSide
//
//  Created by Lukasz Stempniewicz on 5/10/15.
//  Copyright (c) 2015 Lukasz Stempniewicz. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *initializeButton;
@property (weak, nonatomic) IBOutlet UITextView *centralConnectionLogText;
@property (weak, nonatomic) IBOutlet UITextView *generalLogText;
@end

@implementation ViewController
- (IBAction)initializeButtonPressed:(id)sender
{
    //Clears Logs
    self.centralConnectionLogText.text = @"";
    self.generalLogText.text = @"";
    
    //Disables button
    self.initializeButton.enabled = NO;
    
    [self initializeConnection];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)updateMacMiniCentralLog:(NSString*)appendingString
{
    NSString* updatedAppendingString = [@"\n" stringByAppendingString:appendingString];
    NSString* newText = [self.centralConnectionLogText.text stringByAppendingString: updatedAppendingString];
    self.centralConnectionLogText.text = newText;
    NSRange range = NSMakeRange(self.centralConnectionLogText.text.length - 1, 1);
    [self.centralConnectionLogText scrollRangeToVisible:range];
}

-(void)updateGeneralLog:(NSString*)appendingString
{
    NSString* updatedAppendingString = [@"\n" stringByAppendingString:appendingString];
    NSString* newText = [self.generalLogText.text stringByAppendingString: updatedAppendingString];
    self.generalLogText.text = newText;
    NSRange range = NSMakeRange(self.generalLogText.text.length - 1, 1);
    [self.generalLogText scrollRangeToVisible:range];
}

- (void)initializeConnection
{
    [self updateMacMiniCentralLog:@"Initializing connection with mac mini central device"];

}

@end
