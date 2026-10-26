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
    char core[PATH_MAX], lib[PATH_MAX], textHook[PATH_MAX], libraries[PATH_MAX * 2];
    snprintf(core, sizeof(core), "%s/RexCore", dir);
    snprintf(lib, sizeof(lib), "%s/../Frameworks/libRexChinese.dylib", dir);
    snprintf(textHook, sizeof(textHook), "%s/../Frameworks/libRexTextHook.dylib", dir);
    setenv("AppleLanguages", "(zh-Hans)", 1);
    setenv("AppleLocale", "zh_CN", 1);
    snprintf(libraries, sizeof(libraries), "%s:%s", lib, textHook);
    setenv("DYLD_INSERT_LIBRARIES", libraries, 1);
    execv(core, argv);
    perror("RexCore");
    return 127;
}
