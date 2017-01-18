# ArchiLZ77
# SUTTER Nicolas et POIZAT Théo - CMI ISR L2S3

Projet Architecture des Ordinateurs: compression/décompression de fichiers avec l'algorithme LZ77 en MIPS

## UTILISATION ET EXPLICATIONS COMPLEMENTAIRES

compression.s :
Le fichier à compresser doit se trouver dans le même dossier que Mars. Notre algorithme
ajoute lui-même l'extension .txt, il suffit donc par exemple d'écrire Lepetitprince pour compresser
le fichier Lepetitprince.txt.

decompression.s :
Le fichier à décompresser doit se trouver dans le même dossier que Mars. Notre algorithme
ajoute lui-même l'extension .lz77, il suffit donc par exemple d'écrire Lepetitprince pour compresser
le fichier Lepetitprince.lz77. De plus, le fichier de sortie s'appellera Lepetitprince2.txt pour ne pas
écraser le fichier original.

Toutes nos fonctions utilisent la pile pour éviter les effets de bords sur les registres utilisés à l'intérieur des fonctions.

## QUESTIONS

1) Non car le taux de compression dépend du nombre de caractères utilisés dans le document et de la répétition de caractères.
   On constate qu'avec un tampon de 6 caractères et 5 pour le tampon de lecture la compression des fichiers sont negatifs sauf pour le fichier zero.
   Le fichier Pirouette.lz77 a 102% d'augmentation de la taille, 127% pour Lepetitprince, 126% pour Voltaire mais une reduction de 43% pour zero.

2) La compression peut être négative dans le cas où, par exemple, on n'utilise que une fois chaque caractère puisqu'un l'algorithme écrit quoi qu'il arrive un triplet. La variante LZSS résout ce problème.

3)
Plus N et F sont grands, plus la fenêtre est grande donc plus les correspondances sont grandes (+ efficace) mais plus il faut de bits pour coder la position et la longueur (- efficace). De plus la recherche de facteurs sera plus longue (+ long) -> la complexité de l'algorithme augmente.

4)
Points forts:
- algorithme universel en une passe (l'algorithme de Huffman nécessite par exemple de connaître une estimation des probabilités d'apparition des caractères)
- la compression peut être très efficace dans le cas où l'alphabet est réduit (binaire par exemple) ou lorsqu'il y une répétition des données (exemple du fichier 42.zip qui contient un fichier de 4,3 gigaoctets sur 42 kilooctets https://fr.wikipedia.org/wiki/Bombe_de_d%C3%A9compression)
- l'algorithme est de plus simple à comprendre et à implémenter (en tout cas dans un langage de haut niveau)

Points faibles:
- possibilité de compression négative (l'algorithme peut renvoyer un triplet pour remplacer un seul caractère par exemple)
