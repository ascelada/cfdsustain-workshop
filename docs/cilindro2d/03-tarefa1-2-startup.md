
# Tarefa 1.2 — *Smooth Start-Up* do Escoamento

Vamos avaliar como o “ramp‐up” gradual da velocidade de entrada afeta
estabilidade e convergência.

---

## Passo 1 · Executar o Caso Original (ramp = 40 % do tempo)

```bash
cd examples/forBeginners/cylinder2d
make clean && make
mpirun -np 4 ./cylinder2d
```

Registre a primeira linha do log que contenha `pressureDrop`.

---

## Passo 2 · **Remover** o *Smooth Start-Up*

1. **Abra** `cylinder2d.cpp` e encontre, dentro de
   `void setBoundaryValues(...)`, a linha:

   ```cpp
   T maxVelocity = converter.getCharLatticeVelocity()*3./2.*frac[0];
   ```

2. **Substitua** por:

   ```cpp
   // --- sem rampa --- velocidade máxima já no passo 0
   T maxVelocity = converter.getCharLatticeVelocity()*3./2.;
   ```

3. **Compile e rode** novamente:

   ```bash
   make clean && make
   mpirun -np 4 ./cylinder2d
   ```

!!! note "Nota"
    Normalmente a simulação apresenta pico de instabilidade (pressão oscilando ou até divergindo).

---

## Passo 3 · *Smooth Start* de **10 %** do tempo

 Volte a linha original do `maxVelocity` (com `*frac[0]`).

 No mesmo bloco, troque:

   ```cpp
   const std::size_t iTmaxStart = converter.getLatticeTime(maxPhysT * 0.4);
   ```

   por

   ```cpp
   const std::size_t iTmaxStart = converter.getLatticeTime(maxPhysT * 0.1);
   ```

 Compile e rode novamente.


## Passo 4 · *Smooth Start* de **80 %** do tempo

Troque o mesmo fator para `0.8`:

```cpp
const std::size_t iTmaxStart = converter.getLatticeTime(maxPhysT * 0.8);
```

Compile e rode.


??? example "Possíveis Conclusões"
    * Sem rampa → picos de pressão e possível divergência.
    * Rampa curta (10 %) → estabiliza rápido, mas ainda há overshoot leve.
    * Rampa longa (80 %) → convergência suave, porém simulação “perde tempo”
    acelerando; escolha depende de robustez desejada × custo computacional.


## Passo 5 · Trocar a Condição de Contorno de **Velocidade** → **Pressão**

### 5.1 · `prepareLattice()` — inflow como Interpolated Pressure

Substitua **uma única linha**:

```cpp
// antes
boundary::set<boundary::InterpolatedVelocity>(sLattice, superGeometry, 3);
```
por
```cpp
// depois
boundary::set<boundary::InterpolatedPressure>(sLattice, superGeometry, 3);
```

*(o material 3 continua sendo a entrada)*

### 5.2 · `setBoundaryValues()` — functor de densidade (ρ)

Logo depois de criar `PolynomialStartScale` insira:

```cpp
// --- pressão alvo: 0.1 Pa, suavemente escalonada ---
AnalyticalConst2D<T,T> rho( converter.getLatticeDensityFromPhysPressure(0.1 * frac[0]) );

// aplica a condição de pressão no inflow (material 3)
sLattice.defineRho(superGeometry, 3, rho);
```
!!! warning "Aviso"
    **Remova ou comente** a linha que define `poiseuilleU`
    (`sLattice.defineU(superGeometry, 3, poiseuilleU);`)
    agora a entrada é controlada por pressão, não velocidade.

---

## Passo 6 · Executar e Comparar

```bash
make clean && make
mpirun -np 4 ./cylinder2d
```

