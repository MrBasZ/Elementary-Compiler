/* Infix notation calculator.  */

%{
  #include <math.h>
  #include <string.h>
  #include <stdio.h>
  int yylex (void);
  int yyerror (char *);
  void loadValue(int,int);
  void loadValueConst(int,int);
  int showValue(int);
  int isZero(int);
  
  int regist[26];
  int error=0;
%}

%union {
    int i;
    float f;
    char *s;
}

/* Bison declarations.  */
%token <i> DEC HEX REG 
%token <f> P_LEFT P_RIGHT B_LEFT B_RIGHT ASSIGN
%token <f> COMMA SEMI NEWLINE
%token <f> SHOWDEC SHOWHEX PRINT PRINTLN IF ELSE LOOP ENDLOOP 
%token <f> LESS LESSEQ MORE MOREEQ ISEQUAL NOTEQUAL
%token <s> STRING
%left '-' '+' 
%left '*' '/' '%' '='  
%nonassoc NEG 
/* negation--unary minus */
%right '^'        /* exponentiation */
%type <i> exp command comp

%% /* The grammar follows.  */
input:
  %empty
| input line  {printf("> ");}
|input error line {
                    yyclearin;
                    yyerrok;
                    YYABORT;
                  }
;
line:
  '\n'      {error=0;}
| command   {}
;
command:
REG ASSIGN exp SEMI                               {regist[$1]=$3;}
| SHOWDEC P_LEFT REG P_RIGHT SEMI                 {printf("%d",regist[$3]);}
| SHOWDEC P_LEFT DEC P_RIGHT SEMI                 {printf("%d",$3);}
| SHOWDEC P_LEFT HEX P_RIGHT SEMI                 {printf("%d",$3);}
| SHOWHEX P_LEFT REG P_RIGHT SEMI                 {printf("%xh",regist[$3]);}
| SHOWHEX P_LEFT HEX P_RIGHT SEMI                 {printf("%xh",$3);}
| SHOWHEX P_LEFT DEC P_RIGHT SEMI                 {printf("%xh",$3);}
| PRINT P_LEFT STRING P_RIGHT SEMI                {printf("%s",$3);}
| PRINTLN P_LEFT P_RIGHT SEMI                     {printf("\n");}
| IF P_LEFT comp P_RIGHT B_LEFT command B_RIGHT   {if($3){$6;}}
| IF P_LEFT comp P_RIGHT B_LEFT command B_RIGHT ELSE B_LEFT command B_RIGHT    {if($3){$6;} else {$10;}}
| LOOP P_LEFT exp COMMA exp P_RIGHT B_LEFT command B_RIGHT  {printf("loop");}
;
comp:
  exp LESS exp    {$$ = ($1<$3?1:0);}
| exp LESSEQ exp  {$$ = ($1<=$3?1:0);}
| exp MORE exp    {$$ = ($1>$3?1:0);}
| exp MOREEQ exp  {$$ = ($1>=$3?1:0);}
| exp ISEQUAL exp {$$ = ($1==$3?1:0);}
| exp NOTEQUAL exp{$$ = ($1!=$3?1:0);}  
| REG LESS REG    {$$ = ($1<$3?1:0);}
| REG LESSEQ REG  {$$ = ($1<=$3?1:0);}
| REG MORE REG    {$$ = ($1>$3?1:0);}
| REG MOREEQ REG  {$$ = ($1>=$3?1:0);}
| REG ISEQUAL REG {$$ = ($1==$3?1:0);}
| REG NOTEQUAL REG{$$ = ($1!=$3?1:0);}  
;
exp:
  HEX                 { $$ = $1;}
| DEC                 { $$ = $1;               }
| exp '+' exp         { $$ = $1 + $3;          }
| exp '-' exp         { $$ = $1 - $3;          }
| exp '*' exp         { $$ = $1 * $3;          }
| exp '/' exp         { $$ = $1 / isZero($3);  }
| exp '%' exp         { $$ = (int)$1 % isZero($3);}
| '-' exp %prec NEG       { $$ = -$2;              }
| exp '^' exp         { $$ = pow ($1, $3);     }
| P_LEFT exp P_RIGHT  { $$ = $2;               }
| REG                {$$=regist[(int)$1];}
;

%%

void loadValue(int first,int second) //store value of register in regist[second]
{
  regist[second]=regist[first];
}

void loadValueConst(int first,int second) //store value in regist[second]
{
  regist[second]=first;
}

int showValue(int value) //show value in each register
{
  return regist[value];
}

int isZero(int num) //check num is zero or not 
{
  if(num==0) 
  {
    yyerror("Cannot divide or mod by zero");
  }
  else return num;
}

int yyerror(char *errormsg)
{
    error++;
    fprintf(stderr, "%s\n", errormsg);
}

