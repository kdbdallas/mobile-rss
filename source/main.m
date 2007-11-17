#import </usr/include/objc/objc-class.h>
#import <UIKit/UIKit.h>
#import "RSS.h"

int main(int argc, char *argv[])
{
     NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

     return UIApplicationMain(argc, argv, [MobileRSS class]);
}

//Takes the place of automatically generated objc function until the toolchain is fixed for this function
double objc_msgSend_fpret(id self, SEL op, ...) 
{
	Method method = class_getInstanceMethod(self->isa, op);
	int numArgs = method_getNumberOfArguments(method);
	
	if(numArgs == 2) {
		double (*imp)(id, SEL);
		imp = (double (*)(id, SEL))method->method_imp;
		return imp(self, op);
	} else if(numArgs == 3) {
		// FIXME: this code assumes the 3rd arg is 4 bytes
		va_list ap;
		va_start(ap, op);
		double (*imp)(id, SEL, void *);
		imp = (double (*)(id, SEL, void *))method->method_imp;
		return imp(self, op, va_arg(ap, void *));
	}
	
	// FIXME: need to work with multiple arguments/types
	fprintf(stderr, "ERROR: objc_msgSend_fpret, called on <%s %p> with selector %s, had to return 0.0\n", object_getClassName(self), self, sel_getName(op));
	return 0.0;	
}