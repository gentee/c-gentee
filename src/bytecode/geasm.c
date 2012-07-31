/******************************************************************************
*
* Copyright (C) 2009, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* Author: Alexander Krivonogov ( gentee )
*
* Summary: 
* 
******************************************************************************/
/*
   CNone,        //   0x0,  0 Error command
*   TInt,         //   0x1,  1 int type
*   TUint,        //   0x2,  2 uint type
*   TByte,        //   0x3,  3 byte type
*   TUbyte,       //   0x4,  4 ubyte type
*   TShort,       //   0x5,  5 short type
*   TUshort,      //   0x6,  6 ushort type
*   TFloat,       //   0x7,  7 float type
*   TDouble,      //   0x8,  8 double type
*   TLong,        //   0x9,  9 long type
*   TUlong,       //   0xA,  10 ulong type
*   TReserved,    //   0xB,  11 reserved type
*   TBuf,         //   0xC,  12 buf type
*   TStr,         //   0xD,  13 str type
*   TArr,         //   0xE,  14 arr type
*   TCollection,  //   0xF,  15 collection type
*   TAny,         //  0x10,  16 any type
*   TFordata,     //  0x11,  17 foreach type
*   CNop,         //  0x12,  18 The command does nothing
*   CGoto,        //  0x13,  19 The unconditional jump.
*   CGotonocls,   //  0x14,  20 The unconditional jump without clearing stack.
*   CIfze,        //  0x15,  21 The conditional jump
*   CIfznocls,    //  0x16,  22 The conditional jump without clearing stack
*   CIfnze,       //  0x17,  23 The conditional jump
*   CIfnznocls,   //  0x18,  24 The conditional jump without clearing stack.
?   CByload,      //  0x19,  25 The next ubyte push into stack. GE only
?   CShload,      //  0x1A,  26 The next ushort push into stack. GE only
*   CDwload,      //  0x1B,  27 The next uint push into stack.
*   CCmdload,     //  0x1C,  28 The next ID push into stack.
*   CResload,     //  0x1D,  29 The next ID (resource) push into stack.
*   CQwload,      //  0x1E,  30 The next ulong push into stack.
*   CDwsload,     //  0x1F,  31 The next uints ( cmd 1 ) ( cmd 2 ) push into the stack
*   CVarload,     //  0x20,  32 Load the value of parameter or variable with number ( cmd 1)
*   CVarptrload,  //  0x21,  33 Load the pointer to value of parameter or variable with number ( cmd 1)
*   CDatasize,    //  0x22,  34 Load the pointer to the next data and the size
*   CLoglongtrue, //  0x23,  35 Return 1 if ulong in stack is not zero
*   CLognot,      //  0x24,  36 Logical not
*   CLoglongnot,  //  0x25,  37 Logical NOT for long ulong
*   CDup,         //  0x26,  38 Duplicate top value
*   CDuplong,     //  0x27,  39 Duplicate two top value
*   CTop,         //  0x28,  40 Return the pointer to top
*   CPop,         //  0x29,  41 Delete the top value
*   CGetUB,       //  0x2A,  42  * ( pubyte ) 
*   CGetB,        //  0x2B,  43  * ( pbyte ) 
*   CGetUS,       //  0x2C,  44  * ( pushort ) 
*   CGetS,        //  0x2D,  45  * ( pshort ) 
*   CGetI,        //  0x2E,  46  * ( puint && pint && float ) 
*   CGetL,        //  0x2F,  47  * ( pulong && plong && double ) 
*   CSetUB,       //  0x30,  48  * ( pubyte ) = 
*   CSetB,        //  0x31,  49  * ( pbyte ) = 
*   CSetUS,       //  0x32,  50  * ( pushort ) = 
*   CSetS,        //  0x33,  51  * ( pshort ) = 
*   CSetI,        //  0x34,  52  * ( puint && pint && float ) = 
*   CSetL,        //  0x35,  53  * ( pulong && plong && double ) = 
*   CAddUIUI,     //  0x36,  54  + 
*   CSubUIUI,     //  0x37,  55  - 
*   CMulUIUI,     //  0x38,  56  * 
*   CDivUIUI,     //  0x39,  57  / 
*   CModUIUI,     //  0x3A,  58  % 
*   CAndUIUI,     //  0x3B,  59  & 
*   COrUIUI,      //  0x3C,  60  | 
*   CXorUIUI,     //  0x3D,  61  ^ 
*   CLeftUIUI,    //  0x3E,  62  << 
*   CRightUIUI,   //  0x3F,  63  >> 
*   CLessUIUI,    //  0x40,  64  < 
*   CGreaterUIUI, //  0x41,  65  > 
*   CEqUIUI,      //  0x42,  66  == 
*   CNotUI,       //  0x43,  67  ~ 
*   CIncLeftUI,   //  0x44,  68  ++i 
*   CIncRightUI,  //  0x45,  69  i++ 
*   CDecLeftUI,   //  0x46,  70  --i 
*   CDecRightUI,  //  0x47,  71  i-- 
*   CAddUI,       //  0x48,  72  += 
*   CSubUI,       //  0x49,  73  -= 
*   CMulUI,       //  0x4A,  74  *= 
*   CDivUI,       //  0x4B,  75  /= 
*   CModUI,       //  0x4C,  76  %= 
*   CAndUI,       //  0x4D,  77  &= 
*   COrUI,        //  0x4E,  78  |= 
*   CXorUI,       //  0x4F,  79  ^= 
*   CLeftUI,      //  0x50,  80  <<= 
*   CRightUI,     //  0x51,  81  >>= 
   CVarsInit,    //  0x52,  82 Initialize variables in block cmd1 
   CGetText,     //  0x53,  83 Get current output of text function
   CSetText,     //  0x54,  84 Print string to current output of text function
   CPtrglobal,   //  0x55,  85 Get to the global variable
*   CSubcall,     //  0x56,  86 Call a subfunc cmd 1 - goto
*   CSubret,      //  0x57,  87 The number of returned uint cmd 1
*   CSubpar,      //  0x58,  88 Parameters of subfunc. cmd 1 - Set block
*   CSubreturn,   //  0x59,  89 Return from a subfunc
   CCmdcall,     //  0x5A,  90 Call a funcion
   CCallstd,     //  0x5B,  91 Call a stdcall or cdecl funcion
   CReturn,      //  0x5C,  92 Return from the function.
*   CAsm,         //  0x5D,  93 Assembler
   CDbgTrace,    //  0x5E,  94 Debug line tracing
   CDbgFunc,     //  0x5F,  95 Debug func entering
*   CMulII,       //  0x60,  96  * 
*   CDivII,       //  0x61,  97  / 
*   CModII,       //  0x62,  98  % 
*   CLeftII,      //  0x63,  99  << 
*   CRightII,     //  0x64,  100  >> 
*   CSignI,       //  0x65,  101  change sign 
*   CLessII,      //  0x66,  102  < 
*   CGreaterII,   //  0x67,  103  > 
*   CMulI,        //  0x68,  104  *= 
*   CDivI,        //  0x69,  105  /= 
*   CModI,        //  0x6A,  106  %= 
*   CLeftI,       //  0x6B,  107  <<= 
*   CRightI,      //  0x6C,  108  >>= 
   CMulB,        //  0x6D,  109  *= 
   CDivB,        //  0x6E,  110  /= 
   CModB,        //  0x6F,  111  %= 
   CLeftB,       //  0x70,  112  <<= 
   CRightB,      //  0x71,  113  >>= 
   CMulS,        //  0x72,  114  *= 
   CDivS,        //  0x73,  115  /= 
   CModS,        //  0x74,  116  %= 
   CLeftS,       //  0x75,  117  <<= 
   CRightS,      //  0x76,  118  >>= 
   Cd2f,         //  0x77,  119 double 2 float
   Cd2i,         //  0x78,  120 double 2 int
   Cd2l,         //  0x79,  121 double 2 long
   Cf2d,         //  0x7A,  122 float 2 double
   Cf2i,         //  0x7B,  123 float 2 int
   Cf2l,         //  0x7C,  124 float 2 long
   Ci2d,         //  0x7D,  125 int 2 double
   Ci2f,         //  0x7E,  126 int 2 float
   Ci2l,         //  0x7F,  127 int 2 long
   Cl2d,         //  0x80,  128 long 2 double
   Cl2f,         //  0x81,  129 long 2 float
   Cl2i,         //  0x82,  130 long 2 int
   Cui2d,        //  0x83,  131 uint 2 double
   Cui2f,        //  0x84,  132 uint 2 float
   Cui2l,        //  0x85,  133 uint 2 long
   CAddULUL,     //  0x86,  134 +
   CSubULUL,     //  0x87,  135 -
   CMulULUL,     //  0x88,  136 *
   CDivULUL,     //  0x89,  137 /
   CModULUL,     //  0x8A,  138 %
   CAndULUL,     //  0x8B,  139 &
   COrULUL,      //  0x8C,  140 |
   CXorULUL,     //  0x8D,  141 ^
   CLeftULUL,    //  0x8E,  142 <<
   CRightULUL,   //  0x8F,  143 >>
   CLessULUL,    //  0x90,  144 <
   CGreaterULUL, //  0x91,  145 >
   CEqULUL,      //  0x92,  146 ==
   CNotUL,       //  0x93,  147 ~
   CIncLeftUL,   //  0x94,  148 ++
   CIncRightUL,  //  0x95,  149 ++
   CDecLeftUL,   //  0x96,  150 --
   CDecRightUL,  //  0x97,  151 --
   CAddUL,       //  0x98,  152 +=
   CSubUL,       //  0x99,  153 -=
   CMulUL,       //  0x9A,  154 *=
   CDivUL,       //  0x9B,  155 /=
   CModUL,       //  0x9C,  156 %
   CAndUL,       //  0x9D,  157 &=
   COrUL,        //  0x9E,  158 |=
   CXorUL,       //  0x9F,  159 &=
   CLeftUL,      //  0xA0,  160 <<=
   CRightUL,     //  0xA1,  161 >>=
   CMulLL,       //  0xA2,  162 *
   CDivLL,       //  0xA3,  163 /
   CModLL,       //  0xA4,  164 %
   CLeftLL,      //  0xA5,  165 <<=
   CRightLL,     //  0xA6,  166 >>=
   CSignL,       //  0xA7,  167 sign
   CLessLL,      //  0xA8,  168 <
   CGreaterLL,   //  0xA9,  169 >
   CMulL,        //  0xAA,  170 *=
   CDivL,        //  0xAB,  171 /=
   CModL,        //  0xAC,  172 %=
   CLeftL,       //  0xAD,  173 <<=
   CRightL,      //  0xAE,  174 >>=
   CAddFF,       //  0xAF,  175 +
   CSubFF,       //  0xB0,  176 -
   CMulFF,       //  0xB1,  177 *
   CDivFF,       //  0xB2,  178 /
   CSignF,       //  0xB3,  179 sign
   CLessFF,      //  0xB4,  180 <
   CGreaterFF,   //  0xB5,  181 >
   CEqFF,        //  0xB6,  182 ==
   CIncLeftF,    //  0xB7,  183 ++
   CIncRightF,   //  0xB8,  184 ++
   CDecLeftF,    //  0xB9,  185 --
   CDecRightF,   //  0xBA,  186 --
   CAddF,        //  0xBB,  187 +=
   CSubF,        //  0xBC,  188 -=
   CMulF,        //  0xBD,  189 *=
   CDivF,        //  0xBE,  190 /=
   CAddDD,       //  0xBF,  191 +
   CSubDD,       //  0xC0,  192 -
   CMulDD,       //  0xC1,  193 *
   CDivDD,       //  0xC2,  194 /
   CSignD,       //  0xC3,  195 sign
   CLessDD,      //  0xC4,  196 <
   CGreaterDD,   //  0xC5,  197 >
   CEqDD,        //  0xC6,  198 ==
   CIncLeftD,    //  0xC7,  199 ++
   CIncRightD,   //  0xC8,  200 ++
   CDecLeftD,    //  0xC9,  201 --
   CDecRightD,   //  0xCA,  202 --
   CAddD,        //  0xCB,  203 +=
   CSubD,        //  0xCC,  204 -=
   CMulD,        //  0xCD,  205 *=
   CDivD,        //  0xCE,  206 /=
*   CIncLeftUB,   //  0xCF,  207 ++
*   CIncRightUB,  //  0xD0,  208 ++
*   CDecLeftUB,   //  0xD1,  209 --
*   CDecRightUB,  //  0xD2,  210 --
   CAddUB,       //  0xD3,  211 +=
   CSubUB,       //  0xD4,  212 -=
   CMulUB,       //  0xD5,  213 *=
   CDivUB,       //  0xD6,  214 /=
   CModUB,       //  0xD7,  215 %=
   CAndUB,       //  0xD8,  216 &=
   COrUB,        //  0xD9,  217 |=
   CXorUB,       //  0xDA,  218 ^=
   CLeftUB,      //  0xDB,  219 <<=
   CRightUB,     //  0xDC,  220 >>=
*   CIncLeftUS,   //  0xDD,  221 ++
*   CIncRightUS,  //  0xDE,  222 ++
*   CDecLeftUS,   //  0xDF,  223 --
*   CDecRightUS,  //  0xE0,  224 --
   CAddUS,       //  0xE1,  225 +=
   CSubUS,       //  0xE2,  226 -=
   CMulUS,       //  0xE3,  227 *=
   CDivUS,       //  0xE4,  228 /=
   CModUS,       //  0xE5,  229 %=
   CAndUS,       //  0xE6,  230 &=
   COrUS,        //  0xE7,  231 |=
   CXorUS,       //  0xE8,  232 ^=
   CLeftUS,      //  0xE9,  233 <<=
   CRightUS,     //  0xEA,  234 >>=
   CCollectadd,  //  0xEB,  235 Run-time loading collection
99
*/

