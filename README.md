# Flex & Bison - Solucion a los Ejercicios del Capitulo 1

Repositorio con la resolucion completa, detallada y ejecutable de los Ejercicios 1 al 6 del Capitulo 1 del libro "flex & bison: Text Processing Tools" de John Levine (O'Reilly Media).

---

## Estructura del Directorio

Cada ejercicio cuenta unicamente con los archivos estrictamente necesarios para su compilacion y ejecucion:

```text
Flex Ejercicios/
├── README.md                 # Documentacion y guia de ejecucion general
├── ejercicio1/               # Ejercicio 1: Lineas con solo comentarios
│   ├── Makefile
│   ├── bison.y
│   └── flex.l
├── ejercicio2/               # Ejercicio 2: Calculadora Hexadecimal y Decimal
│   ├── Makefile
│   ├── bison.y
│   └── flex.l
├── ejercicio3/               # Ejercicio 3: Operadores a nivel de bits (AND & / OR |)
│   ├── Makefile
│   ├── bison.y
│   └── flex.l
├── ejercicio4/               # Ejercicio 4: Escaner Manual en C vs Escaner Flex
│   ├── Makefile
│   ├── flex_scanner.l
│   ├── manual_scanner.c
│   ├── tokens.h
│   └── main.c
├── ejercicio5/               # Ejercicio 5: Lenguajes no aptos para Flex (Demo Indentacion)
│   ├── Makefile
│   ├── python_indent.l
│   └── main.c
└── ejercicio6/               # Ejercicio 6: Word Count en C vs Flex (Benchmark)
    ├── Makefile
    ├── benchmark.sh
    ├── wc_c.c
    └── wc_flex.l
```

---

## Requisitos Previos

Para compilar y ejecutar cualquiera de los programas en Linux, asegurate de tener instaladas las herramientas esenciales:

```bash
# En sistemas basados en Debian/Ubuntu:
sudo apt update
sudo apt install build-essential flex bison
```

---

## Guia Rapida de Compilacion y Ejecucion

| Ejercicio | Directorio | Comando de Compilacion | Comando de Ejecucion |
|---|---|---|---|
| 1. Solo Comentarios | `ejercicio1/` | `make` | `./programa` |
| 2. Calculadora Hex/Dec | `ejercicio2/` | `make` | `./programa` |
| 3. Operadores Bitwise | `ejercicio3/` | `make` | `./programa` |
| 4. Comparativa Escaneres | `ejercicio4/` | `make` | `./programa` |
| 5. Demo Indentacion | `ejercicio5/` | `make` | `./programa` |
| 6. Benchmark Word Count | `ejercicio6/` | `make` | `./benchmark.sh` |

Nota: Para limpiar los archivos generados en cualquier ejercicio, ejecuta `make clean`.

---

## Descripcion Detallada y Casos de Uso por Ejercicio

---

### Ejercicio 1: Manejo de Lineas con Solo Comentarios

#### Enunciado
> *Aceptara la calculadora una linea que contenga solo un comentario? Por que no? Seria mas facil solucionar esto en el escaner o en el analizador sintactico?*

#### Justificacion Teorica
1. **Acepta la version original una linea de solo comentario?**  
   **No.** En la version base del libro, ingresar una linea como `// comentario\n` genera un error sintactico (`error: syntax error`).
2. **Por que falla?**  
   - En `flex.l`, la regla `"//".*` descarta el texto del comentario pero **no consume el salto de linea `\n`** (porque el punto `.` coincide con todo excepto `\n`).
   - El `\n` es capturado por la siguiente regla y retorna el token `EOL` al parser.
   - En `bison.y`, la regla `calclist: calclist exp EOL` exige estrictamente una expresion (`exp`) antes del fin de linea (`EOL`). Al recibir `EOL` sin haber derivado una expresion, el parser detecta un error de sintaxis.
3. **Donde es mejor solucionarlo?**  
   - **En el Parser (Solucion recomendada):** Se añade la regla `| calclist EOL` para aceptar lineas vacias o de solo comentario sin emitir error:
     ```yacc
     calclist: /* vacio */
         | calclist exp EOL { printf("= %d\n", $2); }
         | calclist EOL     { /* linea en blanco o comentario: no hacer nada */ }
         ;
     ```
   - **En el Escaner (Problematico):** Si se intentara absorber el `\n` dentro del comentario (`"//".*\n`), los comentarios colocados al final de una expresion (ej. `5 + 3 // suma\n`) consumirian el `\n`, impidiendo que el parser reciba el token `EOL` necesario para evaluar la operacion.

#### Como Ejecutar
```bash
cd ejercicio1
make
./programa
```

**Ejemplo de prueba interactiva:**
```text
// Linea de solo comentario (no produce error)
2 + 3
// Otro comentario
(10 * 5) - 8 // Comentario al final de linea
```

**Salida:**
```text
= 5
= 42
```

---

### Ejercicio 2: Calculadora Hexadecimal y Decimal

#### Enunciado
> *Convierte la calculadora en una calculadora hexadecimal que acepte tanto numeros hexadecimales como decimales. En el escaner agrega un patron como `0x[a-f0-9]+` para reconocer numeros hexadecimales y en el codigo de accion usa `strtol` para convertir la cadena a un numero que almacenes en `yylval`; luego retorna un token `NUMBER`. Ajusta la salida del `printf` para imprimir el resultado tanto en decimal como en hexadecimal.*

#### Implementacion
1. **Escaner (`flex.l`):**
   - Soporta prefijos `0x` y `0X` con digitos del 0 al 9 y letras de la A a la F:
     ```lex
     0[xX][0-9a-fA-F]+   { yylval = (int)strtol(yytext, NULL, 16); return NUMBER; }
     [0-9]+              { yylval = (int)strtol(yytext, NULL, 10); return NUMBER; }
     ```
2. **Parser (`bison.y`):**
   - Imprime el resultado en formato decimal y hexadecimal:
     ```yacc
     calclist exp EOL { printf("= %d (0x%X)\n", $2, $2); }
     ```

#### Como Ejecutar
```bash
cd ejercicio2
make
./programa
```

**Ejemplo de prueba interactiva:**
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

#### Analisis de Sobrecarga y Conflictos
- **Sobrecarga Sintactica:** El caracter `|` cumple una doble funcion dependiendo de su posicion en la estructura sintactica:
  1. **Unario Prefijo (Valor Absoluto):** `term: ABS term` (ej. `| -10` o `| 5`).
  2. **Binario Infijo (Operador OR bit a bit):** `exp: exp ABS factor` (ej. `5 | 3`).
- **Comportamiento en Bison:**  
  Al estructurar la gramatica con una jerarquia BNF estricta (`exp -> factor -> bit_and -> term`), cuando `|` aparece al inicio de una expresion o tras un operador, el parser deriva hacia `term: ABS term`. Cuando aparece despues de haber derivado un `exp`, actua como operador binario OR.
- **Precedencia implementada:**
  1. `term`: Parentesis `(exp)`, Numeros, Menos unario `-term`, Valor Absoluto `|term`.
  2. `bit_and`: Operador AND a nivel de bits (`&`).
  3. `factor`: Multiplicacion (`*`) y Division (`/`).
  4. `exp`: Suma (`+`), Resta (`-`) y OR a nivel de bits (`|`).

#### Como Ejecutar
```bash
cd ejercicio3
make
./programa
```

**Ejemplo de prueba interactiva:**
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

#### Comparativa y Conclusiones
**No, existen discrepancias clave en su funcionamiento:**

| Caracteristica | Escaner Escrito a Mano (C) | Escaner Generado por Flex |
|---|---|---|
| **Salto de linea en comentarios (`//...\n`)** | **Consume y descarta el `\n`** en el bucle `while (getc != '\n')`. **No retorna el token `EOL`**. | `"//".*` coincide con el comentario pero **no consume el `\n`**, por lo que en el siguiente paso **si retorna `EOL`**. |
| **Deteccion de `/` vs `//`** | Realiza `getc()` y luego `ungetc()` manual para devolver el caracter si no es barra. | El automata finito (DFA) resuelve el prefijo mas largo automaticamente sin llamadas manuales a `ungetc`. |
| **Fin de archivo (EOF)** | Requiere una bandera de estado estatica (`seeneof`) para recordar el fin de archivo tras un `ungetc`. | Integrado de forma nativa en la gestion de buffers de Flex (`yyin`, `YY_BUFFER_STATE`). |

#### Demostracion Comparativa
Se construyo un ejecutable que procesa las mismas entradas con ambos escaneres simultaneamente:
```bash
cd ejercicio4
make
./programa
```

**Evidencia de salida (Demostracion de la diferencia de tokens):**
```text
====================================================
PRUEBA: Linea con comentario y siguiente operacion
Entrada:
"// Comentario
50 * 2
"
----------------------------------------------------
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
====================================================
```
*(Se observa claramente que el escaner manual omitio el token `EOL` correspondiente al salto de linea del comentario).*

---

### Ejercicio 5: Lenguajes No Aptos para Flex

#### Enunciado
> *Puedes pensar en lenguajes para los cuales Flex no seria una buena herramienta para escribir un escaner?*

#### Clasificacion y Razones Tecnicas
Flex se fundamenta en **expresiones regulares y automatas finitos deterministas (DFA)** (Chomsky Tipo 3), los cuales no disponen de memoria de pila ni capacidad para resolver contextos recursivos o globales.

1. **Lenguajes con Indentacion Significativa ("Off-side Rule"):**
   - *Ejemplos:* **Python, Haskell, Nim, YAML, F#**.
   - *Motivo:* Requieren emitir tokens sinteticos `INDENT` y `DEDENT` basados en la comparacion con una pila de profundidad de columnas. Flex no puede mantener esta pila por si mismo.
2. **Lenguajes con Espaciado Insignificante o Columnas Fijas:**
   - *Ejemplos:* **FORTRAN 66 / 77, COBOL**.
   - *Motivo en Fortran:* Los espacios no separan palabras: `DO 10 I = 1.10` es una asignacion (`DO10I = 1.10`) mientras que `DO 10 I = 1, 10` es un bucle. Se requiere lookahead arbitrario mas alla del `=` para distinguir la coma del punto.
3. **Lenguajes con Ambiguedad Lexica dependiente del Parser ("Lexer Hack"):**
   - *Ejemplos:* **C / C++** (`typedef` vs variable), **JavaScript** (`/` como division vs `/` como inicio de expresion regular literal).
4. **Cadenas Interpoladas Complejas / Plantillas Anidadas:**
   - *Ejemplos:* **Ruby, ES6 Template Strings, JSX, PHP**.
   - *Motivo:* Permiten codigo anidado arbitrario dentro de cadenas: `"Texto ${ 1 + f("${x}") }"`.
5. **Lenguajes Naturales y Escrituras Continuas:**
   - *Ejemplos:* **Chino, Japones, Tailandes**.
   - *Motivo:* Al no tener espacios entre palabras, requieren analisis morfologico y probabilistico en lugar de reglas de coincidencia lexica fija.

#### Como Ejecutar (Demo de Indentacion)
```bash
cd ejercicio5
make
./programa
```

**Salida generada:**
```text
==============================================================
DEMOSTRACION: LIMITACIONES DE FLEX CON LENGUAJES INDENTADOS
==============================================================
Codigo fuente a analizar (Python):

def calcular():
    if activo:
        procesar()
    else:
        detener()
finalizar()

--------------------------------------------------------------
Tokens generados (con pila de indentacion manual requerida):
--------------------------------------------------------------
  [KEYWORD] -> 'def'
  [IDENTIFIER] -> 'calcular'
  [OTHER] -> '('
  [OTHER] -> ')'
  [COLON (:)]
  [NEWLINE]
  [INDENT (Inicio de bloque)]
  [KEYWORD] -> 'if'
  [IDENTIFIER] -> 'activo'
  [COLON (:)]
  [NEWLINE]
  [INDENT (Inicio de bloque)]
  [IDENTIFIER] -> 'procesar'
  [OTHER] -> '('
  [OTHER] -> ')'
  [NEWLINE]
  [DEDENT (Fin de bloque)]
  [KEYWORD] -> 'else'
  [COLON (:)]
  [NEWLINE]
  [INDENT (Inicio de bloque)]
  [IDENTIFIER] -> 'detener'
  [OTHER] -> '('
  [OTHER] -> ')'
  [NEWLINE]
  [IDENTIFIER] -> 'finalizar'
  [OTHER] -> '('
  [OTHER] -> ')'
  [NEWLINE]
  [DEDENT (Fin de bloque)]
  [DEDENT (Fin de bloque)]
  [EOF]
==============================================================
```

---

### Ejercicio 6: Word Count en C vs Flex (Benchmark)

#### Enunciado
> *Reescribe el programa de conteo de palabras (word count) en C. Ejecuta algunos archivos grandes a traves de ambas versiones. Es la version en C notablemente mas rapida? Que tan mas dificil fue de depurar?*

#### Resultados del Benchmark (Archivo de Texto de 18 MB / 300,000 lineas)

| Metrica | Version Flex (`wc_flex`) | Version C Puro Optimizado (`wc_c`) |
|---|---|---|
| **Lineas contadas** | 300,000 | 300,000 |
| **Palabras contadas** | 2,400,000 | 2,400,000 |
| **Caracteres contados** | 18,475,378 | 18,475,378 |
| **Tiempo de Ejecucion** | **~0.140 s** | **~0.037 s** (~3.8x mas rapido) |

#### Conclusiones: Velocidad vs Mantenibilidad
- **Rendimiento:** C puro es mas rapido en este caso simple porque realiza un barrido secuencial en memoria con `isalpha()` sin el overhead de la tabla de transiciones ni la gestion de tokens (`yytext`/`yyleng`) del DFA generalizado de Flex.
- **Dificultad de Depuracion y Mantenimiento:**
  - **Flex:** Requiere menos de 10 lineas. Modificar que cuenta como "palabra" (por ejemplo, admitir numeros o guiones con `[a-zA-Z0-9_-]+`) toma 5 segundos y es inmune a errores de punteros.
  - **C Puro:** Requiere gestionar manualmente los buffers con `fread`, controlar la bandera de estado `in_word`, manejar condiciones de borde en EOF y lidiar con punteros. Conforme las reglas del lenguaje crecen, el codigo en C puro se vuelve exponencialmente mas dificil de mantener y depurar.

#### Como Ejecutar el Benchmark
```bash
cd ejercicio6
./benchmark.sh
```
*(El script compilara automaticamente ambos programas, generara un archivo de prueba temporal de 18 MB, medira los tiempos con `time`, verificara la igualdad en los conteos y eliminara el archivo temporal al finalizar).*

---

## Licencia y Creditos
Ejercicios resueltos en base a los temas y ejemplos de:
- **Libro:** *flex & bison: Text Processing Tools* (1.ª Edicion, 2009)
- **Autor:** John R. Levine
- **Editorial:** O'Reilly Media
