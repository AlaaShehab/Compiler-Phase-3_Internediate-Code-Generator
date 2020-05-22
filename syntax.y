%{
#include <bits/stdc++.h>
#include <unistd.h>

using namespace std;

extern  int yylex();
extern  FILE *yyin;
void yyerror(const char * s);

extern int currentLine;
ofstream fileOut("byteCode.j");

typedef enum {INT_TYPE, FLOAT_TYPE, BOOL_TYPE, VOID_TYPE, ERROR_TYPE} type_enum;

map<string,string> instructions = {
	/* arithmetic operations */
	{"+", "add"},
	{"-", "sub"},
	{"/", "div"},
	{"*", "mul"},
	{"|", "or"},
	{"&", "and"},
	/* relational operations */
	{"==", "if_icmpeq"},
	{"<=", "if_icmple"},
	{">=", "if_icmpge"},
	{"!=", "if_icmpne"},
	{">",  "if_icmpgt"},
	{"<",  "if_icmplt"}
};

map<string, pair<int,type_enum> > symbolTable;

vector<string> codeGenList;

string classFileName ;
int varaiblesNum = 1; 	/* new variable will be issued this number, java starts with 1, 0 is 'this' */
int currentLabel = 0;

void generateHeader(void);
void generateFooter(void);

void checkType(int from , int to, string op);
void backpatch(vector<int> *list, int num);
void defineVariable(string name, int type);
string getOperationName(string op);
string getLabel(int n);
string generateLabel();
void addLineCode(string x);
void printCode(void);
bool findInSymbolTab(string id);
vector<int> * merge (vector<int> *list1, vector<int>* list2);


void printLineNumber(int lineNumber)
{
	addLineCode(".line "+ to_string(lineNumber));
}
%}

%token <ival> INT
%token <fval> FLOAT
%token <bval> BOOL

%token <idval> IDENTIFIER

%token <opval> ARITH_OP
%token <opval> REL_OP
%token <opval> BOOL_OP

%token IF_STMT
%token ELSE_STMT
%token WHILE_STMT
%token FOR_STMT

%token INT_DECL
%token FLOAT_DECL
%token BOOL_DECL

%token SEMICOLON
%token EQU
%token OPEN_BRACKET
%token CLOSE_BRACKET
%token OPEN_CURLY_BRACKET
%token CLOSE_CURLY_BRACKET

%type <synType> primitive_type

%type <expr_type> expression

%type <inh_bool_list_type> bool_expression

%type <inh_next_list_type> statement
%type <inh_next_list_type> statement_list
%type <inh_next_list_type> no_else_if
%type <inh_next_list_type> if_else
%type <inh_next_list_type> while
%type <inh_next_list_type> for

%type <ival> init_label
%type <ival> goto

%union{
	int ival;
	float fval;
	int bval;
	char * idval;
	char * opval;
	
	int synType;
	
	struct {      // synthesized attribute
		int synType;
	} expr_type;
	
	struct {      // inherited attr for labeling
		vector<int> *trueList, *falseList;
	} inh_bool_list_type;
	
	struct {
		vector<int> *nextList;
	} inh_next_list_type;
	
}

%code requires {
	#include <vector>
	using namespace std;
}

%% 
method_body: 
	{generateHeader();}
	statement_list
	init_label
	{
		backpatch($2.nextList, $3);
		generateFooter();
	}
	;
statement_list: 
	statement 
	| 
	statement
	init_label
	statement_list 
	{
		backpatch($1.nextList,$2);
		$$.nextList = $3.nextList;
	}
	;
statement: 
	declaration {$$.nextList = new vector<int>();}
	| if_else {$$.nextList = $1.nextList;}
	| while {$$.nextList = $1.nextList;}
	| for {$$.nextList = $1.nextList;}
	| assignment {$$.nextList = new vector<int>();}
	| full_declaration {$$.nextList = new vector<int>();}
	;
primitive_type: 
	INT_DECL {$$ = INT_TYPE;}
	| FLOAT_DECL {$$ = FLOAT_TYPE;}
	| BOOL_DECL {$$ = BOOL_TYPE;}
	;
	
init_label:
{
	$$ = currentLabel;
	addLineCode(generateLabel() + ":");
}
;
goto:
{
	$$ = codeGenList.size();
	addLineCode("goto ");
}
;
no_else_if: 
	IF_STMT
	OPEN_BRACKET 
	bool_expression 
	CLOSE_BRACKET
	OPEN_CURLY_BRACKET 
	init_label
	statement_list 
	CLOSE_CURLY_BRACKET 
	{
		backpatch($3.trueList,$6);
		$$.nextList = merge($7.nextList, $3.falseList);
	}
	;

