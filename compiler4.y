%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include "compiler4.h"

/* prototypes */
nodeType *opr(int oper, int nops, ...);
nodeType *id(int i);
nodeType *con(int value);
nodeType *str(char *str);

void freeNode(nodeType *p);
int ex(nodeType *p);
void yyerror(char *s);
int oneParse(char* filename);

int yylex(void);
extern FILE* yyin;
extern int yylineno;

int no_msg = 0;
int sym[26];                    /* symbol table */

typedef struct texts {
    char *msg;
    struct texts *next;
} save_texts;

void print_dataText(save_texts *h);
save_texts *h, *t = NULL;

%}

%union {
    int iValue;                 /* integer value */
    char sIndex;                /* symbol table index */
    char *string;                /* string */
    nodeType *nPtr;             /* node pointer */
};

%token      <iValue> CONSTANT
%token      <sIndex> VARIABLE
%token      <string> STRING
%token      LOOP IF PRINT PRINTLN SHOWDEC SHOWHEX
%nonassoc   IFX
%nonassoc   ELSE

%token      END_OF_FILE 0

%left       GE LE EQ NE '>' '<'
%left       '+' '-'
%left       '*' '/' '%'
%nonassoc   UMINUS

%type <nPtr> stmt expr stmt_list text

%start file

%%

file:
        line END_OF_FILE        {
                                    /* append exit to assembly */
                                    printf("\n\t\tMOV\trbx, 0\n"); // return 0 status on exit - 'No Errors'
                                    printf("\t\tMOV\trax, 1\n"); // invoke SYS_EXIT (kernel opcode 1)
                                    printf("\t\tINT\t80h\n");

                                    /* data section */
                                    printf("\n\t\tSECTION\t.data\n\n");

                                    // append text data
                                    print_dataText(h);
                                    // clear list text
                                    free(h);
                                }
        ;

line:   
           stmt                     { 
                                        //printf("SAVE\n");
                                        ex($1); freeNode($1);
                                        //printf("RESAVE\n");
                                    }
        |  line stmt                {   
                                        //printf("SAVE\n");
                                        ex($2); freeNode($2);
                                        //printf("RESAVE\n");
                                    }
        ;

stmt:   
          PRINT '(' text ')' ';'            { $$ = opr(PRINT, 1, $3); }
        | SHOWDEC '(' expr ')' ';'          { $$ = opr(SHOWDEC, 1, $3); }
        | SHOWHEX '(' expr ')' ';'          { $$ = opr(SHOWHEX, 1, $3); }
        | PRINTLN '(' ')' ';'               { printf("\n"); }
        | expr ';'                          { $$ = $1; }
        | VARIABLE '=' expr ';'             { $$ = opr('=', 2, id($1), $3); }
        | LOOP '(' expr ',' expr ')' stmt   { $$ = opr(LOOP, 3, $3, $5, $7); }
        | IF '(' expr ')' stmt %prec IFX    { $$ = opr(IF, 2, $3, $5); }
        | IF '(' expr ')' stmt ELSE stmt    { $$ = opr(IF, 3, $3, $5, $7); }
        | '{' stmt_list '}'                 { $$ = $2; }
        ;

text:
        { $$ = NULL; }
        | STRING                { $$ = str($1); no_msg++;}
        ;

stmt_list:
          stmt                  { $$ = $1; }
        | stmt_list stmt        { $$ = opr(';', 2, $1, $2); }
        ;

