/******************************************************************************
*
* Copyright (C) 2006-08, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* Author: Alexey Krivonogov
*
******************************************************************************/

/*-----------------------------------------------------------------------------
* Id: genteeapi L "Gentee API"
* 
* Desc:    Gentee API functions for the using of gentee.dll.
* Summary: There is an option for software engineers to run programs in Gentee 
           in their own applications. To do that, it is enough to connect the 
           gentee.dll file. It contains several importable functions, which 
           are responsible for compilation and execution of the programs.
*
* List: *, gentee_call, gentee_compile, gentee_deinit, gentee_getid, 
        gentee_init, gentee_load, gentee_ptr, gentee_set, 
        *#lng/types#, tgentee, compileinfo, toptimize
* 
-----------------------------------------------------------------------------*/

#include "gentee.h"
#include "../common/crc.h"
#include "../common/memory.h"
#include "../common/file.h"
#include "../os/user/defines.h"
#include "../bytecode/ge.h"

gentee    _gentee;
pcompile  _compile;

/*-----------------------------------------------------------------------------
* Id: gentee_deinit F1
* 
* Summary: End of working with gentee.dll. This function should be called when 
           the work with Gentee is finished. 
*  
* Return: #lng/retf#
*
-----------------------------------------------------------------------------*/

uint  STDCALL gentee_deinit( void )
{
//   print("Deinit %i %s size=%i use=%i\n", &_gentee.tempdir, _gentee.tempdir.data,
//         _gentee.tempdir.size, _gentee.tempdir.use );
   vm_deinit();
   if ( _gentee.tempfile )
   {
      str  stemp;

      str_init( &stemp );
      str_reserve( &stemp, 512 );
      os_dirdeletefull( &_gentee.tempdir );
      os_fileclose( _gentee.tempfile );
      str_printf( &stemp, "%s.tmp", str_ptr( &_gentee.tempdir ));
      os_filedelete( &stemp );
      str_delete( &stemp );
   }
   str_delete( &_gentee.tempdir );
   mem_deinit();

   return TRUE;
}

/*-----------------------------------------------------------------------------
* Id: gentee_init F
* 
* Summary: Initialization of gentee.dll. This function should be called before 
           beginning to work with Gentee.
*
* Params: flags - Flags. $$[initflags]
*
* Return: #lng/retf#
*  
-----------------------------------------------------------------------------*/

uint  STDCALL gentee_init( uint flags )
{
   mem_zero( &_gentee, sizeof( gentee ));

   mem_init();
   crc_init();
   
   _gentee.flags = flags;
   _gentee.print = &os_print;
   os_init( 0 );

   str_init( &_gentee.tempdir );

   vm_init();
   _compile = NULL;
   _gentee.message = &message;

   return TRUE;
}

/*-----------------------------------------------------------------------------
* Id: gentee_set F
* 
* Summary: This function specifies some gentee parameters.
*
* Params: state - The identifier of the parameter.$$[setpars]
          val - The new value of the parameter.
*
* Return: #lng/retf#
*  
-----------------------------------------------------------------------------*/

uint  STDCALL gentee_set( uint state, pvoid val )
{
   switch ( state )
   {
      case GSET_FLAG:
         _gentee.flags = ( uint )val;
         break;
      case GSET_TEMPDIR:  
         if ( _gentee.tempfile )
            return 0;
         str_copyzero( &_gentee.tempdir, ( pubyte )val );
         break;
      case GSET_PRINT:
         _gentee.print = ( printfunc )val;
         break;
      case GSET_MESSAGE:
         _gentee.message = ( messagefunc )val;
         break;
      case GSET_EXPORT:
         _gentee.export = ( exportfunc )val;
         break;
      case GSET_DEBUG:
         _gentee.debug = ( debugfunc )val;
         break;
      case GSET_GETCH:
         _gentee.getch = ( getchfunc )val;
         break;
      case GSET_ARGS:
         _gentee.args = val;
         break;
   }
   return 1;
}

/*-----------------------------------------------------------------------------
* Id: gentee_ptr F
* 
* Summary: Get Gentee structures. This function returns pointers to global 
           Gentee structures.
*
* Params: par - The identifier of the parameter.$$[ptrpars].
*
* Return: The pointer to according global Gentee structure.
*  
-----------------------------------------------------------------------------*/

