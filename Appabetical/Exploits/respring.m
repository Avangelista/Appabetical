#import "helpers.h"
#import <Foundation/Foundation.h>

void respringBackboard(void) {
    xpc_crasher("com.apple.backboard.TouchDeliveryPolicyServer");
}

void respringFrontboard(void) {
    xpc_crasher("com.apple.frontboard.systemappservices");
    exit(0);
}
