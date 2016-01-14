//
//  NSStringCamelCaseTests.m
//  ToloApp
//
//  Created by Torey Lomenda on 6/8/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "NSStringCamelCaseTests.h"

#import "NSString+CamelCaseUtils.h"

@implementation NSStringCamelCaseTests

- (void) testCamelCase { 
    NSString *wordStr = nil;
    NSString *camelCaseStr1 = @"RodlessScrew";
    NSString *camelCaseStr2 = @"TestCAPSWord";
    NSString *camelCaseStr3 = @"MXE-SSolidBearing";
    NSString *camelCaseStr4 = @"TEST-dsfs232Product";
    NSString *camelCaseStr5 = @"ICRIntegratedMotor_Drive_Actuator";
    
    wordStr = [camelCaseStr1 wordify];
    STAssertTrue([wordStr isEqualToString:@"Rodless Screw"], @"Should be equal");
    
    wordStr = [camelCaseStr2 wordify];
    STAssertTrue([wordStr isEqualToString:@"Test CAPS Word"], @"Should be equal");

    wordStr = [camelCaseStr3 wordify];
    STAssertTrue([wordStr isEqualToString:@"MXE-S Solid Bearing"], @"Should be equal");

    wordStr = [camelCaseStr4 wordify];
    STAssertTrue([wordStr isEqualToString:@"TEST-dsfs232 Product"], @"Should be equal");
    
    wordStr = [camelCaseStr5 wordify];
    STAssertTrue([wordStr isEqualToString:@"ICR Integrated Motor/Drive/Actuator"], @"Should be equal");

}
@end