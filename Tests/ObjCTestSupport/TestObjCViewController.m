#import "ObjCTestSupport.h"

#if COMBINEVM_HAS_UIKIT && COMBINEVM_HAS_UIVIEWCONROLLER

@implementation TestObjCViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  _viewDidLoadSelector = _cmd;
}

@end

#endif // COMBINEVM_HAS_UIKIT && COMBINEVM_HAS_UIVIEWCONROLLER
