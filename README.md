# Atividade 4 - Programação Concorrente e Distribuída

## Descrição
Este projeto é parte da disciplina Programação Concorrente e Distribuída e tem como objetivo implementar e comparar o desenpenho de técnicas de programação *multithreaded* em um programa desenvolvido previamente. O programa no qual as melhorias são testadas é uma simulação, em linguagem Python, da propagação de um rumor em uma rede social, representada por um grafo. Este código foi desenvolvido no primeiro semestre de 2019, na disciplina Modelagem Computacional.

O código do programa original, em Python, pode ser encontrado no arquivo `rumor_old.py`.

O diretório `Cython` contém uma implementação do problema original em linguagem Python, utilizando a biblioteca Cython, que converte parte do código para linguagem C, permitindo a implementação de um certo grau de paralelismo.

O diretório `C_openmp` contém um implementação do problema orignal em linguagem C, utilizando recursos OpenMP para implementação de execução paralela.

Todas as três versões disponíveis neste repositório usam a mesma biblioteca igraph (disponível em Python e C) para manipular a estrutura de dados de grafos.

## Resultados
Resultados de teste de desmepenho dos alogritmos disponíveis [nesta tabela](https://docs.google.com/spreadsheets/d/1et7R4TficKX_tw7l7peO5Njs3813JhO5R7RAzD1qyGU/edit?usp=sharing).

O vídeo explicativo do trabalho pode ser encontrado [neste link](https://drive.google.com/file/d/1_IpASHpXv5byaNRbje1iFb1crEN14Sbj/view?usp=sharing).

## Referências
* https://igraph.org/
* https://cmake.org/
* https://www.openmp.org/
* https://cython.org/
