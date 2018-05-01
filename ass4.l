/* lex file for infix notation calculator */
%option noyywrap

%{
//#define YYSTYPE char*     /* type for bison's var: yylval */

#include <stdlib.h>        /* for atof(const char*) */
#include <string.h>
#include <stdio.h>
#include <math.h>
#include "y.tab.h"
%}

digits [0-9]
op     [+-*/^%]
ws     [ \t]+  
h	   [a-fA-F0-9]
string [a-zA-Z0-9]
%%
\n              return *yytext;
{ws}            /* eats up white spaces */
"("             return P_LEFT;
")"             return P_RIGHT;
"{"             return B_LEFT;
"}"             return B_RIGHT;
","             return COMMA;
";"             return SEMI;
{digits}+       yylval.i = atoi(yytext); return DEC;
{h}+"h"         yylval.i = toDecimal(yytext); return HEX;// hexdecimal ex. F2A3h
"showdec"       return SHOWDEC;
"showhex"       return SHOWHEX;
"print"         return PRINT;
"println"       return PRINTLN;
"$"[a-z]        yylval.i = calPos(yytext); return REG;
"="             return ASSIGN;
"if"            return IF;
"else"          return ELSE;
"<"             return LESS;
"<="            return LESSEQ;
">"             return MORE;
">="            return MOREEQ;
"=="            return ISEQUAL;
"!="            return NOTEQUAL;
"loop"          return LOOP;
"endloop"       return ENDLOOP;
{string}+       {yylval.s = strdup(yytext); return STRING; }
.               return yytext[0];

%%

//convert hexadecomal to decimal
int toDecimal(char *yytext)
{
    int i=0;
    int decimal=0;
    int len = strlen(yytext);
    int val=0;
    len-=2;
    while(yytext[i]!= 'h')
    {
        if(yytext[i]>='0' && yytext[i]<='9')
        {
            val = yytext[i] - 48;
        }
        else if(yytext[i]>='a' && yytext[i]<='f')
        {
            val = yytext[i] - 97 + 10;
        }
        else if(yytext[i]>='A' && yytext[i]<='F')
        {
            val = yytext[i] - 65 + 10;
        }

        decimal += val * pow(16, len);
        len--;
        i++;
    }
    return decimal;
     
}

// calculate subscript of array in register $rA-$rZ (0-25)
int calPos(char *yytext) 
{
    int pos=0;
    //if alphabet is uppercase
    if(yytext[1]>='A' && yytext[1]<='Z'){ 
        pos=yytext[1]-'A';
    } 
    //if alphabet is lowercase
    else if(yytext[1]>='a' && yytext[1]<='z')
    {
        pos=yytext[1]-'a';
    }
    return pos;
}
int main()
{
    printf("> ");
    while(1)
    {
        yyparse();
    }
}
