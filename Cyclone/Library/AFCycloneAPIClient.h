#import <Foundation/Foundation.h>
#import "AFHTTPClient.h"

#define kCycloneAPIBaseURL              @"http://cyclone.torinnguyen.com"
#define kCycloneAPIGetTriggers          @"/srv_get_triggers.php"
#define kCycloneAPIExtTrigger           @"/srv_ext_trigger.php"
#define kCycloneAPIModuleAlias          @"ios"

#define kCycloneAPI_ws_service          @"ws_service"
#define kCycloneAPI_ws_message          @"ws_message"
#define kCycloneAPI_ws_data             @"ws_data"

@interface AFCycloneAPIClient : AFHTTPClient

+ (AFCycloneAPIClient *)sharedClient;

- (NSNumber*)getTriggerIdForAlias:(NSString *)trigger_alias;

- (void)networkInit:(void (^)(BOOL success))completion;

- (void)getTriggersForModuleAlias:(NSString*)module_alias 
                       completion:(void (^)(BOOL success, NSString *statusMessage, NSArray *triggers))completion;

- (void)updateLocation:(CLLocation *)newLocation
            completion:(void (^)(BOOL success, NSString *statusMessage, NSNumber *queue_id))completion;

@end
