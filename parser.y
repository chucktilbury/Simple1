%{
#include <stdio.h>
#include <string.h>

#include "scanner.h"

#define TOKSTR get_tok_str()

void yyerror(const char *str)
{
  //va_list ap;
  //va_start(ap, s);
  /*
  if(yylloc.first_line)
    fprintf(stderr, "%d.%d-%d.%d: error: ", yylloc.first_line, yylloc.first_column,
        yylloc.last_line, yylloc.last_column);
  */
  fprintf(stderr, "error: %s: %d: near \"%s\"\n", get_file_name(), get_line_number(), TOKSTR);
  //vfprintf(stderr, s, ap);
  //fprintf(stderr, "\n");
  // printf("%s\n", TOKSTR);
  num_errors++;
}
 
int yywrap()
{
        return 1;
} 

int main()
{
    open_file("test1.txt");
    yyparse();
    return 0;
} 

%}

%token OPAREN_TOK CPAREN_TOK OCURLY_TOK CCURLY_TOK OBOX_TOK CBOX_TOK
%token COMMA_TOK SCOLON_TOK DOT_TOK COLON_TOK 
%token CLASS_TOK FUNC_TOK PRIVATE_TOK PUBLIC_TOK PROTECTED_TOK
%token CREATE_TOK DESTROY_TOK IMPORT_TOK STRUCT_TOK

%token PLUS_TOK MINUS_TOK MULT_TOK DIV_TOK MODULO_TOK ASSIGN_TOK 

%token BIT_NOT_TOK BIT_OR_TOK BIT_AND_TOK BIT_XOR_TOK BIT_LSH_TOK BIT_RSH_TOK

%token INT_TOK FLOAT_TOK UNSD_TOK STRG_TOK
%token BOOL_TOK 

%token RETURN_TOK BREAK_TOK CONT_TOK IF_TOK ELSE_TOK WHILE_TOK
%token FOR_TOK SWITCH_TOK CASE_TOK 

%token OR_TOK AND_TOK NOT_TOK EQ_TOK GEQ_TOK LEQ_TOK
%token NEQ_TOK MORE_TOK LESS_TOK 

%token TRUE_TOK FALSE_TOK NOTHING_TOK

%token SYMBOL_TOK UNSIGNED_TOK INTEGER_TOK FLOATING_TOK STRING_TOK

%left MINUS_TOK PLUS_TOK
%left MULT_TOK DIV_TOK
%right CARAT_TOK    /* exponentiation        */

%%

module
    : module_element
    | module module_element
    ;

module_element
    : import_statement
    | class_definition
    ;

import_statement
    : IMPORT_TOK { printf("import statement\n"); } COLON_TOK 
            SYMBOL_TOK {printf("name to import = %s\n", yytext);} SCOLON_TOK
    ;

class_definition
    : CLASS_TOK {printf("begin class definition\n");} COLON_TOK 
            SYMBOL_TOK {printf("class name = %s\n", yytext);} 
            OPAREN_TOK {printf("begin class parameter list\n");} class_parameter_list 
            CPAREN_TOK {printf("end class parameter list\n");} 
            class_body {printf("end class definition\n");}
    ;

class_parameter_list
    : /* could be blank */
    | SYMBOL_TOK {printf("class parameter name = %s\n", yytext);}
    | class_parameter_list COMMA_TOK 
            SYMBOL_TOK {printf("class parameter name = %s\n", yytext);}
    ;

class_body
    : OCURLY_TOK {printf("begin class body definition\n");}
            class_body_element_list 
            CCURLY_TOK {printf("end class body definition\n");}
    ;

class_body_element_list
    : class_body_element
    | class_body_element_list class_body_element
    ;

class_body_element
    : struct_defintion
    | function_definition
    | initialized_variable_definition
    ;

variable_definition
    : intrinsic_type_specification COLON_TOK 
            SYMBOL_TOK {printf("var name = %s\n", yytext);}
    | SYMBOL_TOK {printf("user defined type = %s\n", yytext);} COLON_TOK 
            SYMBOL_TOK {printf("var name = %s\n", yytext);}
    ;

