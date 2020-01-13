.data
#Figura
figure_x: .byte 0,1,0,0,1
figure_y: .byte 0,0,1,2,2
fig_cells: .byte 5

#Forma Encontrada
sucesso: .asciiz "A forma foi encontrada na célula "
insucesso: .asciiz "A forma não foi encontrada no bitmap."
sucesso180: .asciiz "A forma rodada a 180 graus foi encontrada na célula "
insucesso180: .asciiz "A forma rodada a 180 graus não foi encontrada no bitmap."

#Dimensão Bitmap
d: .word 11

#Espaço pré-alocado ao mapa
map: .space 10000

#Nova Linha
newline: .asciiz "\n"
parentesis1: .asciiz "("
virgula: .asciiz ","
parentesis2: .asciiz ")"

.text

jal GetRandomMap
jal PrintMap
jal newLine
jal GetMapwPiece
jal newLine
jal PrintMap
jal ver

j exit


GetRandomMap:
#Gera um mapa aleatório com 0's e 1's
	
	#protege as variaveis usadas
	addi $sp,$sp,-8	
	sw $s1,0($sp)
	sw $s2,4($sp)
	sw $s0,8($sp)

	#$t1 - Área do mapa (11*11)
	lw $t1, d
	multu $t1,$t1
	#$t2 - Número total de entradas no mapa (11*11=121)
	mflo $t2

	#Guardar em $s0 o endereço do mapa a preencher 
	la $s0, map

	#Inicia o contador iterador no array com todas as entradas do mapa 
	li $t4,0
	
	#Prepara a execucão de randoms para 
	li $v0, 42 # Codigo associado a' geracao de nnmeros inteiros aleatorios
	li $a0, 1	
	addi $a1, $t2, 1 #fin [!]

	#Percorre todos as entradas, determinando se sao preenchidas a "0" ou a "1". 
	#(Este codigo pode ser modificado para se tornar o preenchimento mais ou menos denso de 1's, 
	#Neste momento, guarda 4 zeros, e depois, de forma aleatoria, coloca um "1" ou um "0".
	LOOP0:	
		beq $t4,$t2,return01     		
		addi $s0, $s0, 1		
		sb $zero, ($s0) 	#Guarda 0 nesta posicao
		addi $t4,$t4,1
		
		beq $t4,$t2,return01
		addi $s0, $s0, 1		
		sb $zero, ($s0) 	#Guarda 0 nesta posicao
		addi $t4,$t4,1
		
		beq $t4,$t2,return01
		addi $s0, $s0, 1		
		sb $zero, ($s0) 	#Guarda 0 nesta posicao		
		addi $t4,$t4,1
		
		#beq $t4,$t2,return01
		#addi $s0, $s0, 1		
		#sb $zero, ($s0) 	#Guarda 0 nesta posicao	
		#addi $t4,$t4,1		
		
		beq $t4,$t2,return01    
		addi $s0, $s0, 1 
		li $a1, 2		
		syscall
		
		#guarda random "1" ou "0" - comentar esta linha para ter um mapa sem ruido
		sb $a0, ($s0) 		
						
		addi $t4,$t4,1
		j LOOP0

	return01:
	

	lw $s1,0($sp)
	lw $s2,4($sp)
	lw $s0,8($sp)	
	addi $sp,$sp,8
	 	
	jr $ra
	
################################################################################################################

#Função para verificar se existe a forma no bitmap.
#Começa por verificar no primeiro endereço do 'map' o valor contido.
#Se for 0 -> aumenta uma unidade ao endereço e procura de novo
#Se for 1 -> assume que poderá ser uma possível célula da forma E,
#Verifica que as restantes células (endereço 'map' + nº da próxima célula da figura) têm o 1 contido
#Encontra a figura se todos tiverem Caso contrário repete o algoritmo

