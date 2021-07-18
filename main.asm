#<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>
#                     MACROS
#<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>

.macro exit()
	li a7, 10
	ecall
.end_macro

.macro definirBloco(%linha, %coluna, %mapa, %bloco)
	# Modifica Um bloco da matriz
	# REGISTRADORES: %linha, %coluna, %mapa, %bloco
	
	# N° Colunas = 19; N° Linhas = 15
	# Eq. => linha * 19 + coluna
	li t0, 20
	mul t0, t0, %linha
	add t0, t0, %coluna
	
	mv t1, %mapa
	add t1, t1, t0
	sb %bloco, 0(t1)
.end_macro

.macro obterBloco(%linha, %coluna, %mapa)
	# Descobre qual o bloco de uma determinada posição
	li t0, 20
	mul t0, t0, %linha
	add t0, t0, %coluna

	mv t1, %mapa
	add t1, t1, t0
	
	# RETORNO(a1)
	lb a1, 0(t1)
.end_macro

#<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>
#               PROGRAMA PRINCIPAL
#<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>

INICIALIZA_LOLO:

#<--------- INICIALIZAÇÃO --------->
.data
	# [     MENU      ]
	.include "Dados/Menu.s"
	
	# [     MAPAS     ]
	.include "Dados/Mapas.s"
	
	.include "sprites/Letras/Point.s"
	
	# [     SPRITES     ]
	 # Letras:
	 
	 .include "sprites/Letras/Greater.s"
	 .include "sprites/Black.s"
	 
	 .include "sprites/Letras/A.s"
	 .include "sprites/Letras/B.s"
	 .include "sprites/Letras/C.s"
	 .include "sprites/Letras/D.s"
	 .include "sprites/Letras/E.s"
	 .include "sprites/Letras/F.s"
	 .include "sprites/Letras/G.s"
	 .include "sprites/Letras/H.s"
	 .include "sprites/Letras/I.s"
	 .include "sprites/Letras/J.s"
	 .include "sprites/Letras/K.s"
	 .include "sprites/Letras/L.s"
	 .include "sprites/Letras/M.s"
	 .include "sprites/Letras/N.s"
	 .include "sprites/Letras/O.s"
	 .include "sprites/Letras/P.s"
	 .include "sprites/Letras/Q.s"
	 .include "sprites/Letras/R.s"
	 .include "sprites/Letras/S.s"
	 .include "sprites/Letras/T.s"
	 .include "sprites/Letras/U.s"
	 .include "sprites/Letras/V.s"
	 .include "sprites/Letras/W.s"
	 .include "sprites/Letras/X.s"
	 .include "sprites/Letras/Y.s"
	 .include "sprites/Letras/Z.s"
	 
	 # Terreno:
	.include "sprites/wall1.s"
	.include "sprites/wall2.s"
	.include "sprites/wall3.s"
	.include "sprites/wall4.s"
	.include "sprites/ground1.s"
	
	.include "sprites/tree1.s"
	.include "sprites/tree2.s"
	.include "sprites/hearth.s"
	.include "sprites/treasure1.s"
	.include "sprites/treasure2.s"
	.include "sprites/door.s"
	.include "sprites/door2.s"
	.include "sprites/rock.s"
	
	# Inimigos
	.include "sprites/Snake.s"
	.include "sprites/Snake2.s"
	
	.include "sprites/Enemy11.s"
	
	# Personagem:
	.include "sprites/Lolo11.s"
	.include "sprites/Lolo12.s"
	.include "sprites/Lolo13.s"
	
	.include "sprites/Lolo21.s"
	.include "sprites/Lolo22.s"
	.include "sprites/Lolo23.s"
	
	.include "sprites/Lolo31.s"
	.include "sprites/Lolo32.s"
	.include "sprites/Lolo33.s"
	
	.include "sprites/Lolo42.s"
	.include "sprites/Lolo43.s"
	.include "sprites/Lolo44.s"
	
	.include "sprites/Shot.s"
	
	# Movimentos (Esq, Dir, Cima, Baixo):
	LOLO_MOV: .byte 1, 4, 7, 10	# Frame do LOLO ( Cada Numero indica um sprite )
	
	# Memoria de Estado de LOLO
	LOLO_EST: .byte 0, # Frame de Lolo Atual
			0, # Numero de Tiros Disponiveis
			0, # Ultima Tecla Pressionada de Movimento
			
	# Memória de Estado de Menu
	MENU_ESTADO: .byte 0, # Menu Esta Ativo
		     .byte 0, # Linha do Seletor
		     .byte 0  # Coluna do Seletor
		     
	# Memória de Estado do Bau
	BAU_EST: .byte 0, # Linha do Bau
		 .byte 0, # Coluna do Bau
		 .byte 0  # Bau Aberto
		 
	# Memória de Estado da Porta
	PORTA_EST: .byte 0, # Linha da Porta
		   .byte 0, # Coluna da Porta
		   .byte 0, # Verifica se Está aberta
.text

#<--------- MENU --------->
	
	# Condições do Mapa
	.eqv MAPA_ATUAL s0  # Endereço do Mapa Atual
	.eqv NUM_LINHA  s1  # Número de Linhas de um mapa
	.eqv NUM_COL    s2  # Número de Colunas de um mapa
	
	# Definições de Personagem
	.eqv LOLO_LINHA s3
	.eqv LOLO_COL   s4
	.eqv LOLO_ESTA	s5 # Estados de Lolo
	
	# Definições do Menu
	.eqv MENU_EST s6
	la MENU_EST, MENU_ESTADO
	
	# Número de Corações a se pegar
	.eqv CORAC_PEGAR s7
	
	# Verifica se Ganhou
	.eqv GANHOU s8
	mv GANHOU, zero # Não Ganhou
	
	# Número de Fases
	.eqv NUM_FASES s9
	li NUM_FASES, 5
	
	# Fase Atual
	.eqv FASE_ATUAL s10
	li FASE_ATUAL, 1
	
	# Define se Menu Esta Ativo ou Não(1, 0)
	li t0, 1
	sb t0, 0(MENU_EST)
	
	# Memória de Estados de Lolo
	la LOLO_ESTA, LOLO_EST
	
	# Definições Iniciais
	la MAPA_ATUAL, MENU_T
	
	li NUM_LINHA, 15
	li NUM_COL, 20
	
