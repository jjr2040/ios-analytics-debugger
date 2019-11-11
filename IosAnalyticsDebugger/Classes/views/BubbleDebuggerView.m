//
//  BubbleDebuggerView.m
//  IosAnalyticsDebugger
//
//  Created by Alex Verein on 22/10/2019.
//  Copyright © 2019 Alex Verein. All rights reserved.
//

#import "BubbleDebuggerView.h"
#import "DebuggerEventItem.h"
#import <UIKit/UINib.h>
#import "Util.h"

@interface BubbleDebuggerView ()

@property (weak, nonatomic) IBOutlet UIImageView *bubble;
@property (weak, nonatomic) IBOutlet UIImageView *counterBackground;
@property (weak, nonatomic) IBOutlet UILabel *counter;

@property int eventsCount;

@end

@implementation BubbleDebuggerView

-(instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    
    if (self) {
        [self loadViewFromNib];
    }
    
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self loadViewFromNib];
    }
    
    return self;
}

-(void)loadViewFromNib {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    UINib *nib = [UINib nibWithNibName:@"BubbleDebuggerXIB" bundle:bundle];
    NSArray *views = [nib instantiateWithOwner:self options:nil];
    UIView *view = [views objectAtIndex:0];
    view.frame = self.bounds;
    [self addSubview:view];
    [self showEventCount:0];
}

- (void) showEvent:(DebuggerEventItem *)event {
    [self showEventCount: ++self.eventsCount];
    
    if ([Util eventHaveErrors:event]) {
        [self setError:YES];
    }
}

- (void) onClick {
    [self setError:NO];
    [self showEventCount:0];
}

- (void) setError:(BOOL) hasError {
    NSBundle *selfBundle = [NSBundle bundleForClass:self.class];
    if (hasError) {
        [self.bubble setImage:[UIImage imageNamed:@"avo_bubble_error" inBundle:selfBundle compatibleWithTraitCollection:nil]];
        [self.counterBackground setImage:[UIImage imageNamed:@"badge_white" inBundle:selfBundle compatibleWithTraitCollection:nil]];
        [self.counter setTextColor:[UIColor colorNamed:@"error_color" inBundle:selfBundle compatibleWithTraitCollection:nil]];
    } else {
        [self.bubble setImage:[UIImage imageNamed:@"avo_bubble" inBundle:selfBundle compatibleWithTraitCollection:nil]];
        [self.counterBackground setImage:[UIImage imageNamed:@"badge_green" inBundle:selfBundle compatibleWithTraitCollection:nil]];
        [self.counter setTextColor:[UIColor whiteColor]];
    }
}

- (void) showEventCount: (int) eventCount {
    self.eventsCount = eventCount;
    [self.counter setText:[@(self.eventsCount) stringValue]];
}

@end