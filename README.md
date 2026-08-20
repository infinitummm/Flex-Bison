# Soluciones a los Ejercicios del Capitulo 1 - Flex & Bison

En este repositorio se encuentran las soluciones a los 6 ejercicios del Capitulo 1 del libro de Flex & Bison.

Los ejercicios que son preguntas conceptuales (1, 4 y 5) estan explicados y respondidos de forma directa y sencilla aqui en el README. Los ejercicios que requieren codigo (2, 3 y 6) tienen su carpeta correspondiente con los archivos fuente necesarios para compilar y probar.

---

## Estructura del Repositorio

```text
Flex-Bison/
├── README.md                 # Respuestas teoricas y guia de ejecucion
├── ejercicio2/               # Calculadora Hexadecimal y Decimal
│   ├── bison.y
│   └── flex.l
├── ejercicio3/               # Operadores a nivel de bits (AND & / OR |)
│   ├── bison.y
│   └── flex.l
└── ejercicio6/               # Word Count en C vs Flex (Benchmark)
    ├── wc_c.c
    └── wc_flex.l
```

---

## Requisitos

Para compilar y correr los programas en Linux solo necesitas tener instalados `flex`, `bison` y `gcc`:

```bash
sudo apt update
sudo apt install build-essential flex bison
```

---

## Ejercicio 1 (Pregunta)

### Enunciado
> Aceptara la calculadora una linea que contenga solo un comentario? Por que no? Seria mas facil solucionar esto en el escaner o en el analizador sintactico?

### Respuesta
**No, la calculadora original no la acepta.** Si ingresas una linea con solo un comentario (por ejemplo `// esto es una prueba`), el programa se detiene y muestra un error de sintaxis (`error: syntax error`).

### Por que ocurre?
1. En Flex, la regla `//.*` lee el texto del comentario y lo ignora, pero deja el salto de linea (`\n`) en el buffer.
2. Al leer ese salto de linea, Flex le manda a Bison el token `EOL` (fin de linea).
3. En Bison, la regla principal de la calculadora espera obligatoriamente una expresion antes del fin de linea (`calclist exp EOL`). Al recibir un `EOL` solo, sin haber recibido numeros ni operaciones antes, Bison no sabe que hacer y lanza el error sintactico.

### Donde es mas facil arreglarlo?
**Es mucho mas facil y limpio arreglarlo en el parser (Bison).**  
Solo hace falta agregar una regla para que Bison acepte lineas donde solo llega un fin de linea:

```yacc
calclist: /* vacio */
    | calclist exp EOL { printf("= %d\n", $2); }
    | calclist EOL     { /* Linea vacia o solo con comentario: no hace nada */ }
    ;
```

Si intentaras arreglarlo en Flex haciendo que el comentario se coma el salto de linea (`//.*\n`), romperias los comentarios que se ponen al final de una operacion valida (como `2 + 3 // suma`), porque Flex se comeria el salto de linea y Bison se quedaria esperando eternamente a que termine la expresion.

---

## Ejercicio 2: Calculadora Hexadecimal y Decimal

### Enunciado
> Convierte la calculadora en una calculadora hexadecimal que acepte tanto numeros hexadecimales como decimales. En el escaner agrega un patron como `0x[a-f0-9]+` para reconocer numeros hexadecimales y en el codigo de accion usa `strtol` para convertir la cadena a un numero que almacenes en `yylval`; luego retorna un token `NUMBER`. Ajusta la salida del `printf` para imprimir el resultado tanto en decimal como en hexadecimal.

### Como funciona
- En `flex.l`, se agregaron dos patrones: uno para hexadecimales (`0[xX][0-9a-fA-F]+`) que usa `strtol(yytext, NULL, 16)` para base 16 y otro para decimales (`[0-9]+`) con `strtol(yytext, NULL, 10)`. Ambos guardan el valor en `yylval` y devuelven el token `NUMBER`.
- En `bison.y`, la accion que imprime el resultado se ajusto para mostrarlo en ambos formatos: `printf("= %d (0x%X)\n", $2, $2);`.

### Como compilar y probar

