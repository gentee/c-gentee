/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: vmload 28.12.06 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
* Summary: 
* 
******************************************************************************/

#include "types.h"
#include "common.h"
#include "vm.h"
#include "gefile.h"
#include "bytecode.h"


/*-----------------------------------------------------------------------------
*
* ID: load_bwd 26.12.06 0.0.A.
* 
* Summary: Unpacking bwd number.
*      byte < 188 returns byte
*      byte from 188 to 253 returns 256 * ( byte - 188 ) + [ byte + 1 ]
*      byte == 254 returns next ushort
*      byte == 255 returns next uint
*
-----------------------------------------------------------------------------*/

uint  STDCALL load_bwd( pvmEngine pThis, pubyte * ptr )
{
   uint   ret;
   pubyte cur = *ptr;

   if ( pThis->_vm.ipack )
   {
      ret = *cur++; 
      if ( ret > 187 )
         if ( ret == MAX_BYTE - 1 )
         {
            ret = *( pushort )cur;
            cur += 2;                   // пропускаем word
         }
         else
            if ( ret == MAX_BYTE )
            {
               ret = *( puint )cur;
               cur += 4;                   // пропускаем dword
            }
            else
               ret = 0xFF * ( ret - 188 ) + *cur++;
   }
   else
   {
      ret = *( puint )cur;
      cur += sizeof( uint );
   }
   *ptr = cur;
   return ret;
}

/*-----------------------------------------------------------------------------
*
* ID: load_convert 26.12.06 0.0.A.
* 
* Summary: Unpacking bwd number and convert.
*
-----------------------------------------------------------------------------*/

uint  STDCALL load_convert( pvmEngine pThis, pubyte * ptr )
{
   uint ret = load_bwd( pThis, ptr );

   if ( ret >= KERNEL_COUNT )
      ret += pThis->_vm.icnv;

   return ret;
}

/*-----------------------------------------------------------------------------
*
* ID: load_addobj 19.10.06 0.0.A.
* 
* Summary: Add an object to VM.
*  
-----------------------------------------------------------------------------*/

