/******************************************************************************
*
* Copyright (C) 2004-2007, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: vis.treeview 25.09.07 0.0.A.
*
* Author: Alexander Krivonogov ( gentee )
*
******************************************************************************/
include {   
 //  "app.g"
   "..\\gt\\gt.g"
}

define <export>{
   TVSORT_NONE          = 0
   TVSORT_SORT          = 1
   TVSORT_RECURSE       = 2   
   TVSORT_NONERECURSE   = $TVSORT_NONE | $TVSORT_RECURSE   
   TVSORT_SORTRECURSE   = $TVSORT_SORT | $TVSORT_RECURSE
}



type TVItem <index=this inherit=gtitem>
{
   
}

type TVSelection <index=TVItem>
{  
   uint pTreeView
   arr  Items of uint
   uint StartShift
}

type treedata
{
   //uint TreeView
   uint treeview //Объект содержащий данный элемент
   uint handle //Идентификатор элемента в окне
   //uint inselection
   
   //uint tag
   //uint gttree   
}

type evparTVEdit <inherit=evparEvent> 
{   
   uint Item
   ustr NewLabel   
   uint flgCancel
}

type evTVEdit <inherit=evEvent> :

method evTVEdit evTVEdit.init
{
   this.eventtypeid = evparTVEdit
   return this
}

/*

type evparItemMoved <inherit=evparEvent>
{
   uint SrcItem
   uint DestItem
   uint Flag
}

type evItemMoved <inherit=evEvent> : 

method evItemMoved evItemMoved.init
{
   this.eventtypeid = evparItemMoved
   return this
}
*/
/* Компонента vTreeView, порождена от vCtrl
События
   onClick - вызывается при нажатии на кнопку
*/
type vTreeView <inherit = vCtrl>
{
//Hidden Fields
   uint    fConnectGt
   /*locustr pCaption     
   uint    pChecked 
   uint    ptreeviewStyle*/
   uint    pShowPlusMinus  //Показывать +/-
   uint    pShowLines      //Показывать линейки дерева
   uint    pShowRootLines  //Показывать корневую линейку
   uint    pShowSelection  //Всегда показывать выделение
   uint    pRowSelect      //Выделение элемента в виде строки
   uint    pLabelEdit      //Возможность редактирования элементов
   uint    pBorder         //Показывать рамку
   uint    pSorted         //Сортировать элементы
   uint    pSelected       //Текущий выбранный элемент
   uint    pMultiSelect    //Выделение нескольких элементов
   uint    pAutoDrag       //Возможность перетаскивать элементы
//   uint    pDragDrop
   uint    fDrag           //Флаг, находимся в режиме drag'n'drop
   uint    fFromMouse
   uint    fMoving
   uint    fReleasing //Находимся в режиме освобождения
   ustr    pImageList
   uint    ptrImageList
   ustr    pStateImageList
   uint    ptrStateImageList
   uint    iNumIml
   uint    iStateNumIml
   //arr items[1] of TVItem
   //arr     pSelections of uint
   TVSelection Selection
   gt      gttree          //Представление в виде gt
   uint    gtroot
//Events   
   //onevent onStartEdit
   evTVEdit   OnAfterEdit
   evTVEdit   OnBeforeEdit
   evQuery    OnBeforeSelect
   evValUint  OnAfterSelect
   //evTVBefore OnBeforeExpand
   //evTVAfter  OnAfterExpand
   //evTVBefore OnBeforeCollapse
   //evTVAfter  OnAfterCollapse
   //evItemMoved OnItemMoved
   evBeforeMove OnBeforeMove
   evAfterMove  OnAfterMove
   evEvent      OnBeginDrag   
}

/*define {
//Стили кнопки treeviewStyle
   bsClassic    = 0 
   bsAsRadiotreeview = 3
   bsAsCheckBox = 4
}*/

extern {
//property uint TVItem.InSelections
//property TVItem.InSelections( uint val )
property TVItem vTreeView.Selected()
property vTreeView.Selected( TVItem item )
property ustr TVItem.Label<result>()
property TVItem TVItem.Child()
property TVItem TVItem.Prev()
//method TVItem.WinSet( uint mask )
property TVItem vTreeView.Root
method TVItem.Del()
method vTreeView.Reload()
}

include {
   "treeviewitem.g"
}

/*Метод vToolBar.iUpdateImageList()
Обновить ImageList
*/
method vTreeView.iUpdateImgList()
{
   .ptrImageList = &.GetImageList( .pImageList, &.iNumIml )
   if .ptrImageList
   {
      .WinMsg( $TVM_SETIMAGELIST, $TVSIL_NORMAL, .ptrImageList->ImageList.arrIml[.iNumIml].hIml )
   }
   else 
   {
      .WinMsg( $TVM_SETIMAGELIST, $TVSIL_NORMAL, 0 )
   }
   .ptrStateImageList = &.GetImageList( .pStateImageList, &.iStateNumIml )
   if .ptrStateImageList
   {
      .WinMsg( $TVM_SETIMAGELIST, $TVSIL_STATE, .ptrStateImageList->ImageList.arrIml[.iNumIml].hIml )
   }
   else 
   {
      .WinMsg( $TVM_SETIMAGELIST, $TVSIL_STATE, 0 )
   }
   .Invalidate()
}
/*------------------------------------------------------------------------------
   Public Methods
*/

