//
//  ResourceLabelTests.m
//  ToloApp
//
//  Created by Torey Lomenda on 9/14/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import "PropertyUtils.h"

@interface ResourceLabelTests : SenTestCase 

- (void) testLoadResourceLabelProperties;

- (NSDictionary *) loadPropertiesForTesting;

@end

@implementation ResourceLabelTests

- (void) testLoadResourceLabelProperties {
    NSDictionary *labelProps = [self loadPropertiesForTesting];
    
    STAssertNotNil(labelProps, @"Expected there to be properties");
    STAssertTrue([labelProps count] == 392, @"Expected number of labels to be 407, but was %d", [labelProps count]);
}

- (NSDictionary *) loadPropertiesForTesting {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];    
    NSString *path = [bundle pathForResource:@"resourcelabels" ofType:@"csv"];
    
    NSDictionary *properties = [PropertyUtils loadJavaProperties:path];
    
    return properties;
}

@end
