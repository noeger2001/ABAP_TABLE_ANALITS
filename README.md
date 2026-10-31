# ABAP_TABLE_ANALITS
para la app con 2 view o tabs 
<img width="1503" height="850" alt="image" src="https://github.com/user-attachments/assets/74178bce-7308-4325-ae6f-3a4597d2e128" />
TotalsCustomList
List Report          +   ✏️   ...
/TotalsCustom
                         ↑
                     ESTE

Views → Add → Add Table View → seleccionar Entity → Add.
un ejemplo "TotalsSummary"

Luego pon el label de la nueva vista:Resumen
y a la vista existente basada en: 

El resultado debería ser: TotalsCustom ponle: Detalle
┌─────────────────────────────────────────────┐
│ Filter Bar                                  │
│ Sociedad | Clase | Año | Región | ...       │
├─────────────────────────────────────────────┤
│                                             │
│ Detalle (108)       Resumen (27)            │
│ ─────────────       ────────────            │
│                                             │
│             tabla del tab activo            │
└─────────────────────────────────────────────┘

Después agrega las columnas del resumen
Una vez creado TotalsSummary, expándelo en el Page Editor y busca:
Columns
→ +
→ Add Basic Columns
Selecciona: las columnas que necesitas 