expr:                           
          CONSTANT              { $$ = con($1); }
        | VARIABLE              { $$ = id($1); }
        | '-' expr %prec UMINUS { 
                                    $$ = opr(UMINUS, 1, $2);
                                    $2->id.poss = 0;
                                    $2->con.poss = 0;
                                }
        | expr '+' expr         { 
                                    $$ = opr('+', 2, $1, $3);
                                    $1->con.poss = 0;
                                    $3->con.poss = 1;
                                    $1->id.poss = 0;
                                    $3->id.poss = 1;
                                }
        | expr '-' expr         { 
                                    $$ = opr('-', 2, $1, $3);
                                    $1->con.poss = 0;
                                    $3->con.poss = 1;
                                    $1->id.poss = 0;
                                    $3->id.poss = 1;
                                }
        | expr '*' expr         { 
                                    $$ = opr('*', 2, $1, $3);
                                    $1->con.poss = 0;
                                    $3->con.poss = 1;
                                    $1->id.poss = 0;
                                    $3->id.poss = 1;
                                }
        | expr '/' expr         { 
                                    if($3->con.value){
                                        $$ = opr('/', 2, $1, $3);
                                        $1->con.poss = 0;
                                        $3->con.poss = 1;
                                        $1->id.poss = 0;
                                        $3->id.poss = 1;
                                    } else {
                                        yyerror("Error! Division by zero");
                                        YYABORT;
                                    }
                                    
                                }
        | expr '<' expr         { $$ = opr('<', 2, $1, $3); }
        | expr '>' expr         { $$ = opr('>', 2, $1, $3); }
        | expr GE expr          { $$ = opr(GE, 2, $1, $3); }
        | expr LE expr          { $$ = opr(LE, 2, $1, $3); }
        | expr NE expr          { $$ = opr(NE, 2, $1, $3); }
        | expr EQ expr          { $$ = opr(EQ, 2, $1, $3); }
        | '(' expr ')'          { $$ = $2; }
        ;

%%

nodeType *con(int value) {
    nodeType *p;

    /* allocate node */
    if ((p = malloc(sizeof(nodeType))) == NULL)
        yyerror("out of memory");

    /* copy information */
    p->type = typeCon;
    p->con.value = value;
    p->con.poss = -1;

    return p;
}

nodeType *id(int i) {
    nodeType *p;

    /* allocate node */
    if ((p = malloc(sizeof(nodeType))) == NULL)
        yyerror("out of memory");

    /* copy information */
    p->type = typeId;
    p->id.i = i;
    p->id.poss = -1;

    return p;
}

nodeType *str(char *strc){
    nodeType *p;
    save_texts *s;
    /* allocate node */
    if ((p = malloc(sizeof(nodeType))) == NULL)
        yyerror("out of memory");
    if ((s = malloc(sizeof(save_texts))) == NULL)
        yyerror("out of memory");
    
    /* copy information */
    p->type = typeStr;
    p->id.str = strdup(strc);

    /* save text */
    if(h == NULL){
        s->msg = strdup(strc);
        s->next = NULL;
        h = s;
        t = s;
    }
    else{
        s->msg = strdup(strc);
        s->next = NULL;
        t->next = s;
        t = s;
    }

    return p;
}

nodeType *opr(int oper, int nops, ...) {
    va_list ap;
    nodeType *p;
    int i;

    /* allocate node, extending op array */
    if ((p = malloc(sizeof(nodeType) + (nops-1) * sizeof(nodeType *))) == NULL)
        yyerror("out of memory");

    /* copy information */
    p->type = typeOpr;
    p->opr.oper = oper;
    p->opr.nops = nops;
    p->opr.poss = -1;
    /* Initializing arguments to store all values after num */
    va_start(ap, nops);
    for (i = 0; i < nops; i++){
            p->opr.op[i] = va_arg(ap, nodeType*);
            
        }
    va_end(ap); // Cleans up the list
    return p;
}

void freeNode(nodeType *p) {
    int i;

    if (!p) return;
    if (p->type == typeOpr) {
        for (i = 0; i < p->opr.nops; i++)
            freeNode(p->opr.op[i]);
    }
    free (p);
}

void yyerror(char *s) {
    fprintf(stdout, "\n\n; %s!\n", s);
}

//text section
char *header = "\t\tSECTION\t.text\n\t\tglobal\t_start\n\n_start:\n";

int main(int argc, char* argv[]) {

    printf("%s", header);

    if (argc == 2){
	    if (oneParse(argv[1]) == -1){
	        return -1;
	    }
    }
    else{
        char	filename[256] = {0};

            sprintf(filename, "test_cases/test1.bug");

            if (oneParse(filename) != 0)
            {
                return -1;
            }

            printf("\n; ======== parsed! ========\n");
            
    }
    return 0;
}

//	return 0 for success, others for error
int oneParse(char* filename)
{
    yyin = fopen(filename, "r");
    if (yyin == NULL)
    {
	    printf("File open error!\n");
        return -1;
    }

    int ret = yyparse();

    fclose(yyin);
    return ret;
}

void print_dataText(save_texts *h){
    int i = 0;
    while(h){
        printf("\t\tmsg%0d\tdb\t\'%s\'\n",++i ,h->msg);
        h=h->next;
    }
    return;
}