#ifdef _ASM

#include "ge.h"
#include "../vm/vm.h"
#include "../vm/vmload.h"
#include "../bytecode/bytecode.h"
#include "../genteeapi/gentee.h"


pbuf   STDCALL buf_append2ch( pbuf pb, ubyte val1, ubyte val2 )
{
   buf_expand( pb, 2 );
   *( pb->data + pb->use++ ) = val1;
   *( pb->data + pb->use++ ) = val2;   
   return pb;
}

pbuf   STDCALL buf_append3ch( pbuf pb, ubyte val1, ubyte val2, ubyte val3 )
{
   buf_expand( pb, 3 );
   *( pb->data + pb->use++ ) = val1;
   *( pb->data + pb->use++ ) = val2;   
   *( pb->data + pb->use++ ) = val3;
   return pb;
}

pbuf   STDCALL buf_append4ch( pbuf pb, ubyte val1, ubyte val2, ubyte val3, ubyte val4 )
{
   buf_expand( pb, 4 );
   *( pb->data + pb->use++ ) = val1;
   *( pb->data + pb->use++ ) = val2;   
   *( pb->data + pb->use++ ) = val3;
   *( pb->data + pb->use++ ) = val4;
   return pb;
}

uint STDCALL startasm( pbuf b )
{
   uint ret;
   buf_appenduint( b, CAsm );
   ret = b->use;
   buf_appenduint( b, 0 );
   //buf_appendch( b, 0xCC );
   //Установка нового стэка
//   buf_appendch( b, 0x56 );//push esi 
//   buf_appendch( b, 0x8B );//mov esi, esp
//   buf_appendch( b, 0xF4 );   
//   buf_appendch( b, 0x8B );//mov esp, ebx
//   buf_appendch( b, 0xE3 );
   return ret;
}

