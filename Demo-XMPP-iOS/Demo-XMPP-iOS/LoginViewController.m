//
//  LoginViewController.m
//  XmppDemoClientiOS
//
//  Created by Paul on 22/07/2015.
//  Copyright © 2015 ProcessOne. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

#pragma mark == LIFE CYCLE ==

/* Set up UI */
- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark == IBACTIONS ==

/* Will store the textfield's values and try to connect */
- (IBAction)connect:(id)sender {
	[[NSUserDefaults standardUserDefaults] setObject:self.loginTextField.text forKey:@"userID"];
	[[NSUserDefaults standardUserDefaults] setObject:self.passwordTextField.text forKey:@"userPassword"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	if ([(AppDelegate *)[UIApplication sharedApplication].delegate connect]) {
		[self dismissViewControllerAnimated:true completion:nil];
	} else {
		//Handle error
	}
}

/* Will dismsiss the VC */
- (IBAction)done:(id)sender {
	[self dismissViewControllerAnimated:true completion:nil];
}

#pragma mark == MEMORY MANAGEMENT ==

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