if_else: 
	IF_STMT
	OPEN_BRACKET 
	bool_expression 
	CLOSE_BRACKET
	OPEN_CURLY_BRACKET 
	init_label
	statement_list
	goto 
	CLOSE_CURLY_BRACKET 
	ELSE_STMT
	OPEN_CURLY_BRACKET 
	init_label
	statement_list 
	CLOSE_CURLY_BRACKET
	{
		backpatch($3.trueList,$6);
		backpatch($3.falseList,$12);
		$$.nextList = merge($7.nextList, $13.nextList);
		$$.nextList->push_back($8);
	}
	;
while:
	init_label 
	WHILE_STMT
	OPEN_BRACKET
	bool_expression
	CLOSE_BRACKET
	OPEN_CURLY_BRACKET 
	init_label
	statement_list
	CLOSE_CURLY_BRACKET
	{
		addLineCode("goto " + getLabel($1));
		backpatch($8.nextList,$1);
		backpatch($4.trueList,$7);
		$$.nextList = $4.falseList;
	}
	;
for:
	FOR_STMT 
	OPEN_BRACKET
	assignment
	init_label
	bool_expression
	SEMICOLON
	init_label
	for_assignment
	goto
	CLOSE_BRACKET
	OPEN_CURLY_BRACKET
	init_label
	statement_list
	goto
	CLOSE_CURLY_BRACKET
	{
		backpatch($5.trueList,$12);
		vector<int> * v = new vector<int> ();
		v->push_back($9);
		backpatch(v,$4);
		v = new vector<int>();
		v->push_back($14);
		backpatch(v,$7);
		backpatch($13.nextList,$7);
		$$.nextList = $5.falseList;
	}
	;
full_declaration:
	primitive_type IDENTIFIER EQU expression SEMICOLON
	{
		string str($2);
		if($1 == INT_TYPE)
		{
			defineVariable(str, INT_TYPE);
		}
		else if ($1 == FLOAT_TYPE)
		{
			defineVariable(str, FLOAT_TYPE);
		}
		
		if($4.synType == symbolTable[str].second)
		{
			if($4.synType == INT_TYPE)
			{
				addLineCode("istore " + to_string(symbolTable[str].first));
			}
			else if ($4.synType == FLOAT_TYPE)
			{
				addLineCode("fstore " + to_string(symbolTable[str].first));
			}
		}
		else
		{
			yyerror("Error casting is needed");
		}
		
	}
	;
declaration: 
	primitive_type IDENTIFIER SEMICOLON 
	{
		string str($2);
		if($1 == INT_TYPE)
		{
			defineVariable(str, INT_TYPE);
		}
		else if ($1 == FLOAT_TYPE)
		{
			defineVariable(str, FLOAT_TYPE);
		}
		
	}
	;
assignment: 
	IDENTIFIER EQU expression SEMICOLON
	{
		string str($1);
		/* After expression finishes, its result should be on top of stack. 
		   Store the top of stack to the identifier
		 */
		if(findInSymbolTab(str))
		{
			if($3.synType == symbolTable[str].second)
			{
				if($3.synType == INT_TYPE)
				{
					addLineCode("istore " + to_string(symbolTable[str].first));
				}
				else if ($3.synType == FLOAT_TYPE)
				{
					addLineCode("fstore " + to_string(symbolTable[str].first));
				}
			}
			else
			{
				yyerror("Error casting is needed");
			}
		}else{
			string err = "identifier: "+str+" isn't declared in this scope";
			yyerror(err.c_str());
		}
	}
	;
for_assignment: 
	IDENTIFIER EQU expression 
	{
		string str($1);
		if(findInSymbolTab(str))
		{
			if($3.synType == symbolTable[str].second)
			{
				if($3.synType == INT_TYPE)
				{
					addLineCode("istore " + to_string(symbolTable[str].first));
				}
				else if ($3.synType == FLOAT_TYPE)
				{
					addLineCode("fstore " + to_string(symbolTable[str].first));
				}
			}
			else
			{
				yyerror("Error casting is needed");
			}
		}else{
			string err = "identifier: "+str+" isn't declared in this scope";
			yyerror(err.c_str());
		}
	}
	;
expression: 
	FLOAT 	{$$.synType = FLOAT_TYPE; addLineCode("ldc "+to_string($1));}
	| INT 	{$$.synType = INT_TYPE;  addLineCode("ldc "+to_string($1));} 
	| expression ARITH_OP expression	{checkType($1.synType, $3.synType, string($2));}
	| IDENTIFIER {
		string str($1);
		if(findInSymbolTab(str))
		{
			$$.synType = symbolTable[str].second;
			if(symbolTable[str].second == INT_TYPE)
			{
				addLineCode("iload " + to_string(symbolTable[str].first));
			}else if (symbolTable[str].second == FLOAT_TYPE)
			{
				addLineCode("fload " + to_string(symbolTable[str].first));
			}
		}
		else
		{
			string err = "identifier: " + str + " isn't declared in this scope";
			yyerror(err.c_str());
			$$.synType = ERROR_TYPE;
		}
	}
	| OPEN_BRACKET expression CLOSE_BRACKET {$$.synType = $2.synType;}
	;
