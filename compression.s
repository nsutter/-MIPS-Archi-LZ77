.data
  nom_fichier: .space 40 # nom du fichier d'entree
  cre: .space 40 # nom du fichier de sortie

  buffer: .space 1600 # texte complet
  buffer_tampon: .space 11 # fenetre actuelle
  buffer_id: .space 5 # chaine recherchee actuelle
  buffer_id_max: .space 5 # chaine recherchee maximale
  buffer_write: .space 3 # chaine a ecrire
  buffer_chiffre: .asciiz "0123456789" # buffer pour la gestion des chiffres en ascii

.text
  # N=6 F=5 ("variables globales")
  # autres "variables globales" : $t5 = position dans la fenetre et $t7 = taille de la chaine
  li $t0 6
  li $t1 5

  #### DEBUT Ouverture et lecture du fichier

  # Recuperation du nom de fichier entre par l'utilisateur
  la $a0 nom_fichier
  li $a1 40
  li $v0 8
  syscall

  # Suppression du caractere nul pour avoir un nom de fichier correct
  li $s0 0
  SuppressionNul:
    lb $a3 nom_fichier($s0)
    addi $s0 $s0 1
    bnez $a3 SuppressionNul
    subiu $s0 $s0 2
    sb $0 nom_fichier($s0)

  li $s0 0
  fichierdecomp: # ajoute .lz77 pour trouver le nom du fichier dans lequel ecrire
    lb $a3 nom_fichier($s0)
    sb $a3 cre($s0)
    addi $s0 $s0 1
    bnez $a3 fichierdecomp
    subi $s0 $s0 1
    li $a0 '.'
    sb $a0,cre($s0)
    addi $s0 $s0 1
    li $a0 'l'
    sb $a0,cre($s0)
    addi $s0 $s0 1
    li $a0 'z'
    sb $a0,cre($s0)
    addi $s0 $s0 1
    li $a0 '7'
    sb $a0,cre($s0)
    addi $s0 $s0 1
    sb $a0,cre($s0)

  li $s0 0
  addext: # ajoute .txt pour obtenir le fichier a lire
    lb $a3,nom_fichier($s0)
    addi $s0 $s0 1
    bnez $a3, addext
    subi $s0 $s0 1
    li $a0 '.'
    sb $a0,nom_fichier($s0)
    addi $s0 $s0 1
    li $a0 't'
    sb $a0 nom_fichier($s0)
    addi $s0 $s0 1
    li $a0 'x'
    sb $a0 nom_fichier($s0)
    addi $s0 $s0 1
    li $a0 't'
    sb $a0 nom_fichier($s0)

  # Ouverture du fichier d'entre
  li $v0 13
  la $a0, nom_fichier
  li $a1, 0 # ouverture pour lecture
  li $a2, 0
  syscall

  jal Initialise_buffer # appel de la fonction d'initialisation pour rajouter 6 espaces au debut du texte

  la $a1 buffer # chargement de l'adresse du texte
  addi $a1 $a1 6

  # On stocke le descripteur du fichier dans $t2
  move $t2, $v0

  move $a0, $t2
  li $v0, 14 # chargement du texte
  li $a2, 1600 # taille du buffer en dur
  syscall

  #### FIN

  li $a2 0

  jal create # creation du fichier de sortie

  li $a3 0 # la 1ere fenetre commencera a 0

  #### DEBUT MainLoop

  MainLoop:
    li $s0 0
    jal CreerTampon # creation de la fenetre
    jal TestTamponVide
    beq $v0 0 FinMainLoop
    jal Recherche # recherche de la plus longue chaine
    ble $t7 0 RechercheFail

    lb $a0 buffer_chiffre($t5) # position
    lb $a1 buffer_chiffre($t7) # longueur
    la $s0 buffer # chargement de la bonne lettre suivante
    add $s0 $s0 $a3
    add $s0 $s0 $t0
    add $s0 $s0 $t7
    lb $a2 0($s0)
    jal formate # ecriture dans le fichier de sortie
    add $a3 $a3 $t7
    addi $a3 $a3 1 # index de la fenetre suivante
    j MainLoop

  RechercheFail:
    li $a0 '0' # position = 0 si la recherche echoue
    li $a1 '0' # longueur = 0 si la recherche echoue
    la $s0 buffer # chargement de la bonne lettre suivante
    add $s0 $s0 $a3
    addi $s0 $s0 6
    lb $a2 0($s0)
    jal formate # ecriture dans le fichier de sortie
    addi $a3 $a3 1 # index de la fenetre suivante
    j MainLoop

  FinMainLoop:
    jal close # fermeture des fichiers
    j Exit

  #### FIN

  #### DEBUT CreerTampon ($a3 la position initiale du tampon -> buffer_tampon)

  CreerTampon:
    subiu $sp $sp 24
    sw $ra 0($sp)
    sw $a0 4($sp)
    sw $a1 8($sp)
    sw $s1 12($sp)
    sw $s2 16($sp)
    sw $s3 20($sp)

    move $s1 $a3

    la $s2, buffer # chargement du texte
    add $s2 $s2 $s1 # chargement de l'index du tampon

    li $s3 0

    add $a1 $t0 $t1
    add $a1 $a1 $s1
    RappelTampon: # boucle d'ecriture du tampon
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
    lw $s3 20($sp)
    addiu $sp $sp 24
    jr $ra

  #### FIN

  #### DEBUT TestTamponVide (buffer_tampon -> $v0 (0 si vide, 1 sinon))

  TestTamponVide:
    subiu $sp $sp 8
    sw $s0 0($sp)
    sw $t6 4($sp)

    la $s0, buffer_tampon # chargement de la fenetre
    add $s0 $s0 $t0

    lb $t6 0($s0) # recuperation du 1ere caractere

    beqz $t6, vide # test du caractere de fin de chaine

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

  #### DEBUT Recherche (-> $t5 la position, $t7 la taille)

  Recherche:
  subiu $sp $sp 52
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
  sw $a3 48($sp)

  li $s5 0 # offset du buffer_id

  li $t5 0 # position p
  li $t6 0 # longueur en cours
  li $t7 0 # longueur max

  la $s0 buffer_tampon # index mobile de la fenetre de recherche
  add $s1 $s0 $t0 # index mobile de la fenetre de lecture

  move $s2 $s0 # index statique du debut de la fenetre de recherche
  move $s3 $s1 # index statique du debut de la fenetre de lecture

  add $s4 $s1 $t1 # index de la fin de la fenetre

  Loop:

  li $t6 0
  lb $a1 0($s1) # caractere du tampon de lecture

  li $s5 0

    Loop1:
      beq $s0 $s3 FinLoop # fin de boucle si les mauvais index se rencontrent
      beq $s1 $s4 FinLoop
      lb $a0 0($s0) # caractere du tampon de recherche
      beq $a0 $a1 PreLoop2
      addi $t5 $t5 1
      addi $s0 $s0 1
      j Loop1

    PreLoop2:
    move $s7 $s0 # taille

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

      sb $zero buffer_id($s6) # reset de buffer_id

      j Loop

      PostLoop:
        move $t7 $t6 # copie de la taille actuelle vers la taille max

        li $s6 0
        Copie: # copie de buffer_id vers buffer_id_max
          lb $a3 buffer_id($s6)
          sb $a3 buffer_id_max($s6)
          addi $s6 $s6 1
          bne $s6 6 Copie

        li $s6 0

        sb $zero buffer_id($s6) # reset de buffer_id

        j Loop

  FinLoop:
    sub $t5 $s7 $s2 # recuperation de la position par soustraction d'adresse
    sub $t5 $t0 $t5 # inversion de la position pour decompression.s

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
    lw $a3 48($sp)
    addiu $sp $sp 52
    jr $ra

  #### FIN

  # Creation d'un fichier avec le nom cre
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

  # Preecriture : $a0$a1$a2 dans buffer_write
  formate:
    subiu $sp $sp 8
    sw $ra 0($sp)
    sw $s1 4($sp)

    la $s1 buffer_write

    sb $a0 0($s1)
    sb $a1 1($s1)
    sb $a2 2($s1)

    jal write

    lw $ra 0($sp)
    lw $s1 4($sp)
    addiu $sp $sp 8
    jr $ra

  # Ecriture de buffer_write dans le fichier de sortie
  write:
    subiu $sp $sp 20
    sw $ra 0($sp)
    sw $a0 4($sp)
    sw $a1 8($sp)
    sw $a2 12($sp)
    sw $s0 16($sp)


    li $v0, 15
    move $a0, $t3
    la $a1, buffer_write
    li $a2, 3
    syscall

    lw $ra 0($sp)
    lw $a0 4($sp)
    lw $a1 8($sp)
    lw $a2 12($sp)
    lw $s0 16($sp)
    addiu $sp $sp 20
    jr $ra

  # Fermeture des fichiers dans $t2 et $t3
  close:
    subiu $sp $sp 8
    sw $ra 0($sp)
    sw $a0 4($sp)

    li   $v0, 16
    move $a0, $t2
    syscall
    li   $v0, 16
    move $a0, $t3
    syscall

    lw $ra 0($sp)
    lw $a0 4($sp)
    addiu $sp $sp 8
    jr $ra

  # Ecriture de 6 espaces dans le texte
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

  Exit:
    li $v0 10
    syscall