pvmobj  STDCALL load_addobj( pvmEngine pThis, uint over )
{
   pvmobj      obj, pover = NULL;
   pvmfunc     curobj = NULL;
   uint        idname = 0;   // previous object
   phashitem   phi = NULL;
   puint       pidphi;

   obj = ( pvmobj )pThis->_vm.pmng->top;

   if ( obj->name && *obj->name )
   {  // Looking for an existing object with the same name
      // and adding name if it is required
      phi = hash_create( pThis, &pThis->_vm.objname, obj->name );
      pidphi = ( puint )( phi + 1 );

      if ( pThis->_vm.loadmode && ( idname = *pidphi))  // Object has already existed
      {
         uint  curcount, objcount, i;

         if ( !( obj->flag & GHRT_MAYCALL ))
            goto error;

         objcount = (( pvmfunc )obj)->parcount - ( obj->flag & GHBC_RESULT ? 1 : 0 );
         while ( idname )
         {
            curobj = ( pvmfunc )PCMD( idname );
            if ( !( curobj->vmo.flag & GHRT_MAYCALL ))
               goto error;
            // Compare parameters
            curcount = curobj->parcount - ( curobj->vmo.flag & GHBC_RESULT ? 1 : 0 );
   
            if ( curcount == objcount )
            {
               for ( i = 0; i < curcount; i++ )
               {
                  if ( curobj->params[ i ].type != 
                         (( pvmfunc )obj )->params[ i ].type )
                     break;
               }
               if ( i == curcount ) // There is the same function
               {
                  // Уходит впустую - реально не добавляем если у нас 
                  // предварительное описание функции 
                  if ( pThis->_vm.loadmode == VMLOAD_EXTERN )
                     return ( pvmobj )curobj;
                  // Байт код для данной функции уже есть - ошибка
                  if ( curobj->func )
                     goto error;
                  // idname == the found object
//                  over = idname;
                  break;
               }
            }
            idname = curobj->vmo.nextname;
         }
      }
   }
   // Object not found
   if ( !idname && !over )
   {
      arr_appendnum( pThis, &pThis->_vm.objtbl, ( uint )obj );
      obj->id = pThis->_vm.count++;
      over = obj->id;
   }
   else
   {
      if ( !over )
         over = idname;

      pover = ( pvmobj )PCMD( over );
      obj->id = over;
      arr_setuint( pThis, &pThis->_vm.objtbl, over, ( uint )obj );
   }
   if ( phi )
   {
      if ( pover && pover->nextname )
         obj->nextname = pover->nextname;
      else
         if (( obj->id != *pidphi && obj->id < KERNEL_COUNT ) ||
               obj->id > *pidphi )//( obj->id != *pidphi ) // fix: От зацикливания
         {
            obj->nextname = ( ushort )*pidphi;
            *pidphi = obj->id;
         }
   }

   // Checking @init @delete @array @oftype =%{}
   if ( obj->flag & GHRT_MAYCALL && obj->name )
   {
      uint    ftype;
      uint    flag = 0;

      pvmfunc pfunc = ( pvmfunc )obj;

      if ( obj->flag & GHBC_METHOD )
      {
         if ( pfunc->parcount == 1 && !mem_cmp( pThis, obj->name, "@init", 6 ))
         {
            flag = GHTY_INITDEL;
            ftype = FTYPE_INIT;
         }
         if ( pfunc->parcount == 1 && !mem_cmp( pThis, obj->name, "@delete", 8 ))
         {
            flag = GHTY_INITDEL;
            ftype = FTYPE_DELETE;
         }
         if ( pfunc->parcount == 2 && !mem_cmp( pThis, obj->name, "@oftype", 8 ))
         {
            flag = GHTY_EXTFUNC;
            ftype = FTYPE_OFTYPE;
         }
         // + 1 на главный тип
         if ( pfunc->parcount > 1 && pfunc->parcount <= MAX_MSR && 
            !mem_cmp( pThis, obj->name, "@array", 7 ))
         {
            ftype = FTYPE_ARRAY + pfunc->parcount - 2;
            flag = GHTY_ARRAY;
         }
      }
      if ( obj->flag & GHBC_OPERATOR )
      {
         if ( pfunc->parcount == 2 && pfunc->params[1].type == TCollection &&
             mem_cmp( pThis, obj->name, "#=", 4 ))
         {
            flag = GHTY_EXTFUNC;
            ftype = FTYPE_COLLECTION;
         }
      }
      if ( flag )
      {
         povmtype ptype = ( povmtype )PCMD( pfunc->params->type );
         ptype->ftype[ ftype ] = obj->id;
         ptype->vmo.flag |= flag;
      }
   }
   return obj;

error:
   longjmp( pThis->stack_state, -1 );//msg( pThis, MNameexist | MSG_VALSTRERR, obj->name, idname );
   return NULL;
}

/*-----------------------------------------------------------------------------
*
* ID: load_common 19.10.06 0.0.A.
* 
* Summary: Common load an object to VM.
*  
-----------------------------------------------------------------------------*/

pubyte  STDCALL load_common( pvmEngine pThis, pubyte input, pubyte* out, uint structsize )
{
   pvmobj  obj;
   ubyte   type = *input++;
   uint    flag = *( puint )input & 0x20FFFFFF; // ??? GHRT_ to zero
                             //  except GHRT_PRIVATE
   uint    len;

   input += sizeof( uint );

   pThis->_vm.ipack = flag & GHCOM_PACK ? 1 : 0;

   pThis->_vm.isize = load_bwd( pThis, &input );

   obj = ( pvmobj )vmmng_begin( pThis, ( pThis->_vm.ipack ? 2 : 1 ) * pThis->_vm.isize );
   mem_zero( pThis, obj, structsize );

   obj->type = type;
   obj->flag = flag;
   *out = ( pubyte )obj + structsize;

   if ( flag & GHCOM_NAME )   
   {
      // считываем опционально имя
      len = mem_copyuntilzero( pThis, *out, input );
      obj->name = *out;

      input += len;
      *out += len;
   }

   return input;
}

/*-----------------------------------------------------------------------------
*
* ID: load_var 19.10.06 0.0.A.
* 
* Summary: Load subtypes or variable
*  
-----------------------------------------------------------------------------*/

