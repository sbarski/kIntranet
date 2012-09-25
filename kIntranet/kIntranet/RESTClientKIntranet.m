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
    
    NSError *error;
    NSURLResponse *response;
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];
    
    [conn release];
}

-(void)updateStaffLocation:(NSMutableArray *)employees
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    
    for(id staff in employees)
    {
        if (((Staff*)staff).modified == YES)
        {
            NSMutableDictionary *member = [[NSMutableDictionary alloc]init];
            
            [member setObject:((Staff*)staff).identification forKey:@"Id"];
            [member setObject:((Staff*)staff).checkin forKey:@"In"];
            [member setObject:((Staff*)staff).checkout forKey:@"Out"];
            [member setObject:((Staff*)staff).location forKey:@"Location"];
            
            ((Staff*)staff).modified = NO;
            
            [dict addEntriesFromDictionary:member];
            
            [member release];
        }
    }
    
    [self updateIntranet:dict];

    [dict release];
}

-(void)updateIntranet:(NSDictionary*)dict
{
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc]initWithIdentifier:@"kIntranet Login" accessGroup:nil];
    NSString *token = [keychainItem objectForKey:kSecValueData];
    
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc]init]autorelease];
    
    NSString *authorization = [Base64 Base64EncodeForString:token];
    NSString *authHeader = [@"Basic " stringByAppendingFormat:@"%@", authorization];
    
    NSString *jsonRequest = [dict JSONRepresentation]; //wrong
    
    NSData *postData = [jsonRequest dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    [request setURL:[NSURL URLWithString:@"https://transit.local/api/intranet/SetStaffLocation"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:authHeader forHTTPHeaderField:@"Authorization"];
    [request setHTTPBody:postData];
    
    NSError *error;
    NSURLResponse *response;
    
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