PINTA_MAPA:
	# Frame de Movimento do Personagem ( Utilizado para "Pintar" o Personagem a cada movimento)
	li t0, 'P'
	sb t0, 0(LOLO_ESTA)
	
	# Primeiro Frame
	li t0, 'P'
	sb t0, 2(LOLO_ESTA)
	
	# Tiros Disponíveis
	li t0, 0
	sb t0, 1(LOLO_ESTA)
	
	# Carrega Mapa
	mv a6, MAPA_ATUAL
	
	# Inicializa Corações que Devem ser Pegados
	li CORAC_PEGAR, 0
	
	li a2, 0
	li a3, 0
	li a5, 0xFF000000

#<--------- CARREGAR MAPA --------->
MAPA_LOOP:
	beq a3, NUM_COL, MUDA_MAPA
	lb a4, 0(a6)
	
	lb t0, 0(MENU_EST) # Esta em Menu
	beqz t0, CONT_MAPA # Verifica Se Está no Menu 
	
	jal SEL_MENU
	j CONT_MENU
	
CONT_MAPA: # Continua Analise do Mapa
	# Obtém a Posição do Personagem
	
	li t0, 'P'
	beq a2, t0, REG_PER
	
CONT_MAPA2: # Continua Analise do Mapa
	la t2, M_REF # Mapa de Referência( Utilizado Para Restaurar o Mapa )
	definirBloco(a2, a3, t2, a4)
	
	jal SELECIONAR_BLOCO
	
CONT_MENU: # Continua Analise do Menu
	addi a3, a3, 1
	addi a6, a6, 1
	j MAPA_LOOP
	
MUDA_MAPA:
	addi a2, a2, 1
	beq a2, NUM_LINHA, INICIAR_JOGO
	
	li a3, 0
	j MAPA_LOOP

REG_PER:
	mv LOLO_LINHA, a2
	mv LOLO_COL, a3
	j CONT_MAPA2
	
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#<--------- INICIAR JOGO --------->
INICIAR_JOGO:
	lb t0, 0(MENU_EST)
	beqz t0, L_FIM_MENU	
	
	# Menu
	LOOP_MENU:
		# Verifica se algo foi pressionado
		li t0, 0xFF200000
		lw t1, 0(t0)
		andi t1, t1, 0x00000001
		
		# < Atualiza Movimento Menu >
		beq t1, zero, LOOP_MENU	# Se Não Pressionou Verifica Novamente
		jal MOV_MENU
		
		j LOOP_MENU
				
	L_FIM_MENU:	
	
	#li LOLO_LINHA, 7
	#li LOLO_COL, 10
	
	# < Execução de Jogo >
	LOOP_JOGO:
		# PARTE QUE ATUALIZA O ESTADO DA PORTA
		li t0, 1
		bne GANHOU, t0, LOOP_JOGO2
		j ABRE_PORTA
		
	LOOP_JOGO2:
		# PARTE QUE ATUALIZA O ESTADO DO BÁU
		bnez CORAC_PEGAR, LOOP_JOGO3
		j ABRE_BAU

	LOOP_JOGO3:
		# Verifica se algo foi pressionado
		li t0, 0xFF200000
		lw t1, 0(t0)
		andi t1, t1, 0x00000001
		
		#< Atualiza Personagem >
		beq t1, zero, LOOP_JOGO	# Se Não Pressionou Verifica Novamente
		jal MOVIMENTA_LOLO	# Ocorreu Movimento
		
		#[ PARTE QUE SUBSTITUI ONDE O PERSONAGEM ESTAVA POR UM CHÃO ]
		# a2 e a3 já armazenam a linha antiga do Personagem
		li a4, 'E'
		li a5, 0xFF000000
		jal SELECIONAR_BLOCO
		
		# PARTE QUE ATUALIZA SUA LINHA E COLUNA
		mv a2, LOLO_LINHA
		mv a3, LOLO_COL
		li a4, 'P'
		jal SELECIONAR_BLOCO
		
		j LOOP_JOGO
	FIM_JOGO:
	exit()

#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

#<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>
#                 SUB PROGRAMAS
#<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>

#<--------- MOVIMENTO PARA MENU --------->
MOV_MENU:
	# Detectar Movimento
	li t0, 0xFF200000   # Endereço de Entradas
	addi t2, t0, 4      # Endereço de Caractere
	lb t3, 0(t2)        # Caractere Pressionado
	
	li t0, 10
	beq t3, t0, M_MENU_F
	
	li t0, 'w'
	beq t3, t0, M_MENU_M
	
	li t0, 's'
	beq t3, t0, M_MENU_M
	
	ret
#<--------- MOVIMENTOS PARA MENU --------->
M_MENU_F:
	lb t0, 1(MENU_EST)
	
	li t1, 6
	beq t0, t1, M_MENU_F1
	
	li t1, 8
	beq t0, t1, M_MENU_F2
	
	ret
	
M_MENU_F1:
	la MAPA_ATUAL, MAPA_1

	li t0, 0
	sb t0, 0(MENU_EST)
	j PINTA_MAPA

M_MENU_F2:
	exit()

#------------------------------------------
M_MENU_M:
	# Limpar Seta
	lb a2, 1(MENU_EST)
	lb a3, 2(MENU_EST)
	li a4, '*'
	
	mv a0, a2
	li a7, 1
	ecall
	
	mv a0, ra
	jal SEL_MENU
	
	li t0, 8
	beq a2, t0, M_MENU_W
	
	sb t0, 1(MENU_EST)
M_MENU2:
	# Pintar Seta
	lb a2, 1(MENU_EST)
	lb a3, 2(MENU_EST)
	li a4, '>'
	jal SEL_MENU
	
	mv ra, a0
	ret
	
M_MENU_W:
	li t0, 6
	sb t0, 1(MENU_EST)
	j M_MENU2
			
