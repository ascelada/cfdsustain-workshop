# Estudo de Parâmetros (Reynolds)

Altere a viscosidade em `cavity2d.cpp`:

```cpp title="Trecho relevante"
const T physViscosity = 0.001;  // exemplo: Re ≈ 100
```

??? note
    Lembre-se que 
    $$
    Re = \frac{L\,U_{\text{lid}}}{\nu}.
    $$


| Caso | \(\nu\) (m²/s) | \(Re\) esperado | Observação |
|----:|--------------:|---------------:|:-----------|
| A | 0.001 | 1000 | Solução estável |
| B | 1e‑4  | 1×10⁴ | Instabilidade numérica |

!!! tip "Recompilar e rodar"
    ```bash
    make && mpirun -np 2 cavity2d
    ```

Para \(Re = 10^4\) o código diverge. Veja [*Diagnósticos*](05-diagnosticos.md) para estratégias de estabilidade.