method vTreeView.iWinClear( uint flgdelitem )
{
   .Selection.Clear()
   .Selected = 0->TVItem
      
   //.pSelected = 0
   .fReleasing = 1
   .WinMsg( $TVM_DELETEITEM, 0, 0 )
//   .Root.iWinClear( flgdelitem )
   uint children as .Root.Children
   if &children
   {      
      uint prev as children.lastchild()->TVItem      
      while &prev
      {       
         prev.iWinClear( flgdelitem )
         uint cur as prev
         prev as cur.Prev
         if flgdelitem :  cur.del()
      }
   }   
   .fReleasing = 0
}

method vTreeView.Clear()
{   
   .iWinClear( 1 )
/*   .fReleasing = 1
   .WinMsg( $TVM_DELETEITEM, 0, 0 )
   .Root.iWinClear( 1 )
   .fReleasing = 0*/
   /*.Root.Release()
   .gttree.clear()
   .Reload()*/
   //.Root.Del()
   //.WinMsg( $TVM_DELETEITEM, 0, $TVI_ROOT )
   //.gttree.clear()
   /*if *.items > 1
   {
      .items.del( 1, *.items - 2 )
      .WinMsg( $TVM_DELETEITEM, 0, $TVI_ROOT )
      .gti.clear()
   }   */
}

method vTreeView.Edit()
{
   if &(.Selected())
   {
      .SetFocus()      
      .WinMsg( $TVM_EDITLABELW, 0, .Selected().param->treedata.handle )      
   }
}


method vTreeView.ReloadGTItem( TVItem parent, TVItem item )
{
   //if &parent
   {        
   
      uint itemdata as new( treedata )->treedata
      itemdata.treeview = &this
      item.param = &itemdata
      /*child.set( "name", name.toutf8( "" ) )
      child.setuint( "tag", tag )*/      
      //TVINSERTSTRUCT ti
      //ti.item.pszText = name.ptr()
      /*uint sorttype = .getuint( "sorttype" )       
      if sorttype & $TVSORT_SORT
      {         
         //ti.hInsertAfter = $TVI_SORT
         if sorttype == $TVSORT_SORTRECURSE 
         {
            child.setuint( "sorttype", sorttype )
         }         
      }*/
      if &parent :  parent.iItemInsert( item )
   }
   uint children as item.Children
   if &children
   {      
      foreach child, children
      {
         .ReloadGTItem( item, child->TVItem )
      }
   }
   item.iItemUpdate( $TVIF_STATE | $TVIF_TEXT | $TVIF_SELECTEDIMAGE | $TVIF_IMAGE)
}

method vTreeView.Reload()
{   

   uint index
   if !.gtroot 
   {
      .gtroot = &this.gttree.root()
   }
   else
   {
      //this.Root.Release()
      .iWinClear( 0 )
   }

   .pSelected = 0
   uint root as this.Root
   //root.Release()    
   uint children as root.Children   
   if !&children 
   {      
      children as root.insertchild( "children", 0->gtitem )      
      //foreach child, root->gtitem
      uint child as root->gtitem.child()
      while &child       
      {         
         uint next as child.getnext() 
         if &child != &children
         {         
            child.gettreeitem().changenode( children.gettreeitem() )            
            child.move( children, $TREE_LAST )            
         } 
         child as next
      }
      /*.gttree.write( "tmp.gt" )
      .gttree.clear()
      .gttree.read( "tmp.gt" )*/
   }   
   this.ReloadGTItem( 0->TVItem, root )
   uint child as root.Child
   
   //.Selected = 0->TVItem
   if &child
   {   
      .Selected = child
   }     
   
   this.Root().SortType = ?( .pSorted, $TVSORT_SORTRECURSE, $TVSORT_NONE )
}


method vTreeView.ConnectGt( gtitem gtroot )
{
 /*  int i
   for i = *.Rows - 1, i >= 0, i-- 
   {
      .Rows[i].Release()
   }
   */
   
   .iWinClear( 0 )
   //.Root.Release()
   
   if !.fConnectGt
   {
      //.gtroot->gtitem.del()
      .gtroot = 0
   }
   /*else
   {
      
   }*/
   
   /**/   
   if &gtroot 
   {
      .gtroot = &gtroot
      .fConnectGt = 1
   }
   else
   {
      .gtroot = 0
      .fConnectGt = 0  
   }   
   .Reload()  
    
}

method vTreeView.DisconnectGt( )
{
   
   if .fConnectGt : .ConnectGt( 0->gtitem)
   //.gtrows = 0
}

method TVItem vTreeView.HitTest( uint x y uint pflags )
{
   uint item
   
   TVHITTESTINFO tvht             
   tvht.pt.x = x
   tvht.pt.y = y
   
   uint dest = .WinMsg( $TVM_HITTEST, 0, &tvht )
   if pflags : pflags->uint = tvht.flags 
   if dest
   {
      TVITEM tvi
      tvi.mask = $TVIF_PARAM
      tvi.hItem = dest
      .WinMsg( $TVM_GETITEMW, 0, &tvi )
      item = tvi.lParam
   }
   return item->TVItem
}


method vTreeView.DelSelected()
{
   int i
   .Selection.RemoveChildren()
   for i = *.Selection-1, i >= 0, i--
   {
      .Selection[i].Del()
   }
}