#<--------- LETRAS PARA MENU --------->
SEL_MENU:
	.data
		TIPOS_BLOCOSM: .byte 'A', 'B','C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
			       'Q','R','S','T','U','V','W','X','Y','Z','>','.','*'
	.text
		mv t0, a4 # Bloco Analisado
		
		la t2, TIPOS_BLOCOSM
		
		# TIPO A
		lb t1, 0(t2)
		beq t0, t1, MENU_A
		
		# TIPO B
		lb t1, 1(t2)
		beq t0, t1, MENU_B
		
		# TIPO C
		lb t1, 2(t2)
		beq t0, t1, MENU_C
		
		# TIPO D
		lb t1, 3(t2)
		beq t0, t1, MENU_D
		
		# TIPO E
		lb t1, 4(t2)
		beq t0, t1, MENU_E
		
		# TIPO F
		lb t1, 5(t2)
		beq t0, t1, MENU_F
		
		# TIPO G
		lb t1, 6(t2)
		beq t0, t1, MENU_G
		
		# TIPO H
		lb t1, 7(t2)
		beq t0, t1, MENU_H
		
		# TIPO I
		lb t1, 8(t2)
		beq t0, t1, MENU_I
		
		# TIPO J
		lb t1, 9(t2)
		beq t0, t1, MENU_J
		
		# TIPO K
		lb t1, 10(t2)
		beq t0, t1, MENU_K
		
		# TIPO L
		lb t1, 11(t2)
		beq t0, t1, MENU_L
		
		# TIPO M
		lb t1, 12(t2)
		beq t0, t1, MENU_M
		
		# TIPO N
		lb t1, 13(t2)
		beq t0, t1, MENU_N
		
		# TIPO O
		lb t1, 14(t2)
		beq t0, t1, MENU_O
		
		# TIPO P
		lb t1, 15(t2)
		beq t0, t1, MENU_P
		
		# TIPO Q
		lb t1, 16(t2)
		beq t0, t1, MENU_Q
		
		# TIPO R
		lb t1, 17(t2)
		beq t0, t1, MENU_R
		
		# TIPO S
		lb t1, 18(t2)
		beq t0, t1, MENU_S
		
		# TIPO T
		lb t1, 19(t2)
		beq t0, t1, MENU_TT
		
		# TIPO U
		lb t1, 20(t2)
		beq t0, t1, MENU_U
		
		# TIPO V
		lb t1, 21(t2)
		beq t0, t1, MENU_V
		
		# TIPO W
		lb t1, 22(t2)
		beq t0, t1, MENU_W
		
		# TIPO X
		lb t1, 23(t2)
		beq t0, t1, MENU_X
		
		# TIPO Y
		lb t1, 24(t2)
		beq t0, t1, MENU_Y
		
		# TIPO Z
		lb t1, 25(t2)
		beq t0, t1, MENU_Z
		
		# TIPO >
		lb t1, 26(t2)
		beq t0, t1, MENU_GG # Seta
		
		# TIPO >
		lb t1, 27(t2)
		beq t0, t1, MENU_PP # Seta
		
		# TIPO ;
		lb t1, 28(t2)
		beq t0, t1, MENU_BL # Seta
		
		ret
MENU_A:		
	la a4, A	
	j PINTAR_BLOCO
MENU_B:		
	la a4, B	
	j PINTAR_BLOCO
MENU_C:		
	la a4, C
	j PINTAR_BLOCO
MENU_D:		
	la a4, D
	j PINTAR_BLOCO
MENU_E:		
	la a4, E
	j PINTAR_BLOCO
MENU_F:		
	la a4, F
	j PINTAR_BLOCO
MENU_G:		
	la a4, G
	j PINTAR_BLOCO
MENU_H:		
	la a4, H
	j PINTAR_BLOCO
MENU_I:		
	la a4, I
	j PINTAR_BLOCO
MENU_J:		
	la a4, J
	j PINTAR_BLOCO
MENU_K:		
	la a4, K
	j PINTAR_BLOCO
MENU_L:		
	la a4, L
	j PINTAR_BLOCO
MENU_M:		
	la a4, M
	j PINTAR_BLOCO
MENU_N:		
	la a4, N
	j PINTAR_BLOCO
MENU_O:		
	la a4, O
	j PINTAR_BLOCO
MENU_P:		
	la a4, P
	j PINTAR_BLOCO
MENU_Q:		
	la a4, Q
	j PINTAR_BLOCO
MENU_R:		
	la a4, R
	j PINTAR_BLOCO
MENU_S:		
	la a4, S
	j PINTAR_BLOCO
MENU_TT:		
	la a4, T
	j PINTAR_BLOCO
MENU_U:		
	la a4, U
	j PINTAR_BLOCO
MENU_V:		
	la a4, V
	j PINTAR_BLOCO
MENU_W:		
	la a4, W
	j PINTAR_BLOCO
MENU_X:		
	la a4, X
	j PINTAR_BLOCO
MENU_Y:		
	la a4, Y
	j PINTAR_BLOCO
MENU_Z:		
	la a4, Z
	j PINTAR_BLOCO
MENU_GG:
	la a4, Greater
	
	sb a2, 1(MENU_EST)
	sb a3, 2(MENU_EST)
	
	j PINTAR_BLOCO
MENU_PP:
	la a4, Point
	j PINTAR_BLOCO
MENU_BL:
	la a4, Black
	j PINTAR_BLOCO

#<--------- FINALIZA FASE --------->
FINALIZA_FASE:
	jal RESTAURA_MAPA
	
	#< Proxima Fase >
	addi FASE_ATUAL, FASE_ATUAL, 1
	
	li t0, 1
	beq FASE_ATUAL, t0, NOVA_FASE1
	
	li t0, 2
	beq FASE_ATUAL, t0, NOVA_FASE2
	
	li t0, 3
	beq FASE_ATUAL, t0, NOVA_FASE3
	
	li t0, 4
	beq FASE_ATUAL, t0, NOVA_FASE4
	
	li t0, 5
	beq FASE_ATUAL, t0, NOVA_FASE5
	
	li FASE_ATUAL, 1
	j NOVA_FASE1
	
#-----------------------------------
NOVA_FASE1:
	la MAPA_ATUAL, MAPA_1
	j PINTA_MAPA
	
NOVA_FASE2:
	la MAPA_ATUAL, MAPA_2
	j PINTA_MAPA
	
NOVA_FASE3:
	la MAPA_ATUAL, MAPA_3
	j PINTA_MAPA

NOVA_FASE4:
	la MAPA_ATUAL, MAPA_4
	j PINTA_MAPA
	
