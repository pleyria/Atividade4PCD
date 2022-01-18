'''
Propagacao de rumor - tipos de pessoas:
tipo 0: nao conhece o rumor, mas pode saber se tiver contato com pessoas
do tipo 1 ou do tipo 2, noa influencia outras pessoas
tipo 1: conhece o rumor, acredita nela e influencia os outros a acreditar, nao
pode mudar de tipo
tipo 2: conhece o rumor, nao acredita nela e influencia os outros a nao 
acreditar, nao pode mudar de tipo
'''
import random
import igraph
import matplotlib.pyplot as plt
from cython.parallel import prange
from cpython.mem cimport PyMem_Malloc, PyMem_Free
cimport openmp

openmp.omp_set_num_threads(8)

# parametros da simulacao
cdef int num_vertices = 1000
cdef int tmax = 500

# estruturas auxiliares
# cdef list tipo = []
cdef int* tipo = <int*> PyMem_Malloc(num_vertices * sizeof(int))
cdef int* new_tipo = <int*> PyMem_Malloc(num_vertices * sizeof(int))
# cdef list quant_tipo0 = []
cdef int* quant_tipo0 = <int*> PyMem_Malloc(tmax * sizeof(int))
# cdef list quant_tipo1 = []
cdef int* quant_tipo1 = <int*> PyMem_Malloc(tmax * sizeof(int))
# cdef list quant_tipo2 = []
cdef int* quant_tipo2 = <int*> PyMem_Malloc(tmax * sizeof(int))
# cdef list tempo = []
cdef int* tempo = <int*> PyMem_Malloc(tmax * sizeof(int))

cdef int* deg = <int*> PyMem_Malloc(num_vertices * sizeof(int))

''' calcula o novo estado do vertice v de forma aleatoria
proporcional aos estados dos seus vizinhos, so e chamada para
um vertice se ele for do tipo 0 '''
cdef int muda_estado(object rede, int v):
	cdef int n0 = calcula_n0(rede, v)
	cdef int n1 = calcula_n1(rede, v)
	cdef int n2 = calcula_n2(rede, v)
	cdef int total
	total = n0 + n1 + n2
	if total == 0:
		return 0
	cdef int x
	x = random.randint(1, total)
	if x <= n0:
		return 0
	else:
		if x > n0 + n1:
			return 2
		else:
			return 1

''' calcula o numero de vizinhos do tipo 0 de um vertice v '''
cdef int calcula_n0(object rede, int v):
	cdef int n0 = 0
	vizinhos = rede.neighbors(v) # vizinhos de v
	for x in vizinhos:
		if tipo[x] == 0:
			n0 += 1
	return n0

''' calcula o numero de vizinhos influentes do tipo 1 de um vertice v
tomando o grau deles como base '''
cdef int calcula_n1(object rede, int v):
	cdef int n1 = 0
	cdef float maior = float(rede.maxdegree())
	vizinhos = rede.neighbors(v)
	cdef float grau, a
	for x in vizinhos:
		grau = float(rede.degree(x))
		a = random.random()
		if a < grau/maior and tipo[x] == 1:
			n1 += 1
	return n1

''' calcula o numero de vizinhos influentes do tipo 2 de um vertice v
tomando o grau deles como base '''
cdef int calcula_n2(object rede, int v):
	cdef int n2 = 0
	cdef float maior = float(rede.maxdegree())
	vizinhos = rede.neighbors(v)
	cdef float grau, a
	for x in vizinhos:
		grau = float(rede.degree(x))
		a = random.random()
		if a < grau/maior and tipo[x] == 2:
			n2 += 1
	return n2

''' inicializa todos no tipo 0 '''
cdef int k
for k in range(num_vertices):
	tipo[k] = 0

# cria o grafo, escolher aqui a topologia
# rede regular
#rede = igraph.Graph.K_Regular(num_vertices, 4)
    
# rede aleatoria
#rede = igraph.Graph.Erdos_Renyi(num_vertices, m = 2*num_vertices)

# rede livre de escala
rede = igraph.Graph.Barabasi(num_vertices)

# salva uma imagem do grafo
# igraph.plot(rede, bbox = (900, 900), vertex_size = 5).save('grafo.png')

print("Inicializando o grafo...")

cdef int t1, t2, t0, q1, q2, q0, a, i, j

# valores iniciais
t1 = random.randint(1, num_vertices/100) # maximo 1% dos vertices
t2 = random.randint(1, num_vertices/100) # maximo 1% dos vertices
t0 = num_vertices - t1 - t2 # o restante eh t0
# tipos
i = 0
while i < t1:
	a = random.randint(0, num_vertices - 1)
	while tipo[a] != 0:
		a = random. randint(0, num_vertices - 1)
	tipo[a] = 1
	i += 1
i = 0
while i < t2:
	a = random.randint(0, num_vertices - 1)
	while tipo[a] != 0:
		a = random.randint(0, num_vertices - 1)
	tipo[a] = 2
	i += 1

quant_tipo0[0] = t0
quant_tipo1[0] = t1
quant_tipo2[0] = t2
tempo[0] = 0

print("Executando a simulacao...")

# simulacao
i = 1
while i < tmax:
	q0 = 0
	q1 = 0
	q2 = 0
	j = 0
	deg_l = rede.degree(rede.vs.indices)
	for j in range(len(deg_l)):
		deg[j] = deg_l[j]
	for j in prange(num_vertices, nogil=True):		
		if tipo[j] == 0 and deg[j] > 0:
			with gil:
				new_tipo[j] = muda_estado(rede, j)
	for j in range(num_vertices):
		tipo[j] = new_tipo[j]
	for j in prange(num_vertices, nogil=True):
		if tipo[j] == 0:
			q0 += 1
		elif tipo[j] == 1:
			q1 += 1
		else:
			q2 += 1
	tempo[i] = i
	quant_tipo0[i] = q0
	quant_tipo1[i] = q1
	quant_tipo2[i] = q2
	print("i = ", i)
	i += 1

PyMem_Free(deg)
PyMem_Free(tipo)
PyMem_Free(new_tipo)

print("Simulacao finalizada!")
print("n0 = ", q0)
print("n1 = ", q1)
print("n2 = ", q2)

# grafico
'''
plt.plot(tempo, quant_tipo0, 'g', label = "nao conhece")
plt.plot(tempo, quant_tipo1, 'r', label = "acredita")
plt.plot(tempo, quant_tipo2, 'b', label = "nao acredita")
plt.title("Tipos de Pessoas")
plt.xlabel("Tempo")
plt.ylabel("Quantidade")
plt.legend()
plt.grid()
plt.savefig("grafico.png", dpi = 300)
plt.show()
'''

PyMem_Free(tempo)
PyMem_Free(quant_tipo0)
PyMem_Free(quant_tipo1)
PyMem_Free(quant_tipo2)