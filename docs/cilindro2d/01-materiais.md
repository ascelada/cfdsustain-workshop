# 1 · Materiais e Condições de Contorno

| Nº | Dinâmica                         | Região física              |
|---:|----------------------------------|----------------------------|
| 1  | `BGKdynamics`                    | Fluido interno             |
| 2  | `BounceBack`                     | Paredes do canal           |
| 3  | `InterpolatedVelocity`           | Entrada (perfil Poiseuille)|
| 4  | `InterpolatedPressure`           | Saída (p = 0)              |
| 5  | `Bouzidi`                        | Superfície do cilindro     |

```cpp title="Trecho prepareGeometry()"
// Todo domínio → paredes
superGeometry.rename(0, 2);

// Fluido interno
superGeometry.rename(2, 1, {1,1});

// Entrada
superGeometry.rename(2, 3, 1, inflow);

// Saída
superGeometry.rename(2, 4, 1, outflow);

// Cilindro
superGeometry.rename(1, 5, circle);
```
