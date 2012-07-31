/******************************************************************************
*
* Copyright (C) 2004-2007, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: vis.treeviewitem 25.09.07 0.0.A.
*
* Author: Alexander Krivonogov ( gentee )
*
******************************************************************************/

extern
{
property TVItem TVItem.Parent
property TVItem TVItem.Next
property TVItem TVItem.Prev
property TVItem TVItem.LastChild

method uint TVItem.eof( fordata tfd )
method uint TVItem.next( fordata tfd )
method uint TVItem.first( fordata tfd )

method TVSelection.Remove( TVItem item )
method uint TVSelection.Find( TVItem item )
method TVItem TVSelection.index( uint idx )
method TVSelection.iWinUpdate( uint selected )
operator uint *( TVSelection obj )
}


method TVItem.iItemUpdate( uint mask )
{
   TVITEM item
   uint   state
   item.mask = mask
   item.hItem = .param->treedata.handle      
    
   
   if .getuint( "bold" ) : state |= $TVIS_BOLD
  
   item.iImage = -1
   item.iSelectedImage = -1
   if .param->treedata.treeview && .param->treedata.treeview->vTreeView.ptrImageList
   {  
      uint tname
      ustr imgname   
      tname as .get( "image" )
      if &tname
      {
         imgname.fromutf8( tname )
         item.iImage = .param->treedata.treeview->vTreeView.ptrImageList->ImageList.GetImageIdx( .param->treedata.treeview->vTreeView.iNumIml, imgname, uint( .get( "disabled", "" ) ) )         
      }
      tname as .get( "selectedimage" )
      if &tname
      {
         imgname.fromutf8( tname )
         item.iSelectedImage = .param->treedata.treeview->vTreeView.ptrImageList->ImageList.GetImageIdx( .param->treedata.treeview->vTreeView.iNumIml, imgname,  uint( .get( "disabled", "" ) ) )
      }         
   }
   if item.iImage != -1 && item.iSelectedImage = -1
   {
      item.iSelectedImage = item.iImage
   }
   
   /*if .param->treedata.inselections {
   state |= $TVIS_SELECTED // $TVIS_DROPHILITED //| $TVIS_CUT
   }*/
   item.state = state //| $TVIS_EXPANDPARTIAL 
   item.stateMask = $TVIS_BOLD///*| $TVIS_DROPHILITED*/ | $TVIS_SELECTED //*/| $TVIS_DROPHILITED// | $TVIS_SELECTED | $TVIS_CUT//| $TVIS_EXPANDEDONCE /*| $TVIS_BOLD |/ $TVIS_SELECTED //|$TVIS_DROPHILITED//| $TVIS_CUT | $TVIS_EXPANDPARTIAL*/7
   
   //.Label      
   item.pszText = .Label->locustr.Text( .param->treedata.treeview->vTreeView ).ptr()
    
   .param->treedata.treeview->vTreeView.WinMsg( $TVM_SETITEMW, 0, &item )
   if mask & $TVIF_STATE
   {    
    //state |= $TVIS_EXPANDEDONCE    
      .param->treedata.treeview->vTreeView.WinMsg( $TVM_EXPAND, ?( .getuint( "expanded" ), $TVE_EXPAND, $TVE_COLLAPSE ), .param->treedata.handle )
   }            
}

method TVItem.iItemInsert( TVItem child )
{   
   TVINSERTSTRUCT ti
   uint thisdata as .param->treedata
   
   uint sorttype = .getuint( "sorttype" )
   if sorttype & $TVSORT_SORT
   {
      ti.hInsertAfter = $TVI_SORT          
   }
   else
   {
      uint prev as child.Prev
      ti.hInsertAfter = ?( &prev, prev.param->treedata.handle, $TVI_FIRST )
      //ti.hInsertAfter = ?( &after, ?( &after==0xFFFFFFFF, $TVI_LAST, after.param->treedata.handle ), $TVI_FIRST )
   }
   ti.hParent = thisdata.handle
   ti.item.mask = $TVIF_PARAM | $TVIF_TEXT
   ti.item.lParam = &child
   ti.item.pszText = child.Label->locustr.Text( .param->treedata.treeview->vTreeView ).ptr()
   child.param->treedata.handle = thisdata.treeview->vTreeView.WinMsg( $TVM_INSERTITEMW, 0, &ti )      
//   child.iItemUpdate( $TVIF_STATE | $TVIF_TEXT | $TVIF_SELECTEDIMAGE | $TVIF_IMAGE)   
}


