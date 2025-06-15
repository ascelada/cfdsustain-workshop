# Código **cavity2d.cpp** Comentado

```cpp title="Definições de tipo"
using T = FLOATING_POINT_TYPE;                  // precisão configurável
using DESCRIPTOR = descriptors::D2Q9<>;
using BulkDynamics = ConstRhoBGKdynamics<T, DESCRIPTOR>;
```

- **`DESCRIPTOR`** define o conjunto de velocidades discretas (D2Q9).  
- **`BulkDynamics`** escolhe o modelo de colisão BGK de densidade constante.

```cpp title="Parâmetros físicos"
const T physDeltaX      = 1.0 / 128;   // espaçamento espacial
const T physDeltaT      = physDeltaX;  // Δt = Δx (CFL = 1)
const T physLidVelocity = 1.0;         // velocidade da tampa
```

> A relação \(\Delta t = \Delta x\) garante \(c = 1\) em unidades de malha.

```cpp title="prepareGeometry() – marcar materiais"
superGeometry.rename(0, 2);   // domínio inteiro → paredes
superGeometry.rename(2, 1, {1,1});   // interior → material 1
IndicatorCuboid2D lid({L+2dx, 2dx}, {-dx, L-dx});
superGeometry.rename(2, 3, 1, lid);  // tampa → material 3
```
- **Material 1** : nó fluido.  
- **Material 2** : paredes estacionárias.  
- **Material 3** : tampa em movimento.

```cpp title="prepareLattice() – dinâmicas e BCs"
sLattice.defineDynamics<BulkDynamics>(superGeometry, 1);
boundary::set<boundary::InterpolatedVelocity<...>>(sLattice, superGeometry, 3);
sLattice.setParameter<descriptors::OMEGA>(converter.getLatticeRelaxationFrequency());
```

```cpp title="Loop principal"
for (std::size_t iT = 0; iT < iTmax; ++iT) {
    setBoundaryValues(...);
    sLattice.collideAndStream();   // passo LBM
    getResults(...);               // escreve VTK e logs
}
```

!!! info "Convergência"
    Monitore `AverageRho` e `AverageU`. Se crescerem muito, reduza *Re* ou refine a malha.
