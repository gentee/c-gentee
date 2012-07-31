/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: vm 18.10.06 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
* Summary: 
* 
******************************************************************************/

#include "vm.h"
#include "vmrun.h"
#include "vmmanage.h"
#include "vmload.h"
#include "vmtype.h"
#include "vmres.h"
#include "../bytecode/bytecode.h"
#include "../bytecode/funclist.h"
#include "../common/file.h"
#include "../genteeapi/gentee.h"

vm  _vm;   // Global virtual machine
pvm _pvm;  // Pointer to VM

/*-----------------------------------------------------------------------------
*
* ID: vm_deinit 19.10.06 0.0.A.
* 
* Summary: Initialize the virtual machine.
*  
-----------------------------------------------------------------------------*/

void  STDCALL vm_deinit( void )// pvm _pvm )
{
   povmglobal  global;
   povmimport  import;
   pvmobj      vmobj;
   uint        i;

   // Destroy global parameters
//   for ( i = 1024; i < arr_count( &_vm.objtbl ); i++ )
   for ( i = arr_count( &_vm.objtbl ) - 1; i >= 1024; i-- )
   {
      vmobj = ( pvmobj )PCMD( i );
      if ( vmobj->type == OVM_GLOBAL && vmobj->flag & GHRT_LOADED )
      {
         global = ( povmglobal )vmobj;
         type_vardelete( global->pval, global->type, 1, 0 );
      }
      if ( vmobj->type == OVM_IMPORT )
      {
         import = ( povmimport )vmobj;
         if ( import->handle )
         {
         #ifdef LINUX
            dlclose( import->handle );
         #else
            FreeLibrary( import->handle );
         #endif
         }
      }
   }
   // Destroy all objects
   arr_delete( &_vm.objtbl );
   hash_delete( &_vm.objname );
   collect_delete( &_vm.resource );
   buf_delete( &_vm.resource.data );
   vmmng_destroy( );
/*  
   #ifdef GEGUI
      gui_deinit();
   #endif

   // Освобождаем глобальные переменные
   buf_destroy( vm->entry );
   lge_deinit( &vm->lge );
   collect_destroy( &vm->collect );
   systbl_deinit( &vm->objmem );
   systbl_deinit( &vm->objtbl );
   nametbl_deinit( &vm->nametbl );
   mem_free( vm->exception );*/
}

/*-----------------------------------------------------------------------------
*
* ID: vm_init 19.10.06 0.0.A.
* 
* Summary: Initialize the virtual machine.
*  
-----------------------------------------------------------------------------*/