property gtitem TVItem.Children
{
   return .findrel( "/children" )   
}

method TVItem.iWinClear( uint flgdelitem )
{ 
   if .param
   {       
      uint children as .Children
      if &children
      {
         uint prev as children.lastchild()->TVItem
         while &prev
         {       
            prev.iWinClear( flgdelitem )
            //uint pdel as prev
            prev as prev.Prev
            //if flgdelitem: pdel.del()
         }
         if flgdelitem: children.del()
      }
      destroy( .param )      
      .param = 0      
   }
}


method TVItem.Release()
{
   /*if this.InSelections
   {
      this.InSelections = 0
   }*/
   if .param
   {     
      uint children as .Children
      if &children
      {
         uint prev as children.lastchild()->TVItem
         while &prev
         {       
            prev.Release()
            prev as prev.Prev
         }
         //fornum i = 0, children
         /*foreach child, children
         {
            child->TVItem.Release()
         }*/
      }
      if &this && .param->treedata.treeview
      {
         .param->treedata.treeview->vTreeView.fReleasing = 1
         uint inselections 
         uint selection as .param->treedata.treeview->vTreeView.Selection
         if selection.StartShift == &this
         {
            selection.StartShift = 0
         }
         if selection.Find( this ) != -1
         {  
            selection.Remove( this )
            if *selection
            {
               inselections = 1       
            }
         }         
         if &this == .param->treedata.treeview->vTreeView.pSelected
         {  
            uint next       
            if inselections            
            {
               next = &selection[0]
            }
            else 
            {                        
               if ( (next = &this.Next) && next->TVItem.param ) || 
                  ( (next = &this.Prev) && next->TVItem.param ) || 
                  ( next = &this.Parent ) 
               {
               }
            }            
            .param->treedata.treeview->vTreeView.Selected = next->TVItem
         }         
         .param->treedata.treeview->vTreeView.WinMsg( $TVM_DELETEITEM, 0, .param->treedata.handle )
         .param->treedata.treeview->vTreeView.fReleasing = 0         
      }      
      //if &this != &.param->treedata.treeview->vTreeView.gttree.root()
      {
         destroy( .param )      
         .param = 0   
      }      
   }
}

method TVItem.Del()
{
   this.Release()   
   this.del()
   /*if this.InSelections
   {
      this.InSelections = 0
   }*/
/*   if .param
   {
      if &this == .param->treedata.treeview->vTreeView.pSelected 
      {
         .param->treedata.treeview->vTreeView.pSelected = 0
      }   
      uint children as .Children
      if &children
      {
         foreach child, children
         {
            child->TVItem.Del()
         }
      }
      if &this && .param->treedata.treeview
      {   
         .param->treedata.treeview->vTreeView.WinMsg( $TVM_DELETEITEM, 0, .param->treedata.handle )
      }  
      
      if &this != &.param->treedata.treeview->vTreeView.gttree.root()
      {
         destroy( .param )
         this.del()
      }
   }*/   
}

/* Свойство ustr Label - Get Set
Устанавливает или определяет заголовок элемента дерева
*/
property ustr TVItem.Label <result>
{ 
   uint name as .get( "label" )
//!   result.clear()   
   if &name
   {
      result.fromutf8( name ).ptr()
   }        
}

property TVItem.Label( ustr val )
{
   .set( "label", val.toutf8( "" ) )
   .iItemUpdate( $TVIF_TEXT )
}

/* Свойство ustr vToolBarItem.ImageId - Get Set
Устанавливает или получает картинку
*/
property ustr TVItem.ImageId <result>
{
   result.fromutf8( .get( "image" ) ).ptr()
}

