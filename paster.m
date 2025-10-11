#import <Cocoa/Cocoa.h>
#import "MyDelegate.h"

int main(int argc, char const *argv[]) {
  @autoreleasepool {
    NSApplication *app = NSApplication.sharedApplication;
    app.delegate = [[MyDelegate alloc] init];
    app.activationPolicy = NSApplicationActivationPolicyAccessory;
    [app run];
  }

  return 0;
}
