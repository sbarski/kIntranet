//
//  RESTClient.m
//  kIntranet
//
//  Created by Peter Sbarski on 19/09/12.
//  Copyright (c) 2012 Peter Sbarski. All rights reserved.
//

#import "RESTClientKIntranet.h"

@implementation RESTClientKIntranet

@synthesize delegate;

-(void)refreshStaffList
{
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc]initWithIdentifier:@"kIntranet Login" accessGroup:nil];
    NSString *token = [keychainItem objectForKey:kSecValueData];
   
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc]init]autorelease];
    
    NSString *authorization = [Base64 Base64EncodeForString:token];
    NSString *authHeader = [@"Basic " stringByAppendingFormat:@"%@", authorization];
   
    [request setURL:[NSURL URLWithString:@"https://transit.local/api/intranet/staff"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:authHeader forHTTPHeaderField:@"Authorization"];
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];
    
    [conn release];
}

-(void)updateStaffLocation:(NSMutableArray *)employees
{
    //NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    NSMutableArray *modifiedStaffArray = [[NSMutableArray alloc]init];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZZZ"];
    
    for(id staff in employees)
    {
        if (((Staff*)staff).modified == YES)
        {
            NSMutableDictionary *member = [[NSMutableDictionary alloc]init];
            
            [member setObject:((Staff*)staff).identification forKey:@"Id"];
            
            if (((Staff*)staff).checkin == nil)
            {
                [member setObject:[NSNull null] forKey:@"In"];
            }
            else
            {
                [member setObject:[dateFormat stringFromDate:((Staff*)staff).checkin] forKey:@"In"];
            }
            
            if (((Staff*)staff).checkout == nil)
            {
                [member setObject:[NSNull null] forKey:@"Out"];
            }
            else
            {
                [member setObject:[dateFormat stringFromDate:((Staff*)staff).checkout] forKey:@"Out"];
            }

            [member setObject:((Staff*)staff).location forKey:@"Location"];
            
            ((Staff*)staff).modified = NO;
            
            [modifiedStaffArray addObject:member];
            //[e addEntriesFromDictionary:member];
            
            [member release];
        }
    }
    
    [dateFormat release];
    
    [self updateIntranet:modifiedStaffArray];

    [modifiedStaffArray release];
    //[dict release];
}

-(void)updateIntranet:(NSMutableArray*)staff
{
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc]initWithIdentifier:@"kIntranet Login" accessGroup:nil];
    NSString *token = [keychainItem objectForKey:kSecValueData];
    
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc]init]autorelease];
    
    NSString *authorization = [Base64 Base64EncodeForString:token];
    NSString *authHeader = [@"Basic " stringByAppendingFormat:@"%@", authorization];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:staff options:NSJSONWritingPrettyPrinted error:&error];
    
    if (!jsonData)
    {
        NSLog(@"Got an error: %@", error);
        return;
    }
    
    //NSString *jsonString = [[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding]autorelease];
    
    [request setURL:[NSURL URLWithString:@"https://transit.local/api/intranet/SetStaffLocation"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:authHeader forHTTPHeaderField:@"Authorization"];
    [request setHTTPBody:jsonData];
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];

    [conn start];
    
    [conn release];
    
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    NSArray *trustedHosts = [NSArray arrayWithObjects:@"transit.local",nil];
    
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]){
        if ([trustedHosts containsObject:challenge.protectionSpace.host]) {
            [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
        }
    }
    
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

-(void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse*)response
{
    NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
    
    if (statusCode == 200)
    {
        NSString *url = [[response URL] absoluteString];
        
        [url release];
    }
    
    if (statusCode == 401) //unauthorized
    {
        [connection cancel];
        
        [self.delegate userSignOut];
    }
    
    if (statusCode > 401) {
        // do error handling here
       
        [connection cancel];
        
        NSLog(@"remote url returned error %d %@",statusCode,[NSHTTPURLResponse localizedStringForStatusCode:statusCode]);
    } else {
        // start recieving data
    }
}
-(void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data
{
    NSLog(@"String sent from server %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    
    NSString *mydata=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    
    NSError *e;
    NSDictionary *JSON =
    [NSJSONSerialization JSONObjectWithData: [mydata dataUsingEncoding:NSUTF8StringEncoding]
                                    options: NSJSONReadingMutableContainers
                                      error: &e];
    
    [self.delegate updateStaffList:JSON];
}

-(void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error
{
    // Handle the error properly
}

-(void)connectionDidFinishLoading:(NSURLConnection*)connection
{
    //[self handleData]; // Deal with the data
}

@end
