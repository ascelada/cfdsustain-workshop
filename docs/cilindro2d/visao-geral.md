# Exemplo *Cylinder2D* — Visão Geral do Código


## 1 · Parâmetros de Entrada

| Símbolo/flag | Papel no código | Valor default | Observações |
|--------------|-----------------|---------------|-------------|
| `N`          | Resolução base (nº de células por 0.1 m) | `10` | dobra a grade se duplicar |
| `CFL`        | Número de Courant (estabilidade)          | `0.05` | ­c Δt/Δx |
| `Re`         | Número de Reynolds (controle de regime)   | `20`  | < 45 ⇒ laminar |
| `maxPhysT`   | Tempo físico de simulação (s)             | `16`  | usado para `iTmax` |
| `radiusCylinder` | Raio do cilindro (m)               | `0.05` | altera drag & shedding |

??? tip "Dica rápida"
    Quer gerar o *Kármán vortex street*?  Mude `Re` para `100` e deixe `maxPhysT`
    maior, pois o escoamento passa a ser não estacionário.

---

## 2 · Etapas Principais do Programa

| # | Função/Código             | Objetivo resumido                                 |
| - | ------------------------- | ------------------------------------------------- |
| 1 | **`initialize()`**        | Inicializa MPI, CUDA/OpenMP, leitura de args      |
| 2 | **`UnitConverter`**       | Traduz unidades SI → lattice (`Δx`, `Δt`, `ν`)    |
| 3 | **`prepareGeometry()`**   | Atribui números de material às regiões do domínio |
| 4 | **`prepareLattice()`**    | Conecta materiais aos modelos de borda/dinâmica   |
| 5 | **`setBoundaryValues()`** | Perfil de Poiseuille com *ramp-up* suave          |
| 6 | **`collideAndStream()`**  | Passo BGK (colisão + advecção)                    |
| 7 | **`getResults()`**        | Saída VTK, estatísticas, Δp no cilindro           |
| 8 | **`timer`**               | Mede desempenho (MFLUPS)                          |

---

### 2.1 Unit Converter
```cpp
const UnitConverter<T, DESCRIPTOR> converter(
  /* physDeltaX   */ L,
  /* physDeltaT   */ CFL * L / 0.2,
  /* charLength   */ 2.0 * radiusCylinder,
  /* charVelocity */ 0.2,
  /* physViscosity*/ 0.2 * 2. * radiusCylinder / Re,
  /* physDensity  */ 1.0
);
```


## 3 · Materiais & Condições de Contorno

| Nº | Dinâmica/BC            | Região física          | Trecho de código                            |
| -: | ---------------------- | ---------------------- | ------------------------------------------- |
|  1 | `BGKdynamics`          | Fluido interno         | `defineDynamics(…, 1)`                      |
|  2 | `BounceBack`           | Paredes do canal       | `boundary::set<BounceBack>(…, 2)`           |
|  3 | `InterpolatedVelocity` | Entrada (Poiseuille)   | `boundary::set<InterpolatedVelocity>(…, 3)` |
|  4 | `InterpolatedPressure` | Saída (`p = 0`)        | `boundary::set<InterpolatedPressure>(…, 4)` |
|  5 | `Bouzidi`              | Superfície do cilindro | `setBouzidiBoundary(…, 5, circle)`          |

!!! note "Por que Bouzidi?"
    O algoritmo de Bouzidi & Firdaouss (2001) impõe *no-slip* preciso em
    superfícies curvas sem “serrar” o contorno — ideal para o cilindro.

---

## 4 · Construção da Geometria (`prepareGeometry`)

```cpp
superGeometry.rename(0, 2);          // 0 → 2: tudo começa como “parede”
superGeometry.rename(2, 1, {1,1});   // 1×1 móvel → fluido interno
superGeometry.rename(2, 3, 1, inflow);
superGeometry.rename(2, 4, 1, outflow);
superGeometry.rename(1, 5, circle);  // sobrepõe o cilindro
```

* **`clean()`** remove voxels “fantasmas” gerados pela renomeação.
* **`checkForErrors()`** aborta se ainda restar vazamento entre materiais.

---

## 5 · Inicialização & *Ramp-up* Suave (`setBoundaryValues`)

1. **Polinômio de 3ª ordem**
   controla o multiplicador `frac[0]` de 0 → 1 até `iTmaxStart`.
2. Cria um *functor* **`Poiseuille2D`** para `material 3`.

---

## 6 · Saída de Resultados (`getResults`)

* **VTK** a cada 0.3 s físicos – abre no ParaView.
* **Console** a cada 0.8 s: FPS, MLUPS, Δp antes-depois do cilindro.
* Functor **`SuperLatticePhysPressure2D`** permite interpolar pressão em
  pontos arbitrários sem extração de campo bruto.

