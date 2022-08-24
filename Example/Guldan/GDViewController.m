//
//  GDViewController.m
//  Guldan
//
//  Created by Alex023 on 11/11/2021.
//  Copyright (c) 2021 Alex023. All rights reserved.
//

#import "GDViewController.h"
#import "GDNOCMethodTimeProfiler.h"

@interface GDViewController ()

@end

@implementation GDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self testM];
    [GDNOCMethodTimeProfiler stop];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [GDNOCMethodTimeProfiler handleRecordsWithComplete:^(NSArray<NSString *> * _Nonnull filePaths) {
            
        }];
    });
}

- (void)testM
{
    clock_t start = clock();
    [self m1];
    [self m2];
    clock_t end = clock();
    double cost = (double)(end - start) / CLOCKS_PER_SEC;
    NSLog(@"cost:%f", cost);

}

- (void)m1 {
    sleep(2);
    [self m3];
    [self m3];
}

- (void)m2 {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"1");
        NSLog(@"1");
        NSLog(@"1");
        NSLog(@"1");
        
        NSLog(@"1");
    });
}

- (void)m3 {
    for (int i = 0; i < 10000; i++) {
        NSLog(@"%d", i);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
