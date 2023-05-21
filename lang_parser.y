%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct ast_node {
    char* type;
    int value;
    char* identifier;
    ast_node* left;
    ast_node* right;
} ast_node;

extern int yylex();
extern int yyparse();
extern FILE* yyin;

void yyerror(const char* s);

ast_node* new_ast_node(char* type, int value, char* identifier, ast_node* left, ast_node* right);
void free_ast(ast_node* node);
void print_ast(ast_node* node, int indent);

ast_node* root = NULL;
%}

%union {
    char* str;
    int value;
    ast_node* node;
}

%token <str> IDENTIFIER
%token <value> INTEGER
%token INT_TYPE 
%token TYPE
%token COMMA 
%token SEMICOLON 
%token ASSIGN 
%token LPAREN 
%token RPAREN
%left ADD SUB
%left MUL DIV 

%type <node> program
%type <node> declarations
%type <node> declaration
%type <node> identifier_list
%type <node> assignments
%type <node> assignment
%type <node> expression

%%

program:
    declarations assignments
    {
        root = new_ast_node("program", 0, NULL, $1, $2);
    }
    ;

declarations:
    declaration
    {
        $$ = $1;
    }
    | declarations declaration
    {
        ast_node* temp = new_ast_node("declarations", 0, NULL, $1, $2);
        $$ = temp;
    }
    ;

declaration:
    TYPE INT_TYPE identifier_list SEMICOLON
    {
        ast_node* temp = new_ast_node("declaration", 0, NULL, $3, NULL);
        $$ = temp;
    }
    ;

identifier_list:
    IDENTIFIER
    {
        ast_node* temp = new_ast_node("identifier", 0, $1, NULL, NULL);
        $$ = temp;
    }
    | identifier_list COMMA IDENTIFIER
    {
        ast_node* temp = new_ast_node("identifier", 0, $3, NULL, NULL);
        ast_node* list = $1;
        while (list->right != NULL) {
            list = list->right;
        }
        list->right = temp;
        $$ = $1;
    }
    ;

assignments:
    assignment
    {
        $$ = $1;
    }
    | assignments assignment
    {
        ast_node* temp = new_ast_node("assignments", 0, NULL, $1, $2);
        $$ = temp;
    }
    ;

assignment:
    IDENTIFIER ASSIGN expression SEMICOLON
    {
        ast_node* temp = new_ast_node("assignment", 0, $1, $3, NULL);
        $$ = temp;
    }
    ;

expression:
    INTEGER
    {
        ast_node* temp = new_ast_node("integer", $1, NULL, NULL, NULL);
        $$ = temp;
    }
    | IDENTIFIER
    {
        ast_node* temp = new_ast_node("identifier", 0, $1, NULL, NULL);
        $$ = temp;
    }
    | LPAREN expression RPAREN
    {
        $$ = $2;
    }
    | expression ADD expression
    {
        ast_node* temp = new_ast_node("add", 0, NULL, $1, $3);
        $$ = temp;
    }
    | expression SUB expression
    {
        ast_node* temp = new_ast_node("sub", 0, NULL, $1, $3);
        $$ = temp;
    }
    | expression MUL expression
    {
        ast_node* temp = new_ast_node("mul", 0, NULL, $1, $3);
        $$ = temp;
    }
    | expression DIV expression
    {
        ast_node* temp = new_ast_node("div", 0, NULL, $1, $3);
        $$ = temp;
    }
    ;

%%

ast_node* new_ast_node(char* type, int value, char* identifier, ast_node* left, ast_node* right) {
    ast_node* node = (ast_node*) malloc(sizeof(ast_node));
    node->type = type;
    node->value = value;
    node->identifier = identifier;
    node->left = left;
    node->right = right;
    return node;
}

void free_ast(ast_node* node) {
    if (node == NULL) {
        return;
    }
    free_ast(node->left);
    free_ast(node->right);
    free(node);
}

void print_ast(ast_node* node, int indent) {
    if (node == NULL) {
        return;
    }
    for (int i = 0; i < indent; i++) {
        printf("  ");
    }
    printf("%s", node->type);
    if (node->value != 0) {
        printf(": %d", node->value);
    }
    if (node->identifier != NULL) {
        printf(": %s", node->identifier);
    }
    printf("\n");
    print_ast(node->left, indent + 1);
    print_ast(node->right, indent);
}

void yyerror(const char* s) {
    fprintf(stderr, "Error: %s\n", s);
}

int main() {
    yyparse();
    print_ast(root, 0);
    free_ast(root);
    return 0;
}
