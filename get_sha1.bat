@echo off
echo ========================================
echo Obteniendo SHA-1 Fingerprint
echo ========================================
echo.

echo Metodo 1: Usando Gradle (RECOMENDADO)
echo ----------------------------------------
cd android
call gradlew.bat signingReport
cd ..
echo.
echo.

echo Si el metodo anterior no funciono, usa el Metodo 2:
echo ----------------------------------------
echo Ejecuta este comando manualmente:
echo.
echo keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
echo.
echo ========================================
echo Busca la linea que dice "SHA1:" y copia ese valor
echo ========================================
pause
