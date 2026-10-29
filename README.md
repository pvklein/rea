# REA en la nube

Copia de las **fuentes** de `C:\REA` para trabajar en el proyecto desde Claude Code en la nube
(móvil, web), aunque la nube no llegue a casa. El contexto completo está en
[docs/RESUMEN-PROYECTO-REA.md](docs/RESUMEN-PROYECTO-REA.md) y las reglas que sigue Claude en cada
sesión, en [CLAUDE.md](CLAUDE.md).

## Cómo funciona

```
C:\REA (PC, copia de verdad)
   │  pc\preparar-copia-fuentes.bat  →  REA-fuentes.zip  →  lo adjuntas en el chat
   ▼
pvklein/rea (este repo, solo fuentes)  ◄──►  Claude en la nube: lee, cambia, compila y prueba lo que puede
   │  Claude te dice qué fichero va a qué ruta
   ▼
C:\REA  (lo copias tú a mano y lanzas el .bat o comando que te dé)
```

¿Por qué así? La nube no puede entrar en tu PC ni en tu red, así que el repo hace de **buzón** entre
los dos lados. Solo viajan fuentes: las APK, claves, copias de móviles y bases de datos se quedan
en casa (lo filtran el `.bat` y el `.gitignore`).

## Puesta en marcha (una sola vez)

1. **Entorno en la nube** → menú del entorno en la barra de título de la sesión → *Edit*:
   - **Setup script**: pega el contenido de [`nube/instalar-entorno.sh`](nube/instalar-entorno.sh).
     Instala JDK 17, Gradle 8.10.2, Pillow, REA 6.7.0 y, si la red lo permite, el Android SDK 35.
   - **Network access**: añade **`dl.google.com`** en *Allowed domains* (dejando marcada la casilla
     de gestores de paquetes). Sin él no se puede compilar ninguna app Android en la nube: de ahí
     salen el SDK y el plugin de Android para Gradle. Pasos:
     <https://code.claude.com/docs/en/cloud-environments#network-access>
   - Opcional, para Ghidra y JADX en la nube: permite también `github.com` y
     `release-assets.githubusercontent.com`, y rellena `URL_GHIDRA` y `URL_JADX_MCP` en el script.
2. **Sube las fuentes**: en el PC, doble clic en `pc\preparar-copia-fuentes.bat` (descárgalo de
   este repo). Revisa la lista que abre en el Bloc de notas y adjunta `REA-fuentes.zip` del
   Escritorio en un chat de Claude con este repo: Claude lo descomprime y lo sube.

## Cada sesión

- Abre la sesión con el repo **pvklein/rea**. Claude carga `CLAUDE.md`, la skill de REA y el
  servidor MCP de REA sin que hagas nada.
- Cuando cambies algo en el PC, vuelve a lanzar el `.bat` y adjunta el zip nuevo (o solo los
  ficheros que hayan cambiado).

## Qué hay aquí

| Ruta | Qué es |
|---|---|
| `CLAUDE.md` | Reglas y contexto que Claude lee al empezar cada sesión |
| `docs/RESUMEN-PROYECTO-REA.md` | Resumen completo del proyecto (2026-10-29) |
| `nube/instalar-entorno.sh` | Setup script del entorno de la nube (idempotente) |
| `pc/preparar-copia-fuentes.bat` | Saca de `C:\REA` solo las fuentes y las comprime |
| `.mcp.json`, `.claude/skills/reverse-engineer-anything/` | REA 6.7.0 como MCP y su skill (MIT) |
| `analisis/`, `reloj-metricas/`, `tab2-nura/`, `jarvis/`… | Llegan con el primer zip; misma estructura que `C:\REA` |
