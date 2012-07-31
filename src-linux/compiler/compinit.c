/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: compinit 18.10.06 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
* Conributors: santy
* Summary: 
* 
******************************************************************************/

#include "compinit.h"
#include "../vm/vm.h"
#include "../vm/vmload.h"
#include "../vm/vmmanage.h"

uint    _compinit = 0;   
uint    _lexlist[ OPERCOUNT ];

typedef struct
{
   ubyte   left;     // Type of the left operand
   ubyte   right;    // Type of the right operand
   ubyte   ret;      // Type of the result
} oppar, * poppar;

// Структура описания встроенных операций
typedef struct
{
   ubyte   oper;     // Oparation
   ubyte   bc;       // stack byte code
} oper, * poper;

enum
{  // left_right_result 
   B_I_I = 0,
   B_0_I,
   UB_UI_UI,
   UB_0_UI,
   S_I_I,
   S_0_I,
   US_UI_UI,
   US_0_UI,
   UI_UI_UI,
   UI_0_UI,
   UI_0_I,
   I_I_I,
   I_0_I,
   I_I_UI,
   UL_UL_UL,
   UL_0_UL,
   UL_UL_UI,
   UL_0_UI,
   UL_0_L,
   L_L_L,
   L_0_L,
   L_L_UI,
   F_F_F,
   F_0_F,
   F_F_UI,
   F_0_UI,
   D_D_D,
   D_0_D,
   D_D_UI,
   D_0_UI,
   ST_ST_ST,
   ST_0_ST,
};

const oppar oppars[]={
   { TByte,  TInt, TInt },    // B_I_I
   { TByte,     0, TInt },    // B_0_I
   { TUbyte,    TUint, TUint },   // UB_UI_UI
   { TUbyte,        0, TUint },   // UB_0_UI
   { TShort,     TInt, TInt },    // T_I_I
   { TShort,        0, TInt },    // T_0_I
   { TUshort,   TUint, TUint },   // UT_UI_UI
   { TUshort,       0, TUint },   // UT_0_UI
   { TUint,     TUint, TUint },   // UI_UI_UI
   { TUint,         0, TUint },   // UI_0_UI
   { TUint,         0,  TInt },   // UI_0_I
   { TInt,       TInt,  TInt },   // I_I_I
   { TInt,          0,  TInt },   // I_0_I
   { TInt,       TInt, TUint },   // I_I_UI
   { TUlong,   TUlong, TUlong },   // UL_UL_UL
   { TUlong,        0, TUlong },   // UL_0_UL
   { TUlong,   TUlong,  TUint },   // UL_UL_UI
   { TUlong,        0,  TUint },   // UL_0_UI
   { TUlong,        0,  TLong },   // UL_0_L
   { TLong,     TLong,  TLong },   // L_L_L
   { TLong,         0,  TLong },   // L_0_L
   { TLong,     TLong,  TUint },   // L_L_UI
   { TFloat,   TFloat, TFloat },   // F_F_F
   { TFloat,        0, TFloat },   // F_0_F
   { TFloat,   TFloat,  TUint },   // F_F_UI
   { TFloat,        0,  TUint },   // F_0_UI
   { TDouble, TDouble, TDouble },  // D_D_D
   { TDouble,       0, TDouble },  // D_0_D
   { TDouble, TDouble,  TUint },   // D_D_UI
   { TDouble,       0,  TUint },   // D_0_UI
   { TStr,       TStr,   TStr },   // TT_TT_TT
   { TStr,          0,   TStr },   // TT_0_TT
};

