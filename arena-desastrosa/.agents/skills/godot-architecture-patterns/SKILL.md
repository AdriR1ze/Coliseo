---
name: godot-architecture-patterns
description: Principios de arquitectura y directrices de diseño para Godot 4. Usar SIEMPRE al planificar, crear, refactorizar o modificar código, UI, componentes o lógica en este proyecto: obliga a pensar en patrones de diseño (consultando obligatoriamente al usuario antes de implementar uno), priorizar el uso de componentes, y estructurar todo mediante el árbol de nodos (.tscn) en lugar de crearlo por código.
---

# Directrices de Arquitectura y Buenas Prácticas en Godot 4

Este documento define las reglas de diseño y arquitectura obligatorias para el desarrollo en este proyecto. Todo cambio, feature o refactorización debe regirse por estas pautas.

---

## 0. Regla de Oro: Separar la UI

**SIEMPRE separar la interfaz de usuario en escenas `.tscn` y componentes independientes.** Nunca dejar toda la UI junta en un solo script o escena monolítica.

- Cada pieza de UI (barra de vida, barra de energía, panel de oleada, slots, botones, pantallas de menú/derrota/elección, etc.) debe ser **su propia escena `.tscn`** (componente), con su script mínimo que solo conecte señales y actualice datos.
- Un orquestador (ej. `hud.tscn`) arma los componentes en el layout final; el orquestador no construye los elementos por código, solo los posiciona/instancia y los conecta.
- Estructura de referencia en `ui/`:
  ```
  ui/hud/health_bar.tscn        ui/hud/power_bar.tscn
  ui/hud/wave_panel.tscn        ui/hud/gold_bar.tscn
  ui/hud/action_slots.tscn      ui/hud/control_buttons.tscn
  ui/hud/defeat_panel.tscn      ui/hud/hud.tscn  (orquesta)
  ui/menu/menu_button.tscn      ui/menu/main_menu.tscn
  ```
- Motivo: cada parte se puede editar, estilizar, reutilizar y testear por separado, y los cambios de una no rompen el resto.
- Prohibido: un script de UI gigante que instancie `Label.new()`, `Button.new()`, `ProgressBar.new()` con posiciones a mano para toda la interfaz.

---

## 1. Patrones de Diseño y Consulta Obligatoria

1. **Mentalidad orientada a Patrones de Diseño**:
   - Siempre analizar los requerimientos y el diseño del código desde la perspectiva de patrones de diseño clásicos y adaptados a Godot (Factory, Strategy, Decorator, Observer/Signals, State, Component, Command, etc.).
   - Revisar activamente el código existente: verificar si se está omitiendo un patrón donde resolvería mejor el problema, o si una lógica está resolviéndose de manera ad-hoc con acoplamiento indebido.

2. **CONSULTA OBLIGATORIA al usuario**:
   - **Bajo ninguna circunstancia** se debe implementar un nuevo patrón de diseño o iniciar un refactor hacia un patrón sin la previa aprobación explícita del usuario.
   - Si se identifica que falta un patrón o que conviene introducir uno:
     1. Explicar el problema o limitación actual (acoplamiento, falta de extensibilidad, código spaghetti, etc.).
     2. Proponer el patrón de diseño concreto a implementar.
     3. Mostrar brevemente la estructura que se plantea y su impacto en el proyecto.
     4. Consultar y esperar la decisión del usuario antes de proceder.

---

## 2. Arquitectura Basada en Componentes

1. **Composición sobre Herencia (Composition over Inheritance)**:
   - Preferir siempre componer comportamientos mediante nodos componentes reutilizables en vez de extender clases profundas o crear clases monolíticas.
   - Ver los ejemplos ya existentes en el directorio `components/` (como `health.gd`, `movement.gd`, `contact_damage.gd`, etc.).

