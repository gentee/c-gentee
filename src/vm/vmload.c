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

#include "vmload.h"
#include "vmmanage.h"
#include "../compiler/operlist.h"
#include "../bytecode/cmdlist.h"
#include "../bytecode/bytecode.h"

#include "../genteeapi/gentee.h"
#include "../compiler/lexem.h"
#include "../compiler/macro.h"

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

uint  STDCALL load_bwd( pubyte * ptr )
{
   uint   ret;
   pubyte cur = *ptr;

   if ( _vm.ipack )
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

uint  STDCALL load_convert( pubyte * ptr )
{
   uint ret = load_bwd( ptr );

   if ( ret >= KERNEL_COUNT )
      ret += _vm.icnv;

   return ret;
}

/*-----------------------------------------------------------------------------
*
* ID: load_cmdflag 
* 
* Summary: Unpacking cmd & flag and convert the cmd.
*
-----------------------------------------------------------------------------*/

uint  STDCALL load_cmdflag( pubyte * ptr )
{
   puint cur = ( puint )*ptr;
   uint flag = *cur & 0xFF000000; 
   uint ret = *cur & 0xFFFFFF;

   if ( ret >= KERNEL_COUNT )
      ret += _vm.icnv;

   cur++;
   *ptr = ( pubyte )cur;
   return ret | flag;
}

/*-----------------------------------------------------------------------------
*
* ID: load_addobj 19.10.06 0.0.A.
* 
* Summary: Add an object to VM.
*  
-----------------------------------------------------------------------------*/

pvmobj  STDCALL load_addobj( uint over )
{
   pvmobj      obj, pover = NULL;
   pvmfunc     curobj = NULL;
   uint        idname = 0;   // previous object
   phashitem   phi = NULL;
   puint       pidphi;

   obj = ( pvmobj )_vm.pmng->top;
/*   if ( flag & VMADD_CRC )
   {
      // CRC control
   }*/
   if ( obj->name && *obj->name )
   {  // Looking for an existing object with the same name
      // and adding name if it is required
      phi = hash_create( &_vm.objname, obj->name );
      pidphi = ( puint )( phi + 1 );
//      print("phi=%x link = %i %s mode = %i\n", phi, *pidphi,  obj->name, _vm.loadmode );
      if ( _vm.loadmode && ( idname = *pidphi))  // Object has already existed
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
                  if ( _vm.loadmode == VMLOAD_EXTERN )//|| _vm.loadmode == VMLOAD_FIRST )
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
//         if ( !idname )
//            curobj = NULL;
      }
   }
//   if ( over )
//      idname = over;
   // Object not found
   if ( !idname && !over )
   {
      arr_appendnum( &_vm.objtbl, ( uint )obj );
      obj->id = _vm.count++;
      over = obj->id;
   }
   else
   {
      if ( !over )
         over = idname;

      pover = ( pvmobj )PCMD( over );
      obj->id = over;
      arr_setuint( &_vm.objtbl, over, ( uint )obj );
   }
   if ( phi )
   {
//      print("EQ0 phi=%x link = %i %s next=%i over=%i id = %i\n", phi, *pidphi, obj->name,
//             obj->nextname, over, obj->id );
      if ( pover && pover->nextname )
         obj->nextname = pover->nextname;
      else
         if (( obj->id != *pidphi && obj->id < KERNEL_COUNT ) ||
               obj->id > *pidphi )//( obj->id != *pidphi ) // fix: От зацикливания
         {
            obj->nextname = ( ushort )*pidphi;
            *pidphi = obj->id;
         }
//      print("EQ1 phi=%x link = %i %s next=%i over=%i id = %i\n", phi, *pidphi, obj->name,
//             obj->nextname, over, obj->id );
   }

   // Checking @init @delete @array @oftype =%{}
   if ( obj->flag & GHRT_MAYCALL && obj->name )
   {
      uint    ftype;
      uint    flag = 0;
//      pubyte  opname[32];

      pvmfunc pfunc = ( pvmfunc )obj;

      if ( obj->flag & GHBC_METHOD )
      {
         if ( pfunc->parcount == 1 && !mem_cmp( obj->name, "@init", 6 ))
         {
            flag = GHTY_INITDEL;
            ftype = FTYPE_INIT;
         }
         if ( pfunc->parcount == 1 && !mem_cmp( obj->name, "@delete", 8 ))
         {
            flag = GHTY_INITDEL;
            ftype = FTYPE_DELETE;
         }
         if ( pfunc->parcount == 2 && !mem_cmp( obj->name, "@oftype", 8 ))
         {
            flag = GHTY_EXTFUNC;
            ftype = FTYPE_OFTYPE;
         }
         // + 1 на главный тип
         if ( pfunc->parcount > 1 && pfunc->parcount <= MAX_MSR && 
            !mem_cmp( obj->name, "@array", 7 ))
         {
            ftype = FTYPE_ARRAY + pfunc->parcount - 2;
            flag = GHTY_ARRAY;
         }
      }
      if ( obj->flag & GHBC_OPERATOR )
      {
         if ( pfunc->parcount == 2 && pfunc->params[1].type == TCollection &&
             mem_cmp( obj->name, "#=", 4 ))
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
//         print("TYPE=%i ftype=%i id= %i %s\n", pfunc->params->type, ftype, 
//                obj->id, obj->name );
      }
   }
   return obj;

error:
   msg( MNameexist | MSG_VALSTRERR, obj->name, idname );
   return NULL;
}

