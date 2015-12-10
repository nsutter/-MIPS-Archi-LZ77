.data
  cre: .space 40

  nom_fichier: .space 40

  buffer_lecture: .space 1600

  buffer: .space 6

  buff_txt: .space 6

.text
  # N=6 F=5
  li $t0 6
  li $t1 5
  #### DEBUT Ouverture et lecture du fichier

  la $a0 nom_fichier
  li $a1 30
  li $v0 8
  syscall

  #suppression du /0
  li $s0 0 # compteur initialise
  Remove:
    lb $a3 nom_fichier($s0)
    addi $s0 $s0 1
    bnez $a3 Remove                  # Tant qu'on est pas a la fin de la chaine
    subiu $s0 $s0 2                  # on supprime le caractère de fin de chaine
    sb $0 nom_fichier($s0)

  li $s0 0
  fichierdecomp:                     # ajoute .txt pour trouver le nom du fichier dans lequel ecrire
    lb $a3 nom_fichier($s0)
    sb $a3 cre($s0)
    addi $s0 $s0 1
    bnez $a3 fichierdecomp
    subi $s0 $s0 1
    li $a0 '2'
    sb $a0,cre($s0)
    addi $s0 $s0 1
    li $a0 '.'
    sb $a0 cre($s0)
    addi $s0 $s0 1
    li $a0 't'
    sb $a0 cre($s0)
    addi $s0 $s0 1
    li $a0 'x'
    sb $a0 cre($s0)
    addi $s0 $s0 1
    li $a0 't'
    sb $a0 cre($s0)

  li $s0 0
  addext:                           # ajoute .lz77 pour obtenir le fichier a lire
    lb $a3,nom_fichier($s0)
    addi $s0 $s0 1
    bnez $a3, addext
    subi $s0 $s0 1
    li $a0 '.'
    sb $a0,nom_fichier($s0)
    addi $s0 $s0 1
    li $a0 'l'
    sb $a0,nom_fichier($s0)
    addi $s0 $s0 1
    li $a0 'z'
    sb $a0,nom_fichier($s0)
    addi $s0 $s0 1
    li $a0 '7'
    sb $a0,nom_fichier($s0)
    addi $s0 $s0 1
    sb $a0,nom_fichier($s0)

  li $v0 13
  la $a0, nom_fichier
  li $a1, 0                         # ouverture pour écriture
  li $a2, 0
  syscall
  move $t2, $v0                     # $t2 fichier de lecture

  #stockage dans buffer_lecture du contenu du fichier a decompresser
  move $a0, $t2
  li $v0, 14
  la $a1, buffer_lecture
  li $a2, 1600                      # taille du buffer en dur
  syscall

  #creation du fichier .txt
  jal create                        # creation du fichier $t3 d'ecriture

  #test si il y a encore quelque chose a decompresser
  jal Testfin                       #Testfin test si le fichier est fini et renvoi dans $v0
  beq $v0 0 Exit                    # si le fichier est vide on fini le programme
  jal Initialise_buffer             # on remplis le tampon avec que des espaces
  li $4 0                           # on initialise un compteur correspondant au nb de couple traiter * 7 (un couple: 7 caracteres)
  loop:                             # boucle de traitement du fichier
    jal extraction                  # exrtaction du couple dans le fichier $t5=p $t6=l $t7=caracteres
    move $s1 $t5                    # deplacement de la position dans $s1
    andi $s1,$s1,0x0F               # convertit le caracteres en chiffre
    beqz $s1 cas_zero               # si le couple est 0,0 cas_zero
    jal cas_autre                   # sinon deuxieme cas
    addi $t4 $t4 3                  # on incremante le compteur (de 3 car un couple= 3 bytes)
    jal Testfin                     # on test si on a atteinds la fin du fichier a decompresser
    bne $v0 0 loop                  # si non on reboucle

  jal close                         # fermeture des fichier $t3 et $t2
  j Exit

  cas_zero:
    li $s2 1                        # nombre de bits a afficher=1 car cas ou 0,0
    la $s1 buff_txt
    sb $t7 0($s1)                   # on charge le caracteres dans le buffer d'ecriture
    jal write                       # on appel la fonction d'ecritre qui prends en param $s1 (nb de bits a ecrire)
    jal shift                       # on decale le buffer (shift)
    move $s3 $t7
    jal add_buff                    # on ajoute au debut du buffer le caractere param: $s3=caractere a ajouter
    addi $t4 $t4 3                  # on incremente le compteur
    jal Testfin                     # test de la fin du fichier
    bne $v0 0 loop                  # si pas fin retour en haut de la boucle
    jal close                       # fermeture des fichier $t3 et $t2
    j Exit

  # dans le cas ou l'on fait une reference au tampon
  cas_autre:
    subiu $sp $sp 4
    sw $ra 0($sp)

    li $s1 0                        # compteur qu'on initialise
    andi $s6,$t6,0x0F               # conversion de l en binaire
    andi $t5,$t5,0x0F               # conversion de p en binaire
    subi $t5 $t5 1                  # on eneleve un a la position car le tableau commence a 0
    la $s4 buffer
    add $s4 $s4 $t5                 # on place $s4 a la bonne position du buffer
    la $s5 buff_txt                 # on charge l'adresse du buffer d'ecriture
    loopcas:                        # boucle de chargement des elts du tampon
      lb $s3 0($s4)
      sb $s3 0($s5)                 # on sotcke dans le tampon de lecture la caractere a ecrire
      jal shift                     # decalage du tableau
      jal add_buff                  # ajout du caractere au debut du buffer
      addi $s5 $s5 1
      addi $s1 $s1 1
      blt $s1 $s6 loopcas           # tant que le compteur inferieur a l
    move $s2 $s1                    # $s2=  nb de bits a ecrire
    jal write                       # ecriture des valeurs dans le buffer ecriture
    la $s5 buff_txt
    li $s2 1                         # $s2= nb de bits a ecrire ici 1
    sb $t7 0($s5)                    # chargement de $t7 dans le buffer ecriture
    jal write                        # ecriture du caractère en 3 eme position dans le couple
    jal shift
    move $s3 $t7                     # $s3= valeur a ajouter dans le buffer
    jal add_buff                     # ajout au buffer

    lw $ra 0($sp)
    addiu $sp $sp 4
    jr $ra

  #rajouter $s3 au debut du tableau
  add_buff:
    subiu $sp $sp 12
    sw $ra 0($sp)
    sw $s1 4($sp)
    sw $s3 8($sp)

    la $s1 buffer
    sb $s3 0($s1)                    # ajoute dans le buffer la variable $s3

    lw $ra 0($sp)
    lw $s1 4($sp)
    lw $s3 8($sp)
    addiu $sp $sp 12
    jr $ra

  # decalle tout le buffer
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
  # prends $t4 en entre qui correpont a la position de p dans le texte
  extraction:
    subiu $sp $sp 8
    sw $a1 0($sp)
    sw $ra 4($sp)

    la $a1 buffer_lecture
    add $a1 $a1 $t4
    lb $t5 0($a1)
    addi $a1 $a1 1
    lb $t6 0($a1)
    addi $a1 $a1 1
    lb $t7 0($a1)

    lb $t7 0($a1)
    lw $a1 0($sp)
    lw $ra 4($sp)
    addiu $sp $sp 8
    jr $ra

  # ecrit que des espaces dans le buffer
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

  # test la fin d'un fichier et renvoi dans v0
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