typedef uint (* puarr)[];


uint STDCALL findnear( pbuf b, uint val, uint flgadd )
{
   puarr array;
   //uint array[];
   //uint m = size;   
   int minlast = 0;
   int maxlast = ( b->use >> 2 );   
   uint cur = 0;
   array = (puarr)b->data;
//print( "Findnear %x %x %x\n", val, flgadd, maxlast );
   if ( maxlast )
   {
      maxlast--;  
      do
      {
         cur = ( maxlast + minlast ) >> 1;         
         if ( (*array)[cur] == val )
         {
            //print( "Nearfind %x %x\n", val, cur );
            return cur<<2;
         }
         if ( (*array)[cur] > val )
         {
            maxlast = cur - 1;
         }
         else
         {
            minlast = cur + 1;
            cur++;            
         }         
      }
      while ( maxlast >= minlast );        
   }
   if ( flgadd )
   {      
      buf_insert( b, cur << 2, (pchar)&val, 4 );
//      print( "near add %x %x\n", cur, val );
      return cur << 2;
   }   
   return -1;
}


void STDCALL stopasm( pbuf b, uint off )
{
   uint val = 0;
   uint offcmd;

   //Восстановление стэка и возврат
//   buf_appendch( b, 0x8B );//mov ebx, esp
//   buf_appendch( b, 0xDC );

//   buf_appendch( b, 0x8B );//mov esp, esi
//   buf_appendch( b, 0xE6 );

   //buf_appendch( b, 0x5E); //pop esi


   buf_appendch( b, 0xB8 );//mov         eax, *
   offcmd = b->use;
   buf_appenduint( b, 0 );

   buf_appendch( b, 0xC3 );//ret

   //Выравнивание до dword      
   buf_append( b, ( pubyte )&val, 
                ( sizeof( uint ) - b->use & ( sizeof( uint ) - 1 ) ) & 3 );
   *(puint)( b->data + off ) = (b->use - off - 4) >> 2;
   //print( "size %x %x %x\n", b->use, off, (b->use - off - 4) >> 2 );
   *(puint)( b->data + offcmd ) = (b->use) >> 2;
}

/*
puint       start; +0
puint       cmd;   +4
puint       top;   +8
uint        uiret; +c
pvmfunc     func;  +10
puint       clmark;+14                   
uint        nline; +18
mov [bx+4], [bx+0x14]
*/


