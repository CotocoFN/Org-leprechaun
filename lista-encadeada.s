.data
    node_size:  .word 8                # Tamanho do nó (8 bytes)
    head:       .word 0                # Ponteiro para o início da lista
    insert_count:   .word 0            # Contador de inserções
    remove_count:   .word 0            # Contador de remoções
    menu:   .asciz "\n1. Inserir elemento na lista\n2. Remover elemento por indice\n3. Remover elemento por valor\n4. Mostrar todos os elementos\n5. Mostrar estatisticas\n6. Sair\nEscolha uma opcao: "
    insert_msg: .asciz "\nDigite um valor para ser inserido na lista: \n"
    insert_success: .asciz "\nValor inserido na lista.\n"
    insert_fail:    .asciz "\nErro ao inserir elemento na lista.\n"
    remove_by_index_msg: .asciz "\nDigite o indice da lista que deseja remover\n"
    remove_by_value_msg: .asciz "\nDigite o valor da lista que deseja remover\n"
    remove_success: .asciz "\nElemento removido da lista.\n"
    remove_fail:    .asciz "\nErro ao remover elemento da lista.\n"
    list_elements:  .asciz "\nElementos da lista: \n"
    empty_list: .asciz "\nLista vazia.\n"
    stats_message:  .asciz "\nEstatisticas da lista: \n"
    min_value_msg:  .asciz "\nMenor valor: "
    max_value_msg:  .asciz "\nMaior valor: "
    total_inserts_msg: .asciz "\nTotal de insercoes: "
    total_removes_msg: .asciz "\nTotal de remocoes: "
    total_elements_msg: .asciz "\nTotal de elementos: "
    exit_message:   .asciz "\nSaindo do programa...\n"
    new_line: .asciz "\n"

.text
main:
    la a0, menu
    li a7, 4
    ecall                              # Mostra o menu
    li a7, 5
    ecall                              # Pega o input do usuário
    li t1, 1
    beq a0, t1, call_insert_element
    li t1, 2
    beq a0, t1, call_remove_by_index
    li t1, 3
    beq a0, t1, call_remove_by_value
    li t1, 4
    beq a0, t1, call_print_list
    li t1, 5
    beq a0, t1, call_print_stats
    li t1, 6
    beq a0, t1, call_exit
    j main

# --------------------------------------------------#
#               Insere Valor Ordenado               #
# --------------------------------------------------#
call_insert_element:
    la a0, insert_msg
    li a7, 4
    ecall                              # Mostra mensagem de inserção
    li a7, 5
    ecall                              # Lê o valor inteiro do usuário
    mv a1, a0                          # a1 = valor a ser inserido
    la a0, head                        # a0 = ponteiro para a cabeça da lista
    addi sp, sp, -4
    sw ra, 0(sp)
    call insert_element
    lw ra, 0(sp)
    addi sp, sp, 4
    li t1, 1
    beq a0, t1, insert_success_message
    # Falha na inserção
    la a0, insert_fail
    li a7, 4
    ecall
    j main

insert_success_message:
    la a0, insert_success
    li a7, 4
    ecall
    j main

# Função insert_element
# Entradas: a0 = endereço de 'head', a1 = valor a inserir
# Retorno:  a0 = 1 (sucesso) ou -1 (falha)
insert_element:
    mv t2, a0                          # t2 = endereço da cabeça da lista

    # aloca memória antes de usar a0 como retorno
    li a7, 9                           # sbrk
    lw a0, node_size                   # a0 = tamanho do nó (entrada para sbrk)
    ecall                              # a0 = ponteiro para o novo nó alocado

    # testa a0 (retorno do sbrk) para verificar falha de alocação
    beqz a0, insert_alloc_fail

    # Inicializa o novo nó
    sw a1, 0(a0)                       # nó->valor = a1
    sw zero, 4(a0)                     # nó->próximo = NULL

    # Verifica se a lista está vazia
    lw t0, 0(t2)                       # t0 = head (primeiro nó)
    beqz t0, insert_first              # Se vazio, insere no início

    # Verifica se o novo valor é menor que o primeiro nó
    lw t5, 0(t0)                       # t5 = valor do primeiro nó
    blt a1, t5, insert_first           # Se menor, insere no início

    # Percorre a lista para inserção ordenada
    mv t1, t0                          # t1 = nó atual

