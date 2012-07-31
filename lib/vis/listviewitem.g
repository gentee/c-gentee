
extern {
//property ustr LVColumn.Label <result>()
property ustr LVCell.Label <result>()
method vListView.iGetColumnOrders()
property vListViewColumn.Order( uint val )
property ustr LVCell.Label <result> ()
method vListViewColumn LVColumns.Find( ustr alias )
method vListViewColumn LVColumns.index( uint idx )
method vListViewColumn.iWinUpdate( uint mask )
operator uint *( LVColumns obj )
method LVCell LVRow.FindCell( ustr alias )
method LVCell LVRow.index( uint colidx )
method LVCell.iWinUpdate( uint mask )
method uint LVRows.first( fordata tfd )
method uint LVRows.next( fordata tfd )
method uint LVRows.eof( fordata tfd )
property uint LVRow.Idx()
method LVRow LVRows.index( uint idx )
property uint LVCell.StateIndex
property uint vListViewColumn.Idx()
method LVRow.iWinUpdate( uint mask )
property uint LVRow.VisIndex
property vListViewColumn.Sorted( uint val )
}


method LVRow vListView.RowFromVisIndex( uint visindex )
{
   LVITEM lvi
   lvi.mask = $LVIF_PARAM
   lvi.iItem = visindex 
   .WinMsg( $LVM_GETITEMW, 0, &lvi )
   return lvi.lParam->LVRow   
}

method vListViewColumn.iWinInsert()
{
   if this.Owner->vListView.hwnd 
   {
      if .pIndex 
      {
         LVCOLUMN lvc
         uint index = this.pIndex//this.param->LVColumnData.idx
         lvc.mask = $LVCF_SUBITEM | $LVCF_TEXT //| $LVCF_WIDTH | $LVCF_ORDER//| $LVCF_IMAGE //| $LVCF_FMT
         //lvc.fmt = 0x8000 //$LVCFMT_COL_HAS_IMAGES | $LVCFMT_BITMAP_ON_RIGHT //| 0x400//| 0x8000 
         lvc.iSubItem = index  
         lvc.pszText = "".ustr().ptr()
         //lvc.cx = .pWidth
         //lvc.iImage = -1
         this.Owner->vListView.WinMsg( $LVM_INSERTCOLUMNW, index, &lvc )
         uint header = this.Owner->vListView.WinMsg( $LVM_GETHEADER )
         HDITEM hdi
         hdi.mask = 0x0004 | //| $HDI_FORMAT      
         hdi.fmt = 0x8000
         //SendMessage( header, 0x1204/*$HDM_SETITEM*/, index, &hdi )
      }
      .iWinUpdate( $LVCF_TEXT | $LVCF_WIDTH | $LVCF_ORDER )
   }
   //this.param->LVColumnData.pColumns->LVColumns.pListView->vListView.WinMsg( $LVM_INSERTCOLUMNW, index, &lvc )
}

method vListViewColumn.iWinRemove()
{
   if .pIndex : this.Owner->vListView.WinMsg( $LVM_DELETECOLUMN, .pIndex )
}

method vListViewColumn.iWinUpdate( uint mask )
{
   if &.Owner
   {  
      LVCOLUMN lvc
      uint listview as .Owner->vListView      
      lvc.mask = mask 
       
      if lvc.mask & $LVCF_FMT
      {
         if .pSorted == $lvsortDown : lvc.fmt = $HDF_SORTDOWN
         elif .pSorted == $lvsortUp : lvc.fmt = $HDF_SORTUP
      }      
      lvc.pszText = .pCaption->locustr.Text( this ).ptr()
      if .pVisible
      {
         lvc.cx = .pWidth
         //lvc.iOrder = .pOrder
         uint i
         fornum i=0, *listview.Columns
         {
            if listview.Columns[i].pOrder < .pOrder
            {
               if listview.Columns[i].pVisible : lvc.iOrder++
            }
         }
      }
      else 
      {
         lvc.cx = 0
         uint i         
         lvc.iOrder = *listview.Columns - 1
         //*listview.Columns - 1
      }
      
/*      if mask & $LVCF_IMAGE
      {      
         lvc.iImage = listview.ptrImageList->ImageList.GetImageIdx( listview.numImageList, .pImageId, 0 )
          print( "l \(lvc.iImage)\n" )             
      }*/    
      
       
      listview.WinMsg( $LVM_SETCOLUMNW, .pIndex, &lvc )
      
      
      //SendMessage( header, 0x1204/*$HDM_SETITEM*/, index, &hdi )
      
      /*uint header = this.Owner->vListView.WinMsg( $LVM_GETHEADER )
      HDITEM hdi
      hdi.mask = 0x0004 //| $HDI_FORMAT      
      hdi.fmt = 0x8000      
      SendMessage( header, 0x1204, .pIndex, &hdi )*/
      /*if mask & $LVCF_WIDTH 
      {
      
         listview.WinMsg( $LVM_SETCOLUMNWIDTH, .pIndex, .pWidth )   
      }*/
   }
}

