/*
 *  yosys -- Yosys Open SYnthesis Suite
 *
 *  Copyright (C) 2012  Claire Xenia Wolf <claire@yosyshq.com>
 *
 *  Permission to use, copy, modify, and/or distribute this software for any
 *  purpose with or without fee is hereby granted, provided that the above
 *  copyright notice and this permission notice appear in all copies.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 *  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 *  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 *  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 *  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 *  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 *  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 *  ---
 *
 *  A very simple and straightforward frontend for the RTLIL text
 *  representation.
 *
 */

%{

#ifdef __clang__
// bison generates code using the 'register' storage class specifier
#pragma clang diagnostic ignored "-Wdeprecated-register"
#endif

#include <cstdlib>
#include "frontends/rtlil/rtlil_frontend.h"
#include "rtlil_parser.tab.hh"

USING_YOSYS_NAMESPACE

#define YY_INPUT(buf,result,max_size) \
	result = readsome(*RTLIL_FRONTEND::lexin, buf, max_size)

%}

%option yylineno
%option noyywrap
%option nounput
%option prefix="rtlil_frontend_yy"

%x STRING

%%

"autoidx"	{ return TOK_AUTOIDX; }
"module"	{ return TOK_MODULE; }
"attribute"	{ return TOK_ATTRIBUTE; }
"parameter"	{ return TOK_PARAMETER; }
"signed"	{ return TOK_SIGNED; }
"real"		{ return TOK_REAL; }
"wire"		{ return TOK_WIRE; }
"memory"	{ return TOK_MEMORY; }
"width"		{ return TOK_WIDTH; }
"upto"		{ return TOK_UPTO; }
"offset"	{ return TOK_OFFSET; }
"size"		{ return TOK_SIZE; }
"input"		{ return TOK_INPUT; }
"output"	{ return TOK_OUTPUT; }
"inout"		{ return TOK_INOUT; }
"cell"		{ return TOK_CELL; }
"connect"	{ return TOK_CONNECT; }
"switch"	{ return TOK_SWITCH; }
"case"		{ return TOK_CASE; }
"assign"	{ return TOK_ASSIGN; }
"sync"		{ return TOK_SYNC; }
"low"		{ return TOK_LOW; }
"high"		{ return TOK_HIGH; }
"posedge"	{ return TOK_POSEDGE; }
"negedge"	{ return TOK_NEGEDGE; }
"edge"		{ return TOK_EDGE; }
"always"	{ return TOK_ALWAYS; }
"global"	{ return TOK_GLOBAL; }
"init"		{ return TOK_INIT; }
"update"	{ return TOK_UPDATE; }
"memwr"		{ return TOK_MEMWR; }
"process"	{ return TOK_PROCESS; }
"end"		{ return TOK_END; }

[a-z]+		{ return TOK_INVALID; }

"\\"[^ \t\r\n]+		{ rtlil_frontend_yylval.string = strdup(yytext); return TOK_ID; }
"$"[^ \t\r\n]+		{ rtlil_frontend_yylval.string = strdup(yytext); return TOK_ID; }

[0-9]+'s?[01xzm-]*	{ rtlil_frontend_yylval.string = strdup(yytext); return TOK_VALUE; }
-?[0-9]+		{
	char *end = nullptr;
	errno = 0;
	long value = strtol(yytext, &end, 10);
	log_assert(end == yytext + strlen(yytext));
	if (errno == ERANGE)
		return TOK_INVALID; // literal out of range of long
	if (value < INT_MIN || value > INT_MAX)
		return TOK_INVALID; // literal out of range of int (relevant mostly for LP64 platforms)
	rtlil_frontend_yylval.integer = value;
	return TOK_INT;
}

\"		{ BEGIN(STRING); }
<STRING>\\.	{ yymore(); }
<STRING>\"	{
	BEGIN(0);
	char *yystr = strdup(yytext);
	yystr[strlen(yytext) - 1] = 0;
	int i = 0, j = 0;
	while (yystr[i]) {
		if (yystr[i] == '\\' && yystr[i + 1]) {
			i++;
			if (yystr[i] == 'n')
				yystr[i] = '\n';
			else if (yystr[i] == 't')
				yystr[i] = '\t';
			else if ('0' <= yystr[i] && yystr[i] <= '7') {
				yystr[i] = yystr[i] - '0';
				if ('0' <= yystr[i + 1] && yystr[i + 1] <= '7') {
					yystr[i + 1] = yystr[i] * 8 + yystr[i + 1] - '0';
					i++;
				}
				if ('0' <= yystr[i + 1] && yystr[i + 1] <= '7') {
					yystr[i + 1] = yystr[i] * 8 + yystr[i + 1] - '0';
					i++;
				}
			}
		}
		yystr[j++] = yystr[i++];
	}
	yystr[j] = 0;
	rtlil_frontend_yylval.string = yystr;
	return TOK_STRING;
}
<STRING>.	{ yymore(); }

"#"[^\n]*	/* ignore comments */
[ \t]		/* ignore non-newline whitespaces */
[\r\n]+		{ return TOK_EOL; }

.               { return *yytext; }

%%

// this is a hack to avoid the 'yyinput defined but not used' error msgs
void *rtlil_frontend_avoid_input_warnings() {
	return (void*)&yyinput;
}
