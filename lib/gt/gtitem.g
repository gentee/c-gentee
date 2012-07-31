/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: gtitem 18.10.06 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
******************************************************************************/

method treeitem gtitem.gettreeitem
{
   return ( &this - sizeof( treeitem ))->treeitem
}

method uint gtitem.moveup()
{
   uint prev cur
   
   cur as this.gettreeitem()
   prev as cur.getprev()
   
   if &prev
   {
      prev as prev.getprev()
      return cur.move( prev )
   }
   return 0
}

method uint gtitem.movedown()
{
   uint next cur
   
   cur as this.gettreeitem()
   next as cur.getnext()
   
   if &next : return cur.move( next )
   return 0
}

method gtitem gtitem.parent
{
   uint parent
   
   parent as this.gettreeitem().parent()
   
   return ?( parent,  parent.data()->gtitem, 0->gtitem )
}

method str gtitem.getfullname( str result )
{
   uint   data
   stack  tstack
   uint   ti = &this.gettreeitem()

   do {
      data = ti->treeitem.data()
      data as gtitem
      if *data.name : tstack.push()->uint = &data.name
//      ti = ti->treeitem.parent      
   } while ti = ti->treeitem.parent
   
   result.clear()

   do {
      result += tstack.top()->uint->str
      result.appendch( $gt_CHDIV )
   } while tstack.pop()

   // Delete the last $gt_CHDIV
   result.setlen( *result - 1 )
   return result
}

method uint gtitem.haschild 
{
   return ?( this.gettreeitem().child, 1, 0 )
}

method uint gtitem.isroot
{
   return this.gettreeitem().isroot()
}

method uint gtitem.find( str attr )
{
   uint  i
   
   fornum i = 0, *this.attrib
   {
      if this.attrib[ i ].name %== attr : return i + 1
   }
   return 0
}

method uint gtitem.delattrib( str attrib )
{
   uint id
   
   if !*attrib : return 0
   
   if id = this.find( attrib ) : this.attrib.del( id - 1 )
   return 1
}

method str gtitem.get( str attrib value )
{
   uint id
   
   if id = this.find( attrib ) : value = this.attrib[ id - 1 ].value 
   else : value.clear()

   return value       
}

method str gtitem.get( str attrib )
{
   uint id
   
   if id = this.find( attrib ) : return this.attrib[ id - 1 ].value 
   return 0->str       
}


method uint gtitem.getuint( str attrib )
{
   str  stemp
   return uint( this.get( attrib, stemp ))
}

method int gtitem.getint( str attrib )
{
   str  stemp
   return int( this.get( attrib, stemp ))
}

operator uint *( gtitem gti )
{
   return *gti.gettreeitem()   
}

method  gtitem gtitem.lastchild
{
   return this.gettreeitem().lastchild().data()->gtitem 
}

method  gtitem gtitem.child
{
   return this.gettreeitem().child().data()->gtitem 
}

method  gtitem gtitem.getnext
{
   return this.gettreeitem().getnext().data()->gtitem 
}

method  gtitem gtitem.getprev
{
   return this.gettreeitem().getprev().data()->gtitem 
}

//-----------------------------------------------------------------
// For 'foreach' operator 
/*
type gtitems < index = gtitem > 
{        
   uint   parent
   uint   cur
} 
*/
//-----------------------------------------------------------------
/*
method  gtitems  gtitem.items( gtitems items )
{
   items.parent = &this
   items.cur = 0
   return items
}
*/
method uint gtitem.eof( fordata tfd )
{
   return !tfd.icur
}

method uint gtitem.next( fordata tfd )
{
   if !tfd.icur : return 0

   tfd.icur = tfd.icur->treeitem.next   
   return tfd.icur->treeitem.data()
}

method uint gtitem.first( fordata tfd )
{
   tfd.icur = this.gettreeitem().child
   return tfd.icur->treeitem.data()
}

method gtitem.delnames
{
   str name
   
   foreach child, this : child.delnames()   
   .getfullname( name )   
   .maingt->gt.names.del( name )
}

method gtitem.setnames( str name )
{
//   .getfullname( name )
   .maingt->gt.names[ name ] = &this.gettreeitem()   
   foreach child, this
   { 
      str stemp 
      ( stemp = name ).appendch( $gt_CHDIV ) += child.name
      child.setnames( stemp )
   }
}

method uint gtitem.move( gtitem target, uint flag )
{
   uint ret
   str  name

   .delnames()   
   ret = this.gettreeitem().move( ?( &target < 2, this.parent().gettreeitem(), 
                                  target.gettreeitem()), flag )
   
   .setnames( .getfullname( name ) )   
   return ret
}

method uint gtitem.move( gtitem after )
{
   uint flag
   
   if !&after : flag = $TREE_FIRST
   elif &after == 1 : flag = $TREE_LAST
   else : flag = $TREE_AFTER
   return this.move( after, flag )
}

//-----------------------------------------------------------------