method vListViewColumn.init()
{   
   this.pTypeId = vListViewColumn
   this.pWidth = 50
   this.pVisible = 1
   this.pDefSorted = $lvsortDown
   //this.pAutoLang = 0
}



method vListViewColumn LVColumns.index( uint idx )
{  
   uint listview as .pListView->vListView
   if &listview
   {
      return listview.Comps[idx]->vListViewColumn
   }
   return 0->vListViewColumn
}

operator uint *( LVColumns obj )
{
   uint listview as obj.pListView->vListView
   if &listview
   {
      return *listview.Comps
   }
   return 0
}

method vListViewColumn LVColOrder.index( uint idx )
{  
   uint listview as .pListView->vListView
   if &listview && idx < *.pListView->vListView.Columns
   {
      return listview.arOrder[idx]->vListViewColumn
   }
   return 0->vListViewColumn
}

method vListViewColumn LVColumns.Append()
{  
   uint listview as .pListView->vListView
   uint item as vListViewColumn
   if &listview
   {
      item as listview.CreateComp( vListViewColumn )->vListViewColumn
      item.Order = item.pIndex 
   }
   return item   
}

method vListViewColumn LVColumns.Insert( uint index )
{  
   uint listview as .pListView->vListView
   uint item as vListViewColumn
   if &listview
   {
      item as listview.CreateComp( vListViewColumn )->vListViewColumn            
      item.CompIndex = index      
      //listview.iGetColumnOrders()            
      listview.Reload()     
      item.Order = index 
   }
   return item   
}


method LVColumns.Clear()
{   
   uint listview as .pListView->vListView
   if &listview
   {
      listview.DelChildren()//CreateComp( vListViewColumn )->vListViewColumn            
      //item.CompIndex = index      
      //listview.iGetColumnOrders()            
      //listview.Reload()     
      //item.Order = index 
   }     
}


/*
method LVColumn LVColumns.Insert( uint index )
{
   uint item
   uint data
   index = min( index, *this )
   this.insert( index )
   item as .pListView->vListView.gtcolumns->gtitem.insertchild( "", ?( index, this[index-1], 0 )->gtitem )->LVColumn
   this->arr of uint [index] = &item
   data as new( LVColumnData )->LVColumnData
   item.param = &data
   data.pColumns = &this
   data.idx = index
   
   item.iWinInsert()  
   return item
}
*/

/*


method LVColumn.Release()
{   
   if .param
   {      
      uint data as .param->LVColumnData
      uint columns as data.pColumns->LVColumns
      uint listview as columns.pListView->vListView
      
      columns.del( data.idx )
      listview.WinMsg( $LVM_DELETECOLUMN, data.idx )    
      
      destroy( &data )
      .param = 0
   }
}

method LVColumn.Del()
{
   .Release()
   .del()   
}
*/
/* Свойство ustr Label - Get Set
Устанавливает или определяет заголовок колонки
*/
property ustr vListViewColumn.Caption <result>
{ 
   result = this.pCaption.Value
}

property vListViewColumn.Caption( ustr val )
{
   if val != this.pCaption.Value
   {       
      this.pCaption.Value = val      
      .iWinUpdate( $LVCF_TEXT )
   }   
}

/* Свойство ustr Alias - Get Set
Устанавливает или определяет псевдоним колонки
*/
property ustr vListViewColumn.Alias <result>
{ 
   result = this.pAlias
}

property vListViewColumn.Alias( ustr val )
{
   if this.pAlias != val
   {
      this.pAlias = val
   }   
}
/*

property uint LVColumn.Idx()
{
   if .param : return .param->LVColumnData.idx
   return -1
}

property vListView LVColumn.ListView()
{
   if .param : return .param->LVColumnData.pColumns->LVColumns.pListView->vListView
   return 0->vListView
}
*/
/* Свойство uint Width - Get Set
Устанавливает или определяет псевдоним колонки
*/
property uint vListViewColumn.Width
{ 
   return .pWidth
}

property vListViewColumn.Width( uint val )
{   
   if .pWidth != val
   {
      .pWidth = val
      .iWinUpdate( $LVCF_WIDTH )
   }   
}