void  STDCALL vm_init( void  )
{
   uint       i, id, k, len, flag;
   stackfunc  pseudo;
   int        topshift, cmdshift;
   pubyte     emb, ptr = ( pubyte )&embtypes;
   ubyte      input[64];
   pvmfunc    pfunc;
//   povmstack  pstack;
  
   _pvm = &_vm;
   mem_zero( _pvm, sizeof( vm ));
   _vm.loadmode = 1;
   // Initialize the array of objects
   arr_init( &_vm.objtbl, sizeof( uint ));
   arr_step( &_vm.objtbl, 1024 );
   buf_init( &_vm.resource.data );
   // Initialize the hash of object names
   hash_init( &_vm.objname, sizeof( uint ));
   vmmng_new();

   // Add zero command
   load_stack( 0, 0, NULL )->type = OVM_NONE;

   // Loading kernel objects into VM
   for ( i = TInt; i <= TFordata; i++ )
   {
//      load_stack( 0, 0, NULL )->type = OVM_TYPE;
      load_type( &ptr );
//      vm_addobj( _pvm, ( pvmobj )mem_allocz( sizeof( vmobj )), 0 );
   }
   // Loading kernel objects into VM
   for ( i = 0; i < STACK_COUNT; i++ )
   {
      topshift = 0;
      cmdshift = 0;
      pseudo = NULL;
      switch ( shifts[i] )
      {
         case SHN3_1: topshift--;
         case SHN2_1: topshift--;
         case SHN1_1: topshift--;
            cmdshift = 1;
            break;
         case SHN1_2: topshift--;
            cmdshift = 2;
            break;
         case SH0_2:  cmdshift++;
         case SH0_1:  cmdshift++;
            break;
         case SH1_3:  cmdshift++;
         case SH1_2:  cmdshift++;
         case SH1_1:  cmdshift++;
            topshift = 1;
            break;
         case SH2_1:
            topshift = 2;
            cmdshift = 1;
            break;
         case SH2_3:
            topshift = 2;
            cmdshift = 3;
            break;
      }
      id = _vm.count;
      if ( id >= CMulII ) // > CReturn )
      {
         if ( id <= Cui2l )
            pseudo = pseudo_i;
         else if ( id <= CNotUL )
                pseudo = pseudo_ul;
         else if ( id <= CRightUL )
                pseudo = pseudo_pul;
         else if ( id <= CGreaterLL )
                pseudo = pseudo_l;
         else if ( id <= CRightL )
                pseudo = pseudo_pl;
         else if ( id <= CEqFF )
                pseudo = pseudo_f;
         else if ( id <= CDivF )
                pseudo = pseudo_pf;
         else if ( id <= CEqDD )
                pseudo = pseudo_d;
         else if ( id <= CDivD )
                pseudo = pseudo_pd;
         else if ( id <= CRightUS )
                pseudo = pseudo_ui;
         else if ( id == CCollectadd )
                pseudo = pseudo_collectadd;
      }
      load_stack( topshift, cmdshift, pseudo );
   }
//   print("Count=%i \n", _vm.count );
   emb = ( pubyte )&embfuncs;
   flag = GHCOM_NAME | GHCOM_PACK;

   for ( i = 0; i < FUNCCOUNT; i++ )
   {
      if ( !mem_cmp( emb, "sin", 3 ))
         flag |= GHEX_CDECL;

      ptr = ( pubyte )&input;
      *ptr++ = OVM_EXFUNC;
      *(( puint )ptr)++ = flag;
      *ptr++ = 0;
      len = mem_copyuntilzero( ptr, emb );
      ptr += len;
      emb += len;
      id = *emb++;
      *ptr++ = ( id & 0x80 ? *emb++ : 0 );
      *ptr++ = 0;
      id &= 0x7f;
      *ptr++ = ( ubyte )id;
      for ( k = 0; k < id; k++ )
      {
         *ptr++ = *emb++;
         *ptr++ = 0;
      }
      input[ 5 ] = ( ubyte )( ptr - ( pubyte )&input );
      ptr = ( pubyte )&input;

      pfunc = ( pvmfunc )load_exfunc( &ptr, 0 );
      pfunc->func = embfuncaddr[ i ];
   }
//   print("Count=%i \n", _vm.count );
   // Loading reserved empty commands
   while ( _pvm->count < KERNEL_COUNT )
      load_stack( 0, 0, NULL )->type = OVM_NONE;

   _vm.countinit = 0;//KERNEL_COUNT;
//   _vm.stacksize = 0x80000; // The default stack size = 512 КБ

/* systbl_init( &vm->objmem, 0, STBL_INIT );
   vm->objmem.numtbl = 1024;
   // Резервируем нулевой элемент
   systbl_appenddw( &vm->objmem, 0 );
   // Инициализируем коллекцию для удаления
   i = 0;
   collect_new( ( pbyte )&i, &vm->collect );

   lge_init( vm );

   vm->stacksize = 0x80000; // Размер стэка 512 КБ
   vm->entry = buf_new( NULL, 64 );
   local_addstack( vm, vm_nocmd, 0 );

   i = 0;
   while ( fromtocmd[ i ].from )
   {
      for ( j = fromtocmd[ i ].from; j <= fromtocmd[ i ].to; j++ )
         local_addstack( vm, idcmd[i], j );
      i++;
   }
   for ( i = SByteSign; i < SLast; i++ )
      local_addtype( vm, i );
  
//   print("Last cmd=%i %i\n", SByteSign, SLast );
//   for ( i = FPrintDw + 1; i < 256; i++ )
   for ( i = SLast; i < 256; i++ )
      local_addstack( vm, vm_nocmd, i );

   for ( i = FMemAlloc; i <= FPrintDw; i++ )
      local_addfunc( vm, i - FMemAlloc );

   #ifdef GEGUI
      gui_init( vm );
   #endif
//   print("Now=%i\n", vm->objtbl.count );
   for ( i = vm->objtbl.count; i < 1024; i++ )
      local_addstack( vm, vm_nocmd, i );
   vm->link = LINKID - 1;
   vm->rtlast = vm->objtbl.count - 1;

   vm->exception = mem_alloc( sizeof( sexception ) * EXCEPT_LIMIT );
   vm->lastexcept = vm->exception;
   vm->lastexcept->start = ( pdword )MAX_DWORD;
   vm->lastexcept->idfunc = 0;
//   vm->idlast = vm->rtlast;*/
}

