%{
#include <stdio.h>
#include <string.h>
#include "compilador.h"
#include "compilador.tab.h"
#define IMPRIME(STR) printf("%s		# %s \n", STR, token);

int nl = 1;

%}

pulo_linha [\n\f\r]
descarte [\t ]+
ident [a-zA-Z][a-zA-Z0-9]*
numero [0-9]+
comentario "(*".*"*)"

%%

{pulo_linha} {nl++;}
{descarte}
{comentario}

program		{ simbolo = simb_program;
				strncpy (token, yytext, TAM_TOKEN);
				//IMPRIME("program ");
				return PROGRAM;
			}

var			{ simbolo = simb_var;
				strncpy (token, yytext, TAM_TOKEN);
				//IMPRIME("var ");
				return VAR;
			}

begin		{ simbolo = simb_begin;
				strncpy (token, yytext, TAM_TOKEN);
				//IMPRIME("begin ");
				return T_BEGIN;
			}

end			{ simbolo = simb_end;
				strncpy (token, yytext, TAM_TOKEN);
				//IMPRIME("end ");
				return T_END;
			}

and			{ simbolo = simb_and;
				strncpy (token, yytext, TAM_TOKEN);
				//IMPRIME(" and ");
				return AND;
			}

"/"			{ simbolo = simb_slash;
				strncpy (token, yytext, TAM_TOKEN);
				//IMPRIME(" slash ");
				return SLASH;
			}
			
div			{ simbolo = simb_div;
				strncpy (token, yytext, TAM_TOKEN);
				//IMPRIME(" div ");
				return DIV;
			}

or			{ simbolo = simb_or;
				strncpy (token, yytext, TAM_TOKEN);
				//IMPRIME(" or ");
				return OR;
			}

not			{ simbolo = simb_not;
				strncpy (token, yytext, TAM_TOKEN);
				//IMPRIME(" not ");
				return NOT;
			}

goto		{ simbolo = simb_goto;
				strncpy (token, yytext, TAM_TOKEN);
				//IMPRIME(" goto ");
				return GOTO;
			}

function	{ simbolo = simb_function;
				strncpy (token, yytext, TAM_TOKEN);
				//IMPRIME(" function ");
				return FUNCTION;
			}

procedure	{ simbolo = simb_procedure;
				strncpy (token, yytext, TAM_TOKEN);
				//IMPRIME(" procedure ");
				return PROCEDURE;
			}

if			{ simbolo = simb_if;
				strncpy (token, yytext, TAM_TOKEN);
				//IMPRIME(" if ");
				return IF;
			}

then		{ simbolo = simb_then;
				strncpy (token, yytext, TAM_TOKEN);
				//IMPRIME(" then ");
				return THEN;
			}

else		{ simbolo = simb_else;
				strncpy (token, yytext, TAM_TOKEN);
				//IMPRIME(" else ");
				return ELSE;
			}

while		{ simbolo = simb_while;
				strncpy (token, yytext, TAM_TOKEN);
				//IMPRIME(" while ");
				return WHILE;
			}

do			{ simbolo = simb_do;
				strncpy (token, yytext, TAM_TOKEN);
				//IMPRIME(" do ");
				return DO;
			}

label		{ simbolo = simb_label;
				strncpy (token, yytext, TAM_TOKEN);
				//IMPRIME(" label ");
				return LABEL;
			}

write		{ simbolo = simb_write;
				strncpy (token, yytext, TAM_TOKEN);
				//IMPRIME(" write ");
				return WRITE;
			}

read		{ simbolo = simb_read;
				strncpy (token, yytext, TAM_TOKEN);
				//IMPRIME(" read ");
				return READ;			           
			}
			
call		{ simbolo = simb_call;
				strncpy (token, yytext, TAM_TOKEN);
				//IMPRIME(" call ");
				return CALL;			           
			}			

":="		{ simbolo = simb_atribuicao;
				strncpy (token, yytext, TAM_TOKEN);
				//IMPRIME("atribuicao ");
				return ATRIBUICAO;	
			}

";"			{ simbolo = simb_ponto_e_virgula;
				strncpy (token, yytext, TAM_TOKEN);
				//IMPRIME(" pt_virgula ");
				return PONTO_E_VIRGULA;
			}

":"			{ simbolo = simb_dois_pontos;
				strncpy (token, yytext, TAM_TOKEN);
				//IMPRIME(" dois pontos ");
				return DOIS_PONTOS;
			}

","			{ simbolo = simb_virgula;
				strncpy (token, yytext, TAM_TOKEN);
				//IMPRIME(" virgula ");
				return VIRGULA;
			}

"."			{ simbolo = simb_ponto;
				strncpy (token, yytext, TAM_TOKEN);
				//IMPRIME(" ponto ");
				return PONTO;
			}

"("			{ simbolo = simb_abre_parenteses;
				strncpy (token, yytext, TAM_TOKEN);
				//IMPRIME(" abre_parenteses ");
				return ABRE_PARENTESES;
			}

")"			{ simbolo = simb_fecha_parenteses;
				strncpy (token, yytext, TAM_TOKEN);
				//IMPRIME(" fecha_parenteses ");
				return FECHA_PARENTESES;
			}

{ident}		{ simbolo = simb_identificador;
				strncpy (token, yytext, TAM_TOKEN);
				//IMPRIME(" ident ");
				return IDENT;
			}

{numero}	{ simbolo = simb_numero;
				strncpy (token, yytext, TAM_TOKEN);
				//IMPRIME(" numero ");
				return NUMERO;
			}

"+" 		{ simbolo = simb_mais;
				strncpy (token, yytext, TAM_TOKEN);
				//IMPRIME(" mais ");
				return MAIS;
			}

"-"			{ simbolo = simb_menos;
				strncpy (token, yytext, TAM_TOKEN);
				//IMPRIME(" menos ");
				return MENOS;
			}

"*"			{ simbolo = simb_vezes;
				strncpy (token, yytext, TAM_TOKEN);
				//IMPRIME(" vezes ");
				return VEZES;
			}

".."		{ simbolo = simb_ponto_ponto;
				strncpy (token, yytext, TAM_TOKEN);
				//IMPRIME(" ponto_ponto ");
				return PONTO_PONTO;
			}

"="			{ simbolo = simb_igual;
				strncpy (token, yytext, TAM_TOKEN);
				//IMPRIME(" igual ");
				return IGUAL;
			}

"<>"		{ simbolo = simb_diferente;
				strncpy (token, yytext, TAM_TOKEN);
				//IMPRIME(" diferente ");
				return DIFERENTE;
			}

"<"			{ simbolo = simb_menor;
				strncpy (token, yytext, TAM_TOKEN);
				//IMPRIME(" menor ");
				return MENOR;
			} 

">"			{ simbolo = simb_maior;
				strncpy (token, yytext, TAM_TOKEN);
				//IMPRIME(" maior ");
				return MAIOR;
			}

"<="		{ simbolo = simb_menor_igual;
				strncpy (token, yytext, TAM_TOKEN);
				//IMPRIME(" menor_igual ");
				return MENOR_IGUAL;
			}

">="		{ simbolo = simb_maior_igual;
				strncpy (token, yytext, TAM_TOKEN);
				//IMPRIME(" maior_igual ");
				return MAIOR_IGUAL;
			}

.			{ printf("Caractere Invalido: %s na linha %d. \n", yytext, nl); }

%%

int yywrap() {
    return 1;
}
