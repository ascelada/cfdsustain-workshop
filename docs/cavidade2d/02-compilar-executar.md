# Compilação e Execução

!!! note "Limpeza e build"
    ```bash
    make clean && make
    ```

!!! note "Execução em 2 processos MPI"
    ```bash
    mpirun -np 2 cavity2d      # ou mpiexec conforme seu ambiente
    ```

Os resultados VTK serão escritos em **`tmp/vtkData/cavity2d/`**.

## Visualização no ParaView

1. Abra *ParaView* → **File ▸ Open** → `cavity2d.pvd`.
2. Clique **Apply** e pressione *Play* na timeline.
3. Use filtros como **Glyph** ou **Stream Tracer** para examinar o campo de velocidades.