/*-----------------------------------------------------------------------------
*
* ID: vm_find 19.10.06 0.0.A.
* 
* Summary: Find the byte-code object
* 
* pars - type + oftype
*  
-----------------------------------------------------------------------------*/

pvmfunc  STDCALL vm_find( pubyte name, uint count, puint pars )
{
   pvmfunc      bcode, best = NULL;
   pvartype     par;
   uint         result = 0, countpars = 0, bestweight = 0;
   uint         i, weight, k, idtype, idof ;
   puint        curpar;
   phashitem    phi = NULL;

   phi = hash_find( &_vm.objname, name );

   if ( !phi || !( result = *( puint )( phi + 1 ) ))
      return ( pvmfunc )MUnkoper;

//   result = *( puint )( phi + 1 );
      
   while ( result )
   {
      bcode =  ( pvmfunc )PCMD( result );
//      print( "Look for %s = %i next=%i\n", name, result, bcode->vmo.nextname );
      if ( !( bcode->vmo.flag & GHRT_MAYCALL ))
         return best;
//      print( "Look for %s = %i next=%i\n", name, result, bcode->vmo.nextname );
      if ( bcode->parcount == count + ( bcode->vmo.flag & GHBC_RESULT ? 1 : 0 ))
      {
         countpars = 1;
         par = bcode->params;
         // Делаем проверку типов
         if ( !bcode->parcount || ( bcode->parcount == 1 && ( bcode->vmo.flag & GHBC_RESULT )))
         {
            best = bcode;
            break;
         }
         weight = 0;
         curpar = pars;
         for ( i = 0; i < count; i++ )
         {
            k = 0;
            idtype = *curpar++;
            idof = *curpar++;

            if ( !idtype )
            {
               weight = 0;
               break;
            }
            k = type_compat( idtype, par->type, 0 );
            // Проверка на of type.
            if ( k && par->oftype && !type_compat( idof, par->oftype, 1 ))
               k = 0;

//            print( "COMP %i= %i %i\n", SUInt, par->type->vmobj.id, *curpar );
/*            if ( par->type == idtype || idtype == TAny || par->type == TAny )
               k = 100;
            else 
               if ( par->type <= TUlong && idtype <= TUlong )
                  k = compnum[ par->type - TInt ][ idtype - TInt ];
               else
               {
                  if ( type_isinherit( idtype, par->type ))
                     k = 45;
               }
            // Проверка на of type.
            if ( par->oftype && par->oftype != idof )
               if ( par->oftype <= TUlong && idof <= TUlong )
               {
                  if ( !compnum[ par->oftype - TInt ][ idof - TInt ] ||
                     (( povmtype )PCMD( par->oftype ))->size != 
                     (( povmtype )PCMD( idof ))->size )
                     k = 0;
               }
               else
               {
                  if ( !type_isinherit( idof, par->oftype ))
                     k = 0;
               }
*/
            if ( !k )
            {
               weight = 0;
               break;
            }
            weight += k; //+ ( k != 100 ? 2 * i : 0 );// - 2 * i;
            // следующий параметр у функции
            par++;
         }
//         print("%s %i weight = %i\n", name, ( dword )bcode->vmobj.id, weight );
         if ( weight > bestweight )
         {
            best = bcode;
            bestweight = weight;
            if ( bestweight == ( uint )bcode->parcount * 100 )
            {
//               print("Best\n");
               return best;
            }
         }
      }
      result = bcode->vmo.nextname;
   }
   if ( !countpars )
      return ( pvmfunc )MCountpars;

   if ( !best )
      return ( pvmfunc )MTypepars;

   return best;
}

