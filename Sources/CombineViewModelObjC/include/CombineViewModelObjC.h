#if defined(__has_include)
# if __has_include(<Foundation/NSNotification.h>)
#  define COMBINEVM_HAS_FOUNDATION
# endif
#endif

#ifdef COMBINEVM_HAS_FOUNDATION
#import <Foundation/NSNotification.h>

@class UIViewController;

FOUNDATION_EXPORT NSNotificationName CombineViewModelViewDidLoad NS_SWIFT_NAME(UIViewController.viewDidLoadNotification);

void _combinevm_hook_viewDidLoad(id object);
#endif // COMBINEVM_HAS_FOUNDATION
