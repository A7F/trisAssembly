.data 
	getp1:	.asciiz "\ngiocatore X, scegli una casella: "
	getp2:	.asciiz "\ngiocatore O, scegli una casella: "
	output1:	.asciiz "\nha vinto il giocatore X!"
	output2:	.asciiz "\nha vinto il giocatore O!"
	output3:	.asciiz "\nla casella scelta non esiste.Scegli un' altra casella da 1 a 9"
	output4:	.asciiz "\nla casella è già stata scelta. Scegli un' altra casella da 1 a 9"
	output5:	.asciiz "\nla partita è patta."
	output6:	.asciiz "O"		#segnaposto giocatore 1
	output7:	.asciiz "X"		#segnaposto giocatore 2
	dash:	.asciiz "-"		#trattino che indica casella vuota
	row:	.asciiz "\n-----------------\n"	#riga
	column:	.asciiz "  |"		#colonna
	align:	.asciiz "  "		#carattere per allineare la prima colonna che altrimenti non sarebbe centrata bene	
	inseriti:	.space 36		#i valori del gioco (X o O) vengono salvati in questo array, su cui farò i confronti.

.text
main:
	addi $a1,$zero,9
	la $a0,inseriti
	add $t0,$zero,$zero	#i=0
	
loop:	add $t1,$t0,$t0	#ciclo per azzerare l'array di memoria che inizia da inseriti
	add $t1,$t1,$t1
	add $t2,$a0,$t1	#t2 contiene l'elemento del vettore
	sw $zero,0($t2)
	addi $t0,$t0,1
	slt $t4,$t0,$a1
	bne $t4,$zero,loop
	
	addi $t0,$zero,0	#modificato con zero
	addi $s0,$zero,9	#contatore per i turni svolti
	addi $s1,$zero,1	#1 è X
	addi $s2,$zero,2	#2 è O
	addi $s3,$zero,3	#su ogni riga stanno 3 "inseriti"
	addi $s4,$zero,3	#su ogni colonna stanno 3 "inseriti"
	add $t8,$zero,$zero	#imposta il flag di vittoria a zero. Se vale 1 ha vinto X, 2 ha vinto O, -1 pareggio.
	add $a0,$zero,$zero
	add $a1,$zero,$zero	
print:
	la $a2,inseriti	#posiziono indirizzo di inseriti per stampare il vettore di word
	li $v0,4		#prepara la syscall
		
	subprint:
		lw $t2,0($a2)	#carica in t2 il primo elemento della lista per controllare se è X,O,-
		addi $a2,$a2,4	#incrementa di una posizione il puntatore
		la $a0,align	#stampa lo spazio bianco di allineamento (questione grafica)
		syscall
		beq $t2,$zero,trattino	#se t2 è zero allora non ho inserito valori quindi è trattino
		beq $t2,$s2,cerchio		#se t2 vale 2 allora è cerchio quindi salta alla proc per stampare il cerchio
	croce:				#fallout: se non è nè trattino nè cerchio, allora deve essere croce.
		la $a0,output7	#carica l'indirizzo per stampare la X
		syscall
		addi $s3,$s3,-1	#decremento di 1 il contatore dei numeri per riga in modo da sapere quante colonne fare
		bgt $s3,$zero,colonna	#se i numeri per riga sono maggiori di zero, significa che le colonne non ci sono tutte. stampane una.
		j acapo		#controlla se le colonne sono state stampate tutte e tre
		
	cerchio:
		la $a0,output6	#carica l'indirizzo per stampare il O
		syscall
		addi $s3,$s3,-1	#decremento di 1 il contatore dei numeri per riga in modo da sapere quante colonne fare
		bgt $s3,$zero,colonna	#se i numeri per riga sono maggiori di zero, significa che le colonne non ci sono tutte. stampane una.
		j acapo		#controlla se le colonne sono state stampate tutte e tre
		
	trattino:
		la $a0,dash	#carica indirizzo del trattino per stamparlo
		syscall
		add $s3,$s3,-1	#decremento di 1 il contatore dei numeri per riga
		bgt $s3,$zero,colonna	#se non ho ancora messo le tre posizioni, metti un divisorio colonna
		j acapo
		
	colonna:
		la $a0,column
		syscall
		j subprint		#ripete la procedura per fare tutte e tre le colonne
		
	acapo:
		la $a0,row		#stampa un divisorio
		syscall
		addi $s4,$s4,-1	#è stata stampata una riga. decrementa di 1 il contatore righe
		addi $s3,$s3,3	#tutte e tre le colonne sono state stampate quindi reinizializza $s3 a 3 per contare di nuovo
		bgt $s4,$zero,subprint	#se non hai stampato tutte e tre le righe, stampane una
		beq $s0,$zero,pat	#check del turno per mostrare il testo del giocatore corrispondente
		beq $t8,1,pw1
		beq $t8,2,pw2
		j turno
		pw1:	la $a0,output1	#stampa che il giocatore 1 ha vinto
			li $v0,4
			syscall
			j end		#termina la partita chiudendo il programma
		pw2:	la $a0,output2	#stampa che il giocatore 2 ha vinto
			li $v0,4
			syscall
			j end		#termina la partita chiudendo il programma
		pat:	la $a0,output5	#stampa che la partita è patta.
			li $v0,4
			syscall
			j end		#termina la partita chiudendo il programma
	
