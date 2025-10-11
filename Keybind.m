#include "Keybind.h"

#import <AppKit/NSEvent.h>
#import <Carbon/Carbon.h>

@implementation Keybind

@synthesize modifiers;
@synthesize keycode;

+ (instancetype)withModifiers:(NSUInteger)mods keyCode:(NSUInteger)code {
  Keybind *me = [[Keybind alloc] init];
  me.modifiers = mods;
  me.keycode = code;
  return me;
}

- (NSString *)description {
  NSMutableString *desc = [NSMutableString string];

  if (self.modifiers & NSEventModifierFlagControl) [desc appendString:@"⌃"];
  if (self.modifiers & NSEventModifierFlagOption)  [desc appendString:@"⌥"];
  if (self.modifiers & NSEventModifierFlagShift)   [desc appendString:@"⇧"];
  if (self.modifiers & NSEventModifierFlagCommand) [desc appendString:@"⌘"];

  TISInputSourceRef currentKeyboard = TISCopyCurrentKeyboardInputSource();
  CFDataRef layoutData = TISGetInputSourceProperty(currentKeyboard, kTISPropertyUnicodeKeyLayoutData);

  if (layoutData) {
    const UCKeyboardLayout *keyboardLayout = (const UCKeyboardLayout *)CFDataGetBytePtr(layoutData);

    UInt32 deadKeyState = 0;
    UniCharCount maxStringLength = 4;
    UniCharCount actualStringLength = 0;
    UniChar unicodeString[4];

    UCKeyTranslate(keyboardLayout,
                   self.keycode,
                   kUCKeyActionDisplay,
                   0,
                   LMGetKbdType(),
                   kUCKeyTranslateNoDeadKeysBit,
                   &deadKeyState,
                   maxStringLength,
                   &actualStringLength,
                   unicodeString);

    if (actualStringLength > 0) {
      NSString *keyChar = [NSString stringWithCharacters:unicodeString length:actualStringLength];
      [desc appendString:[keyChar uppercaseString]];
    } else {
      [desc appendFormat:@"Key%lu", (unsigned long)self.keycode];
    }
  } else {
    [desc appendFormat:@"Key%lu", (unsigned long)self.keycode];
  }

  if (currentKeyboard) CFRelease(currentKeyboard);

  return desc;
}
@end