NOVA_FASE5:
	la MAPA_ATUAL, MAPA_5
	j PINTA_MAPA

#<--------- RESTAURA MAPA --------->
RESTAURA_MAPA:
	li a2, 0
	li a3, 0
	la a6, M_REF # Mapa de Referência

LREST_MAPA: # Loop de Restaura Mapa
	beq a3, NUM_COL, MLREST_MAPA
	lb a4, 0(a6)

	mv t2, MAPA_ATUAL # Mapa de Referência( Utilizado Para Restaurar o Mapa )
	definirBloco(a2, a3, t2, a4)

	addi a3, a3, 1
	addi a6, a6, 1
	j LREST_MAPA
	
MLREST_MAPA: # Muda Loop de Restaurar Mapa
	addi a2, a2, 1
	beq a2, NUM_LINHA, FREST_MAPA
	
	li a3, 0
	j LREST_MAPA
	
FREST_MAPA: # Fim de Restaura Mapa
	ret

#<--------- MOVIMENTO DE PERSONAGEM --------->
MOVIMENTA_LOLO:
	# Utilizados para Realizar Movimento Futuro
	mv a2, LOLO_LINHA
	mv a3, LOLO_COL
	
	# Utilizado Para Verificar se Colidiu
	mv t4, LOLO_LINHA
	mv t5, LOLO_COL
	
	# Detectar Movimento
	li t0, 0xFF200000   # Endereço de Entradas
	addi t2, t0, 4      # Endereço de Caractere
	lb t3, 0(t2)        # Caractere Pressionado
	
	# Casos de Movimento
	li t0, 'w'
	beq t3, t0, MOV_W
	
	li t0, 'a'
	beq t3, t0, MOV_A
	
	li t0, 's'
	beq t3, t0, MOV_S
	
	li t0, 'd'
	beq t3, t0, MOV_D
	
	# Movimentos Especiais
	j MOV_ESP
	
FIM_MOV:
	ret

#-----------------------------------------
MOV_W:
	# Obtém seu frame de Esquerda
	la t1, LOLO_MOV
	lb a6, 2(t1)
	
	# Verifica se Já virou para a esquerda antes
	lb t2, 2(LOLO_ESTA)
	bne t2, t0, LOLO_ATUA_MOV2
	
	addi t4, t4, -1
	j LOLO_COLIDIU

MOV_S:
	# Obtém seu frame de Esquerda
	la t1, LOLO_MOV
	lb a6, 3(t1)
	
	# Verifica se Já virou para a esquerda antes
	lb t2, 2(LOLO_ESTA)
	bne t2, t0, LOLO_ATUA_MOV2
	
	addi t4, t4, 1
	j LOLO_COLIDIU
	
MOV_A:
	# Obtém seu frame de Esquerda
	la t1, LOLO_MOV
	lb a6, 0(t1)
	
	# Verifica se Já virou para a esquerda antes
	lb t2, 2(LOLO_ESTA)
	bne t2, t0, LOLO_ATUA_MOV2
	
	addi t5, t5, -1
	j LOLO_COLIDIU
	
MOV_D:
	# Obtém seu frame de Esquerda
	la t1, LOLO_MOV
	lb a6, 1(t1)
	
	# Verifica se Já virou para a esquerda antes
	lb t2, 2(LOLO_ESTA)
	bne t2, t0, LOLO_ATUA_MOV2
	
	addi t5, t5, 1
	j LOLO_COLIDIU

#<--------- LOLO MOVIMENTOS --------->
LOLO_ATUA_MOV2:
	sb t0, 2(LOLO_ESTA)
	
LOLO_ATUA_MOV: # < LOLO ATUALIZA MOVIMENTO >
	# a6 = Frame que deverá ocorrer
	
	# 1° TIPO DE MOVIMENTO
	li t1, 1
	beq a6, t1, LOLO_ESQ1
	
	# 2° TIPO DE MOVIMENTO
	li t1, 2
	beq a6, t1, LOLO_ESQ2
	
	# 3° TIPO DE MOVIMENTO
	li t1, 3
	beq a6, t1, LOLO_ESQ3
	
	# 4° TIPO DE MOVIMENTO
	li t1, 4
	beq a6, t1, LOLO_DIR1
	
	# 5° TIPO DE MOVIMENTO
	li t1, 5
	beq a6, t1, LOLO_DIR2
	
	# 6° TIPO DE MOVIMENTO
	li t1, 6
	beq a6, t1, LOLO_DIR3
	
	# 7° TIPO DE MOVIMENTO
	li t1, 7
	beq a6, t1, LOLO_COS1
	
	# 8° TIPO DE MOVIMENTO
	li t1, 8
	beq a6, t1, LOLO_COS2
	
	# 9° TIPO DE MOVIMENTO
	li t1, 9
	beq a6, t1, LOLO_COS3
	
	# 10° TIPO DE MOVIMENTO
	li t1, 10
	beq a6, t1, LOLO_FRE1
	
	# 11° TIPO DE MOVIMENTO
	li t1, 11
	beq a6, t1, LOLO_FRE2
	
	# 12° TIPO DE MOVIMENTO
	li t1, 12
	beq a6, t1, LOLO_FRE3
	
	j FIM_MOV

#---------------------------------------------
LOLO_ESQ1:	
	li t0, 'Q' 	# Frame que deverá ser pintado
	sb t0, 0(LOLO_ESTA)
	
	#li LOLO_ROT, 1  # Ocorreu Rotação
	
	# Modifica a Esquerda
	la t0, LOLO_MOV
	li t1, 3            # Segundo movimento da esquerda.
	sb t1, 0(t0)
	
	j FIM_MOV
	
LOLO_ESQ2:	
	li t0, 'R' 	# Frame que deverá ser pintado
	sb t0, 0(LOLO_ESTA)
	
	# Modifica a Esquerda
	la t0, LOLO_MOV
	li t1, 3            # Terceiro movimento da esquerda.
	sb t1, 0(t0)
	
	j FIM_MOV
	
LOLO_ESQ3:
	li t0, 'S'	# Frame que deverá ser pintado
	sb t0, 0(LOLO_ESTA)
	
	# Modifica a Esquerda
	la t0, LOLO_MOV
	li t1, 1            	# Primeiro movimento da esquerda.
	sb t1, 0(t0)
	
	j FIM_MOV

