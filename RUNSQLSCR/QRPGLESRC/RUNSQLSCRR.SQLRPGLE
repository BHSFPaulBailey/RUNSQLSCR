000100150211     h option(*NODEBUGIO : *SRCSTMT) expropts(*resdecpos) DFTACTGRP(*NO)
000200150210      *===================================================================
000300150211      * PROGRAM NAME - RUNSQLSCRR - RPGLE portion for RUNSQLSCR
000400150211      * PROGRAMMER   - Paul Bailey
000500150211      * DATE WRITTEN - Feb 2015
000600150211      * FUNCTION     - Parse the error SPLF from a RUNSQLSTM command
000700150211      *                and create an EVFEVENT file displaying the errors
000800150211      *                so Rational Developer for i can help the programmer.
000900980903      *===================================================================
001000980903      *  A M E N D M E N T S
001100130201      *
001200850313      *===================================================================
001300000718      *
001400150212     FTMPEVENT  IF   E             DISK    QUALIFIED
001500850315      *===================================================================
001600050718      *
001700150213      *
001800150213      *===============================================================
001900150213      *  Procedure Prototypes
002000150213      *===============================================================
002100150213     d/copy runsqlscr/qrpglesrc,runsqlscrp
002101160419     d/include qsysinc/qrpglesrc,sysstat
002200150213      *
002300150213     DRUNSQLSCRR       PI
002400160120     D  p#SrcLib                     10A
002500160120     D  p#SrcFile                    10A
002600160120     D  p#SrcMember                  10A
002601160120     D  p#SrcStream                 540A
002700160120     D  p#EventL                     10A
002800160120     D  p#SrcMbrChg                  13A
002900150213      *===============================================================
003000160420     D stat2           PR            10I 0 ExtProc('stat')
003001160420     D   path                          *   value options(*string)
003002160420     D   buf                           *   value
003003160420     D statsize        S             10I 0 inz
003004160120     D p_statds        S               *
003005160419     D statds          DS                  BASED(p_statds) likeds(stat_t)
003006160419     D* st_mode                      10U 0
003007160419     D* st_ino                       10U 0
003008160419     D* st_nlink                      5U 0
003009160419     D* st_pad                        2A
003010160419     D* st_uid                       10U 0
003011160419     D* st_gid                       10U 0
003012160419     D* st_size                      10I 0
003013160419     D* st_atime                     10I 0
003014160419     D* st_mtime                     10I 0
003015160419     D* st_ctime                     10I 0
003016160419     D* st_dev                       10U 0
003017160419     D* st_blksize                   10U 0
003018160419     D* st_allocsize                 10U 0
003019160419     D* st_objtype                   12A
003020160419     D* st_codepage                   5U 0
003021160419     D* st_reserved1                 62A
003022160419     D* st_ino_gen_id                10U 0
003023160419     D MyStat          S                   like(statds)
003024160120     D MyModTime       S               Z
003025160120     D MySize          S             10I 0
003026160120     D w#SrcMbrChg     S                   like(p#SrcMbrChg)
003027160420     D w#SrcMbrChg2    S             14A   inz
003028160120     D EscErrno        PR             1N
003029160120     D   errnum                      10i 0 value
003030160120     D @__errno        PR              *   ExtProc('__errno')
003031160120     D errno           PR            10I 0
003032160120     D Get_UTC_Offset  PR            10i 0
003033160120     D ToTime          PR              z
003034160120     D  inSeconds                    10i 0 value
003035160120      *
003100150212     D spoolFile       DS                  LIKEREC(TMPEVENT.TMPEVENT: *INPUT)
003200150213      * eventLine.spoolLine is from each line of the RUNSQLSTM report spooled file
003300150213     D eventLine       DS                  QUALIFIED
003400150213     D   spoolLine                  132A
003500150213     D   msgID                        7A   OverLay(spoolLine)
003600150213     D   blank1                       2A   OverLay(spoolLine: *NEXT)
003700150213     D   errorSev                     2A   OverLay(spoolLine: *NEXT)
003800150213     D   blank2                       2A   OverLay(spoolLine: *NEXT)
003900150213     D   errorLine                    6A   OverLay(spoolLine: *NEXT)
004000150213     D   blank3                       2A   OverLay(spoolLine: *NEXT)
004100150213     D   msgText                    111A   OverLay(spoolLine: *NEXT)
004200150212     D
004300150213     D eventDetail     DS                  QUALIFIED
004400150212     D   msgID                        7A   inz
004500150212     D   errorSev                     2S 0 inz
004600150212     D   errorLine                    6S 0 inz
004700150212     D   msgText                    999A   inz
004800150212     D
004900150211     D dsAnnotation    DS                  QUALIFIED
005000150211     D   TopLine                      1S 0 INZ(0)
005100150211     D   InLine                       1S 0 INZ(1)
005200150211     D
005300150211     D fileLoop        S               N
005400150213     D writtenHeader   S               N
005500150211     D foundRecord     S               N
005600150213      *
005700850313      *===================================================================
005800850313      * START OF PROGRAM                                               ===
005900850313      *===================================================================
006000150211      /FREE
006100150211
006200150211         SetGT *HIVAL TMPEVENT;
006300150211         fileLoop = *on;
006400150211         foundRecord = *OFF;
006500150213         DoW fileLoop = *ON;
006600150212           ReadP TMPEVENT spoolFile;
006700150211           If %EOF(TMPEVENT);
006800150211             fileLoop = *OFF;
006900150211           Else;
007000150212             If %trim(spoolFile.TMPEVENT) =
007100150211                     '* * * * *  E N D  O F  S O U R C E  * * * * *';
007200150211               fileLoop = *OFF;
007300150211               foundRecord = *ON;
007400150211             EndIf;
007500150211           EndIf;
007600150211         EndDo;
007700150211
007800150211         if foundRecord = *ON;
007900150211
008000150211           fileLoop = *ON;
008100150213           writtenHeader = *OFF;
008200150211           DoW fileLoop = *ON;
008300150212             Read TMPEVENT spoolFile;
008400150211             If %EOF(TMPEVENT);
008500150211               fileLoop = *OFF;
008600150212             ElseIf %TRIM(spoolFile.TMPEVENT) = 'Message Summary';
008700150211               fileLoop = *OFF;
008800150212             ElseIf %subst(spoolFile.TMPEVENT: 22: 33) =
008900150211                                        '               Run SQL Statements';
009000150211               // Ignore page headings
009100150212             ElseIf %subst(spoolFile.TMPEVENT: 1: 28) =
009200150211                                        'Record  *...+... 1 ...+... 2';
009300150211               // Ignore page headings
009400150212             ElseIf %trim(spoolFile.TMPEVENT) = 'MSG ID  SEV  RECORD  TEXT';
009500150211               // Ignore error column headings
009600150211             Else;
009700150213               eventLine.spoolLine = spoolFile.TMPEVENT;
009800150213               if eventLine.msgID = *BLANKS And eventDetail.msgID <> *BLANKS;
009900150211                 // Error message text wrapped over
010000150213                 eventDetail.msgText = %trim(eventDetail.msgText)
010100150211                                    + ' '
010200150213                                    + %TRIM(eventLine.msgText);
010300150213               Elseif eventLine.msgID = *BLANKS And eventDetail.msgID = *BLANKS;
010400150211                 // Ignore blank lines
010500150211               Else;
010600150213                 If eventDetail.msgID <> *BLANKS;
010700150212                   ExSr WriteErrEvent;
010800150211                 EndIf;
010900150213                 eventDetail.msgID = eventLine.msgID;
011000150213                 eventDetail.msgText = eventLine.msgText;
011001170216                 if eventLine.errorSev = *BLANKS;
011002170216                   eventLine.errorSev = '00';
011003170216                   eventDetail.msgText = '?' + %trim(eventDetail.msgText);
011004170216                 EndIf;
011100150213                 eventDetail.errorSev = %INT(%TRIM(eventLine.errorSev));
011101170216                 if eventLine.errorLine = *BLANKS;
011102170216                   eventLine.errorLine = '000000';
011103170216                   eventDetail.msgText = '?' + %trim(eventDetail.msgText);
011104170216                 EndIf;
011200150213                 eventDetail.errorLine = %INT(%TRIM(eventLine.errorLine));
011300150211               EndIf;
011400150211             EndIf;
011500150211           EndDo;
011600150213           If eventDetail.msgID <> *BLANKS;
011700150212             ExSr WriteErrEvent;
011800150211           EndIf;
011900150213           If writtenHeader = *OFF;
012000150213             eventDetail.msgID = 'CPF0000';
012001160120             If p#SrcStream <> *BLANKS;
012100160120               eventDetail.msgText = 'Script '
012200160120                                  + %TRIM(p#SrcStream)
012500160120                                  + ' ran successfully';
012501160120             else;
012502160120               eventDetail.msgText = 'Script '
012503160120                                  + %TRIM(p#SrcLib) + '/'
012504160120                                  + %TRIM(p#SrcFile) + ' ('
012505160120                                  + %TRIM(p#SrcMember) + ')'
012506160120                                  + ' ran successfully';
012507160120             EndIf;
012600150213             eventDetail.errorSev = 0;
012700150213             eventDetail.errorLine = 0;
012800150212             ExSr WriteErrEvent;
012900150211           EndIf;
013000150211
013100150212           #wrtEvtFileFileEnd() ;
013200150211         EndIf;
013300150211
013400150211         *inLR = *ON;
013500150211         Return;
013600150211
013700150213
013800150211       //===================================================================
013900150212       // WriteErrEvent - Write an events file entry for an error line
014000150211       //===================================================================
014100150212S01    BEGSR WriteErrEvent;
014200150211
014300150213         If writtenHeader = *OFF;
014301160120           w#SrcMbrChg = p#SrcMbrChg;
014302160120           if w#SrcMbrChg = 'xxx';
014303160120             // get stat info into "MyStat":
014304160420             statsize = %size(statds);
014305160420             p_statds = %alloc(statsize);
014306160420             if stat2(%trim(p#SrcStream):
014307160420                     p_statds) < 0;
014308160420       //            %addr(mystat)) < 0;
014309160120               EscErrno(errno);
014310160120             endif;
014311160120
014312160120             // move structure to overlay the "mystat" info:
014313160420       //      p_statds = %addr(mystat);
014314160120
014315160120             // read the file's modifcation time into MyModTime:
014316160419             MyModTime = ToTime(statds.st_mtime);
014317160420             w#SrcMbrChg2 = %Char(MyModTime : *iso0);
014318160420             w#SrcMbrChg = '0' + %subst(w#SrcMbrChg2: 2: 12);
014319160420             if %subst(w#SrcMbrChg2: 1: 4) >= '2000';
014320160420               %subst(w#SrcMbrChg: 1: 1) = '1';
014321160420             EndIf;
014322160120           EndIf;
014323160120           If p#SrcStream <> *BLANKS;
014324160120             #crtEvtFileMbr2(p#EventL: p#SrcStream:
014325160420                            p#SrcMember: w#SrcMbrChg2) ;
014326160120           Else;
014400160120             #crtEvtFileMbr(p#EventL: p#SrcLib: p#SrcFile:
014500160120                            p#SrcMember: w#SrcMbrChg) ;
014501160120           EndIf;
014600150213           writtenHeader = *ON;
014700150211         EndIf;
014800150213
014900150213         If eventDetail.errorLine = 0;
015000150213           #wrtEvtFileError(eventDetail.msgID
015100150213                            :eventDetail.msgText
015200150211                            :dsAnnotation.TopLine
015300150213                            :eventDetail.errorLine
015400150213                            :eventDetail.errorSev
015500150211                            :' '
015600150211                            );
015700150211         Else;
015800150213           #wrtEvtFileError(eventDetail.msgID
015900150213                            :eventDetail.msgText
016000150211                            :dsAnnotation.InLine
016100150213                            :eventDetail.errorLine
016200150213                            :eventDetail.errorSev
016300150211                            :' '
016400150211                            );
016500150211         EndIf;
016600150213         clear eventDetail;
016700150211
016800150211
016900150212E01    ENDSR; // WriteErrEvent
017000150211       //
017100150211      /END-FREE
017200150211
017300150211      *===============================================================
017400150211      * Originally from a "Four Hundred Guru" article on itjungle.com
017500150211      * <http://www.itjungle.com/fhg/fhg080404-story01.html>
017600150211      *===============================================================
017700150213      * Check the following URL to see Events File format
017800150213      * <http://www-01.ibm.com/support/knowledgecenter/SSAE4W_9.1.1/
017900150213      *  com.ibm.etools.iseries.rse.doc/topics/revformat.html?lang=en>
018000150211      *
018100150211      *===============================================================
018200150212      *  Procedure:   #crtEvtFileMbr - Create Events File Member
018300150211      *       Input parms:
018400150211      *            Object Library
018500150211      *            Source Library
018600150211      *            Source File
018700150211      *            Source Member
018800150213      *            Source Member Change Date
018900150211      *       Output parms:
019000150211      *            None
019100150211      *       Return Value:
019200150211      *            None
019300150211      *===============================================================
019400150212     p #crtEvtFileMbr...
019500150212     p                 b
019600150211      *===============================================================
019700150212     d #crtEvtFileMbr...
019800150211     d                 pi
019900150211     d  objlib                       10a   const
020000150211     d  srclib                       10a   const
020100150211     d  srcfile                      10a   const
020200150211     d  srcmbr                       10a   const
020300150212     d  srcchg                       13a   const
020400150211      *===============================================================
020500150211     d command         s           3000a   varying
020600150211     d sqlstmt         s             80a
020700150211      *===============================================================
020800150211      /free
020900150211
021000150213       // Do the following in the calling CLLE
021100150212       //  // Create file EVFEVENT in Object Library
021200150213       //  // Add Member to file EVFEVENT in Object Library
021300150213       //  // Clear Member in file EVFEVENT in Object Library
021400150213
021500150213       // Build Create Alias Statement
021600150213       // (makes all file reads point at a specific member)
021700150213       sqlstmt = 'create alias qtemp/evtfilembr for '
021800150213               + %trim(objlib)
021900150213               + '/EVFEVENT('
022000150213               + %trim(srcmbr)
022100150213               + ')';
022200150211
022300150211       EXEC SQL
022400150211         EXECUTE IMMEDIATE :sqlstmt;
022500150211
022600150213       // Write Processor Record
022700150213       #wrtEvtFileTimestamp();
022800150211
022900150213       // Write Processor Record
023000150213       #wrtEvtFileProcessor();
023100150211
023200150213       // Write FileID Record
023300150213       #wrtEvtFileFileID(srclib:
023400150213                         srcfile:
023500150213                         srcmbr:
023600150213                         srcchg);
023700150211
023800150213       return;
023900150211
024000150211      /end-free
024100150211     p                 e
024200150211      *===============================================================
024300150212
024400150212
024401160120      *===============================================================
024402160120      *  Procedure:   #crtEvtFileMbr2 - Create Events File Member (for IFS source)
024403160120      *       Input parms:
024404160120      *            Object Library
024406160120      *            Source File
024407160120      *            Source Member name (used by system in, e.g., spool files)
024408160120      *            Source File Change Date
024409160120      *       Output parms:
024410160120      *            None
024411160120      *       Return Value:
024412160120      *            None
024413160120      *===============================================================
024414160120     p #crtEvtFileMbr2...
024415160120     p                 b
024416160120      *===============================================================
024417160120     d #crtEvtFileMbr2...
024418160120     d                 pi
024419160120     d  objlib                       10a   const
024421160120     d  srcstmf                     540a   const
024422160120     d  srcmbr                       10a   const
024423160420     d  srcchg                       14a   const
024424160120      *===============================================================
024426160120     d sqlstmt         s             80a
024427160120      *===============================================================
024428160120      /free
024429160120
024430160120       // Do the following in the calling CLLE
024431160120       //  // Create file EVFEVENT in Object Library
024432160120       //  // Add Member to file EVFEVENT in Object Library
024433160120       //  // Clear Member in file EVFEVENT in Object Library
024434160120
024435160120       // Build Create Alias Statement
024436160120       // (makes all file reads point at a specific member)
024437160120       sqlstmt = 'create alias qtemp/evtfilembr for '
024438160120               + %trim(objlib)
024439160120               + '/EVFEVENT('
024440160120               + %trim(srcmbr)
024441160120               + ')';
024442160120
024443160120       EXEC SQL
024444160120         EXECUTE IMMEDIATE :sqlstmt;
024445160120
024446160120       // Write Processor Record
024447160120       #wrtEvtFileTimestamp();
024448160120
024449160120       // Write Processor Record
024450160120       #wrtEvtFileProcessor();
024451160120
024452160120       // Write FileID Record
024453160120       #wrtEvtFileFileID2(srcstmf:
024456160120                         srcchg);
024457160120
024458160120       return;
024459160120
024460160120      /end-free
024461160120     p                 e
024462160120      *===============================================================
024463160120
024464160120
024500150212      *===============================================================
024600150212      *  Procedure:   #wrtEvtFileTimestamp - Write TimeStamp Format
024700150211      *       Input parms:
024800150211      *            None
024900150211      *       Output parms:
025000150211      *            None
025100150211      *       Return Value:
025200150211      *            None
025300150211      *===============================================================
025400150212     p #wrtEvtFileTimestamp...
025500150212     p                 b
025600150211      *===============================================================
025700150212     d #wrtEvtFileTimestamp...
025800150211     d                 pi
025900150211      *===============================================================
026000150211     d timestamp       s             14a   inz
026100150211      *===============================================================
026200150211      /free
026300150211
026400150213       // Determine TimeStamp
026500150213       timestamp = %char(%date():*iso0)
026600150213                   + %char(%time():*hms0);
026700150211
026800150213       EXEC SQL
026900150213        INSERT
027000150213          INTO qtemp/evtfilembr
027100150213        VALUES ('TIMESTAMP  1 ' ||
027200150213                :timestamp);
027300150211
027400150213       return;
027500150211
027600150211      /end-free
027700150211     p                 e
027800150211      *===============================================================
027900150212
028000150212
028100150212      *===============================================================
028200150212      *  Procedure:   #wrtEvtFileProcessor - Write Processor Format
028300150211      *       Input parms:
028400150211      *            None
028500150211      *       Output parms:
028600150211      *            None
028700150211      *       Return Value:
028800150211      *            None
028900150211      *===============================================================
029000150212     p #wrtEvtFileProcessor...
029100150212     p                 b
029200150211      *===============================================================
029300150212     d #wrtEvtFileProcessor...
029400150211     d                 pi
029500150211      *===============================================================
029600150211      /FREE
029700150211       EXEC SQL
029800150211        INSERT
029900150211          INTO qtemp/evtfilembr
030000150211        VALUES ('PROCESSOR  1 000 1');
030100150211
030200150211       return;
030300150211
030400150211      /end-free
030500150211     p                 e
030600150211      *===============================================================
030700150212
030800150212
030900150212      *===============================================================
031000150212      *  Procedure:   #wrtEvtFileFileID - Write FileID Format
031100150211      *       Input parms:
031200150211      *            Source Library
031300150211      *            Source File
031400150211      *            Source Member
031500150213      *            Source Member Change Date
031600150211      *       Output parms:
031700150211      *            None
031800150211      *       Return Value:
031900150211      *            None
032000150211      *===============================================================
032100150212     p #wrtEvtFileFileID...
032200150212     p                 b
032300150211      *===============================================================
032400150212     d #wrtEvtFileFileID...
032500150211     d                 pi
032600150211     d  srclib                       10a   const
032700150211     d  srcfile                      10a   const
032800150211     d  srcmbr                       10a   const
032900150212     d  srcchg                       13a   const
033000150211      *===============================================================
033100150211     d command         s           3000a   varying
033200150211     d lstchgcen       s              2a   inz
033300150211     d sourcelen       s              3s 0 inz
033400150211     d sourcelena      s              3a   inz
033500150211     d sourcename      s             33a   inz varying
033600150211      *
033700150211     d lstchgds        ds                  inz
033800150211     d  lstchgc                       1a
033900150211     d  lstchgd                       6a
034000150211     d  lstchgt                       6a
034100150213      *===============================================================
034200150211      /free
034300150211
034400150213       // Determine Source Name Length
034500150213       sourcename = %trim(srclib)
034600150213                  + '/'
034700150213                  + %trim(srcfile)
034800150213                  + '('
034900150213                  + %trim(srcmbr)
035000150213                  + ')';
035100150211
035200150213       sourcelen  = %len(sourcename);
035300150213       sourcelena = %editc(sourcelen:'X');
035400150211
035500150213       // Determine Source Change Date/Time's century
035600150212       eval lstchgds = srcchg;
035700150212       if lstchgc = '0';
035800150212         eval lstchgcen = '19';
035900150212       else;
036000150212         eval lstchgcen = '20';
036100150212       endif;
036200150212
036300150213       EXEC SQL
036400150213        INSERT
036500150213          INTO qtemp/evtfilembr
036600150213        VALUES ('FILEID     1 001 000001 ' ||
036700150213                :sourcelena || ' ' ||
036800150213                :sourcename || ' ' ||
036900150213                :lstchgcen ||
037000150213                :lstchgd ||
037100150213                :lstchgt || ' 0');
037200150211
037300150213       return;
037400150211
037500150211      /end-free
037600150211      *===============================================================
037700150211     p                 e
037800150211      *===============================================================
037801160120
037802160120
037803160120      *===============================================================
037804160120      *  Procedure:   #wrtEvtFileFileID2 - Write FileID Format (IFS file)
037805160120      *       Input parms:
037807160120      *            Source File
037809160120      *            Source File Change Date
037810160120      *       Output parms:
037811160120      *            None
037812160120      *       Return Value:
037813160120      *            None
037814160120      *===============================================================
037815160120     p #wrtEvtFileFileID2...
037816160120     p                 b
037817160120      *===============================================================
037818160120     d #wrtEvtFileFileID2...
037819160120     d                 pi
037821160120     d  srcstmf                     540a   const
037823160420     d  srcchg                       14a   const
037824160120      *===============================================================
037826160120     d lstchgcen       s              2a   inz
037827160120     d sourcelen       s              3s 0 inz
037828160120     d sourcelena      s              3a   inz
037829160120     d sourcename      s            540a   inz varying
037830160120      *
037831160420     d*lstchgds        ds                  inz
037832160420     d* lstchgc                       2a
037833160420     d* lstchgd                       6a
037834160420     d* lstchgt                       6a
037835160120      *===============================================================
037836160120      /free
037837160120
037838160120       // Determine Source Name Length
037839160120       sourcename = %trim(srcstmf);
037845160120
037846160120       sourcelen  = %len(sourcename);
037847160120       sourcelena = %editc(sourcelen:'X');
037848160120
037849160120       // Determine Source Change Date/Time's century
037850160420       //eval lstchgds = srcchg;
037851160420       //if lstchgc < '2000';
037852160420       //  eval lstchgcen = '19';
037853160420       //else;
037854160420       //  eval lstchgcen = '20';
037855160420       //endif;
037856160120
037857160420       EXEC SQL
037858160420         INSERT INTO qtemp/evtfilembr
037859160420           VALUES ('FILEID     1 001 000001 ' || :sourcelena || ' ' ||
037860160420             :sourcename || ' ' || :srcchg || ' 0');
037866160120
037867160120       return;
037869160120      /end-free
037870160120      *===============================================================
037871160120     p                 e
037872160120      *===============================================================
037900150212
038000150212
038100150212      *===============================================================
038200150212      *  Procedure:   #wrtEvtFileError - Write Error Format
038300150211      *       Input parms:
038400150211      *            Message ID
038500150211      *            Message Text
038600150211      *            Annotation (0=Top, 1-In, 2-Bottom)
038700150211      *            Error Line (line reported containing error)
038800150213      *            Severity Code (only I, W, =E, S or T)
038900150213      *            Severity Value (default=40)
039000150211      *            Position From (0=whole line, otherwise start of token in error)
039100150211      *            Position To (0=whole line, otherwise end of token in error)
039200150211      *       Output parms:
039300150211      *            None
039400150211      *       Return Value:
039500150211      *            None
039600150211      *===============================================================
039700150211      * Modified by BaileyP to pass extra parameters into events file
039800150211      *===============================================================
039900150212     p #wrtEvtFileError...
040000150212     p                 b
040100150211      *===============================================================
040200150212     d #wrtEvtFileError...
040300150211     d                 pi
040400150211     d  msgid                         7a   const
040500150211     d  msgtext                     999a   const options(*varsize)
040600150211     d  errAnnot                      1s 0 const options(*nopass)
040700150211     d  errLine                       6s 0 const options(*nopass)
040800150211     d  errSevVal                     2s 0 const options(*nopass)
040900150211     d  errSevCode                    1a   const options(*nopass)
041000150211     d  errPosFrom                    3s 0 const options(*nopass)
041100150211     d  errPosTo                      3s 0 const options(*nopass)
041200150211      *===============================================================
041300150211     d msgtextlen      s              3s 0 inz
041400150211     d msgtextlena     s              3a   inz
041500150211     d msgtextvar      s            999a   inz varying
041600150211     d
041700150211     d optParm         s              2p 0 inz(3)
041800150211     d errAnnotA       s              1a   inz('0')
041900150211     d errLineA        s              6a   inz('000000')
042000150211     d errSevA         s              2a   inz('40')
042100150211     d errSevC         s              1a   inz('E')
042200150211     d errPosFromA     s              3a   inz('000')
042300150211     d errPosToA       s              3a   inz('000')
042400150211      *===============================================================
042500150211      /free
042600150211
042700150213       optParm = 3; // First optional parameter
042800150213       if %parms() >= optParm ; // Annotation
042900150213         if errAnnot >= 0 and errAnnot <= 2;
043000150213           errAnnotA = %EditC(errAnnot: 'X');
043100150213         endif;
043200150213         optParm += 1;
043300150213       EndIf;
043400150213       if %parms() >= optParm ; // Error line
043500150213         errLineA = %EditC(errline: 'X');
043600150213         optParm += 1;
043700150213       EndIf;
043800150213       if %parms() >= optParm ; // Severity value
043900150213         errSevA = %EditC(errSevVal: 'X');
044000150213         optParm += 1;
044100150213       EndIf;
044200150213       if %parms() >= optParm ; // Severity code
044300150213         if %CHECK('IWEST': errSevCode) = 0;
044400150213           errSevC = errSevCode;
044500150213         ElseIf errSevCode = ' ';
044600150213           Select;
044700150213             When errSevVal >= 40;
044800150213               errSevC = 'T';
044900150213             When errSevVal >= 30;
045000150213               errSevC = 'S';
045100150213             When errSevVal >= 20;
045200150213               errSevC = 'E';
045300150213             When errSevVal >= 10;
045400150213               errSevC = 'W';
045500150213             Other;
045600150213               errSevC = 'I';
045700150213           EndSl;
045800150213         EndIf;
045900150213         optParm += 1;
046000150213       EndIf;
046100150213       if %parms() >= optParm ; // Start position of token in error
046200150213         errPosFromA = %EditC(errPosFrom: 'X');
046300150213         optParm += 1;
046400150213       EndIf;
046500150213       if %parms() >= optParm ; // End position of token in error
046600150213         errPosToA = %EditC(errPosTo: 'X');
046700150213         optParm += 1;
046800150213       EndIf;
046900150211
047000150213       // Determine Message Text Length
047100150213       msgtextvar  = %trim(msgtext);
047200150213       msgtextlen  = %len(msgtextvar);
047300150213       msgtextlena = %editc(msgtextlen:'X');
047400150211
047500150213       EXEC SQL
047600150213        INSERT
047700150213          INTO qtemp/evtfilembr
047800150213        VALUES ('ERROR      1 001 ' ||
047900150213                :errannota || ' ' ||
048000150213                :errlinea || ' ' ||
048100150213                :errlinea || ' ' ||
048200150213                :errposfroma || ' ' ||
048300150213                :errlinea || ' ' ||
048400150213                :errpostoa || ' ' ||
048500150213                :msgid || ' ' ||
048600150213                :errsevc || ' ' ||
048700150213                :errseva || ' ' ||
048800150213                :msgtextlena || ' ' ||
048900150213                :msgtextvar);
049000150213
049100150213       return;
049200150211
049300150211      /end-free
049400150213     p                 e
049500150211      *===============================================================
049600150212
049700150212
049800150212      *===============================================================
049900150212      *  Procedure:   #wrtEvtFileFileEnd - Write FileEnd Format
050000150211      *       Input parms:
050100150211      *            None
050200150211      *       Output parms:
050300150211      *            None
050400150211      *       Return Value:
050500150211      *            None
050600150211      *===============================================================
050700150212     p #wrtEvtFileFileEnd...
050800150212     p                 b
050900150211      *===============================================================
051000150212     d #wrtEvtFileFileEnd...
051100150211     d                 pi
051200150211      //===============================================================
051300150211      /FREE
051400150211       EXEC SQL
051500150211        INSERT
051600150211          INTO qtemp/evtfilembr
051700150211        VALUES ('FILEEND    1 001 000000');
051800150213
051900150212       EXEC SQL
052000150212         DROP ALIAS qtemp/evtfilembr ;
052100150211
052200150213       return;
052300150211
052400150211      /end-free
052500150211     p                 e
052600150211      *===============================================================
052700150211
052701160120      *===============================================================
052702160120      * From http://www.scottklement.com/rpg/ifs_ebook/errors.html
052703160120      *
052704160120      * Kill the program, sending an error message to the message queue
052705160120      *===============================================================
052706160120     P EscErrno        B
052707160120     D EscErrno        PI             1N
052708160120     D   errnum                      10i 0 value
052709160120
052710160120     D QMHSNDPM        PR                  ExtPgm('QMHSNDPM')
052711160120     D   MessageID                    7A   Const
052712160120     D   QualMsgF                    20A   Const
052713160120     D   MsgData                      1A   Const
052714160120     D   MsgDtaLen                   10I 0 Const
052715160120     D   MsgType                     10A   Const
052716160120     D   CallStkEnt                  10A   Const
052717160120     D   CallStkCnt                  10I 0 Const
052718160120     D   MessageKey                   4A
052719160120     D   ErrorCode                  256A
052720160120
052721160120     D dsEC            DS
052722160120     D  dsECBytesP             1      4I 0 inz(%size(dsEC))
052723160120     D  dsECBytesA             5      8I 0 inz(0)
052724160120     D  dsECMsgID              9     15
052725160120     D  dsECReserv            16     16
052726160120     D  dsECMsgDta            17    256
052727160120
052728160120     D TheKey          S              4A
052729160120     D MsgID           S              7A
052730160120
052731160120     c                   move      errnum        MsgID
052732160120     c                   movel     'CPE'         MsgID
052733160120
052734160120     c                   callp     QMHSNDPM(MsgID: 'QCPFMSG   *LIBL':
052735160120     c                               ' ': 0: '*ESCAPE':
052736160120     c                               '*': 3: TheKey: dsEC)
052737160120
052738160120     c                   return    *off
052739160120     P                 E
052740160120      *===============================================================
052741160120     P errno           B
052742160120     D errno           PI            10I 0
052743160120     D p_errno         S               *
052744160120     D retval          S             10I 0 based(p_errno)
052745160120     c                   eval      p_errno = @__errno
052746160120     c                   return    retval
052747160120     P                 E
052748160120
052800160120      * ==============================================================
052801160120      * Return the difference (in seconds) of the current time and the UTC time
052802160120      * ==============================================================
052803160120     P Get_UTC_Offset  b
052804160120     D Get_UTC_Offset  pi            10i 0
052805160120
052806160120     D CEEUTCO         pr                  extproc('CEEUTCO')
052807160120     D   Hours                       10i 0
052808160120     D   Minutes                     10i 0
052809160120     D   Seconds                      8f
052810160120     D   FC                          12a   options(*omit)
052811160120
052812160120     D UTC_Hours       s             10i 0
052813160120     D UTC_Minutes     s             10i 0
052814160120     D UTC_Seconds     s              8f
052815160120
052816160120      /free
052817160120
052818160120          CEEUTCO (UTC_Hours: UTC_Minutes: UTC_Seconds: *omit);
052819160120          return %int(UTC_Seconds);
052820160120
052821160120      /end-free
052822160120     P                 e
052823160120      * ===============================================================
052824160120      * Create a time stamp from an API's "number of seconds since Unix Epoch"
052825160120      * ===============================================================
052826160120     P ToTime          b
052827160120     D ToTime          pi              z
052828160120     D  inSeconds                    10i 0 value
052829160120
052831160120     D Epoch           s               z   inz(z'1970-01-01-00.00.00')
052832160120      /free
052833160120
052835160120          return Epoch + %seconds(inSeconds) + %seconds(Get_UTC_Offset());
052836160120
052837160120      /end-free
052838160120     P                 e
052839160120
052849160120
052900150213
053000150213
