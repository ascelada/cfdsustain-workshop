# 1. Visão Geral

O exemplo **Cylinder2D** simula um escoamento fluido (estacionário ou transiente) ao redor de um cilindro circular dentro de um canal retangular.  
Principais elementos:

- **Entrada com perfil de Poiseuille** (velocidade fixa) no lado esquerdo.  
- **Saída de pressão fixa** no lado direito.  
- **Contorno no-slip** nas paredes do canal (utilizando bounce-back).  
- **Cilindro circular** modelado via contorno curvo de Bouzidi.

Ao término da inicialização, o programa executa até o tempo físico definido e gera:

1. **Arquivos VTK** de velocidade e pressão (periodicamente).  
2. **Diagnósticos de queda de pressão** (impresso no console a cada intervalo).

Este exemplo ilustra como:

- Construir e renomear a geometria  
- Atribuir dinâmicas LB e contornos conforme materiais  
- Rampa de velocidade de entrada  
- Calcular queda de pressão no cilindro