LOLO_DIR1:	
	li t0, 'T' 	# Frame que deverá ser pintado
	sb t0, 0(LOLO_ESTA)
	
	# Modifica a Direita
	la t0, LOLO_MOV
	li t1, 5            	# Primeiro movimento da esquerda.
	sb t1, 1(t0)
	
	j FIM_MOV

LOLO_DIR2:	
	li t0, 'U'	# Frame que deverá ser pintado
	sb t0, 0(LOLO_ESTA)
	
	# Modifica a Direita
	la t0, LOLO_MOV
	li t1, 6            	# Primeiro movimento da esquerda.
	sb t1, 1(t0)
	
	j FIM_MOV

LOLO_DIR3:	
	li t0, 'V'	# Frame que deverá ser pintado
	sb t0, 0(LOLO_ESTA)
	
	# Modifica a Direita
	la t0, LOLO_MOV
	li t1, 4            	# Primeiro movimento da esquerda.
	sb t1, 1(t0)
	
	j FIM_MOV
	
LOLO_COS1:
	li t0, 'W'	# Frame que deverá ser pintado
	sb t0, 0(LOLO_ESTA)
	
	# Modifica a Costas
	la t0, LOLO_MOV
	li t1, 8            	# Primeiro movimento da esquerda.
	sb t1, 2(t0)
	
	j FIM_MOV
	
LOLO_COS2:	
	li t0, 'X'	# Frame que deverá ser pintado
	sb t0, 0(LOLO_ESTA)
	
	# Modifica a Costas
	la t0, LOLO_MOV
	li t1, 9            	# Primeiro movimento da esquerda.
	sb t1, 2(t0)
	
	j FIM_MOV

LOLO_COS3:	
	li t0, 'Y'	# Frame que deverá ser pintado
	sb t0, 0(LOLO_ESTA)
	
	# Modifica a Costas
	la t0, LOLO_MOV
	li t1, 7            	# Primeiro movimento da esquerda.
	sb t1, 2(t0)
	
	j FIM_MOV

LOLO_FRE1:	
	li t0, 'Z'
	sb t0, 0(LOLO_ESTA)
	
	# Modifica a Frente
	la t0, LOLO_MOV
	li t1, 11            	# Primeiro movimento da esquerda.
	sb t1, 3(t0)
	
	j FIM_MOV

LOLO_FRE2:	
	li t0, 'p'	# Frame que deverá ser pintado
	sb t0, 0(LOLO_ESTA)
	
	# Modifica a Frente
	la t0, LOLO_MOV
	li t1, 12            	# Primeiro movimento da esquerda.
	sb t1, 3(t0)
	
	j FIM_MOV

LOLO_FRE3:	
	li t0, 'q'	# Frame que deverá ser pintado
	sb t0, 0(LOLO_ESTA)
	
	# Modifica a Frente
	la t0, LOLO_MOV
	li t1, 10            	# Primeiro movimento da esquerda.
	sb t1, 3(t0)
	
	j FIM_MOV

#<--------- VERIFICA SE PERSONAGEM COLIDIU --------->
LOLO_COLIDIU:
	obterBloco(t4, t5, MAPA_ATUAL) # Guarda Bloco em a1
	
	li t6, 'E' # E = Chão
	bne a1, t6, LOLO_SEM_MOV

LOLO_NCOLIDIU: # Lolo Colidiu Porém com um elemento válido

	# Modifica Bloco
	definirBloco(LOLO_LINHA, LOLO_COL, MAPA_ATUAL, t6)
	
	# Atualiza Movimento
	mv LOLO_LINHA, t4
	mv LOLO_COL, t5
	
	# Nova Posição do Personagem
	li t6, 'P'
	definirBloco(LOLO_LINHA, LOLO_COL, MAPA_ATUAL, t6)
	
	j LOLO_ATUA_MOV # Lolo Atualiza Movimentimento
	
LOLO_SEM_MOV: # < Lolo Colidiu em Algo >
	# Aqui serao feitas analises mais complexas, como o caso de ser um bloco que permite movimento
	
	# Colidiu com um coração
	li t0, 'H'
	beq t0, a1, OBTER_COR # Obter Coração
	
	# Colidiu com uma Pedra
	li t0, 'N'
	beq t0, a1, MOV_PEDRA
	
	# Colidiu com um Bau
	li t0, 'I'
	beq t0, a1, COL_BAU
	
	# Colidiu com a Porta
	li t0, 'J'
	beq t0, a1, COL_PORTA
	
	ret
	
OBTER_COR: # < Obter Coração >
	# Aumenta em 2 o número de tiros disponíveis
	
	lb t0, 1(LOLO_ESTA) # Numero de Tiros de Lolo Disponivel
	addi t0, t0, 2
	sb t0, 1(LOLO_ESTA)
	
	# Numero de Corações Pegos
	addi CORAC_PEGAR, CORAC_PEGAR, -1
	
	j LOLO_NCOLIDIU

COL_BAU: # Colidiu com Baú
	la t0, BAU_EST
	lb t1, 2(t0)
	
	bnez t1, COL_BAU2 # Verifica se Bau está aberto
	ret
	
COL_BAU2:
	li GANHOU, 1	  # Significa que Ganhou de Fato
	j LOLO_NCOLIDIU
	
#----------------------------------
COL_PORTA:
	la t0, PORTA_EST
	lb t0, 2(t0)
	
	beqz t0, COL_PORTA2 # Verifica se a porta esta aberta
	# Esta Aberta
	j FINALIZA_FASE

COL_PORTA2:
	ret

#<----------- ABERTURA DO BAÚ ------------->
ABRE_BAU:
	li CORAC_PEGAR, -1
	
	#mv a0, ra # Endereço de Retorno
	
	la t0, BAU_EST # Estado do Baú
	lb a2, 0(t0)
	lb a3, 1(t0)
	li a4, 'o'
	
	# Bau Aberto
	li t1, 1
	sb t1, 2(t0)
	
	jal SELECIONAR_BLOCO
	
	j LOOP_JOGO3

