/******************************************************************************
*
* Copyright (C) 2006-2008, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* Author: Alexey Krivonogov ( gentee )
*
******************************************************************************/
/*-----------------------------------------------------------------------------
* Id: tree L "Tree"
* 
* Summary: Tree object. The each node of tree object can have a lot of childs.
           It is required to include tree.g.#srcg[
|include : $"...\gentee\lib\tree\tree.g"]   
*
* List: *#lng/opers#,tree_opof,tree_oplen,treeitem_oplen,treeitem_opfor,
        *#lng/methods#,tree_clear,tree_del,tree_leaf,tree_node,tree_root,
        *Treeitem methods,treeitem_changenode,treeitem_child,treeitem_data,
        treeitem_getnext,treeitem_getprev,treeitem_isleaf,treeitem_isnode,
        treeitem_isroot,treeitem_lastchild,treeitem_move,treeitem_parent
* 
-----------------------------------------------------------------------------*/

type treeitem //< index = treeitem >
{
   uint  node    // 1 if a group
   uint  parent  // The pointer to the owner
   uint  child   // The pointer to the first child
   uint  next    // The pointer to the next item
}
// После этой структуры идут данные

type tree 
{
   uint      rooti     // The root item
   uint      count     // The count of items
   uint      itype     // The type of items
   uint      isize     // The size of item
}

define 
{
/*-----------------------------------------------------------------------------
* Id: treeflags D
* 
* Summary: Flags for tree.move.
*
-----------------------------------------------------------------------------*/
   TREE_FIRST  = 0x0001   // The first child item of the same parent.
   TREE_LAST   = 0x0002   // The last child item of the same parent.
   TREE_AFTER  = 0x0004   // After this item.
   TREE_BEFORE = 0x0008   // Before this item.
//-----------------------------------------------------------------
}

/*-----------------------------------------------------------------------------
* Id: treeitem_isleaf F3
*
* Summary: Check if it is a leaf. The method checks if an item is a "leaf" 
           (if it cannot have child items).  
*  
* Return: Returns 1 if this item is a tree "leaf" and 0 otherwise.
*
-----------------------------------------------------------------------------*/

method uint treeitem.isleaf
{
   return !this.node
}

/*-----------------------------------------------------------------------------
* Id: treeitem_isnode F3
*
* Summary: Check if it is a node. The method checks is an item can have 
           child items.  
*  
* Return: Returns 1 if this item is a tree "node" and 0 otherwise.
*
-----------------------------------------------------------------------------*/

method uint treeitem.isnode
{
   return this.node
}

/*-----------------------------------------------------------------------------
* Id: treeitem_isroot F3
*
* Summary: Check if it is a root item. The method checks if an item is a 
           root one.
*  
* Return: Returns 1 if this item is a root one and 0 otherwise. 
*
-----------------------------------------------------------------------------*/

method uint treeitem.isroot
{
   return !this.parent
}

/*-----------------------------------------------------------------------------
* Id: treeitem_oplen F4
* 
* Summary: Get the count of childs in the tree item.
*  
* Return: The count of childs in the tree item.
*
-----------------------------------------------------------------------------*/

operator uint *( treeitem treei )
{
   uint result
   uint child = treei.child
   
   while child
   {
      result++
      child = child->treeitem.next
   }
   return result
}

/*-----------------------------------------------------------------------------
* Id: treeitem_parent F3
*
* Summary: Get the parent of an item.
*  
* Return: Returns the parent of this item. 
*
-----------------------------------------------------------------------------*/

method treeitem treeitem.parent()
{
   return this.parent->treeitem
}

/*-----------------------------------------------------------------------------
* Id: treeitem_child F3
*
* Summary: Get the first child of an item.
*  
* Return: Returns the first child item or 0 if there is none. 
*
-----------------------------------------------------------------------------*/

method treeitem treeitem.child()
{
   return this.child->treeitem
}

