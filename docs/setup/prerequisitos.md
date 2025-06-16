# 2. Pré-requisitos

Para compilar e executar o exemplo **Cylinder2D**, certifique-se de ter:

1. **OpenLB instalado e compilado** com as bibliotecas necessárias (MPI, CUDA, etc.).  
2. **Compilador C++20 ou superior** (por exemplo, `clang 19` ou `g++ -std=c++20`).  
3. O arquivo `examples/forBeginners/cylinder2d.cpp` deve estar disponível no diretório de trabalho do OpenLB.  

Opcionalmente, para usar GPU ou MPI:

- **CUDA Toolkit** instalado e configurado (se for rodar em GPU).
- **OpenMPI** disponível no sistema (se for compilado com suporte MPI).
