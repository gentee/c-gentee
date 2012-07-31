/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: vmtype 26.12.06 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
* Summary: 
* 
******************************************************************************/

#include "vmrun.h"
#include "vmtype.h"
#include "vmload.h"
#include "../common/collection.h"
//#include "../bytecode/bytecode.h"

/*-----------------------------------------------------------------------------
*
* ID: type_vardelete 26.12.06 0.0.A.
* 
* Summary: Delete variables
*
-----------------------------------------------------------------------------*/

void   STDCALL type_vardelete( pubyte start, pvartype psub, uint count, 
                               uint align )
{
   povmtype   ptype;
   pubyte     pvar;

   while ( count-- )
   {
      ptype = ( povmtype )PCMD( psub->type );
      if ( !( ptype->vmo.flag & GHTY_STACK ))
      {
         pvar =  start + ( psub->off << ( align ? 2 : 0 ));
//            print("Var delete = %x type=%i RTDEL=%x\n", pvar, psub->type,
//               ptype->vmo.flag & GHRT_DELETE);
         if ( ptype->ftype[ FTYPE_DELETE ] )
            vm_runone( ptype->ftype[ FTYPE_DELETE ], ( uint )pvar );

         if ( ptype->vmo.flag & GHRT_DELETE )
            type_vardelete( pvar, ptype->children, ptype->count, 0 );
      }
      psub++;
   }
}

/*-----------------------------------------------------------------------------
*
* ID: type_varinit 26.12.06 0.0.A.
* 
* Summary: Init variables
*
-----------------------------------------------------------------------------*/

void   STDCALL type_varinit( pubyte start, pvartype psub, uint count, 
                             uint align )
{
   povmtype   ptype;
   pubyte     pvar;
   uint       ret;
   pcollect   pcol;

   while ( count-- )
   {
      ptype = ( povmtype )PCMD( psub->type );
      pvar =  start + ( psub->off << ( align ? 2 : 0 ));

      if ( !( ptype->vmo.flag & GHTY_STACK ))
      {
//         print("Var init = %x type=%i align=%i\n", pvar, psub->type, align );
         if ( ptype->vmo.flag & GHRT_INIT )
            type_varinit( pvar, ptype->children, ptype->count, 0 );

         if ( ptype->ftype[ FTYPE_INIT ] )
         {
            vm_runone( ptype->ftype[ FTYPE_INIT ], ( uint )pvar );
         }
      }
      if ( psub->flag & VAR_OFTYPE && ptype->ftype[ FTYPE_OFTYPE ] )
      {
         vm_runtwo( ptype->ftype[ FTYPE_OFTYPE ], ( uint )pvar, psub->oftype );
      }
      if ( psub->flag & VAR_DIM && ptype->ftype[ FTYPE_ARRAY + psub->dim - 1 ] )
      {
         uint  params[ MAX_MSR + 1 ];
         uint  i;

         params[ 0 ] = ( uint )pvar;
         for ( i = 0; i < psub->dim; i++ )
            params[ i + 1 ] = psub->ptr[i];
         vm_run( ptype->ftype[ FTYPE_ARRAY + psub->dim - 1 ], ( puint )&params, &ret, 8192 );
      }
      if ( psub->flag & VAR_DATA )
      {
         pubyte pdata = ( pubyte )( psub->ptr + psub->dim );
         if ( ptype->vmo.flag & GHTY_STACK )
            mem_copy( start, pdata, ptype->size );
         else
            switch ( ptype->vmo.id )
            {
               case TBuf:
                  buf_copy( ( pbuf )start, pdata + sizeof( uint ), *( puint )pdata );
                  break;
               case TStr:
//                  str_copylen( ( pstr )start, pdata + sizeof( uint ), *( puint )pdata - 1 );
                  str_copyzero( ( pstr )start, pdata );
                  break;
               case TCollection:
                  collect_copy( ( pcollect )start, pdata + sizeof( uint ));
                  break;
               default:
                  if ( ptype->ftype[ FTYPE_COLLECTION ] )
                  {
//                     print("OK 0 %i %x%x%x%x%x%x%x%x%x\n", ptype->ftype[ FTYPE_COLLECTION ], pdata[0], pdata[1], pdata[2], pdata[3], pdata[4], pdata[5], pdata[6], pdata[7], pdata[8], pdata[9]);
                     pcol = ( pcollect )type_new( TCollection, pdata );// + sizeof( uint ) );
                     vm_runtwo( ptype->ftype[ FTYPE_COLLECTION ], ( uint )start, ( uint )pcol );
                     type_destroy( pcol );
                  }
                  break;
            }
      }
      psub++;
   }
}

