000100
000101150211      * Originally from a "Four Hundred Guru" article on itjungle.com
000102150211      * <http://www.itjungle.com/fhg/fhg080404-story01.html>
000103150211
000104150213     DRUNSQLSCRR       PR                  ExtPgm('RUNSQLSCRR')
000105150213     D  p#SrcLib                     10A
000106150213     D  p#SrcFile                    10A
000107150213     D  p#SrcMember                  10A
000108160120     d  p#SrcStream                 540a
000109150213     D  p#Schema                     10A
000110150213     D  p#SrcMbrChg                  13A
000111150213      *
000112150213      *===============================================================
000113150213     d #crtEvtFileMbr...
000114150211     d                 pr
000115150211     d  objlib                       10a   const
000116150211     d  srclib                       10a   const
000117150211     d  srcfile                      10a   const
000118150211     d  srcmbr                       10a   const
000119150212     d  srcmbrc                      13a   const
000120160120      *===============================================================
000121160120     d #crtEvtFileMbr2...
000122160120     d                 pr
000123160120     d  objlib                       10a   const
000124160120     d  srcstmf                     540a   const
000126160120     d  srcmbr                       10a   const
000127160420     d  srcmbrc                      14a   const
000128150211      *===============================================================
000129150213     d #wrtEvtFileTimestamp...
000130150211     d                 pr
000131150211      *===============================================================
000132150213     d #wrtEvtFileProcessor...
000133150211     d                 pr
000134150211      *===============================================================
000135150213     d #wrtEvtFileFileID...
000136150211     d                 pr
000137150211     d  srclib                       10a   const
000138150211     d  srcfile                      10a   const
000139150211     d  srcmbr                       10a   const
000140150212     d  srcmbrc                      13a   const
000141160120      *===============================================================
000142160120     d #wrtEvtFileFileID2...
000143160120     d                 pr
000144160120     d  srcstmf                     540a   const
000145160420     d  srcmbrc                      14a   const
000146150211      *===============================================================
000147150213     d #wrtEvtFileError...
000148150211     d                 pr
000149150211     d  msgid                         7a   const
000150150211     d  msgtext                     999a   const options(*varsize)
000151150211     d  errAnnot                      1s 0 const options(*nopass)
000152150211     d  errLine                       6s 0 const options(*nopass)
000153150211     d  errSevVal                     2s 0 const options(*nopass)
000154150211     d  errSevCode                    1a   const options(*nopass)
000155150211     d  errPosFrom                    3s 0 const options(*nopass)
000156150211     d  errPosTo                      3s 0 const options(*nopass)
000157150211      *===============================================================
000158150213     d #wrtEvtFileFileEnd...
000159150211     d                 pr
000160150211
