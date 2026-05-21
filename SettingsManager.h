#pragma once

#import <Foundation/Foundation.h>
#import <AppKit/NSFontDescriptor.h>

#import "Keybind.h"

@interface SettingsManager : NSObject

@property (nonatomic, strong) Keybind *kbOpenAndPaste;
@property (nonatomic, strong) Keybind *kbOpen;
@property (nonatomic, strong) NSFontDescriptor *font;

+ (instancetype)sharedInstance;

- (void)save;
- (void)load;

- (NSString *)fontName;
- (NSNumber *)fontSize;

@end