void STDCALL ge_toasm( uint id, pbuf bout )
{
   puint     ptr, end;
   povmbcode bcode;
   povmtype  ptype;
   pvmobj    pvmo;
   uint      cmd, i, count = 0;
   uint      flgcop = 0;
   uint      off;
   uint      flgjmp = 0;
   uint      flgcls = 0;
   uint      flgtmp;
   //pbuf      bout;
   buf       bjmpsrc;
   buf       bjmpdst;
   buf       bjmpun;
   buf       bsubfuncs;
   uint      subparsize;
   uint      subretsize;
   //pvarset   pset;

   pvartype   pvar;
   uint      tmp;
   uint      tmp2;
   //uint      flgcls = 0;   
   uint      curjmpsrc;
   uint      funcoff;

   /*bout = mem_alloc( sizeof( buf ));
   buf_init( bout );
   buf_reserve( bout, 0x200 );
   bout->step = 0x200;   */

   buf_init( &bjmpsrc );
   buf_init( &bsubfuncs );
   buf_init( &bjmpdst );
   buf_init( &bjmpun );

   if ( id < KERNEL_COUNT ) 
      return;

   pvmo = ( pvmobj )PCMD( id );   
   if ( pvmo->type == OVM_BYTECODE )
   {  
      bcode = ( povmbcode )pvmo;
      ptr = ( puint )bcode->vmf.func;
      if ( !ptr )
         return;
      end = ( puint )( ( pubyte )ptr + bcode->bcsize );
      //Первый проход определение переходов
      while ( ptr < end )
      {
         cmd = *ptr++;
         if ( cmd < CNop || cmd >= CNop + STACK_COUNT )
         {              
            continue;
         }       
   
         switch ( cmd )
         {            
            case CDwsload:                              
            case CAsm:
               i = *ptr++;
               ptr += i;
               break;
            
            case CDatasize:                          
               i = *ptr++;               
               i = ( i >> 2 ) + ( i & 3 ? 1 : 0 );
               ptr += i;              
               break;

            case CSubcall:
               off = (*(ptr) + 1)<<2;               
               findnear( &bsubfuncs, off, 1 );
               findnear( &bjmpsrc, off, 1 );
               goto shiftg;

            case CGoto:                  
            case CGotonocls:
            case CIfze:               
            case CIfznocls:               
            case CIfnze:               
            case CIfnznocls:            
               off = (*(ptr) + 1)<<2;               
               findnear( &bjmpsrc, off , 1 );
               
            default:               
shiftg:
               switch ( shifts[ cmd - CNop ] )
               {
                  case SH1_3:
                  case SH2_3:
                     ptr++;
                  case SHN1_2:
                  case SH0_2:
                  case SH1_2:
                     ptr++;               
                     break;
               }
         }

         continue;
      }
      
      buf_expand( &bjmpdst, bjmpsrc.use );      
      mem_zero( bjmpdst.data, bjmpsrc.use );      
      curjmpsrc = 0;
      
      //Второй проход конвертация
      ptr = ( puint )bcode->vmf.func;
      while ( ptr < end )
      {
         cmd = *ptr++;         
         //print ("cmd %x\n", cmd );
         funcoff = (uint)ptr - ( uint )bcode->vmf.func;         
         
         if ( ( off = findnear( &bjmpsrc, funcoff, 0 )) != -1 )
         {            
            if (!flgcop ) flgcop = startasm( bout );                            
            *(puint)((uint)bjmpdst.data + off) = bout->use;
            if ( findnear( &bsubfuncs, funcoff, 0 ) != -1 )
            {               
               buf_appendch( bout, 0x58 );//pop  eax
               buf_append3ch( bout, 0x83, 0xC6, 0x08 );//add  esi,8
               buf_append3ch( bout, 0x89, 0x46, 0xFC );//mov dword ptr [esi-4],eax               
               buf_append3ch( bout, 0x8B, 0x41, 0x14 );//mov eax, dword ptr [ecx+14h]               
               buf_append2ch( bout, 0x89, 0x06 );//mov  dword ptr [esi],eax
               buf_append3ch( bout, 0x89, 0x71, 0x14 );//mov dword ptr [ecx+0x14], esi

               subparsize = 0;
               subretsize = 0;
            }
         }

         if ( cmd >= CNop + STACK_COUNT )
         {  
            if ( flgcop ) 
            {
               stopasm( bout, flgcop);
               flgcop = 0;
            }
            buf_appenduint( bout, cmd );
            continue;
         }       
         
         switch ( cmd )
         {        
            case TInt:         
            case TUint:        
            case TByte:        
            case TUbyte:       
            case TShort:       
            case TUshort:      
            case TFloat:       
            case TDouble:      
            case TLong:        
            case TUlong:       
            case TReserved:    
            case TBuf:         
            case TStr:         
            case TArr:         
            case TCollection:  
            case TAny:         
            case TFordata:     
               if ( !flgcop ) flgcop = startasm( bout );                                 
               buf_append3ch( bout, 0x83, 0xC6, 0x04 );//add  esi,4
               buf_append2ch( bout, 0xC7, 0x06 );//mov  dword ptr [esi], *
               buf_appenduint( bout, cmd );
               goto shift;

            case CNop:
               goto shift;

            case CIfznocls:
               flgjmp = 0x73;
               goto cgotonocls;
            case CIfnznocls:
               flgjmp = 0x72;
               goto cgotonocls;
            case CIfze:  
               flgjmp = 0x73;
               goto cgoto;
            case CIfnze:
               flgjmp = 0x72;
               goto cgoto;
            case CGoto:   
cgoto:
               flgcls = 1;               
            case CGotonocls:
cgotonocls:
               if ( !flgcop ) flgcop = startasm( bout );                                 
               if ( flgjmp )
               {  
                  if ( flgcls )
                     buf_appendch( bout, 0xAD );//lods  dword ptr [esi]                     
                  else
                     buf_append2ch( bout, 0x8B, 0x06 );//mov  eax,dword ptr [esi]
                  buf_append2ch( bout, 0xF7, 0xD8 );//neg  eax                  
               }
               if ( flgcls )
               {
                  buf_append3ch( bout, 0x8B, 0x71, 0x14 );//mov esi, dword ptr [ecx+14h]                  
                  //flgcls = 0;
               }
               tmp = (*(ptr) + 1)<<2;                              
               off = *(puint)((uint)bjmpdst.data + findnear( &bjmpsrc, tmp, 0 ));               
               if ( off )
               {                  
                  off = off - bout->use - 2;                
                  if ( (int)off > -128 )
                  {
                     buf_append2ch( bout, (ubyte) (flgjmp ? flgjmp : 0xEB), (ubyte)off );//jmp *                     
                  }
                  else
                  {                     
                     if ( flgjmp )
                     {
                        off -= 4;
                        buf_append2ch( bout, 0x0F, (ubyte)(flgjmp + 0x10) );//jmp *                           
                     }
                     else 
                     {
                        off -= 3;   
                        buf_appendch( bout, 0xE9 );//jmp *                     
                     }
                     buf_appenduint( bout, off );
                  }
               }
               else 
               {
                  if ( flgjmp )
                  {
                     buf_append2ch( bout, 0x0F, (ubyte)(flgjmp + 0x10) );//jmp *                           
                  }
                  else  buf_appendch( bout, 0xE9 );//jmp *                     
                  buf_appenduint( &bjmpun, bout->use );
                  buf_appenduint( &bjmpun, tmp );
                  buf_appenduint( bout, 0 );
               }
               if ( flgjmp && !flgcls )
                  buf_appendch( bout, 0xAD );//lods dword ptr [esi]   
               flgjmp = 0;
               flgcls = 0;
               goto shift;

            case CDwload:
            //case CCmdload:
            case CResload:
               if ( !flgcop ) flgcop = startasm( bout );                                 
               buf_append3ch( bout, 0x83, 0xC6, 0x04 );//add  esi,4
               buf_append2ch( bout, 0xC7, 0x06 );//mov  dword ptr [esi], *
               buf_appenduint( bout, *ptr );            
               goto shift;

            case CQwload:  
               if ( !flgcop ) flgcop = startasm( bout );                                 
               buf_append3ch( bout, 0x83, 0xC6, 0x08 );//add  esi,8
               buf_append3ch( bout, 0xC7, 0x46, 0xFC );//mov  dword ptr [esi-4], *
               buf_appenduint( bout, *ptr );
               buf_append2ch( bout, 0xC7, 0x06 );//mov  dword ptr [esi], *
               buf_appenduint( bout, *(ptr+1) );               
               goto shift;

/*            case CDwsload:                              
               if ( !flgcop ) flgcop = startasm( bout );
               tmp = *ptr++;               
               if  (tmp < 11 )
               {
                  buf_append3ch( bout, 0x83, 0xC6, ( ubyte )( tmp << 2 ) );//add  esi, tmp * 4   
                  for ( i = tmp ; i > 0; i-- ) 
                  {                     
                     if ( i > 1 )
                        buf_append3ch( bout, 0xC7, 0x46, (ubyte)( (1-i) * 4 ) );// mov  dword ptr [esi-*], *   
                     else
                        buf_append2ch( bout, 0xC7, 0x06 );//mov  dword ptr [esi], *
                     buf_appenduint( bout, *ptr++ );
                  }
               }
               else
               {
                  buf_appendch( bout, 0x57 );//push  edi
                  buf_appendch( bout, 0x51 );//push  ecx                  
                  buf_append3ch( bout, 0x8D, 0x7E, 0x04 );//lea  edi,[esi+4]
                  buf_appendch( bout, 0xE8 );//call  *
                  buf_appenduint( bout, tmp << 2 );
                  for ( i = tmp ; i > 0; i-- ) 
                     buf_appenduint( bout, *ptr++ );
                  buf_appendch( bout, 0x5E );//pop  esi
                  buf_appendch( bout, 0xFC );//cld
                  buf_appendch( bout, 0xB9 );//mov  ecx, *
                  buf_appenduint( bout, tmp );
                  buf_append2ch( bout, 0xF3, 0xA5 );//rep movs dword ptr [edi],dword ptr [esi]
                  buf_appendch( bout, 0xFD );//std                  
                  buf_append3ch( bout, 0x8D, 0x77, 0xFC );//lea  esi,[edi-4]
                  buf_appendch( bout, 0x59 );//pop  ecx
                  buf_appendch( bout, 0x5F );//pop  edi  
               }               
               break;
*/
            case CVarptrload:
            case CVarload:
               if ( !flgcop ) 
               {
                  flgcop = startasm( bout );                  
               }
               i = *ptr;
               if ( i < bcode->vmf.parcount )
               {                  
                  pvar = bcode->vmf.params + i;
                  off = pvar->off;                  
                  tmp = 0;
               }
               else
               {
                  pvar = bcode->vars + ( i - bcode->vmf.parcount );
                  off = pvar->off;                  
                  tmp = 2;
               }
               off <<= 2;
               ptype = ( povmtype )PCMD( pvar->type );               
               if ( cmd == CVarload && ptype->vmo.flag & GHTY_STACK ) 
               {
                  buf_appendch( bout, 0x8B ); //mov  eax,dword ptr [ebp/edi+*]   
                  if ( ptype->stsize > 1 )
                  {
                     if ( off > 127 )
                     {
                        buf_appendch( bout, (ubyte)(0x85 + tmp) );
                        buf_appenduint( bout, off );
                     }
                     else
                     {
                        buf_append2ch( bout, (ubyte)(0x45 + tmp), (ubyte)off );                        
                     }   
                     buf_append3ch( bout, 0x83, 0xC6, 0x04 );//add  esi,4               
                     buf_append2ch( bout, 0x89, 0x06 );//mov  dword ptr [esi],eax               
                     off += 4;
                     buf_appendch( bout, 0x8B ); 
                  }
               }
               else
               {
                  if ( pvar->flag & VAR_PARAM && 
                       !( ptype->vmo.flag & GHTY_STACK ))
                     buf_appendch( bout, 0x8B );
                  else 
                     buf_appendch( bout, 0x8D );//45        lea         eax,[ebp+*]
               }
               if ( off > 127 )
               {
                  buf_appendch( bout, (ubyte)(0x85 + tmp) );
                  buf_appenduint( bout, off );
               }
               else
               {
                  buf_append2ch( bout, (ubyte)(0x45 + tmp), (ubyte)off );                  
               }
               buf_append3ch( bout, 0x83, 0xC6, 0x04 );//add         esi,4               
               buf_append2ch( bout, 0x89, 0x06 );//mov         dword ptr [esi],eax               
               goto shift;

            case CDatasize:
               if ( !flgcop ) flgcop = startasm( bout );                              
               tmp = *ptr++;
               i = ( tmp >> 2 ) + ( tmp & 3 ? 1 : 0 );
               buf_appendch( bout, 0xE8 );//call  *
               buf_appenduint( bout, tmp );
               buf_append( bout, (pubyte)ptr, tmp );
               ptr += i;               
               buf_appendch( bout, 0x58 );//pop  eax
               buf_append3ch( bout, 0x83, 0xC6, 0x08 );//add  esi,8
               buf_append3ch( bout, 0x89, 0x46, 0xFC );//mov dword ptr [esi-4],eax               
               buf_append2ch( bout, 0xC7, 0x06 );//mov  dword ptr [esi], *
               buf_appenduint( bout, tmp );
               break;            
            
            case CLoglongnot:
               tmp = 1;
               goto loglong;
            case CLoglongtrue: //*pop2 = ( val1 || val2 ? 1 : 0 );  break;
               tmp = 0;
loglong:
               if ( !flgcop ) flgcop = startasm( bout );                  
               buf_appendch( bout, 0xAD );//lods  dword ptr [esi]                  
               buf_append2ch( bout, 0x33, 0xD2);//xor  edx,edx   
               buf_append2ch( bout, 0x3B, 0xC2);//cmp  eax,edx
               //buf_append2ch( bout, 0x75, 0x04);//jne 4
               buf_append2ch( bout, 0x75, (ubyte)(0x04 + tmp) );//jne 4/5
               buf_append2ch( bout, 0x39, 0x16 );//cmp  dword ptr [esi],edx
               buf_append2ch( bout, (ubyte)(0x74 + tmp), 0x01);//je/jne 1
               //buf_append2ch( bout, 0x75, 0x01);//jne 1
               buf_appendch( bout, 0x42 );//inc  edx   
               buf_append2ch( bout, 0x89, 0x16 );//mov  dword ptr [esi],edx
               goto shift;

            case CLognot:      
               if ( !flgcop ) flgcop = startasm( bout );                  
               buf_append2ch( bout, 0x33, 0xD2);//xor  edx,edx   
               buf_append2ch( bout, 0x39, 0x16 );//cmp  dword ptr [esi],edx
               buf_append2ch( bout, (ubyte)(0x75), 0x01);//jne 1
               buf_appendch( bout, 0x42 );//inc  edx   
               buf_append2ch( bout, 0x89, 0x16 );//mov  dword ptr [esi],edx
               goto shift;

            //case CLoglongnot:  *pop2 = ( val1 || val2 ? 0 : 1 ); break;
            case CDup: 
               if ( !flgcop ) flgcop = startasm( bout );                                 
               buf_appendch( bout, 0xAD );//lods dword ptr [esi]   
               buf_append3ch( bout, 0x83, 0xC6, 0x08 );//add  esi,8               
               buf_append2ch( bout, 0x89, 0x06 );//mov  dword ptr [esi],eax               
               goto shift;               

            case CDuplong:
               if ( !flgcop ) flgcop = startasm( bout );                                 
               buf_appendch( bout, 0xAD );//lods dword ptr [esi]   
               buf_append2ch( bout, 0x8B, 0xD0 );//mov  edx,eax
               buf_appendch( bout, 0xAD );//lods dword ptr [esi]   
               buf_append3ch( bout, 0x83, 0xC6, 0x10 );//add  esi,16               
               buf_append3ch( bout, 0x89, 0x46, 0xFC );//mov  dword ptr [esi-4],eax               
               buf_append2ch( bout, 0x89, 0x16 );//mov  dword ptr [esi],edx                              
               goto shift;                              

            case CTop: 
               if ( !flgcop ) flgcop = startasm( bout );        
               buf_append3ch( bout, 0x89, 0x76, 0x04 );//mov dword ptr [esi+4],esi
               buf_append3ch( bout, 0x83, 0xC6, 0x04 );//add  esi,4                              
               goto shift;                              

            case CPop: 
               if ( !flgcop ) flgcop = startasm( bout );                                 
               buf_appendch( bout, 0xAD );//lods dword ptr [esi]   
               goto shift;

            case CGetUB:
               tmp = 0xB6;//movzx eax,byte ptr [ebx]
               goto getub;
            case CGetB:
               tmp = 0xBE;//movsx eax,byte ptr [ebx]
               goto getub;
            case CGetUS:               
               tmp = 0xB7;//movzx eax,word ptr [ebx]             
               goto getub;
            case CGetS:
               tmp = 0xBF;//movsx eax,word ptr [ebx]
getub:
               if ( !flgcop ) flgcop = startasm( bout );                                 
               buf_append2ch( bout, 0x8B, 0x1E );//mov  ebx,dword ptr [esi]
               buf_append3ch( bout, 0x0F, (ubyte)(tmp), 0x03 );//movsx/movzx  eax,byte/word ptr [ebx]
               buf_append2ch( bout, 0x89, 0x06 );//mov  dword ptr [esi],eax
               goto shift;
            
            case CGetI: 
               if ( !flgcop ) flgcop = startasm( bout );                                 
               buf_append2ch( bout, 0x8B, 0x1E );//mov  ebx,dword ptr [esi]
               buf_append2ch( bout, 0x8B, 0x03 );//mov  eax,word ptr [ebx]
               buf_append2ch( bout, 0x89, 0x06 );//mov  dword ptr [esi],eax
               goto shift;

            case CGetL: 
               if ( !flgcop ) flgcop = startasm( bout );                                 
               buf_append2ch( bout, 0x8B, 0x1E );//mov  ebx,dword ptr [esi]
               buf_append2ch( bout, 0x8B, 0x03 );//mov  eax,word ptr [ebx]
               buf_append2ch( bout, 0x89, 0x06 );//mov  dword ptr [esi],eax
               buf_append3ch( bout, 0x8B, 0x43, 0x04 );//mov  eax,word ptr [ebx+4]
               buf_append3ch( bout, 0x83, 0xC6, 0x04 );//add  esi,4
               buf_append2ch( bout, 0x89, 0x06 );//mov  dword ptr [esi],eax
               goto shift;

            case CSetUB: 
            case CSetB:  
               if ( !flgcop ) flgcop = startasm( bout );                                 
               buf_appendch( bout, 0xAD );       //lods dword ptr [esi]   
               buf_append2ch( bout, 0x8B, 0x1E );//mov  ebx,dword ptr [esi]   
               buf_append2ch( bout, 0x88, 0x03 );//mov  byte ptr [ebx],al                  
               buf_append2ch( bout, 0x89, 0x06 );//mov  dword ptr [esi],eax
               goto shift;

            case CSetUS: 
            case CSetS:  
               if ( !flgcop ) flgcop = startasm( bout );                                 
               buf_appendch( bout, 0xAD );       //lods dword ptr [esi]   
               buf_append2ch( bout, 0x8B, 0x1E );//mov  ebx,dword ptr [esi]   
               buf_append3ch( bout, 0x66, 0x89, 0x03 );//mov  word ptr [ebx],ax
               buf_append2ch( bout, 0x89, 0x06 );//mov  dword ptr [esi],eax
               goto shift;

            case CSetI:
               if ( !flgcop ) flgcop = startasm( bout );                                 
               buf_appendch( bout, 0xAD );       //lods dword ptr [esi]   
               buf_append2ch( bout, 0x8B, 0x1E );//mov  ebx,dword ptr [esi]   
               buf_append2ch( bout, 0x89, 0x03 );//mov  dword ptr [ebx],eax   
               buf_append2ch( bout, 0x89, 0x06 );//mov  dword ptr [esi],eax
               goto shift;

            case CSetL: 
               if ( !flgcop ) flgcop = startasm( bout );                                 
               buf_appendch( bout, 0xAD );       //lods dword ptr [esi]   
               buf_append2ch( bout, 0x8B, 0x1E );//mov  ebx, dword ptr [esi]
               buf_append3ch( bout, 0x8B, 0x56, 0xFC );//mov  edx, dword ptr [esi-4]
               buf_append2ch( bout, 0x89, 0x1A );//mov  dword ptr [edx], ebx
               buf_append3ch( bout, 0x89, 0x42, 0x04 );//mov  dword ptr [edx+4], eax
               buf_append3ch( bout, 0x89, 0x5E, 0xFC );//mov  dword ptr [esi-4], ebx
               buf_append2ch( bout, 0x89, 0x06 );//mov  dword ptr [esi], eax
               goto shift;               

            case CSubUIUI: 
               tmp = 0x29;//sub
               goto binopuiui;
            case CAndUIUI: 
               tmp = 0x21;//and
               goto binopuiui;
            case COrUIUI: 
               tmp = 0x09;//or
               goto binopuiui;
            case CXorUIUI: 
               tmp = 0x31;//xor
               goto binopuiui;
            case CAddUIUI:               
               tmp = 0x01;//add
binopuiui:
               if ( !flgcop ) flgcop = startasm( bout );                  
               buf_appendch( bout, 0xAD );//lods dword ptr [esi]   
               buf_append2ch( bout, (ubyte)tmp, 0x06 );//*tmp dword ptr [esi],eax
               goto shift;
            
            case CMulUIUI:   
            case CMulII:               
               if ( !flgcop ) flgcop = startasm( bout );                  
               buf_appendch( bout, 0xAD );//lods dword ptr [esi]                  
               buf_append3ch( bout, 0x0F, 0xAF, 0x06 );//imul eax,dword ptr [esi]
               buf_append2ch( bout, 0x89, 0x06 );//mov dword ptr [esi],eax
               goto shift;            

            case CDivUIUI:       
               tmp = 0;
               tmp2 = 0xF3;
               goto divuiui;
            case CModUIUI:       
               tmp = 0x10;
               tmp2 = 0xF3;
               goto divuiui;
            case CDivII:
               tmp = 0;
               tmp2 = 0xFB;
               goto divuiui;
            case CModII:   
               tmp = 0x10;
               tmp2 = 0xFB;               
divuiui:
               if ( !flgcop ) flgcop = startasm( bout );                  
               buf_appendch( bout, 0xAD );//lods dword ptr [esi]   
               buf_append2ch( bout, 0x8B, 0xD8 );//mov  ebx,eax   
               buf_append2ch( bout, 0x8B, 0x06 );//mov  eax,dword ptr [esi]                  
               if ( tmp2 == 0xF3 ) 
                  buf_append2ch( bout, 0x33, 0xD2 );//xor  edx,edx   
               else
                  buf_appendch( bout, 0x99 );//cdq
               buf_append2ch( bout, 0xF7, (ubyte)tmp2 );//div  eax,ebx
               buf_append2ch( bout, 0x89, (ubyte)( 0x06 + tmp ) );//mov  dword ptr [esi],eax/edx                                                
               goto shift;

            case CLeftUIUI:  
            case CLeftII:  
               tmp = 0x26;//shl
               goto rightuiui;
            case CRightII: 
               tmp = 0x3e;//sar
               goto rightuiui;
            case CRightUIUI: 
               tmp = 0x2e;//shr
rightuiui:
               if ( !flgcop ) flgcop = startasm( bout );                  
               buf_appendch( bout, 0xAD );//lods  dword ptr [esi]   
               buf_appendch( bout, 0x51 );//push  ecx
               buf_append2ch( bout, 0x8A, 0xC8 );//mov  cl,al   
               buf_append2ch( bout, 0xD3, (ubyte)tmp );//shr/shl/sar  dword ptr [esi],cl                  
               buf_appendch( bout, 0x59 );//pop  ecx
               goto shift;

            case CSignI:
               if ( !flgcop ) flgcop = startasm( bout );                                 
               buf_append2ch( bout, 0xF7, 0x1E );//neg  dword ptr [esi]
               goto shift;

            case CLessII://jge
               tmp = 0x7D;
               goto equiui;
            case CGreaterII:
               tmp = 0x7E;//jle
               goto equiui;
            case CLessUIUI:
               tmp = 0x73;//jnb
               goto equiui;
            case CGreaterUIUI:
               tmp = 0x76;//jna
               goto equiui;
            case CEqUIUI:
               tmp = 0x75;//jne
equiui:
               if ( !flgcop ) flgcop = startasm( bout );                  
               if ( *ptr == CLognot )
               {
                  ptr++;
                  switch ( cmd )
                  {
                     case CGreaterII:
                     case CGreaterUIUI:
                        tmp++;
                        break;
                     case CLessII:
                     case CLessUIUI:                        
                     case CEqUIUI:
                        tmp--;
                  }
               }
               buf_appendch( bout, 0xAD );//lods  dword ptr [esi]   
               buf_append2ch( bout, 0x33, 0xD2);//xor  edx,edx   
               buf_append2ch( bout, 0x39, 0x06);//cmp  dword ptr [esi],eax   
               buf_append2ch( bout, (ubyte)tmp, 0x01);//jne/jge/jle  1
               buf_appendch( bout, 0x42 );//inc  edx   
               buf_append2ch( bout, 0x89, 0x16 );//mov  dword ptr [esi],edx
               goto shift;

            case CNotUI:            
               if ( !flgcop ) flgcop = startasm( bout );
               buf_append2ch( bout, 0xF7, 0x16 );//not  dword ptr [esi]
               goto shift;

            case CSubUI: 
               tmp = 0x29;//0x2B;//sub
               goto binopui;
            case CAndUI: 
               tmp = 0x21;//0x23;//and
               goto binopui;
            case COrUI: 
               tmp = 0x09;//0x0B;//or
               goto binopui;
            case CXorUI: 
               tmp = 0x31;//0x33;//xor
               goto binopui;
            case CAddUI:               
               tmp = 0x01;//0x03;//add
binopui:
               if ( !flgcop ) flgcop = startasm( bout );                  
               buf_appendch( bout, 0xAD );//lods dword ptr [esi]   
               buf_append2ch( bout, 0x8B, 0x16 );//mov  edx,dword ptr [esi]      
               //buf_append2ch( bout, (ubyte)tmp, 0x02 );//add/sub/and/or/xor  eax,dword ptr [edx]      
               buf_append2ch( bout, (ubyte)tmp, 0x02 );//add/sub/and/or/xor  dword ptr [edx], eax
               //buf_append2ch( bout, 0x89, 0x02 );//mov  dword ptr [edx],eax      
               buf_append2ch( bout, 0x8B, 0x02 );//mov  eax, dword ptr [edx]
               buf_append2ch( bout, 0x89, 0x06 );//mov  dword ptr [esi],eax
               goto shift;
               
            case CMulUI:       
            case CMulI:                      
               if ( !flgcop ) flgcop = startasm( bout );                  
               buf_appendch( bout, 0xAD );//lods dword ptr [esi]                 
               buf_append2ch( bout, 0x8B, 0x1E );//mov  ebx,dword ptr [esi]                              
               buf_append3ch( bout, 0x0F, 0xAF, 0x03 );//imul eax,dword ptr [ebx]
               buf_append2ch( bout, 0x89, 0x03 );//mov dword ptr [ebx],eax
               buf_append2ch( bout, 0x89, 0x06 );//mov dword ptr [esi],eax               
               goto shift;            

            
            case CDivUI:       
               tmp = 0;
               tmp2 = 0xF3;
               goto divui;
            case CModUI:       
               tmp = 0x10;
               tmp2 = 0xF3;
               goto divui;
            case CDivI:
               tmp = 0;
               tmp2 = 0xFB;
               goto divui;
            case CModI:   
               tmp = 0x10;
               tmp2 = 0xFB;               
divui:
               if ( !flgcop ) flgcop = startasm( bout );                  
               buf_appendch( bout, 0x51 );//push  ecx
               buf_appendch( bout, 0xAD );//lods dword ptr [esi]   
               buf_append2ch( bout, 0x8B, 0xD8 );//mov  ebx,eax   
               buf_append2ch( bout, 0x8B, 0x0E );//mov  ecx,dword ptr [esi]                              
               buf_append2ch( bout, 0x8B, 0x01 );//mov  eax, dword ptr[ecx]                                             
               if ( tmp2 == 0xF3 ) 
                  buf_append2ch( bout, 0x33, 0xD2 );//xor  edx,edx   
               else
                  buf_appendch( bout, 0x99 );//cdq
               buf_append2ch( bout, 0xF7, (ubyte)tmp2 );//div/idiv eax,ebx                              
               buf_append2ch( bout, 0x89, (ubyte)( 0x01 + tmp ) );//mov dword ptr [ecx],eax/edx
               buf_append2ch( bout, 0x89, (ubyte)( 0x06 + tmp ) );//mov  dword ptr [esi],eax/edx                                 
               buf_appendch( bout, 0x59 );//pop  ecx
               goto shift;

            
            case CLeftUI:     
            case CLeftI:      
               tmp = 0xE3;//shl
               goto rightui;
            case CRightI: 
               tmp = 0xFB;//sar
               goto rightui;
            case CRightUI:    
               tmp = 0xEB;//shr
rightui:
               if ( !flgcop ) flgcop = startasm( bout );                  
               buf_appendch( bout, 0xAD );//lods  dword ptr [esi]   
               buf_appendch( bout, 0x51 );//push  ecx
               buf_append2ch( bout, 0x8A, 0xC8 );//mov  cl,al   
               buf_append2ch( bout, 0x8B, 0x16 );//mov  edx,dword ptr [esi]                              
               buf_append2ch( bout, 0x8B, 0x1A );//mov  ebx,dword ptr [edx]
               buf_append2ch( bout, 0xD3, (ubyte)tmp );//shr/shl/sar ebx,cl                  
               buf_append2ch( bout, 0x89, 0x1E );//mov  dword ptr [esi],ebx
               buf_append2ch( bout, 0x89, 0x1A );//mov  dword ptr [edx],ebx
               buf_appendch( bout, 0x59 );//pop  ecx
               goto shift;

            case CSubcall:
               if ( !flgcop ) flgcop = startasm( bout );                                                
               tmp = (*(ptr) + 1)<<2;                                             
               off = *(puint)((uint)bjmpdst.data + findnear( &bjmpsrc, tmp, 0 )) - bout->use - 5;                               
               buf_appendch( bout, 0xE8 );//call
               buf_appenduint( bout, off );
               /*// Меняем стэк 
               *curpos->top++ = ( uint )( curpos->cmd + 2 ); // указатель на команду после выхода
               *curpos->top++ = ( uint )curpos->clmark;  // текущее значение clmark 
               *curpos->top++ = 0;               // Количество возвращаемых dword 
               *curpos->top++ = 0;               // Количество полученных dword в качестве параметров
               curpos->clmark = curpos->top;     // Новое значение clmark
               // Указатель на первую команду подфункции
               curpos->cmd = ( puint )curpos->func->func + *( curpos->cmd + 1 );*/
               goto shift;

            case CSubret:       
               subretsize = *ptr;
               /* *( curpos->clmark - 2 ) = *( curpos->cmd + 1 );*/
               goto shift;

            case CSubpar:
               if ( !flgcop ) flgcop = startasm( bout );                
               buf_appendch( bout, 0x51 );//push ecx                  
               buf_appendch( bout, 0x56 );//push esi
               buf_appendch( bout, 0x57 );//push edi

               (pvarset)tmp = bcode->sets + *ptr;
               subparsize = ((pvarset)tmp)->size/*pset->size*/;
               tmp = (bcode->vars + ((pvarset)tmp)->first)->off << 2;               
               if (tmp < 128)
               {
                  buf_append3ch( bout, 0x83, 0xC7, ( ubyte )tmp );//add edi, tmp
               }
               else
               {
                  buf_append2ch( bout, 0x81, 0xC7 );//add edi, tmp
                  buf_appenduint( bout, tmp );
               }               

               tmp = 4 + subparsize * 4;
               if (tmp < 128)
               {
                  buf_append3ch( bout, 0x83, 0xEE, ( ubyte )tmp );//sub esi, tmp
               }
               else
               {
                  buf_append2ch( bout, 0x81, 0xEE );//sub esi, tmp
                  buf_appenduint( bout, tmp );
               }               
               
               buf_appendch( bout, 0xB9 );//mov  ecx, subparsize
               buf_appenduint( bout, subparsize );
               buf_appendch( bout, 0xFC );//cld
               buf_append2ch( bout, 0xF3, 0xA5 );//rep movs dword ptr [edi],dword ptr [esi]
               buf_appendch( bout, 0xFD );//std

               buf_appendch( bout, 0x5F );//pop  edi
               buf_appendch( bout, 0x5E );//pop  esi
               buf_appendch( bout, 0x59 );//pop  ecx               
               goto shift;

            case CSubreturn:
               if ( !flgcop ) flgcop = startasm( bout );                                 
               for ( tmp = 0; tmp < subretsize; tmp++ )
               {
                  buf_appendch( bout, 0xAD );//lods dword ptr [esi]  
                  buf_appendch( bout, 0x50 );//push eax
               }
               buf_append3ch( bout, 0x8B, 0x71, 0x14 );//mov esi, dword ptr [ecx+14h]
               buf_appendch( bout, 0xAD );//lods dword ptr [esi]   
               buf_append3ch( bout, 0x89, 0x41, 0x14 );//mov dword ptr [ecx+0x14], eax
               buf_appendch( bout, 0xAD );//lods dword ptr [esi]   
               
               tmp = (subparsize - subretsize)<<2;
               if (tmp < 128)
               {
                  buf_append3ch( bout, 0x83, 0xEE, ( ubyte )tmp );//sub esi, tmp
               }
               else
               {
                  buf_append2ch( bout, 0x81, 0xEE );//sub esi, tmp
                  buf_appenduint( bout, tmp );
               }               
               
               if ( subretsize == 2 )
               {
                  buf_appendch( bout, 0x5A );//pop  edx  
                  buf_append3ch( bout, 0x89, 0x56, 0xFC );//mov  dword ptr [esi-4], edx   
               }
               if ( subretsize )
               {
                  buf_appendch( bout, 0x5A );//pop  edx  
                  buf_append2ch( bout, 0x89, 0x16 );//mov  dword ptr [esi], edx
               }               

               buf_appendch( bout, 0x50 );//push eax
               buf_appendch( bout, 0xC3 );//ret
               
               /*// Выход из подфункции
               top = curpos->clmark - 4;  // Указатель на старый top 
               // Восстанавливаем команду
               curpos->cmd = ( puint )*top;
               curpos->clmark = ( puint )*( top + 1 );
               i = *( top + 2 );
               // записываем возвращаемое значение
               if ( i )
                  mem_copyui( top - *( top + 3 ), curpos->top - i, i );
                  // Устанавливаем стэк
               curpos->top = top + i - *( top + 3 );*/
               goto shift;
            
            case CDwsload: 
            case CAsm:
               i = *ptr + 2;               
               *ptr--;
               for ( i; i > 0; i-- ) 
               {                                    
                  buf_appenduint( bout, *ptr++ );
               }
               break;

            case CDecLeftUB:
               flgtmp = 5;
               goto leftinc;
            case CDecLeftUS:
               flgtmp = 4;
               goto leftinc;
            case CDecLeftUI:
               flgtmp = 3;
               goto leftinc;
            case CIncLeftUB:
               flgtmp = 2;
               goto leftinc;
            case CIncLeftUS:
               flgtmp = 1;
               goto leftinc;
            case CIncLeftUI:
               flgtmp = 0;
leftinc:
               if ( !flgcop ) flgcop = startasm( bout );                                 
               buf_append2ch( bout, 0x8B, 0x06 );//mov  eax,dword ptr [esi]   
               switch ( flgtmp )
               {
                  case 0:
                     buf_append2ch( bout, 0xFF, 0x00 );//inc  dword ptr [eax]   
                     break;
                  case 1:                     
                     buf_append3ch( bout, 0x66, 0xFF, 0x00 );//inc word ptr [eax]
                     break;
                  case 2:
                     buf_append2ch( bout, 0xFE, 0x00 );//inc  byte ptr [eax]
                     break;
                  case 3:
                     buf_append2ch( bout, 0xFF, 0x08 );//dec  dword ptr [eax]   
                     break;
                  case 4:                     
                     buf_append3ch( bout, 0x66, 0xFF, 0x08 );//dec word ptr [eax]
                     break;
                  case 5:
                     buf_append2ch( bout, 0xFE, 0x08 );//dec  byte ptr [eax]
                     break;
               }               
               buf_append2ch( bout, 0x8B, 0x18 );//mov  ebx,dword ptr [eax]   
               buf_append2ch( bout, 0x89, 0x1E );//mov  dword ptr [esi],ebx
               goto shift;
            
            case CDecRightUB:
               flgtmp = 5;
               goto rightinc;
            case CDecRightUS:
               flgtmp = 4;
               goto rightinc;
            case CDecRightUI:
               flgtmp = 3;
               goto rightinc;
            case CIncRightUB:
               flgtmp = 2;
               goto rightinc;
            case CIncRightUS:
               flgtmp = 1;
               goto rightinc;
            case CIncRightUI:
               flgtmp = 0;
rightinc:
               if ( !flgcop ) flgcop = startasm( bout );                                    
               buf_append2ch( bout, 0x8B, 0x06 );//mov  eax,dword ptr [esi]                  
               buf_append2ch( bout, 0x8B, 0x18 );//mov  ebx,dword ptr [eax]   
               buf_append2ch( bout, 0x89, 0x1E );//mov  dword ptr [esi],ebx
               switch ( flgtmp )
               {
                  case 0:
                     buf_append2ch( bout, 0xFF, 0x00 );//inc  dword ptr [eax]   
                     break;
                  case 1:                     
                     buf_append3ch( bout, 0x66, 0xFF, 0x00 );//inc word ptr [eax]
                     break;
                  case 2:
                     buf_append2ch( bout, 0xFE, 0x00 );//inc  byte ptr [eax]
                     break;
                  case 3:
                     buf_append2ch( bout, 0xFF, 0x08 );//dec  dword ptr [eax]   
                     break;
                  case 4:                     
                     buf_append3ch( bout, 0x66, 0xFF, 0x08 );//dec word ptr [eax]
                     break;
                  case 5:
                     buf_append2ch( bout, 0xFE, 0x08 );//dec  byte ptr [eax]
                     break;
               }               
               goto shift;              
            
            
            /*c
            case CPtrglobal:
               if ( flgcop ) 
               {
                  stopasm( bout, flgcop);
                  flgcop = 0;
               }
               buf_appenduint( bout, cmd );
               //ge_getused( *ptr );
               buf_appenduint( bout, *ptr++ );                              
               break;*/

            default:               
               if ( flgcop ) 
               {
                  stopasm( bout, flgcop);
                  flgcop = 0;
               }

               buf_appenduint( bout, cmd );//pop  ebx
               switch ( shifts[ cmd - CNop ] )
               {
                  case SH1_3:
                  case SH2_3:
                     buf_appenduint( bout, *ptr++ );               
                  case SHN1_2:
                  case SH0_2:
                  case SH1_2:
                     buf_appenduint( bout, *ptr++ );               
                     break;
               }
         }

         continue;
shift:               
         
         switch ( shifts[ cmd - CNop ] )
         {
            case SH1_3:
            case SH2_3:
               ptr++;
            case SHN1_2:
            case SH0_2:
            case SH1_2:
               ptr++;
               break;
         }
      }
   }
   ptr = ( puint )bjmpun.data;
   end = ( puint )( ( pubyte )ptr + bjmpun.use );
   //Коррекция переходов
   while ( ptr < end )
   {
      tmp = *(ptr++);      
      off = *(puint)((uint)bjmpdst.data + findnear( &bjmpsrc, *(ptr++), 0 ));
      if ( off )
      {  
         *(puint)((uint)bout->data + tmp ) = off - tmp - 4;         
      }
   }

//   Вывод  
   /*ptr = ( puint )bcode->vmf.func;
   end = ( puint )( ( pubyte )ptr + bcode->bcsize );
   print( "src %i\n", bout->use );
   while ( ptr < end )
      print( "  %x", *ptr++ );
   print( "\n dest \n" );
   ptr = ( puint )bout->data;
   end = ( puint )( ( pubyte )ptr + bout->use );
   while ( ptr < end )
      print( "  %x", *ptr++ );
*/
/*
   bcode->vmf.func = bout->data;
   bcode->bcsize  = bout->use;
*/   
}

#endif // _ASM