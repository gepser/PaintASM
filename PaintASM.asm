;ESTE CODIGO DE CABECERA LO GENERA AUTOMATICAMENTE EMU8086
;CUANDO GENERAMOS UN .EXE
;Aqui empieza el segmento de datos
;es donde declaramos nuestras variables

data segment
misdatos dw '          ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»',13,10,
          dw '         º                   PRACTICA NUMERO 1                    º',13,10,
          dw '         ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»',13,10,
          dw '         º         Universidad de San Carlos de Guatemala         º',13,10,
          dw '         º                 Facultad de Ingenieria                 º',13,10,
          dw '         º             Escuela de Ciencias y Sistemas             º',13,10,
          dw '         º Curso: Arquitectura de Computadores y Ensambladores 1  º',13,10,
          dw '         º                       Seccion: A                       º',13,10,
          dw '         º          Nombre: Gepser Hoil                            º',13,10,      
                    dw '         ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼',13,10,
          dw '$'
                                                                      
;Este sera el color del pincel
;-----------------------------
;Negro         = 0
;Azul          = 1                 
;Verde         = 2
;Celeste       = 3
;Rojo          = 4
;Magenta       = 5
;Cafe          = 6
;Gris Claro    = 7
;Gris Oscuro   = 8
;Azul Claro    = 9
;Verde Claro   = 10
;Celeste Claro = 11
;Rojo Claro    = 12
;Magenta Claro = 13
;Amarillo      = 14
;Blanco        = 15

;Me van a servir para manejar la posicion de la barra
aux      dw  0 
posbarrax dw 3
posbarray dw 199
cont     dw 0
init     dw 0

grax     db  "",13,10,
         db  "  Gracias por utilizar GepserPaint",13,10,
         db  "  Presione una tecla para salir...$"
ends
;Termina segmento de datos

;Empieza segmento del Stack
stack segment
         dw   128  dup(0)
ends
;Termina el segmento del Stack

;Elpieza el segmento de codigo
code segment

;La etiqueta general, se finaliza hasta que termina el programa
start:

;DE AQUI PARA ARRIBA ES EL CODIGO DE CABECERA GENERADO POR EMU8086
;AL GENERAR UN .EXE (A EXCEPCION DE LAS VARIABLES),
;LO DE ABAJO ES LO QUE CONTIENE TODO EL PROGRAMA EN SI

;color inicial, azul (init le suma 1)
mov si,0

; Le pasamos a AX 'misdatos' como segmento 
mov ax,seg misdatos
; Le pasamos a DS (Registro de Segmento de Datos) 
; un segmento con 'misdatos' para que sepa que y cuanto va a imprimir
mov ds,ax          
                   
;Configurando la Pantalla Verde-Aqua Inicial
mov al, 0 ;Resolucion 40x25, 16 colores, Tipo Texto  

;este es el color Azul de la pantalla y el de las letras
;El primer numero es la pantalla y el segundo las letras
mov bh, 34h

;Posiciones  
mov ch, 1    ;posicion donde empieza el cuadro azul (x = 1)
mov cl, 1    ;posicion donde empieza el cuadro azul (y = 1)
mov dh, 17h  ;posicion donde termina el cuadro azul (x = 23)
mov dl, 4eh  ;posicion donde termina el cuadro azul (y = 78)
int 10h      ;Llamamos para aplicar los cambios de la pantalla

mov ah, 2    ;Posicionar el cursor
mov bh, 00   ;Numero de pagina 
             ;(nos sirve para poder escribir en el centro)
mov dh, 08h  ;Numero de Fila donde vamos a escribir texto
mov dl, 01h  ;Numero de Columna donde vamos a posicionar el texto
int 10h      ;Aplicamos cambios llamando a la interrupcion 10h

mov dx,offset misdatos ;Mandamos 'mis datos al Registro de Datos'
mov ah,09h   ;Para escribir texto en la salida estandar
             ;escribe hasta que encuentra el simbolo $
