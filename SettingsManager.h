#pragma once

#import <Foundation/Foundation.h>

#import "Keybind.h"

@interface SettingsManager : NSObject

@property (nonatomic, strong) Keybind *kbOpenAndPaste;
@property (nonatomic, strong) Keybind *kbOpen;

+ (instancetype)sharedInstance;

- (void)save;
- (void)load;

@end
