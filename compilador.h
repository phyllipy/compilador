/* -------------------------------------------------------------------
 *            Arquivo: compilaodr.h
 * -------------------------------------------------------------------
 *              Autor: Bruno Muller Junior
 *               Data: 08/2007
 *      Atualizado em: [15/03/2012, 08h:22m]
 *
 * -------------------------------------------------------------------
 *
 * Tipos, protótipos e vaiáveis globais do compilador
 *
 * ------------------------------------------------------------------- */
#define TAM_TOKEN 16
#include "pilha.h"
typedef enum simbolos {
  //operadores
  simb_mais,
  simb_menos,
  simb_vezes,
  simb_ponto_ponto,
  simb_div,
  simb_mod,
  simb_slash,
  simb_menor,
  simb_menor_igual,
  simb_maior,
  simb_maior_igual,
  simb_igual,
  simb_diferente,
  simb_or,
  simb_and,
  simb_not,
  //palavras da linguagem
  simb_begin, //OK
  simb_do,
  simb_else,
  simb_end, //*
  simb_function, //ok
  simb_goto, //ok
  simb_if, //ok
  simb_label, //ok
  simb_procedure , //ok
  simb_program, //ok
  simb_then, //ok
  simb_var, //ok
  simb_while, //ok
  simb_write,
  simb_read,
  //idenfificadores
  simb_atribuicao,//ok 
  simb_abre_parenteses, //ok
  simb_dois_pontos, //ok
  simb_fecha_parenteses, //ok
  simb_identificador, //ok
  simb_numero, //ok
  simb_ponto,  //ok
  simb_ponto_e_virgula, //ok
  simb_virgula //ok

} simbolos;



/* -------------------------------------------------------------------
 * variáveis globais
 * ------------------------------------------------------------------- */

extern simbolos simbolo, relacao;
extern char token[TAM_TOKEN];
extern int nivel_lexico;
extern int desloc;
extern int nl;
extern int contador_rotulo;
pilha* ts;
simbolos simbolo, relacao;
char token[TAM_TOKEN];



