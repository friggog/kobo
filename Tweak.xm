@import WebKit;
#import "UIKit/_UIBackdropView.h"

static inline UIColor *UIColorFromHexString(NSString *hexString) {
    unsigned rgbValue = 0;
    if (! hexString) {
        return [UIColor clearColor];
    }

    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1];
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16) / 255.0 green:((rgbValue & 0xFF00) >> 8) / 255.0 blue:(rgbValue & 0xFF) / 255.0 alpha:1.0];
}

@interface SafariWebView : WKWebView
@end
@interface _SFToolbar : UIView {
	_UIBackdropView *_backgroundView;
}
@end
@interface _SFNavigationBar : UIView {
	_UIBackdropView* _backdrop;
}
@end

static NSMutableArray *bars = [NSMutableArray array];

%hook SafariWebView

- (id)loadRequest:(NSURLRequest *)request {
	id o = %orig;
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		[self evaluateJavaScript:@"document.getElementsByName('theme-color')[0].getAttribute('content')"
			   completionHandler:^(NSString *r, NSError *e){
					UIColor *col = UIColorFromHexString(r);
					for(id b in bars) {
						LOG(@"%@",b);
						_UIBackdropView *bg = NULL;
						if([b isKindOfClass:%c(_SFToolbar)]) {
							bg = MSHookIvar<_UIBackdropView *>(b,"_backgroundView");
						}
						else {
							bg = MSHookIvar<_UIBackdropView *>(b,"_backdrop");
						}
						[bg transitionToColor:col];
					}
		}];
	});
	return o;
}

%end

%hook _SFToolbar

-(id)initWithPlacement:(long long)arg1 {
	id o = %orig;
	[bars addObject:o];
	return o;
}

-(void) dealloc {
	[bars removeObject:self];
	%orig;
}

%end

%hook _SFNavigationBar

-(id)initWithFrame:(CGRect)arg1 inputMode:(unsigned long long)arg2  {
	id o = %orig;
	[bars addObject:o];
	return o;
}

-(void) dealloc {
	[bars removeObject:self];
	%orig;
}

%end