initialized_variable_definition
    : variable_definition ASSIGN_TOK arithmetic_expression SCOLON_TOK
    ;

uninitialized_variable_definition
    : variable_definition SCOLON_TOK
    ;

intrinsic_type_specification
    : INT_TOK {printf("type of INT\n");}
    | UNSD_TOK {printf("type of UNSIGNED\n");}
    | FLOAT_TOK {printf("type of FLOAT\n");}
    | STRG_TOK {printf("type of STRG\n");}
    | BOOL_TOK {printf("type of BOOL\n");}
    ;

struct_body
    : uninitialized_variable_definition
    | struct_body uninitialized_variable_definition
    ;

struct_defintion
    : STRUCT_TOK {printf("begin struct definition\n");} 
            COLON_TOK SYMBOL_TOK {printf("struct name = %s\n", yytext);} 
            OCURLY_TOK {printf("begin struct body definition\n");} 
            struct_body CCURLY_TOK {printf("end struct body definition\n");} 
            SCOLON_TOK
    ;

function_definition_intro
    : FUNC_TOK {printf("begin function definition\n");} COLON_TOK 
    ;

normal_function_definition
    : function_definition_intro { printf("begin normal function definition\n"); }
            SYMBOL_TOK {printf("function name = %s\nbegin function input parameter definition\n", yytext);} 
            function_definition_parameters {printf("end function input parameter definition\nbegin function output parameter definition\n");} 
            function_definition_parameters {printf("end function output parameter definition\n");} 
            function_body {printf("end function definition\n");} 
    ;

create_function_definition    
    : function_definition_intro { printf("begin create function definition\n"); }
            CREATE_TOK { printf("begin create function definition\n"); }
            function_definition_parameters { printf("end create function parameters\n"); }
            function_body { printf("end create function definition\n"); }
    ;

destroy_function_parameters
    : OPAREN_TOK function_parameter_list { printf("destroy function parameters must be blank\n"); }
            CPAREN_TOK
    ;

destroy_function_definition    
    : function_definition_intro { printf("begin destroy function definition\n"); }
            DESTROY_TOK { printf("begin destroy function definition\n"); }
            destroy_function_parameters { printf("end destroy function parameters\n"); }
            function_body { printf("end destroy function definition\n"); }
    ;

function_definition
    : normal_function_definition
    | create_function_definition
    | destroy_function_definition
    ;

function_definition_parameters
    : OPAREN_TOK function_parameter_list CPAREN_TOK
    ;

function_parameter_list
    : /* could be blank */
    | variable_definition
    | function_parameter_list COMMA_TOK variable_definition
    ;

function_body
    : OCURLY_TOK CCURLY_TOK /* can be blank */
    | OCURLY_TOK {printf("begin function body definition\n");} function_statement_list 
            CCURLY_TOK {printf("end function body definition\n");}
    ;

function_statement
    : initialized_variable_definition { printf("initialized_variable_definition\n"); }
    | var_assignment { printf("var_assignment\n"); }
    | if_clause { printf("if_clause\n"); }
    | while_clause { printf("while_clause\n"); }
    | for_clause { printf("for_clause\n"); }
    | switch_clause { printf("switch_clause\n"); }
    | return_clause { printf("return_clause\n"); }
    | function_call  { printf("function_call\n"); }
    ;

function_statement_list
    : function_statement
    | function_statement_list function_statement
    ;

compound_symbol
    : SYMBOL_TOK { printf("compound symbol call\n"); }
    | compound_symbol DOT_TOK SYMBOL_TOK { printf("building compound symbol\n"); }
    ;

return_clause
    : RETURN_TOK SCOLON_TOK { printf("return statement\n"); }
    ;

switch_clause  
    : SWITCH_TOK
    ;

possibly_blank_testing_expression
    : /* yep */
    | boolean_expression
    ;

else_clause
    : ELSE_TOK OPAREN_TOK possibly_blank_testing_expression CPAREN_TOK function_body {printf("else with a test\n");} 
    ;

else_clause_list
    : /* can have zero or more */
    | else_clause
    | else_clause_list else_clause
    ;

