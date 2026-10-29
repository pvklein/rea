# Proyecto REA: resumen completo para continuar en otra sesión de Claude

Fecha del resumen: **2026-10-29**. Escrito para pasárselo a Claude en la nube, que **no tiene acceso
a mi PC, a mi red de casa ni a mis aparatos**. Todo lo que aparece aquí como ruta (`C:\REA\…`) o
IP (`192.168.0.x`) existe solo en mi equipo. Si una tarea necesita ejecutar algo en local, dame
los comandos o los ficheros y los lanzo yo.

---

## 1. Qué es el proyecto y cómo trabajo

**Objetivo:** aprender **desarrollo de aplicaciones** y la **interrelación entre sistemas**
(cómo hablan una app y sus servicios, un proceso con otro, un aparato con el PC…). Empezó como
ingeniería inversa con [REA](https://github.com/morluto/rea) (*Reverse Engineer Anything*, MIT,
servidor MCP que conecta Claude con Ghidra, JADX, adb…) y ha derivado en construir mis propias
herramientas reutilizando aparatos viejos de casa.

Principios:

- Solo software propio o que puedo examinar, con fines de aprendizaje. Los análisis de apps
  comerciales son **estáticos**: sin ejecutar, sin interceptar tráfico y sin saltar protecciones.
  No copio claves ni credenciales que aparezcan dentro de las APK.
- En los análisis cada afirmación lleva **[Observado]** (está en el artefacto), **[Inferido]**
  (conclusión razonable) o **[Desconocido]** (pregunta abierta).
- Las **explicaciones importan tanto como el código**: quiero entender el porqué.

Preferencias:

- Todo en **español**, con nombres de código, ficheros y variables en español (`Detector.kt`,
  `agenda.py`, `instalar.sh`…).
- Para acciones físicas (botones, cables, modos de arranque) quiero una **guía paso a paso muy
  detallada**.
- No uso el panel Terminal de la app de Claude: prefiero un **`.bat`** que se abra en su propia
  ventana `cmd`.
- Las opciones que se usan poco van en una pantalla de **Configuración**, no en la principal.
- **Nunca** crear cuentas ni teclear contraseñas o claves por mí: las meto yo (con scripts de
  entrada oculta si hace falta).
- No hacer pruebas en la tele Samsung sin preguntar: puede estar viéndola la familia.

---

## 2. Entorno del PC

Windows 11 Pro x64, nombre **JCAV**, Wi‑Fi en 192.168.0.15 (adaptador USB TP‑Link, a través del
repetidor).

| Componente | Versión / ruta |
|---|---|
| REA (`rea-agents`, npm) | 6.7.0; registrado como MCP en Claude Code y Claude Desktop con la skill `reverse-engineer-anything` |
| Node.js / npm | 26.8.1 / 11.7.0 |
| Ghidra | 12.1.4 en `C:\tools\ghidra_12.1.4_PUBLIC` (soporte Windows experimental, solo lectura) |
| JDK del sistema | Temurin 21 (`JAVA_HOME`, para Ghidra y JADX) |
| JADX | `C:\tools\jadx-headless-mcp-0.7.1-all.jar` |
| adb | platform-tools 37.0.1 en el PATH (también en `C:\Users\javie\Android\sdk\platform-tools`) |
| Python | con la biblioteca estándar; los scripts del proyecto evitan dependencias externas |
| Adobe Digital Editions | 4.5.12 (para préstamos de bibliotecas) |

**Toolchain Android (fuera de la ruta estándar, sin `ANDROID_HOME`):**

- SDK `C:\Users\javie\Android\sdk` (android-35, build-tools 34/35), JDK 17
  `C:\Users\javie\Android\jdk17`, Gradle 8.10.2 `C:\Users\javie\Android\gradle-8.10.2`.
- En caché: AGP 8.7.3 / 9.0.0 / 9.4.1 y Kotlin 2.0.21 / 2.2.10 / 2.4.21. Sin conexión hay que
  usar esas versiones (receta probada: **AGP 8.7.3 + Kotlin 2.0.21 + Gradle 8.10.2**).
- Compilar:
  ```powershell
  $env:JAVA_HOME = "$env:USERPROFILE\Android\jdk17"; $env:ANDROID_HOME = "$env:USERPROFILE\Android\sdk"; .\gradlew.bat assembleDebug
  ```

**Puertos:** el **8765** del PC lo usa otra herramienta mía (`pythonw`, pide cabecera `X-Clave`):
no tocarlo. El receptor del reloj usa el 8787 y el puente de la Samsung el 8770.

