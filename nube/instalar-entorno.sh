#!/bin/bash
# ---- Entorno en la nube para el proyecto REA ----
# Deja el contenedor de Claude Code en la nube lo más parecido posible al PC "JCAV":
#   JDK 17 (Android) + JDK 21 (ya viene), Gradle 8.10.2, Android SDK 35,
#   Python 3 con Pillow, REA 6.7.0 y, si se rellenan sus URL, Ghidra y JADX.
#
# Dónde se usa: entorno de la nube -> Edit -> "Setup script" (pegar el fichero entero).
# También se puede lanzar a mano dentro de una sesión: bash nube/instalar-entorno.sh
#
# Es idempotente (lo ya instalado no se repite) y nunca hace fallar el arranque:
# si la red del entorno bloquea una descarga, lo avisa al final y sigue.

set -u

# ---- Versiones (las mismas que en el PC) ----
VERSION_GRADLE="8.10.2"
VERSION_REA="6.7.0"
SDK_PAQUETES="platform-tools platforms;android-35 build-tools;35.0.0 build-tools;34.0.0"

# ---- Rutas en el contenedor ----
DIR_GRADLE="/opt/gradle-${VERSION_GRADLE}"
DIR_SDK="/opt/android-sdk"
DIR_HERRAMIENTAS="/opt/rea-herramientas"
FICHERO_PERFIL="/etc/profile.d/rea-entorno.sh"

# ---- Descargas ----
# cmdline-tools de Android: solo sirve para instalar el resto del SDK, no hace falta la última.
URL_ANDROID_CMDLINE="https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip"
# Ghidra 12.1.4 (necesita JDK 21, que ya trae el contenedor). Unos 543 MB.
# URL y SHA-256 copiados de la página de la versión Ghidra_12.1.4_build en GitHub.
URL_GHIDRA="https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_12.1.4_build/ghidra_12.1.4_PUBLIC_20260921.zip"
SHA_GHIDRA="ddac49f903da9d5bac833e5cc79395098b9c33cfd3279be5f31bd00387d2d4db"
# jadx-headless-mcp 0.7.1: URL y SHA-256 copiados de REA 6.7.0 (dist/android/JadxRelease.js).
URL_JADX_MCP="https://github.com/1013503897/jadx-headless-mcp/releases/download/v0.7.1/jadx-headless-mcp-0.7.1-all.jar"
SHA_JADX_MCP="6e5eacf500b64292bfb73c49797c1958f6ee44646e43e868039ae7feb573ff75"

AVISOS=""
aviso() {
  echo "[rea-entorno] AVISO: $1"
  AVISOS="${AVISOS}\n  - $1"
}
info() {
  echo "[rea-entorno] $1"
}
# Devuelve 0 si el fichero $1 tiene la suma SHA-256 $2
suma_correcta() {
  SUMA_LEIDA="$(sha256sum "$1" | cut -d ' ' -f 1)"
  [ "${SUMA_LEIDA}" = "$2" ]
}

# ---- 1. Paquetes del sistema: JDK 17, Pillow, unzip ----
if [ ! -x /usr/lib/jvm/java-17-openjdk-amd64/bin/javac ] || ! python3 -c "import PIL" 2>/dev/null; then
  info "Instalando JDK 17, Pillow y unzip con apt..."
  if ! apt-get update -q >/tmp/rea-apt.log 2>&1 || ! apt-get install -y -q openjdk-17-jdk-headless python3-pil unzip >>/tmp/rea-apt.log 2>&1; then
    aviso "apt no pudo instalar openjdk-17-jdk-headless / python3-pil / unzip (ver /tmp/rea-apt.log)"
  fi
else
  info "JDK 17 y Pillow ya estaban."
fi
JDK17="/usr/lib/jvm/java-17-openjdk-amd64"

# ---- 2. Gradle 8.10.2 (los proyectos traen gradlew; esto es por si falta el wrapper) ----
if [ ! -x "${DIR_GRADLE}/bin/gradle" ]; then
  info "Descargando Gradle ${VERSION_GRADLE}..."
  if curl -fsSL --max-time 300 -o /tmp/gradle.zip "https://services.gradle.org/distributions/gradle-${VERSION_GRADLE}-bin.zip"; then
    unzip -q -o /tmp/gradle.zip -d /opt && rm -f /tmp/gradle.zip
  else
    aviso "no se pudo descargar Gradle ${VERSION_GRADLE} (host services.gradle.org)"
  fi
else
  info "Gradle ${VERSION_GRADLE} ya estaba."
fi

# ---- 3. Android SDK (necesita el host dl.google.com permitido en la red del entorno) ----
SDKMANAGER="${DIR_SDK}/cmdline-tools/latest/bin/sdkmanager"
if [ ! -x "${SDKMANAGER}" ]; then
  info "Descargando cmdline-tools de Android..."
  if curl -fsSL --max-time 300 -o /tmp/cmdline-tools.zip "${URL_ANDROID_CMDLINE}"; then
    # El zip trae una carpeta "cmdline-tools" que sdkmanager quiere en cmdline-tools/latest
    rm -rf /tmp/cmdline-tools-extraido
    mkdir -p /tmp/cmdline-tools-extraido "${DIR_SDK}/cmdline-tools"
    unzip -q -o /tmp/cmdline-tools.zip -d /tmp/cmdline-tools-extraido
    rm -rf "${DIR_SDK}/cmdline-tools/latest"
    mv /tmp/cmdline-tools-extraido/cmdline-tools "${DIR_SDK}/cmdline-tools/latest"
    rm -rf /tmp/cmdline-tools.zip /tmp/cmdline-tools-extraido
  else
    aviso "no se pudo descargar el Android SDK: hay que permitir el host dl.google.com en la red del entorno"
  fi
