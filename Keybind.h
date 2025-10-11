#pragma once

#import <Foundation/Foundation.h>

@interface Keybind : NSObject
@property NSUInteger modifiers;
@property NSUInteger keycode;

+ (instancetype)withModifiers:(NSUInteger)mods keyCode:(NSUInteger)code;
@end
