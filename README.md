
# README: Exemplo Cylinder2D (forBeginners/cylinder2d.cpp)

Este guia explica passo a passo o **Exemplo Cylinder2D**, disponível na pasta `examples/forBeginners` do OpenLB. Nele você aprenderá:

- Como configurar e executar o exemplo  
- Como a geometria é preparada (incluindo renomeação de materiais)  
- Como as regiões de contorno e interior são definidas na malha  

> **Link do repositório:**  
> [Substitua pelo link do seu repositório aqui](URL_DO_REPOSITORIO)

---

## 1. Visão Geral

O exemplo **Cylinder2D** simula um escoamento fluido (estacionário ou não) ao redor de um cilindro circular dentro de um canal retangular. Seus principais elementos:

- **Entrada com perfil de Poiseuille** à esquerda (velocidade fixa)  
- **Saída de pressão fixa** à direita  
- **Contorno no‐slip** nas paredes do canal (bounce‐back)  
- **Cilindro circular** representado via contorno curvo de Bouzidi  

Ao final da inicialização, o programa executa até o tempo físico definido, gerando arquivos VTK de velocidade e pressão, além de imprimir diagnósticos de queda de pressão.

---

## 2. Pré‐requisitos

1. **Instalação do OpenLB.** O OpenLB deve estar compilado com suas dependências (por exemplo, MPI, CUDA, se necessário).  
2. **Compilador C++20 ou superior** (por exemplo, `clang 19`).  
3. Ter o arquivo `examples/forBeginners/cylinder2d.cpp` disponível no seu diretório de trabalho do OpenLB.  

---

## 3. Execução do Exemplo

Para executar:

```bash
./cylinder2d [maxIter] [outputPrefix]
```

* `maxIter` (opcional) – número máximo de passos de tempo (substitui o valor padrão).
* `outputPrefix` (opcional) – prefixo usado nos arquivos VTK gerados.

Se nenhum argumento for fornecido, o código usará os parâmetros internos (Reynolds, dimensões, etc.) e:

1. Simulará até `maxPhysT = 16` segundos (convertidos em passos‐lattice pelo `UnitConverter`).
2. Gerará arquivos com prefixo `cylinder2d_…`.

Durante a execução, você verá no console o passo atual, valores de queda de pressão e tempos de simulação.

---

## 4. Estrutura Principal do Código

### 4.1 Função `main()`

1. Inicializa o OpenLB:

   ```cpp
   initialize(&argc, &argv);
   ```
2. Cria um **`UnitConverter`** (mapeia unidades físicas → unidades lattice).
3. Constroi um **`SuperGeometry`** não‐estruturado via decomposição de um paralelepípedo 2D.
4. Chama **`prepareGeometry(...)`** para atribuir números de material.
5. Chama **`prepareLattice(...)`** para definir dinâmicas e contornos conforme cada material.
6. Entra no loop de tempo:

   1. `setBoundaryValues(...)` (faz rampa suave de velocidade de entrada)
   2. `sLattice.collideAndStream()`
   3. `getResults(...)` (gera VTK e imprime queda de pressão)

---

## 5. Preparação da Geometria & Renomeação de Materiais

O método **`prepareGeometry(...)`** contém:

```cpp
void prepareGeometry(
    const UnitConverter<T,DESCRIPTOR>& converter,
    SuperGeometry<T,2>& superGeometry,
    IndicatorF2D<T>& circle
) {
  Vector<T,2> extend(lengthX, lengthY);
  Vector<T,2> origin;

  // 1) Renomeia “material de fundo” (0 → 2)
  superGeometry.rename(0, 2);

  // 2) Dentro do cubo inteiro, renomeia “2 → 1” (com halo de 1 célula)
  superGeometry.rename(2, 1, {1, 1});

  // 3) Marca região de entrada (material 3)
  extend[0] = 2. * L;      // espessura no eixo x
  origin[0] = -L;          // começa ligeiramente fora do canal
  IndicatorCuboid2D<T> inflow(extend, origin);
  superGeometry.rename(2, 3, 1, inflow);

  // 4) Marca região de saída (material 4)
  origin[0] = lengthX - L;
  IndicatorCuboid2D<T> outflow(extend, origin);
  superGeometry.rename(2, 4, 1, outflow);

  // 5) Marca o cilindro (material 5)
  superGeometry.rename(1, 5, circle);

  // 6) Limpa voxels órfãos e verifica erros
  superGeometry.clean();
  superGeometry.checkForErrors();
  superGeometry.print();
}
```