/* Свойство uint Order - Get Set
Устанавливает или определяет порядковый номер колонки при отображении
*/
method vListView.iGetColumnOrders()
{
   arr arcol[*.Columns] of uint
   uint i
   LVCOLUMN lvc
   
   .WinMsg( $LVM_GETCOLUMNORDERARRAY, *.Columns, arcol.ptr() )
   fornum i, *.Columns
   {
     // print( "xxx= \(i) \( arcol[i] )\n" )
      uint col as .Columns[arcol[i]]
      col.pOrder = i
      .arOrder[i] = &col
   }
   
   /*lvc.mask = $LVCF_ORDER
   fornum i, *.Columns
   {  
      uint col as .Columns[i]       
      if col.pVisible
      {
         .WinMsg( $LVM_GETCOLUMNW, i, &lvc )               
         col.pOrder = lvc.iOrder
      }
      .arOrder[col.pOrder] = &col
   } */    
}

/* Свойство uint Visible - Get Set
Устанавливает или определяет видимость колонки
*/
property uint vListViewColumn.Visible
{ 
   return .pVisible
}

property vListViewColumn.Visible( uint val )
{  
   if .pVisible != val
   {
      .pVisible = val
      /*if val
      {
      print( "ins1\n" )
      .iWinInsert()*/
      .iWinUpdate( $LVCF_WIDTH | $LVCF_ORDER )
      .Owner->vListView.iGetColumnOrders()
      /*print( "ins2\n" )
      }
      else
      {
         print( "rm1\n" )
         .iWinRemove()
         print( "rm2\n" )
      }*/
   }   
}


property uint vListViewColumn.Order
{ 
   return .pOrder
}

property vListViewColumn.Order( uint val )
{   
   if .pOrder != val
   {
      .pOrder = val
      .iWinUpdate( $LVCF_ORDER )
      .Owner->vListView.iGetColumnOrders()
      .Owner->vListView.Invalidate()
   }   
}

/* Свойство str vListViewColumn.Image - Get Set
Усотанавливает или получает картинку
*/
/*property ustr vListViewColumn.ImageId <result>
{
   result = this.pImageId
}

property vListViewColumn.ImageId( ustr val )
{
   if val != .pImageId
   { 
      .pImageId = val
      //.iUpdateImage()
      .iWinUpdate( $LVCF_IMAGE | $LVCF_TEXT  )      
   } 
}
*/

/* Свойство str vListViewColumn.AdvSortColumn - Get Set
Указатель на колонку для дополнительной сортировки
*/
property vListViewColumn vListViewColumn.AdvSortColumn
{
   return this.pAdvSortColumn->vListViewColumn
}

property vListViewColumn.AdvSortColumn( vListViewColumn val )
{
   if &val != .pAdvSortColumn
   {  
      if &val
      {         
         uint next = &val
         uint lv as .Owner
         while next
         {
            if &next->vListViewColumn.Owner != &lv || next == &this : return
            next = next->vListViewColumn.pAdvSortColumn
         }
      }
      .pAdvSortColumn = &val                  
   } 
}



// Свойство str vListViewColumn.Sorted - Get Set
//Сортировка колонки
//
property uint vListViewColumn.Sorted 
{
   return this.pSorted
}

method vListViewColumn.iSortUpdate()
{
   if .pSorted
   {
      uint lv as .Owner->vListView
      if lv.pSortedColumn && 
         lv.pSortedColumn != &this
      {
         lv.pSortedColumn->vListViewColumn.Sorted = 0          
      }         
      lv.pSortedColumn = &this
      lv.WinMsg( $LVM_SORTITEMSEX, &this, lv.pSortFunc ) 
   }           
}

property vListViewColumn.Sorted( uint val )
{
   if val != .Sorted
   {  
      if .pSortType
      {
         .pSorted = val
         .iWinUpdate( $LVCF_FMT )
         .iSortUpdate()
      }
   }
}

// Свойство str vListViewColumn.DefSorted - Get Set
//Сортировка колонки по умолчанию
//
property uint vListViewColumn.DefSorted 
{
   return this.pDefSorted
}

property vListViewColumn.DefSorted( uint val )
{
   if val != .DefSorted
   {       
      .pDefSorted = val
                 
   }

}


/* Свойство str vListViewColumn.SortType - Get Set
Тип сортировки колонки
*/
property uint vListViewColumn.SortType
{
   return this.pSortType
}