/*-----------------------------------------------------------------------------
*
* ID: type_setdelete 26.12.06 0.0.A.
* 
* Summary: Delete local variables
*
-----------------------------------------------------------------------------*/

void STDCALL type_setdelete( pstackpos curpos, uint item )
{
   povmbcode   bcode;

   // Has not been initialized
   if ( !*( curpos->start + curpos->func->parsize + 1 + item ))
      return;

   bcode = BCODE( curpos );

   type_vardelete( ( pubyte )*( curpos->start + curpos->func->parsize ),
                   bcode->vars + bcode->sets[ item ].first, 
                   bcode->sets[ item ].count, 1 );
}

/*-----------------------------------------------------------------------------
*
* ID: type_setinit 26.12.06 0.0.A.
* 
* Summary: Init local variables
*
-----------------------------------------------------------------------------*/

void STDCALL type_setinit( pstackpos curpos, uint item )
{
   povmbcode   bcode;
   pubyte      ptr;

   type_setdelete( curpos, item );

   bcode = BCODE( curpos );
   
   ptr = ( pubyte )*( curpos->start + curpos->func->parsize );
   mem_zeroui( ( puint )ptr + bcode->sets[ item ].off, bcode->sets[ item ].size );
   type_varinit( ptr, bcode->vars + bcode->sets[ item ].first, 
                   bcode->sets[ item ].count, 1 );
   // Отмечаем что было инициализация множества
   *( curpos->start + curpos->func->parsize + 1 + item ) = 1;
}

/*-----------------------------------------------------------------------------
*
* ID: type_init 26.12.06 0.0.A.
* 
* Summary: Initialize OVM_TYPE  Set GHRT_INIT & GHRT_DEINIT
*
-----------------------------------------------------------------------------*/

void   STDCALL type_initialize( uint idtype )
{
   uint       i, isinit = 0, isdelete = 0;
   povmtype   ptype = ( povmtype )PCMD( idtype );
   povmtype   psub;

   for ( i = 0; i < ptype->count; i++ )
   {
      psub = ( povmtype )PCMD( ptype->children[ i ].type );
      if ( !psub->vmo.flag & GHRT_LOADED )
         type_initialize( psub->vmo.id );

      if ( psub->vmo.flag & GHRT_INIT )
         isinit = 1;

      if ( psub->vmo.flag & GHRT_DELETE )
         isdelete = 1;

      psub++;
   }
   ptype->vmo.flag |= GHRT_LOADED;

   if ( ptype->ftype[ FTYPE_INIT ] )
      isinit = 1;
   if ( ptype->ftype[ FTYPE_DELETE ] )
      isdelete = 1;

   if ( isinit )
      ptype->vmo.flag |= GHRT_INIT;

   if ( isdelete )
      ptype->vmo.flag |= GHRT_DELETE;
//   print("Type=%i name=%s INIT=%x DELETE=%x\n", idtype, ptype->vmo.name, ptype->vmo.flag & GHRT_INIT, 
//             ptype->vmo.flag & GHRT_DELETE );
}

/*-----------------------------------------------------------------------------
*
* ID: type_isinherit 26.12.06 0.0.A.
* 
* Summary: 
*
-----------------------------------------------------------------------------*/

uint   STDCALL type_isinherit( uint idtype, uint idowner )
{
   povmtype curtype;

   if ( idtype == idowner )
      return 1;
   if ( !idtype )
      return 0;
   curtype =  ( povmtype )PCMD( idtype );
   while ( curtype->inherit )
   {
      if ( idowner == curtype->inherit )
         return 1;
      curtype =  ( povmtype )PCMD( curtype->inherit );
   }
   return 0;
}

