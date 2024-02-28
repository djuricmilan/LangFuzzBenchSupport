grammar Ruby;

options {
  contextSuperClass = PolyGlotRuleContext;
}

@parser::header {
#include "polyglot_rule_context.h"
}

program
    : expression_list EOF
    ;

expression_list
    : expression terminator
    | expression_list expression terminator
    | terminator
    ;

expression
    : function_definition
    | function_inline_call
    | require_block
    | if_statement
    | unless_statement
    | rvalue
    | return_statement
    | while_statement
    | for_statement
    ;

global_get
    : lvalue ASSIGN id_global
    ;

global_set
    : id_global ASSIGN all_result
    ;

global_result
    : id_global
    ;

function_inline_call
    : function_call
    ;

require_block
    : REQUIRE literal_t
    ;

function_definition
    : function_definition_header function_definition_body END
    ;

function_definition_body
    : expression_list
    ;

function_definition_header
    : DEF function_name crlf
    | DEF function_name function_definition_params crlf
    ;

function_name
    : id_function
    | id_
    ;

function_definition_params
    : LEFT_RBRACKET RIGHT_RBRACKET
    | LEFT_RBRACKET function_definition_params_list RIGHT_RBRACKET
    | function_definition_params_list
    ;

function_definition_params_list
    : function_definition_param_id
    | function_definition_params_list COMMA function_definition_param_id
    ;

function_definition_param_id
    : id_
    ;

return_statement
    : RETURN all_result
    ;

function_call
    : function_name LEFT_RBRACKET function_call_param_list RIGHT_RBRACKET
    | function_name function_call_param_list
    | function_name LEFT_RBRACKET RIGHT_RBRACKET
    ;

function_call_param_list
    : function_call_params
    ;

function_call_params
    : function_param
    | function_call_params COMMA function_param
    ;

function_param
    : (function_unnamed_param | function_named_param)
    ;

function_unnamed_param
    : (int_result | float_result | string_result | dynamic_result)
    ;

function_named_param
    : id_ ASSIGN (int_result | float_result | string_result | dynamic_result)
    ;

function_call_assignment
    : function_call
    ;

all_result
    : (int_result | float_result | string_result | dynamic_result | global_result)
    ;

elsif_statement
    : if_elsif_statement
    ;

if_elsif_statement
    : ELSIF cond_expression crlf statement_body
    | ELSIF cond_expression crlf statement_body else_token crlf statement_body
    | ELSIF cond_expression crlf statement_body if_elsif_statement
    ;

if_statement
    : IF cond_expression crlf statement_body END
    | IF cond_expression crlf statement_body else_token crlf statement_body END
    | IF cond_expression crlf statement_body elsif_statement END
    ;

unless_statement
    : UNLESS cond_expression crlf statement_body END
    | UNLESS cond_expression crlf statement_body else_token crlf statement_body END
    | UNLESS cond_expression crlf statement_body elsif_statement END
    ;

while_statement
    : WHILE cond_expression crlf statement_body END
    ;

for_statement
    : FOR lvalue IN RANGE crlf statement_body END
    ;

cond_expression
    : comparison_list
    ;

statement_body
    : statement_expression_list
    ;

statement_expression_list
    : expression terminator
    | RETRY terminator
    | break_expression terminator
    | statement_expression_list expression terminator
    | statement_expression_list RETRY terminator
    | statement_expression_list break_expression terminator
    ;

assignment
    : lvalue ASSIGN rvalue
    | lvalue (
        PLUS_ASSIGN
        | MINUS_ASSIGN
        | MUL_ASSIGN
        | DIV_ASSIGN
        | MOD_ASSIGN
        | EXP_ASSIGN
    ) rvalue
    ;

dynamic_assignment
    : lvalue ASSIGN dynamic_result
    | lvalue (
        PLUS_ASSIGN
        | MINUS_ASSIGN
        | MUL_ASSIGN
        | DIV_ASSIGN
        | MOD_ASSIGN
        | EXP_ASSIGN
    ) dynamic_result
    ;

int_assignment
    :  lvalue ASSIGN int_result
    |  lvalue (
        PLUS_ASSIGN
        | MINUS_ASSIGN
        | MUL_ASSIGN
        | DIV_ASSIGN
        | MOD_ASSIGN
        | EXP_ASSIGN
    ) int_result
    ;