const  oper  operpars[]={
{ 0xFF, B_I_I },
{ OpSet, CSetUB }, { OpAddset, CAddUB },  { OpSubset, CSubUB },
{ OpMulset,  CMulB }, { OpDivset, CDivB }, { OpModset, CModB },
{ OpLeftset, CLeftB },{ OpRightset, CRightB },
{ 0xFF, B_0_I },
{ OpIncleft, CIncLeftUB }, { OpIncright, CIncRightUB }, { OpDecleft, CDecLeftUB },
{ OpDecright, CDecRightUB },

{ 0xFF, UB_UI_UI },
{ OpSet, CSetUB }, { OpAddset, CAddUB }, { OpSubset, CSubUB },
{ OpMulset,  CMulUB }, { OpDivset, CDivUB }, { OpModset, CModUB },
{ OpAndset,  CAndUB }, { OpOrset,  COrUB },  { OpXorset, CXorUB },
{ OpLeftset, CLeftB },{ OpRightset, CRightB },
{ 0xFF, UB_0_UI },
{ OpIncleft,  CIncLeftUB }, { OpIncright, CIncRightUB }, { OpDecleft,  CDecLeftUB },
{ OpDecright, CDecRightUB }, { OpLognot, CLognot },

{ 0xFF, S_I_I },
{ OpSet, CSetUS },{ OpAddset, CAddUS },{ OpSubset, CSubUS },
{ OpMulset, CMulS },  { OpDivset, CDivS }, { OpModset, CModS },
{ OpLeftset, CLeftS },{ OpRightset, CRightS },
{ 0xFF, S_0_I },
{ OpIncleft, CIncLeftUS }, { OpIncright, CIncRightUS }, { OpDecleft, CDecLeftUS },
{ OpDecright, CDecRightUS },

{ 0xFF, US_UI_UI },
{ OpSet, CSetUS }, { OpAddset, CAddUS }, { OpSubset, CSubUS },
{ OpMulset, CMulUS }, { OpDivset, CDivUS }, { OpModset, CModUS },
{ OpAndset, CAndUS }, { OpOrset, COrUS },   { OpXorset, CXorUS },
{ OpLeftset, CLeftUS }, { OpRightset, CRightUS },
{ 0xFF, US_0_UI },
{ OpIncleft, CIncLeftUS }, { OpIncright, CIncRightUS },
{ OpDecleft, CDecLeftUS }, { OpDecright, CDecRightUS },

{ 0xFF, UI_UI_UI },
{ OpSet, CSetI }, { OpAdd, CAddUIUI }, { OpSub, CSubUIUI },
{ OpMul, CMulUIUI }, { OpDiv, CDivUIUI }, { OpMod, CModUIUI },
{ OpBinand, CAndUIUI }, { OpBinor,  COrUIUI },  { OpBinxor, CXorUIUI },
{ OpLeft, CLeftUIUI }, { OpRight, CRightUIUI }, { OpLess, CLessUIUI },
{ OpEq, CEqUIUI },   { OpGreater, CGreaterUIUI },
{ OpAddset, CAddUI }, { OpSubset, CSubUI }, { OpMulset, CMulUI },
{ OpDivset, CDivUI }, { OpModset, CModUI }, { OpAndset, CAndUI },
{ OpOrset, COrUI },   { OpXorset, CXorUI }, { OpLeftset, CLeftUI },
{ OpRightset, CRightUI },
{ 0xFF, UI_0_UI },
{ OpBinnot, CNotUI }, { OpLognot, CLognot }, { OpIncleft, CIncLeftUI }, 
{ OpIncright, CIncRightUI }, { OpDecleft, CDecLeftUI }, { OpDecright, CDecRightUI },
{ 0xFF, UI_0_I },
{ OpMinus, CSignI },

{ 0xFF, I_I_I },
{ OpSet, CSetI }, { OpAdd, CAddUIUI }, { OpSub, CSubUIUI },
{ OpMul, CMulUIUI },   { OpDiv, CDivII },   { OpMod, CModII },
{ OpLeft, CLeftUIUI }, { OpRight, CRightII }, { OpAddset, CAddUI },
{ OpSubset, CSubUI }, { OpMulset, CMulUI },  { OpDivset, CDivI },
{ OpModset, CModI },  { OpLeftset, CLeftUI },{ OpRightset, CRightI },
{ 0xFF, I_0_I },
{ OpMinus, CSignI }, { OpIncleft, CIncLeftUI }, { OpIncright, CIncRightUI },
{ OpDecleft, CDecLeftUI }, { OpDecright, CDecRightUI },
{ 0xFF, I_I_UI },
{ OpLess, CLessII }, { OpGreater, CGreaterII },

{ 0xFF, UL_UL_UL },
{ OpSet, CSetL }, { OpAdd, CAddULUL }, { OpSub, CSubULUL },
{ OpMul, CMulULUL }, { OpDiv, CDivULUL }, { OpMod, CModULUL },
{ OpBinand, CAndULUL }, { OpBinor, COrULUL }, { OpBinxor, CXorULUL },
{ OpLeft, CLeftULUL }, { OpRight, CRightULUL },
{ OpAddset, CAddUL }, { OpSubset, CSubUL }, { OpMulset, CMulUL },
{ OpDivset, CDivUL }, { OpModset, CModUL }, { OpAndset, CAndUL },
{ OpOrset, COrUL },   { OpXorset, CXorUL }, { OpLeftset, CLeftUL },
{ OpRightset, CRightUL },
{ 0xFF, UL_0_UL },
{ OpBinnot, CNotUL }, { OpIncleft, CIncLeftUL }, { OpIncright, CIncRightUL },
{ OpDecleft, CDecLeftUL }, { OpDecright, CDecRightUL },
{ 0xFF, UL_UL_UI },
{ OpLess, CLessULUL }, { OpEq, CEqULUL }, { OpGreater, CGreaterULUL },
{ 0xFF, UL_0_UI },
{ OpLognot, CLoglongnot },
{ 0xFF, UL_0_L },
{ OpMinus, CSignL },

{ 0xFF, L_L_L },
{ OpSet, CSetL }, { OpAdd, CAddULUL }, { OpSub, CSubULUL },
{ OpMul, CMulLL },   { OpDiv, CDivLL },   { OpMod, CModLL },
{ OpLeft, CLeftLL }, { OpRight, CRightLL },{ OpAddset, CAddUL },
{ OpSubset, CSubUL }, { OpMulset, CMulL },  { OpDivset, CDivL },
{ OpModset, CModL },  { OpLeftset, CLeftL },{ OpRightset, CRightL },
{ 0xFF, L_0_L },
{ OpMinus, CSignL },  { OpIncleft, CIncLeftUL }, { OpIncright, CIncRightUL },
{ OpDecleft, CDecLeftUL }, { OpDecright, CDecRightUL },
{ 0xFF, L_L_UI },
{ OpLess, CLessLL }, { OpGreater, CGreaterLL },

{ 0xFF, F_F_F },
{ OpSet, CSetI }, { OpAdd, CAddFF }, { OpSub, CSubFF },
{ OpMul, CMulFF },   { OpDiv, CDivFF }, { OpAddset, CAddF },
{ OpSubset, CSubF },  { OpMulset, CMulF },{ OpDivset, CDivF },
{ 0xFF, F_0_F },
{ OpMinus, CSignF },  { OpIncleft, CIncLeftF }, { OpIncright, CIncRightF },
{ OpDecleft, CDecLeftF }, { OpDecright, CDecRightF },
{ 0xFF, F_F_UI },
{ OpLess, CLessFF }, { OpEq, CEqFF }, { OpGreater, CGreaterFF },
{ 0xFF, F_0_UI },
{ OpLognot, CLognot },

{ 0xFF, D_D_D },
{ OpSet, CSetL }, { OpAdd, CAddDD }, { OpSub, CSubDD },
{ OpMul,   CMulDD }, { OpDiv, CDivDD }, { OpAddset, CAddD },
{ OpSubset,  CSubD }, { OpMulset, CMulD }, { OpDivset, CDivD },
{ 0xFF, D_0_D },
{ OpMinus, CSignD },  { OpIncleft, CIncLeftD }, { OpIncright, CIncRightD },
{ OpDecleft, CDecLeftD }, { OpDecright, CDecRightD },
{ 0xFF, D_0_UI },
{ OpLognot, CLoglongnot },
{ 0xFF, D_D_UI },
{ OpLess, CLessDD }, { OpEq, CEqDD }, { OpGreater, CGreaterDD },

// Для text функций
{ 0xFF, ST_ST_ST },
{ OpStradd, 0 }, 
{ 0xFF, ST_0_ST },
{ OpStrout, 0 },

{ 0, 0 }
};

