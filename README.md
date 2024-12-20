# Bernux-kernel-3.0
The New Kernel in assembly for simple Operating systems and interfaces in assembly
french: noyaux bernux 3.0
le tout nouveaux noyaux en assembleur pour des système d'exploitation (et interface) pour des OS simple coder en assembleur

# How to Run Bernux ?

**(1):** download and install msys2 with other apps, run mingw 64 or install it with **pacman -S mingw-w64-x86_64-toolchain**

**(2)** Install qemu with this command **pacman -S mingw-w64-x86_64-qemu**

**(3)** download the .img file in top

# execute the commands

**(4)** run **qemu-system-i386 -drive format=raw,file=kernel.bin** on mingw 64

# in french: 

# Comment exécuter Bernux ?
**(1)**: Téléchargez et installez MSYS2 avec les autres applications, puis lancez mingw 64 ou installez-le avec **pacman -S mingw-w64-x86_64-toolchain.**

**(2)**: Installez QEMU avec cette commande : **pacman -S mingw-w64-x86_64-qemu.**

**(3)**: Téléchargez le fichier .img mentionné plus haut.

# Exécuter les commandes
**(4)**: Exécutez **qemu-system-i386 -drive format=raw,file=bernux-3.0.bin** dans MinGW 64.

