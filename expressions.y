%{
#include <stdio.h>
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
%left NEGATION
%right CARAT_TOK    /* exponentiation        */

%%

expression
    : arithmetic_expression
    | boolean_expression
    | bitwise_expression
    ;

compound_symbol
    : SYMBOL_TOK
    | compound_symbol DOT_TOK SYMBOL_TOK
    ;

exponent_numeric_value
    : FLOATING_TOK
    | INTEGER_TOK
    ;

arithmetic_factor
    : INTEGER_TOK
    | FLOAT_TOK
    | UNSIGNED_TOK
    | exponent_numeric_value CARAT_TOK exponent_numeric_value
    | compound_symbol
    ;

arithmetic_expression
    : arithmetic_factor
    | arithmetic_expression PLUS_TOK arithmetic_expression
    | arithmetic_expression MINUS_TOK arithmetic_expression
    | arithmetic_expression MULT_TOK arithmetic_expression
    | arithmetic_expression DIV_TOK arithmetic_expression
    | MINUS_TOK arithmetic_expression %prec NEGATION
    | OPAREN_TOK arithmetic_expression CPAREN_TOK
    ;

boolean_factor
    : arithmetic_factor
    | TRUE_TOK
    | FALSE_TOK
    | STRING_TOK
    ;

boolean_expression
    : boolean_factor
    | boolean_expression OR_TOK boolean_expression
    | boolean_expression AND_TOK boolean_expression 
    | boolean_expression EQ_TOK boolean_expression 
    | boolean_expression NEQ_TOK boolean_expression 
    | boolean_expression LEQ_TOK boolean_expression 
    | boolean_expression GEQ_TOK boolean_expression 
    | boolean_expression MORE_TOK boolean_expression 
    | boolean_expression LESS_TOK boolean_expression 
    | NOT_TOK boolean_expression 
    | OPAREN_TOK boolean_expression CPAREN_TOK
    ;

bitwise_factor
    : INTEGER_TOK
    | UNSIGNED_TOK
    | compound_symbol
    ;

bitwise_expression
    : bitwise_factor
    | bitwise_expression BIT_AND_TOK bitwise_expression
    | bitwise_expression BIT_OR_TOK bitwise_expression
    | bitwise_expression BIT_XOR_TOK bitwise_expression
    | bitwise_expression BIT_LSH_TOK bitwise_expression
    | bitwise_expression BIT_RSH_TOK bitwise_expression
    | BIT_NOT_TOK bitwise_expression
    | OPAREN_TOK bitwise_expression CPAREN_TOK 
    ; 
%% 