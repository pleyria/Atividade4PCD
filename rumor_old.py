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
from timeit import default_timer as timer

# parametros da simulacao
num_vertices = 5000
tmax = 2000

# estruturas auxiliares
tipo = []
new_tipo = [0] * num_vertices
quant_tipo0 = []
quant_tipo1 = []
quant_tipo2 = []
tempo = []

''' calcula o novo estado do vertice v de forma aleatoria
proporcional aos estados dos seus vizinhos, so e chamada para
um vertice se ele for do tipo 0 '''
def muda_estado(rede, v):
    n0 = calcula_n0(rede, v)
    n1 = calcula_n1(rede, v)
    n2 = calcula_n2(rede, v)
    total = n0 + n1 + n2
    if total == 0:
        return 0
    x = random.randint(1, total)
    if x <= n0:
        return 0
    else:
        if x > n0 + n1:
            return 2
        else:
            return 1

''' calcula o numero de vizinhos do tipo 0 de um vertice v '''
def calcula_n0(rede, v):
    n0 = 0
    vizinhos = rede.neighbors(v) # vizinhos de v
    for x in vizinhos:
        if tipo[x] == 0: # todos sao contabilizados independentemente do grau
            n0 += 1
    return n0

''' calcula o numero de vizinhos influentes do tipo 1 de um vertice v
tomando o grau deles como base '''
def calcula_n1(rede, v):
    n1 = 0
    maior = float(rede.maxdegree()) # maior grau do grafo
    vizinhos = rede.neighbors(v) # vizinhos de v
    for x in vizinhos:
        grau = float(rede.degree(x))
        a = random.random()
        if a < grau/maior and tipo[x] == 1:
            n1 += 1
    return n1

''' calcula o numero de vizinhos influentes do tipos 2 de um vertice v
tomando o grau deles como base '''
def calcula_n2(rede, v):
    n2 = 0
    maior = float(rede.maxdegree()) # maior grau do grafo
    vizinhos = rede.neighbors(v) # vizinhos de v
    for x in vizinhos:
        grau = float(rede.degree(x))
        a = random.random()
        if a < grau/maior and tipo[x] == 2:
            n2 += 1
    return n2

# inicializa todos no tipo 0
for i in range(num_vertices):
    tipo.append(0)

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
		a = random.randint(0, num_vertices - 1)
	tipo[a] = 1
	i += 1
i = 0
while i < t2:
	a = random.randint(0, num_vertices - 1)
	while tipo[a] != 0:
		a = random.randint(0, num_vertices - 1)
	tipo[a] = 2
	i += 1

quant_tipo0.append(t0)
quant_tipo1.append(t1)
quant_tipo2.append(t2)
tempo.append(0)

print("Executando a simulacao...")

# simulacao
i = 1
while i < tmax:
    q0 = 0
    q1 = 0
    q2 = 0
    j = 0
    for j in range(num_vertices):
        if tipo[j] == 0 and rede.degree(j) > 0: 
            new_tipo[j] = muda_estado(rede, j)
    tipo = new_tipo.copy()
    for x in tipo:
        if x == 0:
            q0 += 1
        if x == 1:
            q1 += 1
        if x == 2:
            q2 += 1
    tempo.append(i)
    quant_tipo0.append(q0)
    quant_tipo1.append(q1)
    quant_tipo2.append(q2)
    #print("i = ", i)
    i += 1

# registra o tempo final
finish = timer()
print("Tempo de execucao = ", (finish - start), " segundos")
'''
print("Simulacao finalizada!")
print("n0 = ", q0)
print("n1 = ", q1)
print("n2 = ", q2)
'''
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