#ifndef ELLOAPP_NETWORK_LOGGING_H
#define ELLOAPP_NETWORK_LOGGING_H

#import <Foundation/Foundation.h>

void NetworkRegisterLoggingFunction();
void NetworkSetLoggingEnabled(bool);

void setBridgingTraceFunction(void (*)(NSString *, NSString *));
void setBridgingShortTraceFunction(void (*)(NSString *, NSString *));

#endif // ELLOAPP_NETWORK_LOGGING_H
