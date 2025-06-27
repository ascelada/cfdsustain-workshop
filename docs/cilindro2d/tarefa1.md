
# Tarefa 1 

## Passo 1 · Executar Caso-Base (cilindro, r = 0.05 m)

```bash
cd $OLB_ROOT/examples/forBeginners/cylinder2d
make clean && make
mpirun -np 4 ./cylinder2d
```

Exemplo de saída:

```text
[getResults] pressure1=0.126632; pressure2=0.0049181; pressureDrop=0.121714
```

## Passo 2 · Alterar o Raio do Cilindro

Edite **`cylinder2d.cpp`**:

```cpp
// r original
const T radiusCylinder = 0.05;   // m
```

```cpp
// exemplo: dobrar o raio
const T radiusCylinder = 0.10;   // m
```

Recompile e execute:

```bash
make clean && make
mpirun -np 4 ./cylinder2d
```

Repita para **≥ 3 valores** (0.05, 0.10, 0.15 m…).

---

## Passo 3 · Coletar Dados (Cilindro)

| r (m) | pressure1 | pressure2 | Δp (Pa) |
| ----: | --------: | --------: | ------: |
|  0.05 |  0.126632 |  0.004918 | 0.12171 |
|  0.10 |         … |         … |       … |
|  0.15 |         … |         … |       … |

??? question "Como a pressão varia com o raio?"
      *Δp ∝ r (arrasto viscoso) ou Δp ∝ r² (arrasto de forma)?*

---

!!! example "Extra"
      Aumente o número de reynolds e veja os vórtices se formarem! Note que precisará aumentar o tempo de simulação!

## Passo 4 · Trocar Cilindro por **Quadrado**

### 4.1 · Defina

#### 1 · Parâmetros iniciais

Defina junto com os outros parametros do problema:

```cpp
// --- QUADRADO ---              ↓ lado em metros
const T sideSquare     = 0.10;      // 0.10 m × 0.10 m
```

---

#### 2 · Criar o obstáculo dentro de `main()`

**Encontre** este trecho (quase no fim de `main`):

```cpp
Vector center{centerCylinderX, centerCylinderY};
IndicatorCircle2D<T> circle(center, radiusCylinder);
prepareGeometry(converter, superGeometry, circle);

// === 3rd Step: Prepare Lattice ===
SuperLattice<T,DESCRIPTOR> sLattice(superGeometry);
prepareLattice(sLattice, converter, superGeometry, circle);
```

**Substitua** por:

```cpp
Vector center{centerCylinderX, centerCylinderY};
IndicatorCuboid2D<T> square(sideSquare, sideSquare, center);
prepareGeometry(converter, superGeometry, square);

// === 3rd Step: Prepare Lattice ===
SuperLattice<T,DESCRIPTOR> sLattice(superGeometry);
prepareLattice(sLattice, converter, superGeometry, square);
```

#### 3 · `prepareLattice()` — usar Bounce-Back em vez de Bouzidi

No início de `prepareLattice(...)`, **comente** a chamada Bouzidi
e adicione Bounce-Back:

```cpp
// Material=5 → obstáculo quadrado (bounce-back simples)
boundary::set<boundary::BounceBack>(sLattice, superGeometry, 5);
```

---

### 4. · Executar 

```bash
make clean && make
mpirun -np 4 ./cylinder2d
```

## Passo 5 · Adicionar **Segundo Objeto** (Quadrado)

### 5.1 · Declarar o novo obstáculo

No **`main()`**, logo depois de criar o primeiro `square`, adicione:

```cpp
Vector<T,2> center2 {centerCylinderX + 0.2, centerCylinderY}
// Segundo quadrado deslocado 0.2 m à direita
IndicatorCuboid2D<T> square2(sideSquare, sideSquare,
                             center2);
```

### 5.2 · `prepareGeometry()` — renomear material
Na definição adicione mais um objeto:

```cpp
void prepareGeometry(const UnitConverter<T, DESCRIPTOR>& converter,
                     SuperGeometry<T, 2>&                superGeometry,
                     IndicatorF2D<T>&                    circle,
                     IndicatorF2D<T>&                    square2)
```

Dentro de `prepareGeometry(...)`, após a linha que renomeia o primeiro quadrado, adicione:

```cpp
// Material do segundo quadrado
superGeometry.rename(1, 6, square2);   // usa material 6, por exemplo
```

### 5.3 · `prepareLattice()` — aplicar Bounce-Back

Logo após definir o Bounce-Back para o material 5, inclua:

```cpp
// Material=6 → segundo quadrado (bounce-back)
boundary::set<boundary::BounceBack>(sLattice, superGeometry, 6);
```
??? note "Nota"
      Se preferir um **círculo** para o segundo objeto, use
      `IndicatorCircle2D` e troque Bounce-Back por:

      ```cpp
      setBouzidiBoundary(sLattice, superGeometry, 6, circle2);
      ```
      Neste caso trá que alterar a definição do método também de forma que consiga passar ao segundo circulo!

---

## Passo 6 · Executar e Observar

```bash
make clean && make
mpirun -np 4 ./cylinder2d
```

* Você verá **`pressureDrop`** no console.
* No ParaView, note que o segundo quadrado inicialmente **não interage** se esqueceu de renomear material ou aplicar Bounce-Back.

---

## Passo 7 · Confirmar Interação

1. Certifique-se de que **ambos** materiais (5 e 6) possuam Bounce-Back (ou Bouzidi).
2. Rode novamente e observe a esteira atrás de cada obstáculo.

