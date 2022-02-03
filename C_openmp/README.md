# Implementação em C com OpenMP

# Requisitos
Para compilar e executar este projeto é preciso ter um compilador C, a ferramenta CMake e a biblioteca igraph C instalados.

# Arquivos
* O arquivo `igraph_rumor.c` contém o programa principal com código em C.

* O arquivo `CMakeLists.txt` contém os parâmetros necessários para compilação usando o CMake.

# Compilação e execução
Para compilar, siga os passos a seguir:

* Vá para o diretório onde estão os arquivos `igraph_rumor.c` e `CMakeLists.txt`.
> cd C_openmp

* Crie um novo diretório chamado `build` e vá para ele.
> mkdir build

> cd build

* Execute CMake para configurar o projeto.
> cmake ..

* Se a configuração foi bem-sucedida, construa o programa.
> cmake --build .

Neste processo, vários arquivos serão gerados dentro do diretório `buil`. O arquivo `rumor_exec` é o arquivo executável do projeto e pode ser movido para outro local. Os demais arquivos produzidos podem ser ignorados e apagados.
> ./igraph_rumor