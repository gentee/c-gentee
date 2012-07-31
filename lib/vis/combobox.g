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

/* Компонента vComboBox, порождена от vCtrl
События   
*/
type vComboBoxItem  
{
   uint pIndex
   uint pComboBox
}

type fordatacombobox <inherit=fordata>
{   
   vComboBoxItem item
} 

type vComboBoxEdit <inherit=vCtrl>
{
}

type vComboBox <index=vComboBoxItem inherit=vCtrl>
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
   
   vComboBoxEdit  edctrl
   
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
   operator uint * ( vComboBox combobox )
   property vComboBox.DropDownLen ( uint val )
   property uint vComboBox.DropDownLen ( )
   method vComboBoxItem vComboBox.GetItem( uint index, vComboBoxItem item )
   method vComboBox.Sel( uint start, uint len )
   method vComboBox.SelAll()
   property uint vComboBox.CurIndex()
   property vComboBox.CurIndex ( uint val )
}

/*------------------------------------------------------------------------------
   Internal Methods
*/
/*Метод iUpdate 
Обновить данные в окне
*/
method vComboBox.iUpdateHeight
{
   if /*!.fUpdate &&*/ .pCBStyle != $cbsSimple
   { 
     // .fUpdate = 1      
      MoveWindow( this.hwnd, .loc.left, .loc.top, .loc.width, .loc.height + 4 + .WinMsg( $CB_GETITEMHEIGHT )*.pDropDownLen, 1 )
      //this.Height = this.Height  + 4 + .WinMsg( $CB_GETITEMHEIGHT )*.pDropDownLen
     // .fUpdate = 0
   }
}

method vComboBox.iUpdate
{
   uint i
   uint curindex = .pCurIndex  
   .pCurIndex = -1
   .WinMsg( $CB_RESETCONTENT )
   fornum i=0, *.pArrLabels
   {
      uint cbi = .WinMsg( $CB_ADDSTRING, 0, .pArrLabels[i].Text(this).ptr() )
      .WinMsg( $CB_SETITEMDATA, cbi, i )      
   }
   .iUpdateHeight()
   .CurIndex = curindex
   //.DropDownLen = .DropDownLen
}

method uint vComboBox.eof( fordatacombobox fd )
{
   return ?( fd.icur < *this, 0,  1 )   
}

method vComboBoxItem vComboBox.first( fordatacombobox fd )
{  
   return this.GetItem(0, fd.item )//fd.icur = 0 )
}

method vComboBoxItem vComboBox.next( fordatacombobox fd )
{
   //return this.index( ++fd.icur )
   return this.GetItem( ++fd.icur, fd.item )
}


/*------------------------------------------------------------------------------
   Properties
*/

operator uint * ( vComboBox combobox )
{
   return *combobox.pArrLabels
}

/*Свойство ustr Text - Get Set
Получить, установить редактируемый текст
*/
property ustr vComboBox.Text <result>
{   
   uint res = GetWindowTextLength( this.hwnd )
   result.reserve( res + 1 )     
   GetWindowText( this.hwnd, result.ptr(), res + 1 )
   result.setlen( res )
}

property vComboBox.Text( ustr val )
{   
   this.fNewText = 1
   SetWindowText( this.hwnd, val.ptr() )
   this.fNewText = 0
}

/*Свойство ustr MaxLen - Get Set
Получить, установить максимальную длину текста в символах
*/
property uint vComboBox.MaxLen
{
   return this.WinMsg( $EM_GETLIMITTEXT )
}

property vComboBox.MaxLen( uint val )
{
   this.WinMsg( $EM_LIMITTEXT, val )
}

/*Свойство ustr SelStart - Get Set
Получить, установить начало выделенного текста
*/
property uint vComboBox.SelStart
{   
   uint start
   this.WinMsg( $EM_GETSEL, &start, 0 )
   return start  
}

property vComboBox.SelStart( uint val )
{
   this.Sel( val, 0 )
}

/*Свойство ustr SelLen - Get Set
Получить, установить длину выделенного текста
*/
property uint vComboBox.SelLen
{
   uint start, end   
   this.WinMsg( $EM_GETSEL, &start, &end )
   return end - start   
}

property vComboBox.SelLen( uint val )
{
   this.Sel( this.SelStart, val )    
}

/*Свойство ustr SelStart - Get
Получить выделенный текст
*/
property ustr vComboBox.SelText<result>
{
   uint start, end   
   this.WinMsg( $EM_GETSEL, &start, &end )
   result.substr( this.Text, start, end-start )
}

