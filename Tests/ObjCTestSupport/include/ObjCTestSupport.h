#if defined(__has_include)
# if __has_include(<UIKit/UIKit.h>)
#  define COMBINEVM_HAS_UIKIT
# endif
#endif

#ifdef COMBINEVM_HAS_UIKIT
#import <UIKit/UIKit.h>

@interface TestObjCViewController : UIViewController

@property (nonatomic, readonly, nullable) SEL viewDidLoadSelector;

@end

#endif // COMBINEVM_HAS_UIKIT
