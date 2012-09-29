%{
#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>
#include "compilador.h"
#include "pilha.h"

FILE *fp;
extern int yylex(void);
extern char *yytext;
int nl;
int nivel = 0;
int offset = 0;
int write = 0;
int label = 0;
char s[32];
int i;
int numParametros;
pilha *aux;
pilha *rotulos;
pilha *parametros;
no *param;
no *noTemp;
no *noTmp;
no *var;
no *oi;
no *rot1,*rot2;

no *proc,*func;
void yyerror (char const *s) {
	
	fprintf (stderr, "%s\n", s);
}

%}



//Total de 40 tokens

%token ABRE_PARENTESES AND ATRIBUICAO DIFERENTE
%token DIV DO DOIS_PONTOS ELSE FECHA_PARENTESES
%token FUNCTION GOTO IDENT IF IGUAL LABEL MAIOR
%token MAIOR_IGUAL MAIS MENOR MENOR_IGUAL MENOS NOT
%token NUMERO OR PONTO PONTO_E_VIRGULA PONTO_PONTO
%token PROCEDURE PROGRAM READ T_BEGIN T_END THEN VAR
%token VEZES VIRGULA WHILE WRITE SLASH CALL
%%

programa:
		{
			geraCodigo(NULL, "INPP");
		}
		PROGRAM IDENT
        ABRE_PARENTESES lista_idents FECHA_PARENTESES PONTO_E_VIRGULA
        bloco PONTO 
		{ 
			geraCodigo(NULL, "PARA");
		}
;

bloco:
	parte_declara_rotulos_opt
	parte_declara_vars_opt
{
        sprintf(s,"%s",geraRotulo());
        rot2 = criaRotulo(atoi(s),nivel);
        strcpy(rot2->item.rot.rotulo,s);
        sprintf(s, "DSVS %s", rot2->item.rot.rotulo);
        geraCodigo(NULL, s);
        push(rotulos,rot2);
}
	parte_declara_subrotinas_opt
{
        rot1 = pop(rotulos);
        sprintf(s, "%s", rot1->item.rot.rotulo);
        geraCodigo(s, "NADA");
}
	comando_composto //TODO ='(
{
        offset = removeElementos(ts,nivel);
        if (offset)
        {
                sprintf(s,"DMEM %d",offset);
                geraCodigo(NULL,s);
        }

        if (ts->tamanho){
                noTemp =&( ts->primeiro[ts->tamanho-1]);
                if (noTemp->categoria==PROCEDIMENTO || noTemp->categoria == FUNCAO){
                        sprintf(s, "RTPR %d, %d", nivel, noTemp->item.func.qtdeParametros);	
                        geraCodigo(NULL, s);

                }
        }
}
;

parte_declara_rotulos_opt:
 | parte_declara_rotulos
;

parte_declara_vars_opt:
 | parte_declara_vars
;

parte_declara_subrotinas_opt:
 |
	{
		nl++;
    nivel++;
		offset = 0;
	}
	parte_declara_subrotinas
	{
		nl--;
    nivel--;
	}
;

parte_declara_rotulos:	
 LABEL
 NUMERO
	{
    noTmp = criaRotulo(atoi(yytext),nivel);
    strcpy(noTmp->item.rot.rotulo,geraRotulo());
    push(ts,noTmp);
    noTmp = NULL;

	}
 parte_declara_rotulos_loop
 PONTO_E_VIRGULA
;

parte_declara_rotulos_loop:
 | VIRGULA NUMERO
	{
    rot1 = criaRotulo(atoi(yytext),nivel);
    strcpy(rot1->item.rot.rotulo,geraRotulo());
    push(ts,rot1);
    rot1 = NULL;
	}
 parte_declara_rotulos_loop
;

parte_declara_vars:	//TODO
 VAR
 {
  aux->tamanho = 0;
	offset = 0;
 }
 declara_vars
 PONTO_E_VIRGULA
 parte_declara_vars_loop
;

parte_declara_vars_loop: //TODO
  { 
	if (aux->tamanho) {
		sprintf(s, "AMEM %d", aux->tamanho);
		geraCodigo(NULL, s);
	}	
	offset = aux->tamanho;
  for( i=0; i<aux->tamanho;i++){
          push(ts,&(aux->primeiro[i]));
  }
   aux->tamanho = 0;
   
 }
 |
 declara_vars
 PONTO_E_VIRGULA
 parte_declara_vars_loop
;

