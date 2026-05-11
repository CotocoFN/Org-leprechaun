.data
newline: .string "\n"
foundMsg: .string "Valor encontrado\n"
notFoundMsg: .string "Valor nao encontrado\n"

.text
.globl main

main:

    # head = NULL
    li s0, 0

    # inserir 10
    li a0, 10
    mv a1, s0
    jal ra, insert_node
    mv s0, a0

    # inserir 20
    li a0, 20
    mv a1, s0
    jal ra, insert_node
    mv s0, a0

    # inserir 30
    li a0, 30
    mv a1, s0
    jal ra, insert_node
    mv s0, a0

    # imprimir
    mv a0, s0
    jal ra, print_list

    # buscar 20
    mv a0, s0
    li a1, 20
    jal ra, search_node

    # buscar 99
    mv a0, s0
    li a1, 99
    jal ra, search_node

    # finalizar
    li a7, 10
    ecall


# =====================================
# create_node
# a0 = valor
# retorna ponteiro em a0
# =====================================

create_node:

    addi sp, sp, -4
    sw ra, 0(sp)

    mv t0, a0

    # malloc 8 bytes
    li a7, 9
    li a0, 8
    ecall

    # salvar valor
    sw t0, 0(a0)

    # next = NULL
    li t1, 0
    sw t1, 4(a0)

    lw ra, 0(sp)
    addi sp, sp, 4

    ret


# =====================================
# insert_node
# a0 = valor
# a1 = head
# retorna head em a0
# =====================================

insert_node:

    addi sp, sp, -8
    sw ra, 4(sp)
    sw s1, 0(sp)

    mv s1, a1

    # criar novo nó
    jal ra, create_node

    mv t0, a0

    # lista vazia
    beqz s1, empty_list

    # percorrer
    mv t1, s1

loop:

    lw t2, 4(t1)

    beqz t2, insert_end

    mv t1, t2
    j loop

insert_end:

    sw t0, 4(t1)

    mv a0, s1
    j finish_insert

empty_list:

    mv a0, t0

finish_insert:

    lw ra, 4(sp)
    lw s1, 0(sp)
    addi sp, sp, 8

    ret


# =====================================
# print_list
# =====================================

print_list:

    mv t0, a0

print_loop:

    beqz t0, print_end

    lw a0, 0(t0)
    li a7, 1
    ecall

    la a0, newline
    li a7, 4
    ecall

    lw t0, 4(t0)

    j print_loop

print_end:

    ret


# =====================================
# search_node
# =====================================

search_node:

    mv t0, a0

search_loop:

    beqz t0, not_found

    lw t1, 0(t0)

    beq t1, a1, found

    lw t0, 4(t0)

    j search_loop

found:

    la a0, foundMsg
    li a7, 4
    ecall

    ret

not_found:

    la a0, notFoundMsg
    li a7, 4
    ecall

    ret