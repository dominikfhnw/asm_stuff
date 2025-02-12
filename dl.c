#include "mini-dl.h"
#include <stdio.h>
#include <stdlib.h>

#include <gnu/lib-names.h>  /* Defines LIBM_SO (which will be a
			       string such as "libm.so.6") */

int main(){
	void *handle;
	//double (*cosine)(double);
	int (*puts)(const char *);
	char *error;

	handle = dlopen("libc.so.6", RTLD_LAZY);

#ifdef DEBUG
	if (!handle) {
		fprintf(stderr, "%s\n", dlerror());
		exit(EXIT_FAILURE);
	}

	dlerror();    /* Clear any existing error */
#endif

	//cosine = (double (*)(double)) dlsym(handle, "cos");
	puts = dlsym(handle, "puts");

	/* According to the ISO C standard, casting between function
	   pointers and 'void *', as done above, produces undefined results.
	   POSIX.1-2001 and POSIX.1-2008 accepted this state of affairs and
	   proposed the following workaround:

	 *(void **) (&cosine) = dlsym(handle, "cos");

	 This (clumsy) cast conforms with the ISO C standard and will
	 avoid any compiler warnings.

	 The 2013 Technical Corrigendum 1 to POSIX.1-2008 improved matters
	 by requiring that conforming implementations support casting
	 'void *' to a function pointer.  Nevertheless, some compilers
	 (e.g., gcc with the '-pedantic' option) may complain about the
	 cast used in this program. */

#ifdef DEBUG
	error = dlerror();
	if (error != NULL) {
		fprintf(stderr, "%s\n", error);
		exit(EXIT_FAILURE);
	}
#endif

	puts("hello world");
//	printf("%f\n", cosine(2.0));
//	dlclose(handle);
//	exit(EXIT_SUCCESS);
}