pvartype  STDCALL load_var( pvmEngine pThis, pubyte* input, pubyte* output, uint count, 
                            puint size, uint align )
{
   pvartype   psub;
   povmtype   newtype;
   pubyte     out = *output;
   pubyte     ptr = *input;
   pvartype   ret;
   uint       i, off = 0, flag, len, k;
   
   ret = psub = ( pvartype )out;
         
   out += count * sizeof( vartype );
   for ( i = 0; i < count; i++ )
   {
      mem_zero( pThis, psub, sizeof( vartype ));

      psub->type = load_convert( pThis, &ptr );   
      psub->off = align ? ( off >> 2 ) : off;
      flag = *ptr++;
      psub->flag = ( ubyte )flag;

      if ( flag & VAR_NAME )
      {
         len = mem_copyuntilzero( pThis, out, ptr ); 
         psub->name = out;
         ptr += len;
         out += len;
      }
      newtype = ( povmtype )PCMD( psub->type );
      off += flag & VAR_PARAM ? ( newtype->stsize << 2 ) : newtype->size;

      if ( flag & VAR_OFTYPE )
         psub->oftype = load_convert( pThis, &ptr );

      psub->ptr = ( puint )out;

      if ( flag & VAR_DIM )
      {
         len = 1;
         psub->dim = *ptr++;
         
         for ( k = 0; k < psub->dim; k++ )      
         {
            *( puint )out = load_bwd( pThis, &ptr );
            len *= *( puint )out;
            out += sizeof( uint );
         }
         // Если reserved < 4 удаляем лишнее
         if ( psub->type == TReserved )
            off += len - 4;
      }
      if ( flag & VAR_DATA )
      {
         psub->data = 1;
         if ( newtype->vmo.flag & GHTY_STACK )
            len = newtype->size;
         else
         {
            if ( psub->type == TStr )
            {
               len = mem_len( pThis, ptr ) + 1;
            }
            else
            {
               *( puint )out = load_bwd( pThis, &ptr );
               len = *( puint )out;
               out += sizeof( uint );
            }
         }
         mem_copy( pThis, out, ptr, len );
         ptr += len;
         out += len;
      }
      // Alignment
      if ( align && ( off & 3 ))
         off += 4 - ( off & 0x3 );
      psub++;         
   }
   *size = off;

   *output = out;
   *input = ptr;
   return ret;
}

/*-----------------------------------------------------------------------------
*
* ID: load_stack 26.12.06 0.0.A.
* 
* Summary: Load stack object
*
-----------------------------------------------------------------------------*/

pvmobj  STDCALL load_stack( pvmEngine pThis, int top, int cmd, void* pseudo )
{
   povmstack pstack = ( povmstack )vmmng_begin( pThis, sizeof( ovmstack ));
   mem_zero( pThis, pstack, sizeof( ovmstack ));

   pstack->vmf.vmo.type = pseudo ? OVM_PSEUDOCMD : OVM_STACKCMD;
   pstack->vmf.vmo.flag = GHRT_MAYCALL;
   pstack->topshift = top;
   pstack->cmdshift = cmd;
   pstack->vmf.func = ( pvoid )pseudo;
   load_addobj( pThis, 0 );
   vmmng_end( pThis, ( pubyte )( pstack + 1 ));

   return ( pvmobj )pstack;
}

/*-----------------------------------------------------------------------------
*
* ID: load_type 26.12.06 0.0.A.
* 
* Summary: Load type object
*
-----------------------------------------------------------------------------*/

