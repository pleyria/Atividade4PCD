'''
Propagacao de rumor - tipos de pessoas:
tipo 0: nao conhece o rumor, mas pode saber se tiver contato com pessoas
do tipo 1 ou do tipo 2, nao influencia outras pessoas
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
from timeit import default_timer as timer
cimport openmp

openmp.omp_set_num_threads(4)

# parametros da simulacao
cdef int num_vertices = 5000
cdef int tmax = 2000

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
cdef int muda_estado(int v):
	cdef int n1, n2, n0
	n0 = calcula_n0(v)
	n1 = calcula_n1(v)
	n2 = calcula_n2(v)
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
cdef int calcula_n0 (int v):
	cdef int n0 = 0
	vizinhos = rede.neighbors(v) # vizinhos de v
	for x in vizinhos:
		if tipo[x] == 0:
			n0 += 1
	return n0

''' calcula o numero de vizinhos influentes do tipo 1 de um vertice v
tomando o grau deles como base '''
cdef int calcula_n1(int v):
	cdef int n1 = 0
	cdef float maior = max_deg
	cdef float grau, a
	vizinhos = rede.neighbors(v)
	for x in vizinhos:
		grau = float(rede.degree(x))
		a = random.random()
		if a < grau/maior and tipo[x] == 1:
			n1 += 1
	return n1

''' calcula o numero de vizinhos influentes do tipo 2 de um vertice v
tomando o grau deles como base '''
cdef int calcula_n2(int v):
	cdef int n2 = 0
	cdef float maior = max_deg
	cdef float grau, a
	vizinhos = rede.neighbors(v)
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

# registra o tempo inicial
start = timer()

print("Inicializando o grafo...")

cdef int t1, t2, t0, q1, q2, q0, a, i, j, pmax
cdef int max_deg

# valores iniciais
pmax = 3
# t1 e t2 comecam entre 1% e pmax% dos nos
t1 = random.randint(int(num_vertices/100), pmax*int(num_vertices/100))
t2 = random.randint(int(num_vertices/100), pmax*int(num_vertices/100))
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
for i in range(1, tmax):
	q0 = 0
	q1 = 0
	q2 = 0
	j = 0
	deg_l = rede.degree(rede.vs.indices)
	max_deg = max(deg_l)
	for j in range(len(deg_l)):
		deg[j] = deg_l[j]

	for j in range(num_vertices):		
		if tipo[j] == 0 and deg[j] > 0:
			new_tipo[j] = muda_estado(j)
		else:
			new_tipo[j] = tipo[j]

	for j in prange(num_vertices, nogil=True):
		tipo[j] = new_tipo[j]
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
	# print("i = ", i)

# registra o tempo final
finish = timer()
print("Tempo de execucao = ", (finish - start), " segundos")

PyMem_Free(deg)
PyMem_Free(tipo)
PyMem_Free(new_tipo)

print("Simulacao finalizada!")
print("n0 = ", q0)
print("n1 = ", q1)
print("n2 = ", q2)
print("total = ", q0+q1+q2)

tempo_l = list()
quant_tipo0_l = list()
quant_tipo1_l = list()
quant_tipo2_l = list()
for i in range(tmax):
	tempo_l.append(tempo[i])
	quant_tipo0_l.append(quant_tipo0[i])
	quant_tipo1_l.append(quant_tipo1[i])
	quant_tipo2_l.append(quant_tipo2[i])
PyMem_Free(tempo)
PyMem_Free(quant_tipo0)
PyMem_Free(quant_tipo1)
PyMem_Free(quant_tipo2)

# grafico
'''
plt.plot(tempo_l, quant_tipo0_l, 'g', label = "nao conhece")
plt.plot(tempo_l, quant_tipo1_l, 'r', label = "acredita")
plt.plot(tempo_l, quant_tipo2_l, 'b', label = "nao acredita")
plt.title("Tipos de Pessoas")
plt.xlabel("Tempo")
plt.ylabel("Quantidade")
plt.legend()
plt.grid()
plt.savefig("grafico.png", dpi = 300)
plt.show()
'''
