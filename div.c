#include <stdio.h>
#include <stdlib.h>

unsigned int stringToUnsigned(const char *str)
{
    unsigned int num = 0;
    int i = 0;

    while(str[i]!= '\0')
    {
        char c = str[i];

        num = num*10 + (c - '0');
        i++;
    
    }
    return num;
}

void divide(unsigned int dividend, unsigned int divisor, unsigned int *quotient, unsigned int *remainder)
{
    *quotient = 0;
    *remainder = 0;

    for(int i = 31; i>=0; i--)
    {
        *remainder = *remainder <<1;
        *remainder |= (dividend >> i) &1;

        if(*remainder >= divisor)
        {
            *remainder -= divisor;
            *quotient |= (1 <<i);
        }

    }
}

int main(int argc, char *argv[])
{
    unsigned int dividend = stringToUnsigned(argv[1]);
    unsigned int divisor = stringToUnsigned(argv[2]);
    unsigned int quotient;
    unsigned int remainder;

    divide(dividend, divisor, &quotient, &remainder);

    printf("%u / %u = %u R %u\n", dividend, divisor, quotient, remainder);

}