2. **Diseño de Entidades**:
   - Entidades como el Jugador (`Player`), Enemigos o Proyectiles deben actuar como contenedores que orquestan sus componentes hijos.
   - Cada componente debe ser responsable de una única función o mecánica (movimiento, vida/daño, detección, inputs, etc.).

3. **Comunicación Desacoplada**:
   - Los componentes se comunican hacia arriba o hacia afuera mediante **señales** (`signals`).
   - Hacia abajo o hacia sus propios datos, mediante métodos claros.
   - Evitar acoplamiento duro entre componentes hermanos; la entidad raíz o un orquestador debe mediar o conectar las señales.

---

## 3. Priorizar el Árbol de Nodos (.tscn) sobre Creación por Código

1. **Regla Fundamental**:
   - Toda jerarquía visual, estructura de escena y configuración estática debe definirse en el **árbol de nodos** dentro de archivos de escena (`.tscn`), **NUNCA crearse proceduralmente por código** con `.new()` y `add_child()` dispersos en scripts.

2. **En Interfaz de Usuario (UI)**:
   - Pantallas, paneles, menús, botones, etiquetas y contenedores (`VBoxContainer`, `HBoxContainer`, `CenterContainer`, `MarginContainer`, `PanelContainer`, etc.) deben armarse y posicionarse en la escena `.tscn`.
   - **PROHIBIDO**: Crear nodos de UI dinámicamente desde `_ready()` o funciones como `_construir_ui()` usando `ColorRect.new()`, `Button.new()`, `Label.new()`, asignando posiciones o márgenes manuales por código para interfaces estáticas.
   - El script adjunto a la escena de UI debe dedicarse exclusivamente a:
     - Conectar señales de botones o eventos.
     - Actualizar datos en pantalla (ej. texto de labels, barras de vida).
     - Gestionar transiciones o visibilidad.

3. **En Lógica y Mecánicas**:
   - Utilizar los nodos nativos del motor en el árbol de escena para resolver necesidades del juego (`Timer`, `Area3D`/`Area2D`, `CollisionShape3D`, `AnimationPlayer`, `RayCast3D`, `VisibleOnScreenNotifier3D`, etc.).
   - No simular en código lo que un nodo nativo ya resuelve (ej. no usar contadores manuales con `delta` en `_process` si un nodo `Timer` en la escena modela mejor la intención y facilita la configuración en el editor).
   - Los componentes lógicos deben agregarse como nodos hijos en la escena `.tscn` correspondiente.

4. **Excepciones Válidas para Creación por Código**:
   - Instanciación dinámica requerida en tiempo de ejecución cuya cantidad o momento de aparición no puede conocerse de antemano (ej. spawn de oleadas de enemigos vía Factory, disparar proyectiles instanciados desde `PackedScene`).

---

## 3.1 Toda Feature Debe Incluir Su UI Necesaria

- **Regla**: Al agregar o modificar una feature, implementar siempre la interfaz de usuario necesaria para que el jugador pueda verla y usarla. Una feature sin su UI queda incompleta.
- Implica:
  - Nuevo dato visible (nivel, estadísticas, puntos, cooldowns) → mostrarlo en el HUD o en la pantalla correspondiente.
  - Nueva decisión/interacción del jugador (elegir mejora, comprar, confirmar) → crear la pantalla o controles (`.tscn`) necesarios.
  - Nueva acción o estado → reflejarlo visualmente (feedback, transiciones, visibilidad).
- La UI de cada feature debe construirse como **escena `.tscn`** (ver sección 3) y su script solo debe conectar señales y actualizar datos dinámicos.

---

## 3.2 Revisar Todo lo Implementado Antes de Dar el OK

**NUNCA** dar una tarea por terminada sin haber revisado y verificado TODO lo que se implementó. Una respuesta que dice "`listo`" sin revisar es una respuesta incompleta.

Proceso obligatorio antes de comunicar el OK al usuario:

