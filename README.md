# Soluciones del Capítulo 1

Este documento contiene las respuestas y explicaciones de los seis ejercicios del primer capítulo del libro sobre Flex y Bison.  
Las preguntas conceptuales se responden de forma directa; los ejercicios de programación incluyen el planteamiento, el funcionamiento y ejemplos de ejecución.

## Dylan Torre - Juan Gomez - Javier Rosero

---

## Ejercicio 1 – Comentarios en la calculadora

**Enunciado:**  
¿Aceptaría la calculadora original una línea que contenga únicamente un comentario? ¿Por qué? ¿Dónde sería más fácil solucionarlo, en el analizador léxico o en el sintáctico?

**Respuesta:**  
No, la calculadora original rechaza una línea de solo comentario y muestra un error de sintaxis.  

La razón es que el analizador léxico (Flex) ignora el contenido del comentario, pero no consume el salto de línea final. Ese salto se envía al analizador sintáctico (Bison) como el token `EOL` (fin de línea). Como la gramática espera una expresión antes de `EOL`, al recibir solo `EOL` se produce un error.

La solución más limpia y sencilla es modificar el analizador sintáctico añadiendo una regla que acepte líneas vacías o con solo comentarios:

```yacc
calclist: /* vacío */
    | calclist exp EOL  { printf("= %d\n", $2); }
    | calclist EOL      { /* línea vacía o solo comentario: no hacer nada */ }
    ;
```

Intentar arreglarlo desde el analizador léxico (haciendo que el comentario consuma también el salto) rompería los comentarios al final de una expresión válida, porque Flex se llevaría el `EOL` y el analizador sintáctico quedaría esperando indefinidamente.

---

## Ejercicio 2 – Calculadora hexadecimal y decimal

**Enunciado:**  
Modifique la calculadora para que acepte números tanto hexadecimales como decimales. En el analizador léxico, añada un patrón para hexadecimales (p. ej. `0x[a-f0-9]+`) y use `strtol` para convertir. Muestre el resultado en ambos formatos.

**Solución:**  
En el archivo Flex se añaden dos reglas:

- Para hexadecimales: `0[xX][0-9a-fA-F]+` → se convierte con `strtol(yytext, NULL, 16)` y se retorna `NUMBER`.
- Para decimales: `[0-9]+` → se convierte con `strtol(yytext, NULL, 10)` y se retorna `NUMBER`.

En Bison, la impresión del resultado se modifica para mostrar ambos formatos:

```c
printf("= %d (0x%X)\n", $2, $2);
```

**Compilación y prueba:**

```bash
bison -d bison.y
flex flex.l
gcc -o programa bison.tab.c lex.yy.c
./programa
```

**Prueba**

<img width="498" height="264" alt="image" src="https://github.com/user-attachments/assets/6d141330-f8e5-4b33-8cad-b8a6fcae9c1f" />


---

## Ejercicio 3 – Operadores binarios AND y OR

**Enunciado:**  
Añada los operadores AND (`&`) y OR (`|`) como operadores binarios. El símbolo `|` ya se usa para el valor absoluto (operador unario). ¿Cómo resolver la ambigüedad?

**Explicación:**  
El símbolo `|` se emplea tanto para el valor absoluto (unario) como para la operación OR (binario). La gramática se organiza con niveles de precedencia. De este modo:

- Si `|` aparece al inicio de una expresión o tras un operador, se interpreta como el operador unario de valor absoluto (`term: ABS term`).
- Si `|` aparece después de haber leído una expresión completa, se interpreta como el OR binario (`exp: exp ABS factor`).

El operador `&` se maneja de manera análoga con la precedencia adecuada.


**Prueba**

<img width="387" height="366" alt="image" src="https://github.com/user-attachments/assets/466e3685-5eb0-490e-ae9a-71163e6b23ea" />


---

## Ejercicio 4 – Comparación entre el escáner manual y Flex

