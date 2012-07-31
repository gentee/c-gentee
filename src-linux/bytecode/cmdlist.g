/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved.
* This file is part of the Gentee open source project - http://www.gentee.com.
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT").
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS
* ACCEPTANCE OF THE AGREEMENT.
*
* Author: Alexey Krivonogov ( gentee )
*
* Contributors: Sergey ( SWR )
*
* Summary: The program genertaes cmdlist.h and cmdlist.ñ files
*
******************************************************************************/

include : $"..\..\lib\gt\gt.g"

global
{
//         OVM_TYPE      flags       size    name          subtype
//                 NAME | PACK | STACK
   // Type description
   buf  types = '\h
\* TInt *\   05      \h4  10003   \h  0B   \"int" 0        4
\* TUInt *\  05      \h4  10003   \h  0C   \"uint" 0       4
\* TByte *\  05      \h4  10003   \h  0C   \"byte" 0       1
\* TUByte *\ 05      \h4  10003   \h  0D   \"ubyte" 0      1
\* TShort *\  05     \h4  10003   \h  0D   \"short" 0      2
\* TUShort *\ 05     \h4  10003   \h  0E   \"ushort" 0     2
\* TFloat *\  05     \h4  10003   \h  0D   \"float" 0      4
\* TDouble *\ 05     \h4  10003   \h  0E   \"double" 0     8
\* TLong *\   05     \h4  10003   \h  0C   \"long" 0       8
\* TULong *\  05     \h4  10003   \h  0D   \"ulong" 0      8
\* TReserved *\  05  \h4  00203   \h  12   \"reserved" 0
    \* index = TUByte & indexof *\ 4   0                   0
\* TBuf *\    05     \h4  00203   \h  29   \"buf" 0
    \* index = TUByte & indexof *\ 4   0                   4
    \* data  type = TUInt & name *\  2  1 \"data" 0
    \* use   type = TUInt & name *\  2  1 \"use" 0
    \* size  type = TUInt & name *\  2  1 \"size" 0
    \* step  type = TUInt & name *\  2  1 \"step" 0        0
\* TStr *\    05     \h4  00103   \h  0E   \"str" 0
               \* inherit = buf *\  0C                     1
       \*  type = TBuf *\            0C   0
\* TArr *\    05     \h4  00303   \h  28   \"arr" 0 
               \* inherit = buf *\  0C 
    \* index = 0  & indexof *\ 0   0                   4
       \*  type = TBuf *\            0C   0
       \* itype  type = TUInt & name *\  2 1 \"itype" 0
       \* isize  type = TUInt & name *\  2 1 \"isize" 0
       \* dim    type = TReserved & name *\  0B 5 \"dim" 0
           \*dimcount*\ 1 \* 8 * sizeof( uint )*\ 20
\* TCollection *\  05 \h4  00303   \h  26   \"collection" 0
               \* inherit = buf *\  0C                     
    \* index = TUInt & indexof *\ 2   0                    3
       \*  type = TBuf *\           0C  0
    \* count  type = TUInt & name *\  2 1 \"count" 0
    \* flag  type = TUInt & name *\   2 1 \"flag" 0
\* TAny *\    05     \h4  10003   \h  0B   \"any"  0      4
\* TFordata *\   05     \h4  00003   \h  16   \"fordata" 0 
                1
       \*  type = TUint *\            2   1 \"icur" 0
'

arrstr typesnames = %{"/* TInt        */", "/* TUInt       */", "/* TByte       */", "/* TUByte      */", "/* TShort      */",
                      "/* TUShort     */", "/* TFloat      */", "/* TDouble     */", "/* TLong       */", "/* TULong      */",
                      "/* TReserved   */", "/* TBuf        */", "/* TStr        */", "/* TArr        */", "/* TCollection */",
                      "/* TAny        */", "/* TFordata    */" }
}




/*-----------------------------------------------------------------------------
*
* ID: headerout 12.10.06 1.1.A. 
* 
* Summary: 
*  
-----------------------------------------------------------------------------*/

text headerout( str name author summary )
/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved.
* This file is part of the Gentee open source project <http://www.gentee.com>.
*
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT").
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS
* ACCEPTANCE OF THE AGREEMENT.
*
* \(name) \{
   str      sdate
   datetime dt
   getdatetime( dt.gettime(), sdate, 0->str )
   @sdate 
} 0.0.A.
*
* Author: \(author)
*
* Summary: \(summary)
*
******************************************************************************/
\!

