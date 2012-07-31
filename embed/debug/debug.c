/******************************************************************************
*
* Copyright (C) 2008, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: gentee 15.01.08 0.0.A.
*
* Author: Alexey Krivonogov
*
* Summary: 
*
******************************************************************************/

#include "windows.h"
#include "windowsx.h"
#include "../../src/genteeapi/gentee.h"
#include "../../src/bytecode/cmdlist.h"
#include "../../src/vm/vmrun.h"
#include "../../src/vm/vmload.h"
#include "../../src/common/arr.h"
#include "stdio.h"

ubyte   curfile[MAX_PATH];   // The current file
pubyte  out;
pubyte  filetext;
uint    vid;

void printline( uint line )
{
   uint i = 0;
   uint k = 0;
   uint count = 1;
   
   while ( filetext[ i ] && line >= count )
   {
      if ( count == line )
      {
         out[ k++ ] = filetext[i];
      }
      if ( filetext[ i++ ] == 0xa )
      {
         count++;
      }
   }
   out[ k ] = 0;
   printf("%03i:%s", line, out );
}

void  funccheck( pubyte name )
{
   if ( mem_cmpign( curfile, name, mem_len( name )))
   {
      pvoid handle;
      uint  read;

      mem_copyuntilzero( curfile, name );

      handle = CreateFile( curfile, GENERIC_READ | GENERIC_WRITE,
                             FILE_SHARE_READ | FILE_SHARE_WRITE, NULL, 
                             OPEN_EXISTING, 0, NULL );
      ReadFile( handle, filetext, GetFileSize( handle, NULL ), &read, NULL ); 
      filetext[ read ] = 0;
//            printf( filetext );
      CloseHandle( handle );
   }
}

void printvar( pvartype pvar, uint count, pstackpos curpos, uint off )
{
   ubyte  name[64];
   uint   cur;
   puint  top;

   for ( cur = 0; cur < count; cur++ )
   {
      if ( curpos )
      {
         if ( pvar->flag & VAR_NAME )
            mem_copyuntilzero( name, pvar->name );
         else
            sprintf( name, "tmp%i", vid++ );
      }
      else  // Global varaiable
         mem_copyuntilzero( name, ((pvmobj)off)->name );

      printf( "%s[%i]: ", name, pvar->type );

      if ( curpos )
      {
         if ( cur + off < curpos->func->parcount )
            top = curpos->start + pvar->off;
         else
            top = ( puint )*( curpos->start + curpos->func->parsize ) +
                   pvar->off;
      }
      else  // Global varaiable
         top = ( puint )(( povmglobal )off)->pval;

      switch ( pvar->type )
      {
         case TUint:
            printf("%i ", *top );
            break;
         case TStr:
            if ( pvar->flag & VAR_PARAM )
               top = ( puint )*top;
            printf("%s ", (pubyte)*top );
            break;
         default:
            printf("%i ", *top );
            break;
      }
      pvar++;
   }
}

void printvars( pstackpos curpos )
{
   povmbcode  bcode;
   uint       i;
   
   vid = 0;
   bcode = ( povmbcode )curpos->func;
   if ( bcode->vmf.parcount )
   {
      printf("------>Params: ");
      printvar( bcode->vmf.params, bcode->vmf.parcount, curpos, 0 );
      printf("\n");
   }
   if ( bcode->setcount )
      printf("------>Vars: ");
   
   for ( i = 0; i < bcode->setcount; i++ )
   {
      if ( *( curpos->start + curpos->func->parsize + 1 + i ))
         printvar( bcode->vars + bcode->sets[i].first, bcode->sets[i].count, 
                   curpos, bcode->sets[i].first + bcode->vmf.parcount );
   }
   printf("\n");
}

void  debugdemo( pstackpos curpos )
{
   funccheck( (pubyte)(( puint )curpos->func->func + 3 ));

   switch ( *curpos->cmd )
   {
      case CDbgTrace:
         printf("Line ");
         printline( curpos->nline );
         printvars( curpos );
         break;
      case CDbgFunc:
         printf("===> File: %s\n", (pubyte)(( puint )curpos->func->func + 3 ) );
         printf("Line ");
         printline( curpos->nline );
         break;
      case CReturn:
         printf("===> Return\n");
         printvars( curpos );
         break;
   }
}

uint arr_count( parr pa )
{
   return pa->data.use / pa->isize;
}

void globalvars()
{
   pvm vm;
   uint i;
   povmglobal pglobal;

   vm = ( pvm )gentee_ptr( GPTR_VM );
   printf("------>Global vars: ");
   
   for ( i = 1024; i < arr_count( &vm->objtbl ); i++ )
   {  
      pglobal = ( povmglobal )*(( puint )vm->objtbl.data.data + i );
      if ( pglobal->vmo.type == OVM_GLOBAL )
      {
         printvar( pglobal->type, 1, 0, ( uint )pglobal );
      }
   }
}
/*
typedef struct funcinfo
{
   uint    line;
   uint    reserve[32];
} funcinfo, * pfuncinfo;
*/
int __cdecl main( int argc, char *argv[] )
{
   compileinfo cmplinfo;
   uint        flag = G_CONSOLE | G_CHARPRN;
//   uint        i;

   printf( "\nDebug Demo\n\
Copyright (C) 2008 The Gentee Group. All rights reserved.\n\
Internet: http://www.gentee.com  Email: info@gentee.com\n\n" );
//   for ( i = 0; i < 50; i++ )
//   {
   gentee_init( flag );
   gentee_set( GSET_DEBUG, &debugdemo );

   mem_zero( &cmplinfo, sizeof( compileinfo ));

   cmplinfo.flag = CMPL_DEBUG;// | CMPL_THREAD;
   cmplinfo.defargs = "";
   cmplinfo.libdirs = "";
   cmplinfo.include = "..\\..\\exe\\lib\\stdlib.ge\0\0"; 
   cmplinfo.defargs = ""; 
   cmplinfo.output = "";  
   cmplinfo.input = "..\\debug.g";
   
   out = ( pubyte )mem_alloc( 0xFFFF );
   filetext = ( pubyte )mem_alloc( 0xFFFF );

   gentee_compile( &cmplinfo );

   printf("Ret=%i\n", cmplinfo.result );
   globalvars();  // you can call it in any moment
   mem_free( out );
   mem_free( filetext );
   gentee_deinit();
//   }
   getch();
   
   return 0;
}