ver:
	
	#endereço mapa
	la $s0, map
	
	# Posição da Célula inicial
	addi $s5, $zero, 0 # x
	addi $s6, $zero, 0 # y	

	startcheck:
		#Verifica se chegou à última célula do bitmap
		add $t1, $s5, $s6
		bne $t1, 18, encontra1
		
		jal newLine
		
		li $v0, 4
		la $a0, insucesso
		syscall
		
		jal ver180
	#Verificar se no endereço actual do 'map' existe o 1 guardado
	#Verificar se já chegou ao último valor de x (0-10) dando reset se já estiver no fim de linha, para mudar para o próximo y
	#Aumenta uma unidade no endereço do 'map' guardado para prosseguir a ver o próximo valor guardado no bitmap		
	encontra1:	
		lb $t0, ($s0)
		beq $t0, 1, verificaresto
		beq $s5, 10, resetX	
		add $s5, $s5, 1
		addi $s0, $s0, 1
		j startcheck
	
	#Condições para  a peça existir, caso uma célula falhe em conter o 1, ignora as outras verificações				
	verificaresto:
	addi $s1, $s0, 1 #endereço célula 1 (1,0)
	lb $t1, ($s1) #load byte contida na célula 1
	bne $t1, 1, fakejump 
	
	addi $s2, $s0, 11 #endereço célula (0,1)
	lb $t2, ($s2) #load byte contida na célula 2
	bne $t2, 1, fakejump 
	
	addi $s3, $s0, 22 #endereço célula (0,2)
	lb $t3, ($s3)  #load byte contida na célula 3
	bne $t3, 1, fakejump 
	
	addi $s4, $s0, 23 #endereço célula (1,2)
	lb $t4, ($s4)  #load byte contida na célula 4
	bne $t4, 1, fakejump 
	
	jal newLine
	
	#Print - forma encontrada
	li $v0, 4
	la $a0, sucesso
	syscall
	
	li $v0, 4
	la $a0, parentesis1
	syscall 
	
	#Valor de X do vértice superior mais à esquerda				
	li $v0, 1
	la $a0, ($s5)
	syscall

	li $v0, 4
	la $a0, virgula
	syscall 
	
	#Valor de Y do vértice superior mais à esquerda	
	li $v0, 1
	la $a0, ($s6)
	syscall	
	
	li $v0, 4
	la $a0, parentesis2
	syscall 
	
	
	jal ver180

	#Valor do X é zerado
	#Valor de Y é incrementado uma unidade
	#Incrementa-se uma unidade ao endereço do 'map' para fazer nova pesquisa
	resetX:
		sub $s5, $s5, $s5
		add $s6, $s6, 1
		addi $s0, $s0, 1
		j startcheck
	
	#Verificar se já chegou ao último valor de x (0-10) para mudar de linha
	#Aumenta uma unidade ao X caso ainda não tenha chegado ao último valor, bem como ao endereço do 'map' para proceder a nova pesquisa		
	fakejump:
		beq $s5, 10, resetX
		add $s5, $s5, 1
		addi $s0, $s0, 1
		j startcheck

################################################################################################################