//CBStyle, Sorted, MaxLength, CurIndex, Items, DownDowncount, AutoComplete, AutoDropDown
/*Свойство ustr CBStyle - Get Set
Получить, установить стиль комбобокса
*/
property uint vComboBox.CBStyle ()
{  
   return .pCBStyle
}

property vComboBox.CBStyle ( uint val )
{
   if .pCBStyle != val
   {
      .pCBStyle = val
      //.ReCreateWin()
      .Virtual( $mReCreateWin )
   }
}

/*Свойство ustr CurIndex - Get Set
Получить, установить текущий элемент
*/
property uint vComboBox.CurIndex()
{  
   /*uint windex = .WinMsg( $CB_GETCURSEL )
   if windex == -1 : return -1
   return .WinMsg( $CB_GETITEMDATA, windex )*/
   return .pCurIndex
}

method vComboBox.SetCurSel()
{
   uint val = .pCurIndex
   if val > *.pArrLabels : val = -1
   if val != -1
   {
      uint i
      fornum i, *.pArrLabels
      {
         if val == .WinMsg( $CB_GETITEMDATA, i ) 
         {
            val = i
            break
         }            
      }
   } 
   .WinMsg( $CB_SETCURSEL, val )   
}

property vComboBox.CurIndex ( uint val )
{
   if .pCurIndex != val
   {
      .pCurIndex = val
      .SetCurSel()         
   }
}

/*Свойство ustr Sorted - Get Set
Получить, установить стиль комбобокса
*/
property uint vComboBox.Sorted ()
{  
   return .pSorted
}

property vComboBox.Sorted ( uint val )
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
property uint vComboBox.DropDownLen ()
{  
   return .pDropDownLen
}

property vComboBox.DropDownLen ( uint val )
{   
   if .pDropDownLen != val
   {
      .pDropDownLen = val
      .iUpdateHeight()
   }
       
}

property vComboBoxItem.Label( ustr val )
{
   uint combobox as .pComboBox->vComboBox
   
   if .pIndex < *combobox
   {
      combobox.pArrLabels[.pIndex].Value = val
      combobox.iUpdate()
   }
}

property ustr vComboBoxItem.Label<result>() 
{
   uint combobox as .pComboBox->vComboBox
   if .pIndex < *combobox
   {
      result = combobox.pArrLabels[.pIndex].Value
   }   
//   return 0->ustr
}

property vComboBoxItem.Key( ustr val )
{
   uint combobox as .pComboBox->vComboBox
   if .pIndex < *combobox
   {
      combobox.pArrKeys[.pIndex] = val
      combobox.iUpdate()
   }
}

property ustr vComboBoxItem.Key()
{
   uint combobox as .pComboBox->vComboBox
   if .pIndex < *combobox
   {
      return combobox.pArrKeys[.pIndex]
   }
   return 0->ustr
}

property vComboBoxItem.Val( uint val )
{
   uint combobox as .pComboBox->vComboBox
   if .pIndex < *combobox
   {
      combobox.pArrVals[.pIndex] = val
      combobox.iUpdate()
   }
}

