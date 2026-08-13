# Flex & Bison - Ejemplos del Capítulo 1

Este repositorio contiene la implementación y solución detallada de los **Ejemplos 1 al 5** del Capítulo 1 del libro *flex & bison* de John Levine.

Cada ejercicio está organizado en su propia carpeta independiente y estructurado únicamente con dos archivos fuente principales: el escáner léxico (`flex.l`) y el analizador sintáctico (`bison.y`), los cuales se compilan de forma conjunta.

---

## 📁 Estructura del Repositorio

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

## 🛠️ Requisitos Previos y Compilación

Para compilar y ejecutar cualquiera de los ejercicios, necesitas tener instalados en tu sistema:
- `flex` (Fast Lexical Analyzer)
- `bison` (GNU Parser Generator)
- `gcc` (GNU Compiler Collection)

### Pasos Generales para Compilar y Ejecutar

Navega a la carpeta del ejercicio que deseas probar (por ejemplo `ejercicio1`):

```bash
cd ejercicio1

# 1. Generar los archivos C y encabezados desde Bison (.y)
bison -d bison.y

# 2. Generar el archivo de escáner en C desde Flex (.l)
flex flex.l

# 3. Compilar los archivos C generados juntos
gcc -o programa bison.tab.c lex.yy.c

# 4. Ejecutar el ejecutable
./programa
```

---

## 🚀 Descripción de los Ejercicios

### 1. `ejercicio1/` — Contador de Palabras, Líneas y Caracteres (Word Count)
* **Descripción:** Adaptación del programa clásico `wc` de Unix mediante la compilación conjunta de Flex y Bison.
* **Funcionamiento:**
  * `flex.l`: Identifica palabras (`[a-zA-Z]+`), saltos de línea (`\n`) y caracteres genéricos (`.`), retornando tokens al parser.
  * `bison.y`: Recibe los tokens, acumula el conteo de palabras, líneas y caracteres, y muestra el resumen al finalizar la entrada (`EOF`).

---

### 2. `ejercicio2/` — Traductor de Inglés Británico a Americano
* **Descripción:** Filtro que traduce palabras escritas en inglés británico a su equivalente en inglés americano.
* **Mapeo de Términos:**
  * `colour` ➔ `color`
  * `flavour` ➔ `flavor`
  * `clever` ➔ `smart`
  * `smart` ➔ `elegant`
  * `conservative` ➔ `liberal`
* **Funcionamiento:**
  * `flex.l`: Asigna el texto traducido a `yylval.str`.
  * `bison.y`: Reconstruye y muestra el texto procesado manteniendo la puntuación y formato original.

---

### 3. `ejercicio3/` — Reconocedor de Tokens para Calculadora
* **Descripción:** Escáner léxico conectado a Bison que identifica e imprime los tokens de una calculadora elemental.
* **Tokens Reconocidos:**
  * Operadores: `+` (PLUS), `-` (MINUS), `*` (TIMES), `/` (DIVIDE), `|` (ABS)
  * Números enteros: `NUMBER <valor>`
  * Salto de línea: `NEWLINE`
  * Desconocidos: `Mystery character <c>`

---

### 4. `ejercicio4/` — Escáner con Identificadores de Tokens y Valores (`yylval`)
* **Descripción:** Demuestra la asignación de números de token por Bison (empezando en 258) y la transmisión de valores numéricos a través de la variable `yylval`.
* **Identificadores de Tokens de Bison:**
  * `NUMBER` = 258 (`yylval.val = valor`)
  * `ADD` = 259, `SUB` = 260, `MUL` = 261, `DIV` = 262, `ABS` = 263, `EOL` = 264
* **Funcionamiento:** Muestra el número de token interno generado por Bison junto con el valor numérico capturado.

---

### 5. `ejercicio5/` — Calculadora Aritmética Completa (Flex + Bison)
* **Descripción:** Calculadora interactiva que evalúa expresiones matemáticas respetando la precedencia de operadores mediante gramática BNF.
* **Precedencia Gramatical:**
  1. `exp`: Operaciones de nivel inferior (`+` y `-`).
  2. `factor`: Operaciones de nivel superior (`*` y `/`).
  3. `term`: Números enteros y operador unario de valor absoluto (`| term`).
* **Ejemplos de Evaluación:**
  * `2 + 3 * 4` ➔ `= 14`
  * `20 - 4 / 2` ➔ `= 18`
  * `| 15` ➔ `= 15`
