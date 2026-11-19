# Portada oficial

La memoria que se deposita debe llevar la **portada oficial de la EPS**, no la provisional que genera la plantilla.

1. Descarga la plantilla de portada (Word) de la web de la EPS: *Tràmits Secretaria → Treballs de Fi de Grau / Màster → Esquema de terminis i requisits → Portada TFG* (o *Portada TFM*).
2. Rellena **todos** los campos, en catalán como la propia plantilla:
   - Estudiant: nombre y apellidos completos.
   - Titulació: «Grau en Enginyeria Informàtica» (o el nombre oficial de tu máster).
   - Títol: el **mismo** título que en la propuesta y en `config/datos.tex`.
   - Director/a y, si lo hay, codirector/a: **todos**.
   - Presentació: mes en catalán (Juny, Juliol, Setembre) y año.
3. Comprueba que no queda ningún texto de ejemplo como «Elija un elemento».
4. Expórtala a PDF y guárdala aquí con el nombre exacto **`portada.pdf`**.

Si `portada/portada.pdf` existe, `main.tex` la usa automáticamente. Si no existe, sale la portada provisional con un aviso rojo, y la compilación en `mode=final` falla a propósito para que no se deposite sin la portada oficial.