const  ubyte typesto[ 5 ][ 10 ]={
//            int,   uint,  byte,  ubyte, short, ushort,  float, double,  long,  ulonge
//*  byte */{   0,      0,      0,     0,     0,      0,   Cf2i,  Cd2i ,  Cl2i,  Cul2i},
//* ubyte */{   0,      0,      0,     0,     0,      0,   Cf2i,  Cd2i ,  Cl2i,  Cul2i},
//* short */{   0,      0,      0,     0,     0,      0,   Cf2i,  Cd2i ,  Cl2i,  Cul2i},
//*ushort */{   0,      0,      0,     0,     0,      0,   Cf2i,  Cd2i ,  Cl2i,  Cul2i},
//*   int */{   0,      0,      0,     0,     0,      0,   Cf2i,  Cd2i ,  Cl2i,  Cul2i},
/*  uint */ {CNop,   CNop,   CNop,  CNop,  CNop,   CNop,   Cf2i,  Cd2i ,  Cl2i,   Cl2i},
/* float */ {Ci2f,  Cui2f,   Ci2f, Cui2f,  Ci2f,  Cui2f,   CNop,  Cd2f ,  Cl2f,   Cl2f},
/* double*/ {Ci2d,  Cui2d,   Ci2d, Cui2d,  Ci2d,  Cui2d,   Cf2d,  CNop ,  Cl2d,   Cl2d},
/*  long */ {Ci2l,  Cui2l,   Ci2l, Cui2l,  Ci2l,  Cui2l,   Cf2l,  Cd2l ,  CNop,   CNop},
/* ulong */ {Ci2l,  Cui2l,   Ci2l, Cui2l,  Ci2l,  Cui2l,   Cf2l,  Cd2l ,  CNop,   CNop},
};

