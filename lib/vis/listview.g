/******************************************************************************
*
* Copyright (C) 2004-2007, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: vis.listview 9.10.07 0.0.A.
*
* Author: Alexander Krivonogov ( gentee )
*
******************************************************************************/
include {   
//   "app.g"
   "..\\gt\\gt.g"
   "treeview.g"
   
}
/*
type LVItem <inherit=gtitem>
{

}*/

type vListViewColumn <inherit=vComp>//gtitem> 
{   
   locustr pCaption
   uint    pWidth
   uint    pOrder
   ustr    pAlias
   uint    pUseLanguage
   
   ustr    pImageId   
   uint    pSortType
   uint    pSorted
   uint    pDefSorted
   uint    pAdvSortColumn
   uint    pVisible
}   

/*type LVColumnData
{
   uint pColumns
   uint idx
}*/

type LVCell <inherit=gtitem>
{
}

type LVRow <inherit=gtitem index=LVCell>
{
}

type LVRowData
{
   uint pRows
   uint idx
   //uint visindex
}



type LVCellData
{
   uint row
   uint column
}


type LVRows <inherit=arr index=LVRow>
{
   uint pListView 
}

type LVColumns <index=vListViewColumn>
{
   uint pListView  
}

type LVColOrder <index=vListViewColumn>
{
   uint pListView  
}

type LVSelection <index=LVRow>
{
   uint pListView
   arr  Items of uint
}
/*
type listdata
{
   //uint listview
   uint listview //Объект содержащий данный элемент
   //uint idx //Номер элемента в окне
//   uint inselections
   //uint tag
   //uint gttree  
}*/
/*
type eventTVEdit <inherit=onevent> 
{   
   ustr NewLabel   
   uint flgCancel
}

method eventTVEdit eventTVEdit.init
{
   this.eventtypeid = eventTVEdit
   return this
}

type eventTVBefore <inherit=onevent> 
{   
   uint CurItem      
   uint flgCancel
}

method eventTVBefore eventTVBefore.init
{
   this.eventtypeid = eventTVBefore
   return this
}

type eventTVAfter <inherit=onevent> 
{   
   uint CurItem
}

method eventTVAfter eventTVAfter.init
{
   this.eventtypeid = eventTVAfter
   return this
}*/

/* Компонента vListView, порождена от vCtrl
События
   onClick - вызывается при нажатии на кнопку
*/
type vListView <inherit = vCtrl>
{
   LVColumns  Columns
   LVColOrder ColumnsOrder
   arr       arOrder of uint
   LVRows    Rows
   LVSelection Selection
   arr sel of uint 
//Hidden Fields   
   uint    fConnectGt
   uint    pListViewStyle  //Стиль списка
   uint    pShowHeader     //Показывать заголовки колонок
   uint    pHeaderDragDrop //Перетаскивать колонки  
   uint    pGridLines      //Отображение сетки таблицы
   uint    pShowSelection  //Всегда показывать выделение   
   uint    pLabelEdit      //Возможность редактирования элементов
   uint    pBorder         //Показывать рамку
   uint    pRowSelect      //Выделение элемента в виде строки
   uint    pCheckBoxes     //Галочки у элементов
   uint    pMultiSelect    //Выделение нескольких элементов
   uint    pEnsureVisible  //Прокручивать до выбранного элемента
   uint    pAutoDrag       //Возможность перетаскивать элементы 
   
   /*uint    pArrangeed         //Сортировать элементы*/
   uint    pSelected       //Текущий выбранный элемент
   uint    fDrag           //Флаг, находимся в режиме drag'n'drop
   uint    fOldDestItem    //Куда перетаскивать текущий элемент
   uint    fUpdateOrders   //Флаг пересчитывать порядок колонок
   uint    pSortedColumn   //Адрес последней отсортированной колонки
   uint    pSortFunc       //Функция для сортировки
   uint    pOwnerData      //Получение данных по запросу
   
   ustr    pSmallImageList
   uint    ptrSmallImageList
   ustr    pImageList
   uint    ptrImageList
   uint    numImageList
   ustr    pStateImageList
   uint    ptrStateImageList

   gt      gttree          //Представление в виде gt
   //uint   gtcolumns
   uint   gtrows 
//Events   
   //onevent onStartEdit
   evTVEdit   OnAfterEdit
   evTVEdit   OnBeforeEdit
   evQuery OnBeforeSelect
   evValUint  OnAfterSelect
   uint    flgItemChanging
   //evItemMoved  OnItemMoved
   evBeforeMove OnBeforeMove
   evAfterMove  OnAfterMove
   
   evValColl  OnGetData
   
   evQuery      OnColumnClick
   
   uint         flgRowInserting
   
   uint clrTextBk
   uint clrText  
   
   evValColl     OnItemDraw
   evValColl     OnSubItemDraw
   evValUint     OnChanged
   
   evEvent      OnBeginDrag
   //evValUint   OnGetLabel
   /*eventTVBefore OnBeforeExpand
   eventTVAfter  OnAfterExpand
   eventTVBefore OnBeforeCollapse
   eventTVAfter  OnAfterCollapse*/
}

extern {
   method vListView.Reload()
   property LVRow vListView.Selected()
   property vListView.Selected( LVRow item )
}



define <export>{
//Стили списка
   lvsIcon       = $LVS_ICON      
   lvsReport     = $LVS_REPORT    
   lvsSmallIcon  = $LVS_SMALLICON 
   lvsList       = $LVS_LIST  

//Стиль vListViewColumn.SortType      
   lvstNone = 0
   lvstText = 1
   lvstValue = 2
   lvstSortIndex = 3
   lvstEvent = 4
   
   lvsortNone = 0
   lvsortDown = 1
   lvsortUp = 2       
}  

include { "listviewitem.g" }

extern {
//property uint LVItem.InSelections
//property LVItem.InSelections( uint val )
//property LVItem vListView.Selected()
//property vListView.Selected( LVItem item )
/*property ustr LVItem.Label// <result>
property LVItem LVItem.Child()*/
//property LVItem LVItem.Prev()
//property LVItem LVItem.Next()
//method LVItem.WinSet( uint mask )
//property uint LVItem.Idx 
//property vListView.Selected( LVItem item )

}
/*------------------------------------------------------------------------------
   Public Methods
*/
/*method vListView.Clear()
{
   .Rows.Clear()
   //.Columns.Clear()
   //.gttree.clear()
   //.WinMsg( $LVM_DELETEALLITEMS )
}*/

method vListView.Edit()
{  
   if &(.Selected())
   {  
      .SetFocus()     
      .WinMsg( $LVM_EDITLABELW, /*.Selected.Idx()*/.Selected.VisIndex, 0)
   }
}

/*------------------------------------------------------------------------------
   Properties
*/
/*Свойство ustr Border - Get Set
Установить, получить наличие рамки у поля ввода
1 - рамка есть
0 - рамки нет
*/
property vListView.Border( uint val )
{
   .pBorder = val
   uint style = GetWindowLong( this.hwnd, $GWL_EXSTYLE )
   if val : style |= $WS_EX_CLIENTEDGE
   else : style &= ~$WS_EX_CLIENTEDGE
   SetWindowLong( this.hwnd, $GWL_EXSTYLE, style )      
   SetWindowPos( this.hwnd, 0, 0, 0, 0, 0, $SWP_FRAMECHANGED | 
                  $SWP_NOACTIVATE | $SWP_NOZORDER | $SWP_NOMOVE | $SWP_NOSIZE )
}