func str str12<result>(str n, int i){
int len = *n;
str ret = ",";
   while len<13 {
      len++;
      ret += " ";
   }
   n += ret;
   ret = "//  ";
   if(i<0x10){
      ret += " "
   }
   n += ret + "0x" + hex2stru( i );
result = n;
}
/*-----------------------------------------------------------------------------
*
* ID: cmdlist_h 12.10.06 1.1.A. 
* 
* Summary: The .h output function.
*  
-----------------------------------------------------------------------------*/
text cmdlist_h( arrstr acmd, arrstr cmt, arrstr shift  )
\@headerout( "cmdlist_h", "Generated with 'cmdlist' program", 
"This file contains a list of the embedded byte-code commands.")
#ifndef _CMDLIST_
#define _CMDLIST_

   #ifdef __cplusplus
      extern "C" {
   #endif // __cplusplus

#include "../common/types.h"

#define  CMDCOUNT  \( *acmd )
#define  STACK_COUNT  \( *shift )

enum {
\{
   uint i
  
   fornum i, *acmd
   { 
      @"   \(str12(acmd[ i ], i)),  \(i) \( cmt[i] )\l" 
   }   
}
};

extern const ubyte shifts[];
extern const ubyte embtypes[];

   #ifdef __cplusplus
      }
   #endif // __cplusplus

#endif // _CMDLIST_
\!

/*-----------------------------------------------------------------------------
*
* ID: cmdlist_h 12.10.06 1.1.A. 
* 
* Summary: The .c output function.
*  
-----------------------------------------------------------------------------*/

text  cmdlist_c( arrstr shift acmd )
\@headerout( "cmdlist_c", "Generated with 'cmdlist' program",
"This file contains shift types of the embedded byte-code commands.")

#include "cmdlist.h"
#include "bytecode.h"



const ubyte embtypes[] = {
\{
   uint i, ii = 0, n = 0;  
   
   fornum i, *types
   {
      if ( types[i] == 5 && types[i+1] == 3){
         if i != 0: @"\l"
         @"\(typesnames[(ii++)]) "
         n = 0;
      }
      if types[i]>0xF: @"0x\( hex2stru(types[i])),"
      else:       @"0x0\( hex2stru(types[i])),"
      if(n++ == 18 ): @"\l                  " 
   }
}
};

const ubyte shifts[] = {
\{
ii = 1;
   fornum i = 0, *shift
   {
      @"\(shift[i]), // \(acmd[i+18])\l"
   }
}
};
\!

/*-----------------------------------------------------------------------------
*
* ID: cmdmain 12.10.06 1.1.A.ABKL 
* 
* Summary: The main function.
*  
-----------------------------------------------------------------------------*/

func main<main>
{
   arrstr shift
   arrstr aout
   arrstr cmt
   str hout
   gt cmdgt
//   gtitems gtis
   
   cmdgt.read( "cmdlist.gt" )
   foreach cur, cmdgt.root()//.items( gtis )
   {
      str stemp 
      int shcmd shtop
    
      cur as gtitem  
      if cur.comment : continue 
      aout += cur.name
      cur.get("comment", stemp )
      if cur.find("type")
      {
//         shift += "SH_TYPE"
      }
      else
      {
         shcmd = cur.getint("cmdshift" )
         shtop = cur.getint("topshift" )
         switch shtop
         {
            case -3
            {
               switch shcmd
               {
                  case 0: shift += "SHN3_1"
                  default : print("Unknown shift \( cur.name )\n")
               }
            }
            case -2
            {
               switch shcmd
               {
                  case 0: shift += "SHN2_1"
                  default : print("Unknown shift \( cur.name )\n")
               }
            }
            case -1
            {
               switch shcmd
               {
                  case 0: shift += "SHN1_1"
                  case 1: shift += "SHN1_2"
                  default : print("Unknown shift \( cur.name )\n")
               }
            }
            case 0
            {
               switch shcmd
               {
                  case 0: shift += " SH0_1"
                  case 1: shift += " SH0_2"
                  default : print("Unknown shift \( cur.name )\n")
               }
            }
            case 1
            {
               switch shcmd
               {
                  case 0: shift += " SH1_1"
                  case 1: shift += " SH1_2"
                  case 2: shift += " SH1_3"
                  default : print("Unknown shift \( cur.name )\n")
               }    
            }
            case 2
            {
               switch shcmd
               {
                  case 0: shift += " SH2_1"
                  case 2: shift += " SH2_3"
                  default : print("Unknown shift \( cur.name )\n")
               }    
            }
         }
      }
      cmt += stemp     
   }
   hout@cmdlist_h( aout, cmt, shift )
   hout.write( "cmdlist.h" )
   hout.clear()
   hout@cmdlist_c( shift, aout )
   hout.write( "cmdlist.c" )
   congetch("Press any key...")   
}