pvmobj  STDCALL load_type( pvmEngine pThis, pubyte* input )
{
   povmtype  ptype;
   pubyte    out;
   pubyte    ptr = *input;

   ptr = load_common( pThis, ptr, &out, sizeof( ovmtype ) );

   ptype = ( povmtype )pThis->_vm.pmng->top;
   ptype->size = 4;
   ptype->stsize = 1;
   ptype->index.type = 0;//TUint;

   if ( ptype->vmo.flag & GHTY_INHERIT )
   {
      ptype->inherit = load_convert( pThis, &ptr );
      // Наследуем index type от родителя
      ptype->index.type = (( povmtype )PCMD( ptype->inherit ))->index.type;
      ptype->index.oftype = (( povmtype )PCMD( ptype->inherit ))->index.oftype;
   }
   if ( ptype->vmo.flag & GHTY_INDEX )
   {
      ptype->index.type = load_convert( pThis, &ptr );
      ptype->index.oftype = load_convert( pThis, &ptr );
   }
   if ( ptype->vmo.flag & GHTY_INITDEL )
   {
      ptype->ftype[ FTYPE_INIT ] = load_convert( pThis, &ptr );
      ptype->ftype[ FTYPE_DELETE ] = load_convert( pThis, &ptr );
   }
   if ( ptype->vmo.flag & GHTY_EXTFUNC )
   {
      ptype->ftype[ FTYPE_OFTYPE ] = load_convert( pThis, &ptr );
      ptype->ftype[ FTYPE_COLLECTION ] = load_convert( pThis, &ptr );
   }
   if ( ptype->vmo.flag & GHTY_ARRAY )
   {
      uint  i, dim = load_convert( pThis, &ptr );

      if ( dim <= MAX_MSR )
      {
         for ( i = 0; i < dim; i++ )
            ptype->ftype[ FTYPE_ARRAY + i ] = load_convert( pThis, &ptr );
      }
      else
         ptype->ftype[ FTYPE_ARRAY ] = dim;
   }
   ptype->count = load_bwd( pThis, &ptr );
   if ( ptype->vmo.flag & GHTY_STACK )
   {
      ptype->size = ptype->count;
      ptype->stsize = ptype->size > sizeof( uint ) ? 2 : 1;
      ptype->count = 0;
   }
   else
      if ( ptype->count )
      {
         ptype->children = load_var( pThis, &ptr, &out, ptype->count, &ptype->size, 0 );
      }
   
   load_addobj( pThis, 0 );
   vmmng_end( pThis, out );

   *input += pThis->_vm.isize;
   return ( pvmobj )ptype;
}

/*-----------------------------------------------------------------------------
*
* ID: load_commonfunc 26.12.06 0.0.A.
* 
* Summary: Common Load bytecode or func object
*
-----------------------------------------------------------------------------*/

pvmfunc  STDCALL load_commonfunc( pvmEngine pThis, pubyte* input, pubyte* out, pubyte* end, puint size )
{
   pvmfunc  pfunc;
   pubyte   ptr = *input;
   uint     i;

   // Проверка на повторный вызов
   ptr = load_common( pThis, ptr, out, *size );
   *end = *input + pThis->_vm.isize;

   pfunc = ( pvmfunc )pThis->_vm.pmng->top;
   pfunc->vmo.flag |= GHRT_MAYCALL;
   pfunc->ret = load_var( pThis, &ptr, out, 1, size, 1 );
   pfunc->dwret = ( ubyte )(( povmtype )PCMD( pfunc->ret->type ))->stsize;
   pfunc->parcount = ( ubyte )load_bwd( pThis, &ptr );
   if ((uint)*out & 3 ) // Alignment
       *out += 4 - ( (uint)*out & 3 );

   pfunc->params = load_var( pThis, &ptr, out, pfunc->parcount, size, 1 );
   
   for ( i = 0; i < pfunc->parcount; i++ )
   {
      pfunc->parsize += ( ubyte )((povmtype)PCMD( pfunc->params[i].type ))->stsize;//( ubyte )( *size >> 2 );
   }
   *input = ptr;

   return pfunc;
}   


/*-----------------------------------------------------------------------------
*
* ID: load_bytecode 26.12.06 0.0.A.
* 
* Summary: Load bytecode object
*
-----------------------------------------------------------------------------*/

