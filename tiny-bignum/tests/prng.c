#include "bn.h"
#include <string.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

void test_random(void)
{
    struct entropy_pool pool = {0};
    int entropy = 0x12357;
    for (int i = 0; i < 16; ++i)
    {
        mix_pool(entropy, &pool);
    }
    entropy = 0xfdf661b;
    for (int i = 0; i < 16; ++i)
    {
        mix_pool(entropy, &pool);
    }

    int fd = open("/dev/urandom", O_RDONLY);
    if (fd == -1)
        err(1, "cannot open");
    for (int i = 0; i < 1000; ++i)
    {
        read(fd, &entropy, 1);
        mix_pool(entropy, &pool);
    }
    uint8_t a[8];
    while (1)
    {
        for (int i = 0; i < 8; ++i)
            a[i] = get_random(&pool);
        write(1, &a, 8);
        read(fd, &entropy, 1);
        mix_pool(entropy, &pool);
    }
    close(fd);
}

int main(void)
{
    test_random();
}
