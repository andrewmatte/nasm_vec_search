section .data
    check db "-100<%.1lf<100", 10, 0
    fmt db "Distance: %lf", 10, 0
    format db "integer: %ld", 10, 0
    filename db "/home/andrew/Codebase/vectors.bin", 0
    filemode db "rb", 0
    input_vector dq -88.0, -68.0, 93.0    ; Example input vector (x, y, z)
    num_vecs dq 1000000

section .bss
    vec_count resq 1                  ; Number of vectors in file
    vectors resq 3000000                ; Space for 10000 vectors, each with 3 doubles
    distances resq 1000000              ; Distance array for each vector
    temp_distance resq 1

section .text
    global _start
    extern fopen, fread, fclose, printf, exit

_start:
    ; Open the file
    mov rdi, filename
    mov rsi, filemode
    call fopen
    test rax, rax
    jz _exit                          ; Exit if file couldn't be opened
    mov rbx, rax                      ; Store file pointer in rbx

    ; Read vectors into memory
    xor rdx, rdx                      ; Counter for number of vectors
    mov rsi, vectors                  ; Point rsi to the start of the vectors array

.read_loop:
    mov rdi, rsi                      ; First argument: destination buffer (vector slot)
    mov rsi, 8                        ; Second argument: size of each item (8 bytes for double)
    mov rdx, 3                        ; Third argument: number of items (3 doubles)
    mov rcx, rbx                      ; Fourth argument: file pointer
    call fread
    cmp rax, 3                        ; Check if we read 24 bytes (1 vector)
    jne _exit
    inc qword [vec_count]             ; Increment the vector count
    cmp qword [vec_count], num_vecs
    jl .read_loop
    je .done_reading                  ; this would indicate EOF

.done_reading:
    ; Calculate distances to input vector
    call _exit
    mov rsi, vectors                  ; Start of vector list
    xor rbx, rbx                      ; Reset index for distance storage
    mov [vec_count], rdx              ; Store count of vectors
    mov r9, distances

.calc_distance:
    ; Initialize ST(0) to zero for the distance
    fldz
    mov qword [temp_distance], 0
    mov rcx, 0                        ; Dimension index

    ; Loop through dimensions (3 dimensions)
.calc_distance_loop:
    cmp rcx, 3                        ; Compare loop counter with number of dimensions
    jge .done_calc                    ; If counter >= dimensions, we are done

    ; Load the corresponding vector component
    fld qword [rsi + rcx * 8]           ; Load vector component
    fsub qword [input_vector + rcx * 8] ; Subtract input component from vector component
    fmul                                ; Square the result

    fadd qword [temp_distance]          ; Add the squared result to the distance in ST(0)
    fstp qword [temp_distance]

    inc rcx                           ; Increment loop counter
    jmp .calc_distance_loop           ; Repeat for the next dimension

.done_calc:
    ; Now, ST(0) contains the sum of squares, calculate the square root
    fld qword [temp_distance]
    fsqrt                             ; Square root to get the distance
    fstp qword [temp_distance]

    mov rax, [temp_distance]
    mov [r9 + 8*rbx], rax

    mov rdi, fmt
    movq xmm0, rax
    call printf
    call _exit

    ; Prepare for the next vector
    inc rbx                           ; Move to the next distance
    cmp rbx, [vec_count]              ; Check if we have processed all vectors
    jl .calc_distance                 ; If not, calculate the next distance
    jge .prepare_print_loop

.prepare_print_loop:
    mov r8, 0                     ; Reset index for printing
    lea rax, [distances]             ; Point to the start of distances

.print_loop:
    cmp r8, rbx             ; Check if we've printed all distances
    jge _exit                        ; If yes, exit
    mov rdi, fmt                     ; Format for printf
    movq xmm0, [rax + r8 * 8]       ; Move next distance into xmm0 for printf
    sub rsp, 8
    movsd [rsp], xmm0
    call printf
    inc r8                          ; Increment counter
    jmp .print_loop                  ; Repeat for the next distance

_exit:
    xor rdi, rdi                     ; Return 0
    call exit
