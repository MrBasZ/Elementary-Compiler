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
            printf("\t\tMOV\trbx, %ld\n", p->con.value);    // for many-constant
        } else{
            printf("\t\tMOV\trax, %ld\n", p->con.value);    // for one-constant
        }
        break;
    case typeId:        //tpye identifier Ex. $a, $b, .. ,$z
        if(p->id.poss == 0){
            printf("\t\tMOV\trcx, [Var%c]\n", p->id.i + 'a');   // for many-identifier
        } else if(p->id.poss == 0){
            printf("\t\tMOV\trbx, [Var%c]\n", p->id.i + 'a');   // for many-identifier
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
            printf("\n\t\tMOV\trbx, %d\n", ex(p->opr.op[0]));
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
                    printf("\t\tADD\trcx, rbx\n\n");
                    printf("\t\tMOV\trax, rcx\n\n");
                } else if(p->opr.poss == 0){
                    printf("\t\tADD\trcx, rbx\n\n");
                } else if(p->opr.poss == 1){
                    printf("\t\tADD\trbx, rcx\n\n");
                }
                break;
            case '-':
                printf(";%d===\n", p->opr.poss);
                
                if(p->opr.poss == -1){
                    printf("\t\tSUB\trcx, rbx\n");
                    printf("\t\tMOV\trax, rcx\n\n");
                } else if(p->opr.poss == 0){
                    printf("\t\tSUB\trcx, rbx\n");
                } else if(p->opr.poss == 1){
                    printf("\t\tNEG\trcx\n");
                    printf("\t\tSUB\trcx, rbx\n");
                }
                break;
            case '*':
                printf(";%d===\n", p->opr.poss);
                if(p->opr.poss == -1){
                    printf("\t\tMOV\trax, rcx\n");
                    printf("\t\tIMUL\trbx\n");
                    //move to rax
                } else if(p->opr.poss == 0){
                    printf("\t\tMOV\trax, rcx\n");
                    printf("\t\tIMUL\trbx\n");
                    printf("\t\tMOV\trcx, rax\n\n");
                } else if(p->opr.poss ==  1){
                    printf("\t\tMOV\trax, rbx\n");
                    printf("\t\tIMUL\trcx\n");
                    printf("\t\tMOV\trbx, rax\n\n");
                }
                break;
            case '/':
                printf(";%d===\n", p->opr.poss);
                if(p->opr.poss == -1){
                    printf("\t\tMOV\trdx, 0\n");
                    printf("\t\tMOV\trax, rcx\n");   
                    printf("\t\tDIV\trbx\n");
                    //printf("\t\tMOV\trax, rax\n");
                } else if(p->opr.poss == 0){
                    printf("\t\tMOV\trdx, 0\n");
                    printf("\t\tMOV\trax, rcx\n");
                    printf("\t\tDIV\trbx\n");
                    printf("\t\tMOV\trcx, rax\n\n");
                } else if(p->opr.poss ==  1){
                    printf("\t\tMOV\trdx, 0\n");
                    printf("\t\tMOV\trax, rb\n");
                    printf("\t\tDIV\trcx\n");
                    printf("\t\tMOV\trbx, rax\n\n");                }
                break;
            case '%':
                printf(";%d===\n", p->opr.poss);
                if(p->opr.poss == -1){
                    printf("\t\tMOV\trdx, 0\n");
                    printf("\t\tMOV\trax, rcx\n");   
                    printf("\t\tDIV\trbx\n");
                    printf("\t\tMOV\trax, rdx\n");
                } else if(p->opr.poss == 0){
                    printf("\t\tMOV\trdx, 0\n");
                    printf("\t\tMOV\trax, rcx\n");   
                    printf("\t\tDIV\trbx\n");
                    printf("\t\tMOV\trcx, rdx\n");
                } else if(p->opr.poss ==  1){
                    printf("\t\tMOV\trdx, 0\n");
                    printf("\t\tMOV\trax, rbx\n");   
                    printf("\t\tDIV\trcx\n");
                    printf("\t\tMOV\trbx, rdx\n");
                }
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
