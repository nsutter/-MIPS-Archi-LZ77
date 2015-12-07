.data
  nom_fichier: .asciiz "./Lepetitprince.txt" # nom du fichier

  saut_ligne: .asciiz "\n"
  toast: .asciiz "\n------------\n"

  buffer: .space 1050
  cre: .asciiz "./test.lz77" # nom du fichier ecrit

.text
# N=6 F=5
li $t0 6
li $t1 5

#### DEBUT Ouverture et lecture du fichier
li $v0 13
la $a0, nom_fichier
li $a1, 0 # ouverture pour écriture
li $a2, 0
syscall

# On stocke le descripteur du fichier dans t2
move $t2, $v0

move $a0, $t2
li $v0, 14
la $a1, buffer
li $a2, 1050 # taille du buffer en dur
syscall

#### FIN Ouverture et lecture du fichier

jal create

jal CreerTampon

lb $a0 0($t4)
li $v0 11
syscall

j exit

#### DEBUT Fonction de creation tampon
CreerTampon:
  subiu $sp $sp 20
  sw $ra 0($sp)
  sw $a0 4($sp)
  sw $a1 8($sp)
  sw $a2 12($sp)
  sw $s1 16($sp)

  li $s1 0

  add $a1 $t0 $t1
  RappelTampon:
    jal Extraction
    lb $t4 0($a0)
    addi $s1 $s1 1
    addi $t4 $t4 1
    bne $s1 $a1 RappelTampon

  lw $ra 0($sp)
  lw $a0 4($sp)
  lw $a1 8($sp)
  lw $a2 12($sp)
  lw $s1 12($sp)
  addiu $sp $sp 20
  jr $ra

# Recupere le 
Extraction:
	la $t0, buffer
	add $t0 $t0 $s1
	lb $a0, 0($t0)
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

# Ecrit dans le fichier lz77 les 10 caracteres dans $s1
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

# Ferme les fichiers dans $t2 et $t3
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
