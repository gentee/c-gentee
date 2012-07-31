/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: tree2 18.10.06 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
* Summary: Working with 'tree2s'
*
******************************************************************************/

type tree2item //< index = tree2item >
{
   uint  node    // 1 если группа
   uint  parent  // указатель на хозяина
   uint  child   // Указатель на первого "ребенка"
   uint  next    // указатель на следующего "ребенка"
}
// После этой структуры идут данные

type tree2items < index = tree2item > 
{        
   uint   parent
   uint   cur
}

type tree2 < index = uint > 
{
//   tree2item  root         // Корневой элемент
   uint      rooti     // Корневой элемент
   uint      count     // Количество записей
   uint      itype     // Тип элементов
   uint      isize     // Размер элементов
}

//-----------------------------------------------------------------

method uint tree2item.isleaf
{
   return !this.node
}

method uint tree2item.isnode
{
   return this.node
}

method uint tree2item.isroot
{
   return !this.parent
}

operator uint *( tree2item tree2i )
{
   uint result
   uint child = tree2i.child
   
   while child
   {
      result++
      child = child->tree2item.next
   }
   return result
}

method tree2item tree2item.parent
{
   return this.parent->tree2item
}

method tree2item tree2item.child
{
   return this.child->tree2item
}

method uint tree2item.data
{
   return &this + sizeof( tree2item )
}

method tree2item tree2item.getroot
{
   uint result = &this
   
   while result->tree2item.parent
   {
      result = result->tree2item.parent
   }
   
   return result->tree2item
}

method tree2item tree2item.getnext
{
   return this.next->tree2item
}

method tree2item tree2item.getprev
{
   uint  parent = this.parent
   
   if !parent : return 0->tree2item
   
   uint  result = parent->tree2item.child
   
   if result == &this : return 0->tree2item
   
   while result
   {
      if result->tree2item.next == &this : return result->tree2item

      result = result->tree2item.next
   }
   return 0->tree2item
}

method tree2item tree2item.lastchild
{
   uint  result = this.child
   
   while result
   {
      if !result->tree2item.next : break

      result = result->tree2item.next
   }
   
   return result->tree2item
}

method uint tree2item.changenode( tree2item tree2i )
{
   if !this.parent || !tree2i.node || 
       &this.getroot() != &tree2i.getroot() : return 0

   uint  curnext = this.next
   uint  curprev 
   curprev as this.getprev()
   
   if &curprev
   {
      curprev.next = curnext
   }
   else
   {
      this.parent->tree2item.child = curnext
   }
   
   this.next = tree2i.child
   tree2i.child = &this
   this.parent = &tree2i
   
   return 1
}

//-----------------------------------------------------------------

operator uint *( tree2 itree2 )
{
   return itree2.count
}

// Метод для разрешения указания подтипа при описании переменной
method tree2.oftype( uint itype )
{
   if this.rooti 
   {
      if type_hasdel( this.itype )
      {
         type_delete( this.rooti + sizeof( tree2item ), this.itype )
      }      
      free( this.rooti )
   }
   this.itype = itype
   this.isize = sizeof( tree2item ) + sizeof( itype )

   this.rooti = alloc( this.isize )
   mzero( this.rooti, sizeof( tree2item ))
   this.rooti->tree2item.node = 1
   type_init( this.rooti + sizeof( tree2item ), this.itype )
}

method tree2item tree2.root
{
   return this.rooti->tree2item
}

method tree2 tree2.init
{
   this.oftype( uint )
   return this   
}

method tree2item tree2.leaf( tree2item parent, tree2item after )
{
   uint tree2i
   uint item
   uint owner

//   owner = ?( &parent, &parent, &this.rooti )
   owner = ?( &parent, &parent, this.rooti )
   owner as tree2item
   
   if !owner.node : return 0->tree2item

   tree2i = alloc( this.isize )
   tree2i as tree2item
   tree2i.parent = &owner
   tree2i.child = 0
   tree2i.node = 0
   tree2i.next = 0 //owner.child
   tree2i as uint
   if !owner.child : owner.child = tree2i
   else
   {
      uint  next = owner.child
      
      while next != &after && next->tree2item.next 
      {
         next = next->tree2item.next
      }
      tree2i->tree2item.next = next->tree2item.next      
      next->tree2item.next = tree2i
   }
   
   item = tree2i + sizeof( tree2item )
   type_init( item, this.itype )
   this.count++
   
   return tree2i->tree2item
}

method tree2item tree2.leaf( tree2item parent )
{
   return this.leaf( parent, 0->tree2item ) 
}

method tree2item tree2.node( tree2item parent, tree2item after )
{
   uint result

   result as this.leaf( parent, after )      
   result.node = 1
   
   return result
}

method tree2item tree2.node( tree2item parent )
{
   return this.node( parent, 0->tree2item )      
}

method tree2.del( tree2item item, uint funcdel )
{
   // Удаляем всех детей
   while item.child : this.del( item.child->tree2item, funcdel )

   if funcdel : funcdel->func( item )
   
   if item.parent
   {
      uint prev
      
      prev as item.getprev()
      
      if &prev : prev.next = item.next
      else : item.parent->tree2item.child = item.next
      this.count--
   }     
    
   // Удаляем объект   
   if type_hasdel( this.itype )
   {
      type_delete( &item + sizeof( tree2item ), this.itype )
   }      
   free( &item )
}

method tree2.del( tree2item item )
{
   this.del( item, 0 )
}

method tree2.delete
{
   this.del( this.rooti->tree2item )   
}

method tree2 tree2.clear
{
   uint ti
   
   ti as this.rooti->tree2item
   // Удаляем всех детей
   while ti.child : this.del( ti.child->tree2item )
   return this
}

//-----------------------------------------------------------------

method uint tree2item.move( tree2item after )
{
   uint  parent
   uint  curnext = this.next
   uint  curprev 

   if !this.parent || ( &after > 1 &&
         this.parent != after.parent ) : return 0

   parent as this.parent()
   curprev as this.getprev()
   
   if curprev : curprev.next = curnext
   else : parent.child = curnext
   if !&after 
   {
      this.next = parent.child
      parent.child = &this
      return 1
   } 
   elif &after == 1 
   {
      this.next = 0
      curprev as parent.lastchild()
      if curprev : curprev.next = &this
      else : parent.child = &this
   }
   else
   {
      this.next = after.next
      after.next = &this
   }
   return 1
}

//-----------------------------------------------------------------

method  tree2items  tree2item.items( tree2items items )
{
   items.parent = &this
   items.cur = 0
   return items
}

method uint tree2items.eof
{
   return !this.cur
}

method uint tree2items.next
{
   if !this.cur : return 0

   this.cur = this.cur->tree2item.next   
   return this.cur
}

method uint tree2items.first
{
   this.cur = this.parent->tree2item.child
   return this.cur
}