/*-----------------------------------------------------------------------------
* Id: treeitem_data F3
*
* Summary: Get the pointer to the data stored in an object.
*  
* Return: Returns the pointer to the data. 
*
-----------------------------------------------------------------------------*/

method uint treeitem.data()
{
   if !&this : return 0
   return &this + sizeof( treeitem )
}

/*-----------------------------------------------------------------------------
* Id: tree_root_1 FB
*
* Summary: Get the root item of a tree.
*  
* Return: Returns the root item of the tree. 
*
-----------------------------------------------------------------------------*/

method treeitem treeitem.getroot()
{
   uint result = &this
   
   while result->treeitem.parent
   {
      result = result->treeitem.parent
   }
   
   return result->treeitem
}

/*-----------------------------------------------------------------------------
* Id: treeitem_getnext F3
*
* Summary: Getting the next item to the current tree item.
*  
* Return: Returns the next item.  
*
-----------------------------------------------------------------------------*/

method treeitem treeitem.getnext()
{
   return this.next->treeitem
}

/*-----------------------------------------------------------------------------
* Id: treeitem_getprev F3
*
* Summary: Getting the previous item to the current tree item.
*  
* Return: Returns the previous item.  
*
-----------------------------------------------------------------------------*/

method treeitem treeitem.getprev()
{
   uint  parent = this.parent
   
   if !parent : return 0->treeitem
   
   uint  result = parent->treeitem.child
   
   if result == &this : return 0->treeitem
   
   while result
   {
      if result->treeitem.next == &this : return result->treeitem

      result = result->treeitem.next
   }
   return 0->treeitem
}

/*-----------------------------------------------------------------------------
* Id: treeitem_lastchild F3
*
* Summary: Get the last child item of the tree item. 
*  
* Return: Returns the last child item or 0 if there is none.  
*
-----------------------------------------------------------------------------*/

method treeitem treeitem.lastchild()
{
   uint  result = this.child
   
   while result
   {
      if !result->treeitem.next : break

      result = result->treeitem.next
   }
   
   return result->treeitem
}

/*-----------------------------------------------------------------------------
* Id: treeitem_changenode F2
*
* Summary: Change the parent node of an item.
*
* Params: treei - New parent node. 
*  
* Return: #lng/retf# 
*
-----------------------------------------------------------------------------*/

method uint treeitem.changenode( treeitem treei )
{
   if !this.parent || !treei.node || 
       &this.getroot() != &treei.getroot() : return 0

   uint  curnext = this.next
   uint  curprev 
   curprev as this.getprev()
   
   if &curprev
   {
      curprev.next = curnext
   }
   else
   {
      this.parent->treeitem.child = curnext
   }
   
   this.next = treei.child
   treei.child = &this
   this.parent = &treei
   
   return 1
}

/*-----------------------------------------------------------------------------
* Id: tree_oplen F4
* 
* Summary: Get the count of items in a tree.
*  
* Return: The count of childs in the tree.
*
-----------------------------------------------------------------------------*/

operator uint *( tree itree )
{
   return itree.count
}

/*-----------------------------------------------------------------------------
* Id: tree_opof F4
* 
* Summary: Specifying the type of items. You can specify #b(of) type when you 
           describe #b(tree) variable. In default, the type of the items 
           is #b(uint).
*  
* Title: tree of type
*
-----------------------------------------------------------------------------*/

method tree.oftype( uint itype )
{
   if this.rooti 
   {
      if type_hasdelete( this.itype )
      {
         type_delete( this.rooti + sizeof( treeitem ), this.itype )
      }      
      mfree( this.rooti )
   }
   this.itype = itype
   this.isize = sizeof( treeitem ) + sizeof( itype )

   this.rooti = malloc( this.isize )
   mzero( this.rooti, sizeof( treeitem ))
   this.rooti->treeitem.node = 1
   type_init( this.rooti + sizeof( treeitem ), this.itype )
}

