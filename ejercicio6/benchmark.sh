#!/bin/bash
set -e

echo "=========================================================="
echo "BENCHMARK DE RENDIMIENTO: FLEX VS C PURO (WORD COUNT)"
echo "=========================================================="

# Compilar ambos
make all

# Generar un archivo de prueba grande (aprox. 20MB de texto)
TESTFILE="test_large.txt"
echo "Generando archivo de prueba de texto ($TESTFILE)..."
python3 -c "
import random
words = ['palabra', 'lenguaje', 'compilador', 'flex', 'bison', 'parsing', 'token', 'scanner', 'analisis', 'codigo']
with open('$TESTFILE', 'w') as f:
    for i in range(300000):
        line = ' '.join(random.choices(words, k=8)) + '\n'
        f.write(line)
"
FILESIZE=$(ls -lh "$TESTFILE" | awk '{print $5}')
echo "Archivo generado con exito (Tamano: $FILESIZE)"
echo "----------------------------------------------------------"

echo "[1] Ejecutando version en FLEX:"
time ./wc_flex "$TESTFILE"
echo ""

echo "[2] Ejecutando version en C PURO:"
time ./wc_c "$TESTFILE"
echo "----------------------------------------------------------"

# Limpieza del archivo de prueba grande
rm -f "$TESTFILE"
echo "Benchmark finalizado y archivo de prueba temporal eliminado."
echo "=========================================================="
