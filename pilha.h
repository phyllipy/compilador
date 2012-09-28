#ifndef PILHA__
#define PILHA__

#define VS 0
#define PROCEDIMENTO 1
#define FUNCAO 2
#define ROTULO 3
#define MAX 32
#define REFERENCIA 0
#define SIMPLES 1
#define VALOR 2


typedef struct{
    int tipo;
    int offset;
    int passagem;
}variavel;

typedef struct{
  int tipo;
  int qtdeParametros;
  int offset;
  variavel *parametros;
  char rotulo[MAX];
}rotina;
typedef struct{
    char rotulo[MAX];
}rotulo;


union uniao{
  variavel vs;
  rotina func;
  rotulo rot;
};
typedef struct _no{
  int nl;
  int categoria;
  char nome[MAX];
  union uniao item;
}no;

typedef struct{
  int capacidade;
  int tamanho;
  no* primeiro;
}pilha;


pilha *criarPilha();
no *find(pilha*,char*);
void push(pilha*,no*);
no* pop(pilha*);

no *criaVariavel(int, char*,int,int,int);
no *criaProcedimento(char*,int);
no *criaFuncao(int,char*,int);
no *criaRotulo(int,int);
no *find(pilha*,char*);
void imprimePilha(pilha*);
void preencherTipo(pilha*,int,int);
int removeElementos(pilha*);

#endif