int 21h      ;Interrupcion que sirve para escribir texto (con AH=9)

leer:
mov ah,0     ;Preparamos para leer un caracter en pantalla
int 16h      ;Leemos caracter
cmp al,1bh   ;ESC = 1b, osea si presionamos ESC...
je fin       ;nos vamos al final del programa (salimos)
jmp grafico  ;sino nos vamos al modo grafico para pintar

grafico:
mov al,13h   ;Tamano pantalla 320x200, 256 colores
mov ah,00h   ;Para establecer modo de video
int 10h      ;Interrupcion que activa modo de video 
mov ax,0000h ;valor para nicializar el mouse
int 33h      ;Interrupcion del Mouse
mov ax,0001h ;Mostrar el puntero
int 33h      ;Interrupcion del Mouse


cmp init,0
je rotar
;Aqui empieza un bucle infinito que siempre estara escuchando
;al mouse y al teclado, solo saldra cuando presionen ESC            
Mouse:
mov ax,0003h ;Asigno el valor a AX para validar clic 
int 33h      ;Interrupcion para leer el mouse
 
;Estamos dividiendo CX por corrimiento a la derecha
;Ejemplo: si CX = 110 (6) entonces luego del corrimiento quedaria asi
;CX = 11 (3), al haberlo corrido 1 bit a la derecha implicitamente
shr cx,1     ;lo estamos dividiendo entre dos    

;Con la interrupcion 16h y AH=01h estaremos escuchando siempre
;el teclado sin que nos intervenga en la escucha del mouse
leertecla:
mov ah,01h
int 16h
;Saltamos si no hay teclas presionadas a 'notecla'
jz notecla

;En caso de haber una tecla vuelvo a llamar a 16h con AH = 0 y comparo 
mov ah,0h
int 16h
cmp al,2bh   ;en caso de signo +
je rotar     ;cambio de color (color += 1) 

cmp al,2dh   ;en caso de signo -
je rotar2    ;cambio de color (color += 2)

cmp al,0dh   ;en caso de Enter
je reiniciar ;Reiniciamos

cmp al,9h    ;en caso de Tab
je start     ;Volvemos a los datos

cmp al,1bh   ;ESC = 1b, osea si presionamos ESC...
je fin       ;en caso de que se haya presionado ESC
             ;nos vamos al final del programa (salimos), sino...


;Seguimos como si nada se hubiera presionado 
notecla:
cmp bx,01h   ;comparo el valor de bx para validar si hizo clic
jz imprimir  ;Si hizo click izq. me voy a 'imprimir'

cmp bx,03h   ;comparo si se hizo click con los dos botones a la vez
jz borrar    ;Si se hizo click con ambos botones me voy a borrar

cmp bx,02h   ;comparo si se hizo click derecho
jz rotar     ;Si se hizo click derecho cambio de color

jmp Mouse    ;Si aun no se ha dado click ni presionado ESC volvemos a
             ;empezar de nuevo el ciclo desde 'Mouse'

;Aqui empieza la parte que imprime los pixeles para pintar    
imprimir:
cmp cx,0     ;Comparo si CX llego al limite de la pantalla
je putcx     ;Si da verdadero me voy a 'putcx'
jmp continue ;Si es falso continuo en 'continue'
cmp dx,5     ;Comparo DX con 5, poco antes del limite de la pantalla
je putdx     ;Si da verdadero me voy a 'putdx'
jmp continue ;Si es falso continuo en 'continue'

putcx:       ;Si llegue al limite en CX (eje X)
mov cx,5     ;Reseteo a 5 a CX
jmp continue ;Luego continuo

putdx:       ;Si llegue al limite en DX (eje Y)
mov dx,10    ;Reseteo a 10 DX
jmp continue ;Luego continuo