/*-----------------------------------------------------------------------------
* Id: tree_root F3
*
* Summary: Get the root item of a tree.
*  
* Return: Returns the root item of the tree. 
*
-----------------------------------------------------------------------------*/

method treeitem tree.root
{
   return this.rooti->treeitem
}

method tree tree.init
{
   this.oftype( uint )
   return this   
}

/*-----------------------------------------------------------------------------
* Id: tree_leaf F2
*
* Summary: Adding a "leaf". Add a "leaf" to the specified node. You can not add
           items to a "leaf". 
*
* Params: parent - Parent node. If it is 0-&gt;treeitem then the item will be /
                   added to the root.
          after - Insert an item after this tree item. If it is /
                  0-&gt;treeitem then the item will be the first child. 
*  
* Return: The added item or 0 in case of an error. 
*
-----------------------------------------------------------------------------*/

method treeitem tree.leaf( treeitem parent, treeitem after )
{
   uint treei
   uint item
   uint owner

//   owner = ?( &parent, &parent, &this.rooti )
   owner = ?( &parent, &parent, this.rooti )
   owner as treeitem
   
   if !owner.node : return 0->treeitem

   treei = malloc( this.isize )
   treei as treeitem
   treei.parent = &owner
   treei.child = 0
   treei.node = 0
   treei.next = 0 //owner.child
   treei as uint
   if !owner.child : owner.child = treei
   elif &after
   {
      uint  next = owner.child
      
      while next != &after && next->treeitem.next 
      {
         next = next->treeitem.next
      }
      treei->treeitem.next = next->treeitem.next      
      next->treeitem.next = treei
   }
   else
   {
      treei->treeitem.next = owner.child
      owner.child = treei      
   }
   
   item = treei + sizeof( treeitem )
   type_init( item, this.itype )
   this.count++
   
   return treei->treeitem
}

/*-----------------------------------------------------------------------------
* Id: tree_leaf_1 FA
*
* Summary: Add a "leaf" to the specified node. An item will be the last child
           item.
*
* Params: parent - Parent node. If it is 0-&gt;treeitem then the item will be /
                   added to the root.
*  
* Return: The added item or 0 in case of an error. 
*
-----------------------------------------------------------------------------*/

method treeitem tree.leaf( treeitem parent )
{
//   return this.leaf( parent, 0->treeitem )//0xFFFFFFFF->treeitem ) 
   return this.leaf( parent, 0xFFFFFFFF->treeitem ) 
}

/*-----------------------------------------------------------------------------
* Id: tree_node F2
*
* Summary: Adding a "node". Add a "node" to the specified node. You can add
           items to a "node". 
*
* Params: parent - Parent node. If it is 0-&gt;treeitem then the item will be /
                   added to the root.
          after - Insert an item after this tree item. If it is /
                  0-&gt;treeitem then the item will be the first child. 
*  
* Return: The added item or 0 in case of an error. 
*
-----------------------------------------------------------------------------*/

method treeitem tree.node( treeitem parent, treeitem after )
{
   uint result

   result as this.leaf( parent, after )      
   result.node = 1
   
   return result
}

/*-----------------------------------------------------------------------------
* Id: tree_node_1 FA
*
* Summary: Add a "node" to the specified node. An item will be the last child
           item.
*
* Params: parent - Parent node. If it is 0-&gt;treeitem then the item will be /
                   added to the root.
*  
* Return: The added item or 0 in case of an error. 
*
-----------------------------------------------------------------------------*/

method treeitem tree.node( treeitem parent )
{
//   return this.node( parent, 0->treeitem )//0xFFFFFFFF->treeitem )      
   return this.node( parent, 0xFFFFFFFF->treeitem )      
}

/*-----------------------------------------------------------------------------
* Id: tree_del F2
*
* Summary: Deleting an item. Delete an item together with all its child items.
*
* Params: item - The item being deleted. 
          funcdel - The custom function that will be called before deleting /
                    the each item. It can be 0. 
*  
-----------------------------------------------------------------------------*/

