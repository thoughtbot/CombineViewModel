#import "CombineViewModelObjC.h"
#ifdef COMBINEVM_HAS_FOUNDATION
#import <Foundation/Foundation.h>
#import <objc/runtime.h>

NSNotificationName CombineViewModelViewDidLoad = @"CombineViewModelViewDidLoad";

static void *kIsHooked = &kIsHooked;
static Class _UIViewController;

__attribute__((constructor))
static void
_combinevm_init(void)
{
  _UIViewController = NSClassFromString(@"UIViewController");
}

static void
_combinevm_enumerate_hierarchy(id object, void (^block)(Class klass, BOOL *stop))
{
  Class class_iter = object_getClass(object);
  BOOL stop = NO;

  while (class_iter != nil && !stop) {
    block(class_iter, &stop);
    class_iter = class_getSuperclass(class_iter);
  }
}

static BOOL
_combinevm_object_hooked(id object)
{
  __block BOOL isHooked = NO;
  _combinevm_enumerate_hierarchy(object, ^(Class klass, BOOL *stop) {
    if ([objc_getAssociatedObject(klass, kIsHooked) boolValue]) {
      isHooked = YES;
      *stop = YES;
    } else if (klass == _UIViewController) {
      *stop = YES;
    }
  });
  return isHooked;
}

void
_combinevm_hook_viewDidLoad(id object)
{
  const Class object_class = object_getClass(object);
  const SEL viewDidLoad_SEL = sel_registerName("viewDidLoad");
  __block IMP original_viewDidLoad_IMP;
  IMP new_viewDidLoad_IMP;
  Method viewDidLoad;

  NSCAssert([object isKindOfClass:_UIViewController], @"Object '%@' is not an instance of UIViewController", object);

  if (_UIViewController == nil || _combinevm_object_hooked(object)) {
    return;
  }

  viewDidLoad = class_getInstanceMethod(object_class, viewDidLoad_SEL);
  NSCAssert(viewDidLoad != nil, @"Object '%@' appears to subclass UIViewController, but does not implement -viewDidLoad.", object);

  new_viewDidLoad_IMP = imp_implementationWithBlock(^(id object, SEL _cmd) {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    void (*viewDidLoad)(id, SEL) = (void (*)(id, SEL))original_viewDidLoad_IMP;
    viewDidLoad(object, _cmd);
    [center postNotificationName:CombineViewModelViewDidLoad object:object];
  });
  original_viewDidLoad_IMP = method_setImplementation(viewDidLoad, new_viewDidLoad_IMP);
  objc_setAssociatedObject(object_class, kIsHooked, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
#else // COMBINEVM_HAS_FOUNDATION
static void
_combinevm_dummy(void)
{
}
#endif // COMBINEVM_HAS_FOUNDATION
