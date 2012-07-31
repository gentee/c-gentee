#exe = 0
#norun = 0
#gefile = 1
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
* Author: Alexander Antypenko ( santy ) v. 1.01
*
******************************************************************************/

define 
{
 ERAR_END_ARCHIVE        =10
 ERAR_NO_MEMORY          =11
 ERAR_BAD_DATA           =12
 ERAR_BAD_ARCHIVE        =13
 ERAR_UNKNOWN_FORMAT     =14
 ERAR_EOPEN              =15
 ERAR_ECREATE            =16
 ERAR_ECLOSE             =17
 ERAR_EREAD              =18
 ERAR_EWRITE             =19
 ERAR_SMALL_BUF          =20
 ERAR_UNKNOWN            =21
 ERAR_MISSING_PASSWORD   =22

 // OpenMode
 RAR_OM_LIST             = 0
 RAR_OM_EXTRACT          = 1
 RAR_OM_LIST_INCSPLIT    = 2

 // File operation
 RAR_SKIP              = 0
 RAR_TEST              = 1
 RAR_EXTRACT           = 2
                       
 RAR_VOL_ASK           = 0
 RAR_VOL_NOTIFY        = 1

 RAR_DLL_VERSION       = 4

 UCM_CHANGEVOLUME      = 0
 UCM_PROCESSDATA       = 1
 UCM_NEEDPASSWORD      = 2

}

type RARHeaderData
{
  uint         ArcName
  uint         FileName
  uint	       Flags
  uint	       PackSize
  uint	       UnpSize
  uint	       HostOS
  uint	       FileCRC
  uint	       FileTime
  uint	       UnpVer
  uint	       Method
  uint	       FileAttr
  uint         CmtBuf
  uint	       CmtBufSize
  uint	       CmtSize
  uint	       CmtState
}


type RARHeaderDataEx
{
  uint          ArcName
  uint         ArcNameW
  uint          FileName
  uint         FileNameW
  uint	       Flags
  uint	       PackSize
  uint	       PackSizeHigh
  uint	       UnpSize
  uint	       UnpSizeHigh
  uint	       HostOS
  uint	       FileCRC
  uint	       FileTime
  uint	       UnpVer
  uint	       Method
  uint	       FileAttr
  uint          CmtBuf
  uint	       CmtBufSize
  uint	       CmtSize
  uint	       CmtState
  arr Reserved[[1024]] of uint
}


type RAROpenArchiveData
{
  uint	       ArcName
  uint         OpenMode
  uint         OpenResult
  uint         CmtBuf
  uint         CmtBufSize
  uint         CmtSize
  uint         CmtState
}

type RAROpenArchiveDataEx
{
  uint          ArcName
  uint         ArcNameW
  uint         OpenMode
  uint         OpenResult
  uint          CmtBuf
  uint         CmtBufSize
  uint         CmtSize
  uint         CmtState
  uint         Flags
  arr Reserved[32] of uint
}

import "unrar.dll" 
{
  uint RAROpenArchive(uint) -> _RAROpenArchive
  uint RAROpenArchiveEx(uint) -> _RAROpenArchiveEx
  int  RARCloseArchive(uint) -> _RARCloseArchive
  int  RARReadHeader(uint,uint) -> _RARReadHeader
  int  RARReadHeaderEx(uint,uint) -> _RARReadHeaderEx
  int  RARProcessFile(uint,int ,uint,uint) -> _RARProcessFile
  int  RARProcessFileW(uint,int,uint,uint) -> _RARProcessFileW
       RARSetCallback(uint,uint,uint) -> _RARSetCallback
       RARSetChangeVolProc(uint,uint)
       RARSetProcessDataProc(uint,uint)
       RARSetPassword(uint,uint) -> _RARSetPassword
  int  RARGetDllVersion() ->_RARGetDllVersion
} 

/*-----------------------------------------------------------------------------
* @syntax  [ RAROpenArchive(RAROpenArchiveData ArchiveData) ]
*
* @param ArchiveData RAROpenArchiveData structure
*
* @return Archive handle or NULL in case of error.
*
* Open RAR archive
-----------------------------------------------------------------------------*/
func uint RAROpenArchive(RAROpenArchiveData ArchiveData)
{
  return _RAROpenArchive(&ArchiveData)
}
 