bool_expression:
	BOOL
	{
		if($1)
		{
			$$.trueList = new vector<int> ();
			$$.trueList->push_back(codeGenList.size());
			$$.falseList = new vector<int>();
			addLineCode("goto ");
		}else
		{
			$$.trueList = new vector<int> ();
			$$.falseList= new vector<int>();
			$$.falseList->push_back(codeGenList.size());
			addLineCode("goto ");
		}
	}
	|bool_expression
	BOOL_OP 
	init_label
	bool_expression
	{
		if(strcmp($2, "&&"))
		{
			backpatch($1.trueList, $3);
			$$.trueList = $4.trueList;
			$$.falseList = merge($1.falseList,$4.falseList);
		}
		else if (strcmp($2,"||"))
		{
			backpatch($1.falseList,$3);
			$$.trueList = merge($1.trueList, $4.trueList);
			$$.falseList = $4.falseList;
		}
	}
	| expression REL_OP expression
	{
		string op ($2);
		$$.trueList = new vector<int>();
		$$.trueList ->push_back (codeGenList.size());
		$$.falseList = new vector<int>();
		$$.falseList->push_back(codeGenList.size()+1);
		addLineCode(getOperationName(op)+ " ");
		addLineCode("goto ");
	}
	;
%%
main (int argv, char * argc[])
{
	FILE *myfile;
	myfile = fopen("code.txt", "r");
	classFileName = "code.txt";
	yyin = myfile;
	yyparse();
	printCode();
}

void yyerror(const char * s)
{
	printf("error@%d: %s\n",currentLine, s);
}

void generateHeader()
{
	addLineCode(".source " + classFileName);
	addLineCode(".class public test\n.super java/lang/Object\n"); //code for defining class
	addLineCode(".method public <init>()V");
	addLineCode("aload_0");
	addLineCode("invokenonvirtual java/lang/Object/<init>()V");
	addLineCode("return");
	addLineCode(".end method\n");
	addLineCode(".method public static main([Ljava/lang/String;)V");
	addLineCode(".limit locals 100\n.limit stack 100");

	/*Add line just to debug*/
	addLineCode(".line 1");
}
void generateFooter()
{
	addLineCode("return");
	addLineCode(".end method");
}

void checkType(int from, int to, string op)
{
	if(from == to)
	{
		if(from == INT_TYPE)
		{
			addLineCode("i" + getOperationName(op));
		}
		else if (from == FLOAT_TYPE)
		{
			addLineCode("f" + getOperationName(op));
		}
	}
	else
	{
		yyerror("casting is needed");
	}
}
string getOperationName(string op)
{
	if(instructions.find(op) != instructions.end())
	{
		return instructions[op];
	}
	return "";
}


string generateLabel()
{
	return "L_"+to_string(currentLabel++);
}
string getLabel(int n)
{
	return "L_"+to_string(n);
}

void backpatch(vector<int> *lists, int ind)
{
	if(!lists) return;
	
	for(int i = 0; i < lists->size(); i++)
	{
		codeGenList[(*lists)[i]] = codeGenList[(*lists)[i]] + getLabel(ind);
	}
}

void addLineCode(string x)
{
	codeGenList.push_back(x);
}

void printCode(void)
{
	for ( int i = 0 ; i < codeGenList.size() ; i++)
	{
		fileOut<<codeGenList[i]<<endl;
	}
}

bool findInSymbolTab(string ident)
{
	return (symbolTable.find(ident) != symbolTable.end());
}

void defineVariable(string name, int type)
{
	if(findInSymbolTab(name))
	{
		string err = "variable: " + name + " declared before";
		yyerror(err.c_str());
	}
	else
	{
		if(type == INT_TYPE)
		{
			addLineCode("iconst_0\nistore " + to_string(varaiblesNum));
		}
		else if ( type == FLOAT_TYPE)
		{
			addLineCode("fconst_0\nfstore " + to_string(varaiblesNum));
		}
		symbolTable[name] = make_pair(varaiblesNum++,(type_enum)type);
	}
}

vector<int> * merge(vector<int> *list1, vector<int> *list2)
{
	if(list1 && list2){
		vector<int> *list = new vector<int> (*list1);
		list->insert(list->end(), list2->begin(),list2->end());
		return list;
	}else if(list1)
	{
		return list1;
	}else if (list2)
	{
		return list2;
	}else
	{
		return new vector<int>();
	}
}