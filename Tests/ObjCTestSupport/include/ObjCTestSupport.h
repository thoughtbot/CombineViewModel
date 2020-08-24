#if defined(__has_include)
# if __has_include(<UIKit/UIKit.h>)
#  define COMBINEVM_HAS_UIKIT 1
# endif
#
# if __has_include(<UIKit/UIViewController.h>)
#  define COMBINEVM_HAS_UIVIEWCONROLLER 1
# endif
#endif

#if COMBINEVM_HAS_UIKIT && COMBINEVM_HAS_UIVIEWCONROLLER
#import <UIKit/UIKit.h>

@interface TestObjCViewController : UIViewController

@property (nonatomic, readonly, nullable) SEL viewDidLoadSelector;

@end

#endif // COMBINEVM_HAS_UIKIT && COMBINEVM_HAS_UIVIEWCONROLLER
