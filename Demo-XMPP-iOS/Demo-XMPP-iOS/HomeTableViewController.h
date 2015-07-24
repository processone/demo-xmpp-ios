//
//  ViewController.h
//  XmppDemoClientiOS
//
//  Created by Paul on 22/07/2015.
//  Copyright © 2015 ProcessOne. All rights reserved.
//

@import UIKit;

#import "AppDelegate.h"

@interface HomeTableViewController : UITableViewController<UITableViewDelegate, UITableViewDataSource, ChatDelegate> {
	NSMutableArray *onlineBuddies;
}


@end

