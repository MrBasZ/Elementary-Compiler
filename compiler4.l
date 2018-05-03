digits [0-9]+
ws     [ \t\n]+  
hex	   [a-fA-F0-9]
string [a-zA-Z0-9]

/* lex file for infix notation calculator */
%option noyywrap
%{
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <math.h>
#include "compiler4.h"
#include "y.tab.h"

/* Prototype function */
void yyerror(char *);
long toDecimal(char *);
int getVar(char *);
%}

%%

"$"[a-z]        { 
                    yylval.sIndex = getVar(yytext);
                    return VARIABLE;
                }

{digits}        {
                    yylval.iValue = atoi(yytext);
                    return CONSTANT;
                }

{hex}+"h"       {
                    yylval.iValue = toDecimal(yytext);
                    return CONSTANT;
                }

{string}        {
                    yylval.string = strdup(yytext);
                    return STRING;
                }

[-()<>=+*/;{},] {
                    return *yytext;
                }

">="            return GE;
"<="            return LE;
"=="            return EQ;
"!="            return NE;

"if"            return IF;
"else"          return ELSE;
"print"         return PRINT;
"showdec"       return SHOWDEC;
"showhex"       return SHOWHEX;
"println"       return PRINTLN;
"loop"          return LOOP;

{ws}            ;       /* ignore whitespace */

.               return yytext[0];
%%

//convert hexadecomal to decimal
long toDecimal(char *yytext)
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

        decimal += val * (int)pow((double)16, len);
        len--;
        i++;
    }
    return decimal;
     
}

// calculate subscript of array in register $rA-$rZ (0-25)
int getVar(char *yytext) 
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