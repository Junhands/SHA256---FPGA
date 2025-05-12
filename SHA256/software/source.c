#include <stdio.h>
#include <stdint.h>
#include <inttypes.h>
#include "system.h"
#include "io.h"

#define NUMBER_OF_TESTCASE 2  

const uint32_t inputs[NUMBER_OF_TESTCASE][16] = {
    {0x61626380,0x00000000,0x00000000,0x00000000,
     0x00000000,0x00000000,0x00000000,0x00000000,
     0x00000000,0x00000000,0x00000000,0x00000000,
     0x00000000,0x00000000,0x00000000,0x00000018},
    {0x636f6e67,0x64657074,0x72616980,0x00000000,
     0x00000000,0x00000000,0x00000000,0x00000000,
     0x00000000,0x00000000,0x00000000,0x00000000,
     0x00000000,0x00000000,0x00000000,0x00000058},
     // insert your testcase here

     //
};

void sendMessage(const uint32_t input[16]) {
    int i;
    for (i = 0; i < 16; i++) {
        IOWR(SHA256_AVALON_0_BASE, i, input[i]);
    }
    IOWR(SHA256_AVALON_0_BASE, 16, 0x3);

    while (!(IORD(SHA256_AVALON_0_BASE, 16) & 0x1) );
    IOWR(SHA256_AVALON_0_BASE, 16, 0x4);
}

void hashedMessage() {
    uint32_t hash[8];
    int i;
    for (i = 0; i < 8; i++) {
        hash[i] = IORD(SHA256_AVALON_0_BASE, 0x80 + i);
    }

    for (i = 0; i < 8; i++) {
        printf("%08" PRIx32, hash[i]);
    }
    printf("\n");
}

int main() {
    int k;
    for (k = 0; k < NUMBER_OF_TESTCASE; k++) {
        printf("TESTCASE %d: ", k+1);
        sendMessage(inputs[k]);
        hashedMessage();
    }

    return 0;
}