property vListViewColumn.SortType( uint val )
{
   if val != .pSortType
   { 
      .pSortType = val            
   }
   //.iUpdateImage()
 /*        
      this.pCaption.Value = val
      .iUpdateCaption()
      .iUpdateSize()      
   }*/ 
}
/*
method LVColumn LVColumns.GetColumn( ustr alias )
{
   uint i
   fornum i = 0, *this
   {
      uint column as this[i]
      if column.Alias == alias : return column             
   }
   return 0->LVColumn  
}

method uint LVColumns.IndexFromAlias( ustr alias )
{
   uint column as .GetColumn( alias )
   if &column
   {
      return column.Idx()
   }
   return -1
}
*/

method LVRow.iWinInsert()
{
   LVITEM lvi
   uint index = this.param->LVRowData.idx
   lvi.mask = /*$LVCF_SUBITEM |*/ $LVCF_TEXT | $LVIF_PARAM
   lvi.iItem = index  
   lvi.pszText = "ssss".ustr().ptr()
   lvi.lParam = &this   
   with this.param->LVRowData.pRows->LVRows.pListView->vListView
   {
      .flgRowInserting = 1
      .WinMsg( $LVM_INSERTITEMW, 0, &lvi )
      .flgRowInserting = 0
   }
}


method LVRows.init()
{
   //this->arr.oftype( LVRow )
}
method LVRow LVRows.index( uint idx )
{
   return this->arr of uint[idx]->LVRow
}

method LVRow LVRows.Insert( uint index, gtitem srcitem )
{   
   uint item as LVRow
   uint data
   index = min( index, *this )
   this.insert( index )
   uint after as ?( index, this[index-1], 0 )->gtitem
   uint listview as .pListView->vListView   
         
   if &srcitem : item as listview.gtrows->gtitem.copy( srcitem, after )->LVRow
   else : item as listview.gtrows->gtitem.insertchild( "", after )->LVRow
    
   this->arr of uint[index] = &item  
  
   data as new( LVRowData )->LVRowData  
   item.param = &data
   data.pRows = &this
   data.idx = index
   
   uint i
   fornum i = index + 1, *this
   {
      this[i].param->LVRowData.idx++
   }
   
   item.iWinInsert()  
   if &srcitem : item.iWinUpdate( 0 )
   if !&listview.Selected: listview.Selected = item
   return item
}

method LVRow LVRows.Insert( uint index )
{
   return .Insert( index, 0->gtitem )
}

method LVRow LVRows.Append( gtitem srcitem )
{
   return .Insert( *this, srcitem )
}

method LVRow LVRows.Append()
{
   return .Insert( *this, 0->gtitem )
}

method LVRows.SetCount( uint count )
{
   uint listview as .pListView->vListView
   
   if listview.pOwnerData
   {
      listview.WinMsg( $LVM_SETITEMCOUNT, count, $LVSICF_NOSCROLL )
   } 
}

operator uint *( LVRows obj )
{
   if obj.pListView->vListView.pOwnerData
   {
      return obj.pListView->vListView.WinMsg( $LVM_GETITEMCOUNT )
   }
   else : return *obj->arr
   
}



method LVRow.iWinUpdate( uint mask )
{
   if .param
   {  
      LVRow lvr    
      uint data as .param->LVRowData
      uint rows as data.pRows->LVRows
      uint listview as rows.pListView->vListView
      uint columns as listview.Columns
      uint i
      fornum i, *columns
      { 
         uint cell as LVCell      
         if *columns[i].Alias 
         {   
            cell as .FindCell(columns[i].Alias)
/*                      
            uint cell as .findrel( "/" + columns[i].Alias.str() )->LVCell
            if &cell
            {
            LVITEM lvi
            lvi.mask = $LVIF_TEXT //mask// | $LVCF_WIDTH
            lvi.iItem = data.idx      
            lvi.iSubItem = i//column.param->LVColumnData.idx 
            lvi.pszText = cell.Label->locustr.Text( listview ).ptr()            
            //lvc.cx = 100
            listview.WinMsg( $LVM_SETITEMW, 0, &lvi )
            }*/
         }
         else
         {
            cell as this[i]
         }
         //evparValUint evu
         //evu.val = &cell
         //listview.OnGetLabel.Run( evu, listview )
         
         cell.iWinUpdate( $LVIF_TEXT | $LVIF_STATE )//? ( i, 0, $LVIF_STATE ) )         
      }
      /*lvr.mask = $LVCF_TEXT//mask// | $LVCF_WIDTH
      lvr.pszText = .Label->locustr.Text( listview ).ptr()
      //lvc.cx = 100
      
      */
   }
}



