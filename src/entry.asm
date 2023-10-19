MULTIBOOT2_MAGIC_NUMBER equ 0xE85250D6
ARCHITECHTURE equ 0                                     ; architecture 0 is 32bit protected mode
; HEADER_LENGTH equ 0x10
; CHECKSUM equ -(MULTIBOOT2_MAGIC_NUMBER+HEADER_LENGTH+ARCHITECHTURE)

global loader
loader:
    jmp _start


section .multiboot
align 8
multiboot_header_start:
    dd MULTIBOOT2_MAGIC_NUMBER 
    dd ARCHITECHTURE
    dd multiboot_header_end-multiboot_header_end-1
    dd 0x100000000 -(MULTIBOOT2_MAGIC_NUMBER+ARCHITECHTURE+multiboot_header_end-multiboot_header_start)
information_request_start:
    dw 1                                                    ; Information request tag type
    dw 0                                                    ; No flags
    dd information_request_end - information_request_start  ; size of informtion tag
    dd tags_requested                                       ; start of array of tags requested
tags_requested:
    dd 6
information_request_end:
framebuffer_tag_start:
    dw 5                                                    ; Framebuffer tag type
    dw 0                                                    ; No flags enabled
    dd framebuffer_tag_end - framebuffer_tag_start          ; the size of the tag
    dd 1024                                                 ; width of screen
    dd 720                                                  ; height of screen
    dd 0                                                    ; means default value of bit depth
framebuffer_tag_end:
final_tag:
    dw 0                                                    ; Tag type last tag
    dw 0                                                    ; no flags  
    dd 8                                                    ; size of final tag 
multiboot_header_end:
    

extern kmain
section .text

_start:
    mov esp, stack_end
    push ebx
    push eax
    call kmain
    jmp $

section .bss
stack_start:
align 8
resb 0x4000
stack_end:
