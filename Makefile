$DEPURA=1
CC=gcc
REDIRECT= 2> /dev/null

compilador: lex.yy.c y.tab.c compilador.o compilador.h pilha.o
	@echo "Gerando compilador...."
	@$(CC)  -g lex.yy.c compilador.tab.c pilha.o  compilador.o -o compilador -ll -ly -lc $(REDIRECT)
	@echo "Compilador gerado com sucesso. Execute com: ./compilador <arquivo.pas>"

lex.yy.c: compilador.l compilador.h
	@echo "Executando flex...."
	@flex compilador.l  $(REDIRECT)

y.tab.c: compilador.y compilador.h
	@echo "Executando bison...."
	@bison compilador.y -d -v $(REDIRECT)

compilador.o : compilador.h compiladorF.c
	@echo "Compilando funcoes do compilador...."
	@$(CC) -c compiladorF.c -o compilador.o  $(REDIRECT)

pilha.o: pilha.c pilha.h
	@echo "Compilando pilha...."
	@$(CC) -g -c pilha.c -o pilha.o $(REDIRECT)
clean : 
	@echo "Removendo executaveis...."
	@rm -f compilador 
	@echo "Removendo objetos...."
	@rm -f *.o *~ *.bak
	@echo "Removendo lixo...."
	@rm -f core 
	@rm -f compilador.tab.* lex.yy.c 