declara_vars:
 lista_idents DOIS_PONTOS tipo {
         int tipo;
         if ( !strcmp(yytext,"integer")){
            tipo = 7;
         }else{
                 tipo = 1;
         }
         alterarTipos(ts,offset,tipo);
 } 
;

tipo: IDENT
;

lista_idents:	//TODO
 identificador
 {
         if ( strcmp(yytext,"input") && strcmp(yytext,"output")){
                 oi = criaVariavel(1,yytext,nivel,offset,SIMPLES);
                 push(aux,oi);
                 offset++;
         }
 }
 lista_idents_loop
;

lista_idents_loop:	//TODO
 | VIRGULA identificador
 {
         if ( strcmp(yytext,"input") && strcmp(yytext,"output")){
                 oi = criaVariavel(1,yytext,nivel,offset,SIMPLES);
                 push(aux,oi);
                 offset++;
         }
 }
 lista_idents_loop
;

parte_declara_subrotinas:
 declaracao_procedimento PONTO_E_VIRGULA parte_declara_subrotinas_loop
 | declaracao_funcao PONTO_E_VIRGULA parte_declara_subrotinas_loop
;

parte_declara_subrotinas_loop:
 | parte_declara_subrotinas
;

declaracao_procedimento:
 PROCEDURE
 {
 }
 identificador
 {
     proc = criaProcedimento(yytext,nivel);
     sprintf(s,"%s",geraRotulo());
     strcpy(proc->item.func.rotulo,s);
     sprintf(s,"ENPR %d",nivel);
     geraCodigo(proc->item.func.rotulo,s);
 }
 parametros_formais_opt PONTO_E_VIRGULA
 {
    proc->item.func.qtdeParametros = parametros->tamanho;
    offset = -4;
    i = parametros->tamanho -1;
    proc->item.func.parametros = (variavel*)malloc(sizeof(variavel*)*parametros->tamanho);

    push(ts,proc);
    //nivel++;
    while (parametros->tamanho){
          param = pop(parametros);

          param->item.vs.offset = offset;
          param->item.vs.offset = -4;

          push(ts,criaVariavel(0,param->nome,nivel,offset,param->item.vs.passagem));
          offset--;
          proc->item.func.parametros[i] = param->item.vs;
          i--;
    }
    parametros->tamanho = 0;
    offset = 0;
    proc = NULL;
 }
 bloco
;

declaracao_funcao: //TODO
 FUNCTION
 {
 }
 identificador
 {
     func = criaFuncao(0,yytext,nivel);
     sprintf(s,"%s",geraRotulo());
     strcpy(func->item.func.rotulo,s);
     sprintf(s,"ENPR %d",nivel);
     geraCodigo(func->item.func.rotulo,s);
 }
 parametros_formais_opt //TODO
 {
    func->item.func.qtdeParametros = parametros->tamanho;
    offset = -4;
    i = parametros->tamanho -1;
    func->item.func.parametros = (variavel*)malloc(sizeof(variavel*)*parametros->tamanho);
    push(ts,func);
    //nivel++;
    while (parametros->tamanho){
          noTemp = pop(parametros);
          noTemp->item.vs.offset = offset;
          push(ts,criaVariavel(0,noTemp->nome,nivel,offset,noTemp->item.vs.passagem));
          offset--;
     //     push(ts,noTemp);
          func->item.func.parametros[i] = noTemp->item.vs;
          i--;
    }
    parametros->tamanho = 0;
    offset = 0;
 }
 DOIS_PONTOS identificador
 {
         int j;
         for (j=ts->tamanho-1;j>=0;j--){
            if (ts->primeiro[j].categoria == FUNCAO){
              ts->primeiro[j].item.func.offset = -4 - ts->primeiro[j].item.func.qtdeParametros ;
              ts->primeiro[j].item.func.tipo = 7;
              break;
            }
  
         }
 }PONTO_E_VIRGULA 
 bloco
;

parametros_formais_opt:
 | parametros_formais
;

parametros_formais:
 ABRE_PARENTESES secao_parametros_formais parametros_formais_loop FECHA_PARENTESES
;

parametros_formais_loop:
 | PONTO_E_VIRGULA secao_parametros_formais parametros_formais_loop
;

secao_parametros_formais: 
 lista_idents
 {
        
    for (i=0;i<aux->tamanho;i++){
       noTemp = &(aux->primeiro[i]);
       noTemp->item.vs.passagem = VALOR;
       push(parametros,noTemp);
    }
    aux->tamanho = 0;
 }
 DOIS_PONTOS tipo
 | VAR  lista_idents
 {
    for (i=0;i<aux->tamanho;i++){
       noTemp = &(aux->primeiro[i]);
       noTemp->item.vs.passagem = REFERENCIA;
       noTemp->nl = nivel;
       push(parametros,noTemp);
    }
    aux->tamanho = 0;
  }
  DOIS_PONTOS tipo
