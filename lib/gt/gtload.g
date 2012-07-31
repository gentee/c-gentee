/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: gtload 06.10.06 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
******************************************************************************/

extern
{
   method  gtitem gtitem.insertchild( str name, gtitem after )
}

method gtitem gtitem.load( str in, gtitem after )
{
   uint    i  off  start nameoff
   arrout  out
//   lex     ilex
//   uint    ilex
   stack   sgt
   uint    igt   // The current gtitem
   uint    ilast = &after
   str     attrib
  
//   print( in ) 
   out.isize = sizeof( lexitem )
   if this.getgt().utf8 && !in.isprefutf8()
   {
      ustr  utemp
      utemp = in
      utemp.toutf8( in )
   }
//   lex_tbl( ilex, lexgt.ptr())
//ifdef  $DEBUG : print("Load 0\n")
//   gentee_lex( in->buf, this.maingt->gt.lexgt, out )
   gentee_lex( &in, this.maingt->gt.lexgt, &out )
//ifdef  $DEBUG : print("Load 1\n")
   start = in.ptr()
   off = out.data.ptr()
   igt as this 
   
   fornum i, *out
   {
      str   stemp
      uint  li 
      
      li as off->lexitem
//ifdef  $DEBUG 
//{
//      print("type=\( li.ltype ) pos = \(li.pos) len=\(li.len )\n")
//}
      switch li.ltype
      {
         case $gt_BEGIN
         {
            nameoff = li.pos + 1
            sgt.push( &igt )
            if in[ nameoff ] == '|' : nameoff++
            if in[ nameoff ] == '*' : nameoff++
             
            stemp.copy( start + nameoff, li.len - nameoff + li.pos )
//            print("\(stemp)\n")
            igt as igt.insertchild( stemp, ilast->gtitem )
            if *sgt == 1 : ilast = &igt
            attrib.clear()
         }
         case $gt_NAME
         {
            attrib.copy( start + li.pos, li.len )
            igt.set( attrib, "" )
         }
         case $gt_STRATTR
         {
            stemp.copy( start + li.pos, li.len )
            if *attrib : igt.set( attrib, stemp )
            else : igt.value = stemp
         }
         case $gt_STRDQ, $gt_STRQ
         {
            stemp.copy( start + li.pos + 1, li.len - 2 )
            if *attrib : igt.set( attrib, stemp )
            else : igt.value = stemp   
         }
         case $gt_DATA
         {
            igt.value.copy( start + li.pos, li.len )
            igt.value.trimsys()
            uint off 
            while ( off = igt.value.findchfrom( '&', off )) < *igt.value 
            {
               if "&x3c;".eqlenign( igt.value.ptr() + off )
               {
                  igt.value.replace( off, 5, "<")
               } 
               off++ 
            }
//            igt.value.replace( "&x3c;", "<", $QS_IGNCASE ) 
         }
         case $gt_COMMENT
         {
            uint comment
            
            comment as igt.insertchild( "", ilast->gtitem )  
            ilast = &igt
            comment.comment = 1
            comment.value.copy( start + li.pos + 2, li.len - 4 )
         }
         case $gt_END
         {
            igt as sgt.popval()->gtitem
         }
      }
      off += sizeof( lexitem )            
   }
//ifdef  $DEBUG : print("Load OK\n")
   return ?( ilast, ilast->gtitem, this )   
}

method gtitem gtitem.load( str in )
{
   return this.load( in, 0xFFFFFFFF->gtitem )
}

method uint gt.read( str filename )
{
   str  stemp
   
   stemp.read( filename )
   this.root().load( stemp )  
   return *stemp != 0
}

method uint gtitem.read( str filename )
{
   str  stemp
   
   stemp.read( filename )
   this.load( stemp )  
   return *stemp != 0
}
