# Problema de Cavidade Quadrada

O problema da cavidade quadrada (lid‑driven cavity) é um caso‑teste clássico em dinâmica dos fluidos computacional (CFD). 

Um fluido incompressível e Newtoniano é confinado em uma cavidade quadrada de paredes rígidas; somente a tampa superior se move com velocidade constante $U_{\text{lid}}$, arrastando o fluido e gerando uma estrutura de vórtices característica cujo desenvolvimento depende essencialmente do número de Reynolds.

![Esquema da cavidade](img/cavity2d.png)

## Condições de contorno

| Parede | Velocidade prescrita | Observação            |
|-------:|:--------------------|:----------------------|
| Tampa  | U,V= (1 m/s, 0)  | *Lid‑driven*          |
| Laterais e base | U,V = (0, 0) | Não‑deslizamento |

- Comprimento característico: $L = 1\,\text{m}$
- Massa específica: $\rho = 1\,\text{kg/m³}$
- Viscosidade cinemática $\nu$ variável

O número de Reynolds é dado por:

$$
  Re = \frac{L\,U_{\text{lid}}}{\nu}.
$$