pvoid STDCALL gentee_ptr( uint par )
{
   switch ( par )
   {
      case GPTR_GENTEE:
         return &_gentee;
      case GPTR_VM: 
         return _pvm;
      case GPTR_COMPILE: 
         return _compile;
      case GPTR_CALL: 
         return &gentee_call;
   }
   return &_gentee;
}

/*-----------------------------------------------------------------------------
* Id: gentee_load F
* 
* Summary: Load and launch the bytecode. This function loads the bytecode from
           the file or the memory and launch it if it is required. You can 
           create the bytecode with $[gentee_compile] function.
*
* Params: bytecode - The pointer to the bytecode or the filename of .ge file.
          flag - Flags. $$[geloadflag]
*
* Return: The result of the executed bytecode if GLOAD_RUN was defined. 
*  
-----------------------------------------------------------------------------*/

uint STDCALL gentee_load( pubyte bytecode, uint flag )
{
   pubyte cur, curout, oldargs;
   uint   count, result = 0;  
   ubyte  stop;
   buf    bcode;

   buf_init( &bcode );
   if ( flag & GLOAD_ARGS )
   {  // Получаем аргументы из командной строки
      oldargs = _gentee.args;
      curout = _gentee.args = mem_alloc( 1024 );
      cur = GetCommandLine();
      count = 0;
      while ( *cur )
      {
         while ( *cur == ' ' ) cur++;
         if ( !*cur ) break;
         
         if ( *cur == '\"' ) 
         {
            cur++;
            stop = '\"';
         }
         else
            stop = ' ';

         while ( *cur != stop )
         {
            if ( count ) 
            {
               if ( *cur == '\\' && *( cur + 1 )== '\"' )
                  cur++;
               *curout++ = *cur;
            }
            if ( !*++cur ) break;
         }
         if ( *cur == stop ) cur++;
         if ( count++ )
            *curout++ = 0;
      }
      *curout = 0;
   }
   if ( flag & GLOAD_FILE )
   {
      str  filename;

      str_init( &filename );
      str_copyzero( &filename, bytecode );
      file2buf( &filename, &bcode, 0 );
      str_delete( &filename );
   }
   else
      buf_copy( &bcode, bytecode, (( pgehead )bytecode)->size );
//   print("OK 0\n");
   ge_load( &bcode );

   if ( flag & GLOAD_RUN )
      result = vm_execute( 1 );

   if ( flag & GLOAD_ARGS )
   {
      mem_free( _gentee.args );
      _gentee.args = oldargs;
   }
   buf_delete( &bcode );
   return result;
}

/*-----------------------------------------------------------------------------
* Id: gentee_getid F
* 
* Summary: Get the object's identifier by its name.
*
* Params: name - The name of the object. If you want to find a method then /
                 use '#b(@)' at the beginning of the name. For example,    /
                 "#b( @mymethod )". If you want to find an operator then   /
                 use '#b(##)' at the beginning of the name. For example,   /
                 "#b( #+= )".
          count - The count of the following parameters. If you want to find  /
                  any object with the defined name then specify the following /
                  flag. $$[getidflag]
          ... - Specify the sequence of the type's identifiers of the       /
                parameters. If the parameter of the function has "#b( of )" /
                subtype then specify it in the HIWORD of the value.
*
* Return: Returns object’s identifier or #b(0), if the object was not found.
*  
-----------------------------------------------------------------------------*/

uint CDECLCALL gentee_getid( pubyte name, uint count, ... )
{
   uint     k = 0;
   uint     params[ 32 ];
   uint     bcode, flag;
   va_list  argptr;

   flag = count;
   count &= 0xFFFFFF;

   if ( flag & GID_ANYOBJ )
   {
      phashitem  phi;
      phi = hash_find( &_vm.objname, name );
      return phi ? *( puint )( phi + 1 ) : 0;
   }
   va_start( argptr, count );

   while ( count-- )
   {
      params[ k++ ] = va_arg( argptr, uint );
      if ( params[ k - 1 ] & 0xFFFF0000 )
      {
         params[ k ] = params[ k - 1 ] >> 16;
         params[ k - 1 ] &= 0xFFFF;
      }
      else
         params[ k ] = 0;
      k++;
   }
   va_end( argptr );
   
   bcode = ( uint )vm_find( name, k >> 1, params );
   return ( uint )bcode < MSGCOUNT ? 0 : ((pvmfunc)bcode)->vmo.id;
}

//--------------------------------------------------------------------------
