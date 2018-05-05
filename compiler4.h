typedef enum { typeCon, typeId, typeOpr, typeStr } nodeEnum;

/* constants */
typedef struct {
    int value;                  /* value of constant */
    int poss;                   /* 0=left, 1=right */
} conNodeType;

/* identifiers */
typedef struct {
    int i;                      /* subscript to sym array */
    int poss;                   /* 0=left node, 1=right node */
    char *str;                  /* value of string */
} idNodeType;

/* operators */
typedef struct {
    int oper;                   /* operator */
    int nops;                   /* number of operands */
    int poss;                   /* -1 = start node */
    struct nodeTypeTag *op[1];	/* operands, extended at runtime */
} oprNodeType;

typedef struct nodeTypeTag {
    nodeEnum type;              /* type of node */

    union {
        conNodeType con;        /* constants */
        idNodeType id;          /* identifiers */
        oprNodeType opr;        /* operators */
    };
} nodeType;

extern int sym[26];
