#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NSBundle * _Nonnull getAppBundle(void);
NSBundle * _Nonnull getLocalizationAppBundle(void);

@interface UIImage (AppBundle)

- (instancetype _Nullable)initWithBundleImageName:(NSString * _Nonnull)bundleImageName;

@end

@interface UIColor (AppBundle)

- (instancetype _Nullable)initWithBundleColorName:(NSString * _Nonnull)bundleColorName;

@end
