#include "MyDelegate.h"
#import <Cocoa/Cocoa.h>
#import "SettingsManager.h"

@interface MyDelegate (PrivateMethods)

- (void)setupUi;
- (void)setupMenu;
- (void)setupGlobalHotkey;

@end

@implementation MyDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
  [SettingsManager.sharedInstance load];
  [self setupUi];
  [self setupMenu];
  [self setupGlobalHotkey];
}

- (void)openPopover {
  [self.popover showRelativeToRect:self.item.button.bounds ofView:self.item.button preferredEdge:NSMaxYEdge];
}

- (void)openSettings {
  NSLog(@"openSettings");
}

@end

@implementation MyDelegate (PrivateMethods)

- (void)setupUi {
  self.item = [NSStatusBar.systemStatusBar statusItemWithLength:NSVariableStatusItemLength];
  self.item.button.image = [NSImage imageWithSystemSymbolName:@"character.textbox" accessibilityDescription:@"pasteboard"];
  self.item.button.action = @selector(openPopover);

  NSMutableParagraphStyle *placeholderStyle = [[NSMutableParagraphStyle alloc] init];
  placeholderStyle.alignment = NSTextAlignmentCenter;
  NSAttributedString *placeholder = [[NSAttributedString alloc] initWithString:@"Write (or paste) something here..."
                                                                    attributes:@{ NSParagraphStyleAttributeName:placeholderStyle,
                                                                                 NSForegroundColorAttributeName:NSColor.systemGrayColor}];

  self.field = [[NSTextView alloc] initWithFrame:NSMakeRect(10, 10, 280, 180)];
  [self.field setPlaceholderAttributedString:placeholder];
  self.field.richText = NO;

  NSViewController *vc = [[NSViewController alloc] init];
  vc.view = self.field;

  self.popover = [[NSPopover alloc] init];
  self.popover.contentSize = CGSizeMake(300, 200);
  self.popover.behavior = NSPopoverBehaviorTransient;
  self.popover.contentViewController = vc;
}

- (void)setupMenu {
  NSMenu *main = [[NSMenu alloc] init];
  [self setupAppMenu:main];
  [self setupEditMenu:main];
  NSApp.mainMenu = main;
}

- (void)setupAppMenu:(NSMenu *)main {
  NSMenuItem *appItem = [[NSMenuItem alloc] init];
  NSMenu *app = [[NSMenu alloc] initWithTitle:@""];

  [app addItemWithTitle:@"Settings" action:@selector(openSettings) keyEquivalent:@","].target = self;

  appItem.submenu = app;
  [main addItem:appItem];
}

- (void)setupEditMenu:(NSMenu *)main {
  NSMenuItem *editItem = [[NSMenuItem alloc] init];
  NSMenu *edit = [[NSMenu alloc] initWithTitle:@"Edit"];

  [edit addItemWithTitle:@"Copy" action:@selector(copy:) keyEquivalent:@"c"];
  [edit addItemWithTitle:@"Paste" action:@selector(paste:) keyEquivalent:@"v"];
  [edit addItemWithTitle:@"Cut" action:@selector(cut:) keyEquivalent:@"x"];
  [edit addItemWithTitle:@"Select All" action:@selector(selectAll:) keyEquivalent:@"a"];
  
  editItem.submenu = edit;
  [main addItem:editItem];
}

- (void)setupGlobalHotkey {
  if (AXIsProcessTrustedWithOptions((__bridge CFDictionaryRef)@{ (__bridge NSString *)kAXTrustedCheckOptionPrompt:@YES })) {
    [NSEvent addGlobalMonitorForEventsMatchingMask:NSEventMaskKeyUp handler:^(NSEvent *ev) {
      Keybind *kbOpen = SettingsManager.sharedInstance.kbOpen;
      Keybind *kbOpenAndPaste = SettingsManager.sharedInstance.kbOpenAndPaste;

      if (((ev.modifierFlags & kbOpen.modifiers) == kbOpen.modifiers) && ev.keyCode == kbOpen.keycode) {
        [self openPopover];
      }

      if (((ev.modifierFlags & kbOpenAndPaste.modifiers) == kbOpenAndPaste.modifiers) && ev.keyCode == kbOpenAndPaste.keycode) {
        [self openPopover];
        [self.field paste:ev];
      }
    }];
  }
}

@end
