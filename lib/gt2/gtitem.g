/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: gt2item 18.10.06 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
******************************************************************************/

type gt2attrib    
{
   str   name
   str   value
}

type gt2item   
{
   str   name
   str   value
   arr   attrib of gt2attrib  // Массив данных у объекта
                          // 0 - main object data
   byte  comment          // 1 if the object is comment
   uint  maingt2           // owner
}

method tree2item gt2item.gettree2item
{
   return ( &this - sizeof( tree2item ))->tree2item
}

method uint gt2item.moveup()
{
   uint prev cur
   
   cur as this.gettree2item()
   prev as cur.getprev()
   
   if &prev
   {
      prev as prev.getprev()
      return cur.move( prev )
   }
   return 0
}

method uint gt2item.movedown()
{
   uint next cur
   
   cur as this.gettree2item()
   next as cur.getnext()
   
   if &next : return cur.move( next )
   return 0
}

method gt2item gt2item.parent
{
   return this.gettree2item().parent->tree2item.data()->gt2item
}

method str gt2item.getfullname( str result )
{
   uint   data
   stack  tstack
   uint   ti = &this.gettree2item()

   do {
      data = ti->tree2item.data()
      data as gt2item
//      print("\(data.name) ")
      if *data.name : tstack.push()->uint = &data.name
//      ti = ti->tree2item.parent      
   } while ti = ti->tree2item.parent
   
   result.clear()

   do {
      result += tstack.top()->uint->str
      result.appendch( $gt2_CHDIV )
   } while tstack.pop()

   // Delete the last $gt2_CHDIV
   result.setlen( *result - 1 )
   return result
}

method uint gt2item.haschild 
{
   return ?( this.gettree2item().child, 1, 0 )
}

method uint gt2item.isroot
{
   return this.gettree2item().isroot()
}

method uint gt2item.find( str attr )
{
   uint  i
   
   fornum i = 0, *this.attrib
   {
      if this.attrib[ i ].name %== attr : return i + 1
   }
   return 0
}

method uint gt2item.delattrib( str attrib )
{
   uint id
   
   if !*attrib : return 0
   
   if id = this.find( attrib ) : this.attrib.del( id - 1 )
   return 1
}

method str gt2item.get( str attrib value )
{
   uint id
   
   if id = this.find( attrib ) : value = this.attrib[ id - 1 ].value 
   else : value.clear()

   return value       
}

method str gt2item.get( str attrib )
{
   uint id
   
   if id = this.find( attrib ) : return this.attrib[ id - 1 ].value 
   return 0->str       
}


method uint gt2item.getuint( str attrib )
{
   str  stemp
   
   return uint( this.get( attrib, stemp ))
}

method int gt2item.getint( str attrib )
{
   str  stemp
   
   return int( this.get( attrib, stemp ))
}

operator uint *( gt2item gt2i )
{
   return *gt2i.gettree2item()   
}

operator gt2item =( gt2item gt2i, str val )
{
   gt2i.value = val   
   return gt2i
}

//-----------------------------------------------------------------
// For 'foreach' operator 

type gt2items < index = gt2item > 
{        
   uint   parent
   uint   cur
} 

//-----------------------------------------------------------------

method  gt2items  gt2item.items( gt2items items )
{
   items.parent = &this
   items.cur = 0
   return items
}

method uint gt2items.eof
{
   return !this.cur
}

method uint gt2items.next
{
   if !this.cur : return 0

   this.cur = this.cur->tree2item.next   
   return this.cur->tree2item.data()
}

method uint gt2items.first
{
   this.cur = this.parent->gt2item.gettree2item().child
   return this.cur->tree2item.data()
}

//-----------------------------------------------------------------
