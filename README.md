# Flex & Bison - Ejemplos del Capitulo 1

## Dylan Torres - Juan Gomez - Javier Rosero

Este repositorio contiene la implementacion, analisis y casos de uso detallados de los Ejemplos 1 al 5 del Capitulo 1 del libro "Flex & Bison" de John Levine.

Cada ejercicio se encuentra organizado en una carpeta individual y esta compuesto unicamente por dos archivos fuente: el escaner lexico (flex.l) y el analizador sintactico (bison.y), disenados para compilarse y trabajar conjuntamente.

---

## Estructura del Repositorio

```text
Flex-Bison/
├── README.md
├── ejercicio1/
│   ├── bison.y
│   └── flex.l
├── ejercicio2/
│   ├── bison.y
│   └── flex.l
├── ejercicio3/
│   ├── bison.y
│   └── flex.l
├── ejercicio4/
│   ├── bison.y
│   └── flex.l
└── ejercicio5/
    ├── bison.y
    └── flex.l
```

---

## Requisitos y Modo de Compilacion

Para compilar y ejecutar cualquiera de los ejercicios en un entorno Linux, se requiere tener instalados:
- flex
- bison
- gcc

### Instrucciones de Compilacion y Ejecucion

Para probar cualquiera de los programas, ingresa a la carpeta del ejercicio correspondiente y ejecuta la siguiente secuencia de comandos:

```bash
cd ejercicio1

# 1. Generar el codigo C del parser y el archivo de cabecera con los tokens
bison -d bison.y

# 2. Generar el codigo C del escaner lexico
flex flex.l

# 3. Compilar ambos codigos fuente en un unico ejecutable
gcc -o programa bison.tab.c lex.yy.c

# 4. Ejecutar el programa
./programa
```

---

## Descripcion Detallada y Casos de Uso por Ejercicio

### 1. ejercicio1/ - Contador de Palabras, Lineas y Caracteres (Word Count)

#### Explicacion del Funcionamiento
Este ejercicio recrea la funcionalidad basica del comando `wc` de Unix. 
- En `flex.l`, el escaner analiza la entrada de texto caracter por caracter. La expresion regular `[a-zA-Z]+` detecta secuencias continuas de letras como palabras, sumando su longitud en caracteres (`yyleng`) y retornando el token `WORD`. El salto de linea `\n` retorna `NEWLINE`, y cualquier otro caracter (espacios, numeros, signos) retorna `CHAR_TOK`.
- En `bison.y`, el parser procesa la secuencia de tokens mediante una regla recursiva. Por cada `WORD` incrementa el contador de palabras; por cada `NEWLINE` incrementa las lineas y suma un caracter; y por cada `CHAR_TOK` incrementa el contador de caracteres. Al finalizar la lectura (EOF con Ctrl+D), la funcion `main` imprime el total de lineas, palabras y caracteres.

#### Casos de Uso Reales

**Prueba 1: Texto simple con dos palabras**
- Entrada:
  ```text
  Hola Mundo
  ```
- Salida del programa:
  ```text
         1       2      11
  ```
- Analisis: Contabiliza 1 linea, 2 palabras ("Hola" y "Mundo") y 11 caracteres (4 letras de Hola + 1 espacio + 5 letras de Mundo + 1 salto de linea).

**Prueba 2: Cadena exclusivamente numerica**
- Entrada:
  ```text
  1234
  ```
- Salida del programa:
  ```text
         1       0       5
  ```
- Analisis: Como el patron `[a-zA-Z]+` solo reconoce caracteres alfabeticos, los digitos `1234` son capturados por la regla generica `.`, por lo que se contabilizan 0 palabras y 5 caracteres totales (4 digitos + 1 salto de linea).

**Prueba 3: Linea con un espacio en blanco**
- Entrada:
  ```text
   
  ```
- Salida del programa:
  ```text
         1       0       1
  ```
- Analisis: Contabiliza 1 linea y 1 caracter correspondiente al salto de linea.

**Prueba 4: Frase larga con varias palabras**
- Entrada:
  ```text
  Hola mundo profesor Joaquin
  ```
- Salida del programa:
  ```text
         1       4      28
  ```
- Analisis: Reconoce correctamente las 4 palabras y los 28 caracteres totales generados en una unica linea.

---

### 2. ejercicio2/ - Traductor de Ingles Britanico a Americano