/*-----------------------------------------------------------------------------
* Id: type_hasinit F
*
* Summary: Whether an object should be initialized. Specifies the necessity 
           to call the function #a(type_init) for initiating an object of 
           this type. 
*  
* Params: idtype - The type of an object. 
* 
* Return: #b(1) is returned if it is necessary to call #a(type_init), #b(0) is 
          returned otherwise. 
*
* Define: func uint type_hasinit( uint idtype )
*
-----------------------------------------------------------------------------*/

uint   STDCALL type_hasinit( uint idtype )
{
   return (( pvmobj )PCMD( idtype ))->flag & GHRT_INIT ? 1 : 0;
}

/*-----------------------------------------------------------------------------
* Id: type_hasdelete F
*
* Summary: Whether an object should be deleted. Specifies the necessity to 
           call the function #a(type_delete) for deleting an object of 
           this type. 
*  
* Params: idtype - The type of an object. 
* 
* Return: #b(1) is returned if it is necessary to call #a(type_delete), 
          #b(0) is returned otherwise. 
*
* Define: func uint type_hasdelete( uint idtype )
*
-----------------------------------------------------------------------------*/

uint   STDCALL type_hasdelete( uint idtype )
{
   return (( pvmobj )PCMD( idtype ))->flag & GHRT_DELETE ? 1 : 0;
}

/*-----------------------------------------------------------------------------
* Id: type_init F
*
* Summary: Initiate the object as located by the pointer. Gentee initializes 
           objects automaticaly. Use this function only if you allocated the 
           memory for the variable.
*  
* Params: ptr - The pointer to the memory space where the object being /
                created is located. 
          idtype - The type of the object. 
* 
* Return: The pointer to the object is returned.
*
* Define: func uint type_init( pubyte ptr, uint idtype )
*
-----------------------------------------------------------------------------*/

pubyte   STDCALL type_init( pubyte ptr, uint idtype )
{
   povmtype  ptype = ( povmtype )PCMD( idtype );
   vartype   vtype;

   if ( ptype->vmo.flag & GHTY_STACK )
   {
      *( puint )ptr = 0;
      if ( ptype->stsize > 1 )
         *(( puint )ptr + 1 ) = 0;
   }
   else
   {
      mem_zero( ptr, ptype->size );

      vtype.type = idtype;
      vtype.off = 0;
      vtype.flag = 0;
//      vtype.oftype = 0;
//      vtype.dim = 0;
//      vtype.data = 0;

      type_varinit( ptr, &vtype, 1, 0 );
   }
   return ptr;
}

/*-----------------------------------------------------------------------------
* Id: type_delete F
*
* Summary: Delete the object as located by the pointer. Gentee deletes 
           objects automaticaly. Use this function only if you allocated the 
           memory for the variable.
*  
* Params: ptr - The pointer to the memory space where the object being /
                deleted is located.
          idtype - The type of the object. 
* 
* Define: func type_delete( pubyte ptr, uint idtype )
*
-----------------------------------------------------------------------------*/

void   STDCALL type_delete( pubyte ptr, uint idtype )
{
   povmtype  ptype = ( povmtype )PCMD( idtype );
   vartype   vtype;

   if ( !( ptype->vmo.flag & GHTY_STACK ))
   {
      vtype.type = idtype;
      vtype.off = 0;
      vtype.oftype = 0;
      vtype.dim = 0;
      vtype.data = 0;

      type_vardelete( ptr, &vtype, 1, 0 );
   }
}

/*-----------------------------------------------------------------------------
* Id: sizeof F
*
* Summary: Get the size of the type.
*  
* Params: idtype - Identifier or the name of the type. The compiler changes /
                   the name of the type to its identifier.
* 
* Return: The type size in bytes.
*
* Define: func uint sizeof( uint idtype )
*
-----------------------------------------------------------------------------*/

