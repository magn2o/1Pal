#import <Preferences/Preferences.h>

@interface _1PalSettingsListController: PSListController {
}
@end

@implementation _1PalSettingsListController
- (id)specifiers
{
	if(_specifiers == nil)
	{
		_specifiers = [self loadSpecifiersFromPlistName:@"1PalSettings" target:self];
	}

	return _specifiers;
}

- (void)launchTwitter:(id)specifier
{
	if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot://"]])
	{
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tweetbot:///user_profile/magn2o"]];
	}
	else 
	{
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/magn2o/"]];
	}
}
@end