ver180: #Igual à função ver, só voltada para a peça a 180º
	
	#endereço mapa
	la $s0, map
	
	# Posição da Célula inicial
	addi $s5, $zero, 0 # x
	addi $s6, $zero, 0 # y	

	startcheck180:
		#Verifica se chegou à última célula do bitmap
		add $t1, $s5, $s6
		bne $t1, 18, encontra1180
		
		jal newLine
		
		li $v0, 4
		la $a0, insucesso180
		syscall
		
		li $v0, 10
		syscall	
	#Verificar se no endereço actual do 'map' existe o 1 guardado
	#Verificar se já chegou ao último valor de x (0-10) dando reset se já estiver no fim de linha, para mudar para o próximo y
	#Aumenta uma unidade no endereço do 'map' guardado para prosseguir a ver o próximo valor guardado no bitmap		
	encontra1180:	
		lb $t0, ($s0)
		beq $t0, 1, verificaresto180
		beq $s5, 10, resetX180	
		add $s5, $s5, 1
		addi $s0, $s0, 1
		j startcheck180
	
	#Condições para  a peça existir, caso uma célula falhe em conter o 1, ignora as outras verificações				
	verificaresto180:
	addi $s1, $s0, 1 #endereço célula 1 (1,0)
	lb $t1, ($s1) #load byte contida na célula 1
	bne $t1, 1, fakejump180 
	
	addi $s2, $s0, 12 #endereço célula (0,1)
	lb $t2, ($s2) #load byte contida na célula 2
	bne $t2, 1, fakejump180 
	
	addi $s3, $s0, 22 #endereço célula (0,2)
	lb $t3, ($s3)  #load byte contida na célula 3
	bne $t3, 1, fakejump180 
	
	addi $s4, $s0, 23 #endereço célula (1,2)
	lb $t4, ($s4)  #load byte contida na célula 4
	bne $t4, 1, fakejump180 
	
	jal newLine
	
	#Print - forma encontrada
	li $v0, 4
	la $a0, sucesso180
	syscall
	
	li $v0, 4
	la $a0, parentesis1
	syscall 
	
	#Valor de X do vértice superior mais à esquerda				
	li $v0, 1
	la $a0, ($s5)
	syscall

	li $v0, 4
	la $a0, virgula
	syscall 
	
	#Valor de Y do vértice superior mais à esquerda	
	li $v0, 1
	la $a0, ($s6)
	syscall	
	
	li $v0, 4
	la $a0, parentesis2
	syscall 
	
	
	li $v0, 10
	syscall	

	#Valor do X é zerado
	#Valor de Y é incrementado uma unidade
	#Incrementa-se uma unidade ao endereço do 'map' para fazer nova pesquisa
	resetX180:
		sub $s5, $s5, $s5
		add $s6, $s6, 1
		addi $s0, $s0, 1
		j startcheck180
	
	#Verificar se já chegou ao último valor de x (0-10) para mudar de linha
	#Aumenta uma unidade ao X caso ainda não tenha chegado ao último valor, bem como ao endereço do 'map' para proceder a nova pesquisa		
	fakejump180:
		beq $s5, 10, resetX180
		add $s5, $s5, 1
		addi $s0, $s0, 1
		j startcheck180



################################################################################################################


GetMapwPiece:

	#protege variaveis usadas
	addi $sp,$sp,-16
	sw $s7,0($sp)
	sw $s4,4($sp)
	sw $s0,8($sp)
	sw $s5,12($sp)
	sw $s6,16($sp)
	

	#lado do mapa - $s0
	lw $s0, d
	multu $s0,$s0
	
	#area do mapa
	mflo $t2
	
	#encontra aleatoriamente uma posicao para a forma 2D ($s4)
	li $v0, 42
	li $a0, 1
	addi $a1, $t2, 1
	syscall
	move $s4, $a0 # em $s4 fica a posicao da forma	
	
	#Descomentar a proxima linha para colocar a forma numa posicao conhecida (15) - para debuging 
	#Atencao que a posicao da forma conta a partir de 0. 
	#li $s4, 15
	
	li $a0, 1
	li $a1, 2
	syscall

	move $v0, $a0 #guarda em $vo a rotacao da forma (parametro para jal rotate)
	
	#verifica se a forma deve ser rodada de 180 graus consoante o random anterior
	bne $v0, $zero, nrotate
		
		#prepara a chamada da funcao rotate, guardando $ra
		addi $sp, $sp, -4
		sw $ra, ($sp) 
		#Roda a forma de 180 graus
		jal rotate
	
	#recupera o $ra do $sp
	lw $ra, ($sp) 
	addi $sp, $sp, 4
	
	
	nrotate:
	
	#vai buscar o inicio do mapa (endereco) e guarda em $t7
	la $t7, map
	
	#carrega os endereco das posicoes (x,y) da forma 	
	la $s5, figure_x
	la $s6, figure_y	
	
	#carrega o numero de entradas da forma
	lb $s7, fig_cells
	
	#faz um loop que precorre todas as entradas da forma ($s7) e devolve um mapa com a forma inserida.
	LOOP2:	
		beq $s1, $s7, return02
				
		#vai buscar os valores da primeira entrada para x e para y		
		lb $t5, ($s5) #x
		lb $t6, ($s6) #y relativos da cada ponto da forma
		
		
		divu $s4, $s0 		
		#posicao x da forma no mapa dada a posicao absoluta da forma encontrada anteriormente
		mfhi $t3
		
		#posicao y da formano mapa dada a posicao absoluta da forma encontrada anteriormente
		mflo $t8
		
				
		#posicao x,y final do elemento (posicao do elemento na forma + posicao da forma no mapa): 
		add $t5, $t5, $t3 #x
		add $t6, $t8, $t6 #y
	
		li $t9, 1
		
		multu $t6, $s0
		mflo $t3
		#$s2 - posicao final no array da entrada da forma de cada iteracao do loop
		add $t0, $t3, $t5
		#$t6 - endereco dessa entrada						
		add $t6, $t7, $t0
		
		#escrita do valor 1 nesse endereco
		sb $t9, ($t6)
		
		addi $s1, $s1, 1 #iteracao no loop		
		addi $s5, $s5, 1 #iteracao do endereco x
		addi $s6, $s6, 1 #iteracao do endereco y	
			
		j LOOP2	
	
	return02:
	

	sw $s7,0($sp)
	sw $s4,4($sp)
	sw $s0,8($sp)
	sw $s5,12($sp)
	sw $s6,16($sp)
	
	addi $sp,$sp,16	
		
	jr $ra		

