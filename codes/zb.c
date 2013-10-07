#include <stdio.h>
#include <string.h>
#define fo2_bug(ins, outs) _fo2_bug(ins, outs, strlen(ins))
void _fo2_bug(char *ins, char *outs, int len)
{
        (!ungetc(*ins, stdin) ? : _fo2_bug(ins+1, outs, len - 1), *(outs + len - 1) = getchar());
}

int main()
{
        char buf[32];
        char *a = "2b sunus";
        fo2_bug(a, buf);
        buf[strlen(a)] = '\0';
        return 0;
}
