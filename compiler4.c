#include <stdio.h>
#include <string.h>
#include "compiler4.h"
#include "y.tab.h"

extern int no_msg;

int ex(nodeType *p) {
    if (!p) return 0;
    switch(p->type) {
    case typeCon:       return p->con.value;
    case typeId:        return sym[p->id.i];
    case typeStr:       return strlen(p->id.str);
    case typeOpr:
        switch(p->opr.oper) {
        case LOOP:     {  
                            int i = ex(p->opr.op[0]);
                            int j = ex(p->opr.op[1]);;
                            while(j >= i){
                                ex(p->opr.op[2]);
                                i++;
                            } return 0;
                        }
        case IF:        if (ex(p->opr.op[0]))
                            ex(p->opr.op[1]);
                        else if (p->opr.nops > 2)
                            ex(p->opr.op[2]);
                        return 0;
        case SHOWDEC:   printf("%d\n", ex(p->opr.op[0])); return 0;
        case SHOWHEX:   printf("%xh\n", ex(p->opr.op[0])); return 0;
        case PRINT:     {
                            // printf("%s\n", ex(p->opr.op[0])); return 0;
                            printf("\n\t\tMOV\trdx, %d\n", ex(p->opr.op[0]));
                            printf("\t\tMOV\trcx, msg%0d\n", no_msg);
                            printf("\t\tMOV\trbx, 1\n");
                            printf("\t\tMOV\trax, 4\n");
                            printf("\t\tINT\t80h\n");
                            return 0;
                        }
        
        case '=':       return sym[p->opr.op[0]->id.i] = ex(p->opr.op[1]);
        case UMINUS:    return -ex(p->opr.op[0]);
        case '+':       return ex(p->opr.op[0]) + ex(p->opr.op[1]);
        case '-':       return ex(p->opr.op[0]) - ex(p->opr.op[1]);
        case '*':       return ex(p->opr.op[0]) * ex(p->opr.op[1]);
        case '/':       return ex(p->opr.op[0]) / ex(p->opr.op[1]);
        case '<':       return ex(p->opr.op[0]) < ex(p->opr.op[1]);
        case '>':       return ex(p->opr.op[0]) > ex(p->opr.op[1]);
        case GE:        return ex(p->opr.op[0]) >= ex(p->opr.op[1]);
        case LE:        return ex(p->opr.op[0]) <= ex(p->opr.op[1]);
        case NE:        return ex(p->opr.op[0]) != ex(p->opr.op[1]);
        case EQ:        return ex(p->opr.op[0]) == ex(p->opr.op[1]);
        }
    }
    return 0;
}
