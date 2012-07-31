/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: vmrun 26.12.06 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
* Contributors: santy
*
* Summary: 
* 
******************************************************************************/

#include "vmtype.h"
#include "vmload.h"
#include "vm-a.h"
#include "../common/collection.h"
#include "../genteeapi/gentee.h"
//#include "../bytecode/bytecode.h"

//--------------------------------------------------------------------------

void STDCALL pseudo_i( pstackpos curpos )
{
   uint       cmd = *curpos->cmd;
   pint       pop1 = curpos->top - SSI1;
   pint       pop2 = curpos->top - SSI2;
   int        val1 = *pop1;
   int        val2 = *pop2;

   switch ( cmd )
   {
      case CMulII:   *pop2 *= val1; break;
      case CDivII:   *pop2 /= val1; break;
      case CModII:   *pop2 %= val1; break;
      case CLeftII:  *pop2 <<= val1; break;
      case CRightII: *pop2 >>= val1; break;
      case CSignI:   *pop1 = -val1; break;
      case CLessII:  *pop2 = val2 < val1 ? 1 : 0; break;
      case CGreaterII:  *pop2 = val2 > val1 ? 1 : 0; break;
      case CMulI:   *( pint )val2 *= val1; goto seti;
      case CDivI:   *( pint )val2 /= val1; goto seti;
      case CModI:   *( pint )val2 %= val1; goto seti;
      case CLeftI:  *( pint )val2 <<= val1; goto seti;
      case CRightI: *( pint )val2 >>= val1; goto seti;
      case CMulB:   *( pchar )val2 *= val1; goto setb;
      case CDivB:   *( pchar )val2 /= val1; goto setb;
      case CModB:   *( pchar )val2 %= val1; goto setb;
      case CLeftB:  *( pchar )val2 <<= val1; goto setb;
      case CRightB: *( pchar )val2 >>= val1; goto setb;
      case CMulS:   *( pshort )val2 *= val1; goto sets;
      case CDivS:   *( pshort )val2 /= val1; goto sets;
      case CModS:   *( pshort )val2 %= val1; goto sets;
      case CLeftS:  *( pshort )val2 <<= val1; goto sets;
      case CRightS: *( pshort )val2 >>= val1; goto sets;
      case Cd2f: *( float* )pop2 = (float)*( double * )pop2; break;
      case Cd2i: *( int* )pop2 = (int)*( double * )pop2; break;
      case Cd2l: *( long64* )pop2 = ( long64 )*( double * )pop2; break;
      case Cf2d: *( double* )pop1 = ( double )*( float * )pop1; break;
      case Cf2i: *( int* )pop1 = ( int )*( float * )pop1; break;
      case Cf2l: *( long64* )pop1 = ( long64 )*( float * )pop1; break;
      case Ci2d: *( double* )pop1 = ( double )*( int * )pop1; break;
      case Ci2f: *( float* )pop1 = (float)*( int * )pop1; break;
      case Ci2l: *( long64* )pop1 = ( long64 )*( int * )pop1; break;
      case Cl2d: *( double* )pop2 = ( double )*( long64 * )pop2; break;
      case Cl2f: *( float* )pop2 = (float)*( long64 * )pop2; break;
      case Cl2i: *( int* )pop2 = ( int )*( long64 * )pop2; break;
      case Cui2d: *( double* )pop1 = ( double )*( uint * )pop1; break;
      case Cui2f: *( float* )pop1 = (float)*( uint * )pop1; break;
      case Cui2l: *( long64* )pop1 = ( long64 )*( uint * )pop1; break;
   }
   return;
seti:
   *pop2 = *( pint )val2;
   return;
setb:
   *pop2 = *( pchar )val2;
   return;
sets:
   *pop2 = *( pshort )val2;
}

//--------------------------------------------------------------------------

void STDCALL pseudo_ul( pstackpos curpos )
{
   uint          cmd = *curpos->cmd;
   pulong64      pop1 = ( pulong64 )( curpos->top - SSL1 );
   pulong64      pop2 = ( pulong64 )( curpos->top - SSL2 );
   ulong64       val1 = *pop1;
   ulong64       val2 = *pop2;

   switch ( cmd )
   {
      case CAddULUL: *pop2 += val1; break;
      case CSubULUL: *pop2 -= val1; break;
      case CMulULUL: *pop2 *= val1; break;
      case CDivULUL: *pop2 /= val1; break;
      case CModULUL: *pop2 %= val1; break;
      case CAndULUL: *pop2 &= val1; break;
      case COrULUL:  *pop2 |= val1; break;
      case CXorULUL: *pop2 ^= val1; break;
      case CLeftULUL:  *pop2 <<= val1; break;
      case CRightULUL: *pop2 >>= val1; break;
      case CLessULUL:     *( puint )pop2 = val2 < val1 ? 1 : 0; break;
      case CGreaterULUL:  *( puint )pop2 = val2 > val1 ? 1 : 0; break;
      case CEqULUL:       *( puint )pop2 = val1 == val2 ? 1 : 0; break;
      case CNotUL:        *pop1 = ~val1; break;
   }
}

//--------------------------------------------------------------------------

