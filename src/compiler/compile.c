/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: compile 18.10.06 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
******************************************************************************/

#include "compile.h"
#include "../lex/lex.h"
#include "../lex/lexgentee.h"
#include "../genteeapi/gentee.h"
#include "../common/file.h"
#include "../common/hash.h"
#include "../bytecode/ge.h"
#include "lexem.h"
#include "operlist.h"
#include "define.h"
#include "macro.h"
#include "compinit.h"
#include "include.h"
#include "import.h"
#include "global.h"

#include <setjmp.h> 
jmp_buf stack_state;

//----------------------------------------------------------------------------

extern const uint lexgentee[];

/*-----------------------------------------------------------------------------
*
* ID: compile_process 23.10.06 0.0.A.
* 
* Summary: The main gentee compile function
*
-----------------------------------------------------------------------------*/

uint STDCALL compile_process( pstr filename )
{
   pcompilefile   prev;
   compilefile    cmpfile;
   arr            lexout;
   arr            lexems;
   pstr      stemp;
   pstr      dir;
   pubyte    input;
   plexem    plex;
   pvmobj    pvmo;
   uint      i;

//   plexem    pil;
//   ubyte  idname[ 32 ];  // delete
//   pcompile  pcmp = _gentee.compile;

   prev = _compile->cur;

   mem_zero( &cmpfile, sizeof( compilefile ));
   cmpfile.src = str_new( str_ptr( filename ));
   cmpfile.filename = str_new( 0 );

   dir = str_new( 0 );
   stemp = str_new( 0 );

   if ( _compile->flag & CMPL_SRC )
      _compile->flag &= ~CMPL_SRC;
   else
   {
      os_filefullname( filename, cmpfile.filename );
      if ( hash_find( &_compile->files, str_ptr( cmpfile.filename )))
         goto end;

      os_dirgetcur( dir );
      file2buf( filename, cmpfile.src, prev ? prev->pos : 0  );
      os_filefullname( filename, cmpfile.filename );
      if ( hash_find( &_compile->files, str_ptr( cmpfile.filename )))
         goto end;

      hash_create( &_compile->files, str_ptr( cmpfile.filename ));
      // Set a new directory
      str_getdirfile( filename, stemp, 0 );
      os_dirsetcur( stemp );
   }

   _compile->cur = &cmpfile;
   _compile->cur->idfirst = _vm.count;

//   print("First=%i\n", _compile->cur->idfirst );
   if ( *( puint )str_ptr( cmpfile.src ) == GE_STRING )
   {
      msg( MLoad | MSG_STR, cmpfile.filename );
      // Загружаем байт-код из откомпилированного файла
      ge_load( cmpfile.src );
//  ???   Обнуление смещения vm->curoff проиcходит в конце gentee_load
      goto end;
   }
   msg( MLoad | MSG_STR, cmpfile.filename );
   _compile->flag &= ~CMPL_LINE;

   // Adding zero character
   buf_appendch( cmpfile.src, 0 );

   input = str_ptr( cmpfile.src );
   // Ignoring all first strings beginning with #
   while ( input[ cmpfile.off ] == '#' )
   {
      while ( input[ cmpfile.off ] && input[ cmpfile.off ] != 0xA )
         cmpfile.off++;
      if ( input[ cmpfile.off ] == 0xA )
         cmpfile.off++;
   }
   input += cmpfile.off;
   // The first pass
   arr_init( &lexout, sizeof( lexitem ));

   gentee_lexptr( input, &_compile->ilex, &lexout );

   _compile->cur->lexems = &lexems;
   // The second pass and generating an array of lexems
   lexem_load( &lexems, &lexout );

/*   for ( i = 0; i < arr_count( &lexems ); i++ )
   {
      pil = ( plexem )arr_ptr( &lexems, i );
      printf("Type = %i pos = %i ", pil->type, pil->pos );
      switch ( pil->type )
      {
         case LEXEM_BINARY:
            printf( "binary= %s", str_ptr( lexem_getstr(  pil )));
            break;
         case LEXEM_FILENAME:
            printf( "filename= %s", str_ptr( lexem_getstr( pil )));
            break;
         case LEXEM_STRING:
            printf( "string= %s len = %i", str_ptr( lexem_getstr(  pil )), 
                     str_len( lexem_getstr(  pil )));
            break;
         case LEXEM_MACRO:
            printf( "macro= %s", hash_name( &_compile->names, pil->macroid ));
            break;
         case LEXEM_NAME:
            printf( "name= %s", hash_name( &_compile->names, pil->nameid ));
            break;
         case LEXEM_KEYWORD:
            printf( "keyword = %i", pil->key );
            break;
         case LEXEM_OPER:
            printf( "oper= %s id=%i", &pil->oper.name, pil->oper.operid );
            break;
         case LEXEM_NUMBER:
            printf( "number = " );
            switch ( pil->num.type )
            {
               case TUint:
                  printf( "+%lu", pil->num.vint );
                  break;
               case TInt:
                  printf( "%i", pil->num.vint );
                  break;
               case TUlong:
                  printf( "+%sL", _ui64toa( pil->num.vlong, &idname, 10 ));
                  break;
               case TLong:
                  printf( "%sL", _i64toa( pil->num.vlong, &idname, 10 ));
                  break;
               case TFloat:
                  printf( "F%e", pil->num.vfloat  );
                  break;
               case TDouble:
                  printf( "D%e", pil->num.vdouble  );
                  break;
               }
            break;
      }
      printf("\n" );
   }
*/
   plex = 0;
//   print("Before "); memstat();
   while ( plex = lexem_next( plex, LEXNEXT_NULL | LEXNEXT_IGNLINE ))
   {
      if ( plex->type == LEXEM_KEYWORD )
      {
         switch ( plex->key ) {
            case KEY_DEFINE:
               plex = define( plex );
               break;
            case KEY_GLOBAL:
               plex = global( plex );
               break;
//            case KEY_IFDEF:  // check in lexem_next
//               break;
            case KEY_IMPORT:
               plex = import( plex );
               break;
            case KEY_INCLUDE:
               plex = include( plex );
               break;
            case KEY_TYPE:
               plex = type( plex );
               break;
				case KEY_OPERATOR:
				case KEY_METHOD:
            case KEY_FUNC:
				case KEY_TEXT:
				case KEY_PROPERTY:
               plex = m_func( plex, 0 );
               break;
            case KEY_PRIVATE:
               _compile->cur->priv = 1;
               break;
            case KEY_PUBLIC:
               _compile->cur->priv = 0;
               break;
            case KEY_EXTERN:
               plex = m_extern( plex );
               break;
            default:
               msg( MUnkcmd | MSG_LEXNAMEERR, plex );
               break;
         }
      }
      else
         msg( MUnkcmd | MSG_LEXNAMEERR, plex );
   }
   // Proceed private public protected
   for ( i = _compile->cur->idfirst; i < _vm.count; i++ )
   {
      pvmo = ( pvmobj )PCMD( i );
      if ( pvmo->flag & GHRT_INCLUDED )
         continue;
      if ( pvmo->type == OVM_TYPE && pvmo->flag & GHTY_PROTECTED )
         type_protect( ( povmtype )pvmo );
      if ( pvmo->flag & GHRT_PRIVATE )   
         vm_clearname( i );
      // Надо добавить для глобальных переменных !!! ???

      pvmo->flag |= GHRT_INCLUDED;
   }
   
   lexem_delete( &lexems );
   arr_delete( &lexout );
end:

   if ( str_len( dir ))
      os_dirsetcur( dir );
   str_destroy( cmpfile.src );
   str_destroy( cmpfile.filename );
   str_destroy( dir );
   str_destroy( stemp );
   _compile->cur = prev;

   return 1;
}

