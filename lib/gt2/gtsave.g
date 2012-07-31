/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: gt2save 29.09.06 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
******************************************************************************/

type gt2save
{
   uint off     // The offset of the first level
   uint offstep // The offset of the next level
   uint inside  // If body len < inside then <name = body
   uint endname // </name> or /name>
}

// Save gt2item to a string 
method str gt2item.save( str ret, gt2save gt2s )
{
   subfunc attr2text( str in )
   {
      uint space slash q dq i
      
      slash = in.findch( '/', 0 )
      if ( space = in.findch( ' ', 0 )) < *in ||
         slash < *in
      {
         dq = in.findch( '"', 0 )
         if dq < *in
         {
            if ( q = in.findch( ''', 0 )) < *in
            {
               fornum i, *in
               {
                  switch in[ i ]
                  { 
                     case '"',''','/'
                     {
                        int2str( ret, "&x%02x;", in[i] ) 
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
   
   gt2items  gt2is
   str      soff name
   uint     i inside   
   
   soff = " ".repeat( gt2s.off )
   
   if this.comment 
   {
      return ret += "\( soff )<-\( this.value )->\l"
   }
   if this.isroot()
   {
      foreach  curroot, this.items( gt2is ) : curroot.save( ret, gt2s )
      return ret
   }
   name = this.name
   name.setlen( name.findch( ' ', 0 ))   
   ret += "\( soff )<\(name)"
   if *this.value < gt2s.inside
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
   if inside && !this.haschild()  
   {
      if name != "_" && gt2s.endname : ret += " /\(name)>\l"
      else : ret += " />\l"
      return ret
   }
   else : ret += " >\l"
   
   gt2s.off += gt2s.offstep
   foreach  cur, this.items( gt2is )
   {
      cur.save( ret, gt2s )
   }
   gt2s.off -= gt2s.offstep
   
   if !inside
   {
      i = 0
      while ( inside = this.value.findchfrom( '<', i )) < *this.value
      {   
         ret.append( this.value.ptr() + i, inside - i )
         if !inside || this.value[ inside + 1 ] == '/' 
         {
            int2str( ret, "&x%02x;", '<' )
         }
         else : ret.appendch( '<' )
         i = inside + 1 
      }
      ret.append( this.value.ptr() + i, inside - i )
      if *this.value : ret += "\l"
   }
   if name != "_" && gt2s.endname : ret += "\(soff)</\(name)>\l"
   else : ret += "\(soff)</>\l"
   return ret
}

method uint gt2.write( str filename, gt2save gt2s )
{
   str  stemp
   
   this.root().save( stemp, gt2s ) 
   return stemp.write( filename )  
}