/*-----------------------------------------------------------------------------
*
* ID: import_execute 23.10.06 0.0.A.
* 
* Summary: This function loads import library
*
-----------------------------------------------------------------------------*/

void  STDCALL import_execute( povmimport pimport )
{
   str  filename;
   str  original;

   str_init( &filename );
   str_init( &original );

   str_copyzero( &original, pimport->filename );
   if ( pimport->vmo.flag & GHIMP_LINK )
   {
      uint    handle;

      gettempfile( &filename, &original );
      if ( pimport->size )
      {
         handle = os_fileopen( &filename, FOP_CREATE | FOP_EXCLUSIVE );
         if ( !handle )
            msg( MFileopen | MSG_STR | MSG_EXIT, &filename );

         if ( !os_filewrite( handle, pimport->data, pimport->size ))
            msg( MFilewrite | MSG_STR | MSG_EXIT, &filename );
         os_fileclose( handle );
      }
   }
   else
      if ( pimport->vmo.flag & GHIMP_EXE )
         getmodulepath( &filename, &original );
      else
         str_copy( &filename, &original );

   if ( str_len( &filename ))
   {
      #ifdef LINUX
         pimport->handle = dlopen( dir, RTLD_LAZY );
      #else
         pimport->handle = LoadLibrary( str_ptr( &filename ));
      #endif
   }
   else
   {
      pimport->handle = _gentee.export ? ( pvoid )0xFFFFFFFF : GetModuleHandle( NULL );
   }
//   print("Import=%x %s\n", pimport->handle, str_ptr( &filename ));
   str_delete( &filename );
   str_delete( &original );
}

/*-----------------------------------------------------------------------------
*
* ID: exfunc_execute 23.10.06 0.0.A.
* 
* Summary: This function loads functions from libraries
*
-----------------------------------------------------------------------------*/

void  STDCALL exfunc_execute( povmfunc pfunc )
{
   pvoid handle;

   if ( !pfunc->import )
      return;
   handle = (( povmimport )PCMD( pfunc->import ))->handle;
   if ((( pvmobj )PCMD( pfunc->import ))->flag & GHIMP_CDECL )
   {
      pfunc->vmf.vmo.flag |= GHEX_CDECL;
   }
   if ( handle )
      if ( handle == ( pvoid )0xFFFFFFFF )
         pfunc->vmf.func = _gentee.export( pfunc->original );
      else
         pfunc->vmf.func = GetProcAddress( handle, pfunc->original );
//   print("HANDLE=%x func=%X name=%s\n", handle, pfunc->vmf.func, pfunc->vmf.vmo.name );
}

/*-----------------------------------------------------------------------------
*
* ID: global_execute 23.10.06 0.0.A.
* 
* Summary: This function initialize global variables
*
-----------------------------------------------------------------------------*/

void  STDCALL global_execute( povmglobal pglobal )
{
//   print("0 %x %x %s size = %i\n", pglobal->pval, pglobal->type, 
//             ((pvmobj)pglobal)->name, ((povmtype)PCMD(pglobal->type->type))->size );
   type_varinit( pglobal->pval, pglobal->type, 1, 1 );
   pglobal->vmo.flag |= GHRT_LOADED;
}

/*-----------------------------------------------------------------------------
*
* ID: vm_execute 23.10.06 0.0.A.
* 
* Summary: This function execute the loaded byte-code
*
-----------------------------------------------------------------------------*/

