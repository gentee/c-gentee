/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: msg 18.10.06 0.0.A.
*
* Author: Alexey Krivonogov
*
* Summary: Message functions.
*
******************************************************************************/

#include "../os/user/defines.h"
#include "../genteeapi/gentee.h"
#include "msg.h"
#include "../compiler/lexem.h"

#ifndef RUNTIME
   #include <setjmp.h> 
   extern jmp_buf stack_state;
#endif
   #include <stdio.h>
   #include <stdarg.h>
uint _time;

/*-----------------------------------------------------------------------------
*
* ID: msg 23.10.06 0.0.A.
* 
* Summary: Show an error or information message
*
-----------------------------------------------------------------------------*/

uint CDECLCALL msg( uint code, ... )
{
   va_list args;
   msginfo minfo;
   plexem  plex;

   mem_zero( &minfo, sizeof( msginfo ));
   minfo.flag = code & 0xFFFF0000;
   minfo.code = code & 0xFFFF;

   va_start( args, code );

   if ( code & MSG_STR )
      minfo.namepar = str_ptr(( pstr )va_arg( args, int ));
   if ( code & MSG_POS || code & MSG_LEXEM )
      plex = ( plexem )va_arg( args, int );
   if ( code & MSG_VALSTR )
      minfo.namepar = ( pubyte )va_arg( args, int );
   if ( code & MSG_VALUE )
      minfo.uintpar = ( uint )va_arg( args, int );

#ifndef RUNTIME
   if ( code & MSG_LEXNAME )
   {
      minfo.namepar = 0;
      switch ( plex->type )
      {
         case LEXEM_OPER: 
            minfo.namepar = ( pubyte )&plex->oper.name;
            break;
         case LEXEM_NAME: 
         case LEXEM_MACRO: 
            minfo.namepar = ( pubyte )lexem_getname( plex );
            break;
      }
      minfo.flag |= MSG_STR;
   }
#endif
//   for ( i = 0; i < 8; i++ )
//      pars[i] = ( uint )va_arg( args, int );
   va_end( args );  

   if ( _compile && _compile->cur )
   {
      // Лишнее ???
      if ( _compile->cur->src->use > _pvm->pos )
         minfo.line = str_pos2line( _compile->cur->src, _pvm->pos, &minfo.pos );
      if ( minfo.flag & MSG_POS )
      {
         minfo.line = str_pos2line( _compile->cur->src, ( uint )plex, &minfo.pos );
      }
      if ( minfo.flag & MSG_LEXEM )
         minfo.line = str_pos2line( _compile->cur->src, plex->pos, &minfo.pos );
      minfo.filename = str_ptr( _compile->cur->filename ); 
      minfo.line++;
      minfo.pos++;
   }
   minfo.pattern = msgtext[ minfo.code ];

   if ( _gentee.message )
      _gentee.message( &minfo );

   if ( minfo.flag & MSG_EXIT )
   {
      if ( _compile )
         os_dirsetcur( _compile->curdir );
      if ( !_compile || _compile->flag & CMPL_THREAD )
         os_exitthread( 0 );
#ifndef RUNTIME
      else
//         os_exitthread( 0 );
         longjmp( stack_state, -1 );
#endif
   }
   return 1;	
}

/*-----------------------------------------------------------------------------
*
* ID: print 26.12.06 0.0.A.
* 
* Summary: Print function for debugging
*
-----------------------------------------------------------------------------*/

void  CDECLCALL print( pubyte output, ... ) 
{
   va_list args;
   uint    len;
   ubyte   ok[ 512 ];

   va_start( args, output );
   len = vsprintf( ok, output, args );
   va_end( args );
   _gentee.print( ok, len );
//   os_print( ok, len );
}

uint STDCALL message( pmsginfo minfo )
{
   uint      temp, time;
   uint      line = 0, pos = 0;

   if ( minfo->flag & MSG_EXIT )
   {
      print( _compile ? "Compile error [ 0x%X %i ]: " :
            "Run-time error [ 0x%X %i ]: ", minfo->code, minfo->code ); 
      if ( minfo->line )
         print( "%s\r\n[ Line: %i Pos: %i ] ", minfo->filename, 
                 minfo->line, minfo->pos ); 
   }
   else 
      if ( _gentee.flags & G_SILENT )
         return 0;

   if ( minfo->flag & MSG_VALSTR )
      print( minfo->pattern, minfo->uintpar, minfo->uintpar, minfo->namepar ); 
   else
      if ( minfo->flag & MSG_VALVAL )
         print( minfo->pattern, minfo->uintpar, minfo->uintpar ); 
      else
         if ( minfo->flag & MSG_STR )
            print( minfo->pattern, minfo->namepar ); 
         else
            if ( minfo->flag & MSG_VALUE )
               print( minfo->pattern, minfo->uintpar ); 
            else
               print( minfo->pattern );
   print( "\r\n" );

   switch ( minfo->code )
   {
      case MStart:
         _time = os_time();
         break;
      case MEnd:
         time = os_time() - _time;
         temp = time % 60000;
         print( "Summary Time: %i:%i:%i\r\n", 
                  time / 60000, temp / 1000, temp % 1000 );
         break;
   }
//   if ( !( _gentee.flags & G_SILENT ) || minfo->flag & MSG_EXIT )
//       str_output( minfo->result );

   if ( minfo->flag & MSG_EXIT )
   {
      print( "\r\nPress any key...\r\n" );
      os_getchar();
   }
   return 0;
}