method vTreeView.ExpandAll( uint val )
{  
   .Root.ExpandRecurse( val ) 
}
/*------------------------------------------------------------------------------
   Properties
*/
/*Свойство ustr Border - Get Set
Установить, получить наличие рамки у поля ввода
1 - рамка есть
0 - рамки нет
*/
property vTreeView.Border( uint val )
{
   .pBorder = val
   uint style = GetWindowLong( this.hwnd, $GWL_EXSTYLE )
   if val : style |= $WS_EX_CLIENTEDGE
   else : style &= ~$WS_EX_CLIENTEDGE
   SetWindowLong( this.hwnd, $GWL_EXSTYLE, style )      
   SetWindowPos( this.hwnd, 0, 0, 0, 0, 0, $SWP_FRAMECHANGED | 
                  $SWP_NOACTIVATE | $SWP_NOZORDER | $SWP_NOMOVE | $SWP_NOSIZE )
}

property uint vTreeView.Border
{   
   //.pBorder = ?(GetWindowLong( this.hwnd, $GWL_EXSTYLE ) & $WS_EX_CLIENTEDGE,1,0)
   return .pBorder
}

/*Свойство ustr ShowPlusMinus - Get Set
Установить, получить отображение кнопочки с крестиком/минусом отображающим 
открытие ветки
1 - кнопка есть
0 - кнопок нет
*/
property vTreeView.ShowPlusMinus( uint val )
{   
   .pShowPlusMinus = val
   .SetStyle( $TVS_HASBUTTONS, val )
}

property uint vTreeView.ShowPlusMinus
{ 
   return .pShowPlusMinus//.GetStyle( $TVS_HASBUTTONS )
}

/*Свойство ustr ShowLines - Get Set
Установить, получить отображение линеек слева от веток
1 - есть
0 - нет
*/
property vTreeView.ShowLines( uint val )
{   
   .pShowLines = val
   .SetStyle( $TVS_HASLINES , val )
}

property uint vTreeView.ShowLines
{ 
   return .pShowLines//.GetStyle( $TVS_HASLINES )
}

/*Свойство ustr ShowRootLines - Get Set
Установить, получить отображение линеек у корневого элемента
открытие ветки
1 - есть
0 - нет
*/
property vTreeView.ShowRootLines( uint val )
{   
   .pShowRootLines = val
   .SetStyle( $TVS_LINESATROOT, val )
}

property uint vTreeView.ShowRootLines
{ 
   return .pShowRootLines//.GetStyle( $TVS_LINESATROOT )
}

/*Свойство ustr ShowSelection - Get Set
Установить, получить отображение линеек слева от веток
1 - есть
0 - нет
*/
property vTreeView.ShowSelection( uint val )
{   
   .pShowSelection = val
   .SetStyle( $TVS_SHOWSELALWAYS, val )
}

property uint vTreeView.ShowSelection
{ 
   return .pShowSelection//.GetStyle( $TVS_HASLINES )
}

/*Свойство ustr RowSelect - Get Set
Установить, получить отображение линеек слева от веток
1 - есть
0 - нет
*/
property vTreeView.RowSelect( uint val )
{   
   .pRowSelect = val
   .SetStyle( $TVS_FULLROWSELECT , val )
}

property uint vTreeView.RowSelect
{ 
   return .pRowSelect//.GetStyle( $TVS_HASLINES )
}

/*Свойство ustr LabelEdit - Get Set
Установить, получить отображение линеек слева от веток
1 - есть
0 - нет
*/
property vTreeView.LabelEdit( uint val )
{   
   .pLabelEdit = val
   .SetStyle( $TVS_EDITLABELS , val )
}

property uint vTreeView.LabelEdit
{ 
   return .pLabelEdit//.GetStyle( $TVS_HASLINES )
}

/* Свойство str vTreeView.ImageList - Get Set
Устанавливает или получает имя списка картинок
*/
property ustr vTreeView.ImageList <result>
{
   result = this.pImageList
}

property vTreeView.ImageList( ustr val )
{
   if val != this.pImageList
   { 
      this.pImageList = val
      .Virtual( $mLangChanged )      
      //.iUpdateImageList()
   }
}

/* Свойство str vTreeView.StateImgListName - Get Set
Устанавливает или получает имя списка картинок состояний
*/
property ustr vTreeView.StateImageList <result>
{
   result = this.pStateImageList
}

property vTreeView.StateImageList( ustr val )
{
   if val != this.pStateImageList
   { 
      this.pStateImageList = val
      .Virtual( $mLangChanged )
      //.iUpdateImageList()
   }
}

/* Свойство uint vTreeView.MultiSelect - Get Set
Выделение нескольких элементов
*/
property uint vTreeView.MultiSelect()
{
   return .pMultiSelect
}

property vTreeView.MultiSelect( uint val )
{
   if val != this.pMultiSelect
   { 
      this.pMultiSelect = val      
   }
}


/* Свойство uint vListView.AutoDrag - Get Set
Возможность перетаскивать элементы внутри объекта
*/
property uint vTreeView.AutoDrag()
{
   return .pAutoDrag
}

property vTreeView.AutoDrag( uint val )
{
   this.pAutoDrag = val   
}