---

## 3. Mapa de carpetas (`C:\REA`)

| Carpeta | Qué hay |
|---|---|
| `HERRAMIENTAS-Y-REA.md` | Qué es REA, qué está instalado y qué permite analizar |
| `analisis\` | Análisis con REA de Flashscore, eBiblio y Health, más `herramientas\` (scripts Python propios: `axml.py`, `arsc.py`, `dex_strings.py`, `dex_xref.py`, `dex_urls.py`, `elf_exports.py`…) |
| `apks\` | APK extraídas del Pixel 9a: flashscore 26.10.2, ebiblio 1.12.3, health 5.10.1, migo 2.4.3.0 |
| `reloj-metricas\` | App propia para el Pixel Watch 2 + app del móvil + receptor en el PC |
| `tab2-nura\` | Tablet Galaxy Tab 2 convertida en servidor casero: panel, marco de fotos, agenda, Wi‑Fi, pantalla, scripts, backups |
| `jarvis\` | Asistente de voz en un Huawei viejo (app Android + descargas de sherpa-onnx) |
| `red-casa\` | Escáner de la LAN, notas de las dos teles y la extensión "Enviar a la Samsung" |
| `migo-caldera\` | Diagnóstico (resuelto) del termostato de la caldera y la app `escaner-bt` |
| `tagus-keepawake\`, `tagus-prestamos\`, `tagus-backup\` | E‑reader Tagus Gaia: app contra los cuelgues y script para pasar préstamos |
| `copia-galaxy-a10\`, `copia-huawei-p8lite\` | Copias de fotos/WhatsApp de dos móviles antes de reutilizarlos |

---

## 4. Aparatos y red de casa

Red `REDWIFI_ksGs`, 192.168.0.0/24, DHCP (las IP pueden cambiar: volver a escanear antes de fiarse).

| IP | Aparato | Notas |
|---|---|---|
| .1 | Router de fibra ZTE ZXHN F6600P | Puerta de enlace y DNS. La tablet vive enchufada a su USB |
| .10 | SolaX Pocket WiFi | Registrador del inversor de las placas solares |
| .13 | Repetidor TP‑Link | El PC sale por él (2,4 GHz, canal 8) |
| .15 | PC "JCAV" | |
| .17 | Nintendo Switch | |
| .23 | Tele Xiaomi Mi LED TV 4A 32" | Android TV 9, ADB por red activado (`adb connect 192.168.0.23:5555`) |
| .25 (variable) | Huawei PRA‑LX1 "Jarvis" / Android con MAC privada | |
| .26 (cuando aparece) | Pixel Watch 2 | Suele hablar por Bluetooth con el móvil |
| .41 | Unidad de comunicación MiGo (caldera) | Wi‑Fi débil |
| .45 | Tele Samsung UE40ES6100 (2012) | Por cable, solo DLNA |
| .46 | Sagemcom sin identificar | ¿decodificador? |
| **.102** (antes .31) | Tablet "tab2-nura" | Servidor casero |

**Tailscale** (para llegar desde fuera sin abrir puertos): tab2-nura = 100.122.91.54,
pixel-9a = 100.86.251.82.

Móvil principal: **Pixel 9a** (Android 17, adb `62121JEBF09503`). Reloj: **Pixel Watch 2**
("aurora", Wear OS, Android 17 / API 37).

---

## 5. Subproyectos

### 5.1 Análisis de apps con REA (2026-10-21 a 23)

Tres análisis estáticos con REA + JADX, cada uno con su `README.md` muy detallado en
`analisis\<app>\`.

- **Flashscore 26.10.2** (`eu.livesport.FlashScore_com`). Split APK, 36 107 clases, 69 % ofuscadas
  con R8. Red: Ktor sobre OkHttp (Cronet solo lo usa el SDK de anuncios); URLs compiladas en
  recursos con plantillas; protocolo propio de "feeds" de texto con separadores `¬ ÷ ~` y un
  diccionario de claves conservado, refresco en directo `u_`/`r_` (sondeo cada ~5 s) y GraphQL con
  *persisted queries*. Una sola base de código genera +50 apps por país. Aprendido: el manifiesto
  es el mapa de la app; una app comercial es sobre todo SDKs (anuncios, analítica, consentimiento);
  lo que sobrevive a la ofuscación son las cadenas y los tipos de librerías públicas.
- **eBiblio 1.12.3** (`com.demarque.ebiblio`, préstamo de las bibliotecas públicas). Código de De
  Marque sin ofuscar, Readium Kotlin Toolkit, DRM **Readium LCP** (`liblcp.so`, 5 métodos JNI de
  `org.readium.lcp.sdk.Lcp` con enlace estático por nombre, visto con Ghidra), PSPDFKit, Room
  (`cantook.db`), `WatchLoanWorker` cada 6 h. Usa estándares abiertos (OPDS, OPDS Authentication).
  Marca blanca por `config.json` en tiempo de ejecución. Sin publicidad.
- **Health 5.10.1** (antes Fitbit, `com.fitbit.FitbitMobile`). Conclusión clave: **el reloj no le
  pasa las métricas al móvil**; la app Fitbit del reloj las sube ella misma a la nube y el móvil
  solo le delega el login (capability `auth:1.x`) y le pide "sincroniza ya"
  (`/sync/v1/request`) por la Data Layer ("Cronus"). La Data Layer solo entrega mensajes entre apps
  con **el mismo paquete y la misma firma**. Vías válidas para mis datos: una app propia en el reloj
  (Wear Health Services) o la **Google Health API** (`health.googleapis.com/v4`; la API web de
  Fitbit se apaga el **2026-11-02**).

Preguntas abiertas que quedaron: prefijos de feed restantes de Flashscore, sus librerías nativas
arm64, registro de push; contenido del registro OPDS de eBiblio; qué token delega Health al reloj.

### 5.2 `reloj-metricas`: mis métricas del Pixel Watch 2 (2026-10-23/24)

App propia **`es.rea.metricas`** en el reloj (Health Services) que manda los datos al PC y al
móvil, sin la app Health ni la nube.

```
Reloj (Sensores.kt: medir / sesión / pasivo) ──WebSocket JSON──► PC receptor.py :8787 (SQLite, panel.html, metricas.py)
        │
        └── Data Layer de Wear OS (Bluetooth) ──► Pixel 9a: app es.rea.metricas (mismo paquete y firma)
