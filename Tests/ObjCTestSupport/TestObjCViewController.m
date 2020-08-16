#import "ObjCTestSupport.h"

#ifdef COMBINEVM_HAS_UIKIT

@implementation TestObjCViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  _viewDidLoadSelector = _cmd;
}

@end

#endif // COMBINEVM_HAS_UIKIT