/*property  TVSelections vTreeView.Selections
{
   return this->TVSelections
}



method TVItem TVSelections.index( uint idx )
{
   uint tv as this->vTreeView
   if idx < *tv.pSelections 
   {
      return tv.pSelections[idx]->TVItem
   }
   return 0->TVItem 
}

operator uint * ( TVSelections sel )
{
   return *sel->vTreeView.pSelections
}

method TVSelections.Clear()
{
   uint tv as this->vTreeView
   while *tv.pSelections 
   {
      tv.pSelections[0]->TVItem.InSelections = 0
   }  
}*/
/*method TVItem.Index( uint 0 )
{
   
}*/


property TVItem vTreeView.Root
{
   if &this
   {
      return .gtroot->TVItem//.gttree.root()->TVItem//.items[0]
   }
   return 0->TVItem
}



/* Свойство uint Sorted - Get Set
Устанавливает или определяет должны ли сортироваться элементы в дереве
1 - элементы сортируются
0 - элементы не сортируются
*/
property uint vTreeView.Sorted()
{  
   return this.pSorted
}

property vTreeView.Sorted( uint val)
{
   if this.pSorted != val
   {
      this.pSorted = val
      this.Root().SortType = ?( val, $TVSORT_SORTRECURSE, $TVSORT_NONE )
      
   }
}

property TVItem vTreeView.Selected()
{     
   return this.pSelected->TVItem
}

property vTreeView.Selected( TVItem item )
{   
   if this.pSelected != &item
   {
      uint destitem = &item
      if destitem == &this.Root : destitem = 0
      //this.pSelected = destitem
      .WinMsg( $TVM_SELECTITEM, $TVGN_CARET, ?( destitem, destitem->TVItem.param->treedata.handle, 0) )      
   }
}

/* Свойство uint InSelections - Get Set
Устанавливает или определяет находится ли элемент в числе выбранных
*/
/*property uint TVItem.InSelections
{ 
   return .param->treedata.inselections 
}

property TVItem.InSelections( uint val )
{
   if val != .param->treedata.inselections
   { 
      .param->treedata.inselections = val
      uint sels as .param->treedata.treeview->vTreeView.pSelections
      if val
      {
         sels[sels.expand( 1 )] = &this
      }
      else
      {
         uint i
         fornum i = 0, *sels
         {
            if sels[i] == &this
            {
               sels.del(i)
               break;
            }
         }
      }
      .iItemUpdate( $TVIF_STATE )
   }
}
*/

/* Свойство uint treeviewStyle - Get Set
Усотанавливает или определяет стиль кнопки
Возможны следующие варианты:
bsClassic     - обычный вид,
bsAsRadiotreeview  - работает как Radiotreeview,
bsAsCheckBox  - работает как CheckBox
*/
/*property uint vTreeView.treeviewStyle()
{
   return this.ptreeviewStyle
}

property vTreeView.treeviewStyle( uint val)
{
   if this.ptreeviewStyle != val
   {      
      uint checked = this.Checked
      uint remstyle = $BS_AUTORADIOBUTTON | $BS_AUTOCHECKBOX | $BS_PUSHLIKE
      uint addstyle
      this.WinMsg( $BM_SETCHECK, 0 )
      this.pChecked = 0
      if val == $bsAsRadiotreeview
      {
         addstyle = $BS_AUTORADIOBUTTON | $BS_PUSHLIKE
      }
      elif val == $bsAsCheckBox
      {
         addstyle = $BS_AUTOCHECKBOX | $BS_PUSHLIKE  
      }      
      this.ChangeStyle( addstyle, remstyle ) 
      this.ptreeviewStyle = val      
      this.Checked = checked
   }
}
*/
/* Свойство uint Caption - Get Set
Усотанавливает или определяет заголовок кнопки
*/
/*property ustr vTreeView.Caption <result>
{
   result = this.pCaption.Value
}

property vTreeView.Caption( ustr val )
{   
   this.pCaption.Value = val
   SetWindowText( this.hwnd, this.pCaption.Text.ptr() )    
}


*/
/*------------------------------------------------------------------------------
   Virtual Methods
*/
/*Виртуальный метод vTreeView vTreeView.mCreateWin - Создание окна
*/
method vTreeView vTreeView.mCreateWin <alias=vTreeView_mCreateWin>()
{
   if .gtroot
   {
      .iWinClear( 0 )
   }


   uint exstyle
   uint style = $WS_CHILD | $WS_CLIPSIBLINGS
   if .pShowPlusMinus : style |= $TVS_HASBUTTONS 
   if .pShowLines     : style |= $TVS_HASLINES
   if .pShowRootLines : style |= $TVS_LINESATROOT
   if .pShowSelection : style |= $TVS_SHOWSELALWAYS
   if .pRowSelect     : style |= $TVS_FULLROWSELECT
   if .pLabelEdit     : style |= $TVS_EDITLABELS
   
   if .pBorder : exstyle |= $WS_EX_CLIENTEDGE   
   this.CreateWin( "SysTreeView32".ustr(), exstyle, style )         
   this->vCtrl.mCreateWin()      
   //this.WinMsg( $WM_SETFONT, GetStockObject( $DEFAULT_GUI_FONT ) )
   .iUpdateImgList()
   //uint himl = ImageList_Create(16, 16, 0xFE, 1, 0)
   //uint hbitmap = LoadBitmap( 0,  32754 )//"OBM_CHECKBOXES".ustr().ptr() )
   //ImageList_Add( himl,hbitmap,0)
   //DeleteObject( hbitmap )
   //hbitmap = LoadBitmap( 0, 32759 )//"OBM_CHECKBOXES".ustr().ptr() )
   //ImageList_Add( himl,hbitmap,0)
   //DeleteObject( hbitmap )
   //.WinMsg( $TVM_SETINDENT, -20 )
//   .WinMsg( $TVM_SETIMAGELIST, 0, himl ); 
   .Reload()                                                                 
   return this
}