;

comando_composto: T_BEGIN comando comando_composto_loop T_END
;

comando_composto_loop: 
 | PONTO_E_VIRGULA comando comando_composto_loop
; 

comando:
 NUMERO
 {
  noTemp = find(ts,yytext);
  if (noTemp){
	//	geraCodigo(noTemp->item.rot.rotulo, "NADA");
  /* o arquivo MEPA de saida do professor, nao coloca virgula entre os parametros do ENRT
   * assim, tirei pra adequar a saida    */
	//	sprintf(s, "ENRT %d %d", nivel, offset);
		sprintf(s, "ENRT %d %d", nivel, offset);
		geraCodigo(noTemp->item.rot.rotulo, s);

  }
	else {
		yyerror("label nao declarado.\n");
    exit(1);
	}
 }
 DOIS_PONTOS comando_sem_label
 | comando_sem_label
;

comando_sem_label:
 |atribuicao
 | chamada_procedimento
 | desvio
 | comando_composto
 | comando_condicional
 | comando_repetitivo
 | comando_escrita
 | comando_leitura
;

comando_escrita:
 WRITE
 {
	write = 1;
 }
 ABRE_PARENTESES lista_expressoes FECHA_PARENTESES
 {
	write = 0;
 }
;

comando_leitura:
 READ
 ABRE_PARENTESES comando_leitura_1 FECHA_PARENTESES
;

comando_leitura_1:
 {
	sprintf(s, "LEIT");
	geraCodigo(NULL, s);
 }
 variavel
 {
	
	if (!noTemp) {
		yyerror("Variavel nao declarada.");
		exit(1);
	}
	if (noTemp->item.vs.passagem == REFERENCIA) {
		sprintf(s, "ARMI %d, %d", noTemp->nl, noTemp->item.vs.offset);
		geraCodigo(NULL, s);
	}
	else if (noTemp->item.vs.passagem == VALOR || noTemp->item.vs.passagem == SIMPLES){
		sprintf(s, "ARMZ %d, %d", noTemp->nl, noTemp->item.vs.offset);
		geraCodigo(NULL, s);
	}
	
 }
 comando_leitura_1_loop
;

comando_leitura_1_loop:
 | VIRGULA comando_leitura_1
;

atribuicao: //TODO 
 variavel
 {
    var = noTemp;
 }
 ATRIBUICAO expressao
{
        if (!var){
                yyerror("Variavel nao declarada.");
                exit(1);
        }
        if (var->categoria == FUNCAO){
          
  //              sprintf(s, "ARMZ %d, %d" , var->nl+1, var->item.func.offset);
                sprintf(s, "ARMZ %d, %d" , var->nl, var->item.func.offset);
                geraCodigo(NULL, s);
        }else
                if (var->item.vs.passagem == REFERENCIA){
                        sprintf(s, "ARMI %d, %d", var->nl, var->item.vs.offset);
                        geraCodigo(NULL, s);
                }else{

                        sprintf(s, "ARMZ %d, %d" , var->nl, var->item.vs.offset);
                        geraCodigo(NULL, s);
                }
}
;

chamada_procedimento:
 identificador
 {
	if (!noTemp) {
		yyerror("Procedimento nao declarado.");
		exit(1);
	}
  proc = noTemp;
  parametros->tamanho = 0;
  numParametros = 0;
 }
 lista_expressoes_opt
 {
	sprintf(s, "CHPR %s, %d", proc->item.func.rotulo,nivel);
	geraCodigo(NULL, s);
	proc = NULL;
 }
;

lista_expressoes_opt:
 | ABRE_PARENTESES lista_expressoes FECHA_PARENTESES
;

desvio: //DONE
 GOTO NUMERO
{
        noTemp = find(ts,yytext);
        if (noTemp) {
                sprintf(s, "DSVR %s, %d, %d", noTemp->item.rot.rotulo, noTemp->nl, nivel);
                geraCodigo(NULL, s);
        } else {
                yyerror("Label nao declarado.");
                exit(1);
        }
}
;

