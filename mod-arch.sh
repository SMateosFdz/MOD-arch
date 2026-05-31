#!/bin/bash

# ─────────────────────────────────────────
#  Utilidades de renombrado de archivos
# ─────────────────────────────────────────

mostrar_menu() {
    echo ""
    echo "======================================================="
    echo "   UTILIDADES DE MOD-arch, TU MODIFICADOR DE ARCHIVOS   "
    echo "======================================================="
    echo " 1) Quitar texto específico del nombre"
    echo " 2) Reemplazar texto específico del nombre"
    echo " 3) Quitar espacios de sobra del nombre"
    echo " 4) Añadir prefijo al nombre"
    echo " 5) Añadir sufijo al nombre"
    echo " 6) Salir"
    echo "======================================================="
    echo ""
}

pedir_extension() {
    read -rp "Extensión a filtrar (deja vacío para todos los archivos): " EXTENSION
    if [ -n "$EXTENSION" ]; then
        PATRON="*.$EXTENSION"
    else
        PATRON="*"
    fi
}

# Separa nombre y extensión de un archivo.
# Si no tiene extensión, ext queda vacío.
separar_nombre_ext() {
    local archivo="$1"
    local punto="${archivo##*.}"

    if [ "$punto" = "$archivo" ] || [ -z "$punto" ]; then
        NOMBRE_BASE="$archivo"
        EXT=""
    else
        NOMBRE_BASE="${archivo%.*}"
        EXT=".$punto"
    fi
}

# Reconstruye el nombre final y llama a mv si hace falta.
renombrar() {
    local archivo="$1"
    local nuevo_base="$2"
    local ext="$3"
    local nuevo="${nuevo_base}${ext}"

    if [ "$archivo" != "$nuevo" ]; then
        # Comprueba si difieren solo en mayúsculas/minúsculas
        if [ "${archivo,,}" = "${nuevo,,}" ]; then
            # Renombrado en dos pasos via nombre temporal
            local tmp="${nuevo}_tmp_$$"
            mv -- "$archivo" "$tmp" && mv -- "$tmp" "$nuevo"
            echo "  ✔ $archivo  →  $nuevo"
        elif [ -e "$nuevo" ]; then
            echo "  ⚠ Saltando '$archivo': '$nuevo' ya existe"
        else
            echo "  ✔ $archivo  →  $nuevo"
            mv -- "$archivo" "$nuevo"
        fi
    fi
}

opcion_quitar_texto() {
    read -rp "Cadena a eliminar: " CADENA
    [ -z "$CADENA" ] && echo "Error: la cadena no puede estar vacía." && return
    pedir_extension

    for archivo in $PATRON; do
        [ -f "$archivo" ] || continue
        separar_nombre_ext "$archivo"
        nuevo_base="${NOMBRE_BASE//$CADENA/}"
        renombrar "$archivo" "$nuevo_base" "$EXT"
    done
}

opcion_quitar_espacios() {
    pedir_extension

    for archivo in $PATRON; do
        [ -f "$archivo" ] || continue
        separar_nombre_ext "$archivo"
        nuevo_base=$(echo "$NOMBRE_BASE" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//; s/[[:space:]]\+/ /g')
        renombrar "$archivo" "$nuevo_base" "$EXT"
    done
}

opcion_añadir_prefijo() {
    read -rp "Prefijo a añadir: " PREFIJO
    [ -z "$PREFIJO" ] && echo "Error: el prefijo no puede estar vacío." && return
    pedir_extension

    for archivo in $PATRON; do
        [ -f "$archivo" ] || continue
        separar_nombre_ext "$archivo"
        nuevo_base="${PREFIJO}${NOMBRE_BASE}"
        renombrar "$archivo" "$nuevo_base" "$EXT"
    done
}

opcion_añadir_sufijo() {
    read -rp "Sufijo a añadir (antes de la extensión): " SUFIJO
    [ -z "$SUFIJO" ] && echo "Error: el sufijo no puede estar vacío." && return
    pedir_extension

    for archivo in $PATRON; do
        [ -f "$archivo" ] || continue
        separar_nombre_ext "$archivo"
        nuevo_base="${NOMBRE_BASE}${SUFIJO}"
        renombrar "$archivo" "$nuevo_base" "$EXT"
    done
}

opcion_reemplazar_texto() {
    read -rp "Texto a buscar: " BUSCAR
    [ -z "$BUSCAR" ] && echo "Error: el texto a buscar no puede estar vacío." && return
    read -rp "Texto de reemplazo: " REEMPLAZO
    pedir_extension

    for archivo in $PATRON; do
        [ -f "$archivo" ] || continue
        separar_nombre_ext "$archivo"
        nuevo_base="${NOMBRE_BASE//$BUSCAR/$REEMPLAZO}"
        renombrar "$archivo" "$nuevo_base" "$EXT"
    done
}

# ─── Bucle principal ───────────────────────────────────────────────────────────

while true; do
    mostrar_menu
    read -rp "Elige una opción [1-6]: " OPCION

    case "$OPCION" in
        1) opcion_quitar_texto     ;;
        2) opcion_reemplazar_texto ;;
        3) opcion_quitar_espacios  ;;
        4) opcion_añadir_prefijo   ;;
        5) opcion_añadir_sufijo    ;;
        6) echo "¡Hasta luego!" && exit 0 ;;
        *) echo "Opción no válida. Introduce un número del 1 al 6." ;;
    esac

    echo ""
    read -rp "Pulsa Enter para volver al menú..."
done