/*Виртуальный метод uint vTreeView.mWinNtf - обработка сообщений
*/
method uint vTreeView.mWinNtf <alias=vTreeView_mWinNtf>( winmsg wmsg )//NMHDR ntf )
{   
   uint nmtv as wmsg.lpar->NMTREEVIEWW
   switch nmtv.hdr.code
   {
      case $NM_RCLICK
      {
         //TVHITTESTINFO tvht
         POINT pt
         uint lpar
         //uint curitem
           
         GetCursorPos( pt )
         lpar = ( pt.y << 16 ) | pt.x
         ScreenToClient( .hwnd, pt )
         /*tvht.pt = pt
      	if curitem = .WinMsg( $TVM_HITTEST, 0, &tvht )
         {
      	    .WinMsg( $TVM_SELECTITEM, $TVGN_CARET, curitem )
         }*/
         
         .WinMsg( $WM_CONTEXTMENU, this.hwnd, lpar )
      }
      case $TVN_GETDISPINFOW
      {      
         nmtv as NMTVDISPINFO   
         //uint nd as ntf->NMTVDISPINFO
         if nmtv.item.mask & $TVIF_IMAGE
         {
            nmtv.item.iImage = -1
         }
         if nmtv.item.mask & $TVIF_SELECTEDIMAGE
         {
            nmtv.item.iSelectedImage = -1
         }      
      return 0
      }
      case $TVN_SELCHANGEDW
      {    
         uint selected = ?( nmtv.itemNew.hItem, nmtv.itemNew.lParam, 0 )
         if selected == this.pSelected : return 0
         this.pSelected = selected
         
         if .pMultiSelect
         { 
            if !.fReleasing                                    
            {
               nmtv as NMTREEVIEWW
               if GetKeyState( $VK_SHIFT ) & 0x8000// nmtv.action == 2/*$TVC_BYMOUSE*/ &&  
               {
                  if nmtv.itemNew.lParam
                  {
                     if .fFromMouse
                     {
                        if nmtv.itemOld.lParam
                        {
                           if .Selection.Find( nmtv.itemOld.lParam->TVItem ) != -1
                           {
                              .Selection.iSelect( nmtv.itemOld.lParam->TVItem, 1 )
                           } 
                        }
                     }
                     else 
                     {
                        .Selection.Clear()
                     }
                     uint item
                     uint flgselect
                     item as .Root
                     if .Selection.StartShift
                     {
                        while ( item as item.NextInList )
                        {          
                           if !flgselect 
                           {
                              if &item == .Selection.StartShift : flgselect = 1 
                              elif &item == nmtv.itemNew.lParam : flgselect = 2
                              else : continue                        
                           }                     
                           {
                              .Selection.Append( item )
                              if ( flgselect == 2 && &item == .Selection.StartShift ) ||
                                 ( flgselect == 1 && &item == nmtv.itemNew.lParam )
                              {
                                 break
                              }
                           }
                           
                        } 
                     } 
                     else 
                     {
                        .Selection.StartShift = nmtv.itemNew.lParam
                        .Selection.Append( nmtv.itemNew.lParam->TVItem )
                     }           
                  }
               }      
               elif GetKeyState( $VK_CONTROL ) & 0x8000 && .fFromMouse/*$TVC_BYMOUSE*/   
               {
                  if nmtv.itemNew.lParam
                  {
                     if .Selection.Find( nmtv.itemNew.lParam->TVItem ) != -1
                     {                
                        .Selection.Remove( nmtv.itemNew.lParam->TVItem )
                     }  
                     else 
                     {                
                        .Selection.Append( nmtv.itemNew.lParam->TVItem )
                     }
                     .Selection.StartShift = nmtv.itemNew.lParam
                  } 
                  if nmtv.itemOld.lParam
                  {
                     if .Selection.Find( nmtv.itemOld.lParam->TVItem ) != -1
                     {
                        .Selection.iSelect( nmtv.itemOld.lParam->TVItem, 1 )
                     } 
                  }            
               }  
               else
               {  
                  .Selection.Clear()  
                  if nmtv.itemNew.lParam 
                  {
                   /*  if .Selection.Find( nmtv.itemNew.lParam->TVItem ) == -1
                     {
                        .Selection.Clear()
                        .Selection.Append( nmtv.itemNew.lParam->TVItem )
                     }       
                     else
                     {
                        //InvalidateRect( this.hwnd, 0->RECT, 0 )
                        //.Selections.iWinUpdate( 1 )
                         
                        if nmtv.itemOld.lParam
                        {
                           if .Selection.Find( nmtv.itemOld.lParam->TVItem ) != -1
                           {
                              .Selection.iSelect( nmtv.itemOld.lParam->TVItem, 1 )
                           } 
                        }
                     }    */            
                     .Selection.Append( nmtv.itemNew.lParam->TVItem )
                     .Selection.StartShift = nmtv.itemNew.lParam
                  }               
               }
            }
            else
            {
               if nmtv.itemNew.lParam
               {
                  .Selection.Append( nmtv.itemNew.lParam->TVItem )       
                  .Selection.StartShift = nmtv.itemNew.lParam
               }
            }
                 
            //if nmtv.itemOld.lParam &&
            //   (( nmtv.action == 1/*$TVC_BYMOUSE*/ &&  GetKeyState( $VK_CONTROL ) & 0x8000 ) ||
            //    ( nmtv.action == 2/*$TVC_BYKEYBOARD*/ &&  GetKeyState( $VK_SHIFT ) & 0x8000 ))
            
            //   nmtv.itemOld.lParam->TVItem.InSelections = !nmtv.itemOld.lParam->TVItem.InSelections
               //wmsg.flags = 1
            
            
         }
         else
         {
            .Selection.Clear()
            if &this.Selected
            {
               .Selection.Append( this.Selected )
            } 
         }
         evparValUint etva         
         etva.val = this.pSelected
         etva.sender = &this      
         .OnAfterSelect.Run( /*this,*/ etva )         
      }
      case $TVN_SELCHANGINGW
      {      
         if .fMoving 
         {
            wmsg.flags = 1
            return 1
         }
       /*  nmtv as NMTREEVIEWW      
         if  nmtv.action == 1 &&  GetKeyState( $VK_CONTROL ) & 0x8000
         {
            wmsg.flags= 1
            return 1
         }*/        
         evparQuery etvb
         etvb.val = ?( nmtv.itemNew, nmtv.itemNew.lParam, 0 )
         etvb.sender = &this                   
         .OnBeforeSelect.Run( /*this,*/ etvb )
         return etvb.flgCancel         
      }
      case $TVN_ITEMEXPANDEDW
      {
         if nmtv.action & ( $TVE_COLLAPSE | $TVE_EXPAND )
         {
            nmtv.itemNew.lParam->TVItem.setuint( "expanded", nmtv.action & $TVE_EXPAND )           
            
         }
         /*foreach it, this.Root()
         {
            .Selected = it   
            break;
         }*/
         
      }
      case $TVN_ITEMEXPANDINGW
      {
      }
      case $TVN_BEGINLABELEDITW
      {
         evparTVEdit etve  
         etve.Item = &.Selected
         etve.sender = &this       
         .OnBeforeEdit.Run( /*this,*/ etve )
         return etve.flgCancel
      }
      case $TVN_ENDLABELEDITW
      {
         nmtv as NMTVDISPINFO
         
         evparTVEdit etve
         uint item as ?( nmtv.item.hItem, nmtv.item.lParam, 0 )->TVItem
         
         etve.Item = &item 
         if nmtv.item.pszText
         {
            etve.NewLabel.copy( nmtv.item.pszText )     
         }
         else
         {
            etve.flgCancel = 1
         }
         etve.sender = &this
         .OnAfterEdit.Run( /*this,*/ etve )
         if !etve.flgCancel 
         {  
            if &item
            {
               item.Label = etve.NewLabel
            }                    
            /*uint selected as .Selected
            if &selected
            {    
               selected.Label = etve.NewLabel            
               //selected.set( "label", etve.NewLabel.toutf8( "" ) )
            } */           
            return 1
         }         
      }
      case $TVN_BEGINDRAGW
      {
         if .pAutoDrag
         {
            .Selected = nmtv.itemNew.lParam->TVItem
         //RECT rect 
         //(&rect)->uint = nmtv.itemNew.hItem
         //.WinMsg( $TVM_GETITEMRECT, 1, &rect )
         //uint hdc = GetDC( .hwnd )
                           
            SetCapture( .hwnd ) 
            .fDrag = 1
         }
         else
         {
            .Selected = nmtv.itemNew.lParam->TVItem
            .OnBeginDrag.Run(this)
         }      
      }  
      case $TVN_DELETEITEMW
      {
      }
      case $NM_CUSTOMDRAW  
      {
         uint cd as wmsg.lpar->NMTVCUSTOMDRAW
         uint resi = $CDRF_DODEFAULT;          
         switch( cd.nmcd.dwDrawStage )
         {
            case $CDDS_PREPAINT: resi |= $CDRF_NOTIFYITEMDRAW;
            case $CDDS_ITEMPREPAINT
            {
               uint item as cd.nmcd.lItemlParam->TVItem                  
               if &item 
               {
                  str color
                  if item.getuint( "disabled" ) : cd.clrText = GetSysColor(16)
                  elif *item.get( "color", color ) : cd.clrText = color.uint()
               }
            }
         }
         wmsg.flags = 1 
         return resi
      } 
   }
   return 0
}