method LVRow.Release()
{   
   if .param
   {      
      uint data as .param->LVRowData
      uint rows as data.pRows->LVRows
      uint listview as rows.pListView->vListView
      uint visindex = .VisIndex
      if &listview.Selected == &this
      {  
         uint newsel, newidx
         /*if data.idx < *rows - 1 : newsel as rows[data.idx + 1]
         elif data.idx > 0 : newsel as rows[data.idx - 1]
         else : newsel = 0*/
         if visindex < *rows - 1 : newidx = visindex + 1
         elif visindex > 0 : newidx = visindex - 1
         else : newidx = -1
         /*
         
         newidx = listview.WinMsg( $LVM_GETNEXTITEM, visindex, $LVNI_BELOW )
         print( "newidx1 \(newidx )\n" ) 
         if newidx == -1 
         {
             newsel = listview.WinMsg( $LVM_GETNEXTITEM, visindex, $LVNI_ABOVE )
         }
         print( "newidx2 \(newidx )\n" )*/
         if newidx == -1 : newsel = 0
         else
         {            
            listview.RowFromVisIndex( newidx ) 
         }
                                             
         listview.Selected = newsel->LVRow                
      }      
      uint i
      fornum i = data.idx + 1, *rows
      {
         rows[i].param->LVRowData.idx--
      }      
      listview.WinMsg( $LVM_DELETEITEM, visindex )
      rows.del( data.idx )
      destroy( &data )
      .param = 0
   }
}

method LVRow.Del()
{   

   .Release()
   .del()
      
}

/* Свойство uint Prev - Get
Определяет предыдущий элемент, если он есть, иначе 0
*/
property LVRow LVRow.Prev
{   
   return this->gtitem.getprev()->LVRow
   //return this->gtitem.getprev()->LVRow
}

/* Свойство uint Next - Get
Определяет предыдущий элемент, если он есть, иначе 0
*/
property LVRow LVRow.Next
{    
   return this->gtitem.getnext()->LVRow
}

property uint LVRow.VisIndex
{
   LVFINDINFO fi
   uint lv as .param->LVRowData.pRows->LVRows.pListView->vListView
   fi.flags = $LVFI_PARAM
   fi.lParam = &this 
   return lv.WinMsg( $LVM_FINDITEMW, -1, &fi )  
}

method LVRow.MoveTo( LVRow dest, uint flag )
{   

   //if &this.Next() != &dest
   {  
      uint lv as .param->LVRowData.pRows->LVRows.pListView->vListView 
      uint rows as lv.Rows
      evparBeforeMove evpB
      evpB.CurItem = &this
      evpB.DestItem = &dest      
      evpB.Flag     = flag
      lv.OnBeforeMove.run( evpB )
      if !evpB.flgCancel
      {            
         uint srcidx = .Idx
         uint destidx
         switch flag
         {
            case $TREE_BEFORE
            { 
               destidx = dest.Idx
               if destidx > srcidx : destidx--
            }
            case $TREE_AFTER
            {
               destidx = dest.Idx
               if destidx < srcidx : destidx++  
            }
            case $TREE_FIRST
            {
               destidx = 0
            }
            case $TREE_LAST
            {
               destidx = *rows - 1            
            }
         }
         lv.WinMsg( $LVM_DELETEITEM, /*.Idx*/.VisIndex, 0)
         this.move( dest, flag )
         rows.move( srcidx, destidx )
         uint i
         fornum i = min( srcidx, destidx ), max( srcidx, destidx ) + 1
         {
            rows[i].param->LVRowData.idx = i
         }
         //lv.WinMsg( $LVM_INSERTITEM, .Idx
         this.iWinInsert()
         this.iWinUpdate( 0 )
         evparAfterMove evpA
         evpA.CurItem = &this
         evpA.DestItem = &dest
         evpA.Flag = flag
         lv.OnAfterMove.run( evpA )
         if &lv.Selected == &this
         {
            lv.Selected = 0->LVRow
            lv.Selected = this
         }
      }
   }
}

method LVCell.iCheck( LVRow row )
{  
   if !.param : .param = new( LVCellData )
   .param->LVCellData.row = &row
   //.param->LVCellData.column = &.Columns[col]   
}


method LVCell LVRow.FindCell( ustr alias )
{
   uint listview as .param->LVRowData.pRows->LVRows.pListView->vListView
   uint col as listview.Columns.Find( alias )
   uint cell as .findrel( "/\(alias.str())" )->LVCell
   if !&cell 
   {
      //if &col : cell as this[col.Idx]
      //else : cell as .insertchild( alias.str(), (-1)->gtitem )
      cell as .insertchild( alias.str(), (-1)->gtitem )
   }
   if !cell.param 
   {
      cell.param = new( LVCellData )
   }
   cell.param->LVCellData.row = &this
   cell.param->LVCellData.column = &col      
   return cell
}

