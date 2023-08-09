#import "SSKeychain.h"

#define kBioAppsList @"/private/var/mobile/Library/Preferences/com.rpetrich.biolockdown.plist", @"/private/var/mobile/Library/Preferences/com.rpetrich.biolockdown.license", @"/private/var/mobile/Library/Preferences/net.limneos.bioprotect.plist", @"/private/var/mobile/Library/Preferences/com.nnfyrbsnss.applocker.plist", @"/private/var/mobile/Library/Preferences/com.a3tweaks.asphaleia.plist", nil

#define k1PalPrefs @"/private/var/mobile/Library/Preferences/com.fortysixandtwo.1pal.plist"

NSString *_passwordString = nil;
NSString *OPMasterPasswordFromKeychain = nil;

static BOOL isBioAppPresent();
static void showAlert(NSString *message, NSString *buttonTitle);

@interface OPPasswordEntryView : UIView {
}
-(BOOL)textFieldShouldReturn:(id)arg1;
@end

%hook OPLockedViewController

-(void)setPasswordView:(id)arg1
{
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:k1PalPrefs]];
  
    if(isBioAppPresent() || [[settings objectForKey:@"bypassSecurity"] boolValue]) // Make sure the user has a biometric app installed
    {
        if([[settings objectForKey:@"clearKeychain"] boolValue])
        {
            NSString *alertMessage = nil;
            
            if([SSKeychain deletePasswordForService:@"com.fortysixandtwo.1pal" account:@"1Password"]) // Remove password from keychain
            {
                alertMessage = @"Viola! Your password has been systematically (and mercilessly) nuked from the keychain.";
                
                // Reset clearKeychain switch in preferences to OFF
                [settings setValue:FALSE forKey:@"clearKeychain"];
                [settings writeToFile:k1PalPrefs atomically:YES];
            }
            else
            {
                alertMessage = @"Uh oh. I'm having trouble clearing the keychain. Reboot and try again.";
            }
            
            showAlert(alertMessage, @"OK");
        }
        
        OPMasterPasswordFromKeychain = [SSKeychain passwordForService:@"com.fortysixandtwo.1pal" account:@"1Password"];
    }
    else
    {
        showAlert(@"Hey, whoa! We got a badass over here! It appears that you DO NOT have any biometric security apps installed (eg. BioLockdown, BioProtect, etc). It's rather foolish to use 1Pal without one, don't you think? That being said, if you'd prefer to spit in the face of danger (or if you think this message is in error), you can enabled the \"Skip Bio-Check\" option in Settings.", @"Sir, yes, sir!");
        
        OPMasterPasswordFromKeychain = nil;
    }
    
    %orig;

    if(OPMasterPasswordFromKeychain) // Send previously stored password to 1Password
    {
        OPPasswordEntryView *passwordView = MSHookIvar<OPPasswordEntryView *>(self, "_passwordView");
    
        UITextField *passwordField = MSHookIvar<UITextField *>(passwordView, "_passwordField");
        passwordField.text = OPMasterPasswordFromKeychain;
    
        [passwordView textFieldShouldReturn:passwordField];
    }
}

-(void)setSuccessfullyUnlocked:(BOOL)arg1
{
    if(arg1 && !OPMasterPasswordFromKeychain) // Store password on successful unlock
    {
        [SSKeychain setPassword:_passwordString forService:@"com.fortysixandtwo.1pal" account:@"1Password"];
        showAlert(@"Woohoo! Your master password has just been stored to the keychain. You will never have to enter your password again.", @"Awesome!");
    }
    
    %orig;
    
    OPMasterPasswordFromKeychain = nil; // Not necessary, but just being thorough..
    _passwordString = nil; // Not necessary, but just being thorough..
}

%end

%hook OPPasswordEntryView
-(void)_tryToUnlockWithPassword:(id)arg1
{
    _passwordString = arg1; // Store entered password to temporary variable
    %orig;
}
%end

static void showAlert(NSString *messageText, NSString *buttonTitle)
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"1Pal"
                                                    message:messageText
                                                   delegate:nil
                                          cancelButtonTitle:buttonTitle
                                          otherButtonTitles:nil];
    [alert show];
}

static BOOL isBioAppPresent()
{
    for(NSString *bioAppPath in [NSArray arrayWithObjects:kBioAppsList])
    {
        if([[NSFileManager defaultManager] fileExistsAtPath:bioAppPath])
        {
            return YES;
        }
    }

    return NO;
}
