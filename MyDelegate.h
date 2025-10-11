#pragma once

#import <Cocoa/Cocoa.h>

@interface MyDelegate : NSObject <NSApplicationDelegate>

@property (strong, nonatomic) NSStatusItem *item;
@property (strong, nonatomic) NSPopover *popover;
@property (strong, nonatomic) NSTextView *field;

- (void)openPopover;
- (void)openSettings;

@end