method LVCell LVRow.index( uint colidx )
{
   uint cell
   uint listview as .param->LVRowData.pRows->LVRows.pListView->vListView   
   if colidx < *listview.Columns
   {          
      if *listview.Columns[colidx].Alias
      {
         return .FindCell( listview.Columns[colidx].Alias )
      }      
      uint idx
      foreach cell, this
      {         
         if idx == colidx
         {         
            if !cell.param 
            {
               cell.param = new( LVCellData )
            }            
            cell.param->LVCellData.row = &this
            cell.param->LVCellData.column = ?( colidx < *listview.Columns, &listview.Columns[ colidx ], 0 )
            return cell->LVCell
         }
         idx++
      }
      //cell as (-1)->LVCell
   }
   elif !colidx
   {
      cell as .child()
      if !&cell
      {
         cell as .insertchild( "", (-1)->gtitem )
      }
      if !cell.param 
      {
         cell.param = new( LVCellData )
      }
      cell.param->LVCellData.row = &this
      cell.param->LVCellData.column = ?( colidx < *listview.Columns, &listview.Columns[ colidx ], 0 )
      return cell->LVCell  
   } 
    
   return (-1)->LVCell
      /*
   fornum idx, colidx + 1
   {
      str alias
      if idx < *listview.Columns
      {
         alias = listview.Columns[idx].pAlias.str() 
      }      
      cell as .insertchild( alias, cell )      
   }
label end   
   if !cell.param 
   {
      cell.param = new( LVCellData )
   }
   cell.param->LVCellData.row = &this
   cell.param->LVCellData.column = ?( colidx < *listview.Columns, &listview.Columns[ colidx ], 0 )      
   return cell*/
}

method LVCell vListView.Cells( uint rowidx, uint colidx )
{
   if rowidx < *.Rows
   {  
      uint row as .Rows[rowidx]
      return row[ colidx ]
   }
   return 0->LVCell
   /*
   uint row as .Rows[rowidx]
   //return 0->LVCell
      
   uint item as gtitem
   if *.Columns && *.Columns[colidx].Alias
   {   
      item as row.findrel( "/\(.Columns[colidx].Alias.str())" )
      if !&item
      {
         item as row.insertchild( .Columns[colidx].Alias.str(), (-1)->gtitem )
      }
   }
   else
   {
         uint idx 
         foreach item, row
         {
            if idx == colidx
            {
               goto end
            }
            idx++
         }
         fornum idx, colidx + 1
         {
            item as row.insertchild( "", item )
         }
   }
label end
   if !item.param : item.param = new( LVCellData )
   item.param->LVCellData.row = &row
   if *.Columns
   {
      item.param->LVCellData.column = &.Columns[colidx]      
   }
   else : item.param->LVCellData.column = 0
   return item->LVCell*/
}


method LVCell.iWinUpdate( uint mask )
{
   if .param 
   {
      LVITEM lvi    
      uint data as .param->LVCellData
      uint row as data.row->LVRow
      uint listview as row.param->LVRowData.pRows->LVRows.pListView->vListView
      
      lvi.pszText = .Label.ptr()
      if data.column
      {
         uint column as data.column->vListViewColumn
         lvi.iSubItem = column.pIndex//param->LVColumnData.idx
         if column.pUseLanguage 
         {
            lvi.pszText = .Label->locustr.Text( listview ).ptr()
         }
      }
      else  
      {
         lvi.iSubItem = 0         
      }
               
      uint tname
      ustr imgname   
      tname as .get( "image" )
      if &tname
      {      
         imgname.fromutf8( tname )
         lvi.iImage = listview.ptrImageList->ImageList.GetImageIdx( listview.numImageList, imgname, uint( .get( "disabled", "" ) ) )
      }                   
      else : lvi.iImage = -1  
      //lvi.iImage = 8     
      //print( "WinUpdate \(&listview) \( lvi.iItem) \( lvi.iSubItem ) \(.Label->locustr.Text( listview ).str()) \n" )
      
      lvi.mask = $LVIF_TEXT | $LVIF_IMAGE//mask// | $LVCF_WIDTH
      if !lvi.iSubItem
      {     
         lvi.mask |= $LVIF_STATE
         lvi.stateMask |= $LVIS_STATEIMAGEMASK
         if listview.pCheckBoxes
         {
            uint state = .StateIndex()            
            if !state : state = 1
            lvi.state = state << 12 
         }
      }      
      //lvi.mask |= $LVIF_STATE
      lvi.iItem = row.VisIndex/*row.param->LVRowData.idx*/
      //lvc.cx = 100      
      listview.WinMsg( $LVM_SETITEMW, lvi.iItem, &lvi )
      if listview.pSortedColumn
      {  
         listview.pSortedColumn->vListViewColumn.iSortUpdate()
      }
   }
}

