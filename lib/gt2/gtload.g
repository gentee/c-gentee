/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: gt2load 06.10.06 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
******************************************************************************/

extern
{
   method  gt2item gt2item.insertchild( str name, gt2item after )
}

method gt2item gt2item.load( str in, gt2item after )
{
{
   uint    i  off  start nameoff
   arrout  out
//   lex     ilex
//   uint    ilex
   stack   sgt2
   uint    igt2   // The current gt2item
   str     attrib
   
   out.data.expand( 100000 )
   out.isize = sizeof( lexitem )
   
//   lex_tbl( ilex, lexgt2.ptr())
ifdef  $DEBUG : print("Load 0\n")
   gentee_lex( in->buf, this.maingt2->gt2.lexgt2, out )
ifdef  $DEBUG : print("Load 1 >>>\(*in)<<<\n")
   start = in.ptr()
   off = out.data.ptr()
   igt2 as this 
   
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
         case $gt2_BEGIN
         {
            nameoff = li.pos + 1
            sgt2.push( &igt2 )
            if in[ nameoff ] == '|' : nameoff++
            if in[ nameoff ] == '*' : nameoff++
             
            stemp.copy( start + nameoff, li.len - nameoff + li.pos )
//            print("\(stemp)\n")
            igt2 as igt2.insertchild( stemp, after )
            attrib.clear()
         }
         case $gt2_NAME
         {
            attrib.copy( start + li.pos, li.len )
            igt2.set( attrib, "" )
         }
         case $gt2_STRATTR
         {
            stemp.copy( start + li.pos, li.len )
            if *attrib : igt2.set( attrib, stemp )
            else : igt2.value = stemp   
         }
         case $gt2_STRDQ, $gt2_STRQ
         {

            stemp.copy( start + li.pos + 1, li.len - 2 )
            if *attrib : igt2.set( attrib, stemp )
            else : igt2.value = stemp   
         }
         case $gt2_DATA
         {

            igt2.value.copy( start + li.pos, li.len )
            igt2.value.trimsys()
         }
         case $gt2_COMMENT
         {
            uint comment
            
            comment as igt2.insertchild( "", after )  
            comment.comment = 1
            comment.value.copy( start + li.pos + 2, li.len - 4 )
         }
         case $gt2_END
         {

            igt2 as sgt2.popval()->gt2item
         }
      }
      off += sizeof( lexitem )            
   }
   ifdef  $DEBUG : print("Stackcount = \( *sgt2 )\n")
   ifdef  $DEBUG : print("Arrcount = \( *out ) Ismem = \(out.isobj) isize = \( out.isize )\n")
   ifdef  $DEBUG : print("Bufptr = \( out.data.ptr()) size = \( out.data.size ) use = \( *out.data )\n")
   
}   
   ifdef  $DEBUG : print("Load OK\n")
   return this   
}

method gt2item gt2item.load( str in )
{
   return this.load( in, 0->gt2item )
}

method gt2 gt2.read( str filename )
{
   str  stemp
   
   this.root().load( stemp.read( filename ))  
   return this
}

method gt2item gt2item.read( str filename )
{
   str  stemp
   
   return this.load( stemp.read( filename ))  
}