float_assignment
    : lvalue ASSIGN float_result
    | lvalue (
        PLUS_ASSIGN
        | MINUS_ASSIGN
        | MUL_ASSIGN
        | DIV_ASSIGN
        | MOD_ASSIGN
        | EXP_ASSIGN
    ) float_result
    ;

string_assignment
    : lvalue ASSIGN string_result
    | lvalue PLUS_ASSIGN string_result
    ;

initial_array_assignment
    : lvalue ASSIGN LEFT_SBRACKET RIGHT_SBRACKET
    | lvalue ASSIGN array_definition
    ;

array_assignment
    : array_selector ASSIGN all_result
    ;

array_definition
    : LEFT_SBRACKET array_definition_elements RIGHT_SBRACKET
    ;

array_definition_elements
    : (int_result | dynamic_result)
    | array_definition_elements COMMA ( int_result | dynamic_result)
    ;

array_selector
    : id_ LEFT_SBRACKET (int_result | dynamic_result) RIGHT_SBRACKET
    | id_global LEFT_SBRACKET ( int_result | dynamic_result) RIGHT_SBRACKET
    ;

dynamic_result
    : dynamic_result (MUL | DIV | MOD) int_result
    | int_result ( MUL | DIV | MOD) dynamic_result
    | dynamic_result ( MUL | DIV | MOD) float_result
    | float_result ( MUL | DIV | MOD) dynamic_result
    | dynamic_result ( MUL | DIV | MOD) dynamic_result
    | dynamic_result MUL string_result
    | string_result MUL dynamic_result
    | dynamic_result ( PLUS | MINUS) int_result
    | int_result ( PLUS | MINUS) dynamic_result
    | dynamic_result ( PLUS | MINUS) float_result
    | float_result ( PLUS | MINUS) dynamic_result
    | dynamic_result ( PLUS | MINUS) dynamic_result
    | LEFT_RBRACKET dynamic_result RIGHT_RBRACKET
    | dynamic_
    ;

dynamic_
    : id_
    | function_call_assignment
    | array_selector
    ;

int_result
    : int_result (MUL | DIV | MOD) int_result
    | int_result ( PLUS | MINUS) int_result
    | LEFT_RBRACKET int_result RIGHT_RBRACKET
    | int_t
    ;

float_result
    : float_result (MUL | DIV | MOD) float_result
    | int_result ( MUL | DIV | MOD) float_result
    | float_result ( MUL | DIV | MOD) int_result
    | float_result ( PLUS | MINUS) float_result
    | int_result ( PLUS | MINUS) float_result
    | float_result ( PLUS | MINUS) int_result
    | LEFT_RBRACKET float_result RIGHT_RBRACKET
    | float_t
    ;

string_result
    : string_result MUL int_result
    | int_result MUL string_result
    | string_result PLUS string_result
    | literal_t
    ;

comparison_list
    : comparison BIT_AND comparison_list
    | comparison AND comparison_list
    | comparison BIT_OR comparison_list
    | comparison OR comparison_list
    | LEFT_RBRACKET comparison_list RIGHT_RBRACKET
    | comparison
    ;

comparison
    : comp_var (LESS | GREATER | LESS_EQUAL | GREATER_EQUAL) comp_var
    | comp_var ( EQUAL | NOT_EQUAL) comp_var
    ;

comp_var
    : all_result
    | array_selector
    | id_
    ;

lvalue
    : id_
    | id_global
    ;

rvalue
    : lvalue
    | initial_array_assignment
    | array_assignment
    | int_result
    | float_result
    | string_result
    | global_set
    | global_get
    | dynamic_assignment
    | string_assignment
    | float_assignment
    | int_assignment
    | assignment
    | function_call
    | literal_t
    | bool_t
    | float_t
    | int_t
    | nil_t
    | rvalue EXP rvalue
    | ( NOT | BIT_NOT) rvalue
    | rvalue ( MUL | DIV | MOD) rvalue
    | rvalue ( PLUS | MINUS) rvalue
    | rvalue ( BIT_SHL | BIT_SHR) rvalue
    | rvalue BIT_AND rvalue
    | rvalue ( BIT_OR | BIT_XOR) rvalue
    | rvalue ( LESS | GREATER | LESS_EQUAL | GREATER_EQUAL) rvalue
    | rvalue ( EQUAL | NOT_EQUAL) rvalue
    | rvalue ( OR | AND) rvalue
    | LEFT_RBRACKET rvalue RIGHT_RBRACKET
    ;

break_expression
    : BREAK
    ;

literal_t
    : LITERAL
    ;

float_t
    : FLOAT
    ;

int_t
    : INT
    ;

bool_t
    : TRUE
    | FALSE
    ;

nil_t
    : NIL
    ;

id_
    : ID
    ;

id_global
    : ID_GLOBAL
    ;

id_function
    : ID_FUNCTION
    ;

terminator
    : terminator SEMICOLON
    | terminator crlf
    | SEMICOLON
    | crlf
    ;

else_token
    : ELSE
    ;

crlf
    : CRLF
    ;

fragment ESCAPED_QUOTE
    : '\\"'
    ;

LITERAL
    : '"' (ESCAPED_QUOTE | ~('\n' | '\r'))*? '"'
    | '\'' ( ESCAPED_QUOTE | ~('\n' | '\r'))*? '\''
    ;

COMMA
    : ','
    ;

SEMICOLON
    : ';'
    ;

CRLF
    : '\r'? '\n'
    ;

REQUIRE
    : 'require'
    ;

END
    : 'end'
    ;

DEF
    : 'def'
    ;

RETURN
    : 'return'
    ;

IF
    : 'if'
    ;

ELSE
    : 'else'
    ;

ELSIF
    : 'elsif'
    ;

UNLESS
    : 'unless'
    ;

WHILE
    : 'while'
    ;

IN
    : 'in'
    ;

RETRY
    : 'retry'
    ;

BREAK
    : 'break'
    ;

FOR
    : 'for'
    ;

TRUE
    : 'true'
    ;

FALSE
    : 'false'
    ;

PLUS
    : '+'
    ;

MINUS
    : '-'
    ;

MUL
    : '*'
    ;

DIV
    : '/'
    ;

MOD
    : '%'
    ;

EXP
    : '**'
    ;

EQUAL
    : '=='
    ;

NOT_EQUAL
    : '!='
    ;

GREATER
    : '>'
    ;

LESS
    : '<'
    ;

LESS_EQUAL
    : '<='
    ;

GREATER_EQUAL
    : '>='
    ;

ASSIGN
    : '='
    ;

PLUS_ASSIGN
    : '+='
    ;

MINUS_ASSIGN
    : '-='
    ;

MUL_ASSIGN
    : '*='
    ;

DIV_ASSIGN
    : '/='
    ;

MOD_ASSIGN
    : '%='
    ;

EXP_ASSIGN
    : '**='
    ;

BIT_AND
    : '&'
    ;

BIT_OR
    : '|'
    ;

BIT_XOR
    : '^'
    ;

BIT_NOT
    : '~'
    ;

BIT_SHL
    : '<<'
    ;

BIT_SHR
    : '>>'
    ;

AND
    : 'and'
    | '&&'
    ;

OR
    : 'or'
    | '||'
    ;

NOT
    : 'not'
    | '!'
    ;

LEFT_RBRACKET
    : '('
    ;

RIGHT_RBRACKET
    : ')'
    ;

LEFT_SBRACKET
    : '['
    ;

RIGHT_SBRACKET
    : ']'
    ;

NIL
    : 'nil'
    ;

SL_COMMENT
    : ('#' ~('\r' | '\n')* '\r'? '\n') -> skip
    ;

ML_COMMENT
    : ('=begin' .*? '=end' '\r'? '\n') -> skip
    ;

WS
    : (' ' | '\t')+ -> skip
    ;

INT
    : [0-9]+
    ;

FLOAT
    : [0-9]* '.' [0-9]+
    ;

ID
    : [a-zA-Z_][a-zA-Z0-9_]*
    ;

ID_GLOBAL
    : '$' ID
    ;

ID_FUNCTION
    : ID [?]
    ;

RANGE
    : [0-9]+ '..' [0-9]+
    ;