property TVItem.ImageId( ustr val )
{
   //if val != "".ustr().fromutf8( .get( "image" ) )
   { 
      .set( "image", val.toutf8( "" ) )
      .iItemUpdate( $TVIF_IMAGE | $TVIF_SELECTEDIMAGE )     
   }   
}



method TVItem TVItem.InsertChild( ustr name, uint tag, ustr image, TVItem after )
{   
   
   if &this && .param->treedata.treeview
   {         
      //uint children as .findrel( "\children" )
      
      uint children as .Children
      if !&children : children as .insertchild( "children", 0->gtitem )
      uint thisdata as .param->treedata       
      uint child as children.insertchild( "", after )->TVItem       
      uint childdata as new( treedata )->treedata
      childdata.treeview = thisdata.treeview
      child.param = &childdata
      child.set( "label", name.toutf8( "" ) )
      child.setuint( "tag", tag )
      if &image && *image
      {
         child.set( "image", image.toutf8( "" ) )
      } 
      //TVINSERTSTRUCT ti
      //ti.item.pszText = name.ptr()
      uint sorttype = .getuint( "sorttype" )       
      if sorttype & $TVSORT_SORT
      {         
         //ti.hInsertAfter = $TVI_SORT
         if sorttype == $TVSORT_SORTRECURSE 
         {
            child.setuint( "sorttype", sorttype )
         }         
      }
      .iItemInsert( child )
      child.iItemUpdate( $TVIF_STATE | $TVIF_TEXT | $TVIF_SELECTEDIMAGE | $TVIF_IMAGE)
      if !&.param->treedata.treeview->vTreeView.Selected 
      {
         .param->treedata.treeview->vTreeView.Selected = child
      }
      /*else
      {
         ti.hInsertAfter = ?( &after, ?( &after==0xFFFFFFFF, $TVI_LAST, after.param->treedata.handle ), $TVI_FIRST )
      }
      ti.hParent = thisdata.handle
      ti.item.mask = $TVIF_TEXT | $TVIF_PARAM// | $TVIF_SELECTEDIMAGE | $TVIF_IMAGE
      //ti.item.stateMask = $TVIS_STATEIMAGEMASK
      //ti.item.state = 0x2000
      ti.item.lParam = &child
      ti.item.iImage = -1
      ti.item.iSelectedImage = -1 
      childdata.handle = thisdata.treeview->vTreeView.WinMsg( $TVM_INSERTITEMW, 0, &ti )*/
      return child->TVItem
   }
   return 0->TVItem
}
 
method TVItem TVItem.InsertFirstChild( ustr name, uint tag, ustr image )
{   
   return this.InsertChild( name, tag, image, 0->TVItem ) 
}

method TVItem TVItem.AppendChild( ustr name, uint tag, ustr image )
{
   return this.InsertChild( name, tag, image, 0xFFFFFFFF->TVItem )
}

method TVItem TVItem.InsertFirstChild( ustr name, uint tag )
{   
   return this.InsertChild( name, tag, 0->ustr, 0->TVItem ) 
}

method TVItem TVItem.AppendChild( ustr name, uint tag )
{
   return this.InsertChild( name, tag, 0->ustr, 0xFFFFFFFF->TVItem )
}

/*operator uint *( TVItem item )
{
   uint count
   if &item && item.TreeView
   {      
      uint tv as item.TreeView->vTreeView
      uint cur = tv.WinMsg( $TVM_GETNEXTITEM, $TVGN_CHILD, item.handle )      
      while cur
      {  
         count++
         tv.WinMsg( $TVM_GETNEXTITEM, $TVGN_NEXT, cur )
      } 
   }
   return count
   return *item->gtitem
}*/

method TVItem TVItem.index( uint idx )
{   
   if &this
   { 
      uint child as .Child
      uint i
      while &child
      {     
         if i++ == idx : return child
         child as child.Next
      } 
   }
   return 0->TVItem   
}