uint   STDCALL type_sizeof( uint idtype )
{
   return (( povmtype )PCMD( idtype ))->size;
}

/*-----------------------------------------------------------------------------
*
* ID: type_compfull 26.12.06 0.0.A.
* 
* Summary: Сплошная совместимость целочисленных тип
*
-----------------------------------------------------------------------------*/

uint  STDCALL type_compfull( uint idtype )
{
   if ( idtype >= TInt && idtype <= TUshort )
      return TUint;
   if ( idtype == TLong || idtype == TUlong )
      return TUlong;
   return idtype;
}

/*-----------------------------------------------------------------------------
*
* ID: type_new 26.12.06 0.0.A.
* 
* Summary: Create an object
*
-----------------------------------------------------------------------------*/

pvoid STDCALL type_new( uint idtype, pubyte data )
{
   vartype   vtype;
   povmtype  ptype = ( povmtype )PCMD( idtype );
   pvoid     ret;

   ret = mem_allocz( max( sizeof( uint ), ptype->size ) + sizeof( uint ));
   // Перед объектом идет его тип
   *( puint )ret = idtype;
   ret = ( pubyte )ret + sizeof( uint );
   mem_zero( &vtype, sizeof( vartype ));
   vtype.flag = data ? VAR_DATA : 0;
   vtype.type = idtype;
   vtype.ptr = ( puint )data;

   type_varinit( ret, &vtype, 1, 1 );

   return ret;
}

/*-----------------------------------------------------------------------------
* Id: destroy F
*
* Summary: Destroying an object. Destroying an object created by the function 
           #a(new).
*  
* Params: obj - The pointer to the object to be destroyed. 
* 
* Define: func destroy( uint obj )
*
-----------------------------------------------------------------------------*/

void STDCALL type_destroy( pvoid obj )
{
   vartype   vtype;

   mem_zero( &vtype, sizeof( vartype ));
//   vtype.flag = 0;
   vtype.type = *(( puint )obj - 1 );
   type_vardelete( obj, &vtype, 1, 1 );
   mem_free( ( puint )obj - 1 );
}

// 1 добавляется для того чтобы если один из двух операндов знаковый
// то использовалась знаковая опреация
const ubyte compnum[ 10 ][ 10 ] =
{
//                 Int UInt Byte   UByte Short UShort Float Double Long ULong
/* Int */         100,  91,   60,    51,  80,   71,    0,     0,    0,   0,  
/* UInt */         90, 100,   50,    60,  70,   80,    0,     0,    0,   0,  
/* Byte      */    80,  51,  100,    71,  90,   61,    0,     0,    0,   0,  
/* UByte */        50,  80,   70,   100,  60,   90,    0,     0,    0,   0,  
/* Short */        90,  61,   80,    51, 100,   71,    0,     0,    0,   0,  
/* UShort */       60,  90,   50,    80,  70,  100,    0,     0,    0,   0,  
/* Float */         0,   0,    0,     0,   0,    0,  100,     0,    0,   0,     
/* Double */        0,   0,    0,     0,   0,    0,    0,   100,    0,   0,  
/* Long */          0,   0,    0,     0,   0,    0,    0,     0,  100,  81,  
/* ULong */         0,   0,    0,     0,   0,    0,    0,     0,   80, 100,  
///* Any  */        100, 100,  100,   100, 100,  100,  100,     0,    0,   0,  100,
};

/*-----------------------------------------------------------------------------
*
* ID: type_compat 26.12.06 0.0.A.
* 
* Summary: Compatibility of types
*
-----------------------------------------------------------------------------*/

uint STDCALL type_compat( uint idleft, uint idright, uint oftype )
{
   uint  i;

   if ( idleft == idright || idleft == TAny || idright == TAny )
      return 100;

   if ( idleft <= TUlong && idright <= TUlong )
   {
      i = compnum[ idright - TInt ][ idleft - TInt ];
      if ( oftype && (( povmtype )PCMD( idleft ))->size != 
          (( povmtype )PCMD( idright ))->size )
         i = 0;
      return i;
   }
   return type_isinherit( idleft, idright ) ? 45 : 0;
}
