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

/* Estrutura de uma variavel
 * tipo: tipo da variavel
 * offset: deslocamento
 * passagem: utilizado quando parametro para funcao (por valor ou referencia)
 */
typedef struct{
    int tipo;
    int offset;
    int passagem;
}variavel;

/*Estrutura de procedimentos e funcoes
 *tipo: tipo de retorno ( exclusivo de funcoes)
 *qtdeParametros: numero de parametros
 *offset: deslocamento (exclusivo de funcoes)
 *rotulo: nome do rotulo gerado na saida
 */
typedef struct{
  int tipo;
  int qtdeParametros;
  int offset;
  variavel *parametros;
  char rotulo[MAX];
}rotina;

/*Estrutura de rotulos
 *rotulo: nome do rotulo gerado na saida
 */
typedef struct{
    char rotulo[MAX];
}rotulo;

/*
 Tipos de dados suportados pela tabela de simbolos
 */
union tipos{
  variavel vs;
  rotina func;
  rotulo rot;
};

/*Item da tabela de simbolos
 *nl: nivel lexico 
 *categoria: indica o tipo de dado (variavel, rotina ou rotulo)
 *nome: nome do item 
 *item: variavel/proc/func/rotulo
 **/
typedef struct _no{
  int nl;
  int categoria;
  char nome[MAX];
  union tipos item;
}no;

/*
* Pilha utilizada para tabela de simbolos
* capacidade: tamanho maximo da pilha
* tamanho: tamanho atual da pilha
* primeiro: pronteiro para o topo item da pilha
*/
typedef struct{
  int capacidade;
  int tamanho;
  no* primeiro;
}pilha;


//cria uma pilha
pilha *criarPilha();

//encontra um item na pilha
no *find(pilha*,char*);

//empilha o no passado
void push(pilha*,no*);

//desempilha e retorna o no
no* pop(pilha*);

//cria uma variavel simples
no *criaVariavel(int, char*,int,int,int);

//cria um procedimento
no *criaProcedimento(char*,int);

//cria uma funcao
no *criaFuncao(int,char*,int);

//cria um rotulo
no *criaRotulo(int,int);

//imprime a tabela de simbolos
void imprimePilha(pilha*);

//preenche o campo tipo das variaveis
void preencherTipo(pilha*,int,int);

//remove os itens do nivel lexico mais alto
int removeElementos(pilha*,int);

#endif
