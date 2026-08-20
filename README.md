# Flex & Bison - Solucion a los Ejercicios del Capitulo 1

Repositorio con la resolucion completa, explicada y ejecutable de los Ejercicios 1 al 6 del Capitulo 1 del libro "flex & bison: Text Processing Tools" de John Levine (O'Reilly Media).

---
## Dylan Torres - Juan Gomez - Javier Rosero
## Estructura del Repositorio

Cada carpeta contiene exclusivamente los archivos fuente esenciales para generar y compilar el programa:

```text
Flex-Bison/
├── README.md                 # Documentacion y guia de compilacion/ejecucion
├── ejercicio1/               # Ejercicio 1: Lineas con solo comentarios
│   ├── bison.y
│   └── flex.l
├── ejercicio2/               # Ejercicio 2: Calculadora Hexadecimal y Decimal
│   ├── bison.y
│   └── flex.l
├── ejercicio3/               # Ejercicio 3: Operadores a nivel de bits (AND & / OR |)
│   ├── bison.y
│   └── flex.l
├── ejercicio4/               # Ejercicio 4: Escaner Manual en C vs Escaner Flex
│   ├── flex_scanner.l
│   ├── manual_scanner.c
│   ├── tokens.h
│   └── main.c
├── ejercicio5/               # Ejercicio 5: Lenguajes no aptos para Flex (Demo Indentacion)
│   ├── python_indent.l
│   └── main.c
└── ejercicio6/               # Ejercicio 6: Word Count en C vs Flex (Benchmark)
    ├── wc_c.c
    └── wc_flex.l
```

---

## Requisitos del Sistema

Para compilar y ejecutar los ejercicios en un entorno Linux, se requiere tener instalados:
- `flex`
- `bison`
- `gcc`

En distribuciones basadas en Debian/Ubuntu:
```bash
sudo apt update
sudo apt install build-essential flex bison
```

---

## Descripcion de Ejercicios y Modo de Ejecucion

---

### Ejercicio 1: Manejo de Lineas con Solo Comentarios

#### Enunciado
> *Aceptara la calculadora una linea que contenga solo un comentario? Por que no? Seria mas facil solucionar esto en el escaner o en el analizador sintactico?*

#### Explicacion del Problema y Solucion
1. **Comportamiento original:** En la calculadora base del libro, una linea con solo `// comentario\n` produce `error: syntax error`.
2. **Causa:** Flex reconoce `"//".*` e ignora el texto del comentario, pero **no consume el salto de linea `\n`**. Al leer el siguiente caracter, Flex envia a Bison el token `EOL`. Como la regla gramatical exige una expresion antes de fin de linea (`calclist: calclist exp EOL`), recibir un `EOL` huerfano detona un error sintactico.
3. **Mejor solucion:** En el **Parser (Bison)**, agregando la regla `| calclist EOL` que admite lineas en blanco o de solo comentario. Solucionarlo en el escaner absorbiendo el `\n` (`"//".*\n`) romperia los comentarios colocados al final de una expresion valida (ej. `2 + 3 // suma\n`).

#### Compilacion y Ejecucion Paso a Paso

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

**Ejemplo de prueba:**
```text
// Este es un comentario solo
10 + 20
// Otro comentario intermedio
(5 * 4) - 2 // Comentario en linea
```

**Salida:**
```text
= 30
= 18
```

---

### Ejercicio 2: Calculadora Hexadecimal y Decimal

#### Enunciado
> *Convierte la calculadora en una calculadora hexadecimal que acepte tanto numeros hexadecimales como decimales. En el escaner agrega un patron como `0x[a-f0-9]+` para reconocer numeros hexadecimales y en el codigo de accion usa `strtol` para convertir la cadena a un numero que almacenes en `yylval`; luego retorna un token `NUMBER`. Ajusta la salida del `printf` para imprimir el resultado tanto en decimal como en hexadecimal.*

#### Explicacion del Funcionamiento
- En `flex.l`, se define la regla `0[xX][0-9a-fA-F]+` utilizando `strtol(yytext, NULL, 16)` para base 16 y `[0-9]+` con `strtol(yytext, NULL, 10)` para base decimal.
- En `bison.y`, se formatea la salida con `printf("= %d (0x%X)\n", $2, $2);` para mostrar el resultado en ambos formatos.

#### Compilacion y Ejecucion Paso a Paso

```bash
cd ejercicio2

# 1. Generar el codigo C del parser y la cabecera
bison -d bison.y

# 2. Generar el codigo C del escaner
flex flex.l

# 3. Compilar en un unico ejecutable
gcc -o programa bison.tab.c lex.yy.c

# 4. Ejecutar el programa
./programa
```

**Ejemplo de prueba:**
```text
0x10 + 10
0xFF - 0x0F
0x20 * 2
0x100 / 0x10
```

**Salida:**
```text
= 26 (0x1A)
= 240 (0xF0)
= 64 (0x40)
= 16 (0x10)
```

---

### Ejercicio 3: Operadores a Nivel de Bits (AND & y OR |)

#### Enunciado
> *(Credito extra) Añade operadores a nivel de bits como AND y OR a la calculadora. El operador obvio para OR es la barra vertical (|), pero esa ya es el operador unario de valor absoluto. Que sucede si tambien la usas como operador binario OR, por ejemplo, `exp ABS factor`?*

#### Explicacion del Funcionamiento
- **Sobrecarga del caracter `|`:**
  - Como **Valor Absoluto Unario (Prefijo):** `term: ABS term` (ejemplo: `| -10` o `| 5`).
  - Como **OR Binario Bit a Bit (Infijo):** `exp: exp ABS factor` (ejemplo: `5 | 3`).
- Al definir la gramatica mediante una jerarquia BNF bien estructurada (`exp -> factor -> bit_and -> term`), Bison deduce si la barra vertical es unaria o binaria segun su posicion en la expresion.

#### Compilacion y Ejecucion Paso a Paso

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

**Salida:**
```text
= 0 (0x0)
= 255 (0xFF)
= 7 (0x7)
= 10 (0xA)
= 12 (0xC)
```

---

### Ejercicio 4: Escaner Manual en C vs Escaner Flex

#### Enunciado
> *Reconoce la version del escaner escrita a mano (del Ejemplo 1-4 / barra lateral del Capitulo 1) exactamente los mismos tokens que la version de Flex?*

#### Explicacion del Funcionamiento
**No reconocen exactamente los mismos tokens.**
- **Diferencia en comentarios:** En el escaner manual en C, el bucle `while((c = getc()) != '\n')` consume y descarta el caracter `\n`, por lo que **no retorna el token `EOL`**. En cambio, Flex descarta el texto pero conserva el `\n`, retornando el token `EOL` en el siguiente paso.
- Este programa incluye ambos escaneres y los ejecuta sobre la misma entrada para evidenciar la diferencia.

#### Compilacion y Ejecucion Paso a Paso

```bash
cd ejercicio4

# 1. Generar el escaner de Flex con salida personalizada
flex -o flex_scanner.c flex_scanner.l

# 2. Compilar el programa comparador que enlaza el escaner manual y el de Flex
gcc -o programa main.c manual_scanner.c flex_scanner.c

# 3. Ejecutar la comparativa
./programa
```

**Resultado de la prueba:**
```text
PRUEBA: Linea con comentario y siguiente operacion
Entrada: "// Comentario\n50 * 2\n"

[1] Tokens generados por FLEX:
  -> EOL (\n)
  -> NUMBER = 50
  -> MUL (*)
  -> NUMBER = 2
  -> EOL (\n)
  -> EOF (0)

[2] Tokens generados por SCANNER MANUAL (C):
  -> NUMBER = 50
  -> MUL (*)
  -> NUMBER = 2
  -> EOL (\n)
  -> EOF (0)
```
*(Se observa que el escaner manual omite el token `EOL` del comentario).*

---

### Ejercicio 5: Lenguajes No Aptos para Flex

#### Enunciado
> *Puedes pensar en lenguajes para los cuales Flex no seria una buena herramienta para escribir un escaner?*

#### Explicacion Teorica
Flex genera Autómatas Finitos Deterministas (DFA) que reconocen lenguajes regulares (Chomsky Tipo 3) sin memoria de pila. Lenguajes no aptos para Flex puro incluyen:
1. **Lenguajes basados en Indentacion (Python, Haskell, YAML):** Requieren emitir tokens sinteticos `INDENT` y `DEDENT` controlando una pila de profundidad de columnas.
2. **Lenguajes con Espaciado Insignificante (FORTRAN 77):** `DO 10 I = 1.10` (asignacion) vs `DO 10 I = 1, 10` (bucle) requiere lookahead arbitrario mas alla del `=`.
3. **Ambiguedad Dependiente del Contexto (C/C++, JavaScript):** `typedef` vs identificador, `/` como division vs `/pattern/` como regex.
4. **Cadenas Interpoladas Complejas (Ruby, JS Template Strings, PHP):** Permitir expresiones gramaticales completas y anidadas dentro de texto.
5. **Lenguajes sin delimitadores de palabras (Chino, Japones):** Requieren segmentacion morfologica estadistica.

#### Compilacion y Ejecucion Paso a Paso (Demo de Indentacion)

```bash
cd ejercicio5

# 1. Generar el escaner con la logica de pila manual
flex python_indent.l

# 2. Compilar con el programa principal
gcc -o programa main.c lex.yy.c

# 3. Ejecutar la demostracion
./programa
```

---

### Ejercicio 6: Word Count en C vs Flex (Benchmark)

#### Enunciado
> *Reescribe el programa de conteo de palabras (word count) en C. Ejecuta algunos archivos grandes a traves de ambas versiones. Es la version en C notablemente mas rapida? Que tan mas dificil fue de depurar?*

#### Explicacion del Funcionamiento
- **Rendimiento:** La version en C puro optimizada con buffer es ~3.8 veces mas rapida en archivos grandes (ej. 18 MB / 300,000 lineas) debido a que no incurre en el overhead del despacho de estados y gestion de buffers de tokens del DFA general de Flex.
- **Depuracion y Mantenibilidad:** Flex se escribe en 6 lineas declarativas y cambiar las reglas de palabras toma segundos sin riesgo de bugs. En C puro, cualquier cambio de reglas requiere reprogramar estados manuales con `switch`/`if` y manejo de buffers, aumentando exponencialmente la complejidad de depuracion.

#### Compilacion y Ejecucion Paso a Paso

```bash
cd ejercicio6

# 1. Compilar la version en Flex
flex wc_flex.l
gcc -O2 -o wc_flex lex.yy.c

# 2. Compilar la version en C puro
gcc -O2 -o wc_c wc_c.c

# 3. Ejecutar sobre cualquier archivo de texto para comparar conteos:
./wc_flex wc_c.c
./wc_c wc_c.c
```

