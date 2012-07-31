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
* Summary: out
*
******************************************************************************/

#include "../genteeapi/gentee.h"
#include "../vm/vmload.h"
#include "lexem.h"

/*-----------------------------------------------------------------------------
*
* ID: out_addubyte 22.11.06 0.0.A.
* 
* Summary: Append a byte
*
-----------------------------------------------------------------------------*/

void STDCALL out_addubyte( uint val )
{
   buf_appendch( _compile->pout, ( ubyte )val );
}

/*-----------------------------------------------------------------------------
*
* ID: out_adduint 22.11.06 0.0.A.
* 
* Summary: Append a unsigned int
*
-----------------------------------------------------------------------------*/

uint STDCALL out_adduint( uint val )
{
	buf_appenduint( _compile->pout, val );
   return _compile->pout->use - sizeof( uint );
}

/*-----------------------------------------------------------------------------
*
* ID: out_addlong 22.11.06 0.0.A.
* 
* Summary: Append a long
*
-----------------------------------------------------------------------------*/

void STDCALL out_addulong( ulong64 val )
{
   buf_appendulong( _compile->pout, val );
}

/*-----------------------------------------------------------------------------
*
* ID: out_add2ui 22.11.06 0.0.A.
* 
* Summary: Append two unsigned ints
*
-----------------------------------------------------------------------------*/

void STDCALL out_add2uint( uint val1, uint val2 )
{
   out_adduint( val1 );
   out_adduint( val2 );
}

/*-----------------------------------------------------------------------------
*
* ID: out_addptr 22.11.06 0.0.A.
* 
* Summary: Append data with alignment.
*
-----------------------------------------------------------------------------*/

void STDCALL out_addptr( pubyte data, uint size )
{
   uint val;

   //Выравнивание до dword   
   buf_append( _compile->pout, data, size );
   buf_append( _compile->pout, ( pubyte )&val, 
                ( sizeof( uint ) - size & ( sizeof( uint ) - 1 ) ) & 3 );
}

/*-----------------------------------------------------------------------------
*
* ID: out_addbuf 22.11.06 0.0.A.
* 
* Summary: Append buf with alignment.
*
-----------------------------------------------------------------------------*/

void STDCALL out_addbuf( pbuf data )
{
   buf_add( _compile->pout, data );
}

/*-----------------------------------------------------------------------------
*
* ID: out_addname 22.11.06 0.0.A.
* 
* Summary: Append name.
*
-----------------------------------------------------------------------------*/

void STDCALL out_addname( pubyte data )
{
   buf_append( _compile->pout, data, mem_len( data ) + 1 );
}

/*-----------------------------------------------------------------------------
*
* ID: out_adduints 22.11.06 0.0.A.
* 
* Summary: Append  unsigned ints
*
-----------------------------------------------------------------------------*/

void CDECLCALL out_adduints( uint count, ... )
{
	puint data;
	va_list args;
	uint i;

	va_start( args, count );	   
	buf_expand( _compile->pout, sizeof( uint ) * count );   
	data = ( puint )( _compile->pout->data + _compile->pout->use );
	for ( i = 0; i < count; i++ )
	{		      
		*( data++ ) = ( uint )va_arg( args, uint );		      
	}   
   _compile->pout->use += sizeof( uint ) * count;     
   va_end( args );
}

/*-----------------------------------------------------------------------------
*
* ID: out_head 22.11.06 0.0.A.
* 
* Summary: Initializing out buffer
*
-----------------------------------------------------------------------------*/

void STDCALL out_head( uint type, uint flag, pubyte name )
{
   out_addubyte( type );

   if ( name )
      flag |= GHCOM_NAME;

   out_add2uint( flag, 0 );
   if ( name )
   {
      if ( type == OVM_BYTECODE || type == OVM_EXFUNC )
      {
         if ( flag & GHBC_METHOD || flag & GHBC_PROPERTY )
            out_addubyte( '@' );
         if ( flag & GHBC_OPERATOR )
            out_addubyte( '#' );
      }
      out_addname( name );
   }
}

/*-----------------------------------------------------------------------------
*
* ID: out_init 22.11.06 0.0.A.
* 
* Summary: Initializing out buffer
*
-----------------------------------------------------------------------------*/

void STDCALL out_init( uint type, uint flag, pubyte name )
{
   _compile->pout = &_compile->out;

   // Уменьшаем если слишком большой размер
   if ( buf_len( _compile->pout ) > 0x100000 )
      buf_alloc( _compile->pout, 0x20000 );

   buf_clear( _compile->pout );
   out_head( type, flag, name );
}

/*-----------------------------------------------------------------------------
*
* ID: out_finish 22.11.06 0.0.A.
* 
* Summary: Finish out buffer
*
-----------------------------------------------------------------------------*/

pubyte STDCALL out_finish( void )
{
   uint len = buf_len( _compile->pout );

   *( puint )( buf_ptr( _compile->pout ) + sizeof( uint ) + 1 ) = len;
//   print("Len=%i\n", len );
   return buf_ptr( _compile->pout );
}

/*-----------------------------------------------------------------------------
*
* ID: out_setuint 22.11.06 0.0.A.
* 
* Summary: Change a unsigned int
*
-----------------------------------------------------------------------------*/

void STDCALL out_setuint( uint off, uint val )
{
   *( puint )( buf_ptr( _compile->pout ) + off ) = val;
}

/*-----------------------------------------------------------------------------
*
* ID: out_addvar 22.11.06 0.0.A.
* 
* Summary: Append VARMODE
*
-----------------------------------------------------------------------------*/

void STDCALL out_addvar( ps_descid field, uint flag, pubyte data )
{
   povmtype ptype;
   uint     i, size = 0;

   out_adduint( field->idtype );
   out_addubyte( flag );
   if ( flag & VAR_NAME ) 
      out_addname( field->name );

   if ( flag & VAR_OFTYPE )
   {
      out_adduint( field->oftype );
   }
   if ( flag & VAR_DIM )
   {
      out_addubyte( field->msr );
      for ( i = 0; i < field->msr; i++ )
         out_adduint( field->msrs[ i ] );
   }

   if ( flag & VAR_DATA )
   {
      ptype = ( povmtype )PCMD( field->idtype );
      if ( ptype->vmo.flag & GHTY_STACK )
         buf_append( _compile->pout, data, ptype->size );
      else
      {
         size = flag & VAR_IDNAME ? mem_len( data ) + 1 : buf_len( ( pbuf )data );
         if ( ptype->vmo.id != TStr )
            out_adduint( size );

         if ( flag & VAR_IDNAME )
            buf_append( _compile->pout, data, size );
         else
            buf_add( _compile->pout, ( pbuf )data );
      }
//      print(" %i size = %x\n", flag, size );
   }
//   print("name=%s type=%i flag=%x\n", name, type, flag );
}

/*-----------------------------------------------------------------------------
*
* ID: out_addvar 17.01.08 0.0.A.
* 
* Summary: Append Debug Trace
*
-----------------------------------------------------------------------------*/
void STDCALL out_debugtrace( plexem curlex )
{
   if ( _compile->flag & CMPL_DEBUG )
   {  
      out_adduints( 3, 
         CDwload, 
         str_pos2line( _compile->cur->src, curlex->pos, 0 ) + 1, 
         CDbgTrace );
   }
}