insert_loop:
    lw t4, 4(t1)                       # t4 = próximo nó
    beqz t4, insert_here               # Se não há próximo, insere aqui
    lw t5, 0(t4)                       # t5 = valor do próximo nó
    blt a1, t5, insert_here            # Se valor < próximo, insere aqui
    mv t1, t4                          # Avança para o próximo nó
    j insert_loop

insert_here:
    sw a0, 4(t1)                       # anterior->próximo = novo nó
    sw t4, 4(a0)                       # novo nó->próximo = antigo próximo
    j insert_done

insert_first:
    sw a0, 0(t2)                       # head = novo nó
    sw t0, 4(a0)                       # novo nó->próximo = antigo primeiro

insert_done:
    # Incrementa contador de inserções
    la t0, insert_count
    lw t1, 0(t0)
    addi t1, t1, 1
    sw t1, 0(t0)
    li a0, 1                           # Retorna sucesso
    ret

insert_alloc_fail:
    li a0, -1                          # Retorna falha
    ret

# --------------------------------------------------#
#               Remove Por índice                   #
# --------------------------------------------------#
call_remove_by_index:
    addi sp, sp, -4
    sw ra, 0(sp)
    call remove_by_index
    lw ra, 0(sp)
    addi sp, sp, 4
    j main

# Função remove_by_index
# Lê o índice do usuário e remove o nó correspondente
remove_by_index:
    addi sp, sp, -4
    sw ra, 0(sp)

    la a0, remove_by_index_msg
    li a7, 4
    ecall                              # Imprime mensagem
    li a7, 5
    ecall                              # Lê o índice em a0

    mv a1, a0                          # a1 = índice a remover
    la a0, head                        # a0 = endereço de head (não usado por remove_element_by_index diretamente)
    call remove_element_by_index

    lw ra, 0(sp)
    addi sp, sp, 4

    li t1, 1
    beq a0, t1, remove_success_label
    j remove_fail_label

# Função remove_element_by_index
# Entrada: a1 = índice (base 1) a remover
# Retorno: a0 = 1 (sucesso) ou -1 (falha)
remove_element_by_index:
    addi sp, sp, -4
    sw ra, 0(sp)

    la t0, head
    lw t1, 0(t0)

    # beqz verifica lista vazia
    beqz t1, remove_index_empty

    mv t4, t0                          # t4 = ponteiro para o nó anterior (inicia em &head)
    mv t2, a1                          # t2 = índice alvo
    li a6, 1                           # a6 = índice atual (começa em 1)

remove_by_index_loop:
    beq a6, t2, remove_element         # Se índice atual == alvo, remove
    addi a6, a6, 1
    mv t4, t1                          # Atualiza anterior
    lw t1, 4(t1)                       # Avança para o próximo nó
    bnez t1, remove_by_index_loop      # Continua se houver próximo
    # índice não encontrado
    lw ra, 0(sp)
    addi sp, sp, 4
    li a0, -1
    ret

remove_index_empty:
    lw ra, 0(sp)
    addi sp, sp, 4
    li a0, -1
    ret

# --------------------------------------------------#
#               Remove Por Valor                    #
# --------------------------------------------------#
call_remove_by_value:
    addi sp, sp, -4
    sw ra, 0(sp)
    call remove_by_value
    lw ra, 0(sp)
    addi sp, sp, 4
    j main

# Função remove_by_value
# Lê o valor do usuário e remove o nó correspondente
remove_by_value:
    addi sp, sp, -4
    sw ra, 0(sp)

    la a0, remove_by_value_msg
    li a7, 4
    ecall                              # Imprime mensagem
    li a7, 5
    ecall                              # Lê o valor em a0

    mv a1, a0                          # a1 = valor a remover
    call remove_element_by_value

    lw ra, 0(sp)
    addi sp, sp, 4

    li t1, 1
    beq a0, t1, remove_success_label
    j remove_fail_label

# Função remove_element_by_value
# Entrada: a1 = valor a remover
# Retorno: a0 = 1 (sucesso) ou -1 (falha)
remove_element_by_value:
    addi sp, sp, -4
    sw ra, 0(sp)

    la t0, head
    lw t1, 0(t0)                       # t1 = primeiro nó

    beqz t1, remove_value_empty        # Falha se lista vazia

    mv t4, t0                          # t4 = ponteiro para o nó anterior
    mv t2, a1                          # t2 = valor alvo

