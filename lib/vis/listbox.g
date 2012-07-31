/******************************************************************************
*
* Copyright (C) 2004-2007, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: vis.combobox 30.07.07 0.0.A.
*
* Author: Alexander Krivonogov ( gentee )
*
******************************************************************************/

include {
  "ctrl.g"
}

/* Компонента vListBox, порождена от vCtrl
События   
*/
type vListBoxItem  
{
   uint pIndex
   uint pComboBox
}

type fordatalistbox <inherit=fordata>
{   
   vListBoxItem item
} 

type vListBoxEdit <inherit=vCtrl>
{
}

type vListBox <index=vListBoxItem inherit=vCtrl>
{
//Hidden Fields  
   uint    fNewText //Признак программного изменения текста
   //uint    fUpdate 
   //uint pChanged //
   uint    pCurIndex
    
   uint    pCBStyle
   uint    pSorted
   uint    pDropDownLen
   
   
   arr     pArrLabels of locustr
   arrustr pArrKeys
   arr     pArrVals of uint
   uint    flgPosChanged
   
   vListBoxEdit  edctrl
   
   //uint itemcounts
//Events      
   evValUstr  OnSelect
   evEvent    oncloseup
   
}





define <export> {
//Стили комбобокса
   cbsDropDown    = 0
   cbsDropDownList= 1
   cbsSimple      = 2
}

extern {
   operator uint * ( vListBox combobox )
   property vListBox.DropDownLen ( uint val )
   property uint vListBox.DropDownLen ( )
   method vListBoxItem vListBox.GetItem( uint index, vListBoxItem item )
   method vListBox.Sel( uint start, uint len )
   method vListBox.SelAll()
   property uint vListBox.CurIndex()
   property vListBox.CurIndex ( uint val )
}

/*------------------------------------------------------------------------------
   Internal Methods
*/
/*Метод iUpdate 
Обновить данные в окне
*/
/*method vListBox.iUpdateHeight
{
   if  .pCBStyle != $cbsSimple
   { 
     // .fUpdate = 1      
      MoveWindow( this.hwnd, .loc.left, .loc.top, .loc.width, .loc.height + 4 + .WinMsg( $CB_GETITEMHEIGHT )*.pDropDownLen, 1 )
      //this.Height = this.Height  + 4 + .WinMsg( $CB_GETITEMHEIGHT )*.pDropDownLen
     // .fUpdate = 0
   }
}*/

method vListBox.iUpdate
{
   uint i
   uint curindex = .pCurIndex  
   .pCurIndex = -1
   .WinMsg( $LB_RESETCONTENT )
   fornum i=0, *.pArrLabels
   {
      uint cbi = .WinMsg( $LB_ADDSTRING, 0, .pArrLabels[i].Text(this).ptr() )
      .WinMsg( $LB_SETITEMDATA, cbi, i )      
   }
//   .iUpdateHeight()
   .CurIndex = curindex
   //.DropDownLen = .DropDownLen
}

method uint vListBox.eof( fordatalistbox fd )
{
   return ?( fd.icur < *this, 0,  1 )   
}

method vListBoxItem vListBox.first( fordatalistbox fd )
{  
   return this.GetItem(0, fd.item )//fd.icur = 0 )
}

method vListBoxItem vListBox.next( fordatalistbox fd )
{
   //return this.index( ++fd.icur )
   return this.GetItem( ++fd.icur, fd.item )
}


/*------------------------------------------------------------------------------
   Properties
*/

operator uint * ( vListBox listbox )
{
   return *listbox.pArrLabels
}


//CBStyle, Sorted, MaxLength, CurIndex, Items, DownDowncount, AutoComplete, AutoDropDown
/*Свойство ustr CBStyle - Get Set
Получить, установить стиль комбобокса
*/
/*property uint vListBox.CBStyle ()
{  
   return .pCBStyle
}

property vListBox.CBStyle ( uint val )
{
   if .pCBStyle != val
   {
      .pCBStyle = val
      //.ReCreateWin()
      .Virtual( $mReCreateWin )
   }
}*/

/*Свойство ustr CurIndex - Get Set
Получить, установить текущий элемент
*/
property uint vListBox.CurIndex()
{  
   /*uint windex = .WinMsg( $CB_GETCURSEL )
   if windex == -1 : return -1
   return .WinMsg( $CB_GETITEMDATA, windex )*/
   return .pCurIndex
}

