@echo off
rem ---- Prepara una copia SOLO de fuentes de C:\REA para subirla al repo pvklein/rea ----
rem No toca C:\REA: copia a una carpeta del Escritorio y la comprime en REA-fuentes.zip.
rem Deja fuera APK, claves, copias de moviles, backups, bases de datos, fotos, videos,
rem libros y modelos (la misma lista que el .gitignore del repo).
rem Despues: revisa REA-fuentes-lista.txt y adjunta REA-fuentes.zip en el chat de Claude.
setlocal

set ORIGEN=C:\REA
set DESTINO=%USERPROFILE%\Desktop\REA-para-subir
set ZIP=%USERPROFILE%\Desktop\REA-fuentes.zip
set LISTA=%USERPROFILE%\Desktop\REA-fuentes-lista.txt

if not exist "%ORIGEN%\" (
  echo No encuentro %ORIGEN%
  pause
  exit /b 1
)

rem ---- La carpeta de destino es solo de este script: se rehace desde cero ----
if exist "%DESTINO%\" rmdir /s /q "%DESTINO%"
if exist "%ZIP%" del /q "%ZIP%"

echo Copiando fuentes de %ORIGEN% ...
robocopy "%ORIGEN%" "%DESTINO%" /E /XJ /R:0 /W:0 /NP /NDL /LOG:"%LISTA%" ^
  /XD .git .gradle .idea .kotlin build node_modules __pycache__ apks copia-galaxy-a10 copia-huawei-p8lite tagus-backup backups resultados ^
  /XF *.key *.keystore *.jks *.pem *.p12 *_ed25519 *_ed25519.pub id_rsa* local.properties .env ^
      *.apk *.apks *.aab *.dex *.class *.pyc ^
      *.db *.sqlite *.sqlite3 *.db-journal *.csv *.onnx *.zip *.tar.bz2 ^
      *.jpg *.jpeg *.heic *.mp4 *.mkv *.webm *.mp3 *.wav *.m4a *.acsm *.epub *.lcpl *.pdf
rem robocopy devuelve 0-7 si ha ido bien y 8 o mas si ha fallado algo
if %ERRORLEVEL% GEQ 8 (
  echo Ha fallado la copia. Mira %LISTA%
  pause
  exit /b 1
)

echo Comprimiendo en %ZIP% ...
powershell -NoProfile -Command "Compress-Archive -Path '%DESTINO%\*' -DestinationPath '%ZIP%' -Force"
if not exist "%ZIP%" (
  echo No se ha podido crear %ZIP%
  pause
  exit /b 1
)

for %%A in ("%ZIP%") do echo Listo: %%~nxA ocupa %%~zA bytes
echo.
echo 1. Revisa la lista de ficheros copiados: %LISTA%
echo 2. Si todo esta bien, adjunta REA-fuentes.zip en el chat de Claude.
echo    Si ves algo que no deberia salir de casa, borralo de %DESTINO%
echo    y vuelve a comprimir (o dimelo y lo anado a las exclusiones).
echo.
start "" notepad "%LISTA%"
start "" explorer "%USERPROFILE%\Desktop"
pause