/*-----------------------------------------------------------------------------
* @syntax  [ RAROpenArchiveEx(RAROpenArchiveDataEx ArchiveDataEx) ]
*
* @param ArchiveDataEx RAROpenArchiveDataEx structure
*
* @return Archive handle or NULL in case of error.
*
* Open RAR archive but uses RAROpenArchiveDataEx structure
* allowing to specify Unicode archive name and returning information
* about archive flags
-----------------------------------------------------------------------------*/
func uint RAROpenArchiveEx(RAROpenArchiveDataEx ArchiveDataEx)
{
  return _RAROpenArchiveEx(&ArchiveDataEx)
}
 
/*-----------------------------------------------------------------------------
* @syntax  [ RARCloseArchive(uint handleArc) ]
*
* @param handleArc archive handle obtained from the RAROpenArchive function call
*
* @return  0 - Success; $ERAR_ECLOSE - error.
*
* Close RAR archive
-----------------------------------------------------------------------------*/
func int RARCloseArchive(uint handleArc) : return _RARCloseArchive(handleArc)
 
/*-----------------------------------------------------------------------------
* @syntax  [ RARReadHeader(uint handleArc,RARHeaderData HeaderData) ]
*
* @param handleArc archive handle obtained from the RAROpenArchive function call
*
* @param HeaderData Pointer to RARHeaderData structure
*
* @return  0 - Success;   $ERAR_END_ARCHIVE   -   End of archive
*			  $ERAR_BAD_DATA      -   File header broken
*
* Read header of file in RAR archive
-----------------------------------------------------------------------------*/
func int RARReadHeader(uint handleArc,uint HeaderData)
{
  return  _RARReadHeader(handleArc,HeaderData)
}

/*-----------------------------------------------------------------------------
* @syntax  [ RARReadHeaderEx(uint handleArc,RARHeaderDataEx HeaderData) ]
*
* @param handleArc archive handle obtained from the RAROpenArchive function call
*
* @param HeaderData Pointer to RARHeaderDataEx structure
*
* @return  0 - Success;   $ERAR_END_ARCHIVE   -   End of archive
*			  $ERAR_BAD_DATA      -   File header broken
*
* Read header of file in RAR archive but uses RARHeaderDataEx structure
* containing information about Unicode file names
-----------------------------------------------------------------------------*/
func int RARReadHeaderEx(uint handleArc,uint HeaderData)
{
  return _RARReadHeaderEx(handleArc,HeaderData)
}

/*-----------------------------------------------------------------------------
* @syntax  [ RARProcessFile(uint handleArc,int operation,str destPath,str destName) ]
*
* @param handleArc archive handle obtained from the RAROpenArchive function call
* @param operation File operation
* @param destPath This parameter containing the destination directory to which to extract files to
* @param destName This parameter should a string containing the full path and name 
*                 to assign to extracted file or it can be NULL to use the default name
*
* @return  0 - Success;   
*  or
*  $ERAR_BAD_DATA         File CRC error
*  $ERAR_BAD_ARCHIVE      Volume is not valid RAR archive
*  $ERAR_UNKNOWN_FORMAT   Unknown archive format
*  $ERAR_EOPEN            Volume open error
*  $ERAR_ECREATE          File create error
*  $ERAR_ECLOSE           File close error
*  $ERAR_EREAD            Read error
*  $ERAR_EWRITE           Write error
*
* Performs action and moves the current position in the archive to 
*  the next file
-----------------------------------------------------------------------------*/
func int RARProcessFile(uint handleArc,int operation,str destPath,str destName)
{
  return _RARProcessFile(handleArc,operation,destPath.ptr(),destName.ptr())
}

/*-----------------------------------------------------------------------------
* @syntax  [ RARProcessFileW(uint handleArc,int operation,ustr destPath,ustr destName) ]
*
* @param handleArc archive handle obtained from the RAROpenArchive function call
* @param operation File operation
* @param destPath This parameter containing the destination directory to which to extract files to
* @param destName This parameter should a string containing the full path and name 
*                 to assign to extracted file or it can be NULL to use the default name
*
* @return  0 - Success;   
*  or
*  $ERAR_BAD_DATA         File CRC error
*  $ERAR_BAD_ARCHIVE      Volume is not valid RAR archive
*  $ERAR_UNKNOWN_FORMAT   Unknown archive format
*  $ERAR_EOPEN            Volume open error
*  $ERAR_ECREATE          File create error
*  $ERAR_ECLOSE           File close error
*  $ERAR_EREAD            Read error
*  $ERAR_EWRITE           Write error
*
* Unicode version of RARProcessFile 
* Performs action and moves the current position in the archive to 
*  the next file
-----------------------------------------------------------------------------*/
func int RARProcessFileW(uint handleArc,int operation,ustr destPath,ustr destName)
{
  return _RARProcessFileW(handleArc,operation,destPath.ptr(),destName.ptr())
}

