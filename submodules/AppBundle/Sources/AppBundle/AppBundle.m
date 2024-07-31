#import <AppBundle/AppBundle.h>

NSBundle * _Nonnull getAppBundle() {
    NSBundle *bundle = [NSBundle mainBundle];
    if ([[bundle.bundleURL pathExtension] isEqualToString:@"appex"]) {
        bundle = [NSBundle bundleWithURL:[[bundle.bundleURL URLByDeletingLastPathComponent] URLByDeletingLastPathComponent]];
    } else if ([[bundle.bundleURL pathExtension] isEqualToString:@"framework"]) {
        bundle = [NSBundle bundleWithURL:[[bundle.bundleURL URLByDeletingLastPathComponent] URLByDeletingLastPathComponent]];
    } else if ([[bundle.bundleURL pathExtension] isEqualToString:@"Frameworks"]) {
        bundle = [NSBundle bundleWithURL:[bundle.bundleURL URLByDeletingLastPathComponent]];
    }
    return bundle;
}

NSBundle * _Nonnull getLocalizationAppBundle() {
    return [NSBundle bundleWithURL:[getAppBundle().bundleURL URLByAppendingPathComponent:@"en.lproj"]];
}

NSBundle * _Nonnull getElloAppUIFrameworkAppBundle() {
    return [NSBundle bundleWithURL:[getAppBundle().bundleURL URLByAppendingPathComponent:@"Frameworks/ElloAppUIFramework.framework"]];
}

@implementation UIImage (AppBundle)

- (instancetype _Nullable)initWithBundleImageName:(NSString * _Nonnull)bundleImageName {
    return [UIImage imageNamed:bundleImageName inBundle:getAppBundle() compatibleWithTraitCollection:nil];
}

@end

@implementation UIColor (AppBundle)

- (instancetype _Nullable)initWithBundleColorName:(NSString * _Nonnull)bundleColorName {
    return [UIColor colorNamed:bundleColorName inBundle:getElloAppUIFrameworkAppBundle() compatibleWithTraitCollection:nil];
}

@end
