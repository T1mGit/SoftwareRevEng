.text
.global _start
_start:
mov %rdi, %r8
push %rbx
mov %rsi, %rdi
mov %rdx, %rbx
mov %r8, %rsi
xor %rdx, %rdx

begin:
lods %ds:(%rsi), %rax
div %rbx
stos %rax, %es:(%rdi)
loop begin
pop %rbx
mov %rdx, %rax

