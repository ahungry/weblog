:- module(wl_numbers,
	  [ n//2,			% +Format, +Value
	    nc//2,			% +Format, +Value
	    nc//3			% +Format, +Value, +Options
	  ]).

/** <module> Tools for formatting numbers

    Part of Weblog

    Derived from

    Part of ClioPatria SeRQL and SPARQL server

    Author:        Jan Wielemaker
    E-mail:        J.Wielemaker@cs.vu.nl
    WWW:           http://www.swi-prolog.org
    Copyright (C): 2010 VU University Amsterdam

    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation; either version 2
    of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public
    License along with this library; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

    As a special exception, if you link this library with other files,
    compiled with a Free Software compiler, to produce an executable, this
    library does not by itself cause the resulting executable to be covered
    by the GNU General Public License. This exception does not however
    invalidate any other reasons why the executable file might be covered by
    the GNU General Public License.
*/

:- use_module(library(http/html_write)).
:- use_module(library(sgml)).
:- use_module(library(lists)).
:- use_module(library(option)).
:- use_module(library(occurs)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_wrapper)).

:- html_meta((
	form_input(html, html, ?, ?),
	odd_even_row(+, -, html, ?, ?),
	sort_th(+, +, html, ?, ?))).

%%	nc(+Format, +Value)// is det.
%%	nc(+Format, +Value, +Options)// is det.
%
%	Numeric  cell.  The  value  is    formatted   using  Format  and
%	right-aligned in a table cell (td).
%
%	@param	Format is a (numeric) format as described by format/2 or
%		the constant =human=.  _Human_ formatting applies to
%		integers and prints then in abreviated (K,M,T) form,
%		e.g., 4.5M for 4.5 million.
%	@param	Options is passed as attributed to the =td= element.
%		Default alignment is =right=.

nc(Fmt, Value) -->
	nc(Fmt, Value, []).

nc(Fmt, Value, Options) -->
	{ class(Value, Class),
	  merge_options(Options,
			[ align(right),
			  class(Class)
			], Opts),
	  number_html(Fmt, Value, HTML)
	},
	html(td(Opts, HTML)).

class(Value, Class) :-
	(   integer(Value)
	->  Class = int
	;   float(Value)
	->  Class = float
	;   Class = value
	).

%%	n(+Format, +Value)//
%
%	HTML component to emit a number.
%
%	@see nc//2 for details.

n(Fmt, Value) -->
	{ number_html(Fmt, Value, HTML) },
	html(HTML).

number_html(human, Value, HTML) :-
	integer(Value), !,
	human_count(Value, HTML).
number_html(Fmt, Value, HTML) :-
	number(Value), !,
	HTML = Fmt-[Value].
number_html(_, Value, '~p'-[Value]).


human_count(Number, HTML) :-
	Number < 1024, !,
	HTML = '~d'-[Number].
human_count(Number, HTML) :-
	Number < 1024*1024, !,
	KB is Number/1024,
	digits(KB, N),
	HTML = '~*fK'-[N, KB].
human_count(Number, HTML) :-
	Number < 1024*1024*1024, !,
	MB is Number/(1024*1024),
	digits(MB, N),
	HTML = '~*fM'-[N, MB].
human_count(Number, HTML) :-
	TB is Number/(1024*1024*1024),
	digits(TB, N),
	HTML = '~*fG'-[N, TB].

digits(Count, N) :-
	(   Count < 100
	->  N = 1
	;   N = 0
	).
