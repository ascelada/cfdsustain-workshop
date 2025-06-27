# Workshop CFDSUSTAIN - OpenLB

Bem-vindo ao repositório do Workshop CFDSUSTAIN, focado em simulações de Dinâmica dos Fluidos Computacional (CFD) utilizando a biblioteca OpenLB.

## Descrição

Este workshop foi projetado para fornecer uma introdução prática ao OpenLB, com exemplos que abrangem desde escoamentos clássicos até simulações com partículas. Os participantes aprenderão a configurar, executar e modificar simulações, bem como a visualizar e analisar os resultados.

## Pré-requisitos

Antes de começar, certifique-se de que possui os seguintes pré-requisitos:

* **OpenLB:** A biblioteca OpenLB deve estar instalada e compilada.
* **Compilador C++:** Um compilador C++20 ou superior (ex: `g++` ou `clang`).
* **MPI:** Uma implementação de MPI como o OpenMPI para execução em paralelo.
* **ParaView:** Para visualização dos resultados.

## Setup e Instalação

O repositório inclui um script `setup.sh` que automatiza a instalação de todas as dependências necessárias, incluindo OpenLB, ParaView e Python, em um ambiente WSL (Windows Subsystem for Linux) Ubuntu.

Para utilizar o script:

1.  Clone o repositório:
    ```bash
    git clone [https://github.com/cfdsustain/cfdsustain-workshop.git](https://github.com/cfdsustain/cfdsustain-workshop.git)
    cd cfdsustain-workshop
    ```

2.  Dê permissão de execução ao script:
    ```bash
    chmod +x setup.sh
    ```

3.  Execute o script:
    ```bash
    ./setup.sh
    ```
O script irá:
* Atualizar os repositórios `apt`.
* Instalar ferramentas de compilação, `git`, `wget`, `tar`, e `OpenMPI`.
* Instalar o Linuxbrew e o Python 3.
* Baixar e instalar o ParaView.
* Verificar as dependências do Qt para o ParaView.
* Clonar o repositório do OpenLB.
* Configurar o OpenLB para compilação com GCC e OpenMPI.

## Módulos do Workshop

O workshop é dividido nos seguintes módulos:

### 1. Cavidade 2D (Lid-Driven Cavity)

Este é um caso de teste clássico em CFD. Um fluido é confinado em uma cavidade quadrada onde a tampa superior se move com uma velocidade constante, gerando vórtices no interior da cavidade. Este exemplo é usado para estudar o efeito do número de Reynolds no escoamento.

### 2. Cilindro 2D

Este módulo explora o escoamento laminar em torno de um cilindro dentro de um canal 2D. Os objetivos incluem:
* Entender como renomear materiais e aplicar diferentes condições de contorno no OpenLB.
* Medir a queda de pressão ao redor do obstáculo.
* Substituir o cilindro por outros objetos e comparar os resultados.

### 3. Bifurcação com Partículas

Este exemplo aborda um escoamento em uma bifurcação utilizando uma abordagem Euler-Lagrange. A fase fluida é resolvida para o regime permanente, e então partículas (fase dispersa) são rastreadas através do domínio. Este módulo é útil para entender simulações de escoamentos multifásicos.

## Como Executar os Exemplos

Para compilar e executar os exemplos, siga os passos abaixo:

1.  Navegue até o diretório do exemplo desejado. Por exemplo, para o caso do cilindro 2D:
    ```bash
    cd $OLB_ROOT/examples/forBeginners/cylinder2d
    ```

2.  Limpe, compile e execute o código. Por exemplo:
    ```bash
    make clean && make
    mpirun -np 4 ./cylinder2d
    ```

3.  Os resultados serão gerados em formato VTK, que podem ser abertos e visualizados com o ParaView.

## Documentação

A documentação detalhada para cada módulo está disponível no diretório `docs/` e é servida como um site MkDocs.

### Deploy da Documentação

O repositório está configurado com um workflow de GitHub Actions (`.github/workflows/deploy.yml`) que faz o deploy automático da documentação para o GitHub Pages sempre que há um push para o branch `main` ou `master`.