continue:    ;Etiqueta 'continue', cuando todo esta normal
;mov al,rojo  ;Le paso el color a AL 
mov ax,si
mov ah,0ch   ;Le mado la orden de imprimir caracter a AH 
int 10h      ;Aplico cambios con INT 10H, imprimo

;Como los pixeles son demasiado pequenhos, la brocha sale muy
;dispera, por eso procedemos a imprimir varios pixeles
;rodenado al pixel central 
;recordemos que el punto (0,0) no esta en el centro de la pantalla
dec cx       ;decremento la posicion en el eje X
int 10h      ;Imprimo

inc dx       ;incremento la posicion en el eje Y
int 10h      ;Imprimo

inc cx       ;incremento la posicion en el eje X
int 10h      ;Imprimo

inc dx       ;incremento la posicion en el eje Y
int 10h      ;Imprimo

dec cx       ;decremento la posicion en el eje X
int 10h      ;Imprimo

jmp Mouse    ;Regreso al bucle infinito que escucha al mouse
             ;(y al teclado)

;Esto sirve para pintar de color negro
;funciona como borrador y se activa con click derecho
borrar:
cmp cx,0      ;Comparo si CX llego al limite de la pantalla
je putcxb     ;Si da verdadero me voy a 'putcx'
jmp continue2 ;Si es falso continuo en 'continue'
cmp dx,5      ;Comparo DX con 5, poco antes del limite de la pantalla
je putdxb     ;Si da verdadero me voy a 'putdx'
jmp continue2 ;Si es falso continuo en 'continue'

putcxb:       ;Si llegue al limite en CX (eje X)
mov cx,5      ;Reseteo a 5 a CX
jmp continue2 ;Luego continuo

putdxb:       ;Si llegue al limite en DX (eje Y)
mov dx,10     ;Reseteo a 10 DX
jmp continue2 ;Luego continuo


;Aqui se empieza a borrar de verdad
continue2:
mov al,0     ;Le paso el color a AL
mov ah,0ch   ;Le mado la orden de imprimir caracter a AH  
int 10h      ;Aplico cambios con INT 10H, imprimo

;Como los pixeles son demasiado pequenhos, el borrador sale muy
;dispero, por eso procedemos a imprimir varios pixeles
;rodenado al pixel central 
;recordemos que el punto (0,0) no esta en el centro de la pantalla
dec cx       ;decremento la posicion en el eje X
int 10h      ;Imprimo
inc dx       ;incremento la posicion en el eje Y
int 10h      ;Imprimo
inc cx       ;incremento la posicion en el eje X
int 10h      ;Imprimo
inc dx       ;incremento la posicion en el eje Y
int 10h      ;Imprimo
dec cx       ;decremento la posicion en el eje X
int 10h      ;Imprimo
jmp Mouse    ;Regreso al bucle infinito que escucha al mouse
             ;(y al teclado) 
             
rotar2:
cmp si,0     ;Si el color actual es negro
jz reset2    ;me voy a reset 2
dec si       ;sino color = color - 1
jmp continue3;nos vamos a imprimir la palabra COLOR y su cuadrito

reset2:      ;vuelvo a empezar la vuelta de los colores
mov si,15    ;si llego a negro le asigno blanco
jmp continue3;nos vamos a imprimir la palabra COLOR y su cuadrito             
                         
rotar:
mov init,1       
cmp si,15    ;Si el color actual es blanco
jz reset     ;me voy a reset
inc si       ;sino color = color + 1
jmp continue3;nos vamos a imprimir la palabra COLOR y su cuadrito

reset:
mov si,0     ;si llego a blanco le vuelvo a asignar negro

continue3:   ;Empezamos con los paso para imprimir COLOR y su cuadrito
push cx      ;guardamos en la pila
push dx      ;guardamos en la pila

mov cx,306   ;306 es lo maximo para que se mire en la pantalla
mov dx,12    ;12 es lo minimo para que se mire en la pantalla

