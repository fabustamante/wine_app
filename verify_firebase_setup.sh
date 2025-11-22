#!/bin/bash

# Script para verificar la configuración de Firebase Auth
# Uso: bash verify_firebase_setup.sh

echo "🔍 Verificando configuración de Firebase Authentication..."
echo ""

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

checks_passed=0
checks_failed=0

# 1. Verificar pubspec.yaml
echo "📦 Verificando dependencias en pubspec.yaml..."
if grep -q "firebase_auth:" pubspec.yaml && grep -q "google_sign_in:" pubspec.yaml; then
    echo -e "${GREEN}✅ Dependencias encontradas${NC}"
    ((checks_passed++))
else
    echo -e "${RED}❌ Faltan dependencias de firebase_auth o google_sign_in${NC}"
    ((checks_failed++))
fi
echo ""

# 2. Verificar google-services.json
echo "🤖 Verificando configuración de Android..."
if [ -f "android/app/google-services.json" ]; then
    echo -e "${GREEN}✅ google-services.json encontrado${NC}"
    ((checks_passed++))
else
    echo -e "${RED}❌ No se encontró android/app/google-services.json${NC}"
    echo -e "${YELLOW}   Descárgalo de Firebase Console${NC}"
    ((checks_failed++))
fi
echo ""

# 3. Verificar archivos de servicio
echo "🔧 Verificando archivos de servicio..."
if [ -f "lib/services/firebase_auth_service.dart" ]; then
    echo -e "${GREEN}✅ FirebaseAuthService creado${NC}"
    ((checks_passed++))
else
    echo -e "${RED}❌ No se encontró firebase_auth_service.dart${NC}"
    ((checks_failed++))
fi
echo ""

# 4. Verificar LoginScreen actualizado
echo "🖥️  Verificando LoginScreen..."
if grep -q "signInWithGoogle" lib/presentation/screen/login.dart; then
    echo -e "${GREEN}✅ LoginScreen actualizado con Google Sign-In${NC}"
    ((checks_passed++))
else
    echo -e "${RED}❌ LoginScreen no tiene soporte para Google Sign-In${NC}"
    ((checks_failed++))
fi
echo ""

# 5. Verificar AuthNotifier
echo "📱 Verificando AuthNotifier..."
if grep -q "signInWithEmailAndPassword" lib/presentation/viewmodels/auth_viewmodel.dart; then
    echo -e "${GREEN}✅ AuthNotifier actualizado${NC}"
    ((checks_passed++))
else
    echo -e "${RED}❌ AuthNotifier no tiene métodos de Firebase Auth${NC}"
    ((checks_failed++))
fi
echo ""

# Resumen
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Resumen de verificación:"
echo -e "${GREEN}   Verificaciones exitosas: $checks_passed${NC}"
if [ $checks_failed -gt 0 ]; then
    echo -e "${RED}   Verificaciones fallidas: $checks_failed${NC}"
else
    echo -e "${GREEN}   Verificaciones fallidas: $checks_failed${NC}"
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Siguientes pasos
if [ $checks_failed -eq 0 ]; then
    echo -e "${GREEN}🎉 ¡Todo configurado correctamente!${NC}"
    echo ""
    echo "Próximos pasos:"
    echo "1. Ejecuta: flutter pub get"
    echo "2. Configura Firebase Console (ver FIREBASE_AUTH_SETUP.md)"
    echo "3. Añade el SHA-1 en Firebase Console"
    echo "4. Ejecuta: flutter run"
else
    echo -e "${YELLOW}⚠️  Completa las configuraciones faltantes${NC}"
    echo ""
    echo "Consulta FIREBASE_AUTH_SETUP.md para más detalles"
fi
echo ""

# Comando para obtener SHA-1
echo "💡 Tip: Para obtener el SHA-1 fingerprint ejecuta:"
echo "   cd android && ./gradlew signingReport"
echo ""