#<----------- ABERTURA DO PORTA ------------->
ABRE_PORTA:
	la t0, PORTA_EST
	lb a2, 0(t0)
	lb a3, 1(t0)
	li a4, 'p'
	
	# Porta Aberta
	sb GANHOU, 2(t0) # Armazena na Porta o estado de Ganhar
	li GANHOU, 0
	
	jal SELECIONAR_BLOCO
	
	j LOOP_JOGO2

#<--------- MOVIMENTA PEDRA --------->

MOV_PEDRA: # Verifica Qual Movimento da Pedra
	.data
		#                 L  C  R(retorno)	          
		NLOLO_INFO: .word 0, 0, 0
	.text
	
	# t4,t5 = Nova Posição do Personagem e antiga posição da pedra
	# t3 = Tecla pressionada
	
	# Memórias de Uso Temporário um Backup - Evitar Uso de Mais de Registradores
	la a0, NLOLO_INFO
	sw t4, 0(a0)	# Nova Linha de Lolo
	sw t5, 4(a0)	# Nova Coluna de Lolo
	sw ra, 8(a0)	# Endereço de retorno
	
	li t0, 'w'
	beq t3, t0, MOV_PEDRA_W
		
	li t0, 'a'
	beq t3, t0, MOV_PEDRA_A
	
	li t0, 's'
	beq t3, t0, MOV_PEDRA_S
	
	li t0, 'd'
	beq t3, t0, MOV_PEDRA_D
	
	ret

#---------------------------------------
MOV_PEDRA2: # Realiza Movimento da Pedra 
	
	# Dados Para Renderizar Pedra
	mv a2, t4	# Linha
	mv a3, t5	# Coluna
	li a4, 'N'	# Tipo de Bloco
	
	definirBloco(a2, a3, MAPA_ATUAL, a4)
	
	# Repintar Pedra
	jal SELECIONAR_BLOCO
	
	# Restaurando a2 e a3
	mv a2, LOLO_LINHA
	mv a3, LOLO_COL
	
	li t6, 'E' 	# Chão
	lw t4, 0(a0)
	lw t5, 4(a0)
	lw ra, 8(a0)
	
	j LOLO_NCOLIDIU
	
#--------------------------------------
MOV_PEDRA_W:
	addi t4, t4, -1
	j PEDRA_COLIDIU
	
MOV_PEDRA_A:
	addi t5, t5, -1
	j PEDRA_COLIDIU

MOV_PEDRA_S:
	addi t4, t4, 1
	j PEDRA_COLIDIU

MOV_PEDRA_D:
	addi t5, t5, 1
	j PEDRA_COLIDIU
			
PEDRA_COLIDIU:
	obterBloco(t4, t5, MAPA_ATUAL)
	
	li t0, 'E'
	beq a1, t0, MOV_PEDRA2
	
	ret # Pedra Não pode Ser Movida
	
	
#<--------- MOVIMENTOS ESPECIAIS --------->
MOV_ESP:
	# Ir para Menu
	li t0, 'm'
	beq t3, t0, ME_MENU # Movimento Especial Menu
	
	# Proxima Fase
	li t0, 'h'
	beq t3, t0, ME_PROX_FASE # Movimento Especial Menu
	
	# Fase Anterior
	li t0, 'g'
	beq t3, t0, ME_ANT_FASE # Movimento Especial Menu
	
	# Movimento Especial de Tiro
	li t0, 'l'
	beq t3, t0, MOV_M
	
	# Saída da Execução do Programa
	li t0, 'e'
	beq t3, t0, EXIT
	
NAO_MOV_ESP:
	ret
	
#--------------------------------------------
ME_MENU: # Movimento Especial Menu
	jal RESTAURA_MAPA
	
	# Define que o Menu está ativo
	li t0, 1
	sb t0, 0(MENU_EST)
	
	# Volta Para a Fase Atual de Inicio
	mv FASE_ATUAL, t0
	
	# Volta Ao Menu
	la MAPA_ATUAL, MENU_T
	
	j PINTA_MAPA
	
ME_PROX_FASE:
	mv t0, FASE_ATUAL
	addi t0, t0, 1
	bgt t0, NUM_FASES, NAO_MOV_ESP

	# Proxima Fase
	j FINALIZA_FASE

ME_ANT_FASE:
	mv t0, FASE_ATUAL
	addi t0, t0, -1
	beqz t0, NAO_MOV_ESP
	
	addi t0, t0, -1
	mv FASE_ATUAL, t0
	# Proxima Fase
	j FINALIZA_FASE

EXIT:
	exit()
MOV_M:
	# Definições para um tiro(é chamado a cada tiro dado apenas uma vez)
	
	lb t0, 1(LOLO_ESTA)	# Tiros de Lolo Disponível
	
	beqz t0, FIM_MOV_M	# Verifica se o número de tiros é igual a zero
	
	# Decrementa Número de Tiros Disponíveis
	addi t0, t0, -1
	sb t0, 1(LOLO_ESTA)
	
	# Registradores de Posição para sofrerem modificações
	mv t2, LOLO_LINHA
	mv t3, LOLO_COL	
	li t4, 0	# Direção do Tiro
	
	#< Lolo Frame >
	lb t5, 0(LOLO_ESTA)
	
	# < CASOS >
	
	# Tiro Frontal( Utilizaram-se muitos casos pois as letras não seguem um padrão)
	li t0, 'Z'
	beq t5, t0, MOV_M_F
	
	li t0, 'p'
	beq t5, t0, MOV_M_F
	
	li t0, 'q'
	beq t5, t0, MOV_M_F
	
	li t0, 'P'
	beq t5, t0, MOV_M_F
	
	# Tiro a Esquerda
	li t0, 'S'
	ble t5, t0, MOV_M_E
	
	# Tiro a Direita
	li t0, 'V'
	ble t5, t0, MOV_M_D
	
	# Tiro de Costas
	li t0, 'Y'
	ble t5, t0, MOV_M_C

FIM_MOV_M: ret
#--------------------------------------------
MOV_MM: # Movimento Especial M(Tiro)

	# Tiro Frontal
	li t0, 1
	beq t4, t0, MOV_M_F
	
	# Tiro a Esquerda
	li t0, 2
	beq t4, t0, MOV_M_E
	
	# Tiro a Direita
	li t0, 3
	beq t4, t0, MOV_M_D
	
	# Tiro de Costas
	li t0, 4
	beq t4, t0, MOV_M_C
	
	ret
	
