# Proyecto REA: instrucciones para Claude en la nube

Lo que hay que saber en cada sesión. El contexto completo (aparatos, red, historia de cada
subproyecto y decisiones ya tomadas) está en [docs/RESUMEN-PROYECTO-REA.md](docs/RESUMEN-PROYECTO-REA.md):
**léelo antes de tocar un subproyecto** y no vuelvas a discutir lo que ya está decidido allí.

## Qué es

Proyecto personal para aprender **desarrollo de aplicaciones** y cómo se comunican los sistemas
(app ↔ servicio, proceso ↔ proceso, aparato ↔ PC), reutilizando aparatos viejos de casa. Nació como
ingeniería inversa con [REA](https://github.com/morluto/rea) y hoy son varios subproyectos propios:
`reloj-metricas`, `tab2-nura`, `jarvis`, `red-casa`, `migo-caldera`, `tagus-*` y `analisis`.

## Dónde está cada cosa

- La copia de verdad está en el PC del usuario, en `C:\REA\`. Este repo es una copia **solo de
  fuentes** que el usuario sube con `pc\preparar-copia-fuentes.bat`. Cada carpeta del repo
  corresponde a la misma carpeta de `C:\REA\` (`tab2-nura/agenda/agenda.py` ↔
  `C:\REA\tab2-nura\agenda\agenda.py`).
- Si una carpeta todavía no está en el repo, **pide al usuario que la suba**. No reconstruyas un
  fichero de memoria ni a partir del resumen.
- Nunca entran en el repo: APK, claves (`openrouter.key`, llaves SSH, keystores), copias de los
  móviles, backups, bases de datos, fotos, vídeos, libros ni modelos `.onnx`. El `.gitignore` lo
  impide; si ves algo así, no lo subas y avisa.

## Límites de la nube (importante)

- **No llegas a la red de casa ni a los aparatos**: nada de `ssh`, `adb`, `192.168.0.x` ni las IP
  de Tailscale `100.x`. Lo que haya que ejecutar allí, entrégaselo al usuario.
- **Entrega**: el usuario copia a mano los ficheros a `C:\REA\`. Al terminar cada tarea, deja los
  cambios en el repo y da una lista de **qué fichero del repo va a qué ruta de `C:\REA\`**, más los
  comandos para compilar, instalar o desplegar.
- Los comandos para el PC van en un **`.bat`** que se abre en su propia ventana `cmd` (no usa el
  panel Terminal) o en **PowerShell 5.1** (sin `&&`, sin `?:`, sin `??`). Los `.bat` con
  finales de línea CRLF (lo fuerza `.gitattributes`) y sin tildes en los `echo`, o con `chcp 65001`.

## Cómo trabaja el usuario

- Todo en **español**; nombres de ficheros, clases, funciones y variables también en español
  (`Detector.kt`, `agenda.py`, `instalar.sh`).
- **Explica el porqué**, no solo el código: el objetivo es aprender.
- En los análisis, cada afirmación lleva **[Observado]** (está en el artefacto), **[Inferido]**
  (conclusión razonable) o **[Desconocido]** (pregunta abierta).
- Para acciones físicas (botones, cables, modos de arranque) da una **guía paso a paso muy
  detallada**.
- Las opciones que se usan poco van en una pantalla de **Configuración**, no en la principal.
- **Nunca** crees cuentas ni escribas contraseñas o claves por él: las mete él, con un script de
  entrada oculta si hace falta (como `guardar-clave-openrouter.bat`).
- **No hagas pruebas en la tele Samsung sin preguntar** (puede estar viéndola la familia).

## Reglas del análisis de apps ajenas

Solo software propio o que se puede examinar, con fines de aprendizaje. Las apps comerciales se
analizan de forma **estática**: sin ejecutarlas, sin interceptar su tráfico y sin saltar
protecciones. No copies claves ni credenciales que aparezcan dentro de una APK.

## Restricciones técnicas por destino

**Apps Android** (reloj, móvil, Jarvis, `escaner-bt`):
- Receta probada: **AGP 8.7.3 + Kotlin 2.0.21 + Gradle 8.10.2**, compileSdk 35, JDK 17.
- El usuario compila con `--offline`: **no añadas dependencias** que no estén ya en los
  `build.gradle(.kts)` del proyecto. Si una tarea la necesita, pregunta antes.
- En el PC se compila así:
  ```powershell
  $env:JAVA_HOME = "$env:USERPROFILE\Android\jdk17"; $env:ANDROID_HOME = "$env:USERPROFILE\Android\sdk"; .\gradlew.bat assembleDebug
  ```
- Excepción: `tagus-keepawake` se compila con su `build.sh`, sin Gradle (Android 4.4).

**Tablet `tab2-nura`** (Nura/postmarketOS, ARMv7 32 bits, ~800 MB de RAM, sin `curl`):
- Python con la **biblioteca estándar** (Pillow ya está instalado). Unidades systemd endurecidas
  (`DynamicUser`, `ProtectSystem=strict`). Instaladores idempotentes.
- **No recargar nftables** (borra las tablas de Tailscale): reglas en caliente con
  `nft add rule` y el `.nft` en `/etc/nftables.d/`.
- `pkill -f` por SSH puede matarse a sí mismo: patrones anclados (`^feh`).
- `xset s`/`dpms` reinician la cuenta de inactividad: envíalos solo si cambian.
- **No quitar `guardian-bateria.timer`.** La tablet vive del USB del router: unas 4 h al día de
  pantalla como mucho. Vigila el consumo antes de añadir servicios.

**Puertos ocupados**: 8765 en el PC (otra herramienta, **no tocar**), 8787 receptor del reloj,
8770 puente de la Samsung; en la tablet 80/8080 portal "Casa" y 8081 agenda.

**Scripts del PC** (`analisis/herramientas`, `red-casa`): Python solo con biblioteca estándar.

## Qué hay en este contenedor

Lo prepara `nube/instalar-entorno.sh` (es el *Setup script* del entorno; si algo falta, se puede
lanzar a mano con `bash nube/instalar-entorno.sh`). Las variables quedan en
`/etc/profile.d/rea-entorno.sh`.

| Herramienta | Estado | Uso |
|---|---|---|
| Python 3 + Pillow | instalado | probar scripts de la tablet y del PC (`python3 -m unittest`, `py_compile`) |
| JDK 17 (`$JAVA_HOME_17`) y JDK 21 | instalados | Android usa el 17 |
| Gradle 8.10.2 (`$GRADLE_8_10`) | instalado | por si un proyecto no trae `gradlew` |
| Android SDK 35 (`$ANDROID_HOME`) y AGP | **solo si la red permite `dl.google.com`** | `JAVA_HOME=$JAVA_HOME_17 ./gradlew assembleDebug` |
| REA 6.7.0 (MCP en `.mcp.json`, skill en `.claude/skills/`) | instalado | análisis estático de artefactos que suba el usuario |
| Ghidra y JADX | **sin instalar** (faltan sus URL en el script y los hosts de GitHub) | REA nativo y Android |

Antes de dar algo por bueno, compílalo o pruébalo aquí si se puede, y di claramente lo que no se
ha podido probar (todo lo que dependa de un aparato real).
