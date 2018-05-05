#include <stdio.h>
#include <string.h>
#include "compiler4.h"
#include "y.tab.h"

static int lbl;
extern int no_msg;

int ex(nodeType *p) {
    int lbl1, lbl2;

    if (!p) return 0;
    switch(p->type) {
    case typeCon:               //constant tpye Ex. 1,2,13h....       
        if(p->con.poss == 0){   // position data for declare register
            printf("\t\tMOV\trcx, %ld\n", p->con.value);    // for many-constant
        } else if(p->con.poss == 1){
            printf("\t\tMOV\trdx, %ld\n", p->con.value);    // for many-constant
        } else{
            printf("\t\tMOV\trax, %ld\n", p->con.value);    // for one-constant
        }
        break;
    case typeId:        
        printf("\tpush\t%c\n", p->id.i + 'a'); 
        break;
    case typeStr:
        return strlen(p->id.str);   //calculate string leng
        break;
    case typeOpr:               //tpye of operarator Ex. loop, if, print...
        switch(p->opr.oper) {
        case LOOP:
            printf("L%03d:\n", lbl1 = lbl++);
            ex(p->opr.op[0]);
            printf("\tjz\tL%03d\n", lbl2 = lbl++);
            ex(p->opr.op[1]);
            printf("\tjmp\tL%03d\n", lbl1);
            printf("L%03d:\n", lbl2);
            break;
        case IF:
            ex(p->opr.op[0]);
            if (p->opr.nops > 2) {
                /* if else */
                printf("\tjz\tL%03d\n", lbl1 = lbl++);
                ex(p->opr.op[1]);
                printf("\tjmp\tL%03d\n", lbl2 = lbl++);
                printf("L%03d:\n", lbl1);
                ex(p->opr.op[2]);
                printf("L%03d:\n", lbl2);
            } else {
                /* if */
                printf("\tjz\tL%03d\n", lbl1 = lbl++);
                ex(p->opr.op[1]);
                printf("L%03d:\n", lbl1);
            }
            break;
        case PRINT:     
            printf("\n\t\tMOV\trdx, %d\n", ex(p->opr.op[0]));
            printf("\t\tMOV\trcx, msg%0d\n", no_msg);
            printf("\t\tMOV\trbx, 1\n");
            printf("\t\tMOV\trax, 4\n");
            printf("\t\tINT\t80h\n");
            break;
        case SHOWDEC:
            printf("%d\n", ex(p->opr.op[0]));
            break;
        case SHOWHEX:
            printf("%x\n", ex(p->opr.op[0]));
            break;
        case '=':       
            ex(p->opr.op[1]);
            printf("\tpop\t%c\n", p->opr.op[0]->id.i + 'a');
            break;
        case UMINUS:    
            ex(p->opr.op[0]);
            printf("\tneg\n");
            break;
        default:
            ex(p->opr.op[0]);
            ex(p->opr.op[1]);
            switch(p->opr.oper) {
            case '+':
                printf("\t\tADD\trcx, rdx\n");
                break;
            case '-':
                printf("\t\tSUB\trcx, rdx\n");
                break;
            case '*':   printf("\t\tMUL\n"); break;
            case '/':   printf("\tdiv\n"); break;
            case '<':   printf("\tcompLT\n"); break;
            case '>':   printf("\tcompGT\n"); break;
            case GE:    printf("\tcompGE\n"); break;
            case LE:    printf("\tcompLE\n"); break;
            case NE:    printf("\tcompNE\n"); break;
            case EQ:    printf("\tcompEQ\n"); break;
            }
        }
    }
    return 0;
}
