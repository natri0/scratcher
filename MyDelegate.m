#include "MyDelegate.h"
#import <Cocoa/Cocoa.h>
#import "SettingsManager.h"

@interface NSTextView (SetPlaceholder)
- (void)setPlaceholderAttributedString:(NSAttributedString *)placeholder;
@end

@interface MyDelegate (PrivateMethods)

- (void)setupUi;
- (void)setupMenu;
- (void)setupGlobalHotkey;

- (void)changeKbOpen;
- (void)changeKbOpenPaste;
- (void)showFontPanel;
- (void)updateButtonTitles;

@end

@implementation MyDelegate {
  NSButton *kbOpenBtn;
  NSButton *kbOpenPasteBtn;
  NSButton *changeFontBtn;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
  [SettingsManager.sharedInstance load];
  [self setupUi];
  [self setupMenu];
  [self setupGlobalHotkey];
}

- (void)openPopover {
  [self.popover showRelativeToRect:self.item.button.bounds ofView:self.item.button preferredEdge:NSMaxYEdge];
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

  self.field = [[NSTextView alloc] initWithFrame:NSMakeRect(10, 30, 280, 0)];
  [self.field setPlaceholderAttributedString:placeholder];
  self.field.richText = NO;
  self.field.verticallyResizable = YES;

  kbOpenBtn = [NSButton buttonWithTitle:@"Open: ⌃⌥K" target:self action:@selector(changeKbOpen)];
  kbOpenPasteBtn = [NSButton buttonWithTitle:@"Open & Paste: ⌃⌥L" target:self action:@selector(changeKbOpenPaste)];
  changeFontBtn = [NSButton buttonWithTitle:@"Font: Helvetica 11" target:self action:@selector(showFontPanel)];

  [SettingsManager.sharedInstance addObserver:self
                                  forKeyPath:@"kbOpen"
                                     options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial)
                                     context:NULL];

  [SettingsManager.sharedInstance addObserver:self
                                  forKeyPath:@"kbOpenAndPaste"
                                     options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial)
                                     context:NULL];
  
  [SettingsManager.sharedInstance addObserver:self
                                  forKeyPath:@"font"
                                     options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial)
                                     context:NULL];

  kbOpenBtn.bezelStyle = kbOpenPasteBtn.bezelStyle = NSBezelStyleRounded;

  NSScrollView *scroll = [[NSScrollView alloc] initWithFrame:NSMakeRect(10, 30, 280, 160)];
  scroll.documentView = self.field;
  scroll.hasVerticalScroller = YES;

  NSView *container = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 300, 200)];

  scroll.translatesAutoresizingMaskIntoConstraints = NO;
  kbOpenBtn.translatesAutoresizingMaskIntoConstraints = NO;
  kbOpenPasteBtn.translatesAutoresizingMaskIntoConstraints = NO;
  changeFontBtn.translatesAutoresizingMaskIntoConstraints = NO;
  container.translatesAutoresizingMaskIntoConstraints = NO;

  [container addSubview:scroll];
  [container addSubview:kbOpenBtn];
  [container addSubview:kbOpenPasteBtn];
  [container addSubview:changeFontBtn];

  [NSLayoutConstraint activateConstraints:@[
    [scroll.topAnchor constraintEqualToAnchor:container.topAnchor constant:10],
    [scroll.leadingAnchor constraintEqualToAnchor:container.leadingAnchor constant:10],
    [scroll.trailingAnchor constraintEqualToAnchor:container.trailingAnchor constant:-10],
    [scroll.bottomAnchor constraintEqualToAnchor:changeFontBtn.topAnchor constant:-10],

    [kbOpenBtn.leadingAnchor constraintEqualToAnchor:container.leadingAnchor constant:10],
    [kbOpenBtn.bottomAnchor constraintEqualToAnchor:container.bottomAnchor constant:-10],
    [kbOpenBtn.widthAnchor constraintEqualToConstant:100],

    [kbOpenPasteBtn.trailingAnchor constraintEqualToAnchor:container.trailingAnchor constant:-10],
    [kbOpenPasteBtn.bottomAnchor constraintEqualToAnchor:container.bottomAnchor constant:-10],
    [kbOpenPasteBtn.widthAnchor constraintEqualToConstant:140],

    [changeFontBtn.leadingAnchor constraintEqualToAnchor:container.leadingAnchor constant:10],
    [changeFontBtn.trailingAnchor constraintEqualToAnchor:container.trailingAnchor constant:-10],
    [changeFontBtn.bottomAnchor constraintEqualToAnchor:kbOpenBtn.topAnchor constant:-10],
  ]];

  NSViewController *vc = [[NSViewController alloc] init];
  vc.view = container;

  self.popover = [[NSPopover alloc] init];
  self.popover.contentSize = CGSizeMake(300, 200);
  self.popover.behavior = NSPopoverBehaviorTransient;
  self.popover.contentViewController = vc;

  [self updateButtonTitles]; // force load fonts & keybinds
}