#### Explicacion del Funcionamiento
Este programa funciona como un filtro de texto que detecta vocabulario en ingles britanico y lo sustituye automaticamente por su equivalente en ingles americano, manteniendo el resto del texto inalterado.
- En `flex.l`, se declaran patrones exactos para palabras clave (`colour`, `flavour`, `clever`, `smart`, `conservative`). Cuando el escaner encuentra una coincidencia, asigna la cadena traducida en memoria dinamica mediante `strdup()` al valor semantico `yylval.str` y retorna el token `WORD_TOK`. Cualquier otra palabra o signo de puntuacion se pasa intacto.
- En `bison.y`, se define `%union { char *str; }` para manejar valores semanticos tipo cadena. La gramatica recibe cada token, imprime el texto traducido y libera la memoria con `free($1)` para evitar fugas de memoria.

#### Casos de Uso Reales

**Prueba 1: Palabra britanica simple**
- Entrada:
  ```text
  colour
  ```
- Salida del programa:
  ```text
  color
  ```
- Analisis: La regla de Flex `"colour"` intercepta el termino britanico y entrega `"color"` a Bison para su impresion inmediata.

**Prueba 2: Sensibilidad a mayusculas y minusculas (Case Sensitivity)**
- Entrada:
  ```text
  CLEVER
  clever
  ```
- Salida del programa:
  ```text
  CLEVER
  smart
  ```
- Analisis: Por defecto Flex distingue entre mayusculas y minusculas. `CLEVER` en mayusculas no coincide con el patron `"clever"` y es tratado como una palabra generica, pasandose sin modificar. En cambio, `clever` en minusculas se traduce exitosamente a `smart`.

**Prueba 3: Cadena de sustituciones mixtas**
- Entrada:
  ```text
  Smart
  smart
  ```
- Salida del programa:
  ```text
  Smart
  elegant
  ```
- Analisis: `Smart` con mayuscula inicial se preserva sin cambios, mientras que `smart` en minusculas se traduce a `elegant`.

---

### 3. ejercicio3/ - Reconocedor de Tokens para Calculadora

#### Explicacion del Funcionamiento
Este ejercicio muestra como Flex y Bison se comunican para identificar la estructura lexica de una calculadora.
- En `flex.l`, se identifican los operadores aritmeticos (`+`, `-`, `*`, `/`, `|`), numeros enteros de uno o mas digitos (`[0-9]+`), y saltos de linea (`\n`). Los espacios y tabulaciones se omiten silenciosamente. Cualquier caracter no reconocido entra en la regla comodin `.`, devolviendo el token `MYSTERY`.
- En `bison.y`, se declaran los tokens correspondientes y se asocian acciones semanticas que imprimen el nombre formal del token identificado (`PLUS`, `MINUS`, `NUMBER`, etc.).

#### Casos de Uso Reales

**Prueba 1: Operacion aritmetica basica**
- Entrada:
  ```text
  1-1
  ```
- Salida del programa:
  ```text
  NUMBER 1
  MINUS
  NUMBER 1
  NEWLINE
  ```
- Analisis: Reconoce el primer numero `1`, el operador de resta `MINUS`, el segundo numero `1` y el fin de instruccion `NEWLINE`.

**Prueba 2: Caracteres no validos (Manejo de errores lexicos)**
- Entrada:
  ```text
  Hola
  ```
- Salida del programa:
  ```text
  Mystery character H
  Mystery character o
  Mystery character l
  Mystery character a
  NEWLINE
  ```
- Analisis: Las letras no forman parte de los simbolos reconocidos por la calculadora. Por lo tanto, la regla comodin atrapa cada letra individualmente e informa que se trata de un caracter desconocido (*Mystery character*).

**Prueba 3: Secuencia continua de operadores y numero largo**
- Entrada:
  ```text
  -+*/1234567890
  ```
- Salida del programa:
  ```text
  MINUS
  PLUS
  TIMES
  DIVIDE
  NUMBER 1234567890
  NEWLINE
  ```
- Analisis: Flex tokeniza en orden secuencial cada operador individual y agrupa toda la cadena de digitos como un unico token `NUMBER`.

---

### 4. ejercicio4/ - Escaner con Identificadores de Tokens y Valores (yylval)