```bash
cd ejercicio2

# 1. Generar el parser
bison -d bison.y

# 2. Generar el escaner
flex flex.l

# 3. Compilar ambos archivos en un ejecutable
gcc -o programa bison.tab.c lex.yy.c

# 4. Ejecutar
./programa
```

**Ejemplo de prueba:**
```text
0x10 + 10
0xFF - 0x0F
0x20 * 2
```

**Salida obtenida:**
```text
= 26 (0x1A)
= 240 (0xF0)
= 64 (0x40)
```

---

## Ejercicio 3: Operadores Bit a Bit (AND & y OR |)

### Enunciado
> (Credito extra) Añade operadores a nivel de bits como AND y OR a la calculadora. El operador obvio para OR es la barra vertical (|), pero esa ya es el operador unario de valor absoluto. Que sucede si tambien la usas como operador binario OR, por ejemplo, `exp ABS factor`?

### Explicacion
El simbolo `|` se usa para dos cosas totalmente distintas:
1. Como operador unario de valor absoluto antes de un termino: `| -10` (da 10).
2. Como operador binario OR entre dos expresiones: `5 | 3` (en binario `101 | 011 = 111`, que es 7).

Al organizar la gramatica en niveles de precedencia BNF (`exp -> factor -> bit_and -> term`):
- Si `|` aparece al inicio o despues de un operador/parentesis, Bison entiende que es el **valor absoluto unario** (`term: ABS term`).
- Si `|` aparece despues de haber completado una expresion, Bison entiende que es el **OR binario** (`exp: exp ABS factor`).

### Como compilar y probar

```bash
cd ejercicio3

# 1. Generar el parser
bison -d bison.y

# 2. Generar el escaner
flex flex.l

# 3. Compilar
gcc -o programa bison.tab.c lex.yy.c

# 4. Ejecutar
./programa
```

**Ejemplo de prueba:**
```text
0x0F & 0xF0
0x0F | 0xF0
5 | 3
| -10
(10 + 2) & 0x0F
```

**Salida obtenida:**
```text
= 0 (0x0)
= 255 (0xFF)
= 7 (0x7)
= 10 (0xA)
= 12 (0xC)
```

---

## Ejercicio 4 (Pregunta)

### Enunciado
> Reconoce la version del escaner escrita a mano (del Ejemplo 1-4 / barra lateral del Capitulo 1) exactamente los mismos tokens que la version de Flex?

### Respuesta
**No, no reconocen exactamente los mismos tokens.** Aunque para numeros y sumas normales parecen hacer lo mismo, hay una diferencia clave en como tratan los saltos de linea despues de los comentarios:

1. **En el escaner manual en C:**
   Cuando lee un comentario con `while ((c = getc(yyin)) != '\n')`, al encontrar el salto de linea `\n` lo consume y lo descarta con un `break` que vuelve al bucle principal sin avisar nada. Por lo tanto, **el escaner manual se come el salto de linea y NO devuelve el token `EOL`**.
2. **En el escaner de Flex:**
   La regla `"//".*` coincide con el texto del comentario pero **no consume el salto de linea** (porque el punto no hace match con `\n`). En la siguiente vuelta, Flex lee el `\n` y **si devuelve el token `EOL`**.

Ademas, el escaner manual tiene que hacer `ungetc()` a mano para saber si una barra `/` es division o el inicio de un comentario `//`, mientras que Flex maneja ese lookahead de forma automatica y segura con su automata.

---

## Ejercicio 5 (Pregunta)

### Enunciado
> Puedes pensar en lenguajes para los cuales Flex no seria una buena herramienta para escribir un escaner?

### Respuesta
Flex se basa en expresiones regulares y automatas finitos deterministas (DFA). Como los automatas regulares no tienen memoria de pila, Flex se queda corto en lenguajes que dependen de estructura o contexto complejo:

1. **Lenguajes con bloques basados en indentacion (Python, Haskell, YAML, Nim):**  
   En Python no hay llaves `{}` para abrir y cerrar funciones o bucles; todo depende de cuantos espacios hay al principio de cada linea. Para avisarle al parser cuando empieza o termina un bloque, el escaner debe emitir tokens artificiales `INDENT` y `DEDENT`. Como Flex no puede recordar niveles previos de indentacion por si solo, toca programar una pila manual en C dentro de las acciones.
2. **Lenguajes donde los espacios no importan (Fortran 66 / 77):**  
   En Fortran antiguo los espacios se ignoran por completo. Por ejemplo, `DO 10 I = 1.10` es una asignacion a una variable llamada `DO10I`, mientras que `DO 10 I = 1, 10` es un bucle `DO`. Un escaner no puede saber si `DO` es una palabra clave o parte del nombre de una variable hasta que mira hacia adelante buscando si hay una coma o un punto, algo que excede el modelo simple de Flex.
3. **Lenguajes con ambiguedades dependientes del contexto (C/C++, JavaScript):**  
   - En C/C++, si `T` es un `typedef`, `T * x;` es la declaracion de un puntero; pero si `T` es una variable, es una multiplicacion.
   - En JavaScript, el caracter `/` puede ser division (`a / b`) o el inicio de una expresion regular (`/abc/g`). Flex no sabe cual es sin ayuda de lo que el parser esta esperando en ese momento.
4. **Cadenas de texto con codigo anidado (Template strings en JS, Ruby, PHP):**  
   Cuando un lenguaje permite meter codigo ejecutable y anidado dentro de un string (como `"Hola ${ nombre + f("${apellido}") }"`), se requiere alternar recursivamente entre modo texto y modo analizador de codigo, lo cual es dificil de manejar con expresiones regulares planas.
5. **Lenguajes naturales sin espacios entre palabras (Chino, Japones, Tailandes):**  
   Al no haber espacios que separen las palabras, tokenizar requiere diccionarios y modelos morfologicos estadisticos, no simples patrones fijos.

---

## Ejercicio 6: Word Count en C vs Flex (Benchmark)

### Enunciado
> Reescribe el programa de conteo de palabras (word count) en C. Ejecuta algunos archivos grandes a traves de ambas versiones. Es la version en C notablemente mas rapida? Que tan mas dificil fue de depurar?

### Resultados de la comparacion

Al procesar un archivo de prueba grande de **18 MB** (300,000 lineas y 2,400,000 palabras):

| Metrica | Version Flex (`wc_flex`) | Version C Puro Optimizado (`wc_c`) |
|---|---|---|
| Lineas contadas | 300,000 | 300,000 |
| Palabras contadas | 2,400,000 | 2,400,000 |
| Caracteres contados | 18,475,378 | 18,475,378 |
| Tiempo real de ejecucion | **~0.140 segundos** | **~0.037 segundos** (aprox. 3.8x mas rapido) |

### Conclusiones

1. **Rendimiento:** C puro es mas rapido en esta tarea concreta porque un bucle sencillo con un buffer de 16 KB y llamadas directas a `isalpha()` compila a muy pocas instrucciones de maquina, sin el costo del despacho general de estados ni la gestion de tokens de Flex.
2. **Facilidad de depuracion y mantenimiento:**  
   - **Con Flex:** El programa completo son apenas 6 lineas declarativas. Si el dia de mañana cambias la regla de que es una palabra (por ejemplo para admitir numeros o guiones con `[a-zA-Z0-9_-]+`), solo cambias esa linea y Flex recalcula el automata de forma matematica sin riesgo de bugs.
   - **Con C Puro:** Tienes que programar a mano las banderas de estado (`in_word`), los buffers con `fread`, y cuidar los casos limite al final del archivo. A medida que las reglas crecen, escribirlo a mano en C se vuelve infinitamente mas dificil de depurar y mantener.

### Como compilar y probar

```bash
cd ejercicio6

# 1. Compilar la version en Flex
flex wc_flex.l
gcc -O2 -o wc_flex lex.yy.c

# 2. Compilar la version en C puro
gcc -O2 -o wc_c wc_c.c

# 3. Probar ambas versiones con cualquier archivo de texto:
./wc_flex wc_c.c
./wc_c wc_c.c
```