- (void)setupMenu {
  NSMenu *main = [[NSMenu alloc] init];
  [self setupAppMenu:main];
  [self setupEditMenu:main];

  NSFontManager *fm = NSFontManager.sharedFontManager;
  NSMenuItem *fontItem = [[NSMenuItem alloc] init];
  fontItem.submenu = [fm fontMenu:YES];
  [main addItem:fontItem];

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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *, id> *)change context:(void *)context {
  if (object == SettingsManager.sharedInstance) {
    dispatch_async(dispatch_get_main_queue(), ^{ [self updateButtonTitles]; });
  }
}

- (void)updateButtonTitles {
  SettingsManager *sm = SettingsManager.sharedInstance;

  kbOpenBtn.title = [NSString stringWithFormat:@"Open: %@", sm.kbOpen];
  kbOpenPasteBtn.title = [NSString stringWithFormat:@"Open & Paste: %@", sm.kbOpenAndPaste];

  NSLog(@"loaded font from SettingsManager: %@ %@", sm.fontName, sm.fontSize);
  changeFontBtn.title = [NSString stringWithFormat:@"Font: %@ %@", sm.fontName, sm.fontSize];
  self.field.font = [NSFont fontWithDescriptor:sm.font size:0.f];
}

- (void)changeKbOpen {
  [self listenForKeybindWithSelector:@selector(setKbOpen:) button:kbOpenBtn];
}

- (void)changeKbOpenPaste {
  [self listenForKeybindWithSelector:@selector(setKbOpenAndPaste:) button:kbOpenPasteBtn];
}

- (void)showFontPanel {
  NSLog(@"trying to show font panel");
  [NSApp activateIgnoringOtherApps:YES];
  NSFontManager *fm = [NSFontManager sharedFontManager];
  fm.target = self;

  [fm setSelectedFont:self.field.font isMultiple:NO];

  NSFontPanel *fp = NSFontPanel.sharedFontPanel;
  fp.worksWhenModal = YES;
  [fm orderFrontFontPanel:self];
}

- (void)changeFont:(id)sender {
  NSFont *newFont = [NSFontManager.sharedFontManager convertFont:self.field.font];
  self.field.font = newFont;

  SettingsManager *sm = SettingsManager.sharedInstance;
  sm.font = newFont.fontDescriptor;
  [sm save];
}

- (void)listenForKeybindWithSelector:(SEL)sel button:(NSButton *)button {
  NSString *originalTitle = button.title;
  button.title = @"Press keys...";

  __block id monitor = [NSEvent addLocalMonitorForEventsMatchingMask:NSEventMaskKeyDown handler:^(NSEvent *ev) {
    switch (ev.keyCode) {
      case 53 /* Esc */:
        [NSEvent removeMonitor:monitor];
        button.title = originalTitle;
        break;
      case 54: case 55: case 56: case 58:
      case 59: case 60: case 61: case 62:
        break; // skip events consisting of just a mod key
      default: {
        [NSEvent removeMonitor:monitor];
        [SettingsManager.sharedInstance performSelector:sel withObject:[Keybind withModifiers:ev.modifierFlags keyCode:ev.keyCode]];
      }
    }

    [SettingsManager.sharedInstance save];
    return (NSEvent *)nil;
  }];

  [self.popover.contentViewController.view.window makeFirstResponder:self.popover.contentViewController.view];
}

@end
