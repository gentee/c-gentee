/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: bcodes 18.10.06 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
* Summary: Working with lexems
*
******************************************************************************/

#ifndef _BCODES_
#define _BCODES_

   #ifdef __cplusplus               
      extern "C" {                 
   #endif // __cplusplus   

#include "lexem.h"
#include "func.h"

/*-----------------------------------------------------------------------------
*
* ID: bcflag 19.10.06 0.0.A.
* 
* Summary: The structure for bc_flag function
*  
-----------------------------------------------------------------------------*/

typedef struct
{
   uint        value;       // The value of flags
   s_desctype  index;       // For index flag
   s_desctype  inherit;     // For inherit flag
   uint        alias;       // For alias flag - id of the created alias
} bcflag, * pbcflag;

/*-----------------------------------------------------------------------------
*
* ID: bflags 03.11.06 0.0.A.
* 
* Summary: flags for bc_flag -> type
*
-----------------------------------------------------------------------------*/

#define BFLAG_DEFINE  0x1  // define command
#define BFLAG_FUNC    0x2  // func operator method property command
#define BFLAG_IMPORT  0x4  // import command
#define BFLAG_TYPE    0x8  // type command

/*-----------------------------------------------------------------------------
*
* ID: bc_getid 03.11.06 0.0.A.
* 
* Summary: Get an id of vm 
*
-----------------------------------------------------------------------------*/

plexem  STDCALL bc_flag( plexem plex, uint type, pbcflag bcf );
uint    STDCALL bc_getid( plexem plex );
uint    STDCALL bc_type( plexem plex );
pvmfunc STDCALL bc_func( plexem plex, uint count, puint pars );
pvmfunc STDCALL bc_method( plexem plex, uint count, puint pars );
uint    CDECLCALL bc_find( plexem plexerr, pubyte name, uint count, ... );
pvmfunc STDCALL   bc_funcname( plexem plexerr, pubyte name, uint count, puint pars );
//uint    STDCALL bc_obj( plexem plex );
//pvmfunc STDCALL bc_oper( plexem plex, uint srctype, uint desttype );
pvmfunc   STDCALL bc_oper( plexem plex, uint srctype, uint desttype, 
                           uint srcof, uint destof );

pvmfunc STDCALL bc_property( plexem plex, uint objtype, uint setpar );
pvmfunc STDCALL bc_isproperty( plexem plex, uint objtype );
uint    STDCALL bc_resource( pubyte ptr );

//--------------------------------------------------------------------------

   #ifdef __cplusplus              
      }                            
   #endif // __cplusplus

#endif // _BCODES_