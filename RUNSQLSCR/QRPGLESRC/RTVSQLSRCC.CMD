000100120425 RTVSQLSRC:  CMD        PROMPT('Retrieve SQL Source')
000200120425             /* Command processing program is: RTVSQLSRC  */
000300120425      /********************************************************/
000400120425      /* Program name: RTVSQLSRC                              */
000500120425      /* Author:       Bob Cozzi                              */
000600120425      /* From: midrangeNews.com/newsletter/rpgreport          */
000700120425      /********************************************************/
000800120425      /* (c) 2004 by Bob Cozzi - All rights reserved.         */
000900120425      /*     Do not republish this source code or any         */
001000120425      /*     derivative version of it on the Internet.        */
001100120425      /*     Do not resell this source code.                  */
001200120425      /*     Permission to use this EXAMPLE source code       */
001300120425      /*     is hereby granted provided you agree that        */
001400120425      /*     No Warranty is Expressed or Implied, and None is Given. */
001500120425      /********************************************************/
001600120425             PARM       KWD(FILE) TYPE(QUAL) MIN(1) PROMPT('File name')
001700120425 QUAL:       QUAL       TYPE(*NAME) MIN(1) EXPR(*YES)
001800120425             QUAL       TYPE(*NAME) DFT(*LIBL) SPCVAL((*CURLIB) (*LIBL)) MIN(0) EXPR(*YES) +
001900120425                          PROMPT('Library')
002000120425             PARM       KWD(SRCFILE) TYPE(SRCFILE) PROMPT('Source file name')
002100120425 SRCFILE:    QUAL       TYPE(*NAME) DFT(QSQLSRC) EXPR(*YES)
002200120425             QUAL       TYPE(*NAME) DFT(*LIBL) SPCVAL((*CURLIB) (*LIBL)) MIN(0) EXPR(*YES) +
002300120425                          PROMPT('Library')
002400120425             PARM       KWD(SRCMBR) TYPE(*NAME) DFT(*FILE) SPCVAL((*FILE)) EXPR(*YES) +
002500120425                          PROMPT('Source member')
002600120425             PARM       KWD(REPLACE) TYPE(*LGL) DFT(*YES) SPCVAL((*YES '1') (*NO '0') (*ON +
002700120425                          '1') (*OFF '0') (*REPLACE '1') (*NOREPLACE '0')) EXPR(*YES) +
002800120425                          PROMPT('Replace source member')
002900120425             PARM       KWD(NAMING) TYPE(*CHAR) LEN(3) RSTD(*YES) DFT(*SYS) SPCVAL((*SYS +
003000120425                          'SYS') (*SQL 'SQL')) EXPR(*YES) PROMPT('Qualified name syntax')
003100120425             PARM       KWD(SQLLVL) TYPE(*INT2) RSTD(*YES) DFT(*SYS) SPCVAL((*SYS 0) (*DB2SQL +
003200120425                          1) (*ANSISQL 2)) PROMPT('SQL Standards syntax')
003300120425             PARM       KWD(GENDROP) TYPE(*LGL) RSTD(*YES) DFT(*NO) SPCVAL((*NO '0') (*YES +
003400120425                          '1')) EXPR(*YES) PROMPT('Generate DROP file statement')
003500120425             PARM       KWD(COMMENT) TYPE(*LGL) RSTD(*YES) DFT(*YES) SPCVAL((*YES '1') (*NO +
003600120425                          '0')) EXPR(*YES) PROMPT('Generate header comments')
003700120425             PARM       KWD(MSGLVL) TYPE(*INT2) DFT(30) RANGE(0 39) PROMPT('Message generation +
003800120425                          level')
003900120425             PARM       KWD(SEVLVL) TYPE(*INT2) RSTD(*YES) DFT(30) VALUES(0 10 20 30 40) +
004000120425                          PROMPT('Error severity level to fail')
004100120425
