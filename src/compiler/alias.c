/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: alias 06.07.07 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
* Summary: alias
*
******************************************************************************/

#include "../vm/vm.h"
#include "../vm/vmload.h"
#include "lexem.h"
#include "out.h"

/*-----------------------------------------------------------------------------
*
* ID: alias_add 06.07.07 0.0.A.
* 
* Summary: Adding alias
*
-----------------------------------------------------------------------------*/

plexem  STDCALL alias_add( plexem plex, puint id )
{
   pubyte    pout;//, pdata;

   out_init( OVM_ALIAS, GHCOM_NAME, lexem_getname( plex ));
   out_adduint( 0 );
   pout = out_finish();
   *id = load_alias( &pout )->id;
   
   return lexem_next( plex, LEXNEXT_IGNLINE );
}