#### Explicacion del Funcionamiento
En este ejercicio se profundiza en el mecanismo interno de Bison para asignar identificadores numericos a los tokens y el uso de `yylval` para transportar datos semanticos heterogeneos.
- Bison asigna de manera automatica numeros enteros a los tokens declarados a partir de 258 (para no colisionar con los codigos ASCII del 0 al 255): `NUMBER` = 258, `ADD` = 259, `SUB` = 260, `MUL` = 261, `DIV` = 262, `ABS` = 263, `EOL` = 264.
- En `flex.l`, cuando se encuentra un numero, se convierte la cadena a entero con `atoi(yytext)` y se almacena en `yylval.val`. Para caracteres desconocidos, se almacena el caracter en `yylval.mystery_char`.
- En `bison.y`, se define `%union { int val; char mystery_char; }` y se imprime el ID numerico del token junto con el valor numerico recibido.

#### Casos de Uso Reales

**Prueba 1: Reconocimiento de un numero individual**
- Entrada:
  ```text
  1
  ```
- Salida del programa:
  ```text
  258 = 1
  264
  ```
- Analisis: El token `NUMBER` tiene el codigo interno `258` y transporta el valor entero `1` a traves de `yylval.val`. El salto de linea corresponde al token `EOL` con codigo `264`.

**Prueba 2: Operadores individuales**
- Entrada:
  ```text
  -
  +
  ```
- Salida del programa:
  ```text
  260
  264
  259
  264
  ```
- Analisis: Muestra los identificadores generados por Bison para resta (`260`) y suma (`259`).

**Prueba 3: Combinacion de operadores y digitos continuos**
- Entrada:
  ```text
  -+
  /-+*
  1234567890
  ```
- Salida del programa:
  ```text
  260
  259
  264
  262
  260
  259
  261
  264
  258 = 1234567890
  264
  ```
- Analisis: Se observa la secuencia exacta de codigos emitidos: division (`262`), resta (`260`), suma (`259`), multiplicacion (`261`) y el numero entero de 10 digitos con su valor integro (`258 = 1234567890`).

---

### 5. ejercicio5/ - Calculadora Aritmetica Completa (Flex + Bison) con Manejo de Division por Cero

#### Explicacion del Funcionamiento
Implementacion de una calculadora aritmetica funcional que evalua expresiones matematicas en tiempo real siguiendo una gramatica libre de contexto (BNF) que establece la precedencia de operadores:
1. Nivel `exp` (menor precedencia): evalua sumas (`+`) y restas (`-`).
2. Nivel `factor` (precedencia media): evalua multiplicaciones (`*`) y divisiones (`/`).
3. Nivel `term` (mayor precedencia): evalua numeros enteros (`NUMBER`) y el operador unario de valor absoluto (`| term`).

#### Control de Excepcion: Division por Cero
En la regla de division de `bison.y`, se incorpora una verificacion de seguridad para el divisor (`$3`):
```yacc
factor: term
    | factor MUL term { $$ = $1 * $3; }
    | factor DIV term {
        if ($3 == 0) {
            yyerror("division por cero");
            $$ = 0;
        } else {
            $$ = $1 / $3;
        }
    }
    ;
```
Si el denominador es cero, se invoca `yyerror("division por cero")` y se asigna un valor por defecto (`$$ = 0`) para evitar que el programa falle por excepcion de punto flotante (`SIGFPE`) y permitir continuar evaluando expresiones posteriores.

#### Casos de Uso y Pruebas

**Prueba 1: Precedencia de operaciones (Multiplicacion y Division antes de Suma y Resta)**
- Entrada:
  ```text
  2 + 3 * 4
  20 - 4 / 2
  ```
- Salida del programa:
  ```text
  = 14
  = 18
  ```
- Analisis: En `2 + 3 * 4`, primero se resuelve `3 * 4 = 12` y luego `2 + 12 = 14`. En `20 - 4 / 2`, primero se resuelve `4 / 2 = 2` y luego `20 - 2 = 18`.

**Prueba 2: Operador Unario de Valor Absoluto**
- Entrada:
  ```text
  | 15
  10 + | 5
  ```
- Salida del programa:
  ```text
  = 15
  = 15
  ```
- Analisis: El operador `|` actua como un operador unario prefijo sobre el termino siguiente.

**Prueba 3: Division por cero controlada**
- Entrada:
  ```text
  10 / 2
  10 / 0
  20 / 4 - 2
  ```
- Salida del programa:
  ```text
  = 5
  error: division por cero
  = 0
  = 3
  ```
- Analisis: La division `10 / 0` detecta el divisor nulo, emite el mensaje de error correspondiente y asigna `0`, permitiendo que la instruccion siguiente (`20 / 4 - 2`) se continue ejecutando normalmente.