/*-----------------------------------------------------------------------------
*
* ID: gentee_compile 23.10.06 0.0.A.
* 
* Summary: The public compile function
*
-----------------------------------------------------------------------------*/
//uint  STDCALL gentee_compile( pcompileinfo compinit )
uint  STDCALL thread_compile( pcompileinfo compinit )
{
   compile   icompile;
   pstr      data;//, src;
   uint      i;
   pubyte    ptr;
   buf       stack;
 //  pstr      src;

   if ( setjmp( stack_state ) == -1 ) 
      return FALSE;

//   if ( !getenv("GNUMSIGN") )
      msg( MStart );
//   else
//      _time = os_time();

   initcompile();
//   memstat();
   _vm.loadmode = 1;
   mem_zero( &icompile, sizeof( compile ));
   _compile = &icompile;

   icompile.curdir = str_new( 0 );
   os_dirgetcur( icompile.curdir );
   
   if ( compinit->flag & CMPL_OPTIMIZE )
      _compile->popti = &compinit->opti;

   icompile.flag = compinit->flag;
   data = str_new( compinit->input );
   buf_init( &stack );
   buf_reserve( &stack, (( STACK_OPERS + STACK_OPS ) << 1 ) + STACK_PARS );//0xFFFF << 1 );

   arrdata_strload( arrdata_init( &icompile.libdirs ), compinit->libdirs );
   hash_init( &icompile.files, sizeof( uint ));
   hash_init( &icompile.names, sizeof( uint ));
   hash_init( &icompile.resource, sizeof( uint ));
   hash_init( &icompile.opers, sizeof( uint ));
   hash_init( &icompile.macros, sizeof( macro ));
   hash_init( &icompile.namedef, sizeof( macro ));

   arrdata_init( &icompile.string );
   arrdata_init( &icompile.binary );
   icompile.files.ignore = 1;
   lex_init( &icompile.ilex, ( puint )&lexgentee );
   icompile.stkopers = buf_ptr( &stack );
   icompile.stkops = ( pubyte )icompile.stkopers + STACK_OPERS;//0xFFFF;
   icompile.stkpars = ( pubyte )icompile.stkops + STACK_OPS;//0xFFFF;
   icompile.stkmopers = ( pubyte )icompile.stkpars + STACK_PARS;//0xFFFF;
   icompile.stkmops = ( pubyte )icompile.stkmopers + STACK_OPERS;//0xFFFF;
   ptr = ( pubyte )&operlexlist;
   // Loading hash of operators
   for ( i = 0; i < OPERCOUNT; i++ )
   {
      if ( *ptr )
      {
         hash_setuint( &icompile.opers, ptr, i );
         ptr += mem_len( ptr );
      }
      ptr++;
   }
   macro_init();

/*#ifndef LINUX
   src = str_new( 0 );
   if ( icompile.flag & CMPL_SRC )
      str_copy( src, data );
   else
      file2buf( data, src, 0  );

   //   print( "CMD LINE=%s\n",str_ptr( cmpfile.src ) );
//   getch();
   if ( *( pushort )str_ptr( src ) == 0x2123 && 
        _compile->flag & CMPL_LINE && !getenv("GNUMSIGN"))
   {
      ubyte   cmdline[512];
      pubyte  cur;
      pubyte  input = str_ptr( src ) + 2;
      PROCESS_INFORMATION  stpi;
      STARTUPINFO          start;
      
      ZeroMemory( &stpi, sizeof( PROCESS_INFORMATION ));
      ZeroMemory( &start, sizeof( STARTUPINFO ));
      start.cb = sizeof( STARTUPINFO );

      cur = ( pubyte )&cmdline;
      while ( *input >= ' ' )
      {
         if ( *input == '%' && *( input + 1 ) == '1' )
         {
            mem_copyuntilzero( cur, str_ptr( data ));
            cur += mem_len( cur );
            input += 2;
         }
         else
            *cur++ = *input++;
      }
      *cur = 0;
      _putenv("GNUMSIGN=1");
//      print( "CMD LINE=%s\n",cmdline );
      CreateProcess( 0, cmdline, 0, 0, TRUE,
                     CREATE_DEFAULT_ERROR_MODE | NORMAL_PRIORITY_CLASS, 
                     0, 0, &start, &stpi );
      ExitProcess( 0 );
   }
   str_destroy( src );
#endif*/

   if ( *compinit->defargs || *compinit->include )
   {
      pstr  stemp = str_new( "" );
      pstr  include = str_new( "" );
      pstr  dargs = str_new( "" );
      pubyte  cur, src;
      
      str_reserve( stemp, 1024 );
      str_reserve( include, 1024 );
      str_reserve( dargs, 1024 );
      
      if ( *compinit->include )
      {
         cur = str_ptr( include );
         src = compinit->include;
         while ( *src )
         {
            sprintf( cur, "$\"%s\"\r\n", src );
            cur += mem_len( cur );
            src += mem_len( src ) + 1;
         }
         *cur = 0;
         str_setlen( include, cur - str_ptr( include ));
      }
      if ( *compinit->defargs )
      {
         cur = str_ptr( dargs );
         src = compinit->defargs;
         while ( *src )
         {
            sprintf( cur, "%s\r\n", src );
            cur += mem_len( cur );
            src += mem_len( src ) + 1;
         }
         *cur = 0;
         str_setlen( dargs, cur - str_ptr( dargs ));
      }
      str_printf( stemp, "define {\r\n\
%s\r\n\
}\r\n\
include {\r\n\
  %s\r\n\
}\r\n", str_ptr( dargs ), str_ptr( include ));
      if ( compinit->flag & CMPL_SRC )
         str_add( stemp, data );
	  else
		 str_printf( stemp, "include : $\"%s\"", str_ptr( data ));
//      print( str_ptr( stemp ));
      _compile->flag |= CMPL_SRC;
      str_copy( data, stemp );
      str_destroy( stemp );
      str_destroy( include );
      str_destroy( dargs );
   }
   compile_process( data );

   hash_delete( &icompile.files );
   hash_delete( &icompile.names );
   hash_delete( &icompile.resource );
   hash_delete( &icompile.opers );
   hash_delete( &icompile.macros );
   hash_delete( &icompile.namedef );
   arrdata_delete( &icompile.libdirs );
   arrdata_delete( &icompile.string );
   arrdata_delete( &icompile.binary );

   lex_delete( &icompile.ilex );
   msg( MEnd );

   if ( compinit->flag & CMPL_GE )
   {
      buf_clear( &stack );
      ge_save( &stack );
      if ( compinit->output[0] )
         str_copyzero( data, compinit->output );
      else
      {
         str_copyzero( data, compinit->input );
         str_ptr( data )[ str_len( data )] = 'e';
         buf_appendch( (pbuf)data, 0 );
      }
      buf2file( data, &stack );
   }
   str_destroy( icompile.curdir );
   _compile = NULL;
   buf_delete( &stack );
   str_destroy( data );
//  memstat();

   if ( !( icompile.flag & CMPL_NORUN ))
      compinit->result = vm_execute( 1 );
   return TRUE;
}

/*-----------------------------------------------------------------------------
* Id: gentee_compile F
* 
* Summary: Program compilation. This function allows to compile and run 
           programs in Gentee.
*
* Params: compinit - The pointer to $[compileinfo] structure with the /
                     specified compiling options.
*
* Return: #lng/retf#
*  
-----------------------------------------------------------------------------*/

uint  STDCALL gentee_compile( pcompileinfo compinit )
{
   uint ret = 0;
   uint i;

   compinit->result = 0;
   compinit->hthread = 0;
   if ( !( compinit->flag & CMPL_NOCLEAR ))
      for ( i = KERNEL_COUNT; i < arr_count( &_vm.objtbl ); i++ )
      {
         ((pvmobj)PCMD( i ))->flag |= GHRT_SKIP;
         vm_clearname( i );
      }

   if ( compinit->flag & CMPL_THREAD )
   {
      compinit->hthread = os_thread( &thread_compile, compinit );
      if ( compinit->flag & CMPL_NOWAIT )
         return 1;
      os_wait( compinit->hthread, INFINITE );
      os_exitcode( compinit->hthread, &ret );
   }
   else
      ret = thread_compile( compinit );

   return ret;
}

//----------------------------------------------------------------------------