/*-----------------------------------------------------------------------------
*
* ID: compinit 19.10.06 0.0.A.
* 
* Summary: Initialize the compiler.
*  
-----------------------------------------------------------------------------*/

void  STDCALL initcompile( void )
{
   uint      i, id, ret, idto, idfrom;
   pvmfunc   pfunc;
   ubyte     out[ 128 ];
   puint     ptr;
   uint      parl, parr;
   pubyte    ptrlex = ( pubyte )&operlexlist;

#if defined ( __GNUC__) || defined (__TINYC__) || defined (LINUX)
   pubyte    ptrpar = (pubyte) mem_allocz(128);    // santy
#endif

   if ( _compinit )
      return;
   _compinit = 1;
//   if ( _vm.count > KERNEL_COUNT )
//      return;

   // Заполняем от верхних к низу
   for ( i = 0; i < OPERCOUNT; i++ )
   {
      _lexlist[ i ] = 0;

      mem_copyuntilzero( ( pubyte )&_lexlist[ i ], ptrlex );
      if ( i && !_lexlist[ i ] )
         _lexlist[ i ] = _lexlist[ i - 1 ];
//      print("%s ", &_lexlist[ i ] );
      ptrlex += mem_len( ptrlex ) + 1;
   }

   id = KERNEL_COUNT - 1;
   i = 0;

   while ( operpars[ i ].oper )
   {
      if ( operpars[i].oper == 0xFF )
      {
         parl = oppars[ operpars[ i ].bc ].left;
         parr = oppars[ operpars[ i ].bc ].right;
         ret = oppars[ operpars[ i ].bc ].ret;
      }
      else
      {
         ptrlex = ( pubyte )&_lexlist[ operpars[ i ].oper ];
         ptr = ( puint )&out;
		 #if defined LINUX  || defined(__GNUC__)
           *(( pubyte )ptr) = 4;
           ptr=(( pubyte )ptr)+1;
		 #else
           *(( pubyte )ptr)++ = 4;// OVM_EXFUNC
		 #endif
         *ptr++ = GHCOM_NAME;
         *ptr++ = ( parr ? 29 : 24 ) + mem_len( ptrlex );
//         sprintf( ( pubyte )ptr, "#%02i", operpars[ i ].oper );
         sprintf( ( pubyte )ptr, "#%s", ptrlex );
         ptr = ( puint )(( pubyte )ptr + mem_len( ptr ) + 1 );
         *ptr++ = ret;
		 #if defined LINUX  || defined(__GNUC__)
          *(( pubyte )ptr) = 0;
          ptr=(( pubyte )ptr)+1;
		 #else
          *(( pubyte )ptr)++ = 0;
         #endif
         *ptr++ = parr ? 2 : 1;
         *ptr++ = parl;
		 #if defined LINUX  || defined(__GNUC__)
          *(( pubyte )ptr) = 0;
          ptr=(( pubyte )ptr)+1;
		 #else
          *(( pubyte )ptr)++ = 0;
		 #endif
         if ( parr )
         {
            *ptr++ = parr;
			#if defined LINUX  || defined(__GNUC__)
             *(( pubyte )ptr) = 0;
             ptr=(( pubyte )ptr)+1;
			#else
             *(( pubyte )ptr)++ = 0;
			#endif
         }
         ptr = ( puint )&out;
#if defined ( __GNUC__) || defined (__TINYC__) || defined (LINUX)
         ptrpar = ( pubyte )ptr;   // santy
         //ptrpar = ( pubyte )out;   // santy
         pfunc = ( pvmfunc )load_exfunc( &ptrpar, id-- );
#else
         pfunc = ( pvmfunc )load_exfunc( &( pubyte )ptr, id-- );
#endif
         // Link to stack command
         pfunc->vmo.id = operpars[ i ].bc;
      }
      i++;
   }
#if defined ( __GNUC__) || defined (__TINYC__) || defined (LINUX)
   mem_free(ptrpar);    // santy
#endif

   for ( idto = TInt; idto <= TUlong; idto++ )
   {
      for ( idfrom = TInt; idfrom <= TUlong; idfrom++ )
      {
         ptrlex = (( pvmobj )PCMD( idto ))->name;

         ptr = ( puint )&out;
         ptr=(( pubyte )ptr)+1;
         *(( pubyte )ptr) = 4;// OVM_EXFUNC
         *ptr++ = GHCOM_NAME;
         *ptr++ = 24 + mem_len( ptrlex );
         sprintf( ( pubyte )ptr, "@%s", ptrlex );
         ptr = ( puint )(( pubyte )ptr + mem_len( ptr ) + 1 );
         *ptr++ = idto;
		 #if defined LINUX  || defined(__GNUC__)
          *(( pubyte )ptr) = 0;
          ptr=(( pubyte )ptr)+1;
		 #else
          *(( pubyte )ptr)++ = 0;
		 #endif

         *ptr++ = 1;
         *ptr++ = idfrom;
		 #if defined LINUX  || defined(__GNUC__)
          *(( pubyte )ptr) = 0;
          ptr=(( pubyte )ptr)+1;
		 #else
          *(( pubyte )ptr)++ = 0;
		 #endif
         ptr = ( puint )&out;
#if defined ( __GNUC__) || defined (__TINYC__)
         ptrpar = ( pubyte )ptr;    // santy
         pfunc = ( pvmfunc )load_exfunc( &ptrpar, id-- );
#else
         pfunc = ( pvmfunc )load_exfunc( &( pubyte )ptr, id-- );
#endif
         // Link to stack command
         pfunc->vmo.id = typesto[ idto < TFloat ? 0 : idto - TFloat + 1 ][ idfrom - TInt ];
      }
   }

}