if_clause
    : IF_TOK OPAREN_TOK boolean_expression CPAREN_TOK function_body else_clause_list
    ;

looping_function_body
    : function_body
    | BREAK_TOK SCOLON_TOK
    | CONT_TOK SCOLON_TOK
    ;

while_clause
    : WHILE_TOK OPAREN_TOK possibly_blank_testing_expression CPAREN_TOK looping_function_body
    ;

for_clause
    : FOR_TOK;

function_call
    : compound_symbol;

var_assignment
    : compound_symbol ASSIGN_TOK
            boolean_expression { printf("after boolean expression for assignment source\n"); }
            SCOLON_TOK { printf("after assignment from boolean expression\n"); }
    | compound_symbol ASSIGN_TOK
            arithmetic_expression { printf("after boolean expression for assignment source\n"); }
            SCOLON_TOK { printf("after assignment from boolean expression\n"); }
    | compound_symbol ASSIGN_TOK
            bitwise_expression { printf("after boolean expression for assignment source\n"); }
            SCOLON_TOK { printf("after assignment from boolean expression\n"); }
    ;

exponent_numeric_value
    : FLOATING_TOK { printf("floating numeric_literal for exponent = %s\n", yytext); }
    | INTEGER_TOK { printf("integer numeric_literal for exponent = %s\n", yytext); }
    ;

arithmetic_factor
    : INTEGER_TOK { printf("integer numeric_literal = %s\n", yytext); }
    | FLOAT_TOK { printf("float numberic_literal = %s\n", yytext); }
    | UNSIGNED_TOK { printf("unsigned numberic_literal = %s\n", yytext); }
    | exponent_numeric_value { printf("base number\n"); } CARAT_TOK exponent_numeric_value { printf("exponent\n"); }
    | compound_symbol
    ;

arithmetic_expression
    : arithmetic_factor
    | arithmetic_expression PLUS_TOK arithmetic_expression { printf("arithmetic_expression addition\n"); }
    | arithmetic_expression MINUS_TOK arithmetic_expression { printf("arithmetic_expression subtraction\n"); }
    | arithmetic_expression MULT_TOK arithmetic_expression { printf("arithmetic_expression multiplication\n"); }
    | arithmetic_expression DIV_TOK arithmetic_expression { printf("arithmetic_expression division\n"); }
    | OPAREN_TOK arithmetic_expression CPAREN_TOK { printf("arithmetic_expression grouping\n"); }
    ;

boolean_factor
    : arithmetic_factor
    | TRUE_TOK {printf("TRUE literal = %s\n", yytext);}
    | FALSE_TOK {printf("FALSE literal = %s\n", yytext);}
    | STRING_TOK {printf("STRING literal = %s\n", get_tok_str());}
    ;

boolean_expression
    : boolean_factor
    | NOT_TOK boolean_expression 
    | boolean_expression OR_TOK boolean_expression
    | boolean_expression AND_TOK boolean_expression 
    | boolean_expression EQ_TOK boolean_expression 
    | boolean_expression NEQ_TOK boolean_expression 
    | boolean_expression LEQ_TOK boolean_expression 
    | boolean_expression GEQ_TOK boolean_expression 
    | boolean_expression MORE_TOK boolean_expression 
    | boolean_expression LESS_TOK boolean_expression 
    | OPAREN_TOK boolean_expression CPAREN_TOK
    ;

bitwise_factor
    : INTEGER_TOK { printf("integer numeric_literal = %s\n", yytext); }
    | UNSIGNED_TOK { printf("unsigned numberic_literal = %s\n", yytext); }
    | compound_symbol
    ;

bitwise_expression
    : bitwise_factor
    | BIT_NOT_TOK bitwise_expression
    | bitwise_expression BIT_AND_TOK bitwise_expression
    | bitwise_expression BIT_OR_TOK bitwise_expression
    | bitwise_expression BIT_XOR_TOK bitwise_expression
    | bitwise_expression BIT_LSH_TOK bitwise_expression
    | bitwise_expression BIT_RSH_TOK bitwise_expression
    | OPAREN_TOK bitwise_expression CPAREN_TOK 
    ; 
%% 