**Enunciado:**  
¿El escáner escrito a mano (del ejemplo del libro) reconoce exactamente los mismos tokens que la versión con Flex?

**Respuesta:**  
No, hay una diferencia fundamental en el tratamiento de los saltos de línea después de los comentarios.

- **Escáner manual en C:** al encontrar un comentario (`//...`), consume el salto de línea y lo descarta, de modo que **no genera el token `EOL`** para esa línea.
- **Escáner con Flex:** la regla `"//".*` no consume el `\n`; por tanto, Flex lo lee en la siguiente iteración y **sí envía el token `EOL`**.

Además, el escáner manual debe gestionar manualmente el retroceso (`ungetc`) para distinguir entre el operador división y el inicio de un comentario, mientras que Flex maneja esta ambigüedad de forma automática mediante su autómata finito.

---

## Ejercicio 5 – Lenguajes no adecuados para Flex

**Enunciado:**  
¿Puede pensar en lenguajes para los cuales Flex no sea una buena herramienta?

**Respuesta:**  
Flex está basado en expresiones regulares y autómatas finitos deterministas, por lo que carece de memoria de pila. No es apropiado para lenguajes que requieran contexto o estructura anidada compleja. Algunos ejemplos:

1. **Lenguajes con indentación significativa** (Python, Haskell, YAML): se necesitan tokens `INDENT`/`DEDENT` que dependen de una pila de niveles, lo que exige programación manual en C dentro de las acciones de Flex.
2. **Lenguajes donde los espacios no son separadores** (Fortran antiguo): la distinción entre palabra clave y nombre de variable puede requerir mirar varios caracteres adelante, superando la capacidad de un DFA.
3. **Lenguajes con ambigüedades contextuales** (C/C++ con `typedef`, JavaScript con la barra `/`): el significado de un token depende del contexto sintáctico, que Flex no conoce sin ayuda del parser.
4. **Cadenas con código anidado** (plantillas de JavaScript, Ruby): se necesita alternar entre modos de análisis de texto y de código, lo que resulta difícil con expresiones regulares planas.
5. **Idiomas sin separadores de palabras** (chino, japonés): la tokenización requiere diccionarios y análisis morfológico, no meros patrones fijos.

---

## Ejercicio 6 – Comparación de rendimiento: Word Count en C vs Flex

**Enunciado:**  
Implemente un contador de palabras (líneas, palabras y caracteres) en C puro y compárelo con la versión hecha con Flex. ¿Es notablemente más rápida la versión en C? ¿Cuál es más fácil de depurar?

**Resultados** (con un archivo de prueba de 18 MB, 300 000 líneas y 2 400 000 palabras):

| Métrica                 | Versión Flex | Versión C optimizada |
|-------------------------|--------------|----------------------|
| Tiempo de ejecución     | ~0.140 s     | ~0.037 s             |
| Líneas contadas         | 300 000      | 300 000              |
| Palabras contadas       | 2 400 000    | 2 400 000            |
| Caracteres contados     | 18 475 378   | 18 475 378           |

**Conclusiones:**

- **Rendimiento:** la versión en C es unas 3,8 veces más rápida en este caso, porque un bucle sencillo con buffer y llamadas a `isalpha()` genera muy pocas instrucciones, sin la sobrecarga de la gestión de estados de Flex.
- **Mantenibilidad:** la versión con Flex es mucho más concisa (unas pocas líneas declarativas) y, ante cambios en la definición de “palabra”, solo hay que modificar la expresión regular. En C puro hay que manejar manualmente el estado, los buffers y los casos límite, lo que se vuelve complejo a medida que crecen las reglas.

**Compilación y prueba:**

```bash
# Versión Flex
flex wc_flex.l
gcc -O2 -o wc_flex lex.yy.c

# Versión C
gcc -O2 -o wc_c wc_c.c

# Ejecutar sobre un archivo
./wc_flex archivo.txt
./wc_c archivo.txt
```