turnoerr:
	li $v0,4		#carica la stringa di errore input non valido
	la $a0,output4
	syscall
turno:
	li $a0,2
	div $s0,$a0	#questa divisione serve per sapere di chi sia il turno
	mfhi $t9
	beq $t9,$zero,turnp1	#controllo se la divisione ha dato resto o no
turnp2:	li $v0,4		#stampa stringa
	la $a0,getp2
	syscall
	j getinput
turnp1:	li $v0,4		#stampa stringa
	la $a0,getp1
	syscall
getinput:	li $v0,5		#inserisci un intero (ottiene la casella scelta). il numero letto viene messo in $v0
	syscall
	slti $t2,$v0,1	#se l'utente mette un numero minore di 1 gestisce l'errore
	bne $t2,$zero,exception
	slti $t2,$v0,10	#se l'utente mette un numero maggiore di 10, gestisce l'errore
	beq $t2,$zero,exception
	la $a3,inseriti
	addi $v0,$v0,-1	#sottrai uno dal valore inserito dall'utente, perchè gli array partono da zero! altrimenti overflow
	sll $v1,$v0,2	#moltiplica per 4 il valore inserito dall'utente
	add $a3,$a3,$v1	#fai puntare alla cella scelta dall' utente
	lw $a2,0($a3)
	bne $a2,$zero,turnoerr	#gestione errore: utente che sceglie una casella già occupata
	bne $t9,$zero,setp2
setp1:	addi $a2,$a2,1		#metti la X nella casella
	j setcont
setp2:	addi $a2,$a2,2		#metti la O nella casella
setcont:	sw $a2,0($a3)
	addi $s0,$s0,-1	#decrementa di 1 i turni totali (9,8,7,6...)
	addi $s4,$s4,3	#reimposta a 3 il numero di caselle per colonna
	j fine
		
exception:
	li $v0,4
	la $a0,output3
	syscall
	j turno
	
fine:
	la $a0,inseriti	#carica in $a0 l'indirizzo del primo elemento di inseriti
	lw $t0,0($a0)	#inserisce i valori della prima riga nei registri $t0,$t1,$t2
	lw $t1,4($a0)
	lw $t2,8($a0)
	beq $t0, $t1, cond2	#se la casella 1 è uguale alla casella 2, vai a cond2 per il prossimo controllo
	j next		#se le prime due caselle sono diverse allora non ha vincitori e passa alla successiva
cond2:	beq $t1, $t2, cond3	#controllo se la seconda casella è uguale alla terza
	j next
cond3:	bnez $t1 win	#se la 1=2 e 2=3 allora 1=3 (pr. transitiva) quindi c'è un vincitore
next:	lw $t0, 12($a0)	#il controllo si ripete per la seconda riga
	lw $t1, 16($a0)
	lw $t2, 20($a0)
	beq $t0, $t1, con12
	j next1
con12:	beq $t1, $t2, con13
	j next1
con13:	bnez $t0, win
next1:	lw $t0, 24($a0)
	lw $t1, 28($a0)
	lw $t2, 32($a0)
	beq $t0, $t1, con22
	j next2
con22:	beq $t1, $t2, con23
	j next2
con23:	bnez $t0, win
next2:	lw $t0, 0($a0)
	lw $t1, 16($a0)
	lw $t2, 32($a0)
	beq $t0, $t1, con32
	j next3
con32:	beq $t1, $t2, con33
	j next3
con33:	bnez $t0, win
next3:	lw $t0, 8($a0)
	lw $t1, 16($a0)
	lw $t2, 24($a0)
	beq $t0, $t1, con42
	j next4
con42:	beq $t1, $t2, con43
	j next4
con43:	bnez $t0, win
next4:	lw $t0, 0($a0)
	lw $t1, 12($a0)
	lw $t2, 24($a0)
	beq $t0, $t1, con52
	j next5
con52:	beq $t1, $t2, con53
	j next5
con53:	bnez $t0, win
next5:	lw $t0, 4($a0)
	lw $t1, 16($a0)
	lw $t2, 28($a0)
	beq $t0, $t1, con62
	j next6
con62:	beq $t1, $t2, con63
	j next6
con63:	bnez $t0, win
next6:	lw $t0, 8($a0)
	lw $t1, 20($a0)
	lw $t2, 32($a0)
	beq $t0, $t1, con72
	j next7
con72:	beq $t1, $t2, con73
	j next7
con73:	bnez $t0, win
next7:	bne $s0, $zero, print	#controlla se i turni si sono esauriti (cioè 9 --> 0). Se No, allora ripete tutto; altrimenti è patta.
	j draw		#qualcuno deve aver vinto entro il nono turno altrimenti è patta.
	
		
win:	beq $t0,1,win1	#se in t0 c'è un 1 allora ha vinto il giocatore 1, altrimenti il 2.
	beq $t0,2,win2
win1:	addi $t8,$zero,1	#setta t8 con l'id del vincitore. -1 significa patta.
	j print	
win2:	addi $t8,$zero,2
	j print
draw:	addi $t8,$zero,-1
	j print
		
end:	li $v0,10		#codice syscall per chiudere il programma
	syscall
