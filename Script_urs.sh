#!/bin/bash
#Autor:Leandra Abigail Luna Celin
#Fecha: 19 de noviembre


# Directorio de entrada y archivos temporales
Dir="/LUSTRE/cursos/2024/semestre1/gnulinux/a.8014/evaluacion_final/REPORTES-SLURM"
Sem_Reporte="Reporte_semestral_usr.csv"
anual_Reporte="Reporte_anual_usr.csv"

# Archivo temporal para acumular resultados
Temp_File="temp_reporte.txt"

# Limpiar el archivo temporal
> "$Temp_File"

# Procesar cada archivo en el directorio
for file in "$Dir"/SLURM-*; do
    if [[ -f "$file" ]]; then
         echo "Procesando $file..."

        # Obtener el año y mes del archivo
        basename=$(basename "$file")
        year=$(echo "$basename" | cut -d'-' -f3)
        mes=$(echo "$basename" | cut -d'-' -f2)

        # Calcular el semestre
        if [[ $mes -le 6 ]]; then
            semester="${year}-S1"
        else
            semester="${year}-S2"
        fi

        # Extraer horas CPU utilizadas
        awk '/Time reported in Hours/ {flag=1; next} /NUM JOBS/ {flag=0} flag && NF' "$file" | \
        awk -F '|' '{if (NF >= 4) print $1, $2}' | \
        sed 's/|//g' | \
        awk -v semester="$semester" -v year="$year" '{print $1, $2, 0, semester, year}' >> "$Temp_File"

        # Extraer número de trabajos
    awk '/Units are in number of jobs ran/ {flag=1; next} /^Account/ {flag=0} flag && NF' "$file" | \
    awk -F '|' '{if (NF >= 5) print $2, 0, $3}' | \
    sed 's/|//g' | \
    awk -v semester="$semester" -v year="$year" '{print $1, 0, $3, semester, year}' >> "$Temp_File"

    fi
done

# Generar reporte semestral
echo "Usuario,Horas_CPU,Num_Jobs,Semestre" > "$Sem_Reporte"
awk '
    $1 != "Account" {key=$1 FS $4; cpu[key]+=$2; jobs[key]+=$3}
    END {
        for (k in cpu) {
            split(k, arr, FS);
            print arr[1] "," cpu[k] "," jobs[k] "," arr[2]
        }
    }
' "$Temp_File" >> "$Sem_Reporte"

# Generar reporte anual
echo "Usuario,Horas_CPU,Num_Jobs,Año" > "$anual_Reporte"
awk '
    $1 != "Account" {key=$1 FS $5; cpu[key]+=$2; jobs[key]+=$3}
    END {
        for (k in cpu) {
            split(k, arr, FS);
            print arr[1] "," cpu[k] "," jobs[k] "," arr[2]
        }
    }
' "$Temp_File" >> "$anual_Reporte"

# Limpiar archivo temporal
rm -f "$Temp_File"

echo "Reportes generados:"
echo " - Reporte semestral urs: $Sem_Reporte"
echo " - Reporte anual urs: $anual_Reporte"
