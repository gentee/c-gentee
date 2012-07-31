/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: out 18.10.06 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
* Summary: define command
*
******************************************************************************/

#ifndef _OUT_
#define _OUT_

   #ifdef __cplusplus               
      extern "C" {                 
   #endif // __cplusplus   

//--------------------------------------------------------------------------

void STDCALL out_addubyte( uint val );
uint STDCALL out_adduint( uint val );
void STDCALL out_addulong( ulong64 val );
void CDECLCALL out_adduints( uint count, ... );
void STDCALL out_add2uint( uint val1, uint val2 );
void STDCALL out_init( uint type, uint flag, pubyte name );
void STDCALL out_head( uint type, uint flag, pubyte name );
pubyte STDCALL out_finish( void );
void STDCALL out_setuint( uint off, uint val );
void STDCALL out_addvar( ps_descid field, uint flag, pubyte data );
void STDCALL out_addptr( pubyte data, uint size );
void STDCALL out_addname( pubyte data );
void STDCALL out_addbuf( pbuf data );
void STDCALL out_debugtrace( plexem curlex );

//--------------------------------------------------------------------------

   #ifdef __cplusplus              
      }                            
   #endif // __cplusplus

#endif // _OUT_