MOV_M_F: # Tiro Frontal
	li t4, 1
	addi t2, t2, 1
	j COLIDIU_TIRO
		
MOV_M_E: # Tiro a Esquerda
	li t4, 2
	addi t3, t3, -1
	j COLIDIU_TIRO
	
MOV_M_D: # Tiro a Direita
	li t4, 3
	addi t3, t3, 1
	j COLIDIU_TIRO
	
MOV_M_C: # Tiro de Costas
	li t4, 4
	addi t2, t2, -1
	j COLIDIU_TIRO
	
#--------------------------------------------	
COLIDIU_TIRO:
	obterBloco(t2, t3, MAPA_ATUAL)
	
	li t0, 'E'
	bne a1, t0, FIM_COL_TIRO
	
	# Definições para o tiro ser renderizado
	mv a2, t2
	mv a3, t3
	li a4, 'L'
	
	# Backup dos valores anteriores
	mv a0, ra
	mv a1, t2
	mv a6, t3
	mv a7, t4
	
	jal SELECIONAR_BLOCO # Renderizar Tiro
	
	# Retornando os Valores Anteriores
	mv ra, a0
	mv t2, a1
	mv t3, a6
	mv t4, a7
	
	# Tempo de Espera
	li a0,10		# pausa de 10m segundos
	li a7,32
	ecall
	
	# Trocar Onde estava o tiro para um chão
	li a4, 'E'
	
	# Backup dos valores anteriores
	mv a0, ra		# Endereço de Retorno
	mv a1, t2		# Posição do tiro
	mv a6, t3
	mv a7, t4
	
	jal SELECIONAR_BLOCO
	
	# Retornando os Valores Anteriores
	mv ra, a0
	mv t2, a1
	mv t3, a6
	mv t4, a7
	
	j MOV_MM
	
FIM_COL_TIRO:
	obterBloco(t2, t3, MAPA_ATUAL)
	
	#< Colisão de Tiro com Snake >
	li t0, 'K' # Snake
	beq a1, t0, MOD_SNAKE1 # Modifica Snake
	
	li t0, 'M'
	beq a1, t0, MOD_SNAKE2
	ret

#<--------- TIRO EM SNAKE --------->
MOD_SNAKE1:
	li t4, 'M' # Modifica para um Ovo
	j MOD_SNAKE
MOD_SNAKE2:
	li t4, 'E' # Mata Snake

MOD_SNAKE: # Modifica Snake
	definirBloco(t2, t3, MAPA_ATUAL, t4)
	
	mv a0, ra # Salvando Endereço de Retorno

	# Renderização do novo estado de Snake
	mv a2, t2
	mv a3, t3
	mv a4, t4
	
	jal SELECIONAR_BLOCO
	
	# Restaurar valores de a2 e a3
	mv a2, LOLO_LINHA
	mv a3, LOLO_COL
	
	mv ra, a0
	ret
	
#<--------- SELEÇÃO DE BLOCOS --------->
SELECIONAR_BLOCO:
	.eqv TILE_LINHA a2   # Linha no Mapa
	.eqv TILE_COL   a3   # Coluna no Mapa
	.eqv TILE_BLOCO a4   # Bloco Escolhido
	.eqv TILE_FRAME a5   # Endereço do Frame Escolhido

.data
	TIPOS_BLOCOS: .byte 'A', 'B','C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'o', 'p','*'
.text
	la t2, TIPOS_BLOCOS
	
	mv t0, TILE_BLOCO
	
	# TIPO A
	lb t1, 0(t2)
	beq t0, t1, BLOCO_A
	# TIPO B
	lb t1, 1(t2)
	beq t0, t1, BLOCO_B
	# TIPO C
	lb t1, 2(t2)
	beq t0, t1, BLOCO_C
	# TIPO D
	lb t1, 3(t2)
	beq t0, t1, BLOCO_D
	# TIPO E
	lb t1, 4(t2)
	beq t0, t1, BLOCO_E
	# TIPO F
	lb t1, 5(t2)
	beq t0, t1, BLOCO_F
	# TIPO G
	lb t1, 6(t2)
	beq t0, t1, BLOCO_G
	# TIPO H (Hearth)
	lb t1, 7(t2)
	beq t0, t1, BLOCO_H
	# TIPO I
	lb t1, 8(t2)
	beq t0, t1, BLOCO_I
	# TIPO J(Porta)
	lb t1, 9(t2)
	beq t0, t1, BLOCO_J
	# TIPO K(Snake)
	lb t1, 10(t2)
	beq t0, t1, BLOCO_K
	# TIPO L(SHOT)
	lb t1, 11(t2)
	beq t0, t1, BLOCO_L
	# TIPO M(Snake2)
	lb t1, 12(t2)
	beq t0, t1, BLOCO_M
	# TIPO N(Rock)
	lb t1, 13(t2)
	beq t0, t1, BLOCO_N
	# TIPO O(Tesouro 2)
	lb t1, 14(t2)
	beq t0, t1, BLOCO_O
	# TIPO P(Porta 2)
	lb t1, 15(t2)
	beq t0, t1, BLOCO_pp
	# TIPO *(Preto)
	lb t1, 16(t2)
	beq t0, t1, BLOCO_AS
	
	# Foi colocado a parte para que futuramente não estoure os endereços
	j SEL_PER
	
FIM_SEL_BLOCO: ret

#<--------- TIPOS DE BLOCO DE TERRENO --------->
BLOCO_A:
	la a4, wall1
	j PINTAR_BLOCO
BLOCO_B:
	la a4, wall3
	j PINTAR_BLOCO
BLOCO_C:
	la a4, wall4
	j PINTAR_BLOCO
BLOCO_D:
	la a4, wall2
	j PINTAR_BLOCO
BLOCO_E:
	la a4, ground1
	j PINTAR_BLOCO
BLOCO_F:
	la a4, tree1
	j PINTAR_BLOCO
BLOCO_G:
	la a4, tree2
	j PINTAR_BLOCO
BLOCO_H:
	addi CORAC_PEGAR, CORAC_PEGAR, 1
	
	la a4, hearth
	j PINTAR_BLOCO
