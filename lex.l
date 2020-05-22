%{
	#include "y.tab.h"
	#include <bits/stdc++.h>
	int currentLine = 1;

	extern int printLineNumber(int lineNumber);
%}
letter [a-zA-Z]
digit [0-9]
digits {digit}+

relop "=="|"!="|">"|">="|"<"|"<="
boolop "&&"|"||"
arithop "+"|"-"|"*"|"/"|"%"|"&"|"|"

id {letter}({letter}|{digit})*

int_num "-"?{digits}
float_num "-"?{digits}.{digits}("E"{digits}+)?
bool_val "true"|"false"

%%
"int"	{return INT_DECL;}
"float"	{return FLOAT_DECL;}
"boolean" {return BOOL_DECL;}

{int_num}	{yylval.ival = atoi(yytext); return INT;}
{float_num}	{yylval.fval = atof(yytext); return FLOAT;}
{bool_val} {if(!strcmp(yytext,"true")){ yylval.bval = 1;} else { yylval.bval = 0;} return BOOL;}

"if"	{return IF_STMT;}
"else"	{return ELSE_STMT;}
"while"	{return WHILE_STMT;}
"for"	{return FOR_STMT;}

{arithop}	{yylval.opval = strdup(yytext); return ARITH_OP;}
{relop} {yylval.opval = strdup(yytext); return REL_OP;}
{boolop} {yylval.opval = strdup(yytext); return BOOL_OP;}

{id}	{yylval.idval = strdup(yytext);return IDENTIFIER;}

";" { return SEMICOLON;}
"=" {return EQU;}

"(" { return OPEN_BRACKET;}
")" {return CLOSE_BRACKET;}
"{" {return OPEN_CURLY_BRACKET;}
"}" {return CLOSE_CURLY_BRACKET;}

\n	{++currentLine;	printLineNumber(currentLine);}
%%


int yywrap() {
}
