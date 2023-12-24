#include <stdlib.h>
#include <unistd.h>
#import "ACNEService.h"
#import "ACNEServicesManager.h"

ACNEService* GetVPNService(NSString* name);
NSString* State2String(SCNetworkConnectionStatus state);

void PrintUsage();

int main(int argc, const char* argv[]) {
  @autoreleasepool {
    if (argc < 2) {
      PrintUsage();
      return 1;
    }
    GetVPNService(@"");  // init request
    NSString* vpnName = [NSString stringWithUTF8String:argv[1]];
    while (YES) {
      ACNEService* service = GetVPNService(vpnName);
      unsigned int interval = 3;
      switch (service.state) {
        case kSCNetworkConnectionDisconnected:
          NSLog(@"VPN \"%@\" is disconnected, reconnect now", vpnName);
          [service connect];
          break;
        case kSCNetworkConnectionConnecting:
          NSLog(@"VPN \"%@\" is connecting", vpnName);
          interval = 1;
          break;
        case kSCNetworkConnectionConnected:
          NSLog(@"VPN \"%@\" is connected", vpnName);
          break;
        default:
          interval = 1;
          break;
      }
      sleep(interval);
    }
  }
  return 0;
}

ACNEService* GetVPNService(NSString* vpnName) {
  __block ACNEService* foundNEService = NULL;
  __block NSArray<ACNEService*>* neServices = NULL;
  NSDate* start = [NSDate now];

  [[ACNEServicesManager sharedNEServicesManager]
      loadConfigurationsWithHandler:^(NSError* error) {
        if (error != nil) {
          NSLog(@"Failed to load the configurations - %@", error);
        }

        neServices = [[ACNEServicesManager sharedNEServicesManager] neServices];
        if ([neServices count] <= 0) {
          NSLog(@"Could not find any VPN");
        }

        for (ACNEService* neService in neServices) {
          if ([neService.name isEqualToString:vpnName]) {
            foundNEService = neService;
            break;
          }
        }
      }];
  BOOL keepRunning = YES;
  while (keepRunning) {
    for (ACNEService* service in neServices) {
      keepRunning = NO;
      if (!service.gotInitialSessionStatus) {
        keepRunning = YES;
        break;
      }
    }
    NSTimeInterval interval = [start timeIntervalSinceNow];
    if (interval >= 10.0) {
      break;
    }
    NSDate* timeoutDate = [NSDate dateWithTimeIntervalSinceNow:1.0];
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                             beforeDate:timeoutDate];
  }
  return foundNEService;
}

NSString* State2String(SCNetworkConnectionStatus state) {
  switch (state) {
    case kSCNetworkConnectionInvalid:
      return @"Invalid";
    case kSCNetworkConnectionDisconnected:
      return @"Disconnected";
    case kSCNetworkConnectionConnecting:
      return @"Connecting";
    case kSCNetworkConnectionConnected:
      return @"Connected";
    case kSCNetworkConnectionDisconnecting:
      return @"Disconnecting";
  }
  return @"UNKNOWN";
}

void PrintUsage() {
  fprintf(stderr, "vpnauto $VPN_NAME\n");
}
