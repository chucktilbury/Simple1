%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

#include "errors.h"
#include "parser.h"

// string buffer to get token from
static char strbuf[1024*64];

typedef struct _file_name_stack {
    int line_no;
    char *name;
    struct _file_name_stack *next;
} _file_name_stack;


static char buffer[1024*64];
static int bidx = 0;
static _file_name_stack *name_stack;
int num_errors = 0; // global updated by parser

// these funcs support the string scanner
static void append_char(char ch) {
    if((sizeof(buffer)-1) > bidx) {
        buffer[bidx] = ch;
        bidx++;
    }
    else {
        scanner_error("buffer overrun");
    }
}

static void append_str(char *str) {
    if((sizeof(buffer)-1) > (strlen(buffer) + strlen(str))) {
        strcat(buffer, str);
        bidx = strlen(buffer);
    }
    else {
        scanner_error("buffer overrun");
    }
}

%}

    /* state definitions */
%x SQUOTES
%x DQUOTES
%x COMMENT
%option noinput nounput

%%
\n          {name_stack->line_no ++; yylineno++; }
[ \t\r]     {}

"("         { return OPAREN_TOK; }
")"         { return CPAREN_TOK; }
"{"         { return OCURLY_TOK; }
"}"         { return CCURLY_TOK; }
"["         { return OBOX_TOK; }
"]"         { return CBOX_TOK; }
","         { return COMMA_TOK; }
";"         { return SCOLON_TOK; }
"."         { return DOT_TOK; }
":"         { return COLON_TOK; }

"+"         { return PLUS_TOK; }
"-"         { return MINUS_TOK; }
"*"         { return MULT_TOK; }
"/"         { return DIV_TOK; }
"%"         { return MODULO_TOK; }
"="         { return ASSIGN_TOK; }

"~"         { return BIT_NOT_TOK; }
"|"         { return BIT_OR_TOK; }
"&"         { return BIT_AND_TOK; }
"^"         { return BIT_XOR_TOK; }
"<"         { return BIT_LSH_TOK; }
">"         { return BIT_RSH_TOK; }

"nothing"   { return NOTHING_TOK; }
"nill"      { return NOTHING_TOK; }
"import"    { return IMPORT_TOK; }
"struct"    { return STRUCT_TOK; }
"private"   { return PRIVATE_TOK; }
"public"    { return PUBLIC_TOK; }
"protected" { return PROTECTED_TOK; }
"create"    { return CREATE_TOK; }
"destroy"   { return DESTROY_TOK; }
"int"       { return INT_TOK; }
"integer"   { return INT_TOK; }
"float"     { return FLOAT_TOK; }
"unsigned"  { return UNSD_TOK; }
"strg"      { return STRG_TOK; }
"string"    { return STRG_TOK; }
"bool"      { return BOOL_TOK; }
"boolean"   { return BOOL_TOK; }
"return"    { return RETURN_TOK; }
"break"     { return BREAK_TOK; }
"continue"  { return CONT_TOK; }
"if"        { return IF_TOK; }
"else"      { return ELSE_TOK; }
"while"     { return WHILE_TOK; }
"for"       { return FOR_TOK; }
"switch"    { return SWITCH_TOK; }
"case"      { return CASE_TOK; }

"||"        { return OR_TOK; }
"&&"        { return AND_TOK; }
"!"         { return NOT_TOK; }
"=="        { return EQ_TOK; }
">="        { return GEQ_TOK; }
"<="        { return LEQ_TOK; }
"!="        { return NEQ_TOK; }
">>"        { return MORE_TOK; }
"<<"        { return LESS_TOK; }

"YES"       { return TRUE_TOK; }
"TRUE"      { return TRUE_TOK; }
"NO"        { return FALSE_TOK; }
"FALSE"     { return FALSE_TOK; }

"class"     { return CLASS_TOK; }
"func"      { return FUNC_TOK; }

[_$A-Za-z]+[_$A-Za-z0-9]*   { return SYMBOL_TOK; }
    /* \.[_$A-Za-z]+[_$A-Za-z0-9]* { return COMPOUND_TOK; } */
