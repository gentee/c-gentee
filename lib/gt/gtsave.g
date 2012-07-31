/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: gtsave 29.09.06 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
******************************************************************************/

define
{
   GTS_ENDNAME  = 0x01 // </name> or /name>
   GTS_INLINE   = 0x02 // <name> data </>
   GTS_NOATTRIB = 0x04 // do not save attributes
}

type gtsave
{
   uint   off     // The offset of the first level
   uint   offstep // The offset of the next level
   uint   inside  // If body len < inside then <name = body
   uint   flags   // 
}

method str str.gtsaveval( str value )
{
   uint inside
   uint i
   
   while ( inside = value.findchfrom( '<', i )) < *value
   {   
      this.append( value.ptr() + i, inside - i )
      if !inside || value[ inside + 1 ] == '/' 
      {
         this.out4( "&x%02x;", '<' )
      }
      else : this.appendch( '<' )
      i = inside + 1 
   }
   this.append( value.ptr() + i, inside - i )
   
   return this
}

method str str.gtsaveval( ustr uvalue )
{
   str  value
   
   uvalue.toutf8( value )
   return this.gtsaveval( value )
}

// Save gtitem to a string 
method str gtitem.save( str ret, gtsave gts )
{
   subfunc attr2text( str in )
   {
      uint space slash q dq i
      
      slash = in.findch( '/' )
      if in.findch( ' ' ) < *in ||
         slash < *in || in.findch( '>' ) < *in
      {
         dq = in.findch( '"' )
         if dq < *in
         {
            if ( q = in.findch( 0x27 /*'''*/ )) < *in
            {
               fornum i, *in
               {
                  switch in[ i ]
                  { 
                     case '"',0x27 /*'''*/,'/'
                     {
                        ret.out4( "&x%02x;", in[i] ) 
                     } 
                     default : ret.appendch( in[i] ) 
                  } 
               }           
            }
            else : ret += "'\(in)'"  
         }  
         else : ret += "\"\(in)\""
      }
      else : ret += in 
   }
   
//   gtitems  gtis
   str      soff name
   uint     i inside   
   
   soff = " ".repeat( gts.off )
   
   if this.comment 
   {
      return ret += "\( soff )<-\( this.value )->\l"
   }
   if this.isroot()
   {
      foreach  curroot, this : curroot->gtitem.save( ret, gts )
      return ret
   }
   name = this.name
   if name[1] == ' ' : name = "_"
   ret += "\( soff )<\(name)"
   if gts.flags & $GTS_NOATTRIB : goto skipattrib 
   if *this.value < gts.inside
   {
      if *this.value
      { 
         ret += " = "
         attr2text( this.value )
      }
      inside = 1
   } 
   fornum i = 0, *this.attrib
   {
      ret += " \(this.attrib[i].name)"
      if *this.attrib[i].value
      {
         ret += " = "
         attr2text( this.attrib[i].value )
      }
   }
   label skipattrib
      
   if inside && !this.haschild()  
   {
      if name != "_" && gts.flags & $GTS_ENDNAME : ret += " /\(name)>\l"
      else : ret += " />\l"
      return ret
   }
   elif gts.flags & $GTS_INLINE && !this.haschild() : ret += " >"
   else : ret += " >\l"
   
   gts.off += gts.offstep
   foreach  cur, this
   {
      cur->gtitem.save( ret, gts )
   }
   gts.off -= gts.offstep
   
   if !inside
   {
      ret.gtsaveval( this.value )
/*      i = 0
      while ( inside = this.value.findchfrom( '<', i )) < *this.value
      {   
         ret.append( this.value.ptr() + i, inside - i )
         if !inside || this.value[ inside + 1 ] == '/' 
         {
            ret.out4( "&x%02x;", '<' )
         }
         else : ret.appendch( '<' )
         i = inside + 1 
      }
      ret.append( this.value.ptr() + i, inside - i )*/
//      print("Ret=\("".substr(ret, 0, 50 ))\n")
      if *this.value && !( gts.flags & $GTS_INLINE ) : ret += "\l"
   }
   if gts.flags & $GTS_INLINE && !this.haschild() : soff.clear()
   if name != "_" && gts.flags & $GTS_ENDNAME : ret += "\(soff)</\(name)>\l"
   else : ret += "\(soff)</>\l"
   return ret
}

method str gtitem.savechildren( str ret, gtsave gts )
{
   foreach curg, this
   {
      curg.save( ret, gts )
   }
   return ret
}

method uint gt.write( str filename, gtsave gts )
{
   str  stemp
   
   if this.utf8 : stemp = "﻿"      
   this.root().save( stemp, gts ) 
   return stemp.write( filename )  
}

method uint gt.write( str filename )
{
   gtsave gts
   
   gts.offstep = 3
   gts.flags = $GTS_INLINE
   return .write( filename, gts )  
}