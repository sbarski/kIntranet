//
//  RESTClientKIntranet.h
//  kIntranet
//
//  Created by Peter Sbarski on 24/09/12.
//  Copyright (c) 2012 Peter Sbarski. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KeychainItemWrapper.h"
#import "Base64.h"

@class RESTClientKIntranet;

@protocol RESTClientDelegate <NSObject>
-(void)updateStaffList:(NSDictionary *)list;
@end

@interface RESTClientKIntranet : NSObject<NSURLConnectionDelegate>

@property (nonatomic, strong) id<RESTClientDelegate> delegate;

-(void)refreshStaffList;

-(void)updateStaffLocation:(NSMutableArray *)employees;

@end