pvmobj  STDCALL load_bytecode( pvmEngine pThis, pubyte* input, uint mode )
{
   povmbcode  pbcode;
   pvmobj     ret;
   pubyte     out, end;
   puint      bcout;
   pubyte     ptr = *input;
   uint       size = sizeof( ovmbcode );
   uint       i, off, cmd;

   pThis->_vm.loadmode = mode;
   pbcode = ( povmbcode )load_commonfunc( pThis, &ptr, &out, &end, &size );
   
   pbcode->setcount = ( ubyte )load_bwd( pThis, &ptr );
   if ( pbcode->setcount )
   {
      pbcode->sets = ( pvarset )out;
      out += sizeof( varset ) * pbcode->setcount;
      off = 0;
      for ( i = 0; i < pbcode->setcount; i++ )
      {
         pbcode->sets[i].count = ( ushort )load_bwd( pThis, &ptr );
         pbcode->sets[i].first = ( ushort )off;
         off += pbcode->sets[i].count;
      }
      pbcode->vars = load_var( pThis, &ptr, &out, off, &size, 1 );
      pbcode->varsize = size >> 2;
      off = 0;

      // Sets summary size of block local variables in uints
      for ( i = 0; i < ( uint )( pbcode->setcount - 1 ); i++ )
      {
         pbcode->sets[i].off = off;
         pbcode->sets[i].size = 
                   pbcode->vars[ pbcode->sets[ i + 1 ].first ].off - off;
         off += pbcode->sets[i].size;
      }
      pbcode->sets[ i ].size = pbcode->varsize - off;
      pbcode->sets[ i ].off = off;
   }
   if ( ptr < end || mode == VMLOAD_GE )
   {
       //      if ((uint)out & 3 )
       out += 4 - ( (uint)out & 3 ); // Alignment
       pbcode->vmf.func = out;
   }

   // Loading byte-code
   if ( mode == VMLOAD_GE )
   {
      bcout = ( puint )out;
      while ( ptr < end )
      {
         cmd = load_convert( pThis, &ptr );
         *bcout++ = cmd;
         if ( cmd >= CNop && cmd < CNop + STACK_COUNT )
            switch ( cmd  )
            {
               case CQwload:
                  *bcout++ = *( puint )ptr;
                  ptr += sizeof( uint ); 
               case CDwload:
                  *bcout++ = *( puint )ptr;
                  ptr += sizeof( uint ); 
                  break;
               case CByload:
                  *( bcout - 1 ) = CDwload;
                  *bcout++ = *( pubyte )ptr;
                  ptr += sizeof( ubyte ); 
                  break;
               case CShload:
                  *( bcout - 1 ) = CDwload;
                  *bcout++ = *( pushort )ptr;
                  ptr += sizeof( ushort ); 
                  break;
               case CDwsload:
                  i = load_bwd( pThis, &ptr );
                  *bcout++ = i;
                  i <<= 2;
                  mem_copy( pThis, bcout, ptr, i );
                  bcout += *( bcout - 1 );
                  ptr += i;
                  break;
               case CResload:
                  *bcout++ = load_bwd( pThis, &ptr ) + pThis->_vm.irescnv;
                  break;
               case CCmdload:
               case CPtrglobal:
                  *bcout++ = load_convert( pThis, &ptr );
                  break;
               case CDatasize:
                  i = load_bwd( pThis, &ptr );
                  *bcout++ = i;
                  mem_copy( pThis, bcout, ptr, i );
                  bcout += ( i >> 2 ) + ( i & 3 ? 1 : 0 );
                  ptr += i;
                  // Зануляем последние добавочные байты
                  i &= 3;
                  if ( i )
                  {
                     i = 4 - i;
                     mem_zero( pThis, ( pubyte )bcout - i, i );
                  }
                  break;
               default:
                  switch ( shifts[ cmd - CNop ] )
                  {
                     case SH1_3:
                     case SH2_3:
                        *bcout++ = load_bwd( pThis, &ptr );
                     case SHN1_2:
                     case SH0_2:
                     case SH1_2:
                        *bcout++ = load_bwd( pThis, &ptr );
                        break;
                  }
            }
      }
      // Если у функции в конце нет команды возврата, то добавляем ее
      if ( *( bcout - 1 ) != CReturn )
         *bcout++ = CReturn;

      out = ( pubyte )bcout;
   }
   else
      while ( ptr < end )
         *out++ = *ptr++;

   if ( pbcode->vmf.func )
      pbcode->bcsize = out - ( pubyte )pbcode->vmf.func;
   ret = load_addobj( pThis, 0 ); 
   if ( ret == ( pvmobj )pbcode )
      vmmng_end( pThis, out );
   // Проверка на методы для типов

   *input += pThis->_vm.isize;
   return ret;
}

/*-----------------------------------------------------------------------------
*
* ID: load_bytecode 26.12.06 0.0.A.
* 
* Summary: Load bytecode object
*
-----------------------------------------------------------------------------*/

