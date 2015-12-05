.data
filename: .asciiz "./pirouette.txt" #file name
textSpace: .space 1050     #space to store strings to be read

.text
#N=11 F=5
li $t0 11
li $t1 5

#Ouverture du fichier
li $v0 13
la $a0, filename # output file name
li $a1, 0        # Open for writing (flags are 0: read, 1: write)
li $a2, 0        # mode is ignored
syscall        

move $a0, $v0        # load file descriptor
li $v0, 14           #read from file
la $a1, textSpace        # allocate space for the bytes loaded
li $a2, 1050         # number of bytes to be read
syscall  
la $a0, textSpace        # address of string to be printed
li $v0, 4            # print string
syscall

exit:
li $v0 10
syscall