property uint vComboBoxItem.Val()
{
   uint combobox as .pComboBox->vComboBox
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
method vComboBox.Sel( uint start, uint len )
{
   this.WinMsg( $EM_SETSEL, start, start + len ) 
} 

/*Метод SelAll()
Выделить весь текст
*/
method vComboBox.SelAll()
{
   this.Sel( 0, -1 )
}

method vComboBox.AddItem( ustr slabel, ustr key, uint val )
{
   uint i = .pArrLabels.expand( 1 )
   .pArrKeys.expand( 1 )
   .pArrVals.expand( 1 )   
   .pArrLabels[i].Value = slabel
   if &key: .pArrKeys[i] = key   
   .pArrVals[i] = val
   
   uint cbi = .WinMsg( $CB_ADDSTRING, 0, .pArrLabels[i].Text(this).ptr() )
   .WinMsg( $CB_SETITEMDATA, cbi, i )
}

method vComboBox.InsertItem( uint pos, ustr slabel, ustr key, uint val )
{
   pos = min( pos, *.pArrLabels )
   .pArrLabels.insert( pos )   
   .pArrKeys.insert( pos )
   .pArrVals.insert( pos )
   .pArrLabels[pos].Value = slabel 
   if &key: .pArrKeys[pos] = key
   .pArrVals[pos] = val
   .iUpdate()
}

method vComboBox.RemoveItem( uint pos )
{  
   if pos < *.pArrLabels - 1
   {   
      .pArrLabels.del( pos )
      .pArrKeys.del( pos )
      .pArrVals.del( pos )
      .iUpdate()
   }
}

method uint vComboBox.FindItem( ustr slabel )
{  
   uint i
   fornum i, *.pArrLabels
   {
      if .pArrLabels[i].Value == slabel : return i      
   }
   return -1
}

method uint vComboBox.FindItemKey( ustr key )
{
   uint i
   fornum i, *.pArrKeys
   {
      if .pArrKeys[i] == key : return i      
   }
   return -1
}


method uint vComboBox.FindItemVal( uint val )
{
   uint i
   fornum i, *.pArrVals
   {
      if .pArrVals[i] == val : return i      
   }
   return -1
}



method vComboBox.AddLines( ustr list )
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

method vComboBox.Clear()
{
   .pArrLabels.clear()
   .pArrKeys.clear()
   .pArrVals.clear()
   .iUpdate()
}

method uint vComboBox.DropDown()
{

   SetFocus( .hwnd )
   return .WinMsg( $CB_SHOWDROPDOWN, 1,0 )
}

method vComboBoxItem vComboBox.index <result>( uint index )
{
   .GetItem( index, result )       
}

/*
property uint vComboBox.count( )
{
   return SendMessage( this.hwnd, $CB_GETCOUNT, 0, 0 )   
}

property uint vComboBox.itemheight()
{
   return SendMessage( this.hwnd, $CB_GETITEMHEIGHT, 0, 0 )
}

property uint vComboBox.itemindex()
{
   return SendMessage( this.hwnd, $CB_GETCURSEL, 0, 0 )
}

property str vComboBox.getitemtext<result>( uint i )
{
   result.reserve( SendMessage( this.hwnd, $CB_GETLBTEXTLEN, i, 0 ) + 1 )
   SendMessage( this.hwnd, $CB_GETLBTEXT, i, result.ptr() )
   result.setlenptr()   
}

method vComboBox.loadfromarr( arrstr ar )
{
   uint i
   SendMessage( this.hwnd, $CB_RESETCONTENT, 0, ar[i].ptr() )
   fornum i, *ar
   {
      SendMessage( this.hwnd, $CB_ADDSTRING, 0, ar[i].ptr() )
   }
}

*/

method uint vComboBox.mWinCmd <alias=vComboBox_mWinCmd>( uint cmd, uint id )
{  
   switch cmd
   { 
      case $CBN_SELENDOK  
      {                     
         //print( "selend\n" )
         uint windex = .WinMsg( $CB_GETCURSEL )
         .pCurIndex = windex
         //print( "selend \(windex) \(.WinMsg( $CB_GETITEMDATA, windex ))\n" )
         .pCurIndex = ?( windex == -1, -1, .WinMsg( $CB_GETITEMDATA, windex ))
         
         evparValUstr es         
         es.val = this[.pCurIndex].Label
         .OnSelect.Run( es, this )                      
      }
      case $CBN_CLOSEUP
      {
         //.WinMsg( $CB_SETCURSEL, .pCurIndex )
         .SetCurSel()
         .oncloseup.run()         
      }
      /*case $CBN_SELENDCANCEL
      {
         print( "xxx \(.pCurIndex) \(.WinMsg( $CB_GETCURSEL ))\n" )
       //  .WinMsg( $CB_SETCURSEL, .pCurIndex )         
      }*/         
   }   
   return 0
}

/*method vComboBox.mPosChanged <alias=vComboBox_mPosChanged>( evparValUint ev )
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

method vComboBoxItem vComboBox.GetItem( uint index, vComboBoxItem item )
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

method vComboBox vComboBox.mCreateWin <alias=vComboBox_mCreateWin>()
{  
   uint CBStyle   
   switch .pCBStyle 
   {
      case $cbsDropDown: CBStyle = $CBS_DROPDOWN
      case $cbsDropDownList: CBStyle = $CBS_DROPDOWNLIST
      default : CBStyle = $CBS_SIMPLE
   }   
   if .pSorted
   {   
      CBStyle |= $CBS_SORT  
   }
   this.CreateWin( "combobox".ustr(), 0,
            CBStyle | $WS_VSCROLL |//| 0x242 |
            $WS_CHILD | $WS_CLIPSIBLINGS )            
   this->vCtrl.mCreateWin()
   
   if .pCBStyle != $cbsDropDownList
   {
      this.pCanContain = 1
      this.edctrl.Owner = this
      this.pCanContain = 0
   //   this.edctrl.Name = "test"
      COMBOBOXINFO cbi
      cbi.cbSize = sizeof( COMBOBOXINFO )
      GetComboBoxInfo( this.hwnd, cbi )
      this.edctrl.hwnd = cbi.hwndItem
      this.edctrl.pTypeDef = &gettypedef( vComboBoxEdit )
      this.edctrl->vCtrl.mCreateWin()      
   }
    
   this.WinMsg( $WM_SETFONT, GetStockObject( $DEFAULT_GUI_FONT ) )   
   .iUpdate() 
   return this
}

method vComboBox.mReCreateWin <alias=vComboBox_mReCreateWin> ()
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

method vComboBoxEdit vComboBoxEdit.mCreateWin <alias=vComboBoxEdit_mCreateWin>()
{
   return this  
}

method uint vComboBoxEdit.mKey <alias=vComboBoxEdit_mKey>( evparKey evk )
{  
   this.Owner->vComboBox.mKey( evk )
   return 0  
}  
 
 

/*Виртуальный метод uint vComboBox.mLangChanged - Изменение текущего языка
*/
method vComboBox.mLangChanged <alias=vComboBox_mLangChanged>()
{
   .iUpdate() 
   this->vCtrl.mLangChanged() 
}

method uint vComboBox.wmwindowposchanged <alias=vComboBox_wmwindowposchanged >( winmsg wmsg )
{
   .flgPosChanged++
//print( "pchanged0 \n" )//\(&this) \(wmsg.lpar->WINDOWPOS.flags) \(wmsg.lpar->WINDOWPOS.cy) \(.Name) \(.fUpdate) \(this.Height)\n")
   this->vCtrl.wmwindowposchanged ( wmsg )
   if .flgPosChanged == 1
   {
      RECT r
      .WinMsg( $CB_GETDROPPEDCONTROLRECT, 0, &r )
      if r.bottom - r.top != .loc.height + 4 + .WinMsg( $CB_GETITEMHEIGHT )*.pDropDownLen
      {
//      print( "update \(r.bottom - r.top)\n" )
         .iUpdateHeight()
         eventpos evp
         evp.move = 1
         evp.loc = this.loc
         .Virtual( $mPosChanging, evp )
      }   
   }
   .flgPosChanged--
//print( "pchanged1 \(.fUpdate) \(this.Height)\n")
   return 0
}

method vComboBox.mPreDel <alias=vComboBox_mPreDel>()
{
   /*this.edctrl.Owner = 0->vComp
   print( "predle 2\n" )*/
  // .flgPosChanged++
   this->vCtrl.mPreDel()
}


/*------------------------------------------------------------------------------
   Registration
*/
/*method vComboBox.getprops( uint typeid, compMan cm )
{
   this->vCtrl.getprops( typeid, cm)                         
}*/

method vComboBox vComboBox.init( )
{     
   this.loc.width = 200
   this.loc.height = 200
   this.pTypeId = vComboBox  
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
method uint vComboBox.mClColor <alias=vComboBox_mClColor>( winmsg wmsg )
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

func init_vComboBox <entry>()
{  
   regcomp( vComboBox, "vComboBox", vCtrl, $vCtrl_last, 
      %{ %{$mCreateWin,    vComboBox_mCreateWin},
         %{$mReCreateWin, vComboBox_mReCreateWin},
         %{$mWinCmd,       vComboBox_mWinCmd},
         //%{$mPosChanged,   vComboBox_mPosChanged},
         %{$mLangChanged,  vComboBox_mLangChanged},
         %{$mPreDel, vComboBox_mPreDel}
         //%{$mClColor,      vComboBox_mClColor }
         }, 
      %{ %{$WM_WINDOWPOSCHANGED,       vComboBox_wmwindowposchanged } } )
   regcomp( vComboBoxEdit, "vComboBoxEdit", vCtrl, $vCtrl_last, 
      %{ %{$mCreateWin,    vComboBox_mCreateWin},         
         %{$mKey, vComboBoxEdit_mKey}
         }, 
      0->collection )           
ifdef $DESIGNING {
   cm.AddComp( vComboBox, 1, "Windows", "combobox" )   
   
   cm.AddProps( vComboBox, %{ 
//"TabOrder", uint, 0,
"CBStyle", uint, 0,
"Sorted", uint, 0,
"DropDownLen", uint, 0 
   })
   
   cm.AddPropVals( vComboBox, "CBStyle", %{ 
"cbsDropDown"    ,   $cbsDropDown,    
"cbsDropDownList",   $cbsDropDownList,     
"cbsSimple"      ,   $cbsSimple      
   }) 
   
   cm.AddEvents( vComboBox, %{
"OnSelect"      , "evparValUstr"
   })
}      
}


