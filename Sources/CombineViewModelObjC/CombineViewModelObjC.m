#import "CombineViewModelObjC.h"
#ifdef COMBINEVM_HAS_FOUNDATION
#import <Foundation/Foundation.h>
#import <objc/runtime.h>

NSNotificationName CombineViewModelViewDidLoad = @"CombineViewModelViewDidLoad";

void *CombineViewModelIsHookedKey = &CombineViewModelIsHookedKey;
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

static Method
_combinevm_object_getInstanceMethod(id object, SEL selector, Class *actual_class)
{
  __block Class found_class;
  __block Method found_method;

  _combinevm_enumerate_hierarchy(object, ^(Class klass, BOOL *stop) {
    Method method, *method_list;
    SEL method_selector;
    unsigned int i, count;

    method_list = class_copyMethodList(klass, &count);

    for (i = 0; i < count; i++) {
      method = method_list[i];
      method_selector = method_getName(method);

      if (method_selector == selector) {
        found_class = klass;
        found_method = method;
        *stop = YES;
        break;
      }
    }
  });

  if (actual_class != nil) {
    *actual_class = found_class;
  }

  return found_method;
}

static BOOL
_combinevm_object_hooked(id object)
{
  __block BOOL isHooked = NO;
  _combinevm_enumerate_hierarchy(object, ^(Class klass, BOOL *stop) {
    if ([objc_getAssociatedObject(klass, CombineViewModelIsHookedKey) boolValue]) {
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
  Class viewDidLoad_class;
  Method viewDidLoad;

  NSCAssert([object isKindOfClass:_UIViewController], @"Object '%@' is not an instance of UIViewController", object);

  if (_UIViewController == nil || _combinevm_object_hooked(object)) {
    return;
  }

  viewDidLoad = _combinevm_object_getInstanceMethod(object, viewDidLoad_SEL, &viewDidLoad_class);
  NSCAssert(viewDidLoad != nil, @"Object '%@' appears to subclass UIViewController, but does not implement -viewDidLoad.", object);

  new_viewDidLoad_IMP = imp_implementationWithBlock(^(id object, SEL _cmd) {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    void (*viewDidLoad)(id, SEL) = (void (*)(id, SEL))original_viewDidLoad_IMP;
    viewDidLoad(object, _cmd);
    [center postNotificationName:CombineViewModelViewDidLoad object:object];
  });
  original_viewDidLoad_IMP = method_setImplementation(viewDidLoad, new_viewDidLoad_IMP);
  objc_setAssociatedObject(viewDidLoad_class, CombineViewModelIsHookedKey, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
#else // COMBINEVM_HAS_FOUNDATION
static void
_combinevm_dummy(void)
{
}
#endif // COMBINEVM_HAS_FOUNDATION
