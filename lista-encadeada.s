#Luiz Augusto Scarsi                 2311101009
#Bruno Francisco Neckel              2221101035
#Paulo Henrique Moura Feijó Braga    2221101020

.data
    node_size:      .word 8  # Tamanho do nó (8 bytes)
    head:           .word 0  # Ponteiro do início da lista
    menu:           .asciz "\n==============================\n1. Inserir elemento na lista\n2. Remover elemento na lista\n3. Mostrar todos os elementos\n4. Sair\nEscolha uma opcao: "
    insert_msg:     .asciz "\nDigite um valor para ser inserido na lista: \n"
    insert_success: .asciz "\nValor inserido na lista.\n"
    insert_fail:    .asciz "\nErro ao inserir elemento na lista.\n"
    remove_msg:     .asciz "\nDigite o indice para remover na lista\n"
    remove_success: .asciz "\nElemento removido da lista.\n"
    remove_fail:    .asciz "\nErro ao remover elemento da lista.\n"
    list_elements:  .asciz "\nElementos da lista: \n"
    empty_list:     .asciz "\nLista vazia.\n"
    exit_message:   .asciz "\nSaindo do programa...\n"
    new_line:       .asciz "\n"

.text
main:
    la a0, menu
    li a7, 4
    ecall   # Printa menu
    li a7, 5
    ecall   # Input
    
# testa qual opção escolhida
    li t1, 1
    beq a0, t1, call_insert_element
    li t1, 2
    beq a0, t1, call_remove_element_by_index
    li t1, 3
    beq a0, t1, call_print_list
    li t1, 4
    beq a0, t1, call_exit
    j main

# --------------Insere Elemento---------------#
call_insert_element:
    la a0, insert_msg
    li a7, 4
    ecall
    li a7, 5
    ecall
    mv a1, a0   # move valor do input (a0) para a1
    la a0, head # a0 vira head
    
# reserva endereço em ra para ret
    addi sp, sp, -4
    sw ra, 0(sp)
    call insert_element
    lw ra, 0(sp)
    addi sp, sp, 4
    
# confere sucesso ou erro da operação
    li t1, 1
    beq a0, t1, insert_success_message
    la a0, insert_fail
    li a7, 4
    ecall
    j main

insert_success_message:
    la a0, insert_success
    li a7, 4
    ecall
    j main

insert_element: # (a0 = 'head' / a1 = valor)
    mv t2, a0
# aloca novo nó
    li a7, 9
    lw a0, node_size
    ecall
    beqz a0, insert_alloc_fail
# inicializa nó
    sw a1, 0(a0)
    sw zero, 4(a0)
    lw t0, 0(t2)           # pega head
    beqz t0, insert_first  # lista vazia
    
# percorre até último nó
    mv t1, t0

insert_loop:
    lw t4, 4(t1)         # próximo nó
    beqz t4, insert_end  # achou último
    mv t1, t4
    j insert_loop

insert_end:
    sw a0, 4(t1)  # último aponta para o novo nó
    j insert_done

insert_first:
    sw a0, 0(t2)

# (retorna 1 (sucesso) ou -1 (falha))
insert_done:
    li a0, 1
    ret
insert_alloc_fail:
    li a0, -1
    ret
# --------------Remove Elemento-------------------#
call_remove_element_by_index:

# reserva endereço em ra pra ret
    addi sp, sp, -4
    sw ra, 0(sp)
    call remove_element_by_index
    lw ra, 0(sp)
    addi sp, sp, 4
    j main

remove_element_by_index:
    addi sp, sp, -4
    sw ra, 0(sp)
    la a0, remove_msg
    li a7, 4
    ecall
    li a7, 5
    ecall

    mv a1, a0  # move índice para a1
    la a0, head
    call remove

# recupera endereço de ret
    lw ra, 0(sp)
    addi sp, sp, 4

# testa sucesso ou erro
    li t1, 1
    beq a0, t1, remove_success_label
    j remove_fail_label

# (a1 = índice)
remove:
    addi sp, sp, -4
    sw ra, 0(sp)
    la t0, head
    lw t1, 0(t0)
    beqz t1, remove_empty

    mv t4, t0  # t4 = nó anterior
    mv t2, a1  # t2 = índice alvo
    li a6, 1   # a6 = índice atual

# percorre lista
remove_loop:
    beq a6, t2, remove_element  # se indice atual = alvo
    addi a6, a6, 1
    mv t4, t1
    lw t1, 4(t1)
    bnez t1, remove_loop
    lw ra, 0(sp)
    addi sp, sp, 4
    li a0, -1
    ret

remove_empty:
    lw ra, 0(sp)
    addi sp, sp, 4
    li a0, -1
    ret

# ---------------------Remove Nó--------------------#
remove_element:
    lw t5, 4(t1)    # pega próximo nó
    beq t4, t0, new_head
    sw t5, 4(t4)    # anterior aponta para próximo
    sw zero, 0(t1)  # limpa valor removido
    j remove_done

new_head:
    sw t5, 0(t4)  # head aponta pra próximo

# (Retorna 1 (sucesso))
remove_done:
    lw ra, 0(sp)
    addi sp, sp, 4
    li a0, 1
    ret

remove_success_label:
    la a0, remove_success
    li a7, 4
    ecall
    ret
remove_fail_label:
    la a0, remove_fail
    li a7, 4
    ecall
    ret

# -----------------Imprime Lista--------------------#
call_print_list:
    addi sp, sp, -4
    sw ra, 0(sp)
    call print_list
    lw ra, 0(sp)
    addi sp, sp, 4
    j main

print_list:
    la a0, list_elements
    li a7, 4
    ecall
    la t1, head
    lw t0, 0(t1)
    beqz t0, print_empty_list

print_list_loop:
    lw a0, 0(t0)  # printa valor do nó
    li a7, 1
    ecall

    li a0, ' '
    li a7, 11
    ecall
    
    lw t0, 4(t0)  # avança pro next
    bnez t0, print_list_loop

    la a0, new_line  # quebra linha
    li a7, 4
    ecall
    ret

print_empty_list:
    la a0, empty_list
    li a7, 4
    ecall
    ret
    
# -----------------Fecha Programa-------------------#
call_exit:
    la a0, exit_message
    li a7, 4
    ecall
    li a7, 10
    ecall