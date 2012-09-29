#ifndef _pilha_c_
#define _pilha_c_

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "pilha.h"
#include "compilador.h"
#define TAM_PILHA 1000
void VerificaPilha(pilha *p){
  if (!p){
      printf("Pilha nao alocada\n");
      exit(1);
  }
}

int contaDeslocamento(pilha *p, int nl){
  int count=0;
  int i = p->tamanho-1;
  no tmp;
  while (1){
          tmp = p->primeiro[i];
          if (tmp.nl < nl ) break;
          if (tmp.categoria == VS && tmp.item.vs.passagem == SIMPLES){
            count++;
          }
          i--;
  }
  return count;
}

int alterarTipos(pilha *p,int offset, int tipo){
  int i;
  int count=0;
  for (i=p->tamanho-1;i>=p->tamanho-offset;i--){
          if (p->primeiro[i].categoria==VS){
                  p->primeiro[i].item.vs.tipo = tipo;
                  count++;
          }
  }
  return count;
}
int removeElementos(pilha *p,int nivelL){
        no * tmp = p->primeiro;
        no *aux;
        int count = 0;
        //int nl = tmp[p->tamanho-1].nl;
        int nl = nivelL;
        while (p->tamanho ){
                
                //se for func ou proc, desempilha APENAS se estiver um nivel acima do nivel desejado
                if (tmp[p->tamanho-1].categoria == FUNCAO || tmp[p->tamanho-1].categoria == PROCEDIMENTO){
                        //verifica se o nivel lexico eh maior que o nivel que eu quero tirar
                        if (tmp[p->tamanho-1].nl > nl){
                                //se for, tira
                                aux = pop(p);
                        }else
                        break;
                }
                else
                        if (tmp[p->tamanho-1].nl == nl){
                                aux =pop(p);
                                if (aux->categoria == VS && aux->item.vs.passagem==SIMPLES)
                                        count++;
                        }else
                                break;
        }
        return count;
}
no* find(pilha *p, char* nome){
   int i;
   int j = p->tamanho;
   for(i=j-1;i>=0;i--){
      if ( (strcmp(nome,p->primeiro[i].nome))==0){
              return &(p->primeiro[i]);
      }
   }
   return NULL;
}
pilha *criaPilha(){
  pilha *p = (pilha*)malloc(sizeof(pilha));
  p->primeiro = (no*)malloc(sizeof(no*)*TAM_PILHA);
  int i;
  p->tamanho = 0;
  p->capacidade = TAM_PILHA;
  return p;
}
void  push(pilha *p, no* n){
  if (p->tamanho+1 >= p->capacidade)
   {
        p->capacidade *=2;
        p->primeiro = (no*)realloc(p->primeiro,p->capacidade*sizeof(no));
   }
  p->primeiro[p->tamanho] = *n;
  p->tamanho++;
}

no* pop(pilha *p){
  VerificaPilha(p);
  if (p->tamanho==0) return NULL;
  no *aux = &(p->primeiro[p->tamanho-1]);
  p->tamanho--;
  return aux;
}

/* Cria uma variavel simples*/
no *criaVariavel(int tipo,char* token,int nivel, int _offset,int ref){
  no *aux = (no*)malloc(sizeof(no*));
  aux->nl = nivel;
  
  aux->categoria = VS;
  strcpy(aux->nome,token);
  aux->item.vs.offset = _offset;
  aux->item.vs.tipo = tipo;
  aux->item.vs.passagem =  ref;
  return aux;
}
no *criaProcedimento (char* token,int nivel){
  no *aux = (no*)malloc(sizeof(no*));
  aux->nl = nivel;
  aux->categoria = PROCEDIMENTO;
  strcpy(aux->nome,token);
  return aux;
}
no *criaFuncao (int tipo,char* token,int nivel ){
  no *aux = (no*)malloc(sizeof(no*));
  aux->nl = nivel;
  aux->categoria = FUNCAO;
  strcpy(aux->nome,token);
  return aux;
}
no *criaRotulo(int label,int nivel){
  no *aux = (no*)malloc(sizeof(no*));
  aux->nl = nivel;
  char tk[MAX];
  aux->categoria = ROTULO;
  sprintf(tk,"%d",label);
  strcpy(aux->nome,tk);
  return aux;
}
void imprimePilha(pilha *p){
  no tmp;
  int i;
  int j;
  for (i=0;i<p->tamanho;i++){
          tmp = p->primeiro[i];
          printf("%s %d %d \t",tmp.nome, tmp.categoria,tmp.nl);
          if (p->primeiro[i].categoria == VS)
                  printf("offset:%d\tpassagem: %d",tmp.item.vs.offset,tmp.item.vs.passagem);
          if (p->primeiro[i].categoria == FUNCAO){
                  printf("offset:%d\tparams:%d",tmp.item.func.offset,tmp.item.func.qtdeParametros);
                  for(j=0;j<tmp.item.func.qtdeParametros;j++)
                          printf("\t p%d : %d",j,tmp.item.func.parametros[j].passagem);
          }
          printf("\n");
  }
}

#endif
