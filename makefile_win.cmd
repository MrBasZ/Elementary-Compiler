yacc -dy -v compiler4.y
flex compiler4.l
gcc -c y.tab.c lex.yy.c
gcc y.tab.o lex.yy.o compiler4.c -o ex.exe