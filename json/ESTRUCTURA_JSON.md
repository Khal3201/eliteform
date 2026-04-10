# Estructura JSON para importar Rutinas y Dietas — EliteForm

---

## 🏋️ JSON para RUTINAS

### Campos obligatorios
- `nombre_rutina` (string)
- `objetivo` (string): `"Fuerza"` | `"Volumen"` | `"Resistencia"` | `"Definición"` | `"Movilidad"`

### Campos opcionales
- `descripcion` (string) — default: `""`
- `nivel` (string): `"Principiante"` | `"Intermedio"` | `"Avanzado"` — default: `"Principiante"`
- `dias_por_semana` (número entero 1–7) — default: `3`
- `musculos_principales` (array de strings) — default: `[]`
- `dias` (array de objetos DiaRutina) — default: `[]`

### Estructura de cada día (`dias`)
```json
{
  "nombre_dia": "Lunes - Pecho y Tríceps",
  "ejercicios": [ ...EjercicioRutina ]
}
```

### Estructura de cada ejercicio (`ejercicios`)
```json
{
  "nombre": "Press de banca",
  "musculo": "Pecho",
  "series": 4,
  "repeticiones": "8-10",
  "descanso": "90 seg",
  "notas": "Bajar controlado, no rebotar"
}
```
> `notas` es opcional.

---

### ✅ Ejemplo completo de rutina

```json
{
  "nombre_rutina": "Rutina Full Body 3x",
  "objetivo": "Fuerza",
  "descripcion": "Rutina de cuerpo completo ideal para principiantes que quieren ganar fuerza base.",
  "nivel": "Principiante",
  "dias_por_semana": 3,
  "musculos_principales": ["Pecho", "Espalda", "Piernas", "Hombros"],
  "dias": [
    {
      "nombre_dia": "Día A — Empuje",
      "ejercicios": [
        {
          "nombre": "Press de banca",
          "musculo": "Pecho",
          "series": 4,
          "repeticiones": "6-8",
          "descanso": "2 min",
          "notas": "Grip prono, codos a 45°"
        },
        {
          "nombre": "Press militar",
          "musculo": "Hombros",
          "series": 3,
          "repeticiones": "8-10",
          "descanso": "90 seg"
        },
        {
          "nombre": "Fondos en paralelas",
          "musculo": "Tríceps",
          "series": 3,
          "repeticiones": "Al fallo",
          "descanso": "60 seg"
        }
      ]
    },
    {
      "nombre_dia": "Día B — Jalón",
      "ejercicios": [
        {
          "nombre": "Dominadas",
          "musculo": "Espalda",
          "series": 4,
          "repeticiones": "Al fallo",
          "descanso": "2 min"
        },
        {
          "nombre": "Remo con barra",
          "musculo": "Espalda",
          "series": 4,
          "repeticiones": "6-8",
          "descanso": "90 seg"
        },
        {
          "nombre": "Curl con barra",
          "musculo": "Bíceps",
          "series": 3,
          "repeticiones": "10-12",
          "descanso": "60 seg"
        }
      ]
    },
    {
      "nombre_dia": "Día C — Pierna",
      "ejercicios": [
        {
          "nombre": "Sentadilla con barra",
          "musculo": "Cuádriceps",
          "series": 5,
          "repeticiones": "5",
          "descanso": "3 min",
          "notas": "Profundidad completa"
        },
        {
          "nombre": "Peso muerto",
          "musculo": "Femorales",
          "series": 3,
          "repeticiones": "5",
          "descanso": "3 min"
        },
        {
          "nombre": "Prensa de pierna",
          "musculo": "Cuádriceps",
          "series": 3,
          "repeticiones": "12-15",
          "descanso": "90 seg"
        }
      ]
    }
  ]
}
```

---

## 🥗 JSON para DIETAS

### Campos obligatorios
- `nombre` (string)
- `objetivo` (string): `"Pérdida de peso"` | `"Volumen"` | `"Mantenimiento"` | `"Definición"`

### Campos opcionales
- `descripcion` (string) — default: `""`
- `calorias` (número entero) — default: `2000`
- `nivel` (string): `"Básica"` | `"Intermedia"` | `"Estricta"` — default: `"Básica"`
- `preferencias_compatibles` (array de strings) — default: `[]`
  - Valores válidos: `"Sin restricciones"`, `"Vegetariana"`, `"Vegana"`, `"Sin gluten"`, `"Sin lactosa"`, `"Alta en proteínas"`, `"Baja en carbohidratos"`
- `comidas` (array de objetos ComidaDia) — default: `[]`

### Estructura de cada comida (`comidas`)
```json
{
  "momento": "Desayuno",
  "descripcion": "Descripción de la comida y su propósito",
  "calorias_aprox": 650,
  "alimentos": ["Avena", "Leche descremada", "Huevo cocido", "Plátano"]
}
```

---

### ✅ Ejemplo completo de dieta

```json
{
  "nombre": "Dieta de Volumen Moderado",
  "objetivo": "Volumen",
  "descripcion": "Plan alimenticio con superávit calórico moderado para favorecer la ganancia de masa muscular sin exceso de grasa.",
  "calorias": 3200,
  "nivel": "Intermedia",
  "preferencias_compatibles": ["Sin restricciones", "Alta en proteínas"],
  "comidas": [
    {
      "momento": "Desayuno",
      "descripcion": "Desayuno alto en carbohidratos y proteínas para comenzar el día con energía.",
      "calorias_aprox": 750,
      "alimentos": [
        "Avena (100g)",
        "Leche entera (300ml)",
        "2 huevos revueltos",
        "1 plátano",
        "Mantequilla de maní (30g)"
      ]
    },
    {
      "momento": "Snack mañana",
      "descripcion": "Colación rica en proteína para mantener el anabolismo.",
      "calorias_aprox": 400,
      "alimentos": [
        "Batido de proteína (1 scoop)",
        "Leche entera (250ml)",
        "Nueces mixtas (30g)"
      ]
    },
    {
      "momento": "Almuerzo",
      "descripcion": "Comida principal del día con proteína de alta calidad y carbohidratos complejos.",
      "calorias_aprox": 950,
      "alimentos": [
        "Pechuga de pollo (200g)",
        "Arroz integral (150g cocido)",
        "Brócoli al vapor (200g)",
        "Aceite de oliva (1 cda)",
        "Aguacate (½ pieza)"
      ]
    },
    {
      "momento": "Merienda",
      "descripcion": "Comida pre-entrenamiento para asegurar energía durante el ejercicio.",
      "calorias_aprox": 500,
      "alimentos": [
        "Pan integral (2 rebanadas)",
        "Atún en agua (1 lata)",
        "Manzana",
        "Yogur griego (150g)"
      ]
    },
    {
      "momento": "Cena",
      "descripcion": "Comida post-entrenamiento enfocada en recuperación muscular.",
      "calorias_aprox": 600,
      "alimentos": [
        "Salmón (180g)",
        "Camote (150g)",
        "Espinacas salteadas (150g)",
        "Aceite de coco (1 cda)"
      ]
    }
  ]
}
```

---

## 📌 Notas importantes

1. **Valores de `objetivo` son exactos** — escríbelos tal como aparecen en la lista (con tilde y mayúsculas donde corresponda).
2. **Campos no reconocidos** son ignorados — no generan error.
3. **Días sin ejercicios** son válidos — se puede usar para descanso activo.
4. **El campo `creado_por`** es asignado automáticamente por la app — no incluirlo en el JSON.
5. **Tamaño máximo recomendado**: 1 MB por archivo JSON.
