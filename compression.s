.data
nom_fichier: .asciiz "./Pirouette.txt" # nom du fichier

saut_ligne: .asciiz "\n"
toast: .asciiz "\n------------\n"

buffer: .space 1050
cre: .asciiz "./test.lz77" # nom du fichier écrit

.text
#N=11 F=5
li $t0 11
li $t1 5



#Ouverture du fichier
li $v0 13
la $a0, nom_fichier
li $a1, 0 # ouverture pour Ã©criture
li $a2, 0
syscall        

# On stocke le descripteur du fichier dans t2
move $t2, $v0

# Affichage 1
li $a2 50
jal Lecture

la $a0, toast
li $v0,4
syscall

# Affichage 2
li $a2 100
jal Lecture

j exit


# Lecture d'un fichier
# a2 la taille
Lecture:
	move $a0, $t2
	li $v0, 14
	la $a1, buffer
	syscall  
	la $a0, buffer
	li $v0, 4
	syscall
	jr $ra

# Créer un fichier avec le nom cre
create:
	li $v0, 13
	la $a0, cre
	li $a1, 1
	li $a2, 0
	syscall
	move $t3, $v0

# Écrit dans le fichier lz77 le 10 caractères dans $s1
write:
	li $v0, 15
	move $a0, $t3
	la $a1, $s1
	li $a2, 10
	syscall

exit:
li $v0 10
syscall
