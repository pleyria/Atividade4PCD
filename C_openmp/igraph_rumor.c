#include <stdio.h>
#include <stdlib.h>
#include <igraph.h>
#include <omp.h>

// parametros da simulacao
#define num_vertices 5000
#define tmax 2000

int calcula_n0(igraph_t rede, igraph_integer_t v, int* tipo){
  int x, n0 = 0;
  igraph_vector_t vizinhos;

  igraph_vector_init(&vizinhos, 1);

  igraph_neighbors(&rede, &vizinhos, v, IGRAPH_ALL);
  for(x = 0; x < igraph_vector_size(&vizinhos); x++){
    if(tipo[(long) VECTOR(vizinhos)[x]] == 0)
      n0++;
  }
  igraph_vector_destroy(&vizinhos);
  return n0;
}

int calcula_n1(igraph_t rede, igraph_integer_t v, int* tipo){
  int n1, grau, x;
  float a;
  long maior;
  igraph_integer_t max;
  igraph_vector_t vizinhos;
  igraph_vector_t deg;
  igraph_vs_t vs;

  n1 = 0;
  igraph_maxdegree(&rede, &max, igraph_vss_all(), IGRAPH_ALL, 0);
  maior = max;

  igraph_vector_init(&vizinhos, 1);
  igraph_neighbors(&rede, &vizinhos, v, IGRAPH_ALL);

  igraph_vector_init(&deg, 1);

  for(x = 0; x < igraph_vector_size(&vizinhos); x++){
    igraph_vs_1(&vs, x);
    igraph_degree(&rede, &deg, vs, IGRAPH_ALL, IGRAPH_NO_LOOPS);
    a = (float)rand()/RAND_MAX;
    if(a < (float) VECTOR(deg)[0]/maior && tipo[x] == 1)
      n1++;
  }
  igraph_vector_destroy(&vizinhos);
  igraph_vector_destroy(&deg);

  return n1;
}

int calcula_n2(igraph_t rede, igraph_integer_t v, int* tipo){
  int n2, grau, x;
  float a;
  long maior;
  igraph_integer_t max;
  igraph_vector_t vizinhos;
  igraph_vector_t deg;
  igraph_vs_t vs;

  n2 = 0;
  igraph_maxdegree(&rede, &max, igraph_vss_all(), IGRAPH_ALL, 0);
  maior = max;

  igraph_vector_init(&vizinhos, 1);
  igraph_neighbors(&rede, &vizinhos, v, IGRAPH_ALL);

  igraph_vector_init(&deg, 1);

  for(x = 0; x < igraph_vector_size(&vizinhos); x++){
    igraph_vs_1(&vs, x);
    igraph_degree(&rede, &deg, vs, IGRAPH_ALL, IGRAPH_NO_LOOPS);
    a = (float)rand()/RAND_MAX;
    if(a < (float) VECTOR(deg)[0]/maior && tipo[x] == 2)
      n2++;
  }
  igraph_vector_destroy(&vizinhos);
  igraph_vector_destroy(&deg);

  return n2;
}

int muda_estado(igraph_t rede, igraph_integer_t v, int* tipo){
  int n1, n2, n0, total, x;
  n0 = calcula_n0(rede, v, tipo);
  n1 = calcula_n1(rede, v, tipo);
  n2 = calcula_n2(rede, v, tipo);
  total = n0 + n1 + n2;
  if(total == 0)
    return 0;
  x = rand() % total + 1;
  if(x <= n0)
    return 0;
  else{
    if(x > n0 + n1)
      return 2;
    else
      return 1;
  }
}

int main() {
  igraph_t rede;

  int min, max, t1, t2, t0, i, j, pmax, q0, q1, q2, a;

  double start, end;

  // estruturas auxiliares
  int tipo[num_vertices];
  int new_tipo[num_vertices];
  int quant_tipo0[num_vertices];
  int quant_tipo1[num_vertices];
  int quant_tipo2[num_vertices];
  int tempo[tmax];
  igraph_vector_t deg;

  // Define o numero de threads
  omp_set_num_threads(8);

  // rede livre de escala
  igraph_barabasi_game(&rede, num_vertices, 1, 2, NULL, 0, 1, 0, IGRAPH_BARABASI_PSUMTREE, NULL);

  start = omp_get_wtime();

  printf("Inicializando o grafo...\n");

  // valores iniciais
  pmax = 4;
  // t1 e t2 comecam entre 1% e pmax% dos nos
  min = num_vertices/100;
  max = pmax * num_vertices/100;
  t1 = rand() % (max + 1 - min) + min;
  t2 = rand() % (max + 1 - min) + min;
  t0 = num_vertices - t1 - t2;

  for(i=0; i < num_vertices; i++)
    tipo[i] = 0;

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

  printf("Executando a simulacao...\n");

  igraph_vector_init(&deg, 1);
  igraph_degree(&rede, &deg, igraph_vss_all(), IGRAPH_ALL, IGRAPH_NO_LOOPS);

  // simulacao
  i = 1;
  for(i = 1; i < tmax; i++){
    q0 = 0;
    q1 = 0;
    q2 = 0;
    j = 0;

    for(j = 0; j < num_vertices; j++){
      if(tipo[j] == 0 && (long) VECTOR(deg)[j] > 0)
        new_tipo[j] = muda_estado(rede, j, tipo);
      else
        new_tipo[j] = tipo[j];
    }
#pragma omp parallel for reduction(+: q0, q1, q2)
    for(j = 0; j < num_vertices; j++){
      tipo[j] = new_tipo[j];
      switch(tipo[j]){
        case 0:
          q0++;
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
    //printf("i = %d\n", i);
  }
  end = omp_get_wtime();

  igraph_vector_destroy(&deg);
  igraph_destroy(&rede);

  printf("Simulacao finalizada!\n");
  printf("n0 = %d\n", q0);
  printf("n1 = %d\n", q1);
  printf("n2 = %d\n", q2);
  printf("total = %d\n", q0+q1+q2);

  printf("Tempo de execucao = %.12lf segundos\n", end-start);

  return 0;
}