method TVItem vTreeView.DragTest( POINT pt )
{
   uint destitem            
   
   if destitem = &.HitTest( pt.x, pt.y, 0 )   
   {                 
      destitem as TVItem
      .WinMsg( $TVM_SELECTITEM, $TVGN_DROPHILITE, destitem.param->treedata.handle )
      return destitem               
   }
   else
   {
      if int( pt.x ) > 0 && int( pt.y ) > 0 && pt.x < .clloc.width && pt.y < .clloc.height
      {
         return (-1)->TVItem
      }      
   }
   return 0->TVItem
}

method uint vTreeView.mMouse <alias=vTreeView_mMouse>( evparMouse em )
{
   switch em.evmtype
   {
      case $evmMove
      {
         if .fDrag 
         {         
            POINT point
            uint destitem            
             
            point.x = em.x
            point.y = em.y            
            
            if destitem = &.HitTest( em.x, em.y, 0 )   
            {                 
               destitem as TVItem
               
               if .Selection.Find( destitem ) == -1
               { 
                  .WinMsg( $TVM_SELECTITEM, $TVGN_DROPHILITE, destitem.param->treedata.handle )               
                  //.WinMsg( $TVM_EXPAND, $TVE_EXPAND, destitem )
                  SetCursor( App.cursorDrag )
               }
               else 
               {
                  .WinMsg( $TVM_SELECTITEM, $TVGN_DROPHILITE, 0 )
                  SetCursor( App.cursorNoDrag )
               } 
            }
            else
            {
               if int( em.x ) > 0 && int( em.y ) > 0 && em.x < .clloc.width && em.y < .clloc.height
               {
                  SetCursor( App.cursorDrag )
               }
               else
               {
                  SetCursor( App.cursorNoDrag )
               }
            }
            ClientToScreen( .hwnd, point )
            //ImageList_DragMove( point.x, point.y )   
         }
      }
      case $evmLUp
      {
         uint dest
         TVHITTESTINFO tvht
         if .fDrag
         {
            uint destitem //as TVItem
            uint selected as .pSelected->TVItem
            uint flg
            
            //tvht.pt.x = em.x
            //tvht.pt.y = em.y            
            //if dest = .WinMsg( $TVM_HITTEST, 0, &tvht)
            if destitem = &.HitTest( em.x, em.y, 0 )  
            {
             /*  TVITEM item
               item.mask = $TVIF_PARAM
               item.hItem = dest
               .WinMsg( $TVM_GETITEMW, 0, &item )
            
               destitem as item.lParam->TVItem*/
               destitem as TVItem
               uint previtem as destitem.getprev()->TVItem
               if .Selection.Find( destitem ) == -1 &&
                  ( !&previtem || .Selection.Find( previtem ) == -1 )
               {                  
                  uint owneritem as destitem
                  uint root as .Root                   
                  do
                  {
                     if &owneritem == .pSelected
                     {
                        destitem as 0
                        break
                     }
                     owneritem as owneritem.Parent                     
                  }
                  while &owneritem != &root
                  flg = $TREE_BEFORE                  
               }     
               else : goto end          
            }
            elif int( em.x ) > 0 && int( em.y ) > 0 && em.x < .clloc.width && em.y < .clloc.height
            {
               destitem as .Root
               flg = $TREE_LAST
               //selected.MoveTo( .Root, $TREE_LAST )
            }  
            .Selection.MoveTo( destitem->TVItem, flg )                                    
            //ImageList_EndDrag( )
label end                        
            ReleaseCapture()
            //.Selected = 0->TVItem
            //.Selected = selected  
            //.fDrag = 0
         }
      }
   }

   return this->vCtrl.mMouse( em )   
}

