#exe = 1
#norun = 1
#gefile = 0
#libdir = %EXEPATH%\lib
#libdir1 = %EXEPATH%\..\lib\vis
#include = %EXEPATH%\lib\stdlib.ge
//#wait = 1
/******************************************************************************
*
* Copyright (C) 2009, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* Author: Alexander Antypenko ( santy )
*
******************************************************************************/

include 
{
   $"unrar.g"
}

define 
{
 EXTRACT, 
 TEST, 
 PRINT 
}

extern
{
 func OutProcessFileError(int iError)
 func ExtractArchive(str sArcName,int iMode, str strPsw)
}

func ShowComment(str cmtBuf)
{
  print("\nComment:\n " +cmtBuf+ " \n")
}


func OutHelp()
{
  print("\nUnrar_demo.   This is a simple example of UNRAR.DLL usage\n")
  print("\nSyntax:\n")
  print("\nUnrar_demo X <Archive> <psw>    extract archive contents")
  print("\nUnrar_demo T <Archive> <psw>    test archive contents")
  print("\nUnrar_demo P <Archive> <psw>    print archive contents to stdout \n\n")
}

func OutOpenArchiveError(int iError,str arcName)
{
  switch (iError)
  {
    case $ERAR_NO_MEMORY: print("\nNot enough memory")
    case $ERAR_EOPEN: print("\nCannot open " + arcName)
    case $ERAR_BAD_ARCHIVE: print("\n "+arcName+" is not RAR archive")
    case $ERAR_BAD_DATA: print("\n "+arcName+"  : archive header broken")
    case $ERAR_UNKNOWN:  print("Unknown error")
  }
}

// main programm

func unrar_demo <main>
{
  str sOption = "" ,sParam2, sPassword
  str dem1,dem2
  //print(" \(argc()) \(argv(dem1.upper(),1))  \(argv(dem2.upper(),2))\n")
  if (argc() != 2 )
  {
    OutHelp()
    exit(0)
  }
  else {
   argv(sOption,1)
   argv(sPassword,3)
   switch (sOption.upper())
   {
    case "X": ExtractArchive(argv(sParam2,2),$EXTRACT,sPassword)
    case "T": ExtractArchive(argv(sParam2,2),$TEST,sPassword)
    case "P": ExtractArchive(argv(sParam2,2),$PRINT,sPassword)
    default
     {
      OutHelp()
      exit(0)
     }
   }
  }
}


func OutProcessFileError(int iError)
{
  switch(iError)
  {
    case $ERAR_UNKNOWN_FORMAT: print("Unknown archive format")
    case $ERAR_BAD_ARCHIVE:    print("Bad volume")
    case $ERAR_ECREATE:        print("File create error")
    case $ERAR_EOPEN:          print("Volume open error")
    case $ERAR_ECLOSE:         print("File close error")
    case $ERAR_EREAD:          print("Read error")
    case $ERAR_EWRITE:         print("Write error")
    case $ERAR_BAD_DATA:       print("CRC error")
    case $ERAR_UNKNOWN:        print("Unknown error")
    case $ERAR_MISSING_PASSWORD: print("Password for encrypted file is not specified")
  }
}

func ExtractArchive(str sArcName,int iMode, str strPsw)
{
  uint hArcData
  int RHCode,PFCode
  buf CmtBuf[16384]
  str cmtBufHeader[255]
  str sFileName,sTempStr
  RARHeaderData HeaderData
  RAROpenArchiveData OpenArchiveData

  mzero( &OpenArchiveData, sizeof( RAROpenArchiveData ))
  with OpenArchiveData
  {
   .ArcName=sArcName.ptr()
   .CmtBuf=CmtBuf.ptr()
   .CmtBufSize=16384
   .OpenMode=$RAR_OM_EXTRACT
  }

  hArcData=RAROpenArchive(OpenArchiveData)
  if (OpenArchiveData.OpenResult != 0)
  {
    OutOpenArchiveError(OpenArchiveData.OpenResult,sArcName)
    return
  }

  if (OpenArchiveData.CmtState==1) : ShowComment(sTempStr.copy(CmtBuf.ptr()))

  if  strPsw != "" : RARSetPassword(hArcData,strPsw)

  uint HeaderData_ptr  = malloc(sizeof( RARHeaderData ))
  while ((RHCode=RARReadHeader(hArcData,HeaderData_ptr)) == 0)
  {
    sFileName.load(HeaderData_ptr+260,260).setlenptr()
    switch(iMode)
    {
      case $EXTRACT: print("\nExtracting "+sFileName)
      case $TEST:    print("\nTesting "+ sFileName ) 
      case $PRINT:   print("\nPrinting "+ sFileName+" \n")
    }
    PFCode = RARProcessFile(hArcData, ?(iMode==$EXTRACT,$RAR_EXTRACT,$RAR_TEST),"","")
    if (PFCode == 0) : print(" Ok \n")
    else
    {
      OutProcessFileError(PFCode)
      break
    }
  }
  if (RHCode == $ERAR_BAD_DATA) : print("\nFile header broken")
  mfree(HeaderData_ptr)
  RARCloseArchive(hArcData);
}
