
# Tarefa

#  Compilação e Execução Inicial

Primeiramente, vamos compilar e executar o código com seus parâmetros padrão. Este primeiro passo irá calcular o campo de escoamento do fluido em regime permanente e salvá-lo em disco. As execuções futuras carregarão este campo, acelerando a simulação da fase particulada.

1.  **Navegue até o diretório do exemplo** no seu terminal.
    ```bash
    cd examples/particles/bifurcation3d/eulerLagrange
     ```

2.  **Copie e cole os seguintes comandos** para limpar compilações anteriores, compilar o código e executá-lo em paralelo com 4 processadores:

    ```bash
    make clean; make
    mpirun -np 4 ./bifurcation3d
    ```

## Visualização no ParaView

1.  Abra o ParaView.
2.  Abra o arquivo `bifurcation3d.pvd` para visualizar o fluido. Clique no botão **Apply** no painel *Properties*.
3.  Abra também o arquivo `particles_master.pvd` para as partículas. Clique em **Apply**.
4.  Para visualizar o campo de velocidade, selecione `bifurcation3d.pvd` no *Pipeline Browser* e aplique o filtro **Slice**. No painel *Properties* do filtro, defina o "Normal" como sendo o eixo **Y**. 

<figure markdown="span">
![figura](https://www.openlb.net/wp-content/uploads/2017/01/bifurcation.png)
<figcaption>Exemplo de visualização de partículas e linhas de corrente em uma bifurcação. (Imagem: OpenLB)</figcaption>
</figure>

### 4.3 · Modificando o Raio e Analisando o Efeito

O **número de Stokes ($St$)** é a principal variável que dita o comportamento das partículas. Ele representa a razão entre o tempo característico de resposta da partícula e o tempo característico do escoamento. Conforme definido no código, ele é proporcional ao quadrado do raio da partícula ($r^2$):

$$\operatorname{St} = \frac{2 \rho_p r^2 U}{9 \mu L}$$

Vamos agora testar diferentes raios para observar essa dependência.

#### Tarefa : Aumentando a Inércia (Raio Maior)

1.  **Modifique o código:** Abra o arquivo `bifurcation3d.cpp` em um editor de texto. Localize a linha que define o raio e altere o valor para `4.0e-4`.

    ```cpp
    // Modifique esta linha
    const T radius = 4.0e-4;            // particles radius
    ```

2.  **Recompile e Execute:** Como o arquivo da solução do fluido já existe, esta execução será muito mais rápida.

    ```bash
    make && mpirun -np 4 ./bifurcation3d
    ```

3.  **Análise:** Visualize o novo `particles_master.pvd` no ParaView. Observe que, com maior inércia, um número significativamente maior de partículas colide com a parede logo no início da bifurcação e não consegue passar para as saídas. A taxa de escape é menor.

#### Cenário 3: Diminuindo a Inércia (Raio Menor)

1.  **Modifique o código:** Altere o valor do raio para `1.5e-5`.

    ```cpp
    // Modifique esta linha
    const T radius = 1.5e-5;            // particles radius
    ```

2.  **Recompile e Execute:**

    ```bash
    make && mpirun -np 4 ./bifurcation3d
    ```

3.  **Análise:** Visualize os resultados. Com inércia muito baixa, as partículas seguem as linhas de corrente do fluido de forma muito mais fiel. A maioria das partículas deve conseguir passar pela bifurcação, resultando em uma alta taxa de escape, com a divisão entre as saídas se aproximando da divisão do fluxo de massa do próprio fluido.