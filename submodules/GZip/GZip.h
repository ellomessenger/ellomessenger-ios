#ifndef ELLOAPP_GZIP_H
#define ELLOAPP_GZIP_H

#import <Foundation/Foundation.h>

#ifdef __cplusplus
extern "C" {
#endif

NSData *TGGZipData(NSData *data, float level);
NSData *TGGUnzipData(NSData *data);
    
#ifdef __cplusplus
}
#endif

#endif // ELLOAPP_GZIP_H
