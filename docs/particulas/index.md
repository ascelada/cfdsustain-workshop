# Escoamento em Bifurcação – Abordagem Euler-Lagrange


> **Visão geral**  
> Um fluido incompressível escoando através de uma bifurcação em regime permanente.  
> As partículas (fase dispersa) são rastreadas individualmente; quando tocam a parede aderente, são
> removidas do domínio (*capture by adhesion*).

---

## 1 · Formulação Euler-Lagrange

### 1.1 Fase Euleriana (Fluido)

- Equações de Navier–Stokes incomp. em regime permanente  
  $$
    \nabla\\cdot\\mathbf{u}=0,\qquad
    \rho(\mathbf{u}\\cdot\\nabla)\mathbf{u} = -\nabla p + \mu\nabla^2\mathbf{u}.
  $$
- Condições de contorno  
  - **Entrada**: perfil totalmente desenvolvido ou velocidade média $U_{\text{in}}$.  
  - **Saídas**: condição de pressão (\(p=p_{\text{ref}}\)).  
  - **Paredes**: não-deslizamento \((\mathbf{u}=0)\).

*Observação*: Como o interesse está na dinâmica das partículas, o campo de escoamento é resolvido apenas uma vez, até convergir para o regime permanente — evitando recálculo a cada *time step*.

### 1.2 Fase Lagrangiana (Partículas)

Para cada partícula $i$:

\[
  m_i\frac{d\mathbf{v}_i}{dt} = \mathbf{F}_{\text{drag}} + \mathbf{F}_{\text{grav}} + \dots
\]

- **Inércia da partícula**  
  $$
    \operatorname{St} = \frac{\rho_p r_i^2}{18\mu}\,\frac{|\mathbf{u}|}{L}
  $$
  determina quão bem a partícula segue o fluido — valores altos indicam maior desvio das linhas de corrente.



<figure markdown="span">
  ![Particulas](img/PIV_Tracking_R1.gif)
  <figcaption>By Fzigunov - Own work, CC BY-SA 4.0, https://commons.wikimedia.org/w/index.php?curid=115917430</figcaption>
</figure>


---

## 2 · Condição de Parede Adesiva

- Quando a distância centro-parede $d_i \le r_i$  
  → **colisão adesiva** ⇒ remover partícula do domínio.  
- Sem ressalto nem fragmentação; partículas capturadas não retornam ao escoamento.

---

## 3 · Estratégia Numérica

1. **Solver do fluido**  
    - Rodar até critério de convergência.  
    - Exportar campo de velocidade em regime permanente $\mathbf{u}(\mathbf{x})$.  

2. **Loop temporal da fase dispersa**  
    - Para cada *time step* $\Delta t$  
        1. Interpolar $\mathbf{u}$ nas posições das partículas.  
        2. Integrar equações de movimento.  
        3. Verificar colisão com parede; remover se aderida.  

3. **Condição de parada**  
     - Não restam partículas, ou tempo físico máximo alcançado.  

---