property uint TVItem.IndexInList()
{
   uint num
   
   if &this
   {
      uint parent as this.Parent
      if &parent
      {
         uint child as parent.Child         
         while &child
         {     
            if &child == &this : return num 
            num++
            child as child.Next
         } 
      }
   }
   return 0
}

operator uint *( TVItem item )
{
   uint count
   if &item
   {
      uint child as item.Child
      while &child
      {
         count++
         child as child.Next  
      }
   }
   return count 
}



/* Свойство uint Expand - Get Set
Устанавливает или определяет открытие ветки
0 - ветка закрыта
1 - ветка открыта
*/
property uint TVItem.Expanded
{ 
   return .getuint( "expanded" )  
}

property TVItem.Expanded( uint val )
{
   if .getuint( "expanded" ) != val
   {
      //.param->treedata.treeview->vTreeView.WinMsg( $TVM_EXPAND, ?( val, $TVE_EXPAND, $TVE_COLLAPSE ), .param->treedata.handle ) 
      .setuint( "expanded", val )
      .iItemUpdate( $TVIF_STATE )
   }
   //.iItemUpdate( $TVIF_STATE )
}

method TVItem.ExpandRecurse( uint val )
{
   .Expanded = val   
   foreach item, this
   {   
      item.ExpandRecurse( val )
   }
      
}

/* Свойство uint Tag - Get Set
Устанавливает или определяет пользовательский параметр элемента дерева
*/
property uint TVItem.Tag
{ 
   return .getuint( "tag" )  
}

property TVItem.Tag( uint val )
{
   .setuint( "tag", val )
}

/* Свойство uint Bold - Get Set
Устанавливает или определяет пользовательский параметр элемента дерева
*/
property uint TVItem.Bold
{ 
   return .getuint( "bold" )  
}

property TVItem.Bold( uint val )
{
   .setuint( "bold", val )
   .iItemUpdate( $TVIF_STATE )
}

/* Свойство uint Checked - Get Set
Устанавливает или определяет пользовательский параметр элемента дерева
*/
property uint TVItem.Checked
{ 
   return .getuint( "checked" )  
}

property TVItem.Checked( uint val )
{
   .setuint( "checked", val )
   //.iItemUpdate( $TVIF_STATE )
}

/* Свойство uint SortTYpe - Get Set
Устанавливает или определяет пользовательский параметр элемента дерева
*/
property uint TVItem.SortType
{ 
   return .getuint( "sorttype" )  
}

property TVItem.SortType( uint val )
{  
   .setuint( "sorttype", ?( val & $TVSORT_SORT, val, $TVSORT_NONE ))
   if val & $TVSORT_SORT
   {   
      .param->treedata.treeview->vTreeView.WinMsg( $TVM_SORTCHILDREN, 0, .param->treedata.handle )
   }   
   if val & $TVSORT_RECURSE 
   {         
      uint children as .Children
      if &children
      {     
         foreach child, children
         {       
            child->TVItem.SortType = val
         }
      }
   }
   
   //.iItemUpdate( $TVIF_STATE )
}

/* Свойство uint Parent - Get
Определяет хозяина данной ветки, если ветка в корне то корень, если корень то 0
*/
property TVItem TVItem.Parent
{    
   return this->gtitem.parent().parent()->TVItem

//   return this->gtitem.parent()->TVItem 
}

/* Свойство uint Prev - Get
Определяет предыдущий элемент, если он есть, иначе 0
*/
property TVItem TVItem.Prev
{    
   uint x = &(this->gtitem.getprev())
   return x->TVItem
   //return this->gtitem.getprev()->TVItem
}

/* Свойство uint Next - Get
Определяет следующий элемент, если он есть, иначе 0
*/
property TVItem TVItem.Next
{    
   return this->gtitem.getnext()->TVItem
}