property uint vListView.Border
{   
   //.pBorder = ?(GetWindowLong( this.hwnd, $GWL_EXSTYLE ) & $WS_EX_CLIENTEDGE,1,0)
   return .pBorder
}

/*Свойство uint ListViewStyle - Get Set
Установить, получить стиль списка
*/
property vListView.ListViewStyle( uint val )
{   
   if val != .pListViewStyle
   {
      .pListViewStyle = val
      .SetStyle( $LVS_TYPEMASK, val )
   }
}

property uint vListView.ListViewStyle
{ 
   return .pListViewStyle
}

/*Свойство uint OwnerData - Get Set
Установить, получить флаг получения данных по запросу
*/
property vListView.OwnerData( uint val )
{   
   if val != .pOwnerData
   {      
      .pOwnerData = val      
      .Virtual( $mReCreateWin )            
   }
}

property uint vListView.OwnerData
{ 
   return .pOwnerData
}


/*Свойство uint ShowHeader - Get Set
Показывать/не показывать заголовки колонок
0 - не показывать
1 - показывать 
*/
property vListView.ShowHeader( uint val )
{   
   if val != .pShowHeader
   {
      .pShowHeader = val
      .SetStyle( $LVS_NOCOLUMNHEADER, !val )
   }
}

property uint vListView.ShowHeader
{ 
   return .pShowHeader
}

/*Свойство uint RowSelect - Get Set
Выделение элемента в виде строки
0 - выделять ячейку
1 - выделять строку
*/
property vListView.RowSelect( uint val )
{   
   if val != .pRowSelect
   {
      .pRowSelect = val      
      .WinMsg( $LVM_SETEXTENDEDLISTVIEWSTYLE, $LVS_EX_FULLROWSELECT, 
               $LVS_EX_FULLROWSELECT )
   }
}

property uint vListView.RowSelect
{ 
   return .pRowSelect
}

/*Свойство uint CheckBoxes - Get Set
Галочки у элементов
0 - показывать
1 - нет
*/
property vListView.CheckBoxes( uint val )
{   
   if val != .pCheckBoxes
   {
      .pCheckBoxes = val      
      .WinMsg( $LVM_SETEXTENDEDLISTVIEWSTYLE, $LVS_EX_CHECKBOXES, 
               $LVS_EX_CHECKBOXES  )
   }
}

property uint vListView.CheckBoxes
{ 
   return .pCheckBoxes
}
/*Свойство uint HeaderDragDrop - Get Set
Возможность перетаскивать колонки
0 - нельзя перетаскивать
1 - можно перетаскивать
*/
property vListView.HeaderDragDrop( uint val )
{   
   if val != .pHeaderDragDrop
   {
      .pHeaderDragDrop = val      
      .WinMsg( $LVM_SETEXTENDEDLISTVIEWSTYLE, $LVS_EX_HEADERDRAGDROP, 
               $LVS_EX_HEADERDRAGDROP )
   }
}

property uint vListView.HeaderDragDrop
{ 
   return .pHeaderDragDrop
}

/*Свойство ustr GreidLines - Get Set
Отображение сетки таблицы
1 - есть
0 - нет
*/
property vListView.GridLines( uint val )
{  
   if .pGridLines != val
   { 
      .pGridLines = val
      .WinMsg( $LVM_SETEXTENDEDLISTVIEWSTYLE, $LVS_EX_GRIDLINES, 
               $LVS_EX_GRIDLINES )
   }
}

property uint vListView.GridLines
{ 
   return .pGridLines
}

/*Свойство ustr ShowSelection - Get Set
//Всегда показывать выделение
1 - показывать всегда
0 - нет
*/
property vListView.ShowSelection( uint val )
{   
   if .pShowSelection != val
   { 
      .pShowSelection = val
      .SetStyle( $LVS_SHOWSELALWAYS, val )
   }
}

property uint vListView.ShowSelection
{ 
   return .pShowSelection
}

/*Свойство uint MultiSelect - Get Set
//Выделение нескольких элементов
1 - да
0 - нет
*/
property vListView.MultiSelect( uint val )
{   
   if .pMultiSelect != val
   { 
      .pMultiSelect = val
      .SetStyle( $LVS_SINGLESEL, !val )
   }
}

property uint vListView.MultiSelect
{ 
   return .pMultiSelect
}

/*Свойство ustr LabelEdit - Get Set
Установить, получить отображение линеек слева от веток
1 - есть
0 - нет
*/
property vListView.LabelEdit( uint val )
{   
   .pLabelEdit = val
   .SetStyle( $LVS_EDITLABELS , val )
}

property uint vListView.LabelEdit
{ 
   return .pLabelEdit
}

/*Свойство ustr EnsureVisible - Get Set
Прокручивать до выбранного элемента
1 - прокручивать
0 - нет
*/
property vListView.EnsureVisible( uint val )
{   
   .pEnsureVisible = val   
}

property uint vListView.EnsureVisible
{ 
   return .pEnsureVisible
}

/* Свойство uint vListView.AutoDrag - Get Set
Возможность перетаскивать элементы внутри объекта
*/
property uint vListView.AutoDrag()
{
   return .pAutoDrag
}

property vListView.AutoDrag( uint val )
{
   this.pAutoDrag = val   
}
/*property uint LVItem.Idx 
{   
   uint id 
   uint prev = &this
   while prev = &prev->LVItem.Prev() 
   {
      id++
   }
   return id  
}

method LVItem.Del()
{
   
   if &this == .param->listdata.listview->vListView.pSelected 
   {
      uint newsel 
      newsel as .Next
      if !&newsel
      {
         newsel as .Prev
      }
      //.param->listdata.listview->vListView.pSelected = 0
      .param->listdata.listview->vListView.Selected = newsel
   }
   
   if &this && .param->listdata.listview
   {   
      .param->listdata.listview->vListView.WinMsg( $LVM_DELETEITEM, .Idx )
      
   }
   //if &this != &.param->treedata.treeview->vTreeView.gttree.root()
   {   
      destroy( .param )
      this.del()
   }
}
*/
/* Свойство ustr Label - Get Set
Устанавливает или определяет заголовок элемента дерева
*/
/*property ustr LVItem.Label <result>
{ 
   result.fromutf8( .get( "name" ) ).ptr()  
}

property LVItem.Label( ustr val )
{
   .set( "name", val.toutf8( "" ) )
   .WinSet( $LVIF_TEXT )
}



method vListView.WinInsert( LVItem curitem )
{
   uint id
   LVITEM li   
   
   //uint thisdata as .param->listdata   
   li.pszText = curitem.Label.ptr()
   li.iItem = curitem.Idx   
   
   
   //ti.hParent = thisdata.handle
   li.mask = $LVIF_TEXT | $LVIF_PARAM   
   li.lParam = &curitem   
   
   .WinMsg( $LVM_INSERTITEMW, 0, &li )
   
   //child.WinSet( $TVIF_STATE )   
}

method LVItem vListView.InsertItem( ustr name, uint tag, LVItem after )
{
   if &this
   {      
      //uint thisdata as .param->treedata
       
      uint newitem as .gttree.root()->LVItem.insertchild( "", after )->LVItem
      uint newitemdata as new( listdata )->listdata
      newitemdata.listview = &this
      newitem.param = &newitemdata
      newitem.set( "name", name.toutf8( "" ) )
      newitem.setuint( "tag", tag )
      
      uint Arrangetype = .getuint( "Arrangetype" )
      if Arrangetype & $TVArrange_Arrange
      {         
         //ti.hInsertAfter = $TVI_Arrange
         if Arrangetype == $TVArrange_ArrangeRECURSE 
         {
            child.setuint( "Arrangetype", Arrangetype )
         }         
      }
      .WinInsert( newitem )
                  
      return newitem->LVItem
   }
   return 0->LVItem
}
 
method LVItem vListView.InsertFirst( ustr name, uint tag )
{   
   return this.InsertItem( name, tag, 0->LVItem ) 
}

method LVItem vListView.Append( ustr name, uint tag )
{   
   return this.InsertItem( name, tag, 0xFFFFFFFF->LVItem )
}
*/
/*
method LVItem LVItem.index( uint idx )
{
   
   return 0->LVItem   
}
*/
/*property LVItem vListView.Root
{
   if &this
   {
      return .gttree.root()->LVItem//.items[0]
   }
   return 0->LVItem
}


method LVItem.WinSet( uint mask )
{
   LVITEM item
   uint   state
   
   
   item.mask = mask
   //item.iItem = this.Idx
   //if .getuint( "expanded" ) : state |= $TVIS_EXPANDED
//   if .getuint( "bold" ) : state |= $TVIS_BOLD
   //if .param->treedata.inselections { state |= $TVIS_SELECTED//$TVIS_DROPHILITED //| $TVIS_CUT
   //item.state = state | $TVIS_EXPANDPARTIAL 
//   item.stateMask = $TVIS_BOLD
      
   ustr val 
   item.pszText = val.fromutf8( .get( "name" ) ).ptr()   
   .param->listdata.listview->vListView.WinMsg( $LVM_SETITEMTEXTW, this.Idx, &item )   
}
*/