comando_condicional:
 IF expressao
 {
         strcpy(s,geraRotulo());
         rot1 = criaRotulo(s,nl);
         strcpy(rot1->item.rot.rotulo,s);
         push(rotulos,rot1);
         sprintf(s, "DSVF %s", rot1->item.rot.rotulo);
         geraCodigo(NULL, s);

 }
 THEN comando_sem_label
 {

         strcpy(s,geraRotulo());
         rot1 = criaRotulo(s,nl);
         strcpy(rot1->item.rot.rotulo,s);
         sprintf(s, "DSVS %s", rot1->item.rot.rotulo);
         geraCodigo(NULL, s);
         rot2 = pop(rotulos);

         sprintf(s, "%s", rot2->item.rot.rotulo);
         geraCodigo(s, "NADA");
         push(rotulos,rot1);
 } 
 comando_condicional_else
 {
         noTemp = pop(rotulos);
         sprintf(s, "%s", noTemp->item.rot.rotulo);
         geraCodigo(s, "NADA");
 }
;

comando_condicional_else:
 | ELSE comando_sem_label
;

comando_repetitivo:
 WHILE
 {
         strcpy(s,geraRotulo());
         rot1 = criaRotulo(s,nl);
         strcpy(rot1->item.rot.rotulo,s);
         sprintf(s, "NADA");
         geraCodigo(NULL, s);
         push(rotulos,rot1);
 }
 expressao
 {
         strcpy(s,geraRotulo());
         rot1 = criaRotulo(s,nl);
         strcpy(rot1->item.rot.rotulo,s);
         sprintf(s, "DSVF %s", rot1->item.rot.rotulo);
         geraCodigo(NULL, s);
         push(rotulos,rot1);
 }
 DO comando_sem_label
 {
         rot1 = pop(rotulos);
         rot2 = pop(rotulos);
         sprintf(s, "DSVS %s", rot2->item.rot.rotulo);
         geraCodigo(NULL, s);
         sprintf(s, "%s", rot1->item.rot.rotulo);
         geraCodigo(s, "NADA");
 }
  ;

lista_expressoes:
 expressao
 {
	if (write) {
		sprintf(s, "IMPR");
		geraCodigo(NULL, s);
	}
 }
 lista_expressoes_loop
;

lista_expressoes_loop:
| VIRGULA expressao
{
 if (write) {
    sprintf(s, "IMPR");
	geraCodigo(NULL, s);
 }
}
 lista_expressoes_loop
;

expressao:
 expressao_simples
 | expressao_simples IGUAL expressao_simples {
	sprintf(s, "CMIG");
	geraCodigo(NULL, s);
 }
 | expressao_simples DIFERENTE expressao_simples {
	sprintf(s, "CMDG");
	geraCodigo(NULL, s);
 }
 | expressao_simples MENOR expressao_simples {
	sprintf(s, "CMME");
	geraCodigo(NULL, s);
 }
 | expressao_simples MAIOR expressao_simples {
	sprintf(s, "CMMA");
	geraCodigo(NULL, s);
 }
 | expressao_simples MAIOR_IGUAL expressao_simples {
	sprintf(s, "CMAG");
	geraCodigo(NULL, s);
 }
 | expressao_simples MENOR_IGUAL expressao_simples {
	sprintf(s, "CMEG");
	geraCodigo(NULL, s);
 }
;
 
expressao_simples:
 termo expressao_simples_loop
 | MAIS termo expressao_simples_loop
 | MENOS termo {
	sprintf(s, "INVR");
	geraCodigo(NULL, s);
 }
 expressao_simples_loop
;

expressao_simples_loop:
 | MAIS termo {
	sprintf(s, "SOMA");
	geraCodigo(NULL, s);
 } expressao_simples_loop
 | MENOS termo {
	sprintf(s, "SUBT");
	geraCodigo(NULL, s);
 }
 expressao_simples_loop 
 | OR termo {
	sprintf(s, "DISJ");
	geraCodigo(NULL, s);
 }
 expressao_simples_loop
;

termo: 
 fator termo_loop
;

termo_loop:
 | VEZES fator {
	sprintf(s, "MULT");
	geraCodigo(NULL, s);
 } termo_loop
 | DIV fator {
	sprintf(s, "DIVI");
	geraCodigo(NULL, s);
 } termo_loop
 | AND fator {
	sprintf(s, "CONJ");
	geraCodigo(NULL, s);
 }
;

