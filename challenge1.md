<h1>Reverse Engineering Challenge #1</h1>
<i>What does this code do? The function has 4 arguments and it is compiled by GCC for Linux x64 ABI (i.e., arguments are passed in registers).</i>
<pre><code>
&ltf&gt:
   0:                   mov    r8,rdi
   3:                   push   rbx
   4:                   mov    rdi,rsi
   7:                   mov    rbx,rdx
   a:                   mov    rsi,r8
   d:                   xor    rdx,rdx

begin:
  10:                   lods   rax,QWORD PTR ds:[rsi]
  12:                   div    rbx
  15:                   stos   QWORD PTR es:[rdi],rax
  17:                   loop   begin
  19:                   pop    rbx
  1a:                   mov    rax,rdx
  1d:                   ret
</code></pre>
<h3>Analysis</h3>
Most tutorial that you will find on assembly talk about the EAX, EBX, EDX, ECX registers.
They are 32 bit registers. In the problem above we have RAX, RBX, RCX, RDX. The R indicates these are 64 bit registers in the x86_64 architecture.
A handy explanation of registers in x64 can be found [here](https://docs.microsoft.com/en-us/windows-hardware/drivers/debugger/x64-architecture).
<h4>ASM Syntax</h4>
Most AMS instructions take the form <code>COMMAND destination source</code> or <code>COMMAND source</code>.<br>
<b>MOV</b>: Moves source to destination<br>
<b>PUSH</b>: pushes source onto the stack in a first-in-last-out basis.<br>
<b>POP</b>: Pops the last-in value from stack to destination.<br>
<b>XOR</b>: bitwise XOR. Result goes in destination.<br>
<b>DIV</b>: Unsigned Division. For 64 bit division, the high order bits of the dividend will be in RDX and the low order in RAX. The resulting quotient goes in RAX and remainder in RDX.<br>
<b>LODS</b>: Load String from Memory into RAX, EAX, AX, AL depending on length.
<b>STOS</b>: Stores registry data into memory (string).
String instruction may use combination register DS:RSI where DS is data segment or ES:RDI where ES is extra segment<br>
<b>LOOP</b>: The loop count is stored in RCX. LOOP jumps to the specified label until RCX<=0 decrementing RCX on each iteration.
<b>[]</b>: Indicates a memory address, which could be an array.
<h4>Registers</h4>
<b>rsi, rdi</b>: source and destination index for string operations
<b>rax, rbx, rdx</b>: Data registers (Accumulator, Base, Data). Both rax and rdx are used for input/output/arithmetic. rbx often used for indexed addressing.<br>
<br>
<h3>What does this function do</h3>
Stack: |rbp|rsp|<br>
Line 0,4,7 10: These lines together result in the values stored in rsi and rdi being swaped.<br>
Line 3: saves contents of rbx to stack.<br>
Stack: |rbp|rbx|esp|<br>
Line 13: clears the rdx register<br>
Start of loop<br>
Reading further down we see the loop command, but the rcx register is not evident, thus we know not how many time the loop will excute.<br>
It may result in a memory violation.<br>
Inide the loop are the commands lods, div & stos. Load from memory divide by by valu in rbx and put back to memory.<br>
The rdi and rsi registers do not apear to be modified and there is no offset apparent, so it would seem that the same memory reference will be repeated divided by some value in rbx.<br>
Finally the original value of rbx is reinstated (from stack) and the remainder after the modulus operations is stored in rax.<br>
<br>
<h3>Summary</h3>
This function is repeatedly doing a divsion, dividing the result of the last division by the same divisor.
However because the value of RCX register is unknown, but is used by the LOOP command it is highly likely that this program will segfault.
Also the RET command is only required if this code is implemented as a function being called with the CALL command.