/*-----------------------------------------------------------------------------
* @syntax  [ RARSetCallback(uint handleArc,uint callBackFunc,uint userData) ]
*
* @param handleArc Archive handle obtained from the RAROpenArchive function call
* @param callBackFunc User-defined callback function
* @param userData User data passed to callback function
*
* Set a user-defined callback function to process Unrar events
-----------------------------------------------------------------------------*/
func RARSetCallback(uint handleArc,uint callBackFunc,uint userData)
{
  uint addrFunc = callback(callBackFunc,4)
  _RARSetCallback(handleArc,addrFunc,userData)
}

/*-----------------------------------------------------------------------------
* @syntax  [ RARSetPassword(uint handleArc,str password) ]
*
* @param handleArc Archive handle obtained from the RAROpenArchive function call
* @param password String containing a zero terminated password
*
* Set a password to decrypt files.
-----------------------------------------------------------------------------*/
func RARSetPassword(uint handleArc,str password)
{
  _RARSetPassword(handleArc,password.ptr())
}
 

type rarfile
{
  str arcName
  RARHeaderData headerData
  RAROpenArchiveData openArchiveData
  uint errorCode 
  uint arcHandle
  uint headerData_ptr
}

method rarfile.init()
{
}

method int rarfile.open(str arcName)
{
  buf CmtBuf[16384]
  this.arcName = arcName
  mzero( &this.openArchiveData, sizeof( RAROpenArchiveData ))
  with this.openArchiveData
  {
   .ArcName=this.arcName.ptr()
   .CmtBuf=CmtBuf.ptr()
   .CmtBufSize=16384
   .OpenMode=$RAR_OM_EXTRACT
  }

  this.arcHandle=RAROpenArchive(this.openArchiveData)
  this.errorCode = this.openArchiveData.OpenResult
  if (this.openArchiveData.OpenResult == 0) : this.headerData_ptr  = malloc(sizeof( RARHeaderData ))
  return this.openArchiveData.OpenResult
}

method rarfile.close(str arcName)
{
  mfree(this.headerData_ptr)
  RARCloseArchive(this.arcHandle)
}

method int rarfile.readHeader()
{
  return RARReadHeader(this.arcHandle,this.headerData_ptr)
}

method int rarfile.processFile(int operation,str destpath,str destName)
{
  return RARProcessFile(this.arcHandle,operation,destpath,destName)
}

method arrstr rarfile.operationWithFiles<result>(int iOper)
{
  int RHCode,PFCode
  str sFileName
  arrstr retFlNames

  while ((RHCode=this.readHeader()) == 0)
  {
    sFileName.load(this.headerData_ptr+260,260).setlenptr()
    PFCode = this.processFile(iOper,"","")
    this.errorCode = PFCode
    if (PFCode != 0) : break
    else : retFlNames+=sFileName
    sFileName.clear()
  }
  result = retFlNames
}

method rarfile.extractFiles(arrstr extrNames) : extrNames = this.operationWithFiles($RAR_EXTRACT)
method rarfile.testFiles(arrstr testNames) : testNames = this.operationWithFiles($RAR_TEST)

method rarfile.setPassword(str passw) : RARSetPassword(this.arcHandle,passw)

method rarfile.openArchiveError()
{
  switch (this.errorCode)
  {
    case $ERAR_NO_MEMORY: print("\nNot enough memory")
    case $ERAR_EOPEN: print("\nCannot open " + this.arcName)
    case $ERAR_BAD_ARCHIVE: print("\n "+this.arcName+" is not RAR archive")
    case $ERAR_BAD_DATA: print("\n "+this.arcName+"  : archive header broken")
    case $ERAR_UNKNOWN:  print("Unknown error")
  }
}