### 5.1 O Que Faz `rename(oldMat, newMat, region)`?

* **Assinatura resumida:**

  ```cpp
  void SuperGeometry::rename(
    int oldMaterial,
    int newMaterial,
    int halo = 0,
    const IndicatorF2D<T>& indicator = default
  );
  ```
* **Objetivo:** Para cada voxel cujo material atual seja `oldMaterial`, se estiver dentro da região de interesse (ou não tiver `indicator`), muda‐se para `newMaterial`.

**Variações:**

1. **`rename(old, new)`**
   Renomeia todos os voxels com material == `old` → `new`.

2. **`rename(old, new, {haloX, haloY})`**
   “Encolhe” a região de interesse por `halo` camadas (1 célula de extensão do contorno permanece com o material antigo). Por exemplo,

   ```cpp
   superGeometry.rename(2, 1, {1,1});
   ```

   Significa: entre os voxels de material 2, só renomeia aqueles que estão a pelo menos 1 célula de distância de qualquer face (isto gera o “bulk” de material 1).

3. **`rename(old, new, 1, indicatorShape)`**
   Somente renomeia voxels de material `old` que também satisfaçam `indicatorShape`. O parâmetro `1` indica o halo (geralmente 1). Exemplo:

   ```cpp
   superGeometry.rename(2, 3, 1, inflow);
   ```

   Aqui, “dentro do cubo inflow” ⨯ “antigo material == 2” → passam a material 3.

---

### 5.2 Convenção de Números de Material

| Material | Região / Finalidade                    | No Lattice                    |
| :------: | :------------------------------------- | :---------------------------- |
|     0    | Não‐inicializado (padrão após criação) | → imediatamente renomeado     |
|     2    | Canal inteiro (antes de “cortar”)      | → depois passa a 1 (bulk)     |
|     1    | Bulk interno do fluido                 | → aplicação de dinâmica BGK   |
|     3    | Fatia de entrada (inflow)              | → contorno de velocidade fixa |
|     4    | Fatia de saída (outflow)               | → contorno de pressão fixa    |
|     5    | Cilindro circular                      | → contorno curvo de Bouzidi   |

**Fluxo de Renomeações:**

1. `rename(0,2)` → todo o canal fica com material 2.
2. `rename(2,1,{1,1})` → gera “bulk” (material 1) no interior, deixando uma camada de 1 célula (material 2) ao redor.
3. `rename(2,3,1,inflow)` → dentro do “inflow cuboid”, material 2 vira material 3.
4. `rename(2,4,1,outflow)` → dentro do “outflow cuboid”, material 2 vira material 4.
5. `rename(1,5,circle)` → dentro do indicativo circular, material 1 vira material 5.

Depois, cada número de material define um tipo de dinâmica/contorno:

* **1 (bulk)** → BGKdynamics
* **2 (paredes)** → bounce‐back
* **3 (entrada)** → InterpolatedVelocity
* **4 (saída)** → InterpolatedPressure
* **5 (cilindro)** → BouzidiBoundary

---

## 6. Preparação da Malha (Lattice)

O método **`prepareLattice(...)`** faz:

```cpp
void prepareLattice(
    SuperLattice<T,DESCRIPTOR>& sLattice,
    const UnitConverter<T,DESCRIPTOR>& converter,
    SuperGeometry<T,2>& superGeometry,
    IndicatorF2D<T>& circle
) {
  // 1) Bulk (material=1) → dinâmica BGK
  sLattice.defineDynamics<BGKdynamics>(superGeometry, 1);

  // 2) Paredes (material=2) → contorno bounce‐back (no‐slip)
  boundary::set<boundary::BounceBack>(sLattice, superGeometry, 2);

  // 3) Entrada (material=3) → contorno de velocidade fixa
  boundary::set<boundary::InterpolatedVelocity>(sLattice, superGeometry, 3);

  // 4) Saída (material=4) → contorno de pressão fixa
  boundary::set<boundary::InterpolatedPressure>(sLattice, superGeometry, 4);

  // 5) Cilindro (material=5) → contorno curvo Bouzidi
  setBouzidiBoundary(sLattice, superGeometry, 5, circle);

  // 6) Condição inicial: ρ = 1, u = (0,0) em todo o bulk
  AnalyticalConst2D<T,T> rhoF(1);
  AnalyticalConst2D<T,T> uF(0, 0);

  sLattice.defineRhoU(superGeometry, 1, rhoF, uF);
  sLattice.iniEquilibrium(superGeometry, 1, rhoF, uF);

  // 7) Define frequência de relaxação ω com base na viscosidade
  sLattice.setParameter<descriptors::OMEGA>(
    converter.getLatticeRelaxationFrequency()
  );

  // 8) Inicializa os dados (e transfere para GPU se necessário)
  sLattice.initialize();
}
```

### 6.1 Dinâmicas e Condições de Contorno

* **`defineDynamics<BGKdynamics>(…, material=1)`**
  Aplica a colisão‐stream BGK em todas as células de material 1.

* **`boundary::set<BounceBack>(…, material=2)`**
  Gera o contorno no‐slip (bounce‐back) em cada célula de material 2.

* **`boundary::set<InterpolatedVelocity>(…, material=3)`**
  Força um contorno de velocidade (perfil de Poiseuille) nas células de material 3.

* **`boundary::set<InterpolatedPressure>(…, material=4)`**
  Força um contorno de pressão fixa nas células de material 4.

* **`setBouzidiBoundary(…, material=5, circle)`**
  Aplica contorno curvo de Bouzidi nas células de material 5, usando o indicativo circular.

---

## 7. Rampa de Velocidade de Entrada e Perfil de Poiseuille

No laço de tempo, o método **`setBoundaryValues(...)`**:

```cpp
void setBoundaryValues(
    SuperLattice<T,DESCRIPTOR>& sLattice,
    const UnitConverter<T,DESCRIPTOR>& converter,
    std::size_t iT,
    SuperGeometry<T,2>& superGeometry
) {
  // 1) Número de passos para rampa (40% de maxPhysT)
  std::size_t iTmaxStart = converter.getLatticeTime(maxPhysT * 0.4);
  std::size_t iTupdate  = iTmaxStart / 1000;

  // 2) Se iT % iTupdate == 0 E iT <= iTmaxStart, atualizamos
  if (iT % iTupdate == 0 && iT <= iTmaxStart) {
    // 3) Escala polinomial 0 → 1 em iTmaxStart passos
    PolynomialStartScale<T,T> StartScale(iTmaxStart, T(1));

    T iTvec[1] = { T(iT) };
    T frac[1]  = {};
    StartScale(frac, iTvec);  // frac[0] = rampa em [0,1]

    // 4) Velocidade máxima da rampa
    T maxVelocity = converter.getCharLatticeVelocity() * 1.5 * frac[0];
    T distance2Wall = L / 2.0;

    // 5) Perfil de Poiseuille (parabólico) no material 3 (entrada):
    Poiseuille2D<T> poiseuilleU(
      superGeometry,
      3,               // material ID da entrada
      maxVelocity,
      distance2Wall
    );
    sLattice.defineU(superGeometry, 3, poiseuilleU);

    // 6) Atualiza contorno no GPU (se em GPU)
    sLattice.setProcessingContext<
      Array<momenta::FixedVelocityMomentumGeneric::VELOCITY>
    >(ProcessingContext::Simulation);
  }
}
```

* **`PolynomialStartScale`** interpola suavemente de 0 a 1 em `iTmaxStart` passos.
* O perfil de Poiseuille é dado por

  $$
    u_{\text{Poiseuille}}(y) = \max Velocity \times \Bigl(1 - \bigl(\tfrac{y}{\text{semi‐altura}}\bigr)^2\Bigr).
  $$

---

## 8. Diagnóstico de Queda de Pressão & Saída VTK

A cada `vtkIter` passos, o método **`getResults(...)`**:

1. Gera arquivos VTK de pressão e velocidade (via `SuperVTMwriter2D`).
2. Imprime no console estatísticas (número de voxels, tempo, etc.).
3. Interpola a pressão em dois pontos frente/atrás do cilindro para calcular

   $$
     \Delta p = p_{\text{upstream}} - p_{\text{downstream}}.
   $$

   Pontos usados:

   ```cpp
   T point1[2] = { centerCylinderX - radiusCylinder, centerCylinderY };
   T point2[2] = { centerCylinderX + radiusCylinder, centerCylinderY };
   ```

Esse diagnóstico ajuda a verificar quando o escoamento converge para o estado estacionário ou mostra desprendimento de vórtices (para Re≈100).

---

## 9. Resumo

1. **prepareGeometry(...)** renomeia materiais para particionar o domínio:

   * **0 → 2**: canal bruto
   * **2 → 1**: bulk interno (com halo de 1 célula)
   * **2 → 3**: fatia de entrada (inflow)
   * **2 → 4**: fatia de saída (outflow)
   * **1 → 5**: cilindro circular

2. **prepareLattice(...)** define:

   * Bulk (material 1) → BGK
   * Paredes (material 2) → bounce‐back
   * Entrada (material 3) → InterpolatedVelocity
   * Saída (material 4) → InterpolatedPressure
   * Cilindro (material 5) → BouzidiBoundary

3. Laço principal:

   * Rampa de velocidade (Poiseuille)
   * `collideAndStream()`
   * Geração de VTK + diagnóstico Δp

---

## 10. Explorações Finais

* **Alterar número de Reynolds (Re):**
  Modifique no código `const T Re = 20.` para `100` para observar desprendimento de vórtices.

* **Ajustar resolução de malha (N):**
  `const int N = 10;` controla quantas células‐lattice por unidade física. Aumente para “refinar” a malha (e custo computacional).

* **Trocar esquemas de contorno:**
  Experimente substituir Bouzidi (material 5) por bounce‐back simples ou contorno “interpolated halfway” para comparar precisão.

---

## 11. Script `setup.sh`

Para facilitar a configuração e compilação do exemplo, crie um arquivo `setup.sh` na raiz do seu repositório com o seguinte conteúdo:

```bash
#!/usr/bin/env bash
# install_openlb_wsl.sh
# --------------------------------------------------------------
# Installs dependencies and OpenLB on WSL Ubuntu 24.04, including:
#   • Linuxbrew + brew-installed Python 3
#   • gcc, make, git, OpenMPI, etc.
#   • ParaView 6.0.0-RC1 via wget
#   • Qt “xcb” dependencies (if Paraview fails to start)
#   • Clones OpenLB and applies cpu_gcc_openmpi.mk → config.mk
# --------------------------------------------------------------

set -e
set -o pipefail

echo "==> 1) Update apt repositories..."
sudo apt update

echo "==> 2) Install build tools, git, wget, tar, OpenMPI, etc. via apt..."
sudo apt install -y \
    build-essential \
    git \
    wget \
    tar \
    libopenmpi-dev \
    openmpi-bin \
    cmake \
    pkg-config

# ------------------------------------------------------------
# 3) Install Linuxbrew (if missing) & brew-installed Python 3
# ------------------------------------------------------------
if ! command -v brew >/dev/null 2>&1; then
  echo "==> Linuxbrew not found—installing now..."
  # Install Linuxbrew
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Add brew to PATH in this shell (adjust if your distro uses ~/.bash_profile or ~/.zshrc)
  echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
else
  echo "==> Linuxbrew already installed."
fi

echo "==> 4) Using brew to install Python 3..."
sudo apt remove --purge python3
sudo apt autoremove 
brew update
brew install python3

# Make brew’s python3 the default in this session
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Confirm
echo "    • brew python3 location: $(which python3)"
echo "    • python3 version:       $(python3 --version)"
echo

# ------------------------------------------------------------
# 5) Download & Install ParaView 6.0.0-RC1 (via wget)
# ------------------------------------------------------------
PARAVIEW_VERSION="6.0.0-RC1"
PARAVIEW_DIR="/opt/paraview/${PARAVIEW_VERSION}"
PARAVIEW_TARBALL="ParaView-6.0.0-RC1-MPI-Linux-Python3.12-x86_64.tar.gz"
PARAVIEW_URL="https://www.paraview.org/paraview-downloads/download.php?submit=Download&version=v6.0&type=binary&os=Linux&downloadFile=${PARAVIEW_TARBALL}"

echo "==> 6) Downloading ParaView ${PARAVIEW_VERSION}..."
cd /tmp

# Quote the URL so that '&' isn’t interpreted by bash
wget -O "${PARAVIEW_TARBALL}" \
  "${PARAVIEW_URL}"

echo "==> 7) Extracting ParaView into ${PARAVIEW_DIR}..."
sudo mkdir -p "${PARAVIEW_DIR}"
sudo tar --strip-components=1 -xzf "${PARAVIEW_TARBALL}" -C "${PARAVIEW_DIR}"

echo "==> 8) Creating symlink /usr/local/bin/paraview → ${PARAVIEW_DIR}/bin/paraview..."
sudo ln -sf "${PARAVIEW_DIR}/bin/paraview" /usr/local/bin/paraview

echo "==> 9) Cleaning up temporary tarball..."
rm -f "/tmp/${PARAVIEW_TARBALL}"
cd ~

# ------------------------------------------------------------
# 10) Quick check: try launching `paraview --help`. If it fails,
#     install the Qt “xcb” plugin dependencies.
# ------------------------------------------------------------
echo "==> 10) Verifying ParaView can start (checks for missing Qt plugins)..."
if ! paraview --help >/dev/null 2>&1; then
  echo "    • Paraview failed to run → installing Qt/XCB dependencies via apt..."
  sudo apt update
  sudo apt install -y \
    libxcb-cursor0 \
    libxcb-keysyms1 \
    libxcb-util1 \
    libxcb-icccm4 \
    libxcb-image0 \
    libxcb-render-util0 \
    libxcb-render0 \
    libxcb-shape0 \
    libxcb-sync1 \
    libxcb-xfixes0 \
    libxcb-xinerama0 \
    libxcb-xkb1 \
    libxkbcommon-x11-0 \
    libx11-xcb1 \
    libglu1-mesa \
    libgl1-mesa-dri
  echo "    • Qt/XCB dependencies installed."
else
  echo "    • Paraview launched successfully (Qt plugins OK)."
fi
echo

# ------------------------------------------------------------
# 11) Clone OpenLB repository (if missing) and set config.mk
# ------------------------------------------------------------
OPENLB_DIR="$HOME/openlb"
if [ -d "${OPENLB_DIR}" ]; then
  echo "==> 11) ${OPENLB_DIR} already exists; skipping clone."
else
  echo "==> 11) Cloning OpenLB into ${OPENLB_DIR}..."
  git clone https://gitlab.com/openlb/release.git "${OPENLB_DIR}"
fi

echo "==> 12) Overwriting OpenLB config.mk with cpu_gcc_openmpi.mk..."
cp -f "${OPENLB_DIR}/config/cpu_gcc_openmpi.mk" "${OPENLB_DIR}/config.mk"

echo
echo "============================================================="
echo "OpenLB installation complete!"
echo
echo "  • brew python3:  $(python3 --version)"
echo "  • ParaView:      /usr/local/bin/paraview  (version ${PARAVIEW_VERSION})"
echo "  • OpenMPI:       $(mpicxx --version | head -n1)"
echo "  • OpenLB root:   ${OPENLB_DIR} (using config.mk → cpu_gcc_openmpi.mk)"
echo "============================================================="

```

### 11.1 Como usar o `setup.sh`

1. Copie o script acima para **`setup.sh`** na raiz do seu repositório (onde está o diretório do OpenLB).
2. Torne-o executável:

   ```bash
   chmod +x setup.sh
   ```
3. Defina a variável de ambiente `OLB_ROOT` apontando para o diretório raiz do OpenLB.

   ```bash
   export OLB_ROOT="/caminho/para/openlb"
   ```
4. Execute:

   ```bash
   ./setup.sh
   ```

   Isso irá gerar o executável `cylinder2d` dentro de `build/examples/forBeginners/`.

---

