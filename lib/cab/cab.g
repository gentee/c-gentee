/******************************************************************************
*
* Copyright (C) 2009, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* Author: Alexey Krivonogov ( gentee )
*
******************************************************************************/

type ERF
{
    int     erfOper
    int     erfType
    uint    fError
} 

import "kernel32"
{
   uint DosDateTimeToFileTime( ushort, ushort, filetime )
}

type cabinfo
{
   ERF      erf
   uint     lztype
   
   uint     call
   uint     pattern     
   
   uint     fnctempfile
   uint     fncnotify
   uint     fncsysnotify
      
   uint     finish       // 1 if finish for progress
   uint     cabsize
   uint     filesize
   uint     percent
   
   ulong    summarysize
}

define
{
   // Notify codes
   FLN_ERROR     = 1
   FLN_FILEBEGIN = 2
   FLN_FILEEND   = 3
   FLN_ERROPEN   = 4
   FLN_PROGRESS  = 5
   FLN_NOTVALID  = 6  // Not CAB file
   FLN_NEXTVOLUME = 7
   FLN_START     = 8
}

import "cab2g.dll"<link>
{  
   uint gcabe_addfile( uint, uint, uint, cabinfo )
   uint gcabe_close( uint )
   uint gcabe_create( uint, uint )
   uint gcabe_flushfolder( uint )
   uint gcabd_create( uint )
   uint gcabd_destroy( uint )
   uint gcabd_iscabinet( uint, uint, uint )
   uint gcabd_copy( uint, uint, uint, uint )
}

include : $"cabencode.g"
include : $"cabdecode.g"