/* Свойство uint Expand - Get Set
Устанавливает или определяет открытие ветки
0 - ветка закрыта
1 - ветка открыта
*/
/*property uint LVItem.Expanded
{ 
   return .getuint( "expanded" )  
}

property LVItem.Expanded( uint val )
{
   if .getuint( "expanded" ) != val
   {
      .param->treedata.listview->vListView.WinMsg( $TVM_EXPAND, ?( val, $TVE_EXPAND, $TVE_COLLAPSE ), .param->treedata.handle ) 
      .setuint( "expanded", val )
   }
   //.WinSet( $TVIF_STATE )
}
*/

/* Свойство uint Tag - Get Set
Устанавливает или определяет пользовательский параметр элемента дерева
*/
/*property uint LVItem.Tag
{ 
   return .getuint( "tag" )  
}

property LVItem.Tag( uint val )
{
   .setuint( "tag", val )
}*/

/* Свойство uint Bold - Get Set
Устанавливает или определяет пользовательский параметр элемента дерева
*/
/*property uint LVItem.Bold
{ 
   return .getuint( "bold" )  
}

property LVItem.Bold( uint val )
{
   .setuint( "bold", val )
   .WinSet( $TVIF_STATE )
}
*/
/* Свойство uint Checked - Get Set
Устанавливает или определяет пользовательский параметр элемента дерева
*//*
property uint LVItem.Checked
{ 
   return .getuint( "checked" )  
}

property LVItem.Checked( uint val )
{
   .setuint( "checked", val )
   //.WinSet( $TVIF_STATE )
}

/* Свойство uint ArrangeTYpe - Get Set
Устанавливает или определяет пользовательский параметр элемента дерева
*//*
property uint LVItem.ArrangeType
{ 
   return .getuint( "Arrangetype" )  
}

property LVItem.ArrangeType( uint val )
{  
   .setuint( "Arrangetype", ?( val & $TVArrange_Arrange, val, $TVArrange_NONE ))
   if val & $TVArrange_Arrange
   {   
      .param->treedata.listview->vListView.WinMsg( $TVM_ArrangeCHILDREN, 0, .param->treedata.handle )
   }   
   if val & $TVArrange_RECURSE 
   {              
      foreach child, this
      {       
         child.ArrangeType = val
      }
   }
   
   //.WinSet( $TVIF_STATE )
}
*/
/* Свойство uint Parent - Get
Определяет хозяина данной ветки, если ветка в корне то корень, если корень то 0
*/
/*property LVItem LVItem.Parent
{    
   return this->gtitem.parent()->LVItem 
}*/

/* Свойство uint Prev - Get
Определяет предыдущий элемент, если он есть, иначе 0
*/
/*property LVItem LVItem.Prev
{   
   return this->gtitem.getprev()->LVItem
   //return this->gtitem.getprev()->LVItem
}*/

/* Свойство uint Next - Get
Определяет предыдущий элемент, если он есть, иначе 0
*/
/*property LVItem LVItem.Next
{    
   return this->gtitem.getnext()->LVItem
}*/

/* Свойство uint LastChild - Get
Определяет последний дочерний элемент, если он есть, иначе 0
*/
/*property LVItem LVItem.LastChild
{    
   return this->gtitem.lastchild()->LVItem
}*/

/* Свойство uint Child - Get
Определяет первый дочерний элемент данной ветки, если ветка не имеет дочерних элементов, то 0
*/
/*property LVItem LVItem.Child
{    
   uint resi as this.child()    
   return resi->LVItem 
}*/


/*
method LVItem.Update()
{  
   //uint owner as this.Parent()
   //uint after as this.Prev
   
   
   .param->listdata.listview->vListView.WinInsert( this )     
}
*/
/*method LVItem.MoveTo( LVItem dest, uint flag )
{
   
   if &this.Next() != &dest
   {  
      uint lv as .param->listdata.listview->vListView 
      lv.WinMsg( $LVM_DELETEITEM, .Idx, 0)
      
            
      this.move( dest, flag )
      this.Update()
      evparItemMoved evpIM
      evpIM.SrcItem = &this
      evpIM.DestItem = &dest
      evpIM.Flag = flag
      lv.OnItemMoved.run( evpIM )
      
   }
}*/

/* Свойство uint Selected - Get Set
Устанавливает или определяет пользовательский параметр элемента дерева
*/

/* Свойство uint Arrangeed - Get Set
Устанавливает или определяет должны ли сортироваться элементы в дереве
1 - элементы сортируются
0 - элементы не сортируются
*//*
property uint vListView.Arrangeed()
{  
   return this.pArrangeed
}

property vListView.Arrangeed( uint val)
{
   if this.pArrangeed != val
   {
      this.pArrangeed = val
      this.Root().ArrangeType = ?( val, $TVArrange_ArrangeRECURSE, $TVArrange_NONE )
      
   }
}
*/



property LVRow vListView.Selected()
{  
   return this.pSelected->LVRow//Item
}

property vListView.Selected( LVRow item )
{ 
   if this.pSelected != &item || .pOwnerData
   {
      if this.pSelected || .pOwnerData
      {
         LVITEM li
         li.stateMask = $LVIS_SELECTED         
         .WinMsg( $LVM_SETITEMSTATE, /*this.Selected.param->LVRowData.idx*/
            ?( .pOwnerData, &this.Selected, this.Selected.VisIndex ), &li )
         this.pSelected = 0
      }
      if &item || .pOwnerData
      {
      
         this.pSelected = &item
         LVITEM li
         uint visindex = ?( .pOwnerData, &this.Selected, this.Selected.VisIndex )
      //li.mask = $LVIF_STATE
      //li.iItem = item.Idx 
         
         li.stateMask = $LVIS_SELECTED | $LVIS_FOCUSED 
         li.state = $LVIS_SELECTED | $LVIS_FOCUSED
            
      //.WinMsg( $LVM_SETSELECTIONMARK, 0,  item.param->listdata.idx )
         .WinMsg( $LVM_SETITEMSTATE, /*item.param->LVRowData.idx*/visindex, &li )
         if .pEnsureVisible 
         {
            .WinMsg( $LVM_ENSUREVISIBLE, /*item.param->LVRowData.idx*/visindex, 0 )
         }
      }
      else 
      {
         //this.pSelected = &item
         /*LVITEM li
         li.stateMask = $LVIS_SELECTED         
         .WinMsg( $LVM_SETITEMSTATE, this.Selected.param->LVRowData.idx, &li )
         this.pSelected = 0*/
      }
   }
}