0[xX][0-9a-fA-F]{1,32}      { return UNSIGNED_TOK; }
[+-]?[0-9]+                 { return INTEGER_TOK; }
[-+]?[0-9]+\.[0-9]+         { return FLOATING_TOK; }

    /* double quoted strings have escapes managed */
\"  {
        bidx = 0;
        memset(buffer, 0, sizeof(buffer));
        BEGIN(DQUOTES);
    }

<DQUOTES>\" {
        strncpy(strbuf, buffer, sizeof(strbuf));
        BEGIN(INITIAL);
        return STRING_TOK;
    }

    /* problem is that the short rule matches before the long one does */
<DQUOTES>\\n    { append_char('\n'); }
<DQUOTES>\\r    { append_char('\r'); }
<DQUOTES>\\t    { append_char('\t'); }
<DQUOTES>\\b    { append_char('\b'); }
<DQUOTES>\\f    { append_char('\f'); }
<DQUOTES>\\v    { append_char('\v'); }
<DQUOTES>\\\\   { append_char('\\'); }
<DQUOTES>\\\"   { append_char('\"'); }
<DQUOTES>\\\'   { append_char('\''); }
<DQUOTES>\\\?   { append_char('\?'); }
<DQUOTES>\\.    { append_char(yytext[1]); }
<DQUOTES>\\[0-7]{1,3} { append_char((char)strtol(yytext+1, 0, 8));  }
<DQUOTES>\\[xX][0-9a-fA-F]{1,3} { append_char((char)strtol(yytext+2, 0, 16));  }
<DQUOTES>[^\\\"\n]*  { append_str(yytext); }

    /* single quoted strings are absolute literals */
\'  {
        bidx = 0;
        memset(buffer, 0, sizeof(buffer));
        BEGIN(SQUOTES);
    }

    /*<SQUOTES>\'[ \t]*\\[ \t]*\n { name_stack->line_no ++; } */
<SQUOTES>[^\\'\n]*  { append_str(yytext); }
<SQUOTES>\\.    { append_str(yytext); }
<SQUOTES>\' {
        strncpy(strbuf, buffer, sizeof(strbuf));
        BEGIN(INITIAL);
        return STRING_TOK;
    }

"#" { BEGIN(COMMENT); }
<COMMENT>"#" { BEGIN(INITIAL); }
<COMMENT>\n { name_stack->line_no++; yylineno++; }
<COMMENT>.  {}  /* eat everything in between */

<<EOF>> {

        debug(0, "closing file \"%s\"", name_stack->name);
        fprintf(stderr, "There were %d errors found.\n", num_errors);
        _file_name_stack *name = name_stack->next;
        free(name_stack->name);
        free(name_stack);
        name_stack = name;

        memset(strbuf, 0, sizeof(strbuf));
        yypop_buffer_state();
        if(!YY_CURRENT_BUFFER) {
            yyterminate();
        }

        //return EOF_TOK;
    }


%%

void open_file(char *fname) {

    _file_name_stack *name;

    debug(0, "opening file: \"%s\"", fname);
    if(NULL == (name = calloc(1, sizeof(_file_name_stack))))
        scanner_error("cannot allocate memory for file stack");

    if(NULL == (name->name = strdup(fname)))
        scanner_error("cannot allocate memory for file stack name");

    name->next = name_stack;
    name->line_no = 1;
    name_stack = name;

    yyin = fopen(fname, "r");
    if(NULL == yyin) {
        scanner_error("cannot open the input file: \"%s\": %s", fname, strerror(errno));
        exit(1);
    }

    yypush_buffer_state(yy_create_buffer(yyin, YY_BUF_SIZE));
}

// Tracking and global interface
char *get_file_name(void) {
    if(NULL != name_stack)
        return name_stack->name;
    else
        return "no name";
}

int get_line_number(void) {
    if(NULL != name_stack)
        return name_stack->line_no;
    else
        return -1;
}

const char *get_tok_str(void) {
    return strbuf;
}

int get_token(void) {

    int retv = yylex();
    if(0 == retv)
        memset(strbuf, 0, sizeof(strbuf));

    return retv;
}