void STDCALL pseudo_pul( pstackpos curpos )
{
   pulong64   pop1 = ( pulong64 )( curpos->top - SSL1 );
   pulong64   pul = ( pulong64 )*( curpos->top - SSI1 );
   puint      pop2 = curpos->top - SSI3;
   ulong64    val1 = *pop1;
   uint       val2 = *pop2;

   switch ( *curpos->cmd )
   {
      case CIncLeftUL:  *( pulong64 )( curpos->top - SSI1 ) =  ++( *pul ); return;
      case CIncRightUL: *( pulong64 )( curpos->top - SSI1 ) =  ( *pul )++; return;
      case CDecLeftUL:  *( pulong64 )( curpos->top - SSI1 ) =  --( *pul ); return;
      case CDecRightUL: *( pulong64 )( curpos->top - SSI1 ) =  ( *pul )--; return;
      case CAddUL:   *( pulong64 )val2 += val1; break;
      case CSubUL:   *( pulong64 )val2 -= val1; break;
      case CMulUL:   *( pulong64 )val2 *= val1; break;
      case CDivUL:   *( pulong64 )val2 /= val1; break;
      case CModUL:   *( pulong64 )val2 %= val1; break;
      case CAndUL:   *( pulong64 )val2 &= val1; break;
      case COrUL:    *( pulong64 )val2 |= val1; break;
      case CXorUL:   *( pulong64 )val2 ^= val1; break;
      case CLeftUL:  *( pulong64 )val2 <<= val1; break;
      case CRightUL: *( pulong64 )val2 >>= val1; break;
   }
   *( pulong64 )pop2 = *( pulong64 )val2;
}

//--------------------------------------------------------------------------

void STDCALL pseudo_l( pstackpos curpos )
{
   plong64      pop1 = ( plong64 )( curpos->top - SSL1 );
   plong64      pop2 = ( plong64 )( curpos->top - SSL2 );
   long64       val1 = *pop1;
   long64       val2 = *pop2;

   switch ( *curpos->cmd )
   {
      case CMulLL: *pop2 *= val1; break;
      case CDivLL: *pop2 /= val1; break;
      case CModLL: *pop2 %= val1; break;
      case CLeftLL:    *pop2 <<= val1; break;
      case CRightLL:   *pop2 >>= val1; break;
      case CSignL:     *pop1 = -val1; break;
      case CLessLL:    *( puint )pop2 = val2 < val1 ? 1 : 0; break;
      case CGreaterLL: *( puint )pop2 = val2 > val1 ? 1 : 0; break;
   }
}

//--------------------------------------------------------------------------

void STDCALL pseudo_pl( pstackpos curpos )
{
   plong64    pop1 = ( plong64 )( curpos->top - SSL1 );
   puint      pop2 = curpos->top - SSI3;
   long64     val1 = *pop1;
   uint       val2 = *pop2;

   switch ( *curpos->cmd )
   {
      case CMulL:   *( plong64 )val2 *= val1; break;
      case CDivL:   *( plong64 )val2 /= val1; break;
      case CModL:   *( plong64 )val2 %= val1; break;
      case CLeftL:  *( plong64 )val2 <<= val1; break;
      case CRightL: *( plong64 )val2 >>= val1; break;
   }
   *( plong64 )pop2 = *( plong64 )val2;
}

//--------------------------------------------------------------------------

void STDCALL pseudo_f( pstackpos curpos )
{
   float*     pop1 = ( float* )( curpos->top - SSI1 );
   float*     pop2 = ( float* )( curpos->top - SSI2 );
   float      val1 = *pop1;
   float      val2 = *pop2;

   switch ( *curpos->cmd )
   {
      case CAddFF:  *pop2 += val1; break;
      case CSubFF:  *pop2 -= val1; break;
      case CMulFF:  *pop2 *= val1; break;
      case CDivFF:  *pop2 /= val1; break;
      case CSignF:  *pop1 = -val1; break;
      case CLessFF:    *( puint )pop2 = val2 < val1 ? 1 : 0; break;
      case CGreaterFF: *( puint )pop2 = val2 > val1 ? 1 : 0; break;
      case CEqFF:      *( puint )pop2 = val1 == val2 ? 1 : 0; break;
   }
}

//--------------------------------------------------------------------------

void STDCALL pseudo_pf( pstackpos curpos )
{
   float*     pop1 = ( float* )( curpos->top - SSI1 );
   float*     pf = ( float* )*( curpos->top - SSI1 );
   puint      pop2 = curpos->top - SSI2;
   float      val1 = *pop1;
   uint       val2 = *pop2;

   switch ( *curpos->cmd )
   {
      case CIncLeftF:  *pop1 =  ++(*pf); return;
      case CIncRightF: *pop1 = (*pf)++ ; return;
      case CDecLeftF:  *pop1 =  --(*pf); return;
      case CDecRightF: *pop1 =  (*pf)--; return;
      case CAddF:      *( float* )val2 += val1; break;
      case CSubF:      *( float* )val2 -= val1; break;
      case CMulF:      *( float* )val2 *= val1; break;
      case CDivF:      *( float* )val2 /= val1; break;
   }
   *( float* )pop2 = *( float* )val2;
}

//--------------------------------------------------------------------------

void STDCALL pseudo_d( pstackpos curpos )
{
   double*     pop1 = ( double* )( curpos->top - SSL1 );
   double*     pop2 = ( double* )( curpos->top - SSL2 );
   double      val1 = *pop1;
   double      val2 = *pop2;

   switch ( *curpos->cmd )
   {
      case CAddDD:  *pop2 += val1; break;
      case CSubDD:  *pop2 -= val1; break;
      case CMulDD:  *pop2 *= val1; break;
      case CDivDD:  *pop2 /= val1; break;
      case CSignD:  *pop1 = -val1; break;
      case CLessDD:    *( puint )pop2 = val2 < val1 ? 1 : 0; break;
      case CGreaterDD: *( puint )pop2 = val2 > val1 ? 1 : 0; break;
      case CEqDD:      *( puint )pop2 = val1 == val2 ? 1 : 0; break;
   }
}

