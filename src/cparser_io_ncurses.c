/**
 * \file     cparser_io_unix.c
 * \brief    Unix-specific parser I/O routines
 * \version  \verbatim $Id: cparser_io_unix.c 159 2011-10-29 09:29:58Z henry $ \endverbatim
 */
/*
 * Copyright (c) 2008-2009, 2011, Henry Kwok
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of the project nor the names of its contributors
 *       may be used to endorse or promote products derived from this software
 *       without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY HENRY KWOK ''AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL HENRY KWOK BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include <assert.h>
#include <ctype.h>
#include <ncurses.h>
#include <stdio.h>
#include <termios.h>
#include <unistd.h>
#include <string.h>
#include "cparser.h"
#include "cparser_io.h"
#include "cparser_priv.h"

#define CTRL_A (1)
#define CTRL_E (5)
#define CTRL_N (14)
#define CTRL_P (16)

static void
cparser_ncurses_getch (cparser_t *parser, int *ch, cparser_char_t *type)
{
    assert(VALID_PARSER(parser) && ch && type);
    *type = CPARSER_CHAR_UNKNOWN;
    *ch = wgetch(parser->cfg.win);
    if ('' == *ch) {
        *ch = wgetch(parser->cfg.win);
        if ('[' == *ch) {
            *ch = wgetch(parser->cfg.win);
            switch (*ch) {
                case 'A':
                    *type = CPARSER_CHAR_UP_ARROW;
                    break;
                case 'B':
                    *type = CPARSER_CHAR_DOWN_ARROW;
                    break;
                case 'C':
                    *type = CPARSER_CHAR_RIGHT_ARROW;
                    break;
                case 'D':
                    *type = CPARSER_CHAR_LEFT_ARROW;
                    break;
            }
        }
#ifdef CPARSER_EMACS_BINDING
    } else if (CTRL_P == (*ch)) {
        *type = CPARSER_CHAR_UP_ARROW;
    } else if (CTRL_N == (*ch)) {
        *type = CPARSER_CHAR_DOWN_ARROW;
    } else if (CTRL_A == (*ch)) {
        *type = CPARSER_CHAR_FIRST;
    } else if (CTRL_E == (*ch)) {
        *type = CPARSER_CHAR_LAST;
#endif /* EMACS_BINDING */
    } else if (isalnum(*ch) || ('\n' == *ch) ||
               ispunct(*ch) || (' ' == *ch) ||
               (*ch == parser->cfg.ch_erase) ||
               (*ch == parser->cfg.ch_del) ||
               (*ch == parser->cfg.ch_help) ||
               (*ch == parser->cfg.ch_complete)) {
        *type = CPARSER_CHAR_REGULAR;
    }
}

static void
cparser_ncurses_printc (const cparser_t *parser, const char ch)
{
    assert(parser && parser->cfg.win);
    wechochar(parser->cfg.win, ch);
}

static void
cparser_ncurses_prints (const cparser_t *parser, const char *s)
{
    assert(parser);
    if (s) {
       waddstr(parser->cfg.win, s);
       wrefresh(parser->cfg.win);
    }
}

static void 
cparser_ncurses_io_init (cparser_t *parser)
{

}

static void
cparser_ncurses_io_cleanup (cparser_t *parser)
{

}

void
cparser_io_ncurses_config (cparser_t *parser, WINDOW *win)
{
    assert(parser);
    parser->cfg.io_init    = cparser_ncurses_io_init;
    parser->cfg.io_cleanup = cparser_ncurses_io_cleanup;
    parser->cfg.cparser_getch      = cparser_ncurses_getch;
    parser->cfg.printc     = cparser_ncurses_printc;
    parser->cfg.prints     = cparser_ncurses_prints;
    parser->cfg.win        = win;
}
