#include <stdio.h>
#include <stdlib.h>
#include <igraph.h>
#include <omp.h>

#define num_vertices 5000
#define tmax 2000

int calcula_n0(igraph_t rede, igraph_integer_t v, int* tipo){
  int x, n0 = 0;
  igraph_vector_t vizinhos;

  igraph_vector_init(&vizinhos, 1);

  igraph_neighbors(&rede, &vizinhos, v, IGRAPH_ALL);
  for(x = 0 ; x < igraph_vector_size(&vizinhos); i++){
    if(tipo[(long) VECTOR(vizinhos)[i]] == 0):
      n0++;
  }
  igraph_destroy(&vizinhos);
  return n0;
}

int calcula_n1(igraph_t rede, igraph_integer_t v, int* tipo){
  int x, n1 = 0;
  igraph_vector_t vizinhos;

  igraph_vector_init(&vizinhos, 1);

  igraph_neighbors(&rede, &vizinhos, v, IGRAPH_ALL);
  for(x = 0 ; x < igraph_vector_size(&vizinhos); i++){
    if(tipo[(long int) VECTOR(vizinhos)[i]] == 1):
      n1++;
  }
  igraph_destroy(&vizinhos);
  return n1;
}

int calcula_n1(igraph_t rede, igraph_integer_t v, int* tipo){
  int n1, grau, x;
  flot a;
  long maior;
  igraph_integer_t max;
  igraph_vector_t vizinhos;
  igraph_vector_t deg;

  n1 = 0;
  igraph_maxdegree(&rede, &max, igraph_vss_all(), IGRAPH_ALL, 0);

  igraph_vector_init(&vizinhos, 1);
  igraph_neighbors(&rede, &vizinhos, v, IGRAPH_ALL);

  for(x = 0; x < igraph_vector_size(&vizinhos); x++){
    igraph_degree(&rede, &deg, x, IGRAPH_ALL, IGRAPH_NO_LOOPS);
    a = (float)rand()/RAND_MAX;
    if(a < (float) VECTOR(deg)[0]/maior && tipo[x] == 1)
      n1++
  }
  return n1;
}

int calcula_n2(igraph_t rede, igraph_integer_t v, int* tipo){
  int n2, grau, x;
  flot a;
  long maior;
  igraph_integer_t max;
  igraph_vector_t vizinhos;
  igraph_vector_t deg;

  n2 = 0;
  igraph_maxdegree(&rede, &max, igraph_vss_all(), IGRAPH_ALL, 0);

  igraph_vector_init(&vizinhos, 1);
  igraph_neighbors(&rede, &vizinhos, v, IGRAPH_ALL);

  for(x = 0; x < igraph_vector_size(&vizinhos); x++){
    igraph_degree(&rede, &deg, x, IGRAPH_ALL, IGRAPH_NO_LOOPS);
    a = (float)rand()/RAND_MAX;
    if(a < (float) VECTOR(deg)[0]/maior && tipo[x] == 1)
      n2++
  }
  return n2;
}

int main() {
  igraph_t rede;

  int min, max, t1, t2, t0, i, j, pmax, q0, q1, q2;

  # estruturas auxiliares
  int tipo[num_vertices];
  int tipo new_tipo[num_vertices];
  int quant_tipo0[num_vertices];
  int quant_tipo1[num_vertices];
  int quant_tipo2[num_vertices];
  int tempo[tmax];

  // rede livre de escala
  igraph_barabasi_game(&rede, num_vertices, 1, 2, NULL, NULL, 1, 0, IGRAPH_BARABASI_PSUMTREE, NULL);

  printf("Inicializando o grafo...");

  // valores iniciais
  pmax = 3;
  // t1 e t2 comecam entre 1% e pmax% dos nos
  min = num_vertices/100;
  max = pmax * num_vertices/100;
  t1 = rand() % (max + 1 - min) + min;
  t2 = rand() % (max + 1 - min) + min;
  t0 = num_vertices - t1 - t2;

  for(i=0; i < num_vertices; i++)
    tipo[í] = 0;

  // tipos
  i = 0;
  while(i < t1){
    a = rand() % num_vertices;
    while(tipo[a] != 0)
      a = rand() % num_vertices;
    tipo[a] = 1;
    i++;
  }
  i = 0;
  while(i < t2){
     a = rand() % num_vertices;
    while(tipo[a] != 0)
      a = rand() % num_vertices;
    tipo[a] = 2;
    i++; 
  }

  quant_tipo0[0] = t0;
  quant_tipo1[0] = t1;
  quant_tipo2[0] = t2;
  tempo[0] = 0;

  printf("Executando a simulacao...");

  igraph_vector_t deg;

  // simulacao
  i = 1
  for(i = 1; i < tmax; i++){
    q0 = 0;
    q1 = 0;
    q2 = 0;
    j = 0;
    igraph_degree(&rede, &deg, igraph_vss_all(), IGRAPH_ALL, IGRAPH_NO_LOOPS);
    for(j = 0; j < num_vertices; j++){
      if(tipo[j] == 0 && (long) VECTOR(deg)[j] > 0){
        new_tipo[j] = muda_estado(rede, j);
      }
    }
    // colocar omp parallel aqui
    for(j = 0; j < num_vertices; j++){
      tipo[j] = new_tipo[j];
      switch(tipo[j]){
        case 0:
          q0++
          break;
        case 1:
          q1++;
          break;
        default:
          q2++;
          break;
      }
    }
    tempo[i] = i;
    quant_tipo0[i] = q0;
    quant_tipo1[i] = q1;
    quant_tipo2[i] = q2;
    printf("i = %d\n", i)
  }

  printf("Simulacao finalizada!\n");
  pritnf("n0 = %d\n", q0);
  printf("n1 = %d\n", q1);
  printf("n2 = %d\n", q2);
  printf("total = %d\n", q0+q1+q2);
}