property vListViewColumn LVCell.Column()
{
   if .param
   {        
      return .param->LVCellData.column->vListViewColumn
   }
   return 0->vListViewColumn
}
/* Свойство ustr Label - Get Set
Устанавливает или определяет заголовок колонки
*/
property ustr LVCell.Label <result>
{ 
   uint name as .get( "label" )     
   if &name
   {
      result.fromutf8( name ).ptr()
   }        
}

property LVCell.Label( ustr val )
{   
   .set( "label", val.toutf8( "" ) )   
   .iWinUpdate( $LVIF_TEXT )   
}

/* Свойство ustr vToolBarItem.ImageId - Get Set
Устанавливает или получает картинку
*/
property ustr LVCell.ImageId <result>
{
   result.fromutf8( .get( "image" ) ).ptr()
}

property LVCell.ImageId( ustr val )
{
   //if val != "".ustr().fromutf8( .get( "image" ) )
   { 
      .set( "image", val.toutf8( "" ) )
      .iWinUpdate( $LVIF_IMAGE  )     
   }   
}


/* Свойство uint StateIndex - Get Set
Устанавливает или определяет состояние ячейки
*/
property uint LVCell.StateIndex
{ 
   return .getuint( "stateindex" )
}

property LVCell.StateIndex( uint val )
{
   .setuint( "stateindex", val )
   .iWinUpdate( $LVIF_STATE )
}


/* Свойство uint StateIndex - Get Set
Устанавливает или определяет состояние ячейки
*/
property uint LVRow.Checked()
{    
   uint state = this[0].StateIndex
   if state : state--
   return state
}

property LVRow.Checked( uint val )
{   
   this[0].StateIndex = val + 1  
}

/* Свойство ustr Tag - Get Set
Устанавливает или определяет заголовок колонки
*/
property uint LVCell.Tag 
{ 
   return .getuint( "tag" )
}

property LVCell.Tag( uint val )
{
   .setuint( "tag", val )   
}

property uint LVRow.Tag 
{ 
   return .getuint( "tag" )
}

property LVRow.Tag( uint val )
{
   .setuint( "tag", val )   
}

property LVCell LVRow.Item()
{
   if .param
   {      
      return .param->LVRowData.pRows->LVRows.pListView->vListView.Cells( .param->LVRowData.idx, 0 )      
   }
   return 0->LVCell
}

/* Свойство ustr Label - Get Set
Устанавливает или определяет заголовок колонки
*/
/*property ustr LVRow.Label <result>
{ 
   uint name as .get( "label" )     
   if &name
   {
      result.fromutf8( name ).ptr()
   }        
}

property LVRow.Label( ustr val )
{
   .set( "label", val.toutf8( "" ) )
   .iRowUpdate( $LVCF_TEXT )
}*/
property uint LVRow.Idx()
{
   if .param
   {
      return .param->LVRowData.idx
   }
   return 0 
}


operator uint *( LVSelection obj )
{
   if obj.pListView->vListView.hwnd
   {
      return obj.pListView->vListView.WinMsg( $LVM_GETSELECTEDCOUNT )
   }
   return 0   
}


method uint LVSelection.eof( fordata tfd )
{
   return tfd.icur >= *.Items
}


method uint LVSelection.next( fordata tfd )
{
   if ++tfd.icur >= *.Items : return 0   
   return .Items[tfd.icur] 
}


method uint LVSelection.first( fordata tfd )
{
   tfd.icur = 0
   if tfd.icur >= *.Items : return 0   
   return .Items[tfd.icur] 
}

method LVRow LVSelection.index( uint idx )
{
   if idx < *.Items : return .Items[idx]->LVRow
   return 0->LVRow
} 

method LVSelection.iSelect( uint idx, uint selected )
{
   LVITEM lvi   
   lvi.stateMask = $LVIS_SELECTED
   if selected : lvi.state |= $LVIS_SELECTED
   .pListView->vListView.WinMsg( $LVM_SETITEMSTATE, idx, &lvi )
}

method LVSelection.iAppend( LVRow row )
{
   .Items[.Items.expand(1)] = &row
}