/* Свойство uint NextInList - Get
Определяет следующий элемент в глобальном списке или 0 если больше нет
*/
property TVItem TVItem.NextInList
{    
   uint item
   uint parent  
      
   item as this.Child 
   if &item : return item
   parent as this  
   do 
   {       
      item as parent.Next      
      if &parent == &(.param->treedata.treeview->vTreeView.Root())
      {
         return 0->TVItem
      }
      if &item : return item
      parent as parent.Parent
   } while &parent
   return 0->TVItem
}

/* Свойство uint LastChild - Get
Определяет последний дочерний элемент, если он есть, иначе 0
*/
property TVItem TVItem.LastChild
{    
   uint children as .Children
   if &children : return children.lastchild()->TVItem 
   return 0->TVItem
   //return this->gtitem.lastchild()->TVItem
}

/* Свойство uint Child - Get
Определяет первый дочерний элемент данной ветки, если ветка не имеет дочерних элементов, то 0
*/
property TVItem TVItem.Child
{
   uint children as .Children
   if &children : return children.child()->TVItem 
   return 0->TVItem
/*        
   uint res as this.child()    
   return res->TVItem*/ 
}



method TVItem.Reinsert()
{      
   uint owner as this.Parent()   
   
   owner.iItemInsert( this )
   uint children as .Children
   if &children
   {
      foreach child, children
      {
         child->TVItem.Reinsert()
      }
   }
   this.iItemUpdate( $TVIF_STATE | $TVIF_TEXT | $TVIF_SELECTEDIMAGE | $TVIF_IMAGE)     
}

method TVItem.Update()
{    
   this.iItemUpdate( $TVIF_IMAGE | $TVIF_SELECTEDIMAGE | $TVIF_TEXT | $TVIF_STATE )   
   uint children as .Children
   if &children
   {
      foreach child, children
      {  
         child->TVItem.Update()
      }
   }   
   if .getuint( "sorttype" ) & $TVSORT_SORT
   {
      .param->treedata.treeview->vTreeView.WinMsg( $TVM_SORTCHILDREN, 0, .param->treedata.handle )
   }  
}

method TVItem.MoveTo( TVItem dest, uint flag )
{
   uint tv as .param->treedata.treeview->vTreeView
   uint root as tv.Root
   //if flag != $TREE_AFTER || ( &this.Next() != &dest )
   if &dest 
   {  
      uint oldfmoving = tv.fMoving
      //uint selected as TVItem
      tv.fMoving = 1
      //uint tv as .param->treedata.treeview->vTreeView
      evparBeforeMove evpB
      evpB.CurItem = &this
      evpB.DestItem = &dest      
      evpB.Flag     = flag
      //if tv.fMoving: 
      tv.OnBeforeMove.run( evpB )
      if !evpB.flgCancel
      {
         this.move( ?( flag == $TREE_LAST || flag == $TREE_FIRST , dest.Children, dest ), flag )
         tv.WinMsg( $TVM_DELETEITEM, 0, .param->treedata.handle )
         this.Reinsert()
         evparAfterMove evpA
         evpA.CurItem = &this
         evpA.DestItem = &dest
         evpA.Flag     = flag
         //if tv.fMoving : 
         tv.OnAfterMove.run( evpA )
      }
      tv.fMoving = oldfmoving
      if !oldfmoving
      {
         //tv.Selected = 0->TVItem  
         //tv.Selected = selected
         tv.Selection.iWinUpdate( 1 )
         tv.WinMsg( $TVM_SELECTITEM, $TVGN_CARET, tv.pSelected->TVItem.param->treedata.handle )
      }
   }
}

/* Свойство uint Selected - Get Set
Устанавливает или определяет пользовательский параметр элемента дерева
*/
/*property uint TVItem.Selected
{ 
   return .getuint( "Selected" )  
}

property TVItem.Selected( uint val )
{  
   .setuint( "Selected", ?( val & $TVSORT_SORT, val, $TVSORT_NONE ))
   if val & $TVSORT_SORT
   {   
      .param->treedata.treeview->vTreeView.WinMsg( $TVM_SORTCHILDREN, 0, .param->treedata.handle )
   }   
   if val & $TVSORT_RECURSE 
   {              
      foreach child, this
      {       
         child.Selected = val
      }
   }
   
   //.iItemUpdate( $TVIF_STATE )
}*/
method TVSelection.iSelect( TVItem item, uint selected )
{
   TVITEM tvi   
   tvi.mask = $TVIF_STATE     
   tvi.hItem = item.param->treedata.handle         
   if selected : tvi.state |= $TVIS_SELECTED
   tvi.stateMask = $TVIS_SELECTED
    
   .pTreeView->vTreeView.WinMsg( $TVM_SETITEMW, 0, &tvi )
}


