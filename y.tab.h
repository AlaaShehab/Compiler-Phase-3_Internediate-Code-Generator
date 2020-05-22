
/* A Bison parser, made by GNU Bison 2.4.1.  */

/* Skeleton interface for Bison's Yacc-like parsers in C
   
      Copyright (C) 1984, 1989, 1990, 2000, 2001, 2002, 2003, 2004, 2005, 2006
   Free Software Foundation, Inc.
   
   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.
   
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   
   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.
   
   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* "%code requires" blocks.  */

/* Line 1676 of yacc.c  */
#line 127 "syntax.y"

	#include <vector>
	using namespace std;



/* Line 1676 of yacc.c  */
#line 47 "syntax.tab.h"

/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     INT = 258,
     FLOAT = 259,
     BOOL = 260,
     IDENTIFIER = 261,
     ARITH_OP = 262,
     REL_OP = 263,
     BOOL_OP = 264,
     IF_STMT = 265,
     ELSE_STMT = 266,
     WHILE_STMT = 267,
     FOR_STMT = 268,
     INT_DECL = 269,
     FLOAT_DECL = 270,
     BOOL_DECL = 271,
     SEMICOLON = 272,
     EQU = 273,
     OPEN_BRACKET = 274,
     CLOSE_BRACKET = 275,
     OPEN_CURLY_BRACKET = 276,
     CLOSE_CURLY_BRACKET = 277
   };
#endif



#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE
{

/* Line 1676 of yacc.c  */
#line 104 "syntax.y"

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
	



/* Line 1676 of yacc.c  */
#line 111 "syntax.tab.h"
} YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
#endif

extern YYSTYPE yylval;