method uint vTreeView.wmcapturechange <alias=vTreeView_wmcapturechanged>( winmsg wmsg )
{   
   if wmsg.lpar != .hwnd && .fDrag 
   {
      SetCursor( App.cursorArrow )
      .WinMsg( $TVM_SELECTITEM, $TVGN_DROPHILITE, 0 )
      .fDrag = 0
   } 
   return 0
}

method vTreeView.mPreDel <alias=vTreeView_mPreDel>()
{
   .DisconnectGt()
   .WinMsg( $TVM_SELECTITEM, $TVGN_CARET, 0 ) 
   //this.Root.Del()
   this.Clear()
   //destroy( this.Root.param )
   this->vCtrl.mPreDel()
}
/*Виртуальный метод uint vTreeView.mLangChanged - Изменение текущего языка
*/
method uint vTreeView.mLangChanged <alias=vTreeView_mLangChanged>()
{
   .iUpdateImgList()
   .Root.Update()
   this->vCtrl.mLangChanged()
//   .Caption = .Caption
   return 0  
}

method vTreeView.mFocus <alias=vTreeView_mFocus>( evparValUint ev )
{
   if *.Selection > 1 
   {  
      .Invalidate()
   }
   this->vCtrl.mFocus( ev )   
}

method vTreeView vTreeView.mOwnerCreateWin <alias=vTreeView_mOwnerCreateWin>()
{
   .Virtual( $mReCreateWin )
   return this
}

method uint vTreeView.wmMouse <alias=vTreeView_wmMouse>( winmsg wmsg )
{  
   //if .pShowSelection
   {
   
      TVHITTESTINFO tvht
      //POINT pt
      //uint lpar
      uint curitem
         
      //GetCursorPos( pt )
      //lpar = ( pt.y << 16 ) | pt.x
      //ScreenToClient( .hwnd, pt )
      tvht.pt.x = int( ( &wmsg.lpar )->short )
      tvht.pt.y = int( ( &wmsg.lpar + 2 )->short )
      if curitem = .WinMsg( $TVM_HITTEST, 0, &tvht )
      {         
         if !( tvht.flags & $TVHT_ONITEMBUTTON )
         {
            .fFromMouse = 1
         	.WinMsg( $TVM_SELECTITEM, $TVGN_CARET, curitem )
            .fFromMouse = 0         
         }   
      }
      //SetFocus( this.hwnd )
     /* LVHITTESTINFO info
      info.pt.x = int( ( &wmsg.lpar )->short )
      info.pt.y = int( ( &wmsg.lpar + 2 )->short )
      if .WinMsg( $LVM_HITTEST, 0, &info ) == -1*/
      { 
         //( &wmsg.lpar )->short = 5
         //( &wmsg.lpar + 2 )->short = 5
        // wmsg.flags = 1
         /*         
         info.pt.x = 5         
         if .WinMsg( $LVM_HITTEST, 0, &info ) != -1
         {              
            LVITEM lvi
            lvi.mask = $LVIF_STATE
            //lvi.iItem = info.iItem
            lvi.stateMask = $LVIS_FOCUSED | $LVIS_SELECTED 
            lvi.state = $LVIS_FOCUSED | $LVIS_SELECTED 
            .WinMsg( $LVM_SETITEMSTATE, info.iItem, &lvi )
         }*/
      }
   }
   return this->vCtrl.wmMouse( wmsg )
}

/*Виртуальный метод vTreeView.mSetName - Установка заголовка в режиме проектирования
*/
/*method uint vTreeView.mSetName <alias=vTreeView_mSetName>( str newname )
{
ifdef $DESIGNING {   
   if !*.Caption || .Caption == .Name
   {
      .Caption = newname.ustr()
   }
}   
   return 1
}

*/
/*------------------------------------------------------------------------------
   Registration
*/
/*Системный метод vTreeView vTreeView.init - Инициализация объекта
*/   
method vTreeView vTreeView.init( )
{   
   this.pTypeId = vTreeView
     
   this.pCanFocus = 1
   this.pTabStop = 1      
   this.loc.width = 100
   this.loc.height = 25
   this.pBorder = 1
   this.pShowPlusMinus = 1
   this.pShowLines = 1
   this.pShowRootLines = 1
   //uint itemdata as new( treedata )->treedata
   //itemdata.treeview = &this
   //this.gttree.root().param = &itemdata
   
   .Selection.pTreeView = &this
   .Reload()
   //this.items[0].TreeView = &this
   //this.items[0].gti = &this.gti.root()
   return this 
}  

/*ifdef $DESIGNING
{
method vTreeView.mRegProps <alias=vTreeView_mRegProps>( uint typeid, compMan cm )
{
//   this->vCtrl.mRegProps( typeid, cm)
}*/
/*
method vTreeView.getevents( uint typeid, compMan cm )
{
   this->vCtrl.getevents( typeid, cm)
   cm.addevents( typeid, %{
"onclick"      , "eventn"
   })
}*/

func init_vTreeView <entry>()
{  
   regcomp( vTreeView, "vTreeView", vCtrl, $vCtrl_last, 
      %{ %{$mCreateWin,    vTreeView_mCreateWin},
          %{$mWinNtf,       vTreeView_mWinNtf },
          %{$mMouse,       vTreeView_mMouse },
          %{$mPreDel,      vTreeView_mPreDel },
         %{$mLangChanged,  vTreeView_mLangChanged },
          %{$mFocus,       vTreeView_mFocus },
          %{$mOwnerCreateWin, vTreeView_mOwnerCreateWin }/*,
         %{$mSetName,      vTreeView_mSetName}*/
      },       
      %{ %{ $WM_CAPTURECHANGED, vTreeView_wmcapturechanged },
         %{ $WM_LBUTTONDOWN, vTreeView_wmMouse },
         %{ $WM_RBUTTONDOWN, vTreeView_wmMouse } 
      }
       )
      
ifdef $DESIGNING {
   cm.AddComp( vTreeView, 1, "Windows", "treeview" )
   cm.AddProps( vTreeView, %{    
//"TabOrder", uint, 0,
"Border", uint, 0,
"ShowPlusMinus", uint, 0,
"ShowLines", uint, 0,    
"ShowRootLines", uint, 0,
"ShowSelection", uint, 0,
"RowSelect", uint, 0,
"LabelEdit", uint, 0,
"ImageList", ustr, 0,
"StateImageList", ustr, 0,
"AutoDrag", uint, 0,
"MultiSelect", uint, 0 
/*"Caption",  ustr, 0,
"treeviewStyle", uint, 0,
"Checked",  uint, 0*/
   }) 
   /*                
   cm.AddPropVals( vTreeView, "treeviewStyle", %{ 
"bsClassic",      $bsClassic,
"bsAsRadiotreeview",   $bsAsRadiotreeview,     
"bsAsCheckBox",   $bsAsCheckBox
   })   
   */
   cm.AddEvents( vTreeView, %{
//"OnBeforeEdit", "eventTVEdit",
"OnAfterEdit", "evparTVEdit",
//"OnBeforeSelect", "",
"OnAfterSelect", "evparValUint",
/*,
"OnBeforeExpand", "",
"OnAfterExpand", "",
"OnBeforeCollapse", "",
"OnAfterCollapse", ""*/
"OnBeforeMove", "evparBeforeMove",
"OnAfterMove", "evparAfterMove",
"OnBeginDrag", "evparEvent"

   })
}
      
}
