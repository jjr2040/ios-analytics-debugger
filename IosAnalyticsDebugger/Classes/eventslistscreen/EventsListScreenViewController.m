//
//  EventsListScreenViewController.m
//  IosAnalyticsDebugger
//
//  Created by Alex Verein on 30/10/2019.
//  Copyright © 2019 Alex Verein. All rights reserved.
//

#import "EventsListScreenViewController.h"
#import "EventTableViewCell.h"
#import "AnalyticsDebugger.h"
#import "Util.h"

@interface EventsListScreenViewController ()

@property (weak, nonatomic) IBOutlet UIView *closeButton;
@property (weak, nonatomic) IBOutlet UITableView *eventsTableView;

@property (strong, nonatomic) NSMutableSet *expendedEvents;

@end

@implementation EventsListScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITableView * __weak weakTableView = self.eventsTableView;
    [AnalyticsDebugger setOnNewEventCallback:^(DebuggerEventItem * _Nonnull item) {
        [weakTableView reloadData];
    }];
   
    [self.closeButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissSelf)]];
    
    self.expendedEvents = [NSMutableSet new];
    [self populateExpended];
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    UINib *eventItemNib = [UINib nibWithNibName:@"EventTableViewCell" bundle:bundle];
      
    [self.eventsTableView registerNib:eventItemNib forCellReuseIdentifier:@"EventTableViewCell"];
}

- (void) viewDidAppear:(BOOL)animated {
    [self.eventsTableView setDelegate:self];
    [self.eventsTableView setDataSource:self];
      
    self.eventsTableView.tableFooterView = [UIView new];
}

- (void)dealloc {
    [AnalyticsDebugger setOnNewEventCallback:nil];
}

- (void) populateExpended {
    
    for (int i = 0; i < [AnalyticsDebugger.events count]; i++) {
        DebuggerEventItem *event = [AnalyticsDebugger.events objectAtIndex:i];
        if (i == 0 || [Util eventHaveErrors:event]) {
            [self.expendedEvents addObject:event];
        }
    }
}

- (void) dismissSelf {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    EventTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"EventTableViewCell" forIndexPath:indexPath];
    cell.eventsListScreenViewController = self;
    [cell populateWithEvent:[AnalyticsDebugger.events objectAtIndex:indexPath.row]];
    
    if ([self.expendedEvents containsObject:cell.event]) {
        [cell expend];
    } else {
        [cell collapse];
    }
    
    [cell showError:[Util eventHaveErrors:cell.event]];
 
    [self showFullLengthSeparators:cell];
    
    return cell;
}

- (void)showFullLengthSeparators:(EventTableViewCell *)cell {
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = [AnalyticsDebugger.events count];
    return count;
}

- (void) setExpendedStatus:(BOOL) expended forEvent:(DebuggerEventItem *) event  {
    if (expended) {
        [self.expendedEvents addObject:event];
    } else {
        [self.expendedEvents removeObject:event];
    }
    
    [self.eventsTableView reloadData];
}

@end