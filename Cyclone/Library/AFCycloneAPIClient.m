
#import "AFCycloneAPIClient.h"
#import "AFJSONRequestOperation.h"
#import "NSDictionary+Additions.h"

@interface AFCycloneAPIClient()

@property (nonatomic, strong) NSArray *triggers;
@property (nonatomic, assign) int user_id;

@end


@implementation AFCycloneAPIClient

@synthesize triggers;
@synthesize user_id;

+ (AFCycloneAPIClient *)sharedClient {
    static AFCycloneAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[AFCycloneAPIClient alloc] initWithBaseURL:[NSURL URLWithString:kCycloneAPIBaseURL]];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
	[self setDefaultHeader:@"Accept" value:@"application/json"];
    
    self.user_id = 1;
    
    return self;
}

- (NSNumber*)getTriggerIdForAlias:(NSString *)trigger_alias
{
    for (NSDictionary *trigger in self.triggers)
    {
        if ([trigger objectForKey:@"trigger_alias"] == nil)
            continue;
        NSString *alias = (NSString *)[trigger objectForKey:@"trigger_alias"];
        if (![[alias lowercaseString] isEqualToString:[trigger_alias lowercaseString]])
            continue;
        NSNumber *trigger_id = [NSNumber numberWithInt:[[trigger objectForKey:@"trigger_id"] intValue]];
        return trigger_id;
    }
    return nil;
}

#pragma mark - Network init sequence

- (void)networkInit:(void (^)(BOOL success))completion
{
    [self getTriggersForModuleAlias:kCycloneAPIModuleAlias
                         completion:^(BOOL success, NSString *statusMessage, NSArray *theTriggers)
    {
        self.triggers = theTriggers;
        NSLog(@"Number of triggers: %d", self.triggers.count);
    }];
}


#pragma mark - Cyclone API

- (void)getTriggersForModuleAlias:(NSString*)module_alias 
                       completion:(void (^)(BOOL success, NSString *statusMessage, NSArray *triggers))completion
{
    //Invalid coordinates
    if (module_alias == nil || [module_alias length] <= 0) {
        if (completion)
            completion(NO, @"module_alias is empty", nil);
        return;   
    }
    
    //POST parameter
    NSDictionary *parameters = [NSDictionary dictionaryWithObject:module_alias forKey:@"module_alias"];
    
    [[AFCycloneAPIClient sharedClient] postPath:kCycloneAPIGetTriggers
                                     parameters:parameters
                                        success:^(AFHTTPRequestOperation *operation, id JSON)
     {
         NSString *message = [JSON valueForKeyPath:kCycloneAPI_ws_message];
         NSArray *triggersArray = [JSON valueForKeyPath:kCycloneAPI_ws_data];
         NSLog(@"%@: %@ %@", kCycloneAPI_ws_service, [JSON valueForKeyPath:kCycloneAPI_ws_service], message);
         
         if (completion)
             completion(YES, message, triggersArray);
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         
         if (completion)
             completion(NO, [NSString stringWithFormat:@"%@", error], nil);
         NSLog(@"Error: %@", error);
     }];
}

- (void)updateLocation:(CLLocation *)newLocation
            completion:(void (^)(BOOL success, NSString *statusMessage, NSNumber *queue_id))completion
{
    //Invalid coordinates
    if (newLocation.horizontalAccuracy < 0) {
        if (completion)
            completion(NO, @"invalid location", nil);
        return;
    }
    
    static int trigger_id = 0;
    if (trigger_id == 0)
        trigger_id = [self getTriggerIdForAlias:@"enter_location"].intValue;
    
    if (trigger_id <= 0) {
        if (completion)
            completion(NO, @"invalid trigger_id", nil);
        return;
    }
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:[NSString stringWithFormat:@"%d", self.user_id] forKey:@"user_id"];
    [parameters setObject:[NSString stringWithFormat:@"%d", trigger_id] forKey:@"trigger_id"];
    [parameters setObject:[NSString stringWithFormat:@"%f", newLocation.coordinate.longitude] forKey:@"longitude"];
    [parameters setObject:[NSString stringWithFormat:@"%f", newLocation.coordinate.latitude] forKey:@"latitude"];
    [parameters setObject:[NSString stringWithFormat:@"%f", newLocation.horizontalAccuracy] forKey:@"accuracy"];
    
    [[AFCycloneAPIClient sharedClient] postPath:kCycloneAPIPutEvent
                                     parameters:parameters
                                        success:^(AFHTTPRequestOperation *operation, id JSON)
     {
         NSString *message = [JSON valueForKeyPath:kCycloneAPI_ws_message];
         NSDictionary *data = [JSON valueForKeyPath:kCycloneAPI_ws_data];
         NSNumber *queue_id = [NSNumber numberWithInt:[[data objectForKey:@"queue_id"] intValue]];
         NSLog(@"%@: %@ %@", kCycloneAPI_ws_service, [JSON valueForKeyPath:kCycloneAPI_ws_service], message);
         
         if (completion)
             completion(YES, message, queue_id);
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         
         if (completion)
             completion(NO, [NSString stringWithFormat:@"%@", error], nil);
         NSLog(@"Error: %@", error);
     }];
}

@end