################################################################################################################
################################################################################################################

newLine: 
	li $v0, 4
	la $a0, newline
	syscall 
	
	jr $ra

################################################################################################################
################################################################################################################

PrintMap:
#imprime o bitmap com "0" e "1" no ecrâ
	

	#lado do mapa - $s0
	lw $t1, d
	multu $t1,$t1
	# area do mapa
	mflo $t2
	
	
	#inicializa a iteracao
	li $t4,0
	la $t7, map
	
	#Faz print do bitmap, iterando por todas as celulas
	LOOP1:	
		beq $t4,$t2,return2
		lb $a0, ($t7)
		addi $t7, $t7, 1 
		li  $v0, 1          		
		#imprime o valor que esta no bitmap ($t7)
		syscall
		
		li $v0, 0xB
		addi $a0, $zero, 0x20
		#imprime um zero de separacao horizontal
		syscall		

		li $v0, 1
		addi $t4, $t4,1
		divu $t4, $t1	#procura o resto para saber se tem que introduzir uma quebra de linha            
		mfhi $t3				
		#se chegou ao fim da linha imprime um carrier - return - nova linha
		bne $zero, $t3, next
			li $v0, 0xB
			addi $a0, $zero, 0xA
			syscall
			li $v0, 1				
		
		next:
		
		j LOOP1

	return2:	

	jr $ra


rotate:
#roda uma forma de 180 graus - igual a simetria em x e simetria em y
	
	#carrega entradas em x e dimensao da forma
	la $t1, figure_x
	lb $t3, fig_cells 
	
	move $t4, $zero
	#itera em cada entrada em x para fazer simetria em x
	LOOP3:
		beq, $t3, $t4, exit2		
		
		#faz simetria em x, usando $t5 para guardar o valor		
		lb $t5, ($t1)
		#partindo do principio que a forma tem 4 entradas de lado, a simetria deve ser 4-x, 
		#sendo x a posicao actual deste "1" 
		li $t6, 4
		#subtrai a 4 a posicao actual
		sub $t5, $t6, $t5
		
		#guarda a entrada de novo no map.
		sb $t5, ($t1)
		
		#itera
		addi $t4, $t4, 1
		addi $t1, $t1, 1
		j LOOP3
	exit2:
	
	#carrega entradas em y e posicao da forma
	la $t1, figure_y
	
	move $t4, $zero
	#itera em cada entrada em y para fazer simetria em y (igual ao codigo para x)
	LOOP4:
		beq, $t3, $t4, exit3				
		lb $t5, ($t1)
		li $t6, 4
		sub $t5, $t6, $t5
		sb $t5, ($t1)
		
		addi $t4, $t4, 1
		addi $t1, $t1, 1
		j LOOP4
	exit3:


	jr $ra



exit:

