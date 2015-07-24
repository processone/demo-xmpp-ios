//
//  ViewController.m
//  XmppDemoClientiOS
//
//  Created by Paul on 22/07/2015.
//  Copyright © 2015 ProcessOne. All rights reserved.
//

#import "HomeTableViewController.h"

@interface HomeTableViewController ()

@end

@implementation HomeTableViewController

#pragma mark == LIFE CYCLE ==
/* Setup ivar and delegates */
- (void)viewDidLoad {
	[super viewDidLoad];
	
	((AppDelegate *)[[UIApplication sharedApplication] delegate]).chatDelegate = self;
	onlineBuddies = [NSMutableArray new];
}

/* Present the Login view if the user isn't connected */
- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"userID"]) {
		if ([((AppDelegate *)[[UIApplication sharedApplication] delegate]) connect]) {
			self.title = [[[((AppDelegate *)[[UIApplication sharedApplication] delegate]) xmppStream] myJID] bare];
			[((AppDelegate *)[[UIApplication sharedApplication] delegate]).xmppRoster fetchRoster];
		}
	} else {
		[self performSegueWithIdentifier:@"Home.To.Login" sender:self];
	}
}

#pragma mark == TABLEVIEW DATASOURCE ==

/* Returns the number of online buddies */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [onlineBuddies count];
}

/* We only want to display online buddies, so we return 1 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

#pragma mark == TABLEVIEW DELEGATES ==

/* Set name of buddy in the cell's textLabel */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *CellIdentifier = @"cellIdentifier";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
	
	cell.textLabel.text = [onlineBuddies objectAtIndex:indexPath.row];

	return cell;
}

/* Send a message (Yo!) to the user */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Warning !" message:@"It will send Yo! to the recipient, continue ?" preferredStyle:UIAlertControllerStyleAlert];
	
	[alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
		[alertController dismissViewControllerAnimated:true completion:nil];
	}]];
	
	[alertController addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
		NSString *message = @"Yo!";
		
		XMPPJID *senderJid = [XMPPJID jidWithString:[onlineBuddies objectAtIndex:indexPath.row]];
		XMPPMessage* msg = [[XMPPMessage alloc] initWithType:@"chat" to:senderJid];
		[msg addBody:message];
		
		[((AppDelegate *)[[UIApplication sharedApplication] delegate]).xmppStream sendElement:msg];
	}]];

	[self presentViewController:alertController animated:true completion:nil];
}

#pragma mark == CHAT DELEGATES ==

/* Update the datasource when a new buddy went online */
- (void)buddyWentOnline:(NSString *)name {
	if (![onlineBuddies containsObject:name]) {
		[onlineBuddies addObject:name];
		[self.tableView reloadData];
	}
}

/* Update the datasource when a new buddy went offline */
- (void)buddyWentOffline:(NSString *)name {
	[onlineBuddies removeObject:name];
	[self.tableView reloadData];
}

/* Empty the datasource and reload if the stream is disconnected */
- (void)didDisconnect {
	[onlineBuddies removeAllObjects];
	[self.tableView reloadData];
}

#pragma mark == MEMORY MANAGEMENT ==

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
