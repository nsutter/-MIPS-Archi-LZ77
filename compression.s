.data
nom_fichier: .asciiz "./Lepetitprince.txt" # nom du fichier

saut_ligne: .asciiz "\n"
toast: .asciiz "\n------------\n"

buffer: .space 1050
cre: .asciiz "./test.lz77" # nom du fichier ecrit

.text
#N=11 F=5
li $t0 11
li $t1 5

#Ouverture du fichier
li $v0 13
la $a0, nom_fichier
li $a1, 0 # ouverture pour écriture
li $a2, 0
syscall        

# On stocke le descripteur du fichier dans t2
move $t2, $v0
move $a0, $v0

# Affichage 1
li $a2 50
jal Lecture

la $a0, toast
li $v0,4
syscall

j exit

# Lecture d'un fichier
# a2 la taille
Lecture:
	subiu $sp $sp 12
	sw $ra 0($sp)
	sw $a0 4($sp)
	sw $a1 8($sp)

	li $v0, 14
	la $a1, buffer
	syscall

	la $a0, buffer
	li $v0, 4
	syscall
	
	la $a0, toast
	li $v0,4
	syscall
	#C'EST PAR LA QUE CA SE PASSE
	la $t0, buffer
	lb $a0, 0($t0)#REMPLACE LE DEUX PAR LA POSITION DE LA LETTRE SOUHAITER
	li $v0, 11
	syscall

	lw $ra 0($sp)
	lw $a0 4($sp)
	lw $a1 8($sp)
	addiu $sp $sp 12
	jr $ra

# Creer un fichier avec le nom cre
create:
	subiu $sp $sp 16
	sw $ra 0($sp)
	sw $a0 4($sp)
	sw $a1 8($sp)
	sw $a2 12($sp)

	li $v0, 13
	la $a0, cre
	li $a1, 1
	li $a2, 0
	syscall
	move $t3, $v0

	lw $ra 0($sp)
	lw $a0 4($sp)
	lw $a1 8($sp)
	lw $a2 12($sp)
	addiu $sp $sp 16
	jr $ra

# Ecrit dans le fichier lz77 le 10 caracteres dans $s1
write:
	subiu $sp $sp 16
	sw $ra 0($sp)
	sw $a0 4($sp)
	sw $a1 8($sp)
	sw $a2 12($sp)

	li $v0, 15
	move $a0, $t3
	la $a1, ($s1)
	li $a2, 10
	syscall
	
	lw $ra 0($sp)
	lw $a0 4($sp)
	lw $a1 8($sp)
	lw $a2 12($sp)
	addiu $sp $sp 16
	jr $ra

#ferme les fichiers dans $t2 et $t3
close:
	subiu $sp $sp 16
	sw $ra 0($sp)
	sw $a0 4($sp)
	sw $a1 8($sp)
	sw $a2 12($sp)

	li   $v0, 16      
	move $a0, $t2    
	syscall  
	li   $v0, 16      
	move $a0, $t3    
	syscall 

	lw $ra 0($sp)
	lw $a0 4($sp)
	lw $a1 8($sp)
	lw $a2 12($sp)
	addiu $sp $sp 16
	jr $ra


exit:
li $v0 10
syscall