property vListBox.CurIndex ( uint val )
{
   if .pCurIndex != val
   {
      .pCurIndex = val
      if val > *.pArrLabels : val = -1
      if val != -1
      {
         uint i
         fornum i, *.pArrLabels
         {
            if val == .WinMsg( $LB_GETITEMDATA, i ) 
            {
               val = i
               break
            }            
         }
      } 
      .WinMsg( $LB_SETCURSEL, val )   
   }
}

/*Свойство ustr Sorted - Get Set
Получить, установить стиль комбобокса
*/
property uint vListBox.Sorted ()
{  
   return .pSorted
}

property vListBox.Sorted ( uint val )
{
   if .pSorted != val
   {  
      .pSorted = val
      //.ReCreateWin()
      .Virtual( $mReCreateWin )
   }
}

/*Свойство ustr DropDownLen - Get Set
Получить, установить количество элементов отображаемых в выпадающем списке
*/
/*property uint vListBox.DropDownLen ()
{  
   return .pDropDownLen
}

property vListBox.DropDownLen ( uint val )
{   
   if .pDropDownLen != val
   {
      .pDropDownLen = val
      .iUpdateHeight()
   }
       
}*/

property vListBoxItem.Label( ustr val )
{
   uint combobox as .pComboBox->vListBox
   
   if .pIndex < *combobox
   {
      combobox.pArrLabels[.pIndex].Value = val
      combobox.iUpdate()
   }
}

property ustr vListBoxItem.Label<result>() 
{
   uint combobox as .pComboBox->vListBox
   if .pIndex < *combobox
   {
      result = combobox.pArrLabels[.pIndex].Value
   }   
//   return 0->ustr
}

property vListBoxItem.Key( ustr val )
{
   uint combobox as .pComboBox->vListBox
   if .pIndex < *combobox
   {
      combobox.pArrKeys[.pIndex] = val
      combobox.iUpdate()
   }
}

property ustr vListBoxItem.Key()
{
   uint combobox as .pComboBox->vListBox
   if .pIndex < *combobox
   {
      return combobox.pArrKeys[.pIndex]
   }
   return 0->ustr
}

property vListBoxItem.Val( uint val )
{
   uint combobox as .pComboBox->vListBox
   if .pIndex < *combobox
   {
      combobox.pArrVals[.pIndex] = val
      combobox.iUpdate()
   }
}

property uint vListBoxItem.Val()
{
   uint combobox as .pComboBox->vListBox
   if .pIndex < *combobox
   {
      return combobox.pArrVals[.pIndex]
   }
   return 0
}


/*Метод Sel( uint start, uint len )
Выделить часть текста
start - позизия начала выделения
len - длина выделения в символах
*/
method vListBox.Sel( uint start, uint len )
{
   this.WinMsg( $EM_SETSEL, start, start + len ) 
} 

/*Метод SelAll()
Выделить весь текст
*/
method vListBox.SelAll()
{
   this.Sel( 0, -1 )
}

method vListBox.AddItem( ustr slabel, ustr key, uint val )
{
   uint i = .pArrLabels.expand( 1 )
   .pArrKeys.expand( 1 )
   .pArrVals.expand( 1 )   
   .pArrLabels[i].Value = slabel
   if &key: .pArrKeys[i] = key   
   .pArrVals[i] = val
   
   uint cbi = .WinMsg( $LB_ADDSTRING, 0, .pArrLabels[i].Text(this).ptr() )
   .WinMsg( $LB_SETITEMDATA, cbi, i )
}

method vListBox.InsertItem( uint ipos, ustr slabel, ustr key, uint val )
{
   ipos = min( ipos, *.pArrLabels )
   .pArrLabels.insert( ipos )   
   .pArrKeys.insert( ipos )
   .pArrVals.insert( ipos )
   .pArrLabels[ipos].Value = slabel 
   if &key: .pArrKeys[ipos] = key
   .pArrVals[ipos] = val
   .iUpdate()
}

method vListBox.RemoveItem( uint pos )
{  
   if pos < *.pArrLabels - 1
   {   
      .pArrLabels.del( pos )
      .pArrKeys.del( pos )
      .pArrVals.del( pos )
      .iUpdate()
   }
}

method uint vListBox.FindItem( ustr slabel )
{  
   uint i
   fornum i, *.pArrLabels
   {
      if .pArrLabels[i].Value == slabel : return i      
   }
   return -1
}

method uint vListBox.FindItemKey( ustr key )
{
   uint i
   fornum i, *.pArrKeys
   {
      if .pArrKeys[i] == key : return i      
   }
   return -1
}


method uint vListBox.FindItemVal( uint val )
{
   uint i
   fornum i, *.pArrVals
   {
      if .pArrVals[i] == val : return i      
   }
   return -1
}



method vListBox.AddLines( ustr list )
{
   arrustr arrnames
   ustr    sname, skey
   uint    name, i
   list.lines( arrnames )   
   
   fornum i, *arrnames
   {      
      
      name as arrnames[i]
      uint eq = name.findch('=')      
      if eq < *name
      {
         sname.substr( name, 0, eq )
         skey.substr( name, eq + 1, *name - eq - 1  )        
      }
      else
      {
         sname = name
         skey.clear()
      }      
      .AddItem( sname, skey, int( skey.str()))      
   }
}

method vListBox.Clear()
{
   .pCurIndex = -1
   .pArrLabels.clear()
   .pArrKeys.clear()
   .pArrVals.clear()
   .iUpdate()
}
/*
method uint vListBox.DropDown()
{

   SetFocus( .hwnd )
   return .WinMsg( $CB_SHOWDROPDOWN, 1,0 )
}
*/
method vListBoxItem vListBox.index <result>( uint index )
{
   .GetItem( index, result )       
}

/*
property uint vListBox.count( )
{
   return SendMessage( this.hwnd, $CB_GETCOUNT, 0, 0 )   
}*/

property uint vListBox.ItemHeight()
{
   return SendMessage( this.hwnd, $LB_GETITEMHEIGHT, 0, 0 )
}

/*property uint vListBox.itemindex()
{
   return SendMessage( this.hwnd, $CB_GETCURSEL, 0, 0 )
}

property str vListBox.getitemtext<result>( uint i )
{
   result.reserve( SendMessage( this.hwnd, $CB_GETLBTEXTLEN, i, 0 ) + 1 )
   SendMessage( this.hwnd, $CB_GETLBTEXT, i, result.ptr() )
   result.setlenptr()   
}

method vListBox.loadfromarr( arrstr ar )
{
   uint i
   SendMessage( this.hwnd, $CB_RESETCONTENT, 0, ar[i].ptr() )
   fornum i, *ar
   {
      SendMessage( this.hwnd, $CB_ADDSTRING, 0, ar[i].ptr() )
   }
}

*/

method uint vListBox.mWinCmd <alias=vListBox_mWinCmd>( uint cmd, uint id )
{  
   switch cmd
   { 
      /*case $CBN_SELENDOK  
      {                     
         //print( "selend\n" )
         uint windex = .WinMsg( $CB_GETCURSEL )
         .pCurIndex = ?( windex == -1, -1, .WinMsg( $CB_GETITEMDATA, windex ))
         
         evparValUstr es         
         es.val = this[.pCurIndex].Label
         .OnSelect.Run( es, this )                      
      }*/
      /*case $CBN_CLOSEUP
      {
         .oncloseup.run()
      }*/         
   }   
   return 0
}

/*method vListBox.mPosChanged <alias=vListBox_mPosChanged>( evparValUint ev )
{  
   this->vCtrl.mPosChanged( ev )
   if !.fUpdate
   {
   
    
   if ev.val = 1
   {  
      .iUpdateHeight()
   }
   }
}*/

method vListBoxItem vListBox.GetItem( uint index, vListBoxItem item )
{
   //print( "set \(&this) \(index)\n" )
   item.pComboBox = &this   
   if index < *.pArrLabels
   {
      item.pIndex = index
   }
   else
   {   
      item.pIndex = -1
   }
   return item       
}
 


/*------------------------------------------------------------------------------
   Virtual Methods
*/