/*-----------------------------------------------------------------------------
*
* ID: load_common 19.10.06 0.0.A.
* 
* Summary: Common load an object to VM.
*  
-----------------------------------------------------------------------------*/

pubyte  STDCALL load_common( pubyte input, pubyte* out, uint structsize )
{
   pvmobj  obj;
   ubyte   type = *input++;
   uint    flag = *( puint )input & 0x20FFFFFF; // ??? GHRT_ to zero
                             //  except GHRT_PRIVATE
   uint    len;

   input += sizeof( uint );

   _vm.ipack = flag & GHCOM_PACK ? 1 : 0;

   _vm.isize = load_bwd( &input );
/*   if ( type == OVM_GLOBAL )
   {
      _vm.isize += 50000;
//      print("Load = %s isize = %i\n", obj->name, _vm.isize );
   }*/
   obj = ( pvmobj )vmmng_begin( ( _vm.ipack ? 2 : 1 ) * _vm.isize );
   mem_zero( obj, structsize );

   obj->type = type;
   obj->flag = flag;
   *out = ( pubyte )obj + structsize;

   if ( flag & GHCOM_NAME )   
   {
      // считываем опционально имя
      len = mem_copyuntilzero( *out, input );
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

pvartype  STDCALL load_var( pubyte* input, pubyte* output, uint count, 
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
//   print("Count=%i ---------\n", count );
   for ( i = 0; i < count; i++ )
   {
      mem_zero( psub, sizeof( vartype ));
      psub->type = load_convert( &ptr );   
      psub->off = align ? ( off >> 2 ) : off;
      flag = *ptr++;
      psub->flag = ( ubyte )flag;
      if ( flag & VAR_NAME )
      {
         len = mem_copyuntilzero( out, ptr ); 
         psub->name = out;
         ptr += len;
//         print("    Field %i %s\n", i, psub->name );
         out += len;
      }
      newtype = ( povmtype )PCMD( psub->type );
      off += flag & VAR_PARAM ? ( newtype->stsize << 2 ) : newtype->size;

      if ( flag & VAR_OFTYPE )
         psub->oftype = load_convert( &ptr );

      psub->ptr = ( puint )out;

      if ( flag & VAR_DIM )
      {
         len = 1;
         psub->dim = *ptr++;
         
         for ( k = 0; k < psub->dim; k++ )      
         {
            *( puint )out = load_bwd( &ptr );
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
//         print("Data=%s\n", psub->name );
         if ( newtype->vmo.flag & GHTY_STACK )
            len = newtype->size;
         else
         {
            if ( psub->type == TStr )
            {
               len = mem_len( ptr ) + 1;
//               print("Val=%s\n", ptr );
            }
            else
            {
               *( puint )out = load_bwd( &ptr );
               len = *( puint )out;
//               print("Load %i %x\n", len, *( puint )ptr );
               out += sizeof( uint );
            }
         }
         mem_copy( out, ptr, len );
         ptr += len;
         out += len;
      }
      // Alignment
      if ( align && ( off & 3 ))
         off += 4 - ( off & 0x3 );
//      print("off = %i \n", off );

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

pvmobj  STDCALL load_stack( int top, int cmd, stackfunc pseudo )
{
   povmstack pstack = ( povmstack )vmmng_begin( sizeof( ovmstack ));

   mem_zero( pstack, sizeof( ovmstack ));
   pstack->vmf.vmo.type = pseudo ? OVM_PSEUDOCMD : OVM_STACKCMD;
   pstack->vmf.vmo.flag = GHRT_MAYCALL;
   pstack->topshift = top;
   pstack->cmdshift = cmd;
   pstack->vmf.func = ( pvoid )pseudo;
   load_addobj( 0 );
   vmmng_end( ( pubyte )( pstack + 1 ));

   return ( pvmobj )pstack;
}

/*-----------------------------------------------------------------------------
*
* ID: load_type 26.12.06 0.0.A.
* 
* Summary: Load type object
*
-----------------------------------------------------------------------------*/

pvmobj  STDCALL load_type( pubyte* input )
{
   povmtype  ptype;
   pubyte    out;
   pubyte    ptr = *input;

   ptr = load_common( ptr, &out, sizeof( ovmtype ) );

   ptype = ( povmtype )_vm.pmng->top;
   ptype->size = 4;
   ptype->stsize = 1;
   ptype->index.type = 0;//TUint;

   if ( ptype->vmo.flag & GHTY_INHERIT )
   {
      povmtype inherit;
      
      ptype->inherit = load_convert( &ptr );
      inherit = ( povmtype )PCMD( ptype->inherit );
      // Наследуем index type от родителя
      ptype->index.type = inherit->index.type;
      ptype->index.oftype = inherit->index.oftype;
      ptype->ftype[ FTYPE_OFTYPE ] = inherit->ftype[ FTYPE_OFTYPE ];
   }
   if ( ptype->vmo.flag & GHTY_INDEX )
   {
      ptype->index.type = load_convert( &ptr );
      ptype->index.oftype = load_convert( &ptr );
   }
   if ( ptype->vmo.flag & GHTY_INITDEL )
   {
      ptype->ftype[ FTYPE_INIT ] = load_convert( &ptr );
      ptype->ftype[ FTYPE_DELETE ] = load_convert( &ptr );
   }
   if ( ptype->vmo.flag & GHTY_EXTFUNC )
   {
      ptype->ftype[ FTYPE_OFTYPE ] = load_convert( &ptr );
      ptype->ftype[ FTYPE_COLLECTION ] = load_convert( &ptr );
   }
   if ( ptype->vmo.flag & GHTY_ARRAY )
   {
      uint  i, dim = load_convert( &ptr );

      if ( dim <= MAX_MSR )
      {
         for ( i = 0; i < dim; i++ )
            ptype->ftype[ FTYPE_ARRAY + i ] = load_convert( &ptr );
      }
      else
         ptype->ftype[ FTYPE_ARRAY ] = dim;
   }
   ptype->count = load_bwd( &ptr );
   if ( ptype->vmo.flag & GHTY_STACK )
   {
      ptype->size = ptype->count;
      ptype->stsize = ptype->size > sizeof( uint ) ? 2 : 1;
      ptype->count = 0;
   }
   else
      if ( ptype->count )
      {
         ptype->children = load_var( &ptr, &out, ptype->count, &ptype->size, 0 );
      }
   
   load_addobj( 0 );
   vmmng_end( out );

//   print("id= %i name= %s s=%i/%i ind = %i\n", ptype->vmo.id, ptype->vmo.name, ptype->size, 
//          ptype->stsize, ptype->index.type );
   *input += _vm.isize;
   return ( pvmobj )ptype;
}

/*-----------------------------------------------------------------------------
*
* ID: load_commonfunc 26.12.06 0.0.A.
* 
* Summary: Common Load bytecode or func object
*
-----------------------------------------------------------------------------*/

pvmfunc  STDCALL load_commonfunc( pubyte* input, pubyte* out, pubyte* end, puint size )
{
   pvmfunc  pfunc;
   pubyte   ptr = *input;
   uint     i;

   // Проверка на повторный вызов
   ptr = load_common( ptr, out, *size );
   *end = *input + _vm.isize;

   pfunc = ( pvmfunc )_vm.pmng->top;
   pfunc->vmo.flag |= GHRT_MAYCALL;
   pfunc->ret = load_var( &ptr, out, 1, size, 1 );
   pfunc->dwret = ( ubyte )(( povmtype )PCMD( pfunc->ret->type ))->stsize;
   pfunc->parcount = ( ubyte )load_bwd( &ptr );
   if ((uint)*out & 3 ) // Alignment
      *out += 4 - ( (uint)*out & 3 );

//   print("ret=%i %s %i\n", pfunc->ret->type,pfunc->vmo.name, pfunc->parcount );
   pfunc->params = load_var( &ptr, out, pfunc->parcount, size, 1 );
   
   for ( i = 0; i < pfunc->parcount; i++ )
   {
      pfunc->parsize += ( ubyte )((povmtype)PCMD( pfunc->params[i].type ))->stsize;//( ubyte )( *size >> 2 );
   }
//   print("%s ret = %i parsize = %i count = %i\n", 
//      pfunc->vmo.name, pfunc->ret->type, pfunc->parsize, pfunc->parcount );

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

pvmobj  STDCALL load_bytecode( pubyte* input, uint mode )
{
   povmbcode  pbcode;
   pvmobj     ret;
   pubyte     out, end;
   puint      bcout;
   pubyte     ptr = *input;
   uint       size = sizeof( ovmbcode );
   uint       i, off, cmd, k;
//   uint       nobcode = 0;  // 1 if there is not bytecode

   _vm.loadmode = mode;
   pbcode = ( povmbcode )load_commonfunc( &ptr, &out, &end, &size );
//   print( "OK %s\n", pbcode->vmf.vmo.name );
   
   pbcode->setcount = ( ushort )load_bwd( &ptr );
   if ( pbcode->setcount )
   {
      pbcode->sets = ( pvarset )out;
      out += sizeof( varset ) * pbcode->setcount;
      off = 0;
      for ( i = 0; i < pbcode->setcount; i++ )
      {
         pbcode->sets[i].count = ( ushort )load_bwd( &ptr );
         pbcode->sets[i].first = ( ushort )off;
         off += pbcode->sets[i].count;
      }
      pbcode->vars = load_var( &ptr, &out, off, &size, 1 );
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
//   if ( ptr == end )
//      nobcode = 1;
//   else
   if ( ptr < end || mode == VMLOAD_GE )
   {
//      if ((uint)out & 3 )
         out += 4 - ( (uint)out & 3 ); // Alignment
      pbcode->vmf.func = out;
   }
//  print("0 %x == %x varsize = %i \n set= %i ret = %i parsize = %i count = %i\n", 
     //ptr, end, pbcode->varsize, pbcode->setcount,
//       pbcode->vmf.ret->type, pbcode->vmf.parsize, pbcode->vmf.parcount );
   // Loading byte-code
   if ( mode == VMLOAD_GE )
   {
      bcout = ( puint )out;
      while ( ptr < end )
      {
         cmd = load_convert( &ptr );
         //print("Load=%x\n", cmd );
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
                  i = load_bwd( &ptr );
                  *bcout++ = i;
                  for ( k = 0; k < i; k++ )
                     *bcout++ = load_cmdflag( &ptr );
                  break;
               case CAsm:
                  i = load_bwd( &ptr );
                  *bcout++ = i;
                  i <<= 2;
                  mem_copy( bcout, ptr, i );
                  bcout += *( bcout - 1 );
                  ptr += i;
                  break;
               case CResload:
                  *bcout++ = load_bwd( &ptr ) + _vm.irescnv;
                  break;
               case CCmdload:
               case CPtrglobal:
                  *bcout++ = load_convert( &ptr );
                  break;
               case CDatasize:
                  i = load_bwd( &ptr );
                  *bcout++ = i;
                  mem_copy( bcout, ptr, i );
                  bcout += ( i >> 2 ) + ( i & 3 ? 1 : 0 );
                  ptr += i;
                  // Зануляем последние добавочные байты
                  i &= 3;
                  if ( i )
                  {
                     i = 4 - i;
                     mem_zero( ( pubyte )bcout - i, i );
                  }
                  break;
               default:
                  switch ( shifts[ cmd - CNop ] )
                  {
                     case SH1_3:
                     case SH2_3:
                        *bcout++ = load_bwd( &ptr );
                     case SHN1_2:
                     case SH0_2:
                     case SH1_2:
                        *bcout++ = load_bwd( &ptr );
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
// print("Add=%s\n", pbcode->vmf.vmo.name );
   ret = load_addobj( 0 );
#ifdef _ASM
   if ( pbcode->vmf.func && ret == ( pvmobj )pbcode && 
        (( mode == VMLOAD_GE && _gentee.flags & G_ASM )
#ifndef RUNTIME
         || ( _compile && _compile->flag & CMPL_ASM )
#endif // RUNTIME
         ))
   {
      buf  asm;

      buf_init( &asm );
      ge_toasm( pbcode->vmf.vmo.id, &asm );
//      print("id=%i %s %i len=%i /%i\n", pbcode->vmf.vmo.id, pbcode->vmf.vmo.name,
//               pbcode->vmf.func, buf_len( &asm ), pbcode->bcsize );
      mem_copy( pbcode->vmf.func, buf_ptr( &asm ), buf_len( &asm ));
      pbcode->bcsize = buf_len( &asm );
      out = ( pubyte )pbcode->vmf.func + pbcode->bcsize;
      buf_delete( &asm );
   }
#endif // _ASM
   if ( ret == ( pvmobj )pbcode )
      vmmng_end( out );
   // Проверка на методы для типов

//   print("id= %i name= %s \n", ret->id, ret->name );
   if ( mode == VMLOAD_GE )
      *input += _vm.isize;
   return ret;
}

/*-----------------------------------------------------------------------------
*
* ID: load_bytecode 26.12.06 0.0.A.
* 
* Summary: Load bytecode object
*
-----------------------------------------------------------------------------*/

pvmobj  STDCALL load_exfunc( pubyte* input, uint over )
{
   povmfunc   pfunc;
   pvmobj     pvmo;
   pubyte     out, end;
   pubyte     ptr = *input;
   uint       size = sizeof( ovmfunc );
   // Проверка на повторный вызов ???

   _vm.loadmode = VMLOAD_EXTERN;

   pfunc = ( povmfunc )load_commonfunc( &ptr, &out, &end, &size );
   
   if ( pfunc->vmf.vmo.name )
      switch ( pfunc->vmf.vmo.name[0] )
      {
         case '@': pfunc->vmf.vmo.flag |= GHBC_METHOD; break;
         case '#': pfunc->vmf.vmo.flag |= GHBC_OPERATOR; break;
      }
   if ( pfunc->vmf.vmo.flag & GHEX_IMPORT )
   {
      pfunc->import = load_convert( &ptr );
      pfunc->original = out;
      size = mem_copyuntilzero( out, ptr );
      ptr += size;
      out += size;
//      print("LOAD %x == %s %s\n", pfunc->import, pfunc->original, pfunc->vmf.vmo.name );
   }
   if ( pfunc->vmf.ret->type == TDouble || pfunc->vmf.ret->type == TFloat )
      pfunc->vmf.vmo.flag |= GHEX_FLOAT;
//   print("1 %x == %x nofunc = %i\n", ptr, end, nofunc );
//   print("Over = %i mode=%i name=%s\n", over, _vm.loadmode, pfunc->vmf.vmo.name );
   pvmo = load_addobj( over );
/*   if ( pfunc->vmf.vmo.flag & GHEX_CDECL )
      print("id= %i next = %i name= %s count=%i %i/%i\n", pfunc->vmf.vmo.id, 
        pfunc->vmf.vmo.nextname, pfunc->vmf.vmo.name,
           pfunc->vmf.parsize, pfunc->vmf.parcount, pfunc->vmf.ret->type );
*/
   if ( ( pvmobj )pfunc == pvmo )
      vmmng_end( out );
//   // Проверка на методы для типов
   *input += _vm.isize;

   return pvmo;
}

/*-----------------------------------------------------------------------------
*
* ID: load_define 26.12.06 0.0.A.
* 
* Summary: Load define object
*
-----------------------------------------------------------------------------*/

pvmobj  STDCALL load_define( pubyte* input )
{
   // Добавляем объект
   povmdefine  pdefine;
   pubyte      out;
   uint        size;
   pubyte      ptr = *input;

   ptr = load_common( ptr, &out, sizeof( ovmdefine ) );

   pdefine = ( povmdefine )_vm.pmng->top;

   pdefine->count = load_bwd( &ptr );
   if ( pdefine->count )
   {
      pdefine->macros = load_var( &ptr, &out, pdefine->count, &size, 0 );
   }
   
   load_addobj( 0 );
   vmmng_end( out );
//   print("id= %i name= %s \n", pdefine->vmo.id, pdefine->vmo.name );
   *input += _vm.isize;
#ifndef RUNTIME
   if ( _vm.loadmode == VMLOAD_GE && _compile )
   {
      lexem group, item;
      uint  namedef, i, idname = 0;
      pmacro  pm;
      pstr    ps;
      pbuf    pb;
      pubyte  data;

      mem_zero( &group, sizeof( lexem ));
      if ( pdefine->vmo.name && pdefine->vmo.name[0] )
      {
         group.type = LEXEM_NAME;
         group.nameid = ( uint )hash_create( &_compile->names, pdefine->vmo.name )->id;
         idname = group.nameid + 1;
      }
      namedef = LEXEM_NUMBER | ( pdefine->vmo.flag & GHDF_NAMEDEF ? MACRO_NAMEDEF : 0 );

      if ( group.type )
         macro_set( &group, namedef, 0 )->flag = MACROF_GROUP;
      
      for ( i = 0; i < pdefine->count; i++ )
      {
         item.type = LEXEM_NAME;
//         print("name=%s\n", pdefine->macros[i].name );
         item.nameid = hash_create( &_compile->names, pdefine->macros[i].name )->id;
         pm = macro_set( &item, namedef, idname );
         data = ( pubyte )( pdefine->macros[i].ptr + pdefine->macros[i].dim );
         switch ( pdefine->macros[i].type )
         {
            case TStr:
               if ( pdefine->macros[i].flag & VAR_IDNAME )
               {
                  pm->mr.vallexem.type = LEXEM_NAME;
                  pm->mr.vallexem.nameid = ( uint )hash_create( &_compile->names,
                            data );
               }
               else
               {
                  pm->mr.vallexem.type = LEXEM_STRING;
                  ps = str_init( ( pstr )arr_append( &_compile->string ));
                  str_copyzero( ps, data );
//                  print("Data=%s\n", data );
                  pm->mr.vallexem.strid = arr_count( &_compile->string ) - 1;
               }
               break;
            case TBuf: 
               pm->mr.vallexem.type = LEXEM_BINARY;
               pb = buf_init( ( pbuf )arr_append( &_compile->binary ));
               buf_copy( pb, data + sizeof( uint ), *( puint )data );
//                  print("Data=%s\n", data );
               pm->mr.vallexem.binid = arr_count( &_compile->binary ) - 1;
               break;
            default:  // Numbers
               pm->mr.vallexem.type = LEXEM_NUMBER;
               pm->mr.vallexem.num.type = pdefine->macros[i].type; 
               mem_copy( ( pubyte )&pm->mr.vallexem.num.vint, data, 
                         (( povmtype )PCMD( pdefine->macros[i].type ))->size );
               break;
         }
      }
   }
#endif
   return ( pvmobj )pdefine;
}

/*-----------------------------------------------------------------------------
*
* ID: load_import 26.12.06 0.0.A.
* 
* Summary: Load import object
*
-----------------------------------------------------------------------------*/

pvmobj  STDCALL load_import( pubyte* input )
{
   povmimport  pimport;
   pubyte      out;
   uint        len;
   pubyte      ptr = *input;

   ptr = load_common( ptr, &out, sizeof( ovmimport ) );

   pimport = ( povmimport )_vm.pmng->top;
   len = mem_copyuntilzero( out, ptr ); 
   pimport->filename = out;
   ptr += len;
   out += len;

   if ( pimport->vmo.flag & GHIMP_LINK )
   {
      pimport->size = *( puint )ptr;
      ptr += sizeof( uint );

      mem_copy( out, ptr, pimport->size );
      pimport->data = out;
      out += pimport->size;
//      print("Load import %i %s\n", pimport->size, pimport->filename );
   }

   load_addobj( 0 );
   vmmng_end( out );
//   print("id= %i name= %s \n", pdefine->vmo.id, pdefine->vmo.name );
   *input += _vm.isize;

   return ( pvmobj )pimport;
}

/*-----------------------------------------------------------------------------
*
* ID: load_global 26.12.06 0.0.A.
* 
* Summary: Load global variable object
*
-----------------------------------------------------------------------------*/

pvmobj  STDCALL load_global( pubyte* input )
{
   povmglobal  pglobal;
//   povmtype    ptype;
   pubyte      out;
   uint        size;
   pubyte      ptr = *input;

   ptr = load_common( ptr, &out, sizeof( ovmglobal ));

   pglobal = ( povmglobal )_vm.pmng->top;
   pglobal->type = load_var( &ptr, &out, 1, &size, 1 );
//   pglobal->pval = out;
//   out += max( sizeof( uint ), (( povmtype )PCMD( pglobal->type->type ))->size );
   load_addobj( 0 );
   vmmng_end( out );

//   ptype = ( povmtype )PCMD( pglobal->type->type );
   if ( pglobal->type->type == TReserved && pglobal->type->ptr )
      size = max( 4, *pglobal->type->ptr );
   else
      size = max( 4, (( povmtype )PCMD( pglobal->type->type ))->size );

   pglobal->pval = ( pubyte )vmmng_begin( size );
   _pvm->pmng->top = pglobal->pval + size;
//   print("GLOBAL id= %i name= %s size = %i type=%i - %x\n", pglobal->vmo.id, pglobal->vmo.name,
//           size, *pglobal->type->ptr, pglobal->pval );
   *input += _vm.isize;

   return ( pvmobj )pglobal;
}

/*-----------------------------------------------------------------------------
*
* ID: load_alias 26.12.06 0.0.A.
* 
* Summary: Load alias object
*
-----------------------------------------------------------------------------*/

pvmobj  STDCALL load_alias( pubyte* input )
{
   povmalias   palias;
   pubyte      out;
//   uint        size;
   pubyte      ptr = *input;

   ptr = load_common( ptr, &out, sizeof( ovmalias ));

   palias = ( povmalias )_vm.pmng->top;
   palias->idlink = load_convert( &ptr );   
   load_addobj( 0 );
   vmmng_end( out );
   *input += _vm.isize;

   return ( pvmobj )palias;
}

//-----------------------------------------------------------------------------
