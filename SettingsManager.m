#include "SettingsManager.h"

#import <AppKit/NSEvent.h>

@implementation SettingsManager

@synthesize kbOpenAndPaste;
@synthesize kbOpen;

+ (instancetype)sharedInstance {
  static id _sharedInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _sharedInstance = [[self alloc] init];
  });
  return _sharedInstance;
}

- (instancetype)init {
  self = [super init];

  /* default: open&paste = Ctrl+Opt+L, open = Ctrl+Opt+K */
  self.kbOpenAndPaste = [Keybind withModifiers:(NSEventModifierFlagControl | NSEventModifierFlagOption) keyCode:37];
  self.kbOpen = [Keybind withModifiers:(NSEventModifierFlagControl | NSEventModifierFlagOption) keyCode:40];
  return self;
}

- (void)save {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

  [defaults setInteger:self.kbOpenAndPaste.keycode forKey:@"kbOpenAndPaste_kc"];
  [defaults setInteger:self.kbOpenAndPaste.modifiers forKey:@"kbOpenAndPaste_mods"];

  [defaults setInteger:self.kbOpen.keycode forKey:@"kbOpen_kc"];
  [defaults setInteger:self.kbOpen.modifiers forKey:@"kbOpen_mods"];
}

- (void)load {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

  if ([defaults integerForKey:@"kbOpenAndPaste_mods"] && [defaults integerForKey:@"kbOpenAndPaste_kc"]) {
    self.kbOpenAndPaste.modifiers = [defaults integerForKey:@"kbOpenAndPaste_mods"];
    self.kbOpenAndPaste.keycode = [defaults integerForKey:@"kbOpenAndPaste_kc"];
  }

  if ([defaults integerForKey:@"kbOpen_mods"] && [defaults integerForKey:@"kbOpen_kc"]) {
    self.kbOpen.modifiers = [defaults integerForKey:@"kbOpen_mods"];
    self.kbOpen.keycode = [defaults integerForKey:@"kbOpen_kc"];
  }
}

@end
