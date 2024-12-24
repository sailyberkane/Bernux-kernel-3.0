BITS 16

org 0x7C00 ; Adresse de chargement du bootloader

start:
    ; Effacer l’écran
    mov ah, 0x06
    mov al, 0
    mov bh, 0x02 ; Attribut (vert sur noir)
    mov cx, 0
    mov dx, 0x184F ; Bas de l’écran
    int 0x10

    ; Afficher la bordure supérieure de la fenêtre
    lea si, runing1
    call print_string

	
	lea si, runing2
    call print_string
	
	lea si, runing3
    call print_string
	
	lea si, runing4
    call print_string
	
	lea si, welcome
    call print_string

    ; Afficher le message d'accueil dans la fenêtre
    lea si, message
    call print_string
    lea si, newline
    call print_string

    ; Boucle pour gérer l’input
input_loop:
    ; Afficher l’invite de commande
    lea si, prompt
    call print_string

    ; Lire une ligne de texte depuis le clavier
    call get_input

    ; Vérifier si l'utilisateur a entré "reboot"
    lea si, input_buffer
    call check_reboot

    ; Vérifier si l'utilisateur a entré "date"
    lea si, input_buffer
    call check_date

    ; Ne pas afficher à nouveau le texte, mais générer uniquement les valeurs hexadécimales
    call print_hex_values

    ; Retourner à la boucle pour une nouvelle commande
    jmp input_loop

; Fonction pour vérifier si la commande "reboot" a été entrée
check_reboot:
    lea di, reboot_command
    lea si, input_buffer
    mov cx, 5 ; Longueur de "reboot"
.check_reboot_loop:
    lodsb
    cmp al, [di]  ; Comparer avec le caractère correspondant
    jne .not_reboot
    inc di
    loop .check_reboot_loop
    ; Si "reboot" est entré, redémarrer
    jmp reboot

.not_reboot:
    ret

; Fonction pour vérifier si la commande "date" a été entrée
check_date:
    lea di, date_command
    lea si, input_buffer
    mov cx, 4 ; Longueur de "date"
.check_date_loop:
    lodsb
    cmp al, [di]  ; Comparer avec le caractère correspondant
    jne .not_date
    inc di
    loop .check_date_loop
    ; Si "date" est entré, afficher la date
    jmp show_date

.not_date:
    ret

; Fonction pour afficher la date
show_date:
    ; Appeler l'interruption BIOS pour obtenir la date
    mov ah, 0x2C     ; Fonction 0x2C de l'interruption 0x21 pour obtenir la date
    int 0x21

    ; Afficher la date
    lea si, date_string
    call print_string

    ; Afficher la date sous forme de chaîne
    mov al, dl        ; Jour (dl)
    call print_digit
    mov al, dh        ; Mois (dh)
    call print_digit
    mov al, ch        ; Année (ch)
    call print_digit

    lea si, newline
    call print_string
    ret

; Fonction pour afficher un chiffre (utilisé pour la date)
print_digit:
    add al, '0'
    mov ah, 0x0E
    mov bl, 0x02 ; Attribut vert sur noir
    int 0x10
    ret

; Fonction pour redémarrer le système
reboot:
    ; Simuler un redémarrage en réinitialisant l'exécution du bootloader
    jmp start

; Fenêtre : cadre autour du terminal
runing1 db "[      booting.. (0x0000)", 0x0D, 0x0A, 0
runing2 db "[      Running kernel (0x1000)", 0x0D, 0x0A, 0
runing3 db "[      load interface (0x10)", 0x0D, 0x0A, 0
runing4 db "", 0x0D, 0x0A, 0

welcome db "Bernux kernel 4.0"
newline db 0x0D, 0x0A, 0
prompt db "root@bernux#/$ ", 0
message db "", 0
input_buffer times 64 db 0
reboot_command db "reboot", 0
date_command db "date", 0 ; Commande pour afficher la date
date_string db "", 0

; Fonction pour afficher une chaîne terminée par \0
print_string:
    mov ah, 0x0E ; Service BIOS pour afficher un caractère
.next_char:
    lodsb        ; Charger le prochain caractère dans AL
    cmp al, 0    ; Fin de chaîne ?
    je .done     ; Oui, terminer
    mov ah, 0x0E ; Service BIOS
    mov bl, 0x02 ; Attribut vert sur noir
    int 0x10     ; Afficher le caractère
    jmp .next_char
.done:
    ret

; Fonction pour lire une ligne depuis le clavier
get_input:
    mov di, input_buffer ; Adresse du tampon d’entrée
.next_char:
    xor ah, ah           ; Lire un caractère
    int 0x16
    cmp al, 0x0D         ; Touche Entrée ?
    je .done

    ; Afficher le caractère et l’ajouter au tampon
    mov ah, 0x0E
    mov bl, 0x02 ; Attribut vert sur noir
    int 0x10
    stosb
    jmp .next_char

.done:
    mov byte [di], 0 ; Ajouter un \0 à la fin
    lea si, newline
    call print_string
    ret

; Fonction pour afficher les valeurs hexadécimales de chaque caractère
print_hex_values:
    lea si, input_buffer ; Charger l’adresse de l’entrée
.next_char:
    lodsb                ; Charger le prochain caractère
    cmp al, 0            ; Fin de chaîne ?
    je .done

    ; Afficher la valeur hexadécimale (4 bits supérieurs)
    push ax
    shr al, 4
    call print_hex_digit

    ; Afficher la valeur hexadécimale (4 bits inférieurs)
    pop ax
    and al, 0x0F
    call print_hex_digit

    ; Espacement entre les valeurs
    mov al, ' '
    mov ah, 0x0E
    mov bl, 0x02 ; Attribut vert sur noir
    int 0x10

    jmp .next_char
.done:
    lea si, newline
    call print_string
    ret

; Fonction pour afficher un chiffre hexadécimal (0-15)
print_hex_digit:
    add al, '0'
    cmp al, '9'
    jbe .output
    add al, 7 ; Convertir en lettre (A-F)
.output:
    mov ah, 0x0E
    mov bl, 0x02 ; Attribut vert sur noir
    int 0x10
    ret

; Remplir le reste du secteur avec des zéros
times 510-($-$$) db 0

dw 0xAA55 ; Signature de boot