pvmobj  STDCALL load_exfunc( pvmEngine pThis, pubyte* input, uint over )
{
   povmfunc   pfunc;
   pvmobj     pvmo;
   pubyte     out, end;
   pubyte     ptr = *input;
   uint       size = sizeof( ovmfunc );
   // Проверка на повторный вызов ???

   pThis->_vm.loadmode = VMLOAD_EXTERN;

   pfunc = ( povmfunc )load_commonfunc( pThis, &ptr, &out, &end, &size );
   
   if ( pfunc->vmf.vmo.name )
      switch ( pfunc->vmf.vmo.name[0] )
      {
         case '@': pfunc->vmf.vmo.flag |= GHBC_METHOD; break;
         case '#': pfunc->vmf.vmo.flag |= GHBC_OPERATOR; break;
      }
   if ( pfunc->vmf.vmo.flag & GHEX_IMPORT )
   {
      pfunc->import = load_convert( pThis, &ptr );
      pfunc->original = out;
      size = mem_copyuntilzero( pThis, out, ptr );
      ptr += size;
      out += size;
   }
   if ( pfunc->vmf.ret->type == TDouble || pfunc->vmf.ret->type == TFloat )
      pfunc->vmf.vmo.flag |= GHEX_FLOAT;
   pvmo = load_addobj( pThis, over );
   if ( ( pvmobj )pfunc == pvmo )
      vmmng_end( pThis, out );
//   // Проверка на методы для типов
   *input += pThis->_vm.isize;

   return pvmo;
}

/*-----------------------------------------------------------------------------
*
* ID: load_define 26.12.06 0.0.A.
* 
* Summary: Load define object
*
-----------------------------------------------------------------------------*/

pvmobj  STDCALL load_define( pvmEngine pThis, pubyte* input )
{
   // Добавляем объект
   povmdefine  pdefine;
   pubyte      out;
   uint        size;
   pubyte      ptr = *input;

   ptr = load_common( pThis, ptr, &out, sizeof( ovmdefine ) );

   pdefine = ( povmdefine )pThis->_vm.pmng->top;

   pdefine->count = load_bwd( pThis, &ptr );
   if ( pdefine->count )
   {
      pdefine->macros = load_var( pThis, &ptr, &out, pdefine->count, &size, 0 );
   }
   
   load_addobj( pThis, 0 );
   vmmng_end( pThis, out );

   *input += pThis->_vm.isize;
   return ( pvmobj )pdefine;
}

/*-----------------------------------------------------------------------------
*
* ID: load_import 26.12.06 0.0.A.
* 
* Summary: Load import object
*
-----------------------------------------------------------------------------*/

pvmobj  STDCALL load_import( pvmEngine pThis, pubyte* input )
{
   povmimport  pimport;
   pubyte      out;
   uint        len;
   pubyte      ptr = *input;

   ptr = load_common( pThis, ptr, &out, sizeof( ovmimport ) );

   pimport = ( povmimport )pThis->_vm.pmng->top;
   len = mem_copyuntilzero( pThis, out, ptr ); 
   pimport->filename = out;
   ptr += len;
   out += len;

   if ( pimport->vmo.flag & GHIMP_LINK )
   {
      pimport->size = *( puint )ptr;
      ptr += sizeof( uint );

      mem_copy( pThis, out, ptr, pimport->size );
      pimport->data = out;
      out += pimport->size;
   }

   load_addobj( pThis, 0 );
   vmmng_end( pThis, out );
   *input += pThis->_vm.isize;

   return ( pvmobj )pimport;
}

/*-----------------------------------------------------------------------------
*
* ID: load_global 26.12.06 0.0.A.
* 
* Summary: Load global variable object
*
-----------------------------------------------------------------------------*/

pvmobj  STDCALL load_global( pvmEngine pThis, pubyte* input )
{
   povmglobal  pglobal;
   pubyte      out;
   uint        size;
   pubyte      ptr = *input;

   ptr = load_common( pThis, ptr, &out, sizeof( ovmglobal ));

   pglobal = ( povmglobal )pThis->_vm.pmng->top;
   pglobal->type = load_var( pThis, &ptr, &out, 1, &size, 1 );
   pglobal->pval = out;
   out += max( sizeof( uint ), (( povmtype )PCMD( pglobal->type->type ))->size );
   load_addobj( pThis, 0 );
   vmmng_end( pThis, out );
   *input += pThis->_vm.isize;

   return ( pvmobj )pglobal;
}

/*-----------------------------------------------------------------------------
*
* ID: load_alias 26.12.06 0.0.A.
* 
* Summary: Load alias object
*
-----------------------------------------------------------------------------*/

pvmobj  STDCALL load_alias( pvmEngine pThis, pubyte* input )
{
   povmalias   palias;
   pubyte      out;
   pubyte      ptr = *input;

   ptr = load_common( pThis, ptr, &out, sizeof( ovmalias ));

   palias = ( povmalias )pThis->_vm.pmng->top;
   palias->idlink = load_convert( pThis, &ptr );   
   load_addobj( pThis, 0 );
   vmmng_end( pThis, out );
   *input += pThis->_vm.isize;

   return ( pvmobj )palias;
}

