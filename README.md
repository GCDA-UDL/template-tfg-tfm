# Plantilla LaTeX para el TFG / TFM

Plantilla de memoria de Trabajo de Fin de Grado o de Máster para el **Grau en Enginyeria Informàtica** de la Escola Politècnica Superior (EPS) de la Universitat de Lleida. Funciona en Overleaf y en local.

Incluye:

- la **memoria** (`main.tex`) con todos los capítulos, ejemplos de figuras, tablas, código, ecuaciones, acrónimos, cronograma y bibliografía;
- las plantillas del **informe inicial** y del **informe de seguimiento** que pide el Portafoli (`informes/`);
- la **guía de recomendaciones** para el estudiante: [`guia/guia_tfg.pdf`](guia/guia_tfg.pdf). Léela antes de empezar.

Todo el contenido de ejemplo (la aplicación *SalaLibre*, los datos y las referencias marcadas como ficticias) es inventado. Sirve para ver cómo se hace cada cosa: sustitúyelo por tu trabajo.

## Empezar

**Estudiantes:** tu director o directora te comparte en Overleaf un proyecto ya creado a partir de esta plantilla. Acepta la invitación, trabaja siempre en ese proyecto y sigue los [primeros pasos](#primeros-pasos).

**Dirección (una vez):** en Overleaf, **New Project → Import from GitHub** y elige `GCDA-UDL/template-tfg-tfm` (sin integración con GitHub: **Code → Download ZIP** aquí y **New Project → Upload Project** en Overleaf). Ese proyecto es la plantilla maestra: no se edita.

**Dirección (por estudiante):** en la lista de proyectos de Overleaf, **Copy** sobre la plantilla maestra, con un nombre como «TFG - Apellidos, Nombre - 2026-27». Después, **Share** con el correo UdL del estudiante y permiso de edición. La copia no queda conectada a GitHub.

En los dos casos, comprueba en **Menu** que el compilador es **pdfLaTeX** y el documento principal es **`main.tex`**.

## Primeros pasos

1. Rellena **`config/datos.tex`**: autor, título (idéntico al de la propuesta), titulación, dirección, mes y año, palabras clave, idioma (`spanish`, `catalan` o `english`) y estilo de cita (`ieee` o `apa`).
2. Descarga la **portada oficial** de la web de la EPS, rellénala y guárdala como `portada/portada.pdf` (ver [`portada/README.md`](portada/README.md)).
3. Escribe tu contenido en `capitulos/`, `preliminares/` y `apendices/`. Cada fichero empieza con un comentario `% GUÍA` que explica qué tiene que contener.
4. Añade tus referencias a `bibliografia.bib` y borra las ficticias.
5. Si escribes en inglés o catalán, traduce también los títulos que están escritos a mano («Agradecimientos», «Declaración de uso de herramientas de IA») y los de los capítulos.

## Estructura

```
main.tex                  documento principal de la memoria
config/datos.tex          TUS DATOS: lo único que hay que configurar
config/preambulo.tex      paquetes y estilo (no hace falta tocarlo)
config/portada_provisional.tex
portada/                  aquí va portada.pdf (la portada oficial de la EPS)
preliminares/             resumen, resum, abstract, agradecimientos, declaración de IA, acrónimos
capitulos/                01_introduccion ... 07_conclusiones
apendices/                repositorio y vídeo demo, manual de instalación
figuras/                  imágenes y cronograma.tex (el Gantt único)
bibliografia.bib          referencias (biblatex + biber)
informes/                 informe inicial e informe de seguimiento
guia/                     guía de recomendaciones (PDF y fuente)
revnotes.sty              notas de revisión y avisos \pending
tools/build.sh            compilación local
```

## Comandos útiles

| Para... | Escribe |
|---|---|
| Citar una referencia | `\cite{clave}` |
| Citar una figura, tabla o sección | `Figura~\ref{fig:x}`, `Tabla~\ref{tab:x}`, `Sección~\ref{sec:x}` |
| Usar una sigla (se expande la primera vez) | `\ac{API}` (definida en `preliminares/acronimos.tex`) |
| Poner la fuente de una figura o tabla | `\fuente{Elaboración propia.}` |
| Una cifra con unidades | `\qty{100}{ms}` |
| Marcar algo pendiente | `\pending{falta la tabla de pruebas}` |
| Notas de la dirección | `\vitornote{...}` (y las tuyas con `\alumnonote{...}`) |

## Modos de compilación

En `main.tex`, la línea `\usepackage[mode=review]{revnotes}`:

- `mode=review` (mientras escribes): se ven las notas y los `\pending` en color.
- `mode=final` (para entregar y depositar): desaparecen las notas, y si queda algún `\pending` o falta `portada/portada.pdf`, **la compilación falla a propósito**. La versión depositada tiene que compilar en `mode=final` sin errores ni referencias indefinidas.

## Informes del Portafoli

`informes/informe_inicial.tex` (semanas 4-6) e `informes/informe_seguimiento.tex` (semanas 10-12) usan los mismos datos, la misma bibliografía y el mismo cronograma (`figuras/cronograma.tex`) que la memoria. En Overleaf, cambia el documento principal en **Menu → Main document** para compilarlos.

## Compilar en local (opcional)

Hace falta una distribución de LaTeX con `biber` (TeX Live o MiKTeX). Desde la carpeta del proyecto, en una terminal Bash (Git Bash en Windows):

```bash
bash tools/build.sh                         # memoria -> build/main.pdf
bash tools/build.sh --mode final            # prueba de la versión de depósito
bash tools/build.sh informes/informe_inicial
bash tools/build.sh guia/guia_tfg
```

El script imprime los errores, las referencias y citas indefinidas, las cajas que se salen del margen y los `\pending` que quedan.

## Licencia

La plantilla se distribuye con licencia MIT (ver [`LICENSE`](LICENSE)). El trabajo que escribas con ella es tuyo.
