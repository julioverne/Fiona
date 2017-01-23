#import <objc/runtime.h>
#import <notify.h>
#import <substrate.h>

#undef HBLogError
#define HBLogError(...)
#define NSLog(...)

#define PLIST_PATH_Settings "/var/mobile/Library/Preferences/com.julioverne.fiona.plist"

static BOOL Enabled;

%group WiFiOn
%hook IdleSleepClass
- (void)allowIdleSleep
{
	if(Enabled) {
		return;
	}
	%orig;
}
%end
%end

#import <libactivator/libactivator.h>
#import <Flipswitch/Flipswitch.h>

static void settingsChangedFiona(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
	@autoreleasepool {
		NSDictionary *Prefs = [[[NSDictionary alloc] initWithContentsOfFile:@PLIST_PATH_Settings]?:@{} copy];
		Enabled = (BOOL)[Prefs[@"Enabled"]?:@YES boolValue];
		if(%c(FSSwitchPanel) != nil) {
			[[%c(FSSwitchPanel) sharedPanel] stateDidChangeForSwitchIdentifier:@"com.julioverne.fiona"];
		}
		notify_post("com.julioverne.fiona/SettingsChanged/Toogle");
	}
}

@interface FionaActivatorSwitch : NSObject <FSSwitchDataSource>
+ (id)sharedInstance;
- (void)RegisterActions;
@end

@implementation FionaActivatorSwitch
+ (id)sharedInstance
{
    __strong static id _sharedObject;
	if (!_sharedObject) {
		_sharedObject = [[self alloc] init];
	}
	return _sharedObject;
}
- (void)RegisterActions
{
    if (access("/usr/lib/libactivator.dylib", F_OK) == 0) {
		dlopen("/usr/lib/libactivator.dylib", RTLD_LAZY);
	    if (Class la = objc_getClass("LAActivator")) {
			[[la sharedInstance] registerListener:(id<LAListener>)self forName:@"com.julioverne.fiona"];
		}
	}
}
- (NSString *)activator:(LAActivator *)activator requiresLocalizedTitleForListenerName:(NSString *)listenerName
{
	return @"Fiona";
}
- (NSString *)activator:(LAActivator *)activator requiresLocalizedDescriptionForListenerName:(NSString *)listenerName
{
	return @"Action For Toggle Enabled/Disabled.";
}
- (UIImage *)activator:(LAActivator *)activator requiresIconForListenerName:(NSString *)listenerName scale:(CGFloat)scale
{
    static __strong UIImage* listenerIcon;
    if (!listenerIcon) {
		listenerIcon = [[UIImage alloc] initWithContentsOfFile:[[NSBundle bundleWithPath:@"/Library/PreferenceBundles/FionaSettings.bundle"] pathForResource:scale==2.0f?@"icon@2x":@"icon" ofType:@"png"]];
	}
    return listenerIcon;
}
- (UIImage *)activator:(LAActivator *)activator requiresSmallIconForListenerName:(NSString *)listenerName scale:(CGFloat)scale
{
    static __strong UIImage* listenerIcon;
    if (!listenerIcon) {
		listenerIcon = [[UIImage alloc] initWithContentsOfFile:[[NSBundle bundleWithPath:@"/Library/PreferenceBundles/FionaSettings.bundle"] pathForResource:scale==2.0f?@"icon@2x":@"icon" ofType:@"png"]];
	}
    return listenerIcon;
}
- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event
{
	@autoreleasepool {
		NSMutableDictionary *Prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@PLIST_PATH_Settings]?:[NSMutableDictionary dictionary];
		Prefs[@"Enabled"] = [Prefs[@"Enabled"]?:@YES boolValue]?@NO:@YES;
		[Prefs writeToFile:@PLIST_PATH_Settings atomically:YES];
		notify_post("com.julioverne.fiona/SettingsChanged");
	}
}
- (FSSwitchState)stateForSwitchIdentifier:(NSString *)switchIdentifier
{
	return Enabled?FSSwitchStateOn:FSSwitchStateOff;
}
- (void)applyActionForSwitchIdentifier:(NSString *)switchIdentifier
{
	[self activator:nil receiveEvent:nil];
}
- (void)applyAlternateActionForSwitchIdentifier:(NSString *)switchIdentifier
{
	[[%c(FSSwitchPanel) sharedPanel] openURLAsAlternateAction:[NSURL URLWithString:@"prefs:root=Fiona"]];
}
@end



%ctor
{
	@autoreleasepool {
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, settingsChangedFiona, CFSTR("com.julioverne.fiona/SettingsChanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
		settingsChangedFiona(NULL, NULL, NULL, NULL, NULL);
		[[FionaActivatorSwitch sharedInstance] RegisterActions];
		%init(WiFiOn, IdleSleepClass = objc_getClass("SBAwayController")?:objc_getClass("SBBacklightController"));
	}
}

