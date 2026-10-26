#include <libgen.h>
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

int main(int argc, char **argv) {
    char here[PATH_MAX];
    if (!realpath(argv[0], here)) return 127;
    char *dir = dirname(here);
    char core[PATH_MAX], lib[PATH_MAX];
    snprintf(core, sizeof(core), "%s/RexCore", dir);
    snprintf(lib, sizeof(lib), "%s/../Frameworks/libRexChinese.dylib", dir);
    setenv("DYLD_INSERT_LIBRARIES", lib, 1);
    execv(core, argv);
    perror("RexCore");
    return 127;
}
