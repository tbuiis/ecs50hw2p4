.global _start
.equ ws, 4

.data

# everything will be callee saves, arguments from memory, return memory

string1:
    .byte 'f','l','a','w',0
    .rept 101-5 # space for 101 bytes
    .byte 0
    .endr

string2:
    .byte 'l','a','w','n',0
    .rept 101-5 # space for 101 bytes
    .byte 0
    .endr

intA:
    .long 0

intB:
    .long 0

intMin:
    .long 0

ptrA:
    .long 0

ptrB:
    .long 0

strlen_arg:
    .long 0

strlen_len:
    .long 0

word1_len:
    .long 0

word2_len:
    .long 0

tempPtr:
    .long 0

oldDist:
    .rept 101
    .long 0
    .endr

curDist:
    .rept 101
    .long 0
    .endr

dist:
    .long 0



.text

min_start:  # int min(int a, int b) function
    # eax will be A
    # ebx will be B

    push %eax
    push %ebx

    # return a <b ? a:b is equivalent to
    # if( a<b) return a, else return b

    movl intA, %eax    # move intA from mem into eax
    movl intB, %ebx    # move intB from mem into ebx

    comparison_start:
        # if (a<b) = a-b < 0
        cmpl %ebx, %eax     # so if a-b is less than 0, that means a is smaller
        jl aSmaller         # therefore jump to aSmaller

        aBigger:            # this is the else part
        movl %ebx, intMin   # if a bigger, put min b into int min
        jmp comparison_end  # jump to end loop so dont accidently run asmaller code

        aSmaller:
        movl %eax, intMin   # if a smaller, put min a into int min
        jmp comparison_end  # this jump doesnt really matter but makes it understandable

    comparison_end:

    pop %ebx
    pop %eax

    ret
min_end:

swap_start:     # void swap(int** a, int** b) function
    # %eax will be ptr A
    # %ebx will be ptr B
    # %ecx will be temporaryA (doesnt need to save)
    # %edx will be temporaryB (doesnt need to save)

    push %eax
    push %ebx
    push %ecx
    push %edx

    movl ptrA, %eax # puts ptrA in eax
    movl ptrB, %ebx # puts ptrB in eax

    # int* temp = *a
    movl (%eax), %ecx

    movl (%ebx), %edx   # just put *b into edx, so u don't compare mem w mem

    #*a = *b (using temp b instead of *b because cant do mem to mem)
    movl %edx, (%eax)

    #*b = temp 
    movl %ecx, (%ebx)   # uses tempA because cant do mem to mem

    pop %edx
    pop %ecx
    pop %ebx
    pop %eax

    ret
swap_end:

str_len_start:  # strlen that will be used inside of editDist
    # str will be in strlen_arg
    # return value will be in strlen_len
    # callee is responsible for saving regs

    # ebx is count
    # ecx will be the str

    push %ebx
    push %ecx

    movl strlen_arg, %ecx   # ecx = str

    # int count = 0;
    movl $0, %ebx   # count = 0;

    # while(str[count]!= '\0')
    strlen_loop_start:
        # str[count] != '\0'
        # str[count] - '\0' != 0
        # neg: str[count] - '\0' == 0
        cmpb $0, (%ecx, %ebx, 1) # str[count] - '\0'
        je strlen_loop_end
        incl %ebx   # count++;
        jmp strlen_loop_start
    strlen_loop_end:

    # return count into strlen_len;
    movl %ebx, strlen_len

    pop %ecx
    pop %ebx
    ret
str_len_end:

editDist_start:
    # ecx will be i
    # edx will be j
    # going to push and pop all just to make sure they are all saved
    push %eax
    push %ebx
    push %ecx
    push %edx
    push %esi
    push %ebp

    # int word1_len = strlen(word1);
    movl $string1, strlen_arg   # sets ADDRESS of string1 into strlen_arg for strlen call
    call str_len_start          # finds length of string1
    movl strlen_len, %ecx       # puts strlen_len in temp reg, so i can store it into mem
    movl %ecx, word1_len        # now puts it into memory

    # int word2_len = strlen(word2);
    movl $string2, strlen_arg   
    call str_len_start          
    movl strlen_len, %ecx       
    movl %ecx, word2_len

    # int* oldDist = (int*)malloc((word2_len + 1) * sizeof(int));
    # int* curDist = (int*)malloc((word2_len + 1) * sizeof(int));
    # these two lines are just made space in the .data section, not real code


    # for(i = 0; i < word2_len + 1; i++){
    # start with i = 0;
    movl $0, %ecx

    initialize_loop_start:
        # i< word2_len +1
        # i - word2_len -1 < 0
        # do neg: i - word2_len -1 >= 0 
        movl word2_len, %esi    # esi = word2_len
        incl %esi               # esi = word2_len + 1
        cmpl %esi, %ecx         # i - word2_len -1 >= 0
        jge initialize_loop_end

        # using eax temporarily for olddist
        # using ebx temporarily for curdist
        movl $oldDist, %eax
        movl $curDist, %ebx
        movl %ecx, (%eax, %ecx, 4)
        movl %ecx, (%ebx, %ecx, 4)

        incl %ecx
        jmp initialize_loop_start

    initialize_loop_end:

    # now that this loop ended, going to put olddist + curdist back into mem
    # and put string1 and string2 back into eax

    movl $string1, %eax # eax is holding the address of string 1 now
    movl $string2, %ebx  # ebx is holding the address of string 2 now

    # for(i = 1; i < word1_len + 1; i++)
    movl $1, %ecx
    outer_for_start:
        # i< word1_len +1
        # i - word1_len -1 < 0
        # neg: 1 - word1_len -1 >= 0, 
        movl word1_len, %esi    # esi = word1_len
        incl %esi               # esi = word1_len +1
        cmpl %esi, %ecx         # i - word1_len -1
        jge outer_for_end

        # curDist[0] = i;
        movl %ecx, curDist

        # for(j = 1; j < word2_len + 1; j++)
        movl $1, %edx           # j = 1
        inner_for_start:
            # j < word2_len +1;
            # j - word2_len -1 <0
            # neg: j - word2_len -1 >= 0
            movl word2_len, %edi    # edi = word2_len
            incl %edi               # edi = word2_len +1
            cmpl %edi, %edx         # j - word2_len -1
            jge inner_for_end     # if >=0 go to end of outer loop

            if_start:
                movl $string1, %eax
                movl $string2, %ebx
                movb -1(%eax,%ecx,1), %al  # move word[i-1] into %eax (%al is lower 8)
                cmpb -1(%eax,%edx,1), %al  # move word[j-1] into %ebx (%bl is lower 8)

                je chars_equal

                
                chars_notequal:

                # min(oldDist[j], curDist[j-1])
                movl oldDist(,%edx,4), %eax     # moves oldDist into eax
                movl (curDist -4)(,%edx,4), %ebx   # moves curdist into ebx
                movl %eax, intA             # puts into memory for intA
                movl %ebx, intB             # puts into memory for intB
                call min_start              # calls func
                movl intMin, %eax           # gets min, and puts into eax

                # min( whatever from first min, oldDist[j-1]) +1
                movl oldDist-4(,%edx,4), %ebx   # moves oldDist[j-1] into ebx
                movl %eax, intA                 # moves last min into intA
                movl %ebx, intB                 # moves oldDist[j-1] into intB
                call min_start                  # calls func
                movl intMin, %eax               # gets intMin and puts into eax
                incl %eax                       # now is the entire right side, with the +1

                # curDist[j] = right side (held in eax)
                movl %eax, curDist(,%edx,4)
                jmp if_end
        
                chars_equal:
                movl oldDist, %esi           # load pointer
                movl (%esi,%edx,4), %eax     # eax = oldDist[j-1]
                movl curDist, %edi           # load pointer
                movl %eax, (%edi,%edx,4)     # curDist[j] = eax    



            if_end:

            incl %edx           # j++
            jmp inner_for_start # jump back to inner for start
        inner_for_end:

        # swap(&oldDist, &curDist);
        movl oldDist, %eax
        movl curDist, %ebx
        movl %ebx, oldDist
        movl %eax, curDist

        incl %ecx               # i++
        jmp outer_for_start     # jump back to outer for start
    outer_for_end:

    # dist = oldDist[word2_len] (also is the return dist)
    movl word2_len, %eax        # word2_len into eax
    movl oldDist(,%eax,4), %ebx # oldDist[word2_len] into ebx
    movl %ebx, %eax             # dist is now in ebx

    pop %ebp
    pop %esi
    pop %edx
    pop %ecx
    pop %ebx
    pop %eax

    ret
editDist_end:



_start:


done:
    nop