1. **Verificar referencias y rutas**:
   - Que en los `.tscn` no haya `ext_resource` apuntando a rutas inexistentes.
   - Que los `preload()` existan (archivos `.gd`, `.tscn`, texturas).
   - Que los nombres de escenas/nodos referenciados por `@onready` y `$`/`%` coincidan exactamente con el árbol (mayúsculas, `_`, rutas de nodos anidados).

2. **Revisar señales conectadas**:
   - Que cada `signal` referenciada exista (y con la misma aridad/tipos).
   - Que no haya conexiones duplicadas o `connect` a métodos que ya no existen (por refactor).

3. **Confirmar que no quedaron referencias muertas**:
   - Tras mover/renombrar archivos (ej. `hud.gd`), buscar y eliminar cualquier `@onready`, `preload`, `extends`, `load()` o `change_scene_to_file` que apunte a la ruta vieja.

4. **Revisar que los `class_name` no dupliquen**:
   - Al crear/reemplazar scripts, confirmar que no hay dos scripts con el mismo `class_name` (duplicados rompen la carga de todo el proyecto).

5. **Revisar la jerarquía y el layout real de la UI**:
   - Verificar los `layout_mode`, `anchors_preset` y `offset_*` de cada Control instanciado (especialmente hijos directos de `CanvasLayer`) para que se posicionen y mantengan tamaño correcto.
   - Confirmar que cada ruta usada por el script del control (ej. `$Root/Margin/Label`) exista en su escena.

6. **Revisar ganancias/propiedades exportadas y datos**:
   - Que las `@export` existan en la clase correcta y que los datos leídos de señales/managers existan (ej. `ClassManager.experiencia_actualizada`, `nivel_subido`).

7. **Revisar los escenarios de flujo**:
   - Flujo de pantallas (menú → selección → combate → derrota → reintento).
   - Flujo de oleadas y de pausa/elección de items (que al pausar no queden nodos sin `process_mode` adecuado).

8. **Intentar validar el proyecto**:
   - Si hay un ejecutable de Godot disponible, correr el proyecto en headless o abrirlo y chequear que no haya errores de parseo ni de recursos faltantes. Si no se puede, avisar explícitamente al usuario que la validación queda pendiente.

> Regla de oro: si el resultado no está verificado, o hay dudas de que compile/cargue y se vea bien, **no dar el OK**. Decir exactamente qué se revisó y qué quedó sin validar.

---

## 4. Checklist de Verificación para el Agente

Antes de dar por concluida una respuesta o realizar cambios:
- [ ] ¿Revisé todas las referencias (rutas, `preload`, `extends`, `$`/`%`, `@onready`) y coinciden con los archivos/árbol?
- [ ] ¿Revisé señales conectadas (existen, con la misma firma, sin conexiones duplicadas)?
- [ ] ¿Eliminé referencias muertas tras mover/renombrar archivos?
- [ ] ¿Confirmé que no hay `class_name` duplicados?
- [ ] ¿Revisé layout/anclas/offsets de los nodos de UI y las rutas internas de cada escena?
- [ ] ¿Repasé los flujos (pantallas, oleadas, pausa/items, derrota/reintento)?
- [ ] ¿Intenté validar el proyecto (Godot headless/editor)? Si no pude, ¿lo dije explícitamente al usuario?
- [ ] ¿He revisado si la solución aplica un patrón de diseño adecuado?
- [ ] Si considero conveniente agregar o cambiar un patrón de diseño, ¿he consultado y obtenido la aprobación del usuario primero?
- [ ] ¿Estoy utilizando componentes para modularizar y desacoplar la lógica en lugar de inflar una sola clase?
- [ ] ¿La UI o jerarquía está modelada en el archivo de escena `.tscn` y no generada con `.new()` / `add_child()` en código?
- [ ] ¿La lógica que puede resolverse mediante nodos nativos (como `Timer`) está en el árbol de la escena?
- [ ] ¿La feature incluye la UI necesaria (HUD, pantalla de elección, feedback visual) para poder verse y usarse?