method tree.del( treeitem item, uint funcdel )
{
   // Удаляем всех детей
   while item.child : this.del( item.child->treeitem, funcdel )

   if funcdel : funcdel->func( item )
      
   if item.parent
   {
      uint prev
      
      prev as item.getprev()
      
      if &prev : prev.next = item.next
      else : item.parent->treeitem.child = item.next
      this.count--
   }     
    
   // Удаляем объект   
   if type_hasdelete( this.itype )
   {
      type_delete( &item + sizeof( treeitem ), this.itype )
   }      
   mfree( &item )
}

/*-----------------------------------------------------------------------------
* Id: tree_del_1 FA
*
* Summary: Delete an item together with all its child items.
*
* Params: item - The item being deleted. 
*  
-----------------------------------------------------------------------------*/

method tree.del( treeitem item )
{
   .del( item, 0 )
}

method tree.delete
{
   this.del( this.rooti->treeitem )   
}

/*-----------------------------------------------------------------------------
* Id: tree_clear F2
*
* Summary: Delete all items in the tree. 
*
* Return: #lng/retobj# 
*
-----------------------------------------------------------------------------*/

method tree tree.clear()
{
   uint ti
   
   ti as this.rooti->treeitem
   // Удаляем всех детей
   while ti.child : this.del( ti.child->treeitem )
   return this
}

/*-----------------------------------------------------------------------------
* Id: treeitem_move F2
*
* Summary: Move an item. 
*
* Params: after - The node to insert the item after. Specify 0 if it should /
                  be made the first item.
*  
* Return: #lng/retf# 
*
-----------------------------------------------------------------------------*/

method uint treeitem.move( treeitem after )
{
   uint  parent
   uint  curnext = this.next
   uint  curprev 

   if !this.parent : return 0
   /*|| ( &after > 1 &&
         this.parent != after.parent ) : return 0*/

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
      if &after == &this || after.next == &this : return 1
      this.parent = after.parent
      this.next = after.next
      after.next = &this
   }
   return 1
}

/*-----------------------------------------------------------------------------
* Id: treeitem_move_1 FA
*
* Summary: Move an item. 
*
* Params: target - The node to insert the item after or before depending on /
                   the flag.
          flag - Move flag.$$[treeflags]
*  
* Return: #lng/retf# 
*
-----------------------------------------------------------------------------*/

method uint treeitem.move( treeitem target, uint flag )
{
   switch flag
   {
      case $TREE_FIRST
      {
         this.changenode( target )
         this.move( 0->treeitem )
      }
      case $TREE_LAST
      {
         this.changenode( target )
         this.move( 1->treeitem )
      }
      case $TREE_AFTER
      {
         this.move( target )
      }
      case $TREE_BEFORE
      {
         uint prev 
         prev as target.getprev()
         if !&prev 
         {
            this.changenode( target.parent->treeitem )
            this.move( 0->treeitem )
         }
         else : this.move( prev )
      }
   }
    
   return 1
} 

/*-----------------------------------------------------------------------------
* Id: treeitem_opfor F5
*
* Summary: Foreach operator. You can use #b(foreach) operator to look over all 
           items of the treeitem. #b(Variable) is a pointer to the child tree
           item.
*  
* Title: foreach var,treeitem
*
* Define: foreach variable,treeitem {...}
* 
-----------------------------------------------------------------------------*/
/*
method  treeitems  treeitem.items( treeitems items )
{
   items.parent = &this
   items.cur = 0
   return items
}
*/
method uint treeitem.eof( fordata tfd )
{
   return !tfd.icur
}

method uint treeitem.next( fordata tfd )
{
   if !tfd.icur : return 0

   tfd.icur = tfd.icur->treeitem.next   
   return tfd.icur
}

method uint treeitem.first( fordata tfd )
{
   tfd.icur = this.child
   return tfd.icur
}