remove_by_value_loop:
    lw t5, 0(t1)                       # t5 = valor do nó atual
    beq t5, t2, remove_element        # Se igual, remove
    mv t4, t1                          # Atualiza anterior
    lw t1, 4(t1)                       # Avança para o próximo
    bnez t1, remove_by_value_loop      # Continua se houver próximo
    # Valor não encontrado
    lw ra, 0(sp)
    addi sp, sp, 4
    li a0, -1
    ret

remove_value_empty:
    lw ra, 0(sp)
    addi sp, sp, 4
    li a0, -1
    ret

# --------------------------------------------------#
#               Remove Nó (comum a ambos)           #
# --------------------------------------------------#
# Entradas: t0 = &head, t1 = nó a remover, t4 = nó anterior
remove_element:
    lw t5, 4(t1)                       # t5 = próximo do nó a remover

    # Se t4 == t0 (anterior é &head), o nó removido é o primeiro
    beq t4, t0, update_head_on_remove

    sw t5, 4(t4)                       # anterior->próximo = próximo do removido
    sw zero, 0(t1)                     # Limpa o valor do nó removido
    j remove_increment

update_head_on_remove:
    sw t5, 0(t4)                       # head = próximo do removido

remove_increment:
    # Incrementa contador de remoções
    la t3, remove_count
    lw t6, 0(t3)
    addi t6, t6, 1
    sw t6, 0(t3)
    lw ra, 0(sp)
    addi sp, sp, 4
    li a0, 1                           # Retorna sucesso
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

# --------------------------------------------------#
#               Imprime Lista                       #
# --------------------------------------------------#
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
    beqz t0, print_empty_list         # Se vazio, imprime mensagem

print_list_loop:
    lw a0, 0(t0)                       # Valor do nó atual
    li a7, 1
    ecall                              # Imprime inteiro
    li a0, ' '
    li a7, 11
    ecall                              # Imprime espaço
    lw t0, 4(t0)                       # Próximo nó
    bnez t0, print_list_loop

    la a0, new_line
    li a7, 4
    ecall
    ret

print_empty_list:
    la a0, empty_list
    li a7, 4
    ecall
    ret

# --------------------------------------------------#
#               Mostra Estatísticas                 #
# --------------------------------------------------#
call_print_stats:
    addi sp, sp, -4
    sw ra, 0(sp)
    call print_stats
    lw ra, 0(sp)
    addi sp, sp, 4
    j main

print_stats:
    la a0, stats_message
    li a7, 4
    ecall

    # Total de inserções
    la a0, total_inserts_msg
    li a7, 4
    ecall
    la t0, insert_count
    lw a0, 0(t0)
    li a7, 1
    ecall

    # Total de remoções
    la a0, total_removes_msg
    li a7, 4
    ecall
    la t0, remove_count
    lw a0, 0(t0)
    li a7, 1
    ecall

    # Verifica se a lista está vazia
    la t1, head
    lw t0, 0(t1)
    beqz t0, print_empty_list_stats

    # Inicializa min/max com o valor do primeiro nó
    lw t2, 0(t0)                       # t2 = menor valor
    lw t3, 0(t0)                       # t3 = maior valor
    li t4, 0                           # t4 = contador de elementos

stats_loop:
    lw t5, 0(t0)                       # Valor do nó atual

    # incrementa o contador antes dos desvios condicionais,
    # e update_min/update_max voltam para stats_continue
    addi t4, t4, 1

    blt t5, t2, update_min
    bgt t5, t3, update_max

stats_continue:
    lw t0, 4(t0)                       # Próximo nó
    bnez t0, stats_loop

    # Exibe total de elementos
    la a0, total_elements_msg
    li a7, 4
    ecall
    mv a0, t4
    li a7, 1
    ecall

    # Exibe menor valor
    la a0, min_value_msg
    li a7, 4
    ecall
    mv a0, t2
    li a7, 1
    ecall

    # Exibe maior valor
    la a0, max_value_msg
    li a7, 4
    ecall
    mv a0, t3
    li a7, 1
    ecall

    la a0, new_line
    li a7, 4
    ecall
    ret

update_min:
    mv t2, t5
    j stats_continue                   # volta para stats_continue, não stats_loop

update_max:
    mv t3, t5
    j stats_continue                   # volta para stats_continue, não stats_loop

print_empty_list_stats:
    la a0, empty_list
    li a7, 4
    ecall
    ret

# --------------------------------------------------#
#               Fecha Programa                      #
# --------------------------------------------------#
call_exit:
    la a0, exit_message
    li a7, 4
    ecall
    li a7, 10
    ecall
