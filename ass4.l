digits [0-9]
ws     [ \t]+  
hex	   [a-fA-F0-9]
string [a-zA-Z0-9]

/* lex file for infix notation calculator */
%option noyywrap

%{
#include <stdlib.h>        /* for atof(const char*) */
#include <string.h>
#include <stdio.h>
#include <math.h>
#include "y.tab.h"

/* Prototype function */
int toDecimal(char *);
int getVar(char *);

%}

%%

"showdec"       { return SHOWDEC;                                   }
"showhex"       { return SHOWHEX;                                   }
"print"         { return PRINT;                                     }
"println"       { return PRINTLN;                                   }
"if"            { return IF;                                        }
"else"          { return ELSE;                                      }
"loop"          { return LOOP;                                      }

"("             { return P_LEFT;                                    }
")"             { return P_RIGHT;                                   }
"{"             { return B_LEFT;                                    }
"}"             { return B_RIGHT;                                   }
","             { return COMMA;                                     }
";"             { return SEMI;                                      }

"="             { return ASSIGN;                                    }
"<"             { return LESS;                                      }
"<="            { return LESSEQ;                                    }
">"             { return MORE;                                      }
">="            { return MOREEQ;                                    }
"=="            { return ISEQUAL;                                   }
"!="            { return NOTEQUAL;                                  }

"$"[a-z]        { 
                    yylval.i = getVar(yytext);
                    return REG;           
                }

{ws}            /* eats up white spaces */
{digits}+       { 
                    yylval.i = atoi(yytext);
                    return DEC;
                }

{hex}+"h"       {
                    yylval.i = toDecimal(yytext);
                    return HEX; // hexdecimal ex. F2A3h
                }

{string}+       {
                    yylval.s = strdup(yytext);
                    return STRING;
                }

\n              { return *yytext;                                   }      

.               { return yytext[0];                                 }
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

int main(int argc, char **argv)
{
    while(1)
    {
        yyparse();
    }
}
