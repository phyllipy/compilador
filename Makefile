$DEPURA=1
CC=gcc


compilador: lex.yy.c y.tab.c compilador.o compilador.h pilha.o
	@echo "Gerando compilador...."
	@$(CC)  -g lex.yy.c compilador.tab.c pilha.o  compilador.o -o compilador -ll -ly -lc  2> /dev/null
	@echo "Compilador gerado com sucesso. Execute com: ./compilador <arquivo.pas>"

lex.yy.c: compilador.l compilador.h
	@echo "Executando flex...."
	@flex compilador.l 2> /dev/null

y.tab.c: compilador.y compilador.h
	@echo "Executando bison...."
	@bison compilador.y -d -v 2> /dev/null

compilador.o : compilador.h compiladorF.c
	@echo "Compilando pilha...."
	@$(CC) -c compiladorF.c -o compilador.o 2> /dev/null

pilha.o: pilha.c pilha.h
	echo "Compilando pilha...."
	@$(CC) -g -c pilha.c -o pilha.o 2> /dev/null
clean : 
	@echo "Removendo executaveis...."
	@rm -f compilador 
	@echo "Removendo objetos...."
	@rm -f *.o *~ *.bak
	@echo "Removendo lixo...."
	@rm -f core 
	@rm -f compilador.tab.* lex.yy.c 
