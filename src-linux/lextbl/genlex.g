/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: genlex 18.10.06 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
* Summary: This program creates tables for lexical analizer. It gets a
  wwwww wwwww
*
******************************************************************************/

include
{
   $"..\..\lib\gt\gt.g"
}

method uint hash.gettype
{
   return this.itype
}

operator  hash  =( hash left, collection right )
{
   uint i
   
   while i < *right - 1
   {
      if right.gettype( i ) != str : break 
      if left.itype == str 
      {
         left->hash of str[ right[ i ]->str ] = right[ ++i ]->str 
      }
      else : left[ right[ i ]->str ] = right[ ++i ]
             
      i++
   }   
   return left
}

method  buf buf.generatelex( gtitem gti, hash defines )
{
   uint    count icmd // latest custom command 
//   gtitems gtis
   hash    lexcmd lexflag lexstate 
   
   lexflag.ignorecase()
   lexcmd.ignorecase()
   
   lexcmd = %{ "STOP"  , 0xFF000000,   "OK", 0xFE000000, "SKIP", 0xFD000000,
            "GTNAME", 0xFC000000, "STRNAME", 0xFB000000, "EXPR", 0xFA000000 }
   lexflag = %{   "itstate" , 0x0001, "itcmd", 0x0002, "pos"  , 0x0004, 
                  "stay"    , 0x0008, "try"  , 0x0010, "ret"  , 0x0020,
                  "value"   , 0x0040, "push" , 0x0080, "pop"  , 0x0100,
                  "pushli"  , 0x0200, "popli", 0x0400, "multi", 0x0800,
                  "hexmulti", 0x0800, "keyword", 0x1000, "new", 0x2000,
                  "pair", 0x4000 }
                  
   subfunc uint getcsf( gtitem gti ) // Get state cmd and flags 
   {
      uint ret
      str  state
      
      foreach curl, lexflag.keys
      {
         if gti.find( curl ) : ret |= lexflag[ curl ]  
      }
      if *gti.get( "state", state )
      {
         if !lexstate.find( state )
         {
            congetch( "Cannot find \(state) state!" )
         }
         ret |= lexstate[ state ] << 16
         if gti.find( "itstate" ) : defines[ state ] = ret & 0xFF0000 
      }
      if *gti.get( "cmd", state )
      {
         if !lexcmd.find( state ) : lexcmd[ state ] = ( ++icmd ) << 24   
         ret |= lexcmd[ state ]         
         if gti.find( "itcmd" ) : defines[ state ] = ret & 0xFF000000 
      }
      if *gti.get( "trycmd", state )
      {
         if !lexstate.find( state )
         {
            congetch( "Cannot find \(state) state!" )
         }
         ret |= lexstate[ state ] << 24         
      }
      return ret 
   }
   subfunc  hexchars( str chars )
   {
      uint i 
      str  stemp 
      
      while i < *chars
      {
         str  s
         
         stemp.appendch( uint("0x\( s.substr( chars, i, 2 ))"))
         i += 2
      }
      chars = stemp
   }
   // Reading all states in lexstate and numerate them   
   foreach  cur, gti
   { 
      cur as gtitem
      if cur.find( "skip" ) || cur.comment : continue
      lexstate[ cur.name ] = ++count
   }
   this += count
   // Main processing
   foreach  curi, gti
   {
      uint    count offcount
//      gtitems gtsub
      curi as gtitem
      
      if curi.find( "skip" ) || curi.comment : continue
      offcount = *this
      this += *curi
      this += getcsf( curi )
      
      foreach cursub, curi
      {
         uint chars i
         str  sch 
         
         cursub as gtitem
         if cursub.comment : continue
      
         count++   
         if cursub.find( "lespace" ) : chars = 0x0120
         elif cursub.find( "name" ) : chars = 0x4100
         elif cursub.find( "numname" ) : chars = 0x3000
         elif cursub.find( "numhex" ) : chars = 0x5800
         elif cursub.find( "multi" )
         {
            cursub.get( "multi", sch ) 
            fornum i = 0, *sch : chars |= sch[i] << ( 8 * i )
         }   
         elif cursub.find( "hexmulti" )
         {
            cursub.get( "hexmulti", sch )
            hexchars( sch ) 
            fornum i = 0, *sch : chars |= sch[i] << ( 8 * i )
         }   
         elif cursub.find( "range" ) 
         {
            cursub.get( "range", sch ) 
            chars |= ( sch[0] << 8 ) | sch[1]
         } 
         elif cursub.find( "hexrange" )
         {
            cursub.get( "hexrange", sch )
            hexchars( sch )              
            chars |= ( sch[0] << 8 ) | sch[1]
         }
         sch.clear()
         
         if !*cursub.get( "ch", sch )
         {
            if *cursub.get( "hexch", sch ) : hexchars( sch )
         }      
         if *sch
         {
            if chars
            {
               fornum i = 0, *sch : chars |= sch[i] << ( 8 * ( i + 2 ))
            }
            else
            {
               chars = sch[0] + ( sch[0] << 8 )
               fornum i = 1, *sch : chars |= sch[i] << ( 8 * ( i + 1 ))
            }   
         }
         this += chars
         this += getcsf( cursub )
//         print("\(cursub.name) = \( *cursub ) \(hex2stru( "", getcsf( cursub )))\n")
      }
      ( this.ptr() + offcount )->uint = count 
//      print("\(curi.name) = \( *curi ) \(hex2stru( "", getcsf( curi )))\n")
   }   
   return this
}