//--------------------------------------------------------------------------

void STDCALL pseudo_pd( pstackpos curpos )
{
   double*    pop1 = ( double* )( curpos->top - SSL1 );
   double*    pd = ( double* )*( curpos->top - SSI1 );
   puint      pop2 = curpos->top - SSI3;
   double     val1 = *pop1;
   uint       val2 = *pop2;

   switch ( *curpos->cmd )
   {
      case CIncLeftD:  *( double* )( curpos->top - SSI1 ) =  ++( *pd ); return;
      case CIncRightD: *( double* )( curpos->top - SSI1 ) =  ( *pd )++; return;
      case CDecLeftD:  *( double* )( curpos->top - SSI1 ) =  --( *pd ); return;
      case CDecRightD: *( double* )( curpos->top - SSI1 ) =  ( *pd )--; return;
      case CAddD:  *( double* )val2 += val1; break;
      case CSubD:  *( double* )val2 -= val1; break;
      case CMulD:  *( double* )val2 *= val1; break;
      case CDivD:  *( double* )val2 /= val1; break;
   }
   *( double* )pop2 = *( double* )val2;
}

//--------------------------------------------------------------------------

void STDCALL pseudo_ui( pstackpos curpos )
{
   puint     pop1 = curpos->top - SSI1;
   puint     pop2 = curpos->top - SSI2;
   uint      val1 = *pop1;
   uint      val2 = *pop2;

   switch ( *curpos->cmd )
   {
      case CIncLeftUB:  *pop1 =  ++( *( pubyte )val1 ); break;
      case CIncRightUB: *pop1 =  ( *( pubyte )val1 )++; break;
      case CDecLeftUB:  *pop1 =  --( *( pubyte )val1 ); break;
      case CDecRightUB: *pop1 =  ( *( pubyte )val1 )--; break;
      case CAddUB:      *( pubyte )val2 += ( ubyte )val1; goto setub;
      case CSubUB:      *( pubyte )val2 -= ( ubyte )val1; goto setub;
      case CMulUB:      *( pubyte )val2 *= ( ubyte )val1; goto setub;
      case CDivUB:      *( pubyte )val2 /= ( ubyte )val1; goto setub;
      case CModUB:      *( pubyte )val2 %= ( ubyte )val1; goto setub;
      case CAndUB:      *( pubyte )val2 &= ( ubyte )val1; goto setub;
      case COrUB:       *( pubyte )val2 |= ( ubyte )val1; goto setub;
      case CXorUB:      *( pubyte )val2 ^= ( ubyte )val1; goto setub;
      case CLeftUB:     *( pubyte )val2 <<= ( ubyte )val1; goto setub;
      case CRightUB:    *( pubyte )val2 >>= ( ubyte )val1; goto setub;
      case CIncLeftUS:  *pop1 =  ++( *( pushort )val1 ); break;
      case CIncRightUS: *pop1 =  ( *( pushort )val1 )++; break;
      case CDecLeftUS:  *pop1 =  --( *( pushort )val1 ); break;
      case CDecRightUS: *pop1 =  ( *( pushort )val1 )--; break;
      case CAddUS:   *( pushort )val2 += ( ushort )val1; goto setus;
      case CSubUS:   *( pushort )val2 -= ( ushort )val1; goto setus;
      case CMulUS:   *( pushort )val2 *= ( ushort )val1; goto setus;
      case CDivUS:   *( pushort )val2 /= ( ushort )val1; goto setus;
      case CModUS:   *( pushort )val2 %= ( ushort )val1; goto setus;
      case CAndUS:   *( pushort )val2 &= ( ushort )val1; goto setus;
      case COrUS:    *( pushort )val2 |= ( ushort )val1; goto setus;
      case CXorUS:   *( pushort )val2 ^= ( ushort )val1; goto setus;
      case CLeftUS:  *( pushort )val2 <<= ( ushort )val1; goto setus;
      case CRightUS: *( pushort )val2 >>= ( ushort )val1; goto setus;
   }
   return;
setub:
   *pop2 = *( pubyte )val2;
   return;
setus:
   *pop2 = *( pushort )val2;
}

//--------------------------------------------------------------------------

void STDCALL pseudo_collectadd( pstackpos curpos )
{
   uint       num, i, count = *( curpos->cmd + 1 );
   puint      start = curpos->top SSS count;
   pcollect   pclt;
   buf        stack;
   puint      cur = curpos->top - SSI1;

   pclt = ( pcollect )*( start - SSI1 );

   buf_reserve( buf_init( &stack ), 128 );
   i = count;

   while ( i )
   {
      num = *cur >> 24;
      buf_appenduint( &stack, num );
      buf_appenduint( &stack, *cur & 0xFFFFFF );
//      print("Num=%i Cur = %i\n", num, *cur & 0xFFFFFF );
      cur SSSS;
      i -= 1 + num;
   }
   while ( stack.use )
   {
      stack.use -= 8;
      num = *( puint )( stack.data + stack.use );
      while ( num )
      {
         i = collect_add( pclt, start, *( puint )( stack.data + 
                            stack.use + 4 ) ) - start;
         num -= i;
         start SSAE i;
      }
//      start++;
   }
   buf_delete( &stack );

   curpos->top SSSE count;
}

