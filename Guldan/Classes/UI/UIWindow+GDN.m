//
//  UIWindow+GDN.m
//  Guldan
//
//  Created by Alex023 on 2022/4/30.
//

#import "UIWindow+GDN.h"
#import "GDNRecordRootViewController.h"

@implementation UIWindow (GDN)

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    GDNRecordRootViewController *vc = [[GDNRecordRootViewController alloc] init];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.rootViewController presentViewController:vc animated:YES completion:nil];
}

- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    
}

@end