mov ax,si    ;Le paso el color actual a AX
mov ah,0ch   ;Le mado la orden de imprimir caracter a AH 
int 10h      ;Aplico cambios con INT 10H, imprimo

push ax      ;guardamos el color en turno
;Aqui estamos pintando el cuadrito del color seleccionado
dec cx
int 10h
dec cx
int 10h 
inc dx    
int 10h  
inc cx
int 10h
inc cx
int 10h
inc dx    
int 10h
dec cx
int 10h
dec cx
int 10h  
inc dx    
int 10h  
inc cx
int 10h
inc cx
int 10h
inc dx    
int 10h
dec cx
int 10h
dec cx
int 10h
add cx,3
int 10h
dec dx
int 10h
dec dx
int 10h
dec dx
int 10h
dec dx
int 10h


;Empiezo a pintar el marco blanco
mov al,15    ;color blanco
inc cx    
int 10h   
dec dx     
call dec3cx
int 10h  
dec cx 
int 10h  
dec cx       
call inc6dx    
call inc3cx   
int 10h         
inc cx     
int 10h    
inc cx       
int 10h     
dec dx       
int 10h     
dec dx     
int 10h      
dec dx      
int 10h    
dec dx       
int 10h
             
;empezamos a imprimir las letras de la palabra COLOR
;Aqui imprimimos la R 
pop ax       ;sacamos el color en turno
add cx,10
sub dx,6

int 10h
dec dx
int 10h
dec dx
int 10h
sub dx,2
int 10h
dec dx
int 10h
dec dx
int 10h
dec cx
int 10h
dec cx
call inc6dx
int 10h
inc cx
dec dx
dec dx
int 10h
dec dx
int 10h
dec dx
int 10h

;Aqui empezamos la O
sub dx,2
sub cx,4
int 10h
call pintarO

;Aqui empezamos la L
dec dx
sub cx,6
add dx,6
call dec3cx
call dec5dx
int 10h
dec dx
int 10h

;Aqui la otra O
sub cx,3
call pintarO

;Aqui la C
dec dx
sub cx,6
add dx,6
call dec3cx
call dec5dx
int 10h
dec dx
call inc3cx
int 10h
;terminamos la palabra COLOR

;Aqui empezamos la paleta
mov cx,posbarrax      ;posicion inicial de la paleta, en eje X, minimo 3
mov dx,posbarray    ;posicion inicial de la paleta, en eje Y, maximo 199
mov ax,15     ;color blanco
mov aux,cx
sub aux,1

push bx
mov bx,193
add bx,cx 
loop1:       ;primera linea inferior de la paleta
cmp cx,bx
jz continue4
mov ah,0ch   ;Le mando la orden de imprimir caracter a AH 
int 10h      ;Aplico cambios con INT 10H, imprimo
inc cx
jmp loop1

continue4:
pop bx       
int 10h      ;linea derecha de la paleta
sub dx,5     ;solo posicionado
jmp lineaSup

lineaSup:    ;pintamos la linea superior
cmp cx,aux
jz color1
mov ah,0ch  
int 10h     
dec cx
jmp lineaSup

color1:      ;el primer cuadro de color de la paleta (azul)
call lineaVert
mov al,0     ;color negro
inc cx
inc dx
inc cx
call pintarCuadro
mov al,1     ;color azul
call pintarCuadro
mov al,2     ;color verde 
call pintarCuadro
mov al,3     ;color celeste
call pintarCuadro
mov al,4     ;color rojo
call pintarCuadro
mov al,5     ;color magenta
call pintarCuadro
mov al,6     ;color cafe
call pintarCuadro
mov al,7     ;color gris claro
call pintarCuadro
mov al,8     ;color gris oscuro
call pintarCuadro
mov al,9     ;color azul claro
call pintarCuadro
mov al,10     ;color verde claro
call pintarCuadro
mov al,11     ;color celeste claro
call pintarCuadro
mov al,12     ;color rojo claro
call pintarCuadro
mov al,13     ;color magenta claro
call pintarCuadro
mov al,14     ;color amarillo claro
call pintarCuadro
mov al,15     ;color blanco 
call pintarCuadro
jmp finalCont

