#ifndef _SCANNER_H_
#define _SCANNER_H_

#include <stdio.h> 

char *get_file_name(void);
int get_line_number(void);
void open_file(char *fname);
const char *get_tok_str(void);
int get_token(void);

/*
 * Defined by flex. Call one time to isolate a symbol and then use the global
 * symbol struct to access the symbol.
 */
extern int yylex(void);
extern int yyparse(void);
extern FILE* yyin;
//void yyerror(char *s, ...);
//void yyerror(char *s);
extern int num_errors; // global updated by parser
extern const char* yytext;

#endif /* _SCANNER_H_ */
