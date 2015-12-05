.data
filename: .asciiz "./Pirouette.txt" # nom du fichier
textSpace: .space 1050

.text
#N=11 F=5
li $t0 11
li $t1 5

#Ouverture du fichier
li $v0 13
la $a0, filename
li $a1, 0 # ouverture pour écriture
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
