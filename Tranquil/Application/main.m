#import <RubyCocoa/RubyCocoa.h>

int main(int argc, const char *argv[])
{
    RBApplicationInit("rb_main.rb", argc, argv, nil);

	return NSApplicationMain(argc, argv);
}
