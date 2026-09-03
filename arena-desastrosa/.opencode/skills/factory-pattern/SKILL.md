---
name: factory-pattern
description: Usar SIEMPRE que se agregue un nuevo tipo de enemigo o clase. Obliga a seguir el patrón de diseño Factory usando las factories existentes (EnemyFactory, ClaseFactory) en lugar de instanciar scripts directamente.
---

# Patrón Factory para Enemigos y Clases

Este proyecto (Godot 4, GDScript) usa el patrón de diseño **Factory** para
crear enemigos y clases. Todo tipo nuevo debe pasar por una factory.

## Reglas

- Al agregar un nuevo tipo de enemigo o clase, NUNCA instanciar el script
  directamente desde fuera (`.new()` o `preload().instantiate()` dispersos por
  el código). Siempre hacerlo a través de la factory existente.
- Si ya existe una factory para esa categoría, REUSARLA. No crear una nueva.

## Factories existentes

### Enemigos — `enemies/enemy_factory.gd`
- Clase base: `Enemy` (`enemy.gd`, extiende `CharacterBody3D`).
- Estructura: `enum TipoEnemigo` + diccionario `const ENEMIGOS` con `preload()`.
- Creación: `EnemyFactory.crear_enemigo(tipo)`.

Pasos para agregar un enemigo:
1. Crear la escena/script que extienda `Enemy`.
2. Agregar una entrada al `enum TipoEnemigo`.
3. Registrar su `preload()` en el diccionario `ENEMIGOS`.

### Clases — `clases/clase_factory.gd`
- Clase base: `BaseClase` (`clases/base_clase.gd`, extiende `Resource`).
- Estructura: `enum Clases` + diccionario `const CLASES` con `preload()`.
- Creación: `ClaseFactory.crear_clase(tipo)`.

Pasos para agregar una clase:
1. Crear el script que extienda `BaseClase` y configure sus propiedades en
   `_init()`.
2. Agregar una entrada al `enum Clases`.
3. Registrar su `preload()` en el diccionario `CLASES`.

## Patrón común de las factories

Ambas factories siguen la misma estructura:

- `enum` con los tipos disponibles.
- Diccionario `const` que mapea tipo → `preload(...)`.
- Método `static func crear_*(tipo)` que valida el tipo y devuelve la
  instancia (o `null` con `push_error` si no está registrado).
- Método `static func listar_tipos()` (hoy solo lo tiene `ClaseFactory`).

Si hace falta una factory para una categoría nueva (solo cuando no exista una),
seguir este mismo patrón para mantener consistencia.

## Consideración general: preferir el árbol de escena sobre el código

Siempre que sea posible, hacer las cosas usando el **árbol de escena** (nodos)
en lugar de hacerlo por código. Esto aplica a todo en general, no solo a la UI:
estructura de escenas, jerarquías de nodos, configuraciones estáticas,
animaciones, colisiones, etc.

- Crear y configurar nodos en el editor (escena `.tscn`) siempre que se pueda,
  en vez de instanciarlos dinámicamente (`add_child`, `new()`, etc.) en el
  script.
- Si algo es configurable estáticamente (posición, tamaño, anclas, textos,
  estilos, valores de exportación), hacerlo en el nodo, no con `set()` dispersos
  en el código.
- Usar código solo para la lógica y el comportamiento (lo que no puede
  expresarse como nodos o configuraciones del editor), no para construir la
  estructura de la escena.