fator: // =[
 variavel
 { 
  
         if (noTemp) {
                 if ((proc) && numParametros >= proc->item.func.qtdeParametros ) {
                         yyerror("Procedimento chamado com numero invalido de parametros.");
                         exit(1);
                 }
                 if ((func) && numParametros > func->item.func.qtdeParametros ) {
                         printf("esperado: %d, %d encontrados\n\n",func->item.func.qtdeParametros,numParametros);
                         exit(1);
                 }
                 if ((proc) && proc->item.func.parametros[numParametros].passagem == REFERENCIA) {
                         if (noTemp->item.vs.passagem == SIMPLES) {
                                 sprintf(s, "CRVL %d, %d", noTemp->nl, noTemp->item.vs.offset);
                                 geraCodigo(NULL, s);
                         }
                         else if (noTemp->item.vs.passagem == VALOR) {
                                 sprintf(s, "CRVL %d, %d", noTemp->nl, noTemp->item.vs.offset);
                                 geraCodigo(NULL, s);
                         }
                         else if (noTemp->item.vs.passagem == REFERENCIA) {
                                 sprintf(s, "CREN %d, %d", noTemp->nl, noTemp->item.vs.offset);
                                 geraCodigo(NULL, s);
                         }
                         numParametros++;
                 }
                 else 
                         if ((func) && func->item.func.parametros[numParametros].passagem == REFERENCIA) {
                                 if (noTemp->item.vs.passagem == SIMPLES) {
                                         sprintf(s, "CRVL %d, %d", noTemp->nl, noTemp->item.vs.offset);
                                         geraCodigo(NULL, s);
                                 }
                                 else if (noTemp->item.vs.passagem == VALOR) {
                                         sprintf(s, "CRVL %d, %d", noTemp->nl, noTemp->item.vs.offset);
                                         geraCodigo(NULL, s);
                                 }
                                 else if (noTemp->item.vs.passagem == REFERENCIA) {
                                         sprintf(s, "CREN %d, %d", noTemp->nl, noTemp->item.vs.offset);
                                         geraCodigo(NULL, s);
                                 }
                                 numParametros++;
                         }
                         else { 
                                 if (noTemp->item.vs.passagem == SIMPLES) {
                                         sprintf(s, "CRVL %d, %d", noTemp->nl, noTemp->item.vs.offset);
                                         geraCodigo(NULL, s);
                                 }
                                 else if (noTemp->item.vs.passagem == VALOR) {
                                         sprintf(s, "CRVL %d, %d", noTemp->nl, noTemp->item.vs.offset);
                                         geraCodigo(NULL, s);
                                 }
                                 else if (noTemp->item.vs.passagem == REFERENCIA) {
                                         sprintf(s, "CRVI %d, %d", noTemp->nl, noTemp->item.vs.offset);
                                         geraCodigo(NULL, s);
                                 } 
                         }

         }
 //                        numParametros++;
 }
 | numero
 {
	sprintf(s, "CRCT %s", yytext);
	geraCodigo(NULL, s);
 }
 | chamada_funcao
 | ABRE_PARENTESES expressao FECHA_PARENTESES
 | NOT fator 
 {
	geraCodigo(NULL, "NEGA");
 }
;

variavel:
 identificador
;

chamada_funcao:
 //CALL
 identificador
 {
	geraCodigo(NULL, "AMEM 1");
	if (!noTemp) {
		yyerror("funcao nao declarada.");
		exit(1);
	}
	func = noTemp;
  parametros->tamanho =0 ;
  numParametros = 0;
 }
 lista_expressoes_opt
{ 	
	sprintf(s, "CHPR %s, %d", func->item.func.rotulo, nivel);
	geraCodigo(NULL, s);
	func = NULL;
 }
;

numero:
 NUMERO
;

identificador:
 IDENT
 {
	noTemp = find(ts,yytext);;
 }
;

%%

int main (int argc, char** argv) {
   FILE *fpent;
   extern FILE *yyin;

   if (argc < 2) {
         printf("Modo de uso: compilador <arq>");
         return(-1);
   }

   fpent = fopen (argv[1], "r");
   if (fpent == NULL) {
      printf("Modo de uso: compilador <arq>\n");
      return(-1);
   }
   if (argc>2)
           if (argv[2][1]=='o'){
                   fp = fopen(argv[3],"w");
                   if (argc!=4){
                           printf("Faltando parametros para a opçao -o\n");
                           printf("Modo de uso: compilador <arq> -o <out>\n");
                           exit(1);
                   }
           }else{
                   printf("Parametro invalido\n");
           }

/* ------------------------------------------------------------------- */
/*  Inicia a Tabela de Simbolos										                     */
/* ------------------------------------------------------------------- */
   
   ts = criaPilha();
   aux = criaPilha();
   rotulos = criaPilha();
   parametros = criaPilha();
   contador_rotulo = 0;
   yyin = fpent;
   yyparse();
      
   fclose(fpent);
//	imprimePilha(ts);
        
   return 0;
}