fi
if [ -x "${SDKMANAGER}" ]; then
  if [ ! -d "${DIR_SDK}/platforms/android-35" ] || [ ! -d "${DIR_SDK}/build-tools/35.0.0" ]; then
    info "Instalando paquetes del SDK: ${SDK_PAQUETES}"
    # Las licencias del SDK son las mismas que acepta Android Studio al instalarlo
    yes | JAVA_HOME="${JDK17}" "${SDKMANAGER}" --sdk_root="${DIR_SDK}" --licenses >/tmp/rea-sdk.log 2>&1
    # shellcheck disable=SC2086
    if ! JAVA_HOME="${JDK17}" "${SDKMANAGER}" --sdk_root="${DIR_SDK}" ${SDK_PAQUETES} >>/tmp/rea-sdk.log 2>&1; then
      aviso "sdkmanager no pudo instalar ${SDK_PAQUETES} (ver /tmp/rea-sdk.log)"
    fi
  else
    info "Android SDK 35 ya estaba."
  fi
fi

# ---- 4. REA 6.7.0 (servidor MCP; el repo lo registra en .mcp.json) ----
if [ "$(rea --version 2>/dev/null)" != "${VERSION_REA}" ]; then
  info "Instalando rea-agents@${VERSION_REA}..."
  if ! npm install -g --no-audit --no-fund "rea-agents@${VERSION_REA}" >/tmp/rea-npm.log 2>&1; then
    aviso "npm no pudo instalar rea-agents@${VERSION_REA} (ver /tmp/rea-npm.log)"
  fi
else
  info "REA ${VERSION_REA} ya estaba."
fi

# ---- 5. Ghidra y JADX (opcionales: necesitan su URL y los hosts de GitHub permitidos) ----
mkdir -p "${DIR_HERRAMIENTAS}"
if [ "${URL_GHIDRA}" != "" ]; then
  if ! ls -d "${DIR_HERRAMIENTAS}"/ghidra_* >/dev/null 2>&1; then
    info "Descargando Ghidra (unos 543 MB)..."
    if curl -fsSL --max-time 1200 -o /tmp/ghidra.zip "${URL_GHIDRA}"; then
      if suma_correcta /tmp/ghidra.zip "${SHA_GHIDRA}"; then
        unzip -q -o /tmp/ghidra.zip -d "${DIR_HERRAMIENTAS}"
      else
        aviso "el zip de Ghidra no tiene la suma SHA-256 esperada: no se instala"
      fi
      rm -f /tmp/ghidra.zip
    else
      rm -f /tmp/ghidra.zip
      aviso "no se pudo descargar Ghidra (hay que permitir github.com y release-assets.githubusercontent.com)"
    fi
  fi
else
  aviso "Ghidra sin instalar: falta URL_GHIDRA en el script"
fi
if [ "${URL_JADX_MCP}" != "" ]; then
  if [ ! -f "${DIR_HERRAMIENTAS}/jadx-headless-mcp-0.7.1-all.jar" ]; then
    info "Descargando jadx-headless-mcp 0.7.1..."
    if curl -fsSL --max-time 300 -o /tmp/jadx-headless-mcp.jar "${URL_JADX_MCP}"; then
      if suma_correcta /tmp/jadx-headless-mcp.jar "${SHA_JADX_MCP}"; then
        mv /tmp/jadx-headless-mcp.jar "${DIR_HERRAMIENTAS}/jadx-headless-mcp-0.7.1-all.jar"
      else
        aviso "el jar de jadx-headless-mcp no tiene la suma SHA-256 esperada: no se instala"
      fi
    else
      aviso "no se pudo descargar jadx-headless-mcp (hay que permitir github.com y release-assets.githubusercontent.com)"
    fi
    rm -f /tmp/jadx-headless-mcp.jar
  fi
else
  aviso "JADX sin instalar: falta URL_JADX_MCP en el script"
fi

# ---- 6. Variables de entorno para todas las shells ----
{
  echo "# Generado por nube/instalar-entorno.sh (proyecto REA)"
  echo "export JAVA_HOME_17=\"${JDK17}\""
  if [ -d "${DIR_SDK}/platforms" ]; then
    echo "export ANDROID_HOME=\"${DIR_SDK}\""
    echo "export ANDROID_SDK_ROOT=\"${DIR_SDK}\""
  fi
  if [ -x "${DIR_GRADLE}/bin/gradle" ]; then
    echo "export GRADLE_8_10=\"${DIR_GRADLE}/bin/gradle\""
  fi
  for DIR_GHIDRA in "${DIR_HERRAMIENTAS}"/ghidra_*; do
    if [ -d "${DIR_GHIDRA}" ]; then
      echo "export GHIDRA_INSTALL_DIR=\"${DIR_GHIDRA}\""
    fi
  done
  if [ -f "${DIR_HERRAMIENTAS}/jadx-headless-mcp-0.7.1-all.jar" ]; then
    echo "export REA_JADX_MCP_JAR=\"${DIR_HERRAMIENTAS}/jadx-headless-mcp-0.7.1-all.jar\""
  fi
} > "${FICHERO_PERFIL}"
# Las shells no interactivas de Claude leen ~/.bashrc, no /etc/profile.d
if ! grep -q "rea-entorno.sh" "${HOME}/.bashrc" 2>/dev/null; then
  echo "[ -f ${FICHERO_PERFIL} ] && . ${FICHERO_PERFIL}" >> "${HOME}/.bashrc"
fi

# ---- Resumen ----
info "Terminado. Variables en ${FICHERO_PERFIL}"
if [ "${AVISOS}" != "" ]; then
  echo -e "[rea-entorno] Quedó pendiente:${AVISOS}"
fi
exit 0
