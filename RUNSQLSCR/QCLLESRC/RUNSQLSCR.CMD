000100
000101150210             CMD        PROMPT('Run a SQL Script')
000102150210
000106160120             PARM       KWD(SRCFILE) TYPE(SRCFILE) +
000107150210                          PROMPT('Source File')
000108150210
000109160120             PARM       KWD(SRCMBR) TYPE(*CHAR) LEN(10) +
000110150213                          PROMPT('Source Member')
000111151102
000112160120             PARM       KWD(SRCSTMF) TYPE(*CHAR) LEN(540) +
000113151102                          PROMPT('Stream file')
000114150210
000115151102             PARM       KWD(SCHEMA) TYPE(*CHAR) LEN(10) DFT(*SRCLIB) +
000116151102                          SPCVAL((*SRCLIB) (*NONE)) PROMPT('Schema +
000117151102                          name')
000119151102
000120151102             PARM       KWD(OPTION) TYPE(*CHAR) LEN(10) RSTD(*YES) +
000121150211                          DFT(*NOEVENTF) VALUES(*EVENTF *NOEVENTF) +
000122150210                          PROMPT('Option')
000123151111
000124151111             PARM       KWD(EVENTFL) TYPE(*CHAR) LEN(10) RSTD(*YES) +
000125151111                          DFT(*NONE) VALUES(*SCHEMA *NONE) +
000126151111                          PROMPT('Library for EVENTF')
000127150213
000128150213             PARM       KWD(SEVLIMIT) TYPE(*DEC) LEN(2) DFT(10) +
000129150213                          RANGE(0 40) PROMPT('Severity Level limit')
000130160421
000131160421             PARM       KWD(PGM) TYPE(*CHAR) LEN(10) PROMPT('For RDi +
000132160421                          - PGM name')
000134150210
000135150210 SRCFILE:    QUAL       TYPE(*NAME) LEN(10) MIN(1) EXPR(*YES)
000136150210             QUAL       TYPE(*NAME) LEN(10) SPCVAL((*LIBL) +
000137150210                          (*CURLIB)) MIN(1) PROMPT('Library')
000138150210
