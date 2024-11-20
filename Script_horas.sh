#!/bin/bash
#Autor:Leandra Abigail Luna Celin
#Fecha: 19 de noviembre

# Directorio 
Directorio="/LUSTRE/cursos/2024/semestre1/gnulinux/a.8014/evaluacion_final/REPORTES-SLURM"

# Variables para almacenar resultados
declare -A semestrales_utilizadas
declare -A semestrales_idle
declare -A anuales_utilizadas
declare -A anuales_idle

# Procesar archivos
for file in "$Directorio"/SLURM-*; do
    # Obtener año y mes del nombre del archivo
    basename=$(basename "$file")
    mes=$(echo $basename | cut -d '-' -f 2)  
    year=$(echo $basename | cut -d '-' -f 3)    

    # Calcular semestre (S1 o S2)
   
   if  [[ $mes -le 6 ]]; then
            semestre="${year}-S1"
        else
            semestre="${year}-S2"
        fi   

    # Extraer horas reportadas y horas utilizadas
    line=$(sed -n '10p' "$file")                          # Línea 10
    H_Reportadas=$(echo "$line" | awk -F '|' '{print $7}' | tr -d ' ') # Campo 7
    H_Utilizadas=$(echo "$line" | awk -F '|' '{print $2}' | tr -d ' ') # Campo 2

    # Calcular horas IDLE
    H_IDLE=$((H_Reportadas - H_Utilizadas))

    # Sumar al total semestral
    semestrales_utilizadas["$semestre"]=$(( ${semestrales_utilizadas["$semestre"]:-0} + H_Utilizadas ))
    semestrales_idle["$semestre"]=$(( ${semestrales_idle["$semestre"]:-0} + H_IDLE ))

    # Sumar al total anual
    anuales_utilizadas["$year"]=$(( ${anuales_utilizadas["$year"]:-0} + H_Utilizadas ))
    anuales_idle["$year"]=$(( ${anuales_idle["$year"]:-0} + H_IDLE ))
done

# Generar reporte semestral
echo "Reporte Semestral" > reporte_semestral.txt
echo "-----------------" >> reporte_semestral.txt
echo "Semestre, Horas Utilizadas, Horas IDLE" >> reporte_semestral.txt
for key in "${!semestrales_utilizadas[@]}"; do
    echo "$key, ${semestrales_utilizadas[$key]}, ${semestrales_idle[$key]}"
done | sort >> reporte_semestral.txt

# Generar reporte anual
echo "Reporte Anual" > reporte_anual.txt
echo "-------------" >> reporte_anual.txt
echo "Año, Horas Utilizadas, Horas IDLE" >> reporte_anual.txt
for year in "${!anuales_utilizadas[@]}"; do
    echo "$year, ${anuales_utilizadas[$year]}, ${anuales_idle[$year]}" 
done | sort  >> reporte_anual.txt

# Mostrar mensajes de éxito
echo "Reportes generados:"
echo "- reporte_semestral.txt"
echo "- reporte_anual.txt"

