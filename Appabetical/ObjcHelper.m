//
//  ObjcHelper.m
//  Appabetical
//
//  Created by Rory Madden on 6/12/22.
//

#import "ObjcHelper.h"

@implementation ObjcHelper

-(void)thing {
    [[NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/SpringBoardHome.framework"] load];
    Class SBLayout = NSClassFromString(@"SBIconListGridLayoutConfiguration");
    NSLog(@"Rows: %llu",[SBLayout _numberOfPortraitRowz]);

}

+ (unsigned long long)_numberOfPortraitRowz
{
    NSLog(@"This would show if this method ran.");
    return -100;
}

@end
