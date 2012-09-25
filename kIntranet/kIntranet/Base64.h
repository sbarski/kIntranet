//
//  Base64.h
//  kIntranet
//
//  Created by Peter Sbarski on 24/09/12.
//  Copyright (c) 2012 Peter Sbarski. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface Base64 : NSObject
+(NSString *)Base64EncodeForString:(NSString *)strData;
+(NSString *)Base64EncodeForData:(NSData *)data;
@end
