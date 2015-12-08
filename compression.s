.data
  nom_fichier: .asciiz "./Lepetitprince.txt" # nom du fichier
  cre: .asciiz "./test.lz77" # nom du fichier de sortie
  parenthese_o: .byte '('
  parenthese_f: .byte ')'
  virgule: .byte ','

  saut_ligne: .asciiz "\n"
  toast: .asciiz "\n-\n"
  aaa: .asciiz "aaa"

  buffer: .space 1600
  buffer_tampon: .space 11
  buffer_id: .space 5
  buffer_id_max: .space 5
  #buffer_cre: .space 1600
  buffer_write: .space 7

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
  li $a2, 1600 # taille du buffer en dur
  syscall

  #### FIN

  jal create

  li $a3 0 # CreerTampon commence a 0

  MainLoop:
  jal CreerTampon
  jal TestTamponVide
  beq $v0 0 Exit
  jal Recherche
  beq $t7 0 RechercheFail
  move $a0 $t5
  move $a1 $t7
  la $s0 buffer
  add $s0 $s0 $a3
  addi $s0 $s0 11
  lb $a2 0($s0)
  jal formate
  j MainLoop

  RechercheFail:
  li $a0 '0'
  li $a1 '0'
  la $s0 buffer
  add $s0 $s0 $a3
  addi $s0 $s0 6
  lb $a2 0($s0)
  jal formate
  addi $a3 $a3 1
  j MainLoop

  #### DEBUT CreerTampon ($a2 la position initiale du tampon -> buffer_tampon)

  CreerTampon:
    subiu $sp $sp 20
    sw $ra 0($sp)
    sw $a0 4($sp)
    sw $a1 8($sp)
    sw $s1 12($sp)
    sw $s2 16($sp)

    move $s1 $a3

    la $s2, buffer
    add $s2 $s2 $s1

    li $s3 0

    add $a1 $t0 $t1
    add $a1 $a1 $s1
    RappelTampon:
      lb $a0, 0($s2)
      sb $a0, buffer_tampon($s3)
      addi $s1 $s1 1
      addi $s2 $s2 1
      addi $s3 $s3 1
      bne $s1 $a1 RappelTampon

    lw $ra 0($sp)
    lw $a0 4($sp)
    lw $a1 8($sp)
    lw $s1 12($sp)
    lw $s2 16($sp)
    addiu $sp $sp 20
    jr $ra

  #### FIN

  #### DEBUT TestTamponVide (buffer_tampon -> $v0 (0 si vide, 1 sinon))

  TestTamponVide:
    subiu $sp $sp 8
    sw $s0 0($sp)
    sw $t6 4($sp)

    la $s0, buffer_tampon
    add $s0 $s0 $t0

    lb $t6 0($s0)

    beqz $t6, vide

    li $v0 1
    lw $s0 0($sp)
	  lw $t6 4($sp)
    addiu $sp $sp 8
    jr $ra

    vide:
   	 li $v0 0
     lw $s0 0($sp)
	   lw $t6 4($sp)
   	 addiu $sp $sp 8
     jr $ra

  #### FIN

  #### DEBUT Recherche (-> t5 la position, t7 la taille)

  Recherche:
  subiu $sp $sp 48
  sw $ra 0($sp)
  sw $a0 4($sp)
  sw $a1 8($sp)
  sw $s0 12($sp)
  sw $s1 16($sp)
  sw $s2 20($sp)
  sw $s3 24($sp)
  sw $s4 28($sp)
  sw $s5 32($sp)
  sw $s6 36($sp)
  sw $s7 40($sp)
  sw $t6 44($sp)

  li $s5 0 # offset du buffer_id

  #la $s6 buffer_id
  #la $s7 buffer_id_max

  li $t5 0 # position p
  li $t6 0 # longueur en cours
  li $t7 0 # longueur max

  la $s0 buffer_tampon
  add $s1 $s0 $t0

  move $s2 $s0
  move $s3 $s1

  add $s4 $s1 $t1

  Loop:

  li $t6 0
  lb $a1 0($s1)

  li $s5 0

    Loop1:
      beq $s0 $s3 FinLoop
      beq $s1 $s4 FinLoop
      lb $a0 0($s0)
      beq $a0 $a1 PreLoop2
      addi $t5 $t5 1
      addi $s0 $s0 1
      j Loop1

    PreLoop2:
    move $s7 $s0

    Loop2:
      sb $a0, buffer_id($s5) # on stocke dans le buffer_id
      addi $t6 $t6 1 # on incremente tous les offsets
      addi $s0 $s0 1
      addi $s1 $s1 1
      addi $s5 $s5 1
      beq $s0 $s3 LabelCopie
      beq $s1 $s4 LabelCopie
      lb $a0 0($s0)
      lb $a1 0($s1)
      beq $a0 $a1 Loop2
      move $s1 $s3

      LabelCopie:
      bge $t6 $t7 PostLoop

      li $s6 0

      # Reset de buffer_id
      sb $zero buffer_id($s6)

      j Loop

      PostLoop:
        move $t7 $t6

        li $s6 0
        Copie:
          lb $a3 buffer_id($s6)
          sb $a3 buffer_id_max($s6)
          addi $s6 $s6 1
          bne $s6 6 Copie

        li $s6 0

        # Reset de buffer_id
        sb $zero buffer_id($s6)

        j Loop

  FinLoop:
    sub $t5 $s7 $s2

    lw $ra 0($sp)
    lw $a0 4($sp)
    lw $a1 8($sp)
    lw $s0 12($sp)
    lw $s1 16($sp)
    lw $s2 20($sp)
    lw $s3 24($sp)
    lw $s4 28($sp)
    lw $s5 32($sp)
    lw $s6 36($sp)
    lw $s7 40($sp)
    lw $t6 44($sp)
    addiu $sp $sp 48
    jr $ra

  #### FIN

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

  formate:
    subiu $sp $sp 16
    sw $ra 0($sp)
    sw $t6 4($sp)
    sw $t5 8($sp)
    sw $t4 12($sp)

    la $s1 buffer_write
    lb $t6 parenthese_o
    lb $t5 parenthese_f
    lb $t4 virgule

    sb $t6 0($s1)
    sb $a0 1($s1)
    sb $t4 2($s1)
    sb $a1 3($s1)
    sb $t4 4($s1)
    sb $a2 5($s1)
    sb $t5 6($s1)
    jal write

    lw $t4 12($sp)
    lw $t5 8($sp)
    lw $t6 4($sp)
    lw $ra 0($sp)
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
    la $a1, buffer_write
    li $a2, 7
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