/*-----------------------------------------------------------------------------
*
* ID: vm_run 26.12.06 0.0.A.
* 
* Summary: Execute VM
*
* Params: vmp - virtual machine
          id - the id of the func to run
          params - The pointer to parameters
          result - The pointer for getting the result value
*
-----------------------------------------------------------------------------*/

//puint        ivm;

uint  STDCALL vm_run( uint id, puint params, puint result, uint stacksize )
{
//register  puint    ivm;
   uint         cmd, i;
   puint        stack;       // The main stack
// слева у стэка идет стэк значений, а справа навстречу ему стэк состояний 
// вызовов
   pstackpos    curpos;      // текущее состояние вызова
   pstackpos    endpos;      // первоначальное состояние вызова
   uint         load[2];     // load id + return
   uint         uiret;       // The count of return uints
   pvmfunc      curfunc;     // текущий байт-код
//   pvmobj       obj;
   pvoid        exfunc;
   uint         val1, val2;
   puint        pop1, pop2;
   puint        top;
   double       d;
   uint         val, valhi;
   pvartype     pvar;
   pvarset      pset;
   povmbcode    bcode;
   povmtype     ptype;

   stack = ( puint )mem_alloc( stacksize );

#ifdef GASM
   curpos = ( pstackpos )stack;
   endpos = curpos;
   curpos->start = ( puint )( ( pubyte )stack + stacksize - sizeof( uint ));
#else
   curpos = ( pstackpos )( ( pubyte )stack + stacksize - sizeof( stackpos ));
   endpos = curpos;
   curpos->start = stack;
#endif
   load[ 0 ] = id;
   load[ 1 ] = CReturn;

   curpos->cmd = ( puint )&load;

   if ( id >= _vm.count )
   {
      cmd = id;
      goto error;
   }
//   pcmd = ( puint )arr_ptr( &vmp->objtbl, 0 );

   curfunc = ( pvmfunc )PCMD( id );// pcmd + id );
   uiret = curfunc->dwret;
   curpos->top = curpos->start;
   
   // Для text функции определяем стандартный вывод как 0
   if ( curfunc->vmo.flag & GHBC_TEXT )
      *curpos->top SSAA = 0;

// заносим в стэк параметры
   if ( params )
   {
#ifdef GASM
      mem_copyui( curpos->top - curfunc->parsize + 1, params, curfunc->parsize );
#else
      mem_copyui( curpos->top, params, curfunc->parsize );
#endif
      curpos->top SSAE curfunc->parsize;
   }
   curpos->clmark = curpos->top;
//   print("Func=%x %s id=%i pars=%i Val=%x\n", 
//          curfunc, curfunc->vmobj.name, id, curfunc->dwpars, *curpos->start );
   while ( 1 )
   {
      // Берем команду
      if (( cmd = *curpos->cmd ) >= _vm.count )
         goto error;
//      if ( (uint)curpos->cmd & 3 || (uint)curpos->top & 3 )
         print("CMD=%x\n", cmd );
stackcmd:
//      obj = *( pvmobj* )( pcmd + cmd );
      curfunc = ( pvmfunc )PCMD( cmd );
      switch ( curfunc->vmo.type )
      {
         case OVM_STACKCMD: goto stack;
         case OVM_PSEUDOCMD: goto pseudo;
         case OVM_BYTECODE: goto bcode;
         case OVM_EXFUNC: goto exfunc;
         case OVM_TYPE: goto type;
      }
      goto error;
//----------------   Stack commands --------------------------------------
stack:
      pop1 = curpos->top - SSI1;
      val1 = *pop1;
      pop2 = curpos->top - SSI2;
      val2 = *pop2;
      print("%x 1=%i 2=%i\n", curpos->top, val1, val2 );
      switch ( cmd )
      {
         case CNop: break;
         case CGoto: 
            curpos->top = curpos->clmark;
         case CGotonocls:
            curpos->cmd = ( puint )curpos->func->func + *( curpos->cmd + 1 ) - 2;
            break;
         case CIfze:
            curpos->top = curpos->clmark;
         case CIfznocls:
            if ( !val1 )
            {
               curpos->cmd = ( puint )curpos->func->func + *( curpos->cmd + 1 );
               continue;
            }
            break;
         case CIfnze:
            curpos->top = curpos->clmark;
         case CIfnznocls:
            if ( val1 )
            {
               curpos->cmd = ( puint )curpos->func->func + *( curpos->cmd + 1 );
               continue;
            }
            break;
         case CDwload:
         case CCmdload:
         case CResload:
            *curpos->top = *( curpos->cmd + 1 );
            print("DWLOAD=%i\n", *curpos->top );
            break;
         case CQwload:
#ifdef GASM
            *( pulong64 )( curpos->top - 1 ) = *( pulong64 )( curpos->cmd + 1 );
            curpos->top += 2;
#else
            *( pulong64 )curpos->top = *( pulong64 )( curpos->cmd + 1 );
#endif
            break;
         case CDwsload:
            val = *++curpos->cmd;
            while ( val-- )
               *curpos->top SSAA = *++curpos->cmd;
            break;
         case CVarload:
         case CVarptrload:
            i = *( curpos->cmd + 1 );
            if ( i < curpos->func->parcount )
            {
               pvar = curpos->func->params + i;
#ifdef GASM
               top = curpos->start + curpos->func->parsize - pvar->off - 
                    (( povmtype )PCMD( pvar->type ))->stsize;
#else
               top = curpos->start + pvar->off;
#endif
            }
            else
            {
               pvar = BCODE( curpos )->vars + ( i - curpos->func->parcount );
               top = ( puint )*( curpos->start + curpos->func->parsize ) +
                      pvar->off;
            }
            ptype = ( povmtype )PCMD( pvar->type );
//            pvari = curpos->func->parvar + *( curpos->cmd + 1 ); 
//            top = curpos->start + pvari->off;
            if ( cmd == CVarload && ptype->vmo.flag & GHTY_STACK ) 
            {
               *curpos->top = *top;
               if ( ptype->stsize > 1 )
                  * SSAA curpos->top = *++top;
            }
            else
            {
               if ( pvar->flag & VAR_PARAM && //i < curpos->func->parcount && 
                    !( ptype->vmo.flag & GHTY_STACK ))
                  top = ( puint )*top; // For parameters
               *curpos->top = ( uint )top;
            }
            print("VARLOAD = %i off = %i %i\n", 
                      *curpos->top, pvar->off, i );
            break;
         case CDatasize:
            val = *++curpos->cmd;
            *curpos->top SSAA = ( uint )++curpos->cmd;
            // Увеличиваем на 3 : 2 вместо 1 : 0 из-за команда и размера
            curpos->cmd += ( val >> 2 ) + ( val & 3 ? 1 : 0 );
            *curpos->top SSAA = val;
            continue;
         case CLoglongtrue: *pop2 = ( val1 || val2 ? 1 : 0 );  break;
         case CLognot:      *pop1 = !val1; break;
         case CLoglongnot:  *pop2 = ( val1 || val2 ? 0 : 1 ); break;
         case CDup:         *curpos->top = *pop1; break;
         case CDuplong:
            *curpos->top = *pop2;
            *( curpos->top SSA 1 ) = *pop1;
            break;
         case CTop: *curpos->top = ( uint )( curpos->top ); break;
         case CPop: break;
         case CGetUB: *pop1 = *( pubyte )val1; break;
         case CGetB:  *( int *)pop1 = ( int )*( pchar )val1; break;
         case CGetUS: *pop1 = *( pushort )val1; break;
         case CGetS:  *( int *)pop1 = ( int )*( pshort )val1; break;
         case CGetI: *pop1 = *( puint )val1; break;
         case CGetL: 
#ifdef GASM
            *( pulong64 )( pop1 - 1 ) = *( pulong64 )val1; 
#else
            *( pulong64 )pop1 = *( pulong64 )val1; 
#endif
            break;
         case CSetUB: *( pubyte )val2 = ( ubyte )val1; goto set;
         case CSetB:  *( pchar )val2 = ( byte )val1; goto set;
         case CSetUS: *( pushort )val2 = ( ushort )val1; goto set;
         case CSetS:  *( pshort )val2 = ( short )val1; goto set;
         case CSetI:  *( puint )val2 = val1; goto set;
         case CSetL: 
#ifdef GASM
            *( pulong64 )*( curpos->top + 3 ) = *( pulong64 )pop1;
#else
            *( pulong64 )*( curpos->top - 3 ) = *( pulong64 )pop2;
#endif
            *( curpos->top - SSI3 ) = val2; 
            goto set;
         case CAddUIUI:  *pop2 += val1; break;
         case CSubUIUI:  *pop2 -= val1; break;
         case CMulUIUI:  *pop2 *= val1; break;
         case CDivUIUI:  *pop2 /= val1; break;
         case CModUIUI:  *pop2 %= val1; break;
         case CAndUIUI:  *pop2 &= val1; break;
         case COrUIUI:   *pop2 |= val1; break;
         case CXorUIUI:  *pop2 ^= val1; break;
         case CLeftUIUI: *pop2 <<= val1; break;
         case CRightUIUI:   *pop2 >>= val1; break;
         case CLessUIUI:    *pop2 = val2 < val1 ? 1 : 0; break;
         case CGreaterUIUI: *pop2 = val2 > val1 ? 1 : 0; break;
         case CEqUIUI:      *pop2 = val1 == val2 ? 1 : 0; break;
         case CNotUI:       *pop1 = ~val1; break;
         case CIncLeftUI:   *pop1 =  ++( *( puint )val1 ); break;
         case CIncRightUI:  *pop1 =  ( *( puint )val1 )++; break;
         case CDecLeftUI:   *pop1 =  --( *( puint )val1 ); break;
         case CDecRightUI:  *pop1 =  ( *( puint )val1 )--; break;
         case CAddUI:   *( puint )val2 += val1; goto setui;
         case CSubUI:   *( puint )val2 -= val1; goto setui;
         case CMulUI:   *( puint )val2 *= val1; goto setui;
         case CDivUI:   *( puint )val2 /= val1; goto setui;
         case CModUI:   *( puint )val2 %= val1; goto setui;
         case CAndUI:   *( puint )val2 &= val1; goto setui;
         case COrUI:    *( puint )val2 |= val1; goto setui;
         case CXorUI:   *( puint )val2 ^= val1; goto setui;
         case CLeftUI:  *( puint )val2 <<= val1; goto setui;
         case CRightUI: *( puint )val2 >>= val1; goto setui;
         case CVarsInit:  type_setinit( curpos, *( curpos->cmd + 1 )); break;
         case CGetText: *curpos->top = curpos->func->vmo.flag & GHBC_TEXT ? 
                             *( curpos->start SSS 1 ) : 0; break; 
         case CSetText: 
            if ( curpos->func->vmo.flag & GHBC_TEXT && 
                  ( val2 = *( curpos->start SSS 1 )) )
               str_add( ( pstr )val2, ( pstr )val1 );
            else
               str_output( ( pstr )val1 );
            break;
         case CPtrglobal:
            *curpos->top = ( uint )(( povmglobal )
                           PCMD( *( curpos->cmd + 1 )))->pval;
//            print("Global PTR %x %i\n", *curpos->top, *( puint )*curpos->top );
            break;
         case CSubcall:
            // Меняем стэк 
            *curpos->top SSAA = ( uint )( curpos->cmd + 2 ); // указатель на команду после выхода
            *curpos->top SSAA = ( uint )curpos->clmark;  // текущее значение clmark 
            *curpos->top SSAA = 0;               // Количество возвращаемых dword 
            *curpos->top SSAA = 0;               // Количество полученных dword в качестве параметров
            curpos->clmark = curpos->top;     // Новое значение clmark
            // Указатель на первую команду подфункции
            curpos->cmd = ( puint )curpos->func->func + *( curpos->cmd + 1 );
            continue;
         case CSubret:
            *( curpos->clmark - SSI2 ) = *( curpos->cmd + 1 );
            break;
         case CSubpar:
            pset = BCODE( curpos )->sets + *( curpos->cmd + 1 );
            // копируем значения переменных из стэка
            pvar = BCODE( curpos )->vars + pset->first;
            top = ( puint )*( curpos->start + curpos->func->parsize ) + pvar->off;

//            top = curpos->start + ( curpos->func->varb + *++curpos->cmd)->firstoff;
//            curpos->cmd++;
//            print("Top=%i %i\n", *top, *( top + 1 ));
            mem_copyui( top,  curpos->clmark - 4 - pset->size, pset->size );
            *( curpos->clmark - 1 ) = pset->size;
            break;
         case CSubreturn:
            // Выход из подфункции
            top = curpos->clmark - 4;  // Указатель на старый top 
            // Восстанавливаем команду
            curpos->cmd = ( puint )*top;
            curpos->clmark = ( puint )*( top + 1 );
            i = *( top + 2 );
            // записываем возвращаемое значение
            if ( i )
               mem_copyui( top - *( top + 3 ), curpos->top - i, i );
               // Устанавливаем стэк
            curpos->top = top + i - *( top + 3 );
            continue;
         case CCmdcall:
            // Берем из стэка код команды
            top = curpos->top SSS *++curpos->cmd SSS 1;
            cmd = *top;
            // Сдвигаем параметры вызова в стэке
#ifdef GASM
            mem_move( curpos->top + 2, curpos->top + 1, *curpos->cmd << 2 );
#else
            mem_copyui( top, top + 1, *curpos->cmd );
#endif
            // сразу устанавливаем указатель на следующую команду
            curpos->top SSSS;
            goto stackcmd;
         case CCallstd:
            val1 = *++curpos->cmd;  // Флаги вызова
            val2 = *++curpos->cmd;  // Размер параметров
            top = curpos->top;
            for ( i = 0; i < val2; i++ )
            {
               val = * SSSS top;
#ifdef LINUX
    	         __asm__ ("push %0"::"d"(val));
#else
   #if defined ( __GNUC__) || defined (__TINYC__)
               __asm__ ("push %0"::"d"(val));
   #else
               _asm {
                  push val
               }
   #endif
#endif
            }  
            exfunc = ( pvoid )* SSSS top;
#ifdef LINUX
            __asm__ ("call *%0"::"m"(exfunc));
            __asm__ ("mov %%eax,%0":"m="(val));
            __asm__ ("mov %%edx,%0":"m="(valhi));
#else
   #if defined (__GNUC__) 
  
            __asm__ ("call *%0"::"m"(exfunc));
            __asm__ ("mov %%eax,%0":"m="(val));
            __asm__ ("mov %%edx,%0":"m="(valhi));
  
   #elif  defined (__TINYC__)
            __asm__ ("call *%0"::"m"(exfunc));
            __asm__ ("mov %%eax,%0":"m"(val));
            __asm__ ("mov %%edx,%0":"m"(valhi));
   #else
            _asm {
               call exfunc
               mov  val,eax
               mov  valhi,edx
            }
   #endif
#endif

#ifdef LINUX
#else
            if ( val1 )// & GHEX_CDECL )
#endif
            {
               i = val2 << 2;
#ifdef LINUX
               __asm__ ("add %0, %%esp"::"m"(i));
#else
   #if defined ( __GNUC__) || defined (__TINYC__)
               __asm__ ("add %0, %%esp"::"m"(i));
   #else
               _asm {
                  add esp, i
               }
   #endif
#endif
            }
//          if ( (( psovmfunc )curfunc)->dwret )
            *top SSAA = val;
            curpos->top = top;
            break;
         case CReturn:
            if ( curpos == endpos )  // Все выполнили
               goto end;  
            // !!! Insert exception here
/*               if ( vm->lastexcept->start == curpos->start )
               {
                  vm->lastexcept--;
               }*/
            if ( _gentee.debug )
               _gentee.debug( curpos ); 

            // Free all variables
            bcode = BCODE( curpos );

            if ( bcode->setcount )
            {
               for ( i = 0; i < bcode->setcount; i++ )
                  type_setdelete( curpos, i );
               // Освобождаем память под структуры
//    ???      if ( *( curpos->start + pbcode->dwsize - 1 ))
               if ( bcode->varsize > VAR_SIZE )
                  mem_free( ( pvoid )*( curpos->start + curpos->func->parsize ));
            }
            // Возвращаемся в предыдущее состояние
            // если функция возвращает значение, то сохраняем необходимое 
            // количество верхних элементов
            if ( curpos->uiret )
            {
#ifdef GASM
               mem_copyui( ( curpos - 1 )->top, curpos->top + 1,
                           curpos->uiret );
#else
               mem_copyui( ( curpos + 1 )->top, curpos->top - curpos->uiret,
                           curpos->uiret );
#endif
               ( curpos SSA 1 )->top SSAE curpos->uiret;
            }
            curpos SSAA;
/*            if ( exceptfunc )
               {
                  curpos->cmd = curpos->func->finally;
                  *curpos->top++ = 0;
                  *curpos->top++ = 0;
                  if ( curpos->start == exceptfunc ) 
                     exceptfunc = 0;
                  continue;
               }*/
            // cmdshift for CReturn == 1 - shift the calling command
            break;
         case CAsm:
            break;
#ifndef RUNTIME
         case CDbgTrace:
         case CDbgFunc:
            if ( _gentee.debug )
            {
               curpos->nline = ( cmd == CDbgFunc ? *( puint )val2 : val1 ); 
               _gentee.debug( curpos );
            }
            break;
#endif
      }
      goto shift;
pseudo:   // Pseudo stack commands
      (( stackfunc )curfunc->func)( curpos );
      goto shift;
set:
      *pop2 = val1; goto shift;
setui:
      *pop2 = *( puint )val2; goto shift;

shift:
      curpos->top SSAE (( povmstack )curfunc)->topshift;
      curpos->cmd += (( povmstack )curfunc)->cmdshift;
      continue;
//----------------   Bytecode command --------------------------------------
bcode:
      // Проверка переполнения стэка
#ifdef GASM
      if ( curpos->top - 128 < ( puint )curpos )
#else
      if ( curpos->top + 128 > ( puint )curpos )
#endif
         msg( MFullstack | MSG_DVAL, stacksize );
      // Сохраняем текущее состояние увеличив стэк
      print("Call = Top1=%i top2=%i\n", *(curpos->top + 1), *(curpos->top + 2));
      curpos->top SSSE curfunc->parsize;
      curpos SSSS;
      curpos->cmd = curfunc->func;
      curpos->start = ( curpos SSA 1 )->top;
#ifdef GASM
      curpos->start -= curfunc->parsize + 1 + (( povmbcode )curfunc)->setcount;
      mem_copyui( curpos->start, ( curpos - 1 )->top - curfunc->parsize + 1, curfunc->parsize );
      curpos->top = curpos->start - 1;
#else
      curpos->top = curpos->start + curfunc->parsize + 1 + 
                   (( povmbcode )curfunc)->setcount;
#endif
      if ( (( povmbcode )curfunc)->varsize > VAR_SIZE )
      {
         // All variable ar in the extern memory
         ( puint )*( curpos->start + curfunc->parsize ) = mem_alloc( (( povmbcode )curfunc)->varsize << 2 );
      }
      else
      {  // All variables are in the stack
#ifdef GASM
         curpos->top -= (( povmbcode )curfunc)->varsize;
         ( puint )*( curpos->start + curfunc->parsize ) = curpos->top + 1;
#else
         ( puint )*( curpos->start + curfunc->parsize ) = curpos->top;
         curpos->top += (( povmbcode )curfunc)->varsize;
#endif
      }
      print("Call 2 = Top1=%i top2=%i\n", *(curpos->top + 1), *(curpos->top + 2));
      curpos->clmark = curpos->top;
      curpos->uiret = curfunc->dwret;
      curpos->func = curfunc;
      // Зануляем признак отведения памяти для локальных структур
//      *( curpos->top - 1 ) = 0;

      // Зануляем признаки инициализации блоков переменных
      if ( (( povmbcode )curfunc)->setcount )
         mem_zeroui( curpos->start + curfunc->parsize + 1, 
                     (( povmbcode )curfunc)->setcount );
      if ( !curpos->cmd )
         msg( MUndefcmd | MSG_VALSTRERR, curfunc->vmo.name, cmd );
      continue;

//----------------   Exfunc commands --------------------------------------
exfunc:
      exfunc = curfunc->func;
      if ( !exfunc )
         msg( MUndefcmd | MSG_VALSTRERR, curfunc->vmo.name, cmd );
      top = curpos->top;

#ifdef LINUX
		if ( curfunc->vmobj.flag & GHEX_SYSCALL )
      {
         curpos->top = syscall( curfunc, top );
         goto next;
      }
#endif
//      print("PAR=%i parsize=%i ret=%i %s\n", curfunc->parcount,
//              curfunc->parsize, curfunc->dwret, curfunc->vmo.name );
      for ( i = 0; i < curfunc->parsize; i++ )
      {
         val = * SSSS top;
#ifdef LINUX
      	__asm__ ("push %0"::"d"(val));
#else
   #if defined (__GNUC__) || defined (__TINYC__)
      	__asm__ ("push %0"::"d"(val));
   #else
         _asm { push val }
   #endif
#endif
      }
      if ( curfunc->vmo.flag & GHEX_FLOAT )
      {
         if ( curfunc->dwret == 1 )
         {
#ifdef LINUX
            __asm__ ("call *%0"::"m"(exfunc));
           	__asm__ ("fstp %%st":"=m"(val));
#else
   #if defined ( __GNUC__) || defined (__TINYC__)
            __asm__ ("call *%0"::"m"(exfunc));
            __asm__ ("fstp %%st":"=m"(val));

   #else
            _asm {
               call exfunc
               fstp dword ptr [val]
            }
   #endif
#endif
         }
         else
         {
#ifdef LINUX
            __asm__ ("call *%0"::"m"(exfunc));
	         __asm__ ("fstp %%st":"=t"(d):"0"(d));
   		   //__asm__ ("fstp %0":"=r"(&d));
#else
   #if defined (__GNUC__) 
            __asm__ ("call *%0"::"m"(exfunc));
	         __asm__ ("fstp %%st":"=t"(d):"0"(d));
   	    //__asm__ ("fstp %0":"=r"(&d));
   #elif defined (__TINYC__)
            __asm__ ("call *%0"::"m"(exfunc));
            __asm__ ("fstp %%st":"m"(d):"0"(d));
   #else 
            _asm {
               call exfunc
//             fstp qword ptr [d]
               fstp d
            }
   #endif
#endif
            val = *(uint*)&d;
            valhi = *((uint*)&d + 1 );
         }
      }
      else
      {
#ifdef LINUX
         //print( "\07exfunc=%x val=%x\n", exfunc, val );
         __asm__ ("call *%0"::"m"(exfunc));
         __asm__ ("mov %%eax,%0":"m="(val));
         __asm__ ("mov %%edx,%0":"m="(valhi));
#else
   #if defined (__GNUC__) 
         __asm__ ("call *%0"::"m"(exfunc));
         __asm__ ("mov %%eax,%0":"m="(val));
         __asm__ ("mov %%edx,%0":"m="(valhi));
   #elif defined (__TINYC__)
         __asm__ ("call *%0"::"m"(exfunc));
         __asm__ ("mov %%eax,%0":"m"(val));
         __asm__ ("mov %%edx,%0":"m"(valhi));
   #else
         _asm {
            call exfunc
            mov  val,eax
            mov  valhi,edx
         }
   #endif
#endif
      }
#ifdef LINUX
#else
      if ( curfunc->vmo.flag & GHEX_CDECL )
#endif
      {
         i = curfunc->parsize << 2;
#ifdef LINUX
         __asm__ ("add %0, %%esp"::"m"(i));
#else
   #if defined (__GNUC__) || defined (__TINYC__)
         __asm__ ("add %0, %%esp"::"m"(i));
   #else
         _asm { add esp, i }
   #endif
#endif
      }
#ifdef GASM
      if ( curfunc->dwret == 2 )
         *top-- = valhi;
      if ( curfunc->dwret )
         *top-- = val;
#else
      if ( curfunc->dwret )
         *top++ = val;
      if ( curfunc->dwret == 2 )
         *top++ = valhi;
#endif
      curpos->top = top;
      goto next;

//----------------   Type command --------------------------------------
type:
      *curpos->top SSAA = cmd;
      goto next;

//----------------   Getting next command ------------------------------
next:
      curpos->cmd++;
   }

end:
// Copy the result value
   if ( result )
#ifdef GASM
      mem_copyui( result, curpos->top + 1, uiret );
#else
      mem_copyui( result, curpos->top - uiret, uiret );
#endif
// Free stack
   mem_free( stack );

   return 1;
error:
   msg( MUnkbcode | MSG_DVAL, cmd );
   return 0;
}

