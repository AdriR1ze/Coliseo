## Cómo funciona el sistema de armas

```
BaseArma (Node3D)
    ├── Espada
    └── BastonMagico

DecoradorArma (extends BaseArma)   ← wraps any BaseArma
    ├── DecoradorVeneno             ← ejemplo: DoT de veneno
    └── DecoradorFuego              ← ejemplo: daño extra de fuego

ArmaFactory                        ← crea instancias por enum
```

### Factory Method
- `ArmaFactory.crear_arma(TipoArma.ESPADA)` devuelve una `Espada` lista.
- Agregar un arma nueva = 1 línea en el enum + 1 línea en el dict.

### Decorator
- `DecoradorArma.envolver(arma_interna)` envuelve cualquier arma.
- Delega `puede_atacar()` y `atacar()` al arma interna.
- Agrega lógica extra en `_on_ataque_decorado()`.
- Se apilan: `DecoradorFuego.new().envolver(DecoradorVeneno.new().envolver(Espada.new()))`.

### Flujo en Player.aplicar_clase()
```
clase.crear_arma()
  → ArmaFactory.crear_arma(clase.tipo_arma)
    → instancia concreta (Espada / BastonMagico)
  → (en el futuro) envolver con decoradores según stats / mejoras
```
