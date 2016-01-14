//
//  SFChangePasswordViewController.m
//  CatalogFoundation
//
//  Created by Steven McCoole on 6/12/14.
//  Copyright (c) 2014 Object Partners Inc. All rights reserved.
//

#import "SFChangePasswordViewController.h"
#import "OPIFoundation.h"
#import "SFAppConfig.h"
#import "ContentUtils.h"
#import "AlertUtils.h"

#import "NSString+Extensions.h"

@interface SFChangePasswordViewController ()

@property (nonatomic, strong) id currentFirstResponder;
@property (nonatomic, assign) CGFloat previousViewOriginY;
@property (nonatomic, assign) CGFloat actualOriginY;

- (void) addKeyboardListeners;
- (void) removeKeyboardListeners;
- (CGRect) swapRect:(CGRect)rect;

@end

@implementation SFChangePasswordViewController

- (id)init {
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View Lifecycle Methods
- (void)loadView {
    SFChangePasswordView *changeView = [[SFChangePasswordView alloc] initWithFrame:CGRectZero];
    changeView.delegate = self;
    changeView.currentPwField.delegate = self;
    changeView.enterNewPwField.delegate = self;
    changeView.confirmNewPwField.delegate = self;
    
    [self setView:changeView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) viewWillAppear:(BOOL)animated {
	// Call super last
	[super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated {
	// Call super first
	[super viewDidAppear:animated];
    [self addKeyboardListeners];
    
    if (self.view) {
        SFChangePasswordView *pwView = (SFChangePasswordView *)self.view;
        _actualOriginY = pwView.roundedView.frame.origin.y;
    }
}

- (void) viewWillDisappear:(BOOL)animated {
    [self removeKeyboardListeners];
    // Call super last
    [super viewWillDisappear:animated];
}

- (void) viewDidDisappear:(BOOL)animated {
    //Call super first
    [super viewDidDisappear:animated];
}

#pragma mark - Rotation Support
- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    // TODO: Fix to use own config value when added
    if ([[[SFAppConfig sharedInstance] getLoginViewConfig] landscapeOnly]) {
        return UIInterfaceOrientationMaskLandscape;
    }
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // TODO: Fix to use own config value when added
    if ([[[SFAppConfig sharedInstance] getLoginViewConfig] landscapeOnly]) {
        return UIInterfaceOrientationIsLandscape(interfaceOrientation);
    } else {
        return YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) doneButtonTapped:(id)doneButton {
    SFChangePasswordView *changePwView = (SFChangePasswordView *)self.view;
    if ([changePwView.confirmNewPwField.text isEmpty] || [changePwView.currentPwField.text isEmpty] || [changePwView.enterNewPwField.text isEmpty]) {
        [AlertUtils showModalAlertMessage:NSLocalizedString(@"Please enter current password, new password and new password confirmation.", nil) withTitle:[[SFAppConfig sharedInstance] getAppAlertTitle]];
    } else if ([changePwView.enterNewPwField.text
                isEqualToString:changePwView.confirmNewPwField.text] == NO) {
        [AlertUtils showModalAlertMessage:NSLocalizedString(@"New and confirmation passwords do not match.  Please re-enter matching passwords.", nil) withTitle:[[SFAppConfig sharedInstance] getAppAlertTitle]];
    } else if ([changePwView.currentPwField.text isEqualToString:[ContentUtils getPasswordFromKeychain]] == NO) {
        [AlertUtils showModalAlertMessage:NSLocalizedString(@"Current password does not match stored password.  Please re-enter current password.", nil) withTitle:[[SFAppConfig sharedInstance] getAppAlertTitle]];
    } else {
        [ContentUtils setPasswordInKeychain:changePwView.enterNewPwField.text];
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}

- (void) cancelButtonTapped:(id)cancelButton {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Keyboard Management Methods

- (void)addKeyboardListeners {
	NSNotificationCenter *noteCenter = [NSNotificationCenter defaultCenter];
	[noteCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[noteCenter addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void) removeKeyboardListeners {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
	[self resignFirstResponderIfPossible];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    
	if (self.navigationController.topViewController == self || self.presentingViewController. presentedViewController == self) {
		NSDictionary* userInfo = [notification userInfo];
		
		// we don't use SDK constants here to be universally compatible with all SDKs ≥ 3.0
		NSValue* keyboardFrameValue = [userInfo objectForKey:@"UIKeyboardBoundsUserInfoKey"];
		if (!keyboardFrameValue) {
			keyboardFrameValue = [userInfo objectForKey:@"UIKeyboardFrameEndUserInfoKey"];
		}
		
		// Find out how much of the keyboard overlaps the textfield and move the view up out of the way
		CGRect windowRect = [[UIApplication sharedApplication] keyWindow].bounds;
        if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
            if ((UIInterfaceOrientationLandscapeLeft == self.interfaceOrientation ||UIInterfaceOrientationLandscapeRight == self.interfaceOrientation)) {
                windowRect = [self swapRect:windowRect];
            }
        }
		
		UITextField *tf = (UITextField *)self.currentFirstResponder;
		
		CGRect viewRectAbsolute = [tf convertRect:tf.bounds toView:[[UIApplication sharedApplication] keyWindow]];
        
        if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
            if ((UIInterfaceOrientationLandscapeLeft == self.interfaceOrientation ||UIInterfaceOrientationLandscapeRight == self.interfaceOrientation)) {
                viewRectAbsolute = [self swapRect:viewRectAbsolute];
            }
        }
        
        if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
            // Need to adjust the y value since the cooridnate system is flipped.
            if ((UIInterfaceOrientationLandscapeRight == self.interfaceOrientation || UIInterfaceOrientationPortraitUpsideDown == self.interfaceOrientation)) {
                viewRectAbsolute.origin.y = windowRect.size.height -   viewRectAbsolute.origin.y - tf.frame.size.height;
                
            }
        }
        
        SFChangePasswordView *pwView = (SFChangePasswordView *)self.view;
		CGRect frame = pwView.roundedView.frame;
		CGRect keyboardRect = [keyboardFrameValue CGRectValue];
		
		_previousViewOriginY = frame.origin.y;
		CGFloat adjustUpBy = (windowRect.size.height - keyboardRect.size.height) - (CGRectGetMaxY(viewRectAbsolute) + 10.0f);
		
        if (adjustUpBy != 0) {
            if (adjustUpBy < 0) {
                frame.origin.y += adjustUpBy;
            } else {
                frame.origin.y = _actualOriginY;
            }
            
            // Put in adjustment for iOS7 (This class should be deprecated at some point.  Kept around for iPOS)
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
                if (self.edgesForExtendedLayout == UIRectEdgeNone &&
                    self.navigationController &&
                    self.navigationController.navigationBarHidden == NO) {
                    // Make sure the view is not underneath the nav bar
                    float reservedHeight = 44.0f;
                    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
                        reservedHeight = 32.0f;
                    }
                    if ([UIApplication sharedApplication].statusBarHidden == NO) {
                        reservedHeight += 20.0f;
                    }
                    
                    if (frame.origin.y < reservedHeight) {
                        frame.origin.y += reservedHeight + 5.0f;
                    }
                }
            }
            
			[UIView beginAnimations:nil context:NULL];
            NSTimeInterval duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue] != 0 ?
            [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue] : 0.3;
			[UIView setAnimationDuration:duration];
			[UIView setAnimationCurve:[[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
            SFChangePasswordView *pwView = (SFChangePasswordView *)self.view;
			pwView.roundedView.frame = frame;
			[UIView commitAnimations];
        }
        
		// iOS 3 sends hide and show notifications right after each other
		// when switching between textFields, so cancel -scrollToOldPosition requests
		[NSObject cancelPreviousPerformRequestsWithTarget:self];
	}
}

- (void)keyboardWillHide:(NSNotification *)notification {
	if (self.navigationController.topViewController == self || self.presentingViewController. presentedViewController == self) {
		NSDictionary* userInfo = [notification userInfo];
		
        SFChangePasswordView *pwView = (SFChangePasswordView *)self.view;
		CGRect frame = pwView.roundedView.frame;
		if (frame.origin.y != _actualOriginY) {
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationDuration:[[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
			[UIView setAnimationCurve:[[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
			frame.origin.y = _actualOriginY;
			pwView.roundedView.frame = frame;
			[UIView commitAnimations];
		}
        
        _previousViewOriginY = _actualOriginY;
	}
}

#pragma mark -
#pragma mark UITextField delegates
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	self.currentFirstResponder = textField;
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	self.currentFirstResponder = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self.currentFirstResponder resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

#pragma mark -
#pragma mark Utility methods
- (CGRect) swapRect:(CGRect)rect
{
	return CGRectMake(rect.origin.y, rect.origin.x, rect.size.height, rect.size.width);
}

- (void) resignFirstResponderIfPossible {
	if (self.currentFirstResponder != nil && [self.currentFirstResponder canResignFirstResponder]) {
		[self.currentFirstResponder resignFirstResponder];
	}
}

@end
