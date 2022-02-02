# Implementação em Cython
Cython é um superconjunto da linguagem Python que apresenta todas as funcionalidades já esperadas do Python e a possibilidade de utilziar variáveis e estruturas da linguagem C, com compliação e otimização para trechos de código a serem executados pelo compilador C e, assim, ganhar desempenho.

# Requisitos
Para compilar e executar este projeto é preciso ter os seguintes pacotes Cython e Matplotlib instalados.

# Arquivos
* O arquivo `rumor.pyx`contém o programa principal com código em python e utilizando funcionalidades da linguagem C.

* O arquivo `setup.py` contém o código para incluir o código encontrado em `rumor.pyx` na execução do interpretador python. Este arquivo também acrescenta alguns parâmetros especiais para execução, incluindo a adição da biblioteca OpenMP para o compilador de código C.

* O arquivo `run.py` chama o código executável gerado a partir dos dois outros arquivos descritos anteriormente. Este arquivo que deve ser usado para executar e testar o programa.

# Compilação e Execução
Para compilar o programa, os arquivos `rumor.pyx` e `setup.py` devem estar no mesmo diretório. Então, no linux, basta executar o seguinte comando:

> python3 setup.py build_ext --inplace

Isso irá gerar os seguintes arquivos/diretórios:

* `build`: Pasta com informações a cerca do código produzido pelo Cython. Pode ser ignorado.

* `rumor.c`: Código fonte em lignuagem C do programa.

* `rumor.html`: Arquivo html que pode ser aberto em um navegador para ver as alterações que o Cython aplicou no código python durante a compilação.

* `rumor.cpython-38-x86_64-linux-gnu.so`: Arquivo *shared object* que é utilizado para executar o programa gerado pelo Cython. O único arquivo que deve estar presente para a execução do programa, após a compilação.

Então, para executar o programa, basta utilizar o seguinte comando:

> Python3 run.py
