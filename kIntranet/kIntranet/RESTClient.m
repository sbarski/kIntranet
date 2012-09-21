//
//  RESTClient.m
//  kIntranet
//
//  Created by Peter Sbarski on 19/09/12.
//  Copyright (c) 2012 Peter Sbarski. All rights reserved.
//

#import "RESTClient.h"

@implementation RESTClient

@synthesize delegate;

-(void)authenticateUserBy:(NSString*)token
{
    
}

-(void)authenticateUserBy:(NSString*)username andPassword:(NSString*)password
{
    
}

-(void)loadStaffList
{
    /*
    NSURL *url = [NSURL URLWithString:@"http://transit.local/api/account/"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSLog(@"IP Address: %@", [JSON valueForKey:@"origin"]);
    } failure:nil];
     */
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
    
    if (statusCode >= 400) {
        // do error handling here
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
}
-(void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error
{
    // Handle the error properly
}
-(void)connectionDidFinishLoading:(NSURLConnection*)connection
{
    //[self handleData]; // Deal with the data
}

-(BOOL)authenticateUser:(NSString *)username password:(NSString*)password
{
    NSString *post = [NSString stringWithFormat:@"Email=%@&Password=%@", username, password];
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc]init]autorelease];
    
    [request setURL:[NSURL URLWithString:@"https://transit.local/api/account/logon"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSError *error;
    NSURLResponse *response;
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];
    
    /*
     NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
     NSString *data=[[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding];
     
     NSError *e;
     NSDictionary *JSON =
     [NSJSONSerialization JSONObjectWithData: [data dataUsingEncoding:NSUTF8StringEncoding]
     options: NSJSONReadingMutableContainers
     error: &e];
     */
    [conn release];
    
    //NSLog(data);
    
}

@end
