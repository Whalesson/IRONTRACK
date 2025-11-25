#!/bin/bash

# Script de execução do IRONTRACK
# Autor: Manus AI
# Data: 25/11/2025

echo "🏋️ IRONTRACK - Iniciando aplicativo..."
echo ""

# Verificar se estamos no diretório correto
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Erro: Execute este script no diretório raiz do projeto IRONTRACK"
    exit 1
fi

# Verificar se Flutter está instalado
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter não encontrado no PATH"
    echo "💡 Adicione ao PATH: export PATH=\"\$PATH:/home/ubuntu/flutter/bin\""
    exit 1
fi

# Verificar dispositivos disponíveis
echo "🔍 Verificando dispositivos disponíveis..."
flutter devices

echo ""
echo "🚀 Executando IRONTRACK em modo release..."
echo ""

# Executar o aplicativo
flutter run -d linux --release