```

- Mensajes JSON (`hola`, `dato`, `estado`, `evento`); órdenes `medir_on/off`, `sesion_on/off`…
  Data Layer: `/metricas/dato`, `/metricas/orden`, `/metricas/ack`; capabilities
  `metricas_reloj` / `metricas_movil`.
- **Buzón en disco** con número de secuencia y confirmaciones tras escritura duradera (descarte de
  repetidos, 7 días de retención): probado cortando el PC y matando la app, 78/78 sin huecos.
- PC: `metricas.py` calcula zonas, TRIMP, cadencia. Móvil: el mismo análisis en Kotlin, panel
  nativo con gráfica, CSV y pantalla ⚙ Configuración.
- **Modo noche** (para enseñar al médico unos despertares bruscos con taquicardia): el móvil graba
  audio+vídeo en tramos de ~1 min (`MediaRecorder.setNextOutputFile`) y solo conserva los que
  rodean a un episodio (3 min antes, 2 después); el reloj detecta FC ≥ mediana de 5 min + 20 lpm,
  movimiento ≥ umbral (por defecto 9 m/s²) o el botón "¡Me ha pasado!". Sobrevive a que otra app
  le quite la cámara. Ahorro de batería: sin wakelock, acelerómetro *wake-up* agrupado 10 s.
  Primera noche real (24‑10): ~4 %/h de batería del reloj, dos subidas de FC sin movimiento.
- Conexión: depuración inalámbrica del reloj; `reloj.ps1` encuentra el puerto por
  `adb mdns services` (en este PC hace falta `ADB_MDNS_OPENSCREEN=1`).
- Limitaciones: FC en vivo solo con la app en pantalla; sin VFC, sueño ni SpO2 (no los expone
  Health Services).
- Pendiente: revisar umbrales del modo noche tras más noches reales; explorar sensores crudos
  (PPG, ECG, GSR, temperatura).

### 5.3 `tab2-nura`: la tablet como servidor casero (desde 2026-10-24)

**Galaxy Tab 2 10.1 Wi‑Fi (GT‑P5110, "espresso10")** reflasheada con **Nura** (nuevo nombre de
postmarketOS desde sep‑2026) v26.06, kernel mainline 7.0.5, systemd, XFCE, ARMv7 32 bits, ~800 MB
de RAM, sin aceleración gráfica. Idea: un "VPS" en casa sin IP fija → Tailscale.

**Acceso:** `ssh -o HostKeyAlias=192.168.0.31 -i ~/.ssh/tab2_nura_ed25519 user@192.168.0.102`
(o `user@172.16.42.1` por la red USB). Solo llave, sudo sin contraseña (sudo‑rs). Sin `curl`.
Particiones: KERNEL = boot.img de Nura, RECOVERY = TWRP 3.4.0, sistema en DATAFS (se escribió desde
TWRP por adb en trozos de 256 MB porque Heimdall falla con imágenes grandes).

**Energía (la gran restricción):** sin driver de cargador; el cargador de pared **no carga** en
Nura. Vive en el USB del router: ≈ +240 mA con pantalla apagada, ≈ −1,15 A encendida →
presupuesto de **~4 h/día de pantalla** como mucho. Si llega a 0 % entra en bucle de reinicios
(hay que abrirla), así que `guardian-bateria.timer` la apaga al 15 % (no quitarlo). Batería real
~5 240 mAh de 7 000.

Servicios montados (fuentes e instaladores idempotentes en `C:\REA\tab2-nura\…`):

| Servicio | Qué hace |
|---|---|
| **Portal "Casa"** (`panel\`, `panel.py` solo stdlib) | Puertos **80** y 8080. `/` = **Hoy** (agenda del día + avisos solo cuando tocan: batería baja, agenda caída), `/calendario/` (pasa al 8081), `/administracion/` (estado: batería, servicios, eventos). Menú común `menu.js` con lista `SECCIONES`; responsive |
| **Agenda familiar** (`agenda\`) | `agenda.py` + SQLite en el **8081**. Web, citas con repetición semanal/mensual/anual, y `/herramientas` (funciones en formato *tools* para Jarvis: `consultar_agenda`, `buscar_citas`, `apuntar_cita`, `cambiar_cita`, `borrar_cita`, `mostrar_agenda`). Puede pintar la agenda en la pantalla 2 min (`dibujo.py` con Pillow) |
| **Marco de fotos** (`marco\`) | Usuario `marco` con auto‑login y feh; modo **a demanda** (un toque enciende 180 s, toque = siguiente foto); horario/batería en `/etc/marco.conf`. El PC manda fotos con `enviar-fotos.bat` |
| `vigilante-wifi.timer` (`wifi\`) | Recupera el BCM4330 (brcmfmac) cuando se cuelga |
| Pantalla (`pantalla\`) | Gancho de boot‑deploy que parchea el dtb con `pclk-sample = <1>` (arregló contornos de colores del conversor LVDS) |

Lecciones técnicas: el cortafuegos (nftables) es *drop* por defecto: **no recargar nftables**
(borra las tablas de Tailscale); añadir reglas en caliente con `nft add rule` y dejar el `.nft` en
`/etc/nftables.d/`. La retroiluminación es todo o nada (el brillo bajo por PWM se descartó tras
probarlo a fondo). `xset s`/`dpms` reinician la cuenta de inactividad: enviarlos solo si cambian.
`pkill -f` por SSH puede matarse a sí mismo: usar patrones anclados (`^feh`).

Siguientes ideas: más secciones y avisos en la portada (ampliar `hoy()` en `panel.py`), más
funciones para Jarvis. Vigilar el consumo antes de añadir servicios pesados.

### 5.4 `jarvis`: asistente de voz propio (desde 2026-10-25/27)

Objetivo: decir la palabra → pitido → escucha → un modelo de **OpenRouter** decide si ejecuta una
función de un aparato de casa o contesta. Objetivo de latencia: 1,5–3 s desde que acabo de hablar.

**Arquitectura decidida:** el **móvil es el cerebro** y **cada aparato publica sus funciones**
(manifiesto HTTP `GET :8081/herramientas`); así añadir funciones no exige reinstalar la app.
Modelo, instrucciones y aparatos en configuración, no en código.

**Aparato:** Huawei P8/P9 Lite 2017 (**PRA‑LX1**), Android 8.0 EMUI 8, arm64, 2,8 GB, sin cuentas,
adb `9DC7N17911003105`. La tablet no sirve de "oído" (sin sonido en Nura).

**Palabra de activación:** Porcupine descartado (sin plan personal desde 30‑03‑2026). Se usa
**sherpa-onnx keyword spotting** 1.13.8 (Apache 2.0, local), modelo inglés
`kws-zipformer-gigaspeech-3.3M`. "Jarvis" no se detectaba (0 de N con varias segmentaciones BPE);
**"Alexa" sí (3/3) → se usa "Alexa"** (`keywords.txt`: `▁A LE X A @ALEXA`). Un "Jarvis" propio
requeriría entrenar un modelo.

**App** `es.rea.jarvis` en `C:\REA\jarvis\app-android\` (Kotlin, minSdk 26):

| Pieza | Qué hace |
|---|---|
| `Detector.kt` | AudioRecord 16 kHz + KWS; suelta el micro antes de avisar |
| `AsistenteService.kt` | Servicio en primer plano (micrófono) + wakelock: pitido → `SpeechRecognizer` de Google es‑ES → atajos locales o modelo → TTS |
| `OpenRouter.kt` | Llamada en *streaming*, `provider.sort=latency`, hasta 4 vueltas de *tool calling*; abre la conexión por adelantado al oír la palabra |
| `Frases.kt` | Dice la respuesta frase a frase |
| `Conversacion.kt` | Recuerda 4 turnos durante 3 min (incluidas llamadas a funciones y resultados), añade fecha y hora |
| `Respuestas.kt` | Atajos sin modelo (p. ej. «muéstrame qué tengo hoy» → `mostrar_agenda`) y despedidas |
| `Aparatos.kt` | Descubre los aparatos (barrido de la /24, ~3 s), los guarda y refresca cada 10 min; ejecuta funciones con POST; copia diaria de la agenda (14 últimas) |
| `Configuracion.kt` | `config.json` en `/sdcard/Android/data/es.rea.jarvis/files/`: `umbral`, `refuerzo`, `idioma`, `modelo` (por defecto `google/gemini-3.1-flash-lite`), `razonamiento` ("minimal"), `instrucciones`, `voz` (`es-es-x-eed-local`), `seguimiento` (6 s), `aparatos` |
| `OrdenReceiver.kt` | Pruebas sin hablar, solo desde adb (permiso DUMP): `adb shell am broadcast -n es.rea.jarvis/.OrdenReceiver -a es.rea.jarvis.ORDEN --es texto "'pregunta'"` |
| `MainActivity.kt`, `ArranqueReceiver.kt` | Iniciar/Parar, "Que no lo cierre", registro en vivo; arranque al encender |

- **Modo conversación:** tras responder, pitido suave y escucha sin palabra (máx. 6 seguidas).
  "gracias", "nada", "adiós"… cierran. Como recogía conversaciones de la habitación: >25 palabras
  se descarta; si no, el modelo puede contestar `SILENCIO` y Jarvis se calla.
- **Clave de OpenRouter:** la guardo yo con `guardar-clave-openrouter.bat` (entrada oculta → adb →
  `files/openrouter.key`, privado). Límite de gasto 3 $/mes.
- **Medidas:** palabra → listo 0,4–0,7 s; orden → empieza a hablar 1,1–1,7 s sin funciones;
  con modelo + función 2,3–3,3 s y ~0,0007 $/orden; atajo local 1,3 s. Pregunta simple
  ~0,00005–0,00008 $.
- **Estabilidad:** excluida del ahorro de batería; 1 h con pantalla apagada y enchufado sin
  reinicios.
- **Pendiente:** poner "Inicio de aplicaciones" de Huawei en manual; probar una noche entera y solo
  con batería; latido del móvil al panel de la tablet para avisar si Jarvis se cae; más funciones
  publicadas por los aparatos; quizá entrenar el "Jarvis" propio.

### 5.5 `red-casa`: escáner, teles y "Enviar a la Samsung" (2026-10-24)

- `escaner.py` (solo stdlib): ping + ARP, mDNS, SSDP, ~50 puertos TCP y cabeceras web. Deja un
  JSON en `resultados\`. No inicia sesión en nada.
- **Tele Xiaomi** (MStar, 1,5 GB RAM, muy justa): ADB activado; animaciones a 0,5x y 13 apps
  desactivadas (telemetría, Play Música/Juegos/Películas, PatchWall, YouTube…; lista en
  `tv-xiaomi\apps-desactivadas.txt`), salvapantallas sencillo. Se dejaron Prime, DAZN, Mitele,
  RTVE, Disney+ y Mi TV+.
- **Tele Samsung UE40ES6100** (2012, Orsay): UPnP/DLNA (MainTVAgent2, AVTransport,
  RenderingControl), mando antiguo 55000.
- **"Enviar a la Samsung"**: extensión de Chrome MV3 + puente Python (puerto 8770) que pide el
  vídeo a la web (con cookies/Referer) y se lo sirve a la tele por DLNA. Funciona con MP4/WebM/MKV
  directos, música y fotos; no con YouTube/Netflix/HLS/DASH. La tele solo decodifica **H.264 hasta
  nivel 4.1**: el puente lo comprueba antes. Saltar al segundo 0 la para (se usa 1 s).

### 5.6 `migo-caldera` (resuelto 2026-10-24)

Caldera Saunier Duval Thema Fast Condens 30‑B con kit **MiGo** (marca blanca de Netatmo). La app
configura la unidad por **Bluetooth clásico** (RFCOMM, reconoce el nombre "Heating Gateway").
Arreglo: poner la unidad en modo emparejamiento (botón superior hasta luz azul) para reenviar el
Wi‑Fi (había cambiado el router) y **pilas nuevas** en el termostato. Se hizo una app propia
`escaner-bt` (clásico + BLE + SDP, con botón "Marcar") para diagnosticar junto a la caldera.
Si vuelve a fallar: mirar primero si la MAC `70:EE:50:55:CB:02` está en la red y la cobertura
Wi‑Fi junto a la caldera (1 raya).

### 5.7 Tagus Gaia (e‑reader, 2026-10-25)

Tagus Gaia de Casa del Libro = Onyx `Tagus_PokeP`, RK3128, Android 4.4.4, sin root.

- **Se colgaba en reposo con batería.** Causa encontrada: en cada arranque el IRQ del RTC HYM8563
  da un *oops* y queda bloqueado, así que cualquier suspensión del kernel se cuelga; Onyx manda
  dormir el kernel 3 s después del último toque (con cargador no pasaba porque el cargador bloquea
  la suspensión).
- **Solución:** app propia `local.keepawake` ("Mantener despierto", `C:\REA\tagus-keepawake`,
  compilada con `build.sh` sin Gradle) que mantiene dos wakelocks parciales desde el arranque,
  saltando la lista negra de Onyx con `addToWakelockWhiteList` por reflexión. Apagado automático a
  30 min tras dormirla con el botón. Consumo alto (~230–340 mA despierta). Un arreglo definitivo
  pediría root o parchear kernel/DTB.
- **Préstamos de biblioteca:** eBiblio no funciona en Android 4.4. Vía: eBiblio → "Otros ereaders"
  (.acsm) → Adobe Digital Editions en el PC (ahora con **ByteBooks ID**, ya no Adobe ID) → copiar el
  epub al Tagus y abrirlo con Neo Reader. Como ADE no ve el Tagus (MTP), no le pasa el `loanToken`:
  `tagus-prestamos\Pasar préstamos al Tagus.cmd` reconstruye desde el registro de ADE los bloques
  `operatorURLList`, `loanToken` y `licenseServices`, los añade al `activation.xml` del Tagus
  (copia en `tagus-backup\`) y copia los libros que falten. Los .lcpl (LCP) no los lee el Tagus.

### 5.8 Otros

- **Disco Seagate M3 Portable:** fallo mecánico (no gira, pita cada ~2 s, errores en LBA 0).
  Caso cerrado: garantía o destruir los platos y tirarlo.
- **Móviles reutilizados:** copias hechas antes de restablecer. El Galaxy A10 se lo queda mi hija
  (Duolingo); el Huawei pasó a ser Jarvis. Un Galaxy Grand 2 modificado no arranca.

---

## 6. Pendientes, en resumen

| Proyecto | Siguiente paso |
|---|---|
| Jarvis | Inicio de apps de Huawei en manual; prueba de una noche y con batería; latido al panel; nuevas funciones en los aparatos |
| Tablet | Más secciones/avisos en la portada "Casa"; vigilar consumo y presupuesto de pantalla |
| Reloj | Ajustar umbrales del modo noche con más noches reales; sensores crudos |
| Análisis | Preguntas abiertas de Flashscore, eBiblio y Health (sección 5.1) |
| Health/Fitbit | Si quiero el histórico de la nube: Google Health API (la API de Fitbit muere el 2026-11-02) |

---

## 7. Cómo ayudarme desde la nube

- No puedes ejecutar nada en mi red: entrégame **código completo o parches** con la ruta exacta
  del fichero en `C:\REA\…` y los comandos para compilar/instalar (en `.bat` o PowerShell 5.1).
- Las apps Android usan Kotlin sin dependencias nuevas que no estén en caché (compilo con
  `--offline`); los servicios de la tablet, Python con biblioteca estándar (Pillow ya está) y
  unidades systemd endurecidas (`DynamicUser`, `ProtectSystem=strict`).
- Respeta el estilo: nombres en español, explicaciones de por qué, y separar lo observado de lo
  inferido.
