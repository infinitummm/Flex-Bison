# 🛠️ Flex & Bison - Solución a los Ejercicios del Capítulo 1

Repositorio con la resolución completa, detallada y ejecutable de los **Ejercicios 1 al 6 del Capítulo 1** del libro *"flex & bison: Text Processing Tools"* de John Levine (O'Reilly Media).

---

## 📂 Estructura del Directorio

Cada ejercicio cuenta únicamente con los archivos estrictamente necesarios para su compilación y ejecución:

```text
Flex Ejercicios/
├── README.md                 # Documentación y guía de ejecución general
├── ejercicio1/               # Ejercicio 1: Líneas con solo comentarios
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
├── ejercicio4/               # Ejercicio 4: Escáner Manual en C vs Escáner Flex
│   ├── Makefile
│   ├── flex_scanner.l
│   ├── manual_scanner.c
│   ├── tokens.h
│   └── main.c
├── ejercicio5/               # Ejercicio 5: Lenguajes no aptos para Flex (Demo Indentación)
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

## ⚙️ Requisitos Previos

Para compilar y ejecutar cualquiera de los programas en Linux, asegúrate de tener instaladas las herramientas esenciales:

```bash
# En sistemas basados en Debian/Ubuntu:
sudo apt update
sudo apt install build-essential flex bison
```

---

## 🚀 Guía Rápida de Compilación y Ejecución

| Ejercicio | Directorio | Comando de Compilación | Comando de Ejecución |
|---|---|---|---|
| **1. Solo Comentarios** | `ejercicio1/` | `make` | `./programa` |
| **2. Calculadora Hex/Dec** | `ejercicio2/` | `make` | `./programa` |
| **3. Operadores Bitwise** | `ejercicio3/` | `make` | `./programa` |
| **4. Comparativa Escáneres** | `ejercicio4/` | `make` | `./programa` |
| **5. Demo Indentación** | `ejercicio5/` | `make` | `./programa` |
| **6. Benchmark Word Count** | `ejercicio6/` | `make` | `./benchmark.sh` |

> 💡 **Nota:** Para limpiar los archivos generados en cualquier ejercicio, ejecuta `make clean`.

---

## 📖 Descripción Detallada y Casos de Uso por Ejercicio

---

### 🟢 Ejercicio 1: Manejo de Líneas con Solo Comentarios

#### 📌 Enunciado
> *¿Aceptará la calculadora una línea que contenga solo un comentario? ¿Por qué no? ¿Sería más fácil solucionar esto en el escáner o en el analizador sintáctico?*

#### 🧠 Justificación Teórica
1. **¿Acepta la versión original una línea de solo comentario?**  
   **No.** En la versión base del libro, ingresar una línea como `// comentario\n` genera un error sintáctico (`error: syntax error`).
2. **¿Por qué falla?**  
   - En `flex.l`, la regla `"//".*` descarta el texto del comentario pero **no consume el salto de línea `\n`** (porque el punto `.` coincide con todo excepto `\n`).
   - El `\n` es capturado por la siguiente regla y retorna el token `EOL` al parser.
   - En `bison.y`, la regla `calclist: calclist exp EOL` exige estrictamente una expresión (`exp`) antes del fin de línea (`EOL`). Al recibir `EOL` sin haber derivado una expresión, el parser detecta un error de sintaxis.
3. **¿Dónde es mejor solucionarlo?**  
   - **En el Parser (Solución recomendada):** Se añade la regla `| calclist EOL` para aceptar líneas vacías o de solo comentario sin emitir error:
     ```yacc
     calclist: /* vacio */
         | calclist exp EOL { printf("= %d\n", $2); }
         | calclist EOL     { /* linea en blanco o comentario: no hacer nada */ }
         ;
     ```
   - **En el Escáner (Problemático):** Si se intentara absorber el `\n` dentro del comentario (`"//".*\n`), los comentarios colocados al final de una expresión (ej. `5 + 3 // suma\n`) consumirían el `\n`, impidiendo que el parser reciba el token `EOL` necesario para evaluar la operación.

#### 💻 Cómo Ejecutar
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

### 🟢 Ejercicio 2: Calculadora Hexadecimal y Decimal

#### 📌 Enunciado
> *Convierte la calculadora en una calculadora hexadecimal que acepte tanto números hexadecimales como decimales. En el escáner agrega un patrón como `0x[a-f0-9]+` para reconocer números hexadecimales y en el código de acción usa `strtol` para convertir la cadena a un número que almacenes en `yylval`; luego retorna un token `NUMBER`. Ajusta la salida del `printf` para imprimir el resultado tanto en decimal como en hexadecimal.*

#### 🧠 Implementación
1. **Escáner (`flex.l`):**
   - Soporta prefijos `0x` y `0X` con dígitos del 0 al 9 y letras de la A a la F:
     ```lex
     0[xX][0-9a-fA-F]+   { yylval = (int)strtol(yytext, NULL, 16); return NUMBER; }
     [0-9]+              { yylval = (int)strtol(yytext, NULL, 10); return NUMBER; }
     ```
2. **Parser (`bison.y`):**
   - Imprime el resultado en formato decimal y hexadecimal:
     ```yacc
     calclist exp EOL { printf("= %d (0x%X)\n", $2, $2); }
     ```

#### 💻 Cómo Ejecutar
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

### 🟢 Ejercicio 3: Operadores a Nivel de Bits (AND `&` y OR `|`)

#### 📌 Enunciado
> *(Crédito extra) Añade operadores a nivel de bits como `AND` y `OR` a la calculadora. El operador obvio para `OR` es la barra vertical (`|`), pero esa ya es el operador unario de valor absoluto. ¿Qué sucede si también la usas como operador binario `OR`, por ejemplo, `exp ABS factor`?*

#### 🧠 Análisis de Sobrecarga y Conflictos
- **Sobrecarga Sintáctica:** El carácter `|` cumple una doble función dependiendo de su posición en la estructura sintáctica:
  1. **Unario Prefijo (Valor Absoluto):** `term: ABS term` (ej. `| -10` o `| 5`).
  2. **Binario Infijo (Operador OR bit a bit):** `exp: exp ABS factor` (ej. `5 | 3`).
- **Comportamiento en Bison:**  
  Al estructurar la gramática con una jerarquía BNF estricta (`exp -> factor -> bit_and -> term`), cuando `|` aparece al inicio de una expresión o tras un operador, el parser deriva hacia `term: ABS term`. Cuando aparece después de haber derivado un `exp`, actúa como operador binario OR.
- **Precedencia implementada:**
  1. `term`: Paréntesis `(exp)`, Números, Menos unario `-term`, Valor Absoluto `|term`.
  2. `bit_and`: Operador AND a nivel de bits (`&`).
  3. `factor`: Multiplicación (`*`) y División (`/`).
  4. `exp`: Suma (`+`), Resta (`-`) y OR a nivel de bits (`|`).

#### 💻 Cómo Ejecutar
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

### 🟢 Ejercicio 4: Escáner Manual en C vs Escáner Flex

#### 📌 Enunciado
> *¿Reconoce la versión del escáner escrita a mano (del Ejemplo 1-4 / barra lateral del Capítulo 1) exactamente los mismos tokens que la versión de Flex?*

#### 🧠 Comparativa y Conclusiones
**No, existen discrepancias clave en su funcionamiento:**

| Característica | Escáner Escrito a Mano (C) | Escáner Generado por Flex |
|---|---|---|
| **Salto de línea en comentarios (`//...\n`)** | **Consume y descarta el `\n`** en el bucle `while (getc != '\n')`. **No retorna el token `EOL`**. | `"//".*` coincide con el comentario pero **no consume el `\n`**, por lo que en el siguiente paso **sí retorna `EOL`**. |
| **Detección de `/` vs `//`** | Realiza `getc()` y luego `ungetc()` manual para devolver el carácter si no es barra. | El autómata finito (DFA) resuelve el prefijo más largo automáticamente sin llamadas manuales a `ungetc`. |
| **Fin de archivo (EOF)** | Requiere una bandera de estado estática (`seeneof`) para recordar el fin de archivo tras un `ungetc`. | Integrado de forma nativa en la gestión de buffers de Flex (`yyin`, `YY_BUFFER_STATE`). |

#### 💻 Cómo Ejecutar
```bash
cd ejercicio4
make
./programa
```

**Evidencia de salida (Demostración de la diferencia de tokens):**
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
*(Se observa claramente que el escáner manual omitió el token `EOL` correspondiente al salto de línea del comentario).*

---

### 🟢 Ejercicio 5: Lenguajes No Aptos para Flex

#### 📌 Enunciado
> *¿Puedes pensar en lenguajes para los cuales Flex no sería una buena herramienta para escribir un escáner?*

#### 🧠 Clasificación y Razones Técnicas
Flex se fundamenta en **expresiones regulares y autómatas finitos deterministas (DFA)** (Chomsky Tipo 3), los cuales no disponen de memoria de pila ni capacidad para resolver contextos recursivos o globales.

1. **Lenguajes con Indentación Significativa ("Off-side Rule"):**
   - *Ejemplos:* **Python, Haskell, Nim, YAML, F#**.
   - *Motivo:* Requieren emitir tokens sintéticos `INDENT` y `DEDENT` basados en la comparación con una pila de profundidad de columnas. Flex no puede mantener esta pila por sí mismo.
2. **Lenguajes con Espaciado Insignificante o Columnas Fijas:**
   - *Ejemplos:* **FORTRAN 66 / 77, COBOL**.
   - *Motivo en Fortran:* Los espacios no separan palabras: `DO 10 I = 1.10` es una asignación (`DO10I = 1.10`) mientras que `DO 10 I = 1, 10` es un bucle. Se requiere lookahead arbitrario más allá del `=` para distinguir la coma del punto.
3. **Lenguajes con Ambigüedad Léxica dependiente del Parser ("Lexer Hack"):**
   - *Ejemplos:* **C / C++** (`typedef` vs variable), **JavaScript** (`/` como división vs `/` como inicio de expresión regular literal).
4. **Cadenas Interpoladas Complejas / Plantillas Anidadas:**
   - *Ejemplos:* **Ruby, ES6 Template Strings, JSX, PHP**.
   - *Motivo:* Permiten código anidado arbitrario dentro de cadenas: `"Texto ${ 1 + f("${x}") }"`.
5. **Lenguajes Naturales y Escrituras Continuas:**
   - *Ejemplos:* **Chino, Japonés, Tailandés**.
   - *Motivo:* Al no tener espacios entre palabras, requieren análisis morfológico y probabilístico en lugar de reglas de coincidencia léxica fija.

#### 💻 Cómo Ejecutar (Demo de Indentación)
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

### 🟢 Ejercicio 6: Word Count en C vs Flex (Benchmark)

#### 📌 Enunciado
> *Reescribe el programa de conteo de palabras (`word count`) en C. Ejecuta algunos archivos grandes a través de ambas versiones. ¿Es la versión en C notablemente más rápida? ¿Qué tan más difícil fue de depurar?*

#### 📊 Resultados del Benchmark (Archivo de Texto de 18 MB / 300,000 líneas)

| Métrica | Versión Flex (`wc_flex`) | Versión C Puro Optimizado (`wc_c`) |
|---|---|---|
| **Líneas contadas** | 300,000 | 300,000 |
| **Palabras contadas** | 2,400,000 | 2,400,000 |
| **Caracteres contados** | 18,475,378 | 18,475,378 |
| **Tiempo de Ejecución** | **~0.140 s** | **~0.037 s** (⚡ ~3.8x más rápido) |

#### 🧠 Conclusiones: Velocidad vs Mantenibilidad
- **Rendimiento:** C puro es más rápido en este caso simple porque realiza un barrido secuencial en memoria con `isalpha()` sin el overhead de la tabla de transiciones ni la gestión de tokens (`yytext`/`yyleng`) del DFA generalizado de Flex.
- **Dificultad de Depuración y Mantenimiento:**
  - **Flex:** Requiere menos de 10 líneas. Modificar qué cuenta como "palabra" (por ejemplo, admitir números o guiones con `[a-zA-Z0-9_-]+`) toma 5 segundos y es inmune a errores de punteros.
  - **C Puro:** Requiere gestionar manualmente los buffers con `fread`, controlar la bandera de estado `in_word`, manejar condiciones de borde en EOF y lidiar con punteros. Conforme las reglas del lenguaje crecen, el código en C puro se vuelve exponencialmente más difícil de mantener y depurar.

#### 💻 Cómo Ejecutar el Benchmark
```bash
cd ejercicio6
./benchmark.sh
```
*(El script compilará automáticamente ambos programas, generará un archivo de prueba temporal de 18 MB, medirá los tiempos con `time`, verificará la igualdad en los conteos y eliminará el archivo temporal al finalizar).*

---

## 📜 Licencia y Créditos
Ejercicios resueltos en base a los temas y ejemplos de:
- **Libro:** *flex & bison: Text Processing Tools* (1.ª Edición, 2009)
- **Autor:** John R. Levine
- **Editorial:** O'Reilly Media
