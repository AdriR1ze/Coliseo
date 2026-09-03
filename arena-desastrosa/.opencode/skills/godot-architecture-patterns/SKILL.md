---
name: godot-architecture-patterns
description: Principios de arquitectura y directrices de diseño para Godot 4. Usar SIEMPRE al planificar, crear, refactorizar o modificar código, UI, componentes o lógica en este proyecto: obliga a pensar en patrones de diseño (consultando obligatoriamente al usuario antes de implementar uno), priorizar el uso de componentes, y estructurar todo mediante el árbol de nodos (.tscn) en lugar de crearlo por código.
---

# Directrices de Arquitectura y Buenas Prácticas en Godot 4

Este documento define las reglas de diseño y arquitectura obligatorias para el desarrollo en este proyecto. Todo cambio, feature o refactorización debe regirse por estas pautas.

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

## 4. Checklist de Verificación para el Agente

Antes de dar por concluida una respuesta o realizar cambios:
- [ ] ¿He revisado si la solución aplica un patrón de diseño adecuado?
- [ ] Si considero conveniente agregar o cambiar un patrón de diseño, ¿he consultado y obtenido la aprobación del usuario primero?
- [ ] ¿Estoy utilizando componentes para modularizar y desacoplar la lógica en lugar de inflar una sola clase?
- [ ] ¿La UI o jerarquía está modelada en el archivo de escena `.tscn` y no generada con `.new()` / `add_child()` en código?
- [ ] ¿La lógica que puede resolverse mediante nodos nativos (como `Timer`) está en el árbol de la escena?
