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
    case typeId:        //tpye identifier Ex. $a, $b, .. ,$z
        if(p->id.poss == 0){
            printf("\t\tMOV\trcx, [Var%c]\n", p->id.i + 'a');   // for many-identifier
        } else if(p->id.poss == 0){
            printf("\t\tMOV\trdx, [Var%c]\n", p->id.i + 'a');   // for many-identifier
        } else{
            printf("\t\tMOV\trax, [Var%c]\n", p->id.i + 'a');   // for one-identifier
        }
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
            printf("\t\tMOV\t[Var%c], rax\n", p->opr.op[0]->id.i + 'a');
            break;
        case UMINUS:    
            ex(p->opr.op[0]);
            printf("\t\tNEG\n");
            break;
        default:
            ex(p->opr.op[0]);
            printf("\t\tPUSH\trcx\n");
            ex(p->opr.op[1]);
            printf("\n\t\tPOP\trcx\n");

            switch(p->opr.oper) {               // opr possition -1 = head node, 0 = child node
            case '+':
                printf(";%d===\n", p->opr.poss);
                if(p->opr.poss == -1){
                    printf("\t\tADD\trcx, rdx\n\n");
                    printf("\t\tMOV\trax, rcx\n\n");
                } else if(p->opr.poss == 0){
                    printf("\t\tADD\trcx, rdx\n\n");
                } else if(p->opr.poss == 1){
                    printf("\t\tADD\trdx, rcx\n\n");
                }
                break;
            case '-':
                printf(";%d===\n", p->opr.poss);
                printf("\t\tSUB\trcx, rdx\n");
                
                break;
            case '*':
                printf(";%d===\n", p->opr.poss);
                printf("\t\tMOV\trax, rcx\n");
                printf("\t\tIMUL\trdx\n");
                if(p->opr.poss == -1){
                    //
                } else if(p->opr.poss == 0){
                    printf("\t\tMOV\trcx, rax\n\n");
                } else if(p->opr.poss ==  1){
                    printf("\t\tMOV\trdx, rax\n\n");
                }
                break;
            case '/':
                printf("\t\tMOV\trax, rcx\n");   
                printf("\t\tDIV\trcx, rdx\n");
                printf("\t\tMOV\trdx, rax\n");
                break;
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