text header( str name )
/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project <http://www.gentee.com>. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* lex\(name) \{
   str      sdate   
   datetime dt
   getdatetime( dt.gettime(), sdate, 0->str )
   @sdate 
}
*
* Author: Generated with 'lextbl' program 
*
* Description: This file contains a lexical table for the lexical analizer.
*
******************************************************************************/
\!

text gout( buf out, str defout keyout name )
\@header( name )

define
{
   // States
\(defout)
   // Keywords
\(keyout)
}

global
{ 
   buf lex\(name) = '\\h4 \{
   uint i
   fornum i, *out >> 2
   {
      @" "//0x"
      this.hexu((out.ptr() + ( i << 2 ))->uint )
      if ( i & 7 ) == 7 : @"\l"
   } 
}'
}
\!

text cout( buf out, str name )
\@header( name )
#include "lextbl.h"

const uint lex\(name)[] = { \{
   uint i
   fornum i, *out >> 2
   {
      @"0x" 
      this.hexu( (out.ptr() + ( i << 2 ))->uint )
      @","//0x"
      if ( i & 7 ) == 7 : @"\l"
   } 
}
};
\!

text hout( buf out, str defout keyout name )
\@header( name )
#ifndef _LEX\(name.upper())_
#define _LEX\( name )_

   #ifdef __cplusplus               
      extern "C" {                 
   #endif // __cplusplus      

// States
\(defout)
// Keywords
\(keyout)

   #ifdef __cplusplus              
      }                            
   #endif // __cplusplus

#endif // _LEX\( name )_
\!

func  generatelex( str name )
{
   uint   gti keyid gtk
   gt     igt
   buf    out kout
   str    prefix stemp sout gdefout gkeyout gfile cfile cdefout ckeyout 
   hash   defines keywords
   
   igt.read( "\(name).gt" )
   gti as igt.find( name )
   gti.get( "prefix", prefix )
   gti.get( "gout", gfile )
   gti.get( "cout", cfile )

   gtk as gti.findrel( "/keywords" )
   if &gtk
   { 
      kout += byte( *gtk )
      kout += byte( ?( gtk.find( "ignore" ), 0x01, 0 ))
         
      foreach curk, gtk
      {
         uint i
         arrstr  names
         curk as gtitem
   
         keyid = curk.getuint( "id" )   
         curk.value.split( names, ' ', $SPLIT_NOSYS )
//         kout += ushort( *names )
         kout += keyid 
         fornum i, *names
         { 
            keywords[ names[i]] = keyid
            kout += names[ i ]
            if *gfile
            {
               gkeyout += "KEY_\(names[i].upper()) = 0x\( hex2stru( 
                          keyid++)) \l"
            }
            if *cfile
            {
               ckeyout += "#define KEY_\(names[i].upper()) 0x\( hex2stru(  
                          keyid++)) // \( keyid - 1 )\l"
            }            
         }
         kout += byte( 0 )
      }
   }
   else : kout += byte( 0 )
   out.generatelex( gti, defines )
   foreach curd, defines.keys
   {
      str comment
      
      igt.get( ?( defines[ curd ] < 0x01000000, "\(name)/\(curd)",
               "\(name)/commands/\(curd)" ), "comment", comment )
      if *gfile
      {
         gdefout += "\(prefix)\(curd) = 0x\(hex2stru( 
                    defines[ curd ])) //  \(comment) \l"
      }
      if *cfile
      {
         cdefout += "#define \(prefix)\(curd) 0x\(hex2stru( 
                    defines[ curd ])) //  \(comment) \l"
      }
   }
   out += kout
   out += 0  // add zero     
   if *gti.get( "binout", stemp ) : out.write( stemp )
   if *gfile
   { 
      sout@gout( out, gdefout, gkeyout, name )
      sout.write( gfile )
   }      
   if *cfile
   {
      sout.clear()
      sout@cout( out, name )
      sout.write( cfile )
      sout.clear()
      sout@hout( out, cdefout, ckeyout, name )
      sout.write( cfile.fsetext( cfile, "h" ) )
   }      
}
