.data
filename: .asciiz "./Pirouette.txt" # nom du fichier
cre: .asciiz "./test.Z77" # nom du fichier
textSpace: .space 1050

.text
#N=11 F=5
li $t0 11
li $t1 5

create:				#creer le fichier avec le nom cre
	li $v0, 13
	la $a0, cre
	li $a1, 1
	li $a2, 0
	syscall
	move $t3, $v0

write:				#ecrit dans le fichier lz77 le 10 caractères dans $s1
	li $v0, 15
	move $a0, $t3
	la $a1, $s1
	li $a2, 10
	syscall

#Ouverture du fichier
li $v0 13
la $a0, filename
li $a1, 0 # ouverture pour Ã©criture
li $a2, 0
syscall        

# Lecture et affichage du fichier
move $a0, $v0 # charge le descripteur de fichier
li $v0, 14
la $a1, textSpace
li $a2, 1050
syscall  
la $a0, textSpace
li $v0, 4
syscall

exit:
li $v0 10
syscall