uint  STDCALL vm_execute( uint main )
{
   pvmobj  pobj;
   uint i, idmain = 0, result = 0;

//   print("Count %i\n", _vm.count );
   // Проходимся по всем объектам и инициализируем то, что нужно
   for ( i = _vm.countinit; i < _vm.count; i++ )
   {
      pobj = ( pvmobj )PCMD( i );

      switch ( pobj->type )
      {
         case OVM_GLOBAL:
            global_execute( ( povmglobal )pobj );
            break;
         case OVM_TYPE:
            // Set GHRT_INIT & GHRT_DEINIT flags
            type_initialize( i );
            break;
         case OVM_EXFUNC:
            exfunc_execute( ( povmfunc )pobj );
            break;
         case OVM_IMPORT:
            import_execute( ( povmimport )pobj );
            break;
      }
      if ( pobj->flag & GHRT_MAYCALL )
      {
//         print("entry 0\n");
         // Call <entry> functions
         if ( pobj->flag & GHBC_ENTRY )
            vm_run( i, NULL, &result, 0x80000 );
         if ( pobj->flag & GHBC_MAIN )
            idmain = i;
//         print("entry 1\n");
      }
   }
//   print("OOOPS\n");
   _vm.countinit = _vm.count;
   if ( main && idmain )
   {
      // Call <main> function
      vm_run( idmain, NULL, &result, 0x80000 );
   }
   return result;
}

/*-----------------------------------------------------------------------------
*
* ID: vm_clearname 23.10.06 0.0.A.
* 
* Summary: This function clear a name of the object
*
-----------------------------------------------------------------------------*/

void   STDCALL vm_clearname( uint id )
{
   phashitem  phi;
   pvmobj     curobj = 0, pvmo = ( pvmobj )PCMD( id );
   uint       idnext;

   if ( !pvmo->name )
      return;
   phi = hash_find( &_vm.objname, pvmo->name );
   idnext = *( puint )( phi + 1 );
   while ( idnext )
   {
      if ( idnext == id )
      {
         if ( curobj )
            curobj->nextname = pvmo->nextname;
         else
            *( puint )( phi + 1 ) = pvmo->nextname;
         break;
      }
      curobj = ( pvmobj )PCMD( idnext );
      idnext = curobj->nextname;
   }
   pvmo->flag &= ~GHCOM_NAME;
   pvmo->name = NULL;
}

/*-----------------------------------------------------------------------------
* Id: getid F
*
* Summary: Getting the code of an object by its name. The function returns the 
           code of an object (function, method, operator, type) by its name 
           and parameters.
*  
* Params: name - The name of an object (function, method, operator ). 
          flags - Flags.$$[getidflags]
          idparams - The types of the required parameters.
* 
* Return: The code (identifier) of the found object. The function returns 
          #b(0) if the such object was not found.
*
* Define: func uint getid( str name, uint flags, collection idparams )
*
-----------------------------------------------------------------------------*/

uint STDCALL vm_getid( pstr name, uint flags, pcollect colpars )
{
   ubyte  fname[256];
   uint   off = 0;
   uint   count;
   uint   i = 0, k = 0;
   uint   params[ 32 ];
   uint   bcode;

   if ( flags & GETID_METHOD )
      fname[ off++ ] = '@';
   if ( flags & GETID_OPERATOR )
      fname[ off++ ] = '#';

   mem_copyuntilzero( fname + off, str_ptr( name ));

   count = collect_count( colpars );
   while ( i < count )
   {
      params[ k++ ] = *( puint )collect_index( colpars, i );
      params[ k++ ] = flags & GETID_OFTYPE ? *( puint )collect_index( colpars, ++i ) : 0;
      i++;
   }
   
   bcode = ( uint )vm_find( fname, k >> 1, params );
   if ( ( uint )bcode < MSGCOUNT )
      bcode = 0;
   else 
      bcode = ((pvmfunc)bcode)->vmo.id;
   return bcode;
}