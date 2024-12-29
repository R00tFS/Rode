#import <Foundation/Foundation.h>
#include <objc/objc.h>
#include <objc/runtime.h>
#import <UIKit/UIKit.h>
#import <substrate.h>

@interface SBPasscodeNumberPadButton : UIView
-(id)stringCharacter;
@end

@interface SBUIPasscodeLockNumberPad : UIView
@property (readonly, weak, nonatomic) NSMutableArray *buttons;
@end

void shuffle(int *array, int n) {
    for (int i = 0; i < n - 1; i++) {
        int j = i + (int)arc4random_uniform(n - i);
        int t = array[j];
        array[j] = array[i];
        array[i] = t;
    }
}

id (*orig_SBUIPasscodeLockNumberPad_initWithDefaultSizeAndLightStyle)(id self, SEL cmd, BOOL arg1);
id hooked_SBUIPasscodeLockNumberPad_initWithDefaultSizeAndLightStyle(id self, SEL cmd, BOOL arg1) {
    SBUIPasscodeLockNumberPad *orig = orig_SBUIPasscodeLockNumberPad_initWithDefaultSizeAndLightStyle(self, cmd, arg1);

    int keys[10] = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 };
    shuffle(keys, 10);
    NSArray *filteredArray = [[orig buttons] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return [evaluatedObject isKindOfClass:objc_getClass("SBPasscodeNumberPadButton")];
    }]];

    for (int i = 0 ; i<5 ; i++) {
        SBPasscodeNumberPadButton *currentButton = filteredArray[keys[i]];
        SBPasscodeNumberPadButton *secondButton = filteredArray[keys[i+5]];

        CGRect temp = secondButton.frame;
        secondButton.frame = currentButton.frame;
        currentButton.frame = temp;
    }
    return orig;
}


__attribute((constructor)) void tweak() {
    MSHookMessageEx(objc_getClass("SBUIPasscodeLockNumberPad"), sel_registerName("initWithDefaultSizeAndLightStyle:"), (IMP)hooked_SBUIPasscodeLockNumberPad_initWithDefaultSizeAndLightStyle, (IMP*) &orig_SBUIPasscodeLockNumberPad_initWithDefaultSizeAndLightStyle);
}