finalCont:
pop dx
pop cx
jmp Mouse

;Pinta 10 pixeles horizontales a la derecha
inc9cx proc near
    push bx
    mov bx,0
  a:
    inc cx
    int 10h
    inc bx
    cmp bx,10
    jz b
    jmp a
  b:
    pop bx
    inc dx
    inc cx    
ret
inc9cx endp 

;Pinta 9 pixeles horizontales a la izquierda
dec9cx proc
    push bx
    mov bx,10
  c:
    dec cx 
    int 10h
    dec bx
    cmp bx,0
    jz d
    jmp c
  d:
    pop bx
    inc dx
    dec cx    
ret
dec9cx endp

;Pinta las lineas intermedias blancas de la paleta
lineaVert proc
    pusha
    mov bh,0
    mov bl,0
    inc cx
  e:
    inc dx
    int 10h
    inc bh
    cmp bh,4
    jz f1
    jmp e
    
  f1:inc cx
     mov bh,0
     jmp f
  f:
    int 10h
    dec dx
    inc bh
    cmp bh,4
    jz g
    jmp f
  g:
   mov bh,0
   inc bl
   cmp bl,17
   jz h
   add cx,11
   jmp e
  h:
     popa    
ret
lineaVert endp

;Manda a llamar a los metodos que pintan lineas
pintarCuadro proc
    call inc9cx
    call dec9cx
    call inc9cx 
    call dec9cx
    add cx,12
    sub dx,4
ret
pintarCuadro endp 

;Metodo que imprime una letra O
;vale la pena debido a que usamos dos veces la letra O
;y el metodo es repetitivo
pintarO proc
call dec3cx
call inc6dx
call inc3cx
call dec5dx
int 10h
ret
pintarO endp

;Imprime tres pixeles en horizontal a la izquierda
dec3cx proc
 d31:  
    int 10h
    dec cx
    inc cont
    cmp cont,3
    jz d32
    jmp d31
 d32:
    mov cont,0  
ret
dec3cx endp

;Imprime cinco pixeles en vertical hacia arriba
dec5dx proc
 d51:  
    int 10h
    dec dx
    inc cont
    cmp cont,5
    jz d52
    jmp d51
 d52:
    mov cont,0  
ret
dec5dx endp

;Imprime tres pixeles en horizontal a la derecha
inc3cx proc
 i31:  
    int 10h
    inc cx
    inc cont
    cmp cont,3
    jz i32
    jmp i31
 i32:
    mov cont,0  
ret
inc3cx endp

;Imprime seis pixeles en vertical hacia abajo
inc6dx proc
 i61:  
    int 10h
    inc dx
    inc cont
    cmp cont,6
    jz i62
    jmp i61
 i62:
    mov cont,0 
ret
inc6dx endp

reiniciar:   ;Limpiar pantalla (y usar color siguiente)
mov init,0
jmp grafico

fin:         ;Etiqueta que me trae al final del programa
             ;Una vez lleguemos aqui no hay forma de regresar
            
lea dx,grax  ;manda el mensaje a DX, termina cuando encuentra $
             ;En realidad lo esta mandando a DS:DX
mov ah, 9    ;Para activar la interrupcion 21H
int 21h      ;Manda a imprimir el mensaje de agradecimiento
    
        
mov ah, 1    ;Esperamos que se presione una tecla
int 21h      ;Lee caracter desde la entrada estandar
    
mov ax, 4c00h;Regresamos al sistema operativo
             ;Se libera toda la memoria
int 21h      ;Si hubiesen archivos abiertos se cierran

ends         ;Marca el final del segmento de codigo

end start    ;Termina con la etiqueta principal y con ello termina
             ;con la ejecucion del programa