//-----------------------------------------------------------------------------


void  STDCALL load_none( pvmEngine pThis )
{
    pvmobj pvmo = ( pvmobj )vmmng_begin( pThis, sizeof( vmobj ));
    
    load_addobj( pThis, 0 );
    vmmng_end( pThis, ( pubyte )( pvmo + 1 ));
}

void STDCALL load_resource( pvmEngine pThis, pubyte* in )
{
    uint count, i, type;
    
    *in += 5;
    count = load_bwd( pThis, in ); // skip size
    count = load_bwd( pThis, in );
    pThis->_vm.irescnv = collect_count( pThis, &pThis->_vm.resource );
    
    for ( i = 0; i < count; i ++ )
    {
        type = load_convert( pThis, in );
        if ( type == TStr )
        {
            vmres_addstr( pThis, *in );
            //         print("OK=%s %i\n", *in, _vm.rescnv[ i ] );
            *in += mem_len( pThis, *in ) + 1;
        }
    }
}


uint STDCALL ge_load( pvmEngine pThis, char* fileName )
{
    pubyte   cur, end, ptemp;
    uint     size;
    buf    bcode;
    str  filename;
    pgehead  phead;
    
    if ( setjmp( pThis->stack_state) == -1 ) 
        return 0xFFFFFFFF;
    
    buf_init( pThis, &bcode );
    str_init( pThis, &filename );
    str_copyzero( pThis, &filename, fileName );
    file2buf( pThis, &filename, &bcode, 0 );
    str_delete( pThis, &filename );
    phead = ( pgehead )buf_ptr( pThis, &bcode );
    
    // Проверка заголовка и целостности
    // Сравниваем с 'GE' с двумя нулями на конце
    
    if ( *( puint )phead != GE_STRING )//0x00004547 )
        longjmp( pThis->stack_state, -1 );//msg( pThis, MNotGE | MSG_EXIT );
    if ( phead->crc != crc( pThis, ( pubyte )phead + 12, phead->size - 12, 0xFFFFFFFF ))
        longjmp( pThis->stack_state, -1 );//msg( pThis, MCrcGE | MSG_EXIT );
    if ( phead->vermajor != GEVER_MAJOR || phead->verminor > GEVER_MINOR )
        longjmp( pThis->stack_state, -1 );//msg( pThis, MVerGE | MSG_EXIT );
    
    pThis->_vm.loadmode = VMLOAD_GE;
    pThis->_vm.icnv = arr_count( pThis, &pThis->_vm.objtbl ) - KERNEL_COUNT;
    cur = ( pubyte )phead + phead->headsize;
    end = ( pubyte )phead + phead->size;
    while ( cur < end )
    {
        ptemp = cur + 5; // type + flag
        pThis->_vm.ipack = ( *( puint )( cur + 1 )) & GHCOM_PACK ? 1 : 0;
        
        size = load_bwd( pThis, &ptemp );
        ptemp = cur;
        
        switch ( *cur )
        {
        case OVM_NONE:
            load_none(pThis);
            break;
        case OVM_BYTECODE:
            load_bytecode( pThis, &cur, VMLOAD_GE );
            break;
        case OVM_EXFUNC:
            load_exfunc( pThis, &cur, 0 );
            pThis->_vm.loadmode = VMLOAD_GE;
            break;
        case OVM_TYPE:
            load_type( pThis, &cur );
            break;
        case OVM_GLOBAL:
            load_global( pThis, &cur );
            break;
        case OVM_DEFINE:
            load_define( pThis, &cur );
            break;
        case OVM_IMPORT:
            load_import( pThis, &cur );
            break;
        case OVM_RESOURCE:
            load_resource( pThis, &cur );
            break;
        case OVM_ALIAS:
            load_alias( pThis, &cur );
            break;
        default: 
            longjmp( pThis->stack_state, -1 );//msg( pThis, MUnkGE | MSG_DVAL, cur - ( pubyte )phead );
        }
        cur = ptemp + size;
    }
    pThis->_vm.loadmode = VMLOAD_G;
    buf_delete( pThis, &bcode );
    return 1;
}