method uint LVSelection.Find( LVRow row )
{
   uint i   
   fornum i = 0, *.Items
   {      
      if .Items[i] == &row : return i
   }  
   return -1
}

method LVSelection.iRemove( LVRow row )
{
   uint idx = .Find( row )
   if idx != -1 : .Items.del( idx )   
}



method LVSelection.Append( LVRow row  )
{
   if .pListView->vListView.hwnd : .iSelect( ?( .pListView->vListView.pOwnerData, &row, row.VisIndex ), 1 )
   else : .iAppend( row )
}

method LVSelection.Remove( LVRow row )
{
   if .pListView->vListView.hwnd : .iSelect( ?( .pListView->vListView.pOwnerData, &row, row.VisIndex ), 0 )
   else : .iRemove( row )   
}

method LVSelection.Clear()
{  
   if .pListView->vListView.hwnd 
   {
      .iSelect( -1, 0 )
   }
   else
   {      
      .Items.clear()      
   } 
}

method LVSelection.SelectAll()
{   
   if .pListView->vListView.hwnd 
   {
      .iSelect( -1, 1 )
   }
   else
   {  
      .Items.clear()
      foreach row, .pListView->vListView.Rows
      {
         .Items[.Items.expand( 1 )] = &row
      }
   } 
}

method LVSelection.Arrange()
{

   uint rows as .pListView->vListView.Rows
   //curitem as root->TVItem
   uint index = 0
   uint curindex
   //while ( curitem as curitem.NextInList )
   foreach currow, rows
   {
   //print("Arrange \(.Find( currow ))\n")
      if ( curindex = .Find( currow )) != -1
      {           
         .Items.move( curindex, index++ ) 
      }
   }
}

method uint LVRows.eof( fordata tfd )
{   
   return tfd.icur >= *this
}


method uint LVRows.next( fordata tfd )
{
   if ++tfd.icur < *this
   {   
      return &this[tfd.icur]
   }
   return 0
}


method uint LVRows.first( fordata tfd )
{
   tfd.icur = 0   
   if tfd.icur < *this
   {   
      return &this[tfd.icur]
   }
   return 0  
}

method LVRows.iWinClear( uint flgdelitem )
{
   with .pListView->vListView
   {       
      .Selected = 0->LVRow               
      .Selection.Clear()
      .WinMsg( $LVM_DELETEALLITEMS )           
      if !.pListView->vListView.pOwnerData && .gtrows
      {      
         foreach item, .gtrows->gtitem
         {  
            if item->LVRow.param 
            {
               destroy( item->LVRow.param )
               item->LVRow.param = 0
            }
            if flgdelitem : item->LVRow.del() 
         }
      }            
   }
   .clear()
   
}

method LVRows.Clear()
{   
   .iWinClear( 1 )   
//   .pListView->vListView.gtrows->gtitem.del()
//   .pListView->vListView.gtrows = 0
//   .pListView->vListView.Reload()         
}

method uint LVColumns.eof( fordata tfd )
{   
   return tfd.icur >= *this
}


method uint LVColumns.next( fordata tfd )
{     
   if ++tfd.icur < *this
   {   
      return &this[tfd.icur]
   }
   return 0
}


method uint LVColumns.first( fordata tfd )
{  
   tfd.icur = 0
   if tfd.icur < *this
   {   
      return &this[tfd.icur]
   }
   return 0   
}

method vListViewColumn LVColumns.Find( ustr alias )
{
   foreach col, this
   {
      if col.Alias == alias
      {
         return col 
      }
   }
   return 0->vListViewColumn
}

property uint vListViewColumn.Idx()
{  
   return this.pIndex
}

method vListViewColumn.mLangChanged <alias=vListViewColumn_mLangChanged>()
{
   .iWinUpdate( $LVCF_TEXT )
   this->vComp.mLangChanged()
   if .pUseLanguage && &.Owner
   {
      uint listview as .Owner->vListView
      uint i
      fornum i = 0, *listview.Rows
      {
         listview.Cells( i, .pIndex ).iWinUpdate( $LVCF_TEXT )
      }  
   }   
}

method vListViewColumn.mPreDel <alias=vListViewColumn_mPreDel>()
{  
   
   uint listview as .Owner->vListView
   if listview.pSortedColumn == &this
   {
      listview.pSortedColumn = 0
   }
   this->vComp.mPreDel()
      
}

property uint vListViewColumn.UseLanguage()
{
   return .pUseLanguage
}

property vListViewColumn.UseLanguage( uint val)
{  
   .AutoLang = val
   if .pUseLanguage != val
   { 
      .pUseLanguage = val
      if val : .Virtual( $mLangChanged )
   }   
}