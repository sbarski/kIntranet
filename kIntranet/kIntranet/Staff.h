//
//  Staff.h
//  kIntranet
//
//  Created by Peter Sbarski on 11/09/12.
//  Copyright (c) 2012 Peter Sbarski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Staff : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *location;
@property (nonatomic, copy) NSDate *checkout;
@property (nonatomic, copy) NSDate *checkin;

@end
