//
//  EventTableViewCell.m
//  IosAnalyticsDebugger
//
//  Created by Alex Verein on 30/10/2019.
//  Copyright © 2019 Alex Verein. All rights reserved.
//

#import "EventTableViewCell.h"
#import "Util.h"
#import "DebuggerProp.h"
#import "EventTableViewSecondaryCell.h"
#import "DebuggerMessage.h"

@interface EventTableViewCell()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *additionalRowsHeight;
@property (weak, nonatomic) IBOutlet UIImageView *expendCollapseImage;
@property (weak, nonatomic) IBOutlet UIView *mainRow;
@property (weak, nonatomic) IBOutlet UIImageView *statusIcon;
@property (weak, nonatomic) IBOutlet UILabel *eventName;
@property (weak, nonatomic) IBOutlet UILabel *timestamp;
@property (weak, nonatomic) IBOutlet UITableView *additionalRows;

@property (nonatomic, readwrite) NSInteger additionalRowsExpendedHeight;

@end

@implementation EventTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.mainRow addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleExpend)]];
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    UINib *eventSecondatyRowItemNib = [UINib nibWithNibName:@"EventTableViewSecondaryCell" bundle:bundle];
    [self.additionalRows registerNib:eventSecondatyRowItemNib forCellReuseIdentifier:@"EventTableViewSecondaryCell"];
    [self.additionalRows setDataSource:self];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void) toggleExpend {
    if (self.additionalRowsHeight.constant == 0) {
        [self expend];
    } else {
        [self collapse];
    }
    
    [self.eventsListScreenViewController setExpendedStatus:[self expended] forEvent:self.event];
}

- (BOOL) expended {
    return !self.additionalRows.hidden;
}

- (void) expend {
    if (![self expended]) {
        self.additionalRowsHeight.constant = self.additionalRowsExpendedHeight;
        self.additionalRows.hidden = false;
       
        [self layoutIfNeeded];
        [self setNeedsUpdateConstraints];
        
        [self.expendCollapseImage setImage:[UIImage imageNamed:@"collapse_arrow" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil]];
    }
}

- (void) collapse {
    if ([self expended]) {
        self.additionalRowsHeight.constant = 0;
        self.additionalRows.hidden = true;
        
        [self layoutIfNeeded];
        [self setNeedsUpdateConstraints];
        
        [self.expendCollapseImage setImage:[UIImage imageNamed:@"expend_arrow" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil]];
    }
}

- (void) showError:(BOOL) isError {
    NSBundle *selfBundle = [NSBundle bundleForClass:self.class];
    if (isError) {
        [self.eventName setTextColor:[UIColor colorNamed:@"error_color" inBundle:selfBundle compatibleWithTraitCollection:nil]];
        [self.statusIcon setImage:[UIImage imageNamed:@"red_warning" inBundle:selfBundle compatibleWithTraitCollection:nil]];
    } else {
        [self.eventName setTextColor:[UIColor blackColor]];
        [self.statusIcon setImage:[UIImage imageNamed:@"tick" inBundle:selfBundle compatibleWithTraitCollection:nil]];
    }
}

- (void)calculateExpendedAdditionalRowsHeight {
    NSInteger count = [self.event.eventProps count] + [self.event.userProps count];
    self.additionalRowsExpendedHeight = 32 * count + 8;
    
    for (DebuggerProp *prop in self.event.eventProps) {
        for (int i = 0; i < [self.event.messages count]; i++) {
            DebuggerMessage *messageData = [self.event.messages objectAtIndex:i];
            if (messageData.propertyId == prop.id) {
                self.additionalRowsExpendedHeight += 28;
                break;
            }
        }
    }
}

- (void) populateWithEvent: (DebuggerEventItem *)event {
    self.event = event;
    
    [self.eventName setText:[event name]];
    [self.timestamp setText:[Util timeString:event.timestamp]];
    
    [self calculateExpendedAdditionalRowsHeight];
    
    if ([self expended]) {
        self.additionalRowsHeight.constant = self.additionalRowsExpendedHeight;
        self.additionalRows.hidden = false;
          
        [self layoutIfNeeded];
        [self setNeedsUpdateConstraints];
    }
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    EventTableViewSecondaryCell * cell = [tableView dequeueReusableCellWithIdentifier:@"EventTableViewSecondaryCell" forIndexPath:indexPath];
    
    DebuggerProp *prop = nil;
    if (indexPath.row < [self.event.eventProps count]) {
        prop = [self.event.eventProps objectAtIndex:indexPath.row];
    } else if (indexPath.row < [self.event.eventProps count] + [self.event.userProps count]) {
       prop = [self.event.userProps objectAtIndex:(indexPath.row - [self.event.eventProps count])];
    }
    
    if (prop != nil) {
        [cell populateWithProp:prop];
    }
    
    for (int i = 0; i < [self.event.messages count]; i++) {
        DebuggerMessage *messageData = [self.event.messages objectAtIndex:i];
        if (messageData.propertyId == prop.id) {
            [cell showError:[self formatErrorMessage:messageData propertyName:prop.name]];
            
            break;
        }
    }
    
    return cell;
}

- (NSAttributedString *) formatErrorMessage:(DebuggerMessage *)messageData propertyName:(NSString *)propName {
    if (messageData.allowedTypes == nil || [messageData.allowedTypes count] == 0
            || messageData.providedType == nil || messageData.providedType.length == 0) {
        return [[NSAttributedString alloc] initWithString:messageData.message];
    }
    
    const CGFloat fontSize = 11;
    NSDictionary *bold = @{
        NSFontAttributeName:[UIFont boldSystemFontOfSize:fontSize]
    };
    
    NSMutableAttributedString *attributedText =
      [[NSMutableAttributedString alloc] initWithString:messageData.message];
    [attributedText setAttributes:bold range:[messageData.message rangeOfString:propName]];
    
    for (NSString *allowedType in messageData.allowedTypes) {
        [attributedText setAttributes:bold range:[messageData.message rangeOfString:allowedType]];
    }
    
    [attributedText setAttributes:bold range:[messageData.message rangeOfString:messageData.providedType]];
    
    return attributedText;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = [self.event.eventProps count] + [self.event.userProps count];
    return count;
}

@end