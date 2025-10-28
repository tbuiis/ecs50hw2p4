.global _start

.data

num1: # address 100
   .long 0x11111111 # address 100,
   .long 0x22222222 # address 104


num2: # address 108
   .long 0x33333333 # address 108
   .long 0x44444444 # address 112


.text

_start:
   # Adding the lower bits
   movl num1 + 4, %eax # EAX = *(num1 + 4);
   addl num2 + 4, %eax # EAX += *(num2 + 4);

   # Adding the upper bits
   movl num1, %edx # EDX = *num1;
   adcl num2, %edx # EDX += *num2;

done:
   nop
   