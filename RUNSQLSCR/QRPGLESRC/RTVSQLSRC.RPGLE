000100120425      *********************************************************
000200120425      ** Program name: RTVSQLSRC
000300120425      ** Author:       Bob Cozzi
000400120425      ** From: midrangeNews.com/newsletter/rpgreport
000500120425      *********************************************************
000600120425     H COPYRIGHT('2004 by Bob Cozzi - All rights reserved.')
000700120425      ** (c) 2004 by Bob Cozzi - All rights reserved.
000800120425      **     Do not republish this source code or any
000900120425      **     derivative version of it on the Internet.
001000120425      **     Do not resell this source code.
001100120425      **     Permission to use this EXAMPLE source code
001200120425      **     is hereby granted provided you agree that
001300120425      **     No Warranty is Expressed or Implied, and None is Given.
001400120425      *********************************************************
001500120425     H DFTACTGRP(*NO) OPTION(*SRCSTMT:*NODEBUGIO)
001600120425      /IF NOT DEFINED(*V6R1M0)
001700120425     H BNDDIR('QC2LE')
001800120425      /ENDIF
001900120425
002000120425     D RtvSQLSrc       PR                  EXTPGM('RTVSQLSRC')
002100120425     D  inFile                             LikeDS(FileLib_T)
002200120425     D  srcFile                            LikeDS(FileLib_T)
002300120425     D  srcMbr                       10A
002400120425     D  bReplace                      1N   OPTIONS(*NOPASS)
002500120425     D  szNaming                      3A   OPTIONS(*NOPASS)
002600120425     D  nStandard                     5I 0 OPTIONS(*NOPASS)
002700120425     D  bDrop                         1N   OPTIONS(*NOPASS)
002800120425     D  bHeader                       1N   OPTIONS(*NOPASS)
002900120425     D  nMsgLvl                       5I 0 OPTIONS(*NOPASS)
003000120425     D  nSevLvl                       5I 0 OPTIONS(*NOPASS)
003100120425
003200120425     D rtvSQLSrc       PI
003300120425     D  inFile                             LikeDS(FileLib_T)
003400120425     D  srcFile                            LikeDS(FileLib_T)
003500120425     D  srcMbr                       10A
003600120425     D  bReplace                      1N   OPTIONS(*NOPASS)
003700120425     D  szNaming                      3A   OPTIONS(*NOPASS)
003800120425     D  nStandard                     5I 0 OPTIONS(*NOPASS)
003900120425     D  bDrop                         1N   OPTIONS(*NOPASS)
004000120425     D  bHeader                       1N   OPTIONS(*NOPASS)
004100120425     D  nMsgLvl                       5I 0 OPTIONS(*NOPASS)
004200120425     D  nSevLvl                       5I 0 OPTIONS(*NOPASS)
004300120425
004400120425     D SafeAddMbr      PR
004500120425     D  srcFile                            Const LikeDS(FileLib_T)
004600120425     D  srcMbr                       10A   Const
004700120425
004800120425     D system          PR                  extproc('system')
004900120425     D  szCMDString                    *   Value OPTIONS(*STRING)
005000120425
005100120425     D  apiErrorDS     DS                  Inz
005200120425     D   errDSLen                    10I 0 Inz(%size(apiErrorDS))
005300120425     D   errRtnLen                   10I 0 Inz
005400120425     D   errMsgID                     7A   Inz(*ALLX'00')
005500120425     D   errReserved                  1A   Inz(X'00')
005600120425     D   errMsgData                  64A   Inz(*ALLX'00')
005700120425
005800120425      /COPY QSYSINC/QRPGLESRC,QSQGNDDL
005900120425      /COPY QSYSINC/QRPGLESRC,QUSROBJD
006000120425
006100120425     D filelib_T       DS                  based(nothing)
006200120425     D  file                         10A
006300120425     D  fileName                     10A   Overlay(file)
006400120425     D  library                      10A
006500120425     D  lib                          10A   Overlay(library)
006600120425
006700120425     D  inReplace      S              1N   Inz('1')
006800120425     D  inNaming       S              3A   Inz('SYS')
006900120425     D  inMsgLvl       S              5I 0 Inz(30)
007000120425     D  inSevLvl       S              5I 0 Inz(30)
007100120425     D  inStandard     S              5I 0 Inz(0)
007200120425     D  inDrop         S              1N   Inz('0')
007300120425     D  inHeader       S              1N   Inz('1')
007400120425
007500120425     D fileType        S                   Like(QUSEoA05)
007600120425     D mySQL           DS                  LikeDS(QSQR0100)
007700120425
007800120425
007900120425     D QRtvOBJD        PR                  extpgm('QUSROBJD')
008000120425     D  rtnData                            LIKEDS(QUSD0200)  OPTIONS(*VARSIZE)
008100120425     D  rtnLen                       10I 0 Const
008200120425     D  OdFormat                      8A   Const
008300120425     D  ObjLib                       20A   Const
008400120425     D  ObjType                      10A   Const
008500120425     D  apiErrorDS                         LikeDS(apiErrorDS) OPTIONS(*VARSIZE)
008600120425
008700120425     D QRtvSQLSrc      PR                  extpgm('QSQGNDDL')
008800120425     D  sqTempl                            LikeDS(QSQR0100) OPTIONS(*VARSIZE)
008900120425     D  sqtLen                       10I 0 Const
009000120425     D  sqFormat                      9A   Const
009100120425     D  apiErrorDS                         LikeDS(apiErrorDS) Options(*VARSIZE)
009200120425
009300120425      /FREE
009400120425       if srcmbr = '*FILE';
009500120425         srcmbr = inFile.file;
009600120425       endif;
009700120425         // Copy the input parms to their variables, if specified.
009800120425       if %parms >= 4;
009900120425         InReplace = bReplace;
010000120425         if %parms >= 5;
010100120425           InNaming = szNaming;
010200120425           if %parms >= 6;
010300120425             InStandard= nStandard;
010400120425             if %parms >= 7;
010500120425               InDrop = bDrop;
010600120425               if %parms >= 8;
010700120425                 InHeader = bHeader;
010800120425                 if %parms >= 9;
010900120425                   inMsgLvl = nMsgLvl;
011000120425                   if %parms >= 10;
011100120425                     InSevLvl = nSevLvl;
011200120425                   endif;
011300120425                 endif;
011400120425               endif;
011500120425             endif;
011600120425           endif;
011700120425         endif;
011800120425       endif;
011900120425
012000120425          //  Retrieve the file attribute (LF or PF)
012100120425          qrtvobjd(QUSD0200 : %Len(QUSD0200) :
012200120425              'OBJD0200' : inFile :'*FILE':apiErrorDS);
012300120425          if (%subst(errMSGID:1:5) = 'CPF98');
012400120425            //  Failed - Source file not found. :(
012500120425            return;
012600120425          endif;
012700120425
012800120425          //  Does the mbr exist? It has to or this stupid API don't work!
012900120425          safeAddMbr(srcFile : SrcMbr);
013000120425
013100120425          fileType = QUSEoA05;
013200120425          CLEAR mySQL;
013300120425          mySQL.qsqOBJN = inFile.fileName;
013400120425          mySQL.qsqOBJL = inFile.lib;
013500120425          select;
013600120425          when fileType = 'PF';   // SQL Table
013700120425            mySQL.qsqObjT = 'TABLE';
013800120425          when fileType = 'LF';   // SQL View
013900120425            mySQL.qsqObjT = 'VIEW';
014000120425          endsl;
014100120425
014200120425          mySQL.qsqSFilN = srcFile.fileName;
014300120425          mySQL.qsqSFilL = srcFile.Lib;
014400120425          mySQL.qsqSFilM = srcMbr;
014500120425
014600120425          mySQL.qsqSL02 = inSevLvl;
014700120425          mySQL.qsqRo   = inReplace;
014800120425          mySQL.qsqSfo  = '0';
014900120425          mySQL.qsqNo02 = inNaming;
015000120425          mySQL.qsqML02 = inMsgLvl;
015100120425          mySQL.qsqDF02 = 'ISO';
015200120425          mySQL.qsqTF02 = 'ISO';
015300120425          mySQL.qsqDS02 = ' ';
015400120425          mySQL.qsqTS02 = ' ';
015500120425          mySQL.qsqDP02 = '.';
015600120425          mySQL.qsqSo01 = %char(inStandard);
015700120425          mySQL.qsqDo   = inDrop;
015800120425          mySQL.qsqCo   = '1';
015900120425          mySQL.qsqLo   = '1';
016000120425          mySQL.qsqHo   = inHeader;
016100120425          mySQL.qsqTo   = '0';
016200120425          mySQL.qsqCo00 = '0';
016300120425          mySQL.qsqSno  = '0';
016400120425
016500120425
016600120425          // Retrieve the SQL Source for the file
016700120425          qrtvsqlsrc(mySQL : %Len(mySQL) :
016800120425              'SQLR0100' : apiErrorDS);
016900120425
017000120425          return;
017100120425
017200120425      /end-free
017300120425     C                   eval      *INLR = *ON
017400120425
017500120425     P safeAddMbr      B                   Export
017600120425     D safeAddMbr      PI
017700120425     D  srcFile                            Const  LikeDS(fileLib_T)
017800120425     D  srcMbr                       10A   Const
017900120425
018000120425
018100120425      // The structure returned by the QusRMBRD API.
018200120425     D mbrD0100        DS                  INZ
018300120425     D  nBytesRtn                    10I 0
018400120425     D  nBytesAval                   10I 0
018500120425     D  szFileName                   10A
018600120425     D  szLibName                    10A
018700120425     D  szMbrName                    10A
018800120425     D  szFileAttr                   10A
018900120425     D  szSrcType                    10A
019000120425     D  dtCrtDate                    13A
019100120425     D  dtLstChg                     13A
019200120425     D  szMbrText                    50A
019300120425     D  bIsSource                     1A
019400120425
019500120425     D CPF_MbrNotFound...
019600120425     D                 C                   CONST('CPF9815')
019700120425     D nBufLen         S             10I 0
019800120425     D apiFMT          C                   Const('MBRD0100')
019900120425
020000120425     D QUSRMBRD        PR                  extPgm('QUSRMBRD')
020100120425     D  rtnDS                              LikeDS(mbrD0100) OPTIONS(*VARSIZE)
020200120425     D  rtnLen                       10I 0 Const
020300120425     D  apiFormat                     8A   Const
020400120425     D  dbFilename                         Const LikeDS(fileLib_T)
020500120425     D  mbrName                      10A   Const
020600120425     D  ignoreOVRDBF                  1N   Const
020700120425     D  apiErrorDS                         LikeDS(apiErrorDS)
020800120425     D                                     OPTIONS(*VARSIZE:*NOPASS)
020900120425     D  findMbr                       1N   Const OPTIONS(*NOPASS)
021000120425      /free
021100120425          reset apiErrorDS;
021200120425          nBufLen = %size(mbrD0100);
021300120425          qusrmbrd(mbrD0100:nBufLen:apiFMT:srcFile:srcMbr:'0':apiErrorDS);
021400120425                // AddMbr only if it doesn't exist.
021500120425             if (errRtnLen > 0);
021600120425               if errMsgID = CPF_MbrNotFound or
021700120425                  errMsgID = 'CPF3019' or
021800120425                  errMsgID = 'CPF32DE' or
021900120425                  errMsgID = 'CPF3C27' or
022000120425                  errMsgID = 'CPF3C26';
022100120425                    system('ADDPFM FILE(' + %TrimR(srcFile.Lib) + '/' +
022200120425                         srcfile.FileName + ') MBR(' + srcMbr + ')' +
022300120425                         ' SRCTYPE(SQL)' );
022400120425                endif;
022500120425             endif;
022600120425             return;
022700120425      /end-free
022800120425     P safeAddMbr      E
022900120425
