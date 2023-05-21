%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "y.tab.h"
%}

%%

"type"         { return TYPE; }
"int"          { return INT_TYPE; }
[0-9]+         { yylval.value = atoi(yytext); return INTEGER; }
[a-zA-Z][a-zA-Z0-9]* { yylval.str = strdup(yytext); return IDENTIFIER; }
","            { return COMMA; }
";"            { return SEMICOLON; }
"="            { return ASSIGN; }
"("            { return LPAREN; }
")"            { return RPAREN; }
"+"            { return ADD; }
"-"            { return SUB; }
"*"            { return MUL; }
"/"            { return DIV; }
[ \t\n]        { /* ignore whitespace */ }
.              { printf("Invalid character: %s\n", yytext); }

%%

int yywrap() {
    return 1;
}