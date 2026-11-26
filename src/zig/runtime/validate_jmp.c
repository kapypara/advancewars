#include <setjmp.h>
#include <stdint.h>

static jmp_buf g_validate_jmp;

int awre_validate_call0(void (*fn)(void)) {
    if (setjmp(g_validate_jmp) != 0) {
        return 1;
    }
    fn();
    return 0;
}

int awre_validate_call_u32(void (*fn)(uint32_t), uint32_t arg) {
    if (setjmp(g_validate_jmp) != 0) {
        return 1;
    }
    fn(arg);
    return 0;
}

void awre_validate_abort(void) {
    longjmp(g_validate_jmp, 1);
}
