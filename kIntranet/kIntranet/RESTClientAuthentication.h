//
//  RESTClient.h
//  kIntranet
//
//  Created by Peter Sbarski on 19/09/12.
//  Copyright (c) 2012 Peter Sbarski. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RESTClient; 

@protocol RESTClientDelegate <NSObject>
-(void)authenticateUser:(BOOL)success and:(NSString*)token;
@end

@interface RESTClient : NSObject<NSURLConnectionDelegate>

@property (nonatomic, strong) id<RESTClientDelegate> delegate;

-(void)authenticateUserBy:(NSString*)username andPassword:(NSString*)password;

@end
