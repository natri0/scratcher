#include "Keybind.h"

@implementation Keybind

@synthesize modifiers;
@synthesize keycode;

+ (instancetype)withModifiers:(NSUInteger)mods keyCode:(NSUInteger)code {
  Keybind *me = [[Keybind alloc] init];
  me.modifiers = mods;
  me.keycode = code;
  return me;
}
@end