method vListBox vListBox.mCreateWin <alias=vListBox_mCreateWin>()
{  
   /*uint CBStyle   
   switch .pCBStyle 
   {
      case $cbsDropDown: CBStyle = $CBS_DROPDOWN
      case $cbsDropDownList: CBStyle = $CBS_DROPDOWNLIST
      default : CBStyle = $CBS_SIMPLE
   }   
   if .pSorted
   {   
      CBStyle |= $CBS_SORT  
   }*/
   this.CreateWin( "listbox".ustr(), 0,
            /*CBStyle | $WS_VSCROLL |*///| 0x242 |
            $WS_VSCROLL | $WS_CHILD | $WS_CLIPSIBLINGS | $WS_BORDER  )            
   this->vCtrl.mCreateWin()
   
   /*if .pCBStyle != $cbsDropDownList
   {
      this.pCanContain = 1
      this.edctrl.Owner = this
      this.pCanContain = 0
   //   this.edctrl.Name = "test"
      COMBOBOXINFO cbi
      cbi.cbSize = sizeof( COMBOBOXINFO )
      GetComboBoxInfo( this.hwnd, cbi )
      this.edctrl.hwnd = cbi.hwndItem
      this.edctrl.pTypeDef = &gettypedef( vListBoxEdit )
      this.edctrl->vCtrl.mCreateWin()      
   }
    */
   this.WinMsg( $WM_SETFONT, GetStockObject( $DEFAULT_GUI_FONT ) )   
   .iUpdate() 
   return this
}

method vListBox.mReCreateWin <alias=vListBox_mReCreateWin> ()
{
   if this.hwnd
   {
      if this.edctrl.hwnd
      {
         this.edctrl.Owner = 0->vComp
      }
   }
   this->vCtrl.mReCreateWin()
  // this->vForm.mReCreateWin()

}

 

/*Виртуальный метод uint vListBox.mLangChanged - Изменение текущего языка
*/
method vListBox.mLangChanged <alias=vListBox_mLangChanged>()
{
   .iUpdate() 
   this->vCtrl.mLangChanged() 
}


method vListBox.mPreDel <alias=vListBox_mPreDel>()
{
   /*this.edctrl.Owner = 0->vComp
   print( "predle 2\n" )*/
  // .flgPosChanged++
   this->vCtrl.mPreDel()
}


/*------------------------------------------------------------------------------
   Registration
*/
/*method vListBox.getprops( uint typeid, compMan cm )
{
   this->vCtrl.getprops( typeid, cm)                         
}*/

method vListBox vListBox.init( )
{     
   this.loc.width = 200
   this.loc.height = 200
   this.pTypeId = vListBox  
   this.pTabStop = 1
   this.pCanFocus = 1
   this.pDropDownLen = 5 
   this.flgReCreate = 1
   this.pCurIndex = -1
   //this.flgXPStyle = 1
   //this.pCanContain = 0 
   return this 
}  


/*
method uint vListBox.mClColor <alias=vListBox_mClColor>( winmsg wmsg )
{
   if .pCBStyle != $cbsDropDownList
   {
      print( "zzz\n" )
      return GetStockObject(5)
   }
   else
   {  
      return this->vCtrl.mClColor( wmsg )
   }
}*/

func init_vListBox <entry>()
{  
   regcomp( vListBox, "vListBox", vCtrl, $vCtrl_last, 
      %{ %{$mCreateWin,    vListBox_mCreateWin},
         %{$mReCreateWin,  vListBox_mReCreateWin},
         %{$mWinCmd,       vListBox_mWinCmd},      
         %{$mLangChanged,  vListBox_mLangChanged},
         %{$mPreDel,       vListBox_mPreDel}
      
         }, 
      0->collection )
                 
ifdef $DESIGNING {
   cm.AddComp( vListBox, 1, "Windows", "listbox" )   
/*   
   cm.AddProps( vListBox, %{ 
//"TabOrder", uint, 0,
"CBStyle", uint, 0,
"Sorted", uint, 0,
"DropDownLen", uint, 0 
   })
   
   cm.AddPropVals( vListBox, "CBStyle", %{ 
"cbsDropDown"    ,   $cbsDropDown,    
"cbsDropDownList",   $cbsDropDownList,     
"cbsSimple"      ,   $cbsSimple      
   }) 
*/   
   cm.AddEvents( vListBox, %{
"OnSelect"      , "evparValUstr"
   })
}      
}