//--------------------------------------------------------------------------

uint  STDCALL vm_runone( uint id, uint first )
{
   uint  ret;
   // Изменяем размеры стэка для функций вызываемых из виртуальной машины
//   _vm.stacksize = 8192;
   vm_run( id, &first, &ret, 8192 );
//   _vm.stacksize = size;
   return ret;
}

//--------------------------------------------------------------------------

uint  STDCALL vm_runtwo( uint id, uint first, uint second )
{
   uint  ret;
//   uint  size = _vm.stacksize;
   uint  params[4];

   // Изменяем размеры стэка для функций вызываемых из виртуальной машины
//   _vm.stacksize = 8192;
   params[0] = first;
   params[1] = second;
   vm_run( id, ( puint )&params, &ret, 8192 );
//   _vm.stacksize = size;
   return ret;
}

/*-----------------------------------------------------------------------------
* Id: gentee_call F
* 
* Summary: Call the function from the bytecode. The bytecode should be 
           previously loaded with the $[gentee_load] or $[gentee_compile]
           functions. 
*
* Params: id - The identifier of the called object. Can be obtained by /
               $[gentee_getid] function.
          result - Pointer to the memory space, to which the result will be /
                   written. It can be the pointer to #b(uint), #b(long) or  /
                   #b(double).
          ... - Required parameters of the function. 
*
* Return: #lng/retf#
*  
-----------------------------------------------------------------------------*/

uint  CDECLCALL gentee_call( uint id, puint result, ... )
{
   uint        ok = 0;
   pvmfunc     curfunc;
   va_list     argptr;
   uint        i = 0;
   uint        params[ 64 ];
//   uint        size = _vm.stacksize;

//   _vm.stacksize = 0x8000; // 32KB
   va_start( argptr, result );
   
   curfunc = ( pvmfunc )PCMD( id );
   if ( curfunc->vmo.flag & GHRT_MAYCALL )
   {
      while ( i < curfunc->parsize )
         params[ i++ ] = va_arg( argptr, uint );

      ok = vm_run( id, ( puint )&params, result, 0x8000 );
   }
   va_end( argptr );
//   _vm.stacksize = size;

   return ok;
}

uint  STDCALL vm_calladdr( void )
{
   return ( uint )&gentee_call;
}

//-----------------------------------------------------------------------------