method TVSelection.iWinUpdate( uint selected )
{
   uint i
   uint treeview as .pTreeView->vTreeView 
   fornum i = 0, *.Items
   {
      .iSelect( .Items[i]->TVItem, selected ) 
   }  
}

method TVItem TVSelection.index( uint idx )
{
   if idx < *.Items : return .Items[idx]->TVItem
   return 0->TVItem
} 

operator uint *( TVSelection obj )
{
   return *(obj.Items)
}


method uint TVSelection.eof( fordata tfd )
{
   return tfd.icur >= *.Items
}


method uint TVSelection.next( fordata tfd )
{
   if ++tfd.icur >= *.Items : return 0   
   return .Items[tfd.icur] 
}


method uint TVSelection.first( fordata tfd )
{
   tfd.icur = 0
   if tfd.icur >= *.Items : return 0   
   return .Items[tfd.icur] 
}


method uint TVItem.eof( fordata tfd )
{
   return !tfd.icur
}


method uint TVItem.next( fordata tfd )
{
   return tfd.icur = &tfd.icur->TVItem.Next()
}


method uint TVItem.first( fordata tfd )
{   
   return tfd.icur = &.Child()     
}

//method uint TVItem.Find( ustr
/*method TVSelection.oftype()
{

}*/

method uint TVSelection.Find( TVItem item )
{
   uint i   
   fornum i = 0, *.Items
   {
      if .Items[i] == &item : return i
   }  
   return -1
}

method TVSelection.Append( TVItem item  )
{
   if .Find( item ) == -1
   {
      uint idx = .Items.expand( 1 )
      .Items[idx] = &item      
      .iSelect( item, 1 )
   }
}

method TVSelection.Remove( TVItem item )
{
   uint idx = .Find( item )
   if idx != -1
   {
      .Items.del( idx )      
      .iSelect( item, 0 )
   }
}

method TVSelection.Clear()
{
   .iWinUpdate( 0 )
   .Items.clear()
}

method TVSelection.SelectAll()
{
   .Items.clear()   
   uint curitem as .pTreeView->vTreeView.Root
   while ( curitem as curitem.NextInList )
   {
      .Items[.Items.expand( 1 )] = &curitem
   }   
   .iWinUpdate( 1 )   
}

method TVSelection.RemoveChildren()
{
   int i
   //foreach item, .tvProject.Selections
   uint parent, curitem
   uint root = &.pTreeView->vTreeView.Root
   for i = *.Items - 1, i >= 0, i--
   {
      curitem as .Items[i]->TVItem
      parent as curitem.Parent            
      while &parent != root
      {      
         if .Find( parent ) != -1
         {         
            .Remove( curitem )
            break            
         }
         parent as parent.Parent
      }      
   }  
   curitem as root->TVItem
   uint index = 0
   uint curindex
   while ( curitem as curitem.NextInList )
   {
      if ( curindex = .Find( curitem )) != -1
      {  
         .Items.move( curindex, index++ ) 
      }
   }          
}

method TVSelection.MoveTo( TVItem dest, uint flag )
{ 
   if &dest
   {       
      uint tv as .pTreeView->vTreeView         
      tv.fMoving = 1                      
      .RemoveChildren()                      
      foreach item, this
      {     
         item.MoveTo( dest, flag )
      }
      tv.fMoving = 0        
      .iWinUpdate( 1 )
      tv.WinMsg( $TVM_SELECTITEM, $TVGN_CARET, tv.pSelected->TVItem.param->treedata.handle )
   }
}