/*Метод vListView.iUpdateImageList()
Обновить ImageList
*/
method vListView.iUpdateImgList()
{
   .ptrImageList = &.GetImageList( .pImageList, &.numImageList )      
   if .ptrImageList
   {
      .WinMsg( $LVM_SETIMAGELIST, $LVSIL_SMALL, .ptrImageList->ImageList.arrIml[.numImageList].hIml )
      .WinMsg( $LVM_SETIMAGELIST, $LVSIL_NORMAL, .ptrImageList->ImageList.arrIml[.numImageList].hIml )
   }
   else 
   {
      .WinMsg( $LVM_SETIMAGELIST, $LVSIL_SMALL, 0 )
      .WinMsg( $LVM_SETIMAGELIST, $LVSIL_NORMAL, 0 )
   }
   .Invalidate()
}

/* Свойство str vListView.ImageList - Get Set
Устанавливает или получает имя списка картинок
*/
property ustr vListView.ImageList <result>
{
   result = this.pImageList
}

property vListView.ImageList( ustr val )
{
   if val != this.pImageList
   { 
      this.pImageList = val
      .Virtual( $mLangChanged )
      //.iUpdateImageList()
   }
}

property vListViewColumn vListView.SortedColumn()
{
   return .pSortedColumn->vListViewColumn
}

method vListView.Reload()
{
   /*uint i
   for i = *.Columns - 1, int( i ) > 0, i--
   {
      .Columns[i].Release()
   }*/
   //.ReloadGTColumn   
   /*.gtcolumns = &this.gttree.find( "columns" )
   if !.gtcolumns
   {
      .gtcolumns = &this.gttree.root().insertchild( "columns", 0->gtitem )
   }
   if !*.gtcolumns->gtitem
   {
      .gtcolumns->gtitem.insertchild( "", 0->gtitem )  
   }*//*
   uint index  
   
   foreach item, this.Comps
   {  
      item->vListViewColumn.iWinRemove()    
   }
   
   foreach item, this.Comps
   {
      //.Columns.insert( index )
      //.Columns->arr of uint[index] = &item
      //item->LVColumn.param->LVColumnData.idx = index
      item->vListViewColumn.iWinInsert()
      item->vListViewColumn.iWinUpdate( $LVCF_TEXT | $LVCF_WIDTH | $LVCF_ORDER )      
      index++
   }*/
   /*foreach item, .gtcolumns->gtitem
   {  
      .Columns.insert( index )
      .Columns->arr of uint[index] = &item
      item->LVColumn.param->LVColumnData.idx = index
      item->LVColumn.iWinInsert()
      item->LVColumn.iColumnUpdate( $LVCF_TEXT )      
      index++      
   }*/   
   uint sortedcolumn   
   if .pSortedColumn
   {  
      sortedcolumn = .pSortedColumn      
      .pSortedColumn = 0
   }
   uint index
   if !.gtrows 
   {
      .gtrows = &this.gttree.find( "rows" )      
      if !.gtrows
      {
         .gtrows = &this.gttree.root().insertchild( "rows", 0->gtitem )
      }
   }
   else
   {
      .Rows.iWinClear( 0 )
      /*int i
      for i = *.Rows - 1, i >= 0, i-- 
      {
         .Rows[i].Release()
      }*/
   }
   index = 0      
   foreach item, .gtrows->gtitem
   {   
      .Rows.insert( index )       
      .Rows->arr of uint[index] = &item
      uint data as new( LVRowData )->LVRowData      
      item.param = &data
      data.pRows = &.Rows
      data.idx = index
      
//      item->LVRow.param->LVRowData.idx = index
      item->LVRow.iWinInsert()             
      item->LVRow.iWinUpdate( 0 )            
      index++      
   }
   if sortedcolumn
   {        
      sortedcolumn->vListViewColumn.iSortUpdate()
   }
   if *.Rows
   {
      .Selected = .RowFromVisIndex(0)//.Rows[0]
   } 
   else
   {
      .pSelected = 0
   }
}


method vListView.FromGt( gtitem srcgtitem )
{
   str tmp
   gtsave gts   
   gts.offstep = 3
   uint src
   src as srcgtitem.findrel( "/rows" )
   if &src 
   {
    //src as srcgtitem 
   
   src.save( tmp, gts )
   
   if .gtrows : .gtrows->gtitem.del()
   //.gtrows = &this.gttree.root().insertchild( "rows", 0->gtitem )
      
   .gttree.root().load( tmp, 0->gtitem )
   
   .Reload()   
   
   }
}



method vListView.ConnectGt( gtitem gtrows )
{
   int i
   /*for i = *.Rows - 1, i >= 0, i-- 
   {
      .Rows[i].Release()
   }
   */
   .Rows.iWinClear( 0 )
   
   if !.fConnectGt
   {
      .gtrows->gtitem.del()
      .gtrows = 0
   }
   /*else
   {
      
   }*/
   
   /**/   
   if &gtrows 
   {
      .gtrows = &gtrows
      .fConnectGt = 1
   }
   else
   {
      .gtrows = 0
      .fConnectGt = 0  
   }
   .Reload()
}

method vListView.DisconnectGt( )
{
   
   if .fConnectGt : .ConnectGt( 0->gtitem)
   //.gtrows = 0
}


method vListView.ToGt()
{
}

method vListView.DelSelected()
{
   int i
   for i = *.Selection-1, i >= 0, i--
   {
      .Selection[i].Del()
   }
}

/*------------------------------------------------------------------------------
   Virtual Methods
*/
method vListView.mInsert <alias=vListView_mInsert>( vListViewColumn item )
{
   if item.TypeIs( vListViewColumn )
   {
      this->vCtrl.mInsert( item )
      item.pOrder = item.CompIndex
      .arOrder.insert(item.pIndex)       
      .arOrder[item.pIndex] = &item          
      item.iWinInsert()               
   }
}

method vListView.mRemove <alias=vListView_mRemove>( vListViewColumn item )
{  
   item.iWinRemove()
   this->vCtrl.mRemove( item )
}

method vListView.mPreDel <alias=vListView_mPreDel>()
{  
   .DisconnectGt()
   this->vCtrl.mPreDel()
}
/*Виртуальный метод vListView vListView.mCreateWin - Создание окна
*/
method vListView vListView.mCreateWin <alias=vListView_mCreateWin>()
{
   uint exstyle 
   uint style =  $WS_CHILD | $WS_CLIPSIBLINGS | .pListViewStyle | $WS_TABSTOP
   if .pOwnerData : style |= $LVS_OWNERDATA
   if !.pShowHeader : style |= $LVS_NOCOLUMNHEADER
   if !.pMultiSelect : style |= $LVS_SINGLESEL
   if .pShowSelection : style |= $LVS_SHOWSELALWAYS
 //  style |= $LVS_SORTASCENDING 
   if .pLabelEdit     : style |= $LVS_EDITLABELS
      
   if .pBorder : exstyle |= $WS_EX_CLIENTEDGE    
   this.CreateWin( "SysListView32".ustr(), exstyle, style )         
   
   this->vCtrl.mCreateWin()     

   uint listexstyle 
   if .pHeaderDragDrop : listexstyle |= $LVS_EX_HEADERDRAGDROP 
   if .pRowSelect : listexstyle |= $LVS_EX_FULLROWSELECT
   if .pCheckBoxes : listexstyle |= $LVS_EX_CHECKBOXES
   if .pGridLines : listexstyle |= $LVS_EX_GRIDLINES
   listexstyle |= $LVS_EX_SUBITEMIMAGES | $LVS_EX_INFOTIP   
   if listexstyle : this.WinMsg( $LVM_SETEXTENDEDLISTVIEWSTYLE, listexstyle, listexstyle ) 
    
   /*LVCOLUMN col
   col.mask = $LVCF_SUBITEM
   this.WinMsg( $LVM_INSERTCOLUMNW, 0, &col )*/
   LVCOLUMN lvc
   uint index = 0
   lvc.mask = $LVCF_SUBITEM | $LVCF_TEXT
   lvc.iSubItem = 0  
   lvc.pszText = "".ustr().ptr()
   .WinMsg( $LVM_INSERTCOLUMNW, 0, &lvc )
   uint i   
   //for i = *.Columns - 1, int( i ) >= 0, i--
   fornum i = 0, *.Columns
   {      
      .Columns[i].iWinInsert( )
   }   
   .Reload()   
   .iUpdateImgList()   
   /*if .pCheckBoxes 
   {        
      .Rows[0][0].iWinUpdate( $LVIF_STATE )
   }*/                                                                  
   return this
}

method vListView vListView.mOwnerCreateWin <alias=vListView_mOwnerCreateWin>()
{
   .Virtual( $mReCreateWin )
   return this
}

/*method uint vListView.wmnotify <alias=vListView_wmnotify>( winmsg wmsg )
{
   
   uint nmcd as wmsg.lpar->NMCUSTOMDRAW
   if nmcd.hdr.code == $NM_CUSTOMDRAW
   {            
      if nmcd.dwDrawStage == 0x00000001
      {  
       //  print ("ntf\n" )
         
         wmsg.flags = 1 
         return 0x00000020
      }
      elif nmcd.dwDrawStage == 0x00010001
      {
      //print ("ntf\n" )
      wmsg.flags = 1
      pDrawThemeBackground->stdcall( ThemeData[( $theme_toolbar )], nmcd.hdc, $BP_PUSHBUTTON, $PBS_HOT, nmcd.rc, 0 )
      //FillRect( nmcd.hdc, nmcd.rc, GetSysColorBrush(13)  )   
      //SetBkColor(nmcd.hdc,0xff00)
      //SetTextColor(nmcd.hdc,0xff)       
      return 0x4
      }
      return 1
   }
   
   return 0
}*/

/*Виртуальный метод uint vListView.mWinNtf - обработка сообщений
*/
global {
  ustr utt
}
method uint vListView.mWinNtf <alias=vListView_mWinNtf>( winmsg wmsg )//NMHDR ntf )
{
   
   uint nmlv as wmsg.lpar->NMLISTVIEW //ntf->NMLISTVIEW
   
   if wmsg.hwnd == .hwnd 
   {  
      return 1
   }
      
   switch nmlv.hdr.code
   {      
      /*case $NM_CUSTOMDRAW
      {
         print ("NTF \(nmlv.hdr.code)\n" )
         wmsg.flags = 1 
         return 0x00000004     
      }*/
      case $HDN_BEGINTRACKW
      {       
         if !.Columns[nmlv.iItem].pVisible
         {
            wmsg.flags = 1
         }   
         return 1
      }      
      case $HDN_ENDTRACKW
      {         
         nmlv as NMHEADER
         if (nmlv.iItem < *.Columns) && (nmlv.pitem->HDITEM.mask & 1 )//HDI_WIDTH
         {             
            .Columns[nmlv.iItem].pWidth = nmlv.pitem->HDITEM.cxy//.WinMsg( $LVM_GETCOLUMNWIDTH, nmlv.iItem )
//            print( "cols \(wmsg.hwnd) \(nmlv.pitem->HDITEM.lParam) \(nmlv.pitem->HDITEM.iOrder) \(nmlv.pitem->HDITEM.mask) \(.Columns[nmlv.iItem].Name) \(.Columns[nmlv.iItem].pWidth)\n" )
            return 1            
         }
      }   
   }   
   
   switch nmlv.hdr.code
   {   
      /*case $HDN_TRACKW
      {      
         //wmsg.flags = 1
         nmlv as NMHEADER
         nmlv.iItem--  
         return 1  
      }*/
      case $HDN_ENDDRAG
      {
         .fUpdateOrders = 1
      }
      case $NM_RELEASEDCAPTURE
      {
         if .fUpdateOrders 
         {
            .iGetColumnOrders()
            .fUpdateOrders = 0
         }  
      }
      /*case $LVN_ITEMACTIVATE
      {  
         nmlv as NMITEMACTIVATE
         this.pSelected = ?( nmlv.lParam, nmlv.lParam, 0 )//?( nmlv.itemNew, nmlv.itemNew.lParam, 0 )
         //.OnSelect.Run( this, etvb )
      }*/      
      case $LVN_ODSTATECHANGED
      {  
         if .pOwnerData
         {            
            nmlv as NMLVODSTATECHANGE            
            uint i                        
            if ( nmlv.uOldState & $LVIS_SELECTED ) && !(nmlv.uNewState & $LVIS_SELECTED)
            {  
               fornum i = nmlv.iFrom, nmlv.iTo + 1
               {
                  .Selection.iRemove( i->LVRow )  
               }               
            }     
            elif !( nmlv.uOldState & $LVIS_SELECTED ) && (nmlv.uNewState & $LVIS_SELECTED)
            {  
               fornum i = nmlv.iFrom, nmlv.iTo + 1
               {
                  .Selection.iAppend( i->LVRow )
               }
            }
            evparValUint etva         
            etva.val = this.pSelected
            etva.sender = &this
            .OnAfterSelect.Run( /*this,*/ etva )
         }
      }
      case $LVN_ITEMCHANGED 
      {
         if ( nmlv.uOldState & $LVIS_SELECTED ) && !(nmlv.uNewState & $LVIS_SELECTED)
         {  
            //.Selection.iRemove( .Rows[nmlv.iItem] )
            if .pOwnerData 
            {               
               if nmlv.iItem == -1
               {
                  
                  .Selection.Items.clear()
               }
               else
               {
                  .Selection.iRemove( nmlv.iItem->LVRow )
               }  
            }
            else 
            {
               if nmlv.lParam : .Selection.iRemove( nmlv.lParam->LVRow )
            }
         }     
         elif !( nmlv.uOldState & $LVIS_SELECTED ) && (nmlv.uNewState & $LVIS_SELECTED)
         {  
            //.Selection.iAppend( .Rows[nmlv.iItem] )
            if .pOwnerData 
            {            
               if nmlv.iItem == -1
               {
                  .Selection.Items.clear()
                  uint i
                  fornum i = 0, *.Rows
                  { 
                     .Selection.iAppend( i->LVRow )
                  }
               }
               else
               {
                  .Selection.iAppend( nmlv.iItem->LVRow )
               }  
            }
            else 
            {
               if nmlv.lParam : .Selection.iAppend( nmlv.lParam->LVRow )
            }
         }
         if !( nmlv.uOldState & $LVIS_SELECTED ) && nmlv.uNewState & $LVIS_SELECTED
         //if nmlv.uOldState & $LVIS_SELECTED != ( nmlv.uNewState & $LVIS_SELECTED ) 
         {
            /*LVITEM li
            li.iItem = .WinMsg( $LVM_GETNEXTITEM, -1, $LVNI_SELECTED )
            li.mask = $LVIF_PARAM 
            .WinMsg( $LVM_GETITEMW, 0, &li )*/
            if nmlv.iItem != -1
            {
               if .pOwnerData : this.pSelected = nmlv.iItem
               else : this.pSelected = nmlv.lParam///*&.Rows[li.iItem]//*/li.lParam              
            
            evparValUint etva         
            etva.val = this.pSelected
            etva.sender = &this
            .OnAfterSelect.Run( /*this,*/ etva )
            }
         }         
         if ( nmlv.uOldState & $LVIS_STATEIMAGEMASK ) != ( nmlv.uNewState & $LVIS_STATEIMAGEMASK )
         { 
            if nmlv.iItem < *.Rows
            {            
               //.Rows[nmlv.iItem][0].setuint( "stateindex", ( nmlv.uNewState & $LVIS_STATEIMAGEMASK ) >> 12 )
               if !.flgRowInserting
               { 
                  nmlv.lParam->LVRow[0].setuint( "stateindex", ( nmlv.uNewState & $LVIS_STATEIMAGEMASK ) >> 12 )
                  evparValUint etva
                  etva.val = nmlv.lParam
                  etva.sender = &this
                  .OnChanged.Run( etva )  
               }
            }
         }         
        /* this.pSelected = ?( nmlv.itemNew, nmlv.itemNew.lParam, 0 )
         
         eventTVAfter etva         
         etva.CurItem = this.pSelected      
         .OnBeforeSelect.Run( this, etva )*/
      }
      
      case $LVN_ITEMCHANGING 
      {
         if nmlv.uChanged & $LVIF_STATE 
         {
            //wmsg.flags = 1
         return 0
         }
 
         /*if nmlv.uChanged & $LVIF_STATE 
         {
            if nmlv.uOldState & $LVIS_SELECTED != ( nmlv.uNewState & $LVIS_SELECTED )
            {
               evparTVBefore etvb
               etvb.CurItem = nmlv.lParam
               .OnBeforeSelect.Run(  etvb )
            }
         }*/
       /*  
            \n" )
            LVITEM li
            li.iItem = .WinMsg( $LVM_GETNEXTITEM, -1, $LVNI_SELECTED )
            li.mask = $LVIF_PARAM 
            .WinMsg( $LVM_GETITEMW, 0, &li )
            return 0
         if nmlv.uOldState & $LVIS_FOCUSED && !( nmlv.uNewState & $LVIS_FOCUSED )
         {
            .flgItemChanging = 1
         }
         
         elif nmlv.uOldState & $LVIS_SELECTED && !( nmlv.uNewState & $LVIS_SELECTED )
         {
            evparTVBefore etvb
            if .flgItemChanging
            {
               etvb.CurItem = nmlv.lParam
            }          
            else
            {
               etvb.CurItem = 0
            }
            .flgItemChanging = 0
            .OnBeforeSelect.Run(  etvb )
            return etvb.flgCancel
         }
            */      
      }
      /*case $TVN_ITEMEXPANDEDW
      {
         if nmlv.action & ( $TVE_COLLAPSE | $TVE_EXPAND )
         {
            nmlv.itemNew.lParam->LVItem.setuint( "expanded", nmlv.action & $TVE_EXPAND )            
         }
         
      }
      case $TVN_ITEMEXPANDINGW
      {
      }*/
      case $LVN_BEGINLABELEDITW
      {
         evparTVEdit etve  
         etve.sender = &this       
         .OnBeforeEdit.Run( etve )
         return etve.flgCancel
      }
      case $LVN_ENDLABELEDITW
      {
         nmlv as NMLVDISPINFO
         
         evparTVEdit etve
         if nmlv.item.pszText
         {
            etve.NewLabel.copy( nmlv.item.pszText )     
         }
         else
         {
            etve.flgCancel = 1
         }
         
         
         etve.sender = &this
         .OnAfterEdit.Run( /*this,*/ etve )         
         if !etve.flgCancel 
         {          
            uint selected as .Selected
            if &selected
            { 
               
               selected.set( "name", etve.NewLabel.toutf8( "" ) )
            }            
            return 1
         }         
      }
      case $LVN_BEGINDRAG
      {          
         //.Selected = nmlv.lParam->LVItem
         /*LVITEM lvitem
         lvitem.stateMask = $LVIS_SELECTED
         .WinMsg( $LVM_SETITEMSTATE, .Selected.param->LVRowData.idx, &lvitem )                           
         */
         if .pAutoDrag && !.pSortedColumn
         {
            SetCapture( .hwnd ); 
            .fDrag = 1
         }  
         else
         {          
            .OnBeginDrag.Run(this)
         }
             
      }
      case $LVN_COLUMNCLICK
      {
         evparQuery evq
         evq.val = nmlv.iSubItem
         .OnColumnClick.Run( evq, this )
         if !evq.flgCancel
         {
            uint curcolumn as .Columns[nmlv.iSubItem]
            uint sort = 0
            if sort = curcolumn.pSorted
            {
               if sort == $lvsortDown : sort = $lvsortUp
               else : sort = $lvsortDown                  
            } 
            else
            {               
               sort = curcolumn.pDefSorted
               if !sort : sort = $lvsortDown               
            }            
            curcolumn.Sorted = sort            
         }         
      }
      case $LVN_GETDISPINFOW
      {         
ifdef !$DESIGNING {
         nmlv as NMLVDISPINFO
         if .Columns[nmlv.item.iSubItem].pVisible
         {            
            evparValColl evc
            utt.clear()
            evc.val = %{ nmlv.item.iItem, nmlv.item.iSubItem, utt }
            evc.sender = &this         
            .OnGetData.Run( evc )
            //t = "getdispINfo \(nmlv.item.iItem) \(nmlv.item.iSubItem)".ustr()
            //nmlv.item.
            nmlv.item.pszText = utt.ptr()
         }
}      
         //nmlv.item.state = 0
      } 
      case $NM_CUSTOMDRAW  
      {
         uint cd as wmsg.lpar->NMLVCUSTOMDRAW
         if (.OnItemDraw.id || .OnSubItemDraw.id ) && cd.nmcd.hdr.hwndFrom == this.hwnd 
         {            
            uint resi = $CDRF_DODEFAULT;
            switch( cd.nmcd.dwDrawStage )
            {
               case $CDDS_PREPAINT
               {               
                  resi |= $CDRF_NOTIFYSUBITEMDRAW//$CDRF_NOTIFYITEMDRAW                
               }
               case $CDDS_ITEMPREPAINT | $CDDS_SUBITEM
               {  
                  cd.nmcd.dwItemSpec 
                  cd.clrTextBk = .clrTextBk  
                  cd.clrText   = .clrText    
                   
                  evparValColl evc
                  uint item
                  if .pOwnerData : item = cd.nmcd.dwItemSpec
                  else : item = cd.nmcd.lItemlParam
                  evc.val = %{ item, cd.iSubItem, cd.clrText, cd.clrTextBk, cd.nmcd.uItemState, cd.nmcd.hdc }
                  evc.sender = &this
                  if .OnSubItemDraw.Run( evc )
                  {
                     cd.clrTextBk = evc.val[2]//->uint//0xFF00
                     cd.clrText = evc.val[3]//->uint//GetSysColor(16)
                     cd.nmcd.uItemState &= ~$CDIS_SELECTED;
                  }               
               }  
               case $CDDS_ITEMPREPAINT            
               {
                  //print( "repaint \(cd.nmcd.hdr.hwndFrom) \(this.hwnd) \(cd.nmcd.dwDrawStage) \(.pOwnerData) \(cd.nmcd.dwItemSpec) \(cd.nmcd.lItemlParam)\n" )
                  evparValColl evc
                  uint item
                  if !cd.iSubItem || .pOwnerData
                  {
                     if .pOwnerData : item = cd.nmcd.dwItemSpec
                     else : item = cd.nmcd.lItemlParam
                      
                     //uint item as cd.nmcd.lItemlParam->TVItem                  
                     //if &item && item.getuint( "disabled" ) :
                     
                     if .WinMsg( $LVM_GETITEMSTATE, cd.nmcd.dwItemSpec, $LVIS_SELECTED )
                     {  
                        cd.nmcd.uItemState |= $CDIS_SELECTED
                        if GetFocus() == .hwnd//cd.nmcd.uItemState & $CDIS_FOCUS
                        {
                           cd.nmcd.uItemState |= $CDIS_FOCUS
                           cd.clrTextBk = GetSysColor(13)
                           cd.clrText = GetSysColor(5)
                        }
                        else
                        {
                           cd.clrTextBk =  GetSysColor(15) 
                           cd.clrText = GetSysColor(18)
                        } 
                     }
                     else :  cd.nmcd.uItemState &= ~$CDIS_SELECTED;
                     
                     evc.val = %{ item, cd.clrText, cd.clrTextBk, cd.nmcd.uItemState, cd.nmcd.hdc }
                     evc.sender = &this                  
                     if .OnItemDraw.Run( evc )
                     {
                        cd.clrText = evc.val[1]//0xFF00
                        cd.clrTextBk = evc.val[2]//GetSysColor(16)
                        cd.nmcd.uItemState &= ~$CDIS_SELECTED;
                     }
                     .clrTextBk = cd.clrTextBk
                     .clrText   = cd.clrText
                     if .OnSubItemDraw.id : resi = $CDRF_NOTIFYSUBITEMDRAW//$CDRF_NOTIFYITEMDRAW
                  }
               }
            }
            wmsg.flags = 1   
            return resi
         }
      } 
   }
   return 0
}

method uint vListView.mMouse <alias=vListView_mMouse>( evparMouse em )
{
   switch em.evmtype
   {
      case $evmMove
      {
         if .fDrag 
         {         
         
            POINT point
            uint destidx
            LVHITTESTINFO lvht
             
            lvht.pt.x = point.x = em.x
            lvht.pt.y = point.y = em.y
            //destidx = .WinMsg( $LVM_HITTEST, 0, &lvht)
            if ( destidx = .WinMsg( $LVM_HITTEST, 0, &lvht)) != -1// destidx != -1 && destidx != .fOldDestItem 
            {
               LVITEM lvitem
               //lvitem.mask = $LVIF_STATE
               lvitem.stateMask = $LVIS_DROPHILITED               
               .WinMsg( $LVM_SETITEMSTATE, .fOldDestItem, &lvitem ) 
               /*lvitem.state = $LVIS_DROPHILITED
               .fOldDestItem = destitem
               .WinMsg( $LVM_SETITEMSTATE, .fOldDestItem, &lvitem )               
               SetCursor( App.cursorDrag ) 
               */
               if .Selection.Find( /*.Rows[destidx]*/.RowFromVisIndex( destidx ) ) == -1
               { 
                  lvitem.state = $LVIS_DROPHILITED
                  .fOldDestItem = destidx
                  .WinMsg( $LVM_SETITEMSTATE, .fOldDestItem, &lvitem )
                  //.WinMsg( $TVM_SELECTITEM, $TVGN_DROPHILITE, dest )
                  SetCursor( App.cursorDrag )
               }
               else 
               {
                  .fOldDestItem = -1
                  //.WinMsg( $TVM_SELECTITEM, $TVGN_DROPHILITE, 0 )
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
         LVHITTESTINFO lvht
         if .fDrag
         {
         
            uint destitem as LVRow
            uint selected as .pSelected->LVRow
            
            lvht.pt.x = em.x
            lvht.pt.y = em.y
            dest = .WinMsg( $LVM_HITTEST, 0, &lvht)
            
            LVITEM lvitem         
            uint flg      
            lvitem.stateMask = $LVIS_DROPHILITED
            .WinMsg( $LVM_SETITEMSTATE, dest, &lvitem )
            .WinMsg( $LVM_SETITEMSTATE, .fOldDestItem, &lvitem )
            .fOldDestItem = -1                        
            if dest != -1 
            {            
               
               /*LVITEM item
               item.mask = $LVIF_PARAM  
               item.iItem = dest             
               .WinMsg( $LVM_GETITEMW, 0, &item )
               */
               //destitem as item.lParam->LVRow              
               //if &destitem 
               {
                  destitem as /*.Rows[ dest ]*/.RowFromVisIndex( dest )
                  flg = $TREE_BEFORE       
                  if .Selection.Find( destitem ) != -1
                  {
                     destitem as (-1)->LVRow
                  } 
                  /*foreach zitem, .Selection
                  {     
                     zitem.MoveTo( destitem, $TREE_BEFORE )
                  }*/
                  //.fMoving = 0
                  //selected.MoveTo( destitem, $TREE_BEFORE )                  
               }                             
               //.WinMsg( $TVM_SELECTITEM, $TVGN_DROPHILITE, destitem )                                        
            }
            elif int( em.x ) > 0 && int( em.y ) > 0 && em.x < .clloc.width && em.y < .clloc.height
            {
               flg = $TREE_LAST
               destitem as 0->LVRow//.Rows[*.Rows-1]               
              // selected.MoveTo( , $TREE_LAST )
            }
            //.fMoving = 1
            //uint selected as .Selected
            ReleaseCapture()      
            //destitem as LVRow
            if &destitem != -1                  
            {                 
               .Selection.Arrange()
               int i
               for i = *.Selection-1, i >= 0, i--
               //foreach item, listview.Selection
               {
                  uint curitem as .Selection[i]
                  curitem.MoveTo( destitem, flg )
                  destitem as curitem
                  flg = $TREE_BEFORE
                  //item.Del()
               }                         
               //.Selected = 0->LVRow
               //.Selected = selected
            }                        
            //ImageList_EndDrag( )            
            
            //.Selected = selected  
            //.fDrag = 0
         }
      }
   }
   return this->vCtrl.mMouse( em )   
}


method vListView.mPosChanging <alias=vListView_mPosChanging>( eventpos evp )
{ 
   this->vCtrl.mPosChanging( evp )
   /*LVCOLUMN col
   col.mask = $LVCF_WIDTH
   col.cx = this.clloc.width - 10
   this.WinMsg( $LVM_SETCOLUMNW, 0, &col ) */     
}


/*Виртуальный метод uint vListView.mLangChanged - Изменение текущего языка
*/
method uint vListView.mLangChanged <alias=vListView_mLangChanged>()
{
   .iUpdateImgList()   
   this->vCtrl.mLangChanged()
   return 0  
}


func int ListViewSort( uint item1 item2, vListViewColumn column )
{   
   uint resi
   uint lv as column.Owner->vListView
   switch column.pSortType
   { 
      case $lvstText
      {
         reserved buf1[512]
         reserved buf2[512]      
         LVITEM lvi      
         
         lvi.mask = $LVCF_SUBITEM
         lvi.cchTextMax = 256
         lvi.iSubItem = column.pIndex   
         
         lvi.pszText = &buf1   
         lv.WinMsg( $LVM_GETITEMTEXTW, item1, &lvi )   
         
         lvi.pszText = &buf2      
         lv.WinMsg( $LVM_GETITEMTEXTW, item2, &lvi )
         
         resi = CompareStringW( 0, 0, &buf1, -1, &buf2, -1 ) - 2
      }
      case $lvstValue
      {
      
         uint row1 as lv.RowFromVisIndex( item1 )
         uint row2 as lv.RowFromVisIndex( item2 )
         ustr value1, value2       
         value1.fromutf8( row1[column.Idx].value )
         value2.fromutf8( row2[column.Idx].value )            
         resi = CompareStringW( 0, 0, value1.ptr(), *value1, value2.ptr(), 
                            *value2 ) - 2                                  
      }
      case $lvstSortIndex
      {
         
      }
      case $lvstEvent
      {
         //resi = lv.OnSort()
      }
      
   }
   
   if !resi && column.pAdvSortColumn
   {  
      return  ListViewSort( item1, item2, column.pAdvSortColumn->vListViewColumn )   
   }
   
   if column.pSorted == $lvsortUp : resi = -resi
      
   return resi 
     
}

/*------------------------------------------------------------------------------
   Registration
*/
/*Системный метод vListView vListView.init - Инициализация объекта
*/   
method vListView vListView.init( )
{   
   this.pTypeId = vListView
   //this.flgXPStyle = 1  
   this.pCanFocus = 1
   this.pTabStop = 1      
   this.loc.width = 100
   this.loc.height = 25
   this.pBorder = 1
   this.pListViewStyle = $lvsReport
   this.flgReCreate = 1
   .pShowHeader = 1
   .pSortFunc = callback( &ListViewSort, 3 )
   /*this.pShowPlusMinus = 1
   this.pShowLines = 1
   this.pShowRootLines = 1
   uint itemdata as new( treedata )->treedata*/
   //itemdata.listview = &this
   //this.gttree.root().param = &itemdata
   //this.gtcolumns = &this.gttree.root().insertchild( "columns", 0->gtitem )
   
   .Columns.pListView = &this
   .ColumnsOrder.pListView = &this
/*   .Columns.Insert( 0 )*/
   
   this.gtrows = &this.gttree.root().insertchild( "rows", 0->gtitem )
   .Rows.pListView = &this
   
   .Selection.pListView = &this
   
   //this.items[0].listview = &this
   //this.items[0].gti = &this.gti.root()
   return this 
}  

method uint vListView.wmMouse <alias=vListView_wmMouse>( winmsg wmsg )
{  
   if .pShowSelection
   {
      LVHITTESTINFO info
      info.pt.x = int( ( &wmsg.lpar )->short )
      info.pt.y = int( ( &wmsg.lpar + 2 )->short )
      if .WinMsg( $LVM_HITTEST, 0, &info ) == -1
      {
         SetFocus( this.hwnd )
         //( &wmsg.lpar )->short = 5
         //( &wmsg.lpar + 2 )->short = 5
         wmsg.flags = 1
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
      else
      {
         if GetFocus() != this.hwnd : SetFocus( this.hwnd ) 
      }
   }
   return this->vCtrl.wmMouse( wmsg )
}
method uint vListView.wmcapturechange <alias=vListView_wmcapturechanged>( winmsg wmsg )
{  
   if wmsg.lpar != .hwnd && .fDrag 
   {
      SetCursor( App.cursorArrow )
      
      LVITEM lvitem            
      lvitem.stateMask = $LVIS_SELECTED
      lvitem.state = $LVIS_SELECTED    
      .WinMsg( $LVM_SETITEMSTATE, /*.Selected.Idx*/.Selected.VisIndex, &lvitem )
      //.WinMsg( $LVM_SELECTITEM, $TVGN_DROPHILITE, 0 )
      .fDrag = 0
   } 
   return 0
}

func init_vListView <entry>()
{  
   regcomp( vListView, "vListView", vCtrl, $vCtrl_last, 
      %{  %{$mCreateWin,    vListView_mCreateWin},          
          %{$mWinNtf,      vListView_mWinNtf },
          %{$mMouse,       vListView_mMouse },
          %{$mPosChanging, vListView_mPosChanging },
          %{$mInsert,      vListView_mInsert},
          %{$mRemove,      vListView_mRemove},
          %{$mPreDel,      vListView_mPreDel},
          %{$mLangChanged,  vListView_mLangChanged },
          %{$mOwnerCreateWin, vListView_mOwnerCreateWin }
         /*%{$mSetName,      vListView_mSetName}*/
      },  
       //0->collection
      %{ %{ $WM_CAPTURECHANGED, vListView_wmcapturechanged },
         %{$WM_LBUTTONDOWN,  vListView_wmMouse},
         %{$WM_LBUTTONUP,  vListView_wmMouse},         
         %{$WM_LBUTTONDBLCLK,  vListView_wmMouse},                  
         %{$WM_RBUTTONDOWN,  vListView_wmMouse},                                    
         %{$WM_RBUTTONUP,  vListView_wmMouse},          
         %{$WM_RBUTTONDBLCLK,  vListView_wmMouse}
//         %{$WM_NOTIFY  ,   vListView_wmnotify}
      }
       )
   regcomp( vListViewColumn, "vListViewColumn", vComp, $vComp_last,
      %{ %{$mLangChanged,  vListViewColumn_mLangChanged },
         %{$mPreDel,       vListViewColumn_mPreDel} },
       0->collection 
        )
         
ifdef $DESIGNING {
   cm.AddComp( vListView, 1, "Windows", "listview" )
   
   cm.AddProps( vListView, %{    
/*"TabOrder", uint, 0,
"Border", uint, 0,
"ShowPlusMinus", uint, 0,
"ShowLines", uint, 0,    
"ShowRootLines", uint, 0,*/
"GridLines", uint, 0,
"ShowSelection", uint, 0,
"ShowHeader",    uint, 0,
"ListViewStyle", uint, 0,
"HeaderDragDrop", uint, 0,
"RowSelect", uint, 0,
"CheckBoxes", uint, 0,
"LabelEdit", uint, 0,
"EnsureVisible", uint, 0,
"AutoDrag", uint, 0,
"MultiSelect", uint, 0,
"ImageList", ustr, 0,
"OwnerData", uint, 0

   }) 
   cm.AddEvents( vListView, %{
"OnBeforeEdit", "eventTVEdit",
"OnAfterEdit", "eventTVEdit",
/*"OnBeforeSelect", "",*/
//"OnGetLabel",    "evParValUint",
"OnAfterSelect", "evparValUint",
"OnBeforeMove", "evparBeforeMove",
"OnAfterMove", "evparAfterMove",
"OnColumnClick", "evQuery",
"OnGetData", "evparValColl",
"OnItemDraw", "evparValColl",
"OnSubItemDraw", "evparValColl",
"OnBeginDrag", "evparEvent"
/*"OnBeforeExpand", "",
"OnAfterExpand", "",
"OnBeforeCollapse", "",
"OnAfterCollapse", ""
*/
   })
   
   cm.AddPropVals( vListView, "ListViewStyle", %{
"lvsIcon"      ,$lvsIcon,          
"lvsReport"    ,$lvsReport,   
"lvsSmallIcon" ,$lvsSmallIcon,
"lvsList"      ,$lvsList 
   })     
}
      
}