BLOCO_I:
	la a4, treasure1
	
	la t0, BAU_EST
	sb a2, 0(t0)   # Linha do Baú
	sb a3, 1(t0)   # Coluna do Baú
	sb zero, 2(t0) # Baú Fechado
	
	j PINTAR_BLOCO
BLOCO_J:
	la a4, door
	
	la t0, PORTA_EST
	sb a2, 0(t0)	# Linha da Porta
	sb a3, 1(t0)	# Coluna da Porta
	sb zero, 2(t0)  # Porta Fechada
	
	j PINTAR_BLOCO
BLOCO_K:
	la a4, Snake
	j PINTAR_BLOCO
BLOCO_L:
	la a4, Shot
	j PINTAR_BLOCO
BLOCO_M:
	la a4, Snake2
	j PINTAR_BLOCO
BLOCO_N:
	la a4, rock
	j PINTAR_BLOCO
BLOCO_O:
	la a4, treasure2
	j PINTAR_BLOCO
BLOCO_pp:
	la a4, door2
	j PINTAR_BLOCO
BLOCO_AS:
	la a4, Black
	j PINTAR_BLOCO
	
#<--------- SELECIONA PERSONAGEM ( Uma Extensão de 'SELECIOANAR_BLOCO') --------->
SEL_PER:
.data 
	TIPOS_PER: .byte 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'p', 'q'
.text
	la t2, TIPOS_PER
	
	#  VERIFICA SE O BLOCO É UM PERSONAGEM
	lb t1, 0(t2)
	beq t0, t1, PINTA_PER
	
	ret
	
#<--------- PINTA PERSONAGEM --------->
PINTA_PER:
	# t2 = TIPOS_PER
	
	# Local onde o Personagem Está
	mv s3, a2
	mv s4, a3
	
	#< Lolo Frame >
	lb t3, 0(LOLO_ESTA)
	
	#< CASOS >
	
	# TIPO P
	lb t1, 0(t2)
	beq t3, t1, BLOCO_P
	
	# TIPO Q
	lb t1, 1(t2)
	beq t3, t1, BLOCO_Q
	
	# TIPO R
	lb t1, 2(t2)
	beq t3, t1, BLOCO_R
	
	# TIPO S
	lb t1, 3(t2)
	beq t3, t1, BLOCO_S
	
	# TIPO T
	lb t1, 4(t2)
	beq t3, t1, BLOCO_T
	
	# TIPO U
	lb t1, 5(t2)
	beq t3, t1, BLOCO_U
	
	# TIPO V
	lb t1, 6(t2)
	beq t3, t1, BLOCO_V
	
	# TIPO W
	lb t1, 7(t2)
	beq t3, t1, BLOCO_W
	
	# TIPO X
	lb t1, 8(t2)
	beq t3, t1, BLOCO_X
	
	# TIPO Y
	lb t1, 9(t2)
	beq t3, t1, BLOCO_Y
	
	# TIPO Z
	lb t1, 10(t2)
	beq t3, t1, BLOCO_Z
	
	# TIPO p
	lb t1, 11(t2)
	beq t3, t1, BLOCO_p
	
	# TIPO q
	lb t1, 12(t2)
	beq t3, t1, BLOCO_q
	
	ret
	
#<--------- TIPOS DE FRAME DE PERSONAGEM --------->
BLOCO_P:
	la a4, Lolo11
	j PINTAR_BLOCO

BLOCO_Q:
	la a4, Lolo22
	j PINTAR_BLOCO

BLOCO_R:
	la a4, Lolo21
	j PINTAR_BLOCO

BLOCO_S:
	la a4, Lolo23
	j PINTAR_BLOCO

BLOCO_T:
	la a4, Lolo31
	j PINTAR_BLOCO

BLOCO_U:
	la a4, Lolo32
	j PINTAR_BLOCO

BLOCO_V:
	la a4, Lolo33
	j PINTAR_BLOCO

BLOCO_W:
	la a4, Lolo42
	j PINTAR_BLOCO

BLOCO_X:
	la a4, Lolo43
	j PINTAR_BLOCO

BLOCO_Y:
	la a4, Lolo44
	j PINTAR_BLOCO

BLOCO_Z:
	la a4, Lolo11
	j PINTAR_BLOCO

BLOCO_p:
	la a4, Lolo12
	j PINTAR_BLOCO

BLOCO_q:
	la a4, Lolo13
	j PINTAR_BLOCO

#------------------------------------------------
FIM_SEL_PER: ret

#----------------------------------------------------------------
#<<<<<<<<<<<<<<<<<<<<<< PINTAR UM BLOCO >>>>>>>>>>>>>>>>>>>>>>>>>
#----------------------------------------------------------------
PINTAR_BLOCO:
	li t5, 16
	mul t0, TILE_LINHA, t5       # Linha Atual * 16 -> pois percorre 16 pixels pra chegar na posição correta
	mul t1, TILE_COL, t5         # Coluna Atual * 16
	    
	li t2, 0                     # Elemento Atual (Contador)
	li t3, 256                   # Máximo de elementos
	
	mv t4, a4
	addi t4, t4, 8
	
	LOOP_TILE:
		beq t2, t3, FIM_TILE
		
		# Pintar Pixel
		li t5, 320               # Número de Colunas
		mul t6, t0, t5           # 320 * linha_atual
		add t6, t6, t1           # 320 * linha_atual + coluna_atual
		add t6, t6, TILE_FRAME   # t6 = t6 + endereço_frame
		
		lw t5, 0(t4)             # Carregar 4pixels
		sw t5, 0(t6)             # Armazena os 4Pixels na máscara de bit
		
		addi t4, t4, 4           # Próximos 4 pixels
		addi t2, t2, 4           # Aumenta número de elementos percorridos
		addi t1, t1, 4           # Aumenta número de colunas percorridas em uma linha
		
		# SE t2 % 16 == 0: [ Nova Linha ]
		li t5, 16
		rem t5, t2, t5
		beq t5, zero, LINHA_TILE
		
		j LOOP_TILE
	LINHA_TILE:
		addi t0, t0, 1
		
		li t5, 16
		mul t1, TILE_COL, t5
		
		j LOOP_TILE
	FIM_TILE:
		j FIM_SEL_BLOCO
