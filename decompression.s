.data
  nom_fichier: .asciiz "./test.lz77" # nom du fichier de sortie
  cre: .asciiz "./test.txt"

  buffer_lecture: .space 1600
  buffer: .space 7
  buff_txt: .space 6


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
  move $t2, $v0

  #stockage dans buffer du contenu
  move $a0, $t2
  li $v0, 14
  la $a1, buffer_lecture
  li $a2, 1600 # taille du buffer en dur
  syscall

  jal create

  jal Testfin
  beq $v0 0 Exit
  jal Initialise_buffer
  li $4 0
  loop:
    li $a0 '/'
    li $v0 11
    syscall
    la $a0 buffer
    li $v0 4
    syscall
    jal extraction
    move $s1 $t5
    andi $s1,$s1,0x0F #convertit le caracteres en chiffre
    beqz $s1 cas_zero
    jal cas_autre
    addi $t4 $t4 7
    jal Testfin
    bne $v0 0 loop

  j Exit

  cas_zero:
    li $s2 1
    la $s1 buff_txt
    sb $t7 0($s1)
    jal write
    jal shift
    move $s3 $t7
    jal add_buff
    addi $t4 $t4 7
    jal Testfin
    bne $v0 0 loop
    j Exit

  cas_autre:

    subiu $sp $sp 4
    sw $ra 0($sp)

    li $s1 0
    andi $s6,$t6,0x0F
    andi $t5,$t5,0x0F
    subi $t5 $t5 1
    la $s4 buffer
    add $s4 $s4 $t5
    la $s5 buff_txt
    loopcas:
      lb $s3 0($s4)
      sb $s3 0($s5)
      jal shift
      jal add_buff
      addi $s4 $s4 1
      addi $s5 $s5 1
      addi $s1 $s1 1
      blt $s1 $s6 loopcas
    move $s2 $s6
    jal write

    lw $ra 0($sp)
    addiu $sp $sp 4
    jr $ra

  #rajouter $s3 au debut du tableau
  add_buff:
    subiu $sp $sp 8
    sw $ra 0($sp)
    sw $s1 4($sp)

    la $s1 buffer
    sb $s3 0($s1)

    lw $ra 0($sp)
    lw $s1 4($sp)
    addiu $sp $sp 8
    jr $ra

  shift:
    subiu $sp $sp 12
    sw $ra 0($sp)
    sw $s1 4($sp)
    sw $s2 8($sp)

    la $s1 buffer
    lb $s2 4($s1)
    sb $s2 5($s1)
    lb $s2 3($s1)
    sb $s2 4($s1)
    lb $s2 2($s1)
    sb $s2 3($s1)
    lb $s2 1($s1)
    sb $s2 2($s1)
    lb $s2 0($s1)
    sb $s2 1($s1)
    li $s2 ' '
    sb $s2 0($s1)

    lw $ra 0($sp)
    lw $s1 4($sp)
    lw $s2 8($sp)
    addiu $sp $sp 12
    jr $ra

  # met dans $t5 p $t6 l et $t7 l
  extraction:
    subiu $sp $sp 8
    sw $a1 0($sp)
    sw $ra 4($sp)

    la $a1 buffer_lecture
    add $a1 $a1 $t4
    addi $a1 $a1 1
    lb $t5 0($a1)
    addi $a1 $a1 2
    lb $t6 0($a1)
    addi $a1 $a1 2
    lb $t7 0($a1)

    lb $t7 0($a1)
    lw $a1 0($sp)
    lw $ra 4($sp)
    addiu $sp $sp 8
    jr $ra

  Initialise_buffer:
    subiu $sp $sp 12
    sw $a1 0($sp)
    sw $ra 4($sp)
    sw $a2 8($sp)

    li $a1 0
    li $a2 ' '
    loop_init:
      sb $a2 buffer($a1)
      add $a1 $a1 1
      bne $a1 6 loop_init

    lw $a1 0($sp)
    lw $ra 4($sp)
    lw $a2 8($sp)
    addiu $sp $sp 12
    jr $ra

  Testfin:
    subiu $sp $sp 12
    sw $s0 0($sp)
	  sw $t6 4($sp)
    sw $a2 8($sp)

    la $s0, buffer_lecture
    move $a2 $t4
    add $s0 $s0 $a2

   	lb $t6 0($s0)

    beqz $t6, vide

    li $v0 1
    lw $s0 0($sp)
	  lw $t6 4($sp)
    lw $a2 8($sp)
    addiu $sp $sp 12
    jr $ra

    vide:
   	 li $v0 0
     lw $s0 0($sp)
	   lw $t6 4($sp)
     lw $a2 8($sp)
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

  #ecrit dans le fichier $t3 le contenu de $s1 avec $s2 bits
  write:
    subiu $sp $sp 16
    sw $ra 0($sp)
    sw $a0 4($sp)
    sw $a1 8($sp)
    sw $a2 12($sp)

    li $v0, 15
    move $a0, $t3
    la $a1, buff_txt
    move $a2 $s2
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

  Exit:
    li $v0 10
    syscall
