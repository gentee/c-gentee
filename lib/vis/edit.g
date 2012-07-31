/******************************************************************************
*
* Copyright (C) 2004-2007, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: vis.edit 17.07.07 0.0.A.
*
* Author: Alexander Krivonogov ( gentee )
*
******************************************************************************/

/* Компонента vEdit, порождена от vCtrl
События
   onChange - изменение текста
*/
type vEdit <inherit = vCtrl>
{  
//Hidden fields
   uint fNewText
   uint pBorder
   uint pChanged
   uint pReadOnly 
   ustr pText  
   uint pPassword
   uint pMaxLen
   uint pMultiline
   uint pWordWrap
   uint pScrollBars
   
//Events
   evEvent OnChange
}


define <export>{
//Режим отображения полос прокрутки ScrollBars
   sbNone = 0 
   sbHorz = 1
   sbVert = 2
   sbBoth = 3
}

/*------------------------------------------------------------------------------
   Public methods
*/

/*Метод Sel( uint start, uint len )
Выделить часть текста
start - позизия начала выделения
len - длина выделения в символах
*/
method vEdit.Sel( uint start, uint len )
{
   this.WinMsg( $EM_SETSEL, start, start + len ) 
} 

/*Метод SelAll()
Выделить весь текст
*/
method vEdit.SelAll()
{
   this.Sel( 0, -1 )
}


/*------------------------------------------------------------------------------
   Properties
*/
/* Свойство uint ReadOnly - Get Set
Усотанавливает или определяет можно ли изменять текст
1 - текст изменять нельзя
0 - текст изменять можно
*/
property uint vEdit.ReadOnly 
{
   return this.pReadOnly
}

property  vEdit.ReadOnly( uint val )
{
   if val != this.pReadOnly
   {
      this.pReadOnly = val
      this.WinMsg( $EM_SETREADONLY, val )
   }
}

/*Свойство ustr Text - Get Set
Получить, установить редактируемый текст
*/
method vEdit.iSetText()
{
   SetWindowText( this.hwnd, .pText.ptr() )   
}

method vEdit.iGetText()
{
   uint res = GetWindowTextLength( this.hwnd )
   .pText.reserve( res + 1 )
   GetWindowText( this.hwnd, .pText.ptr(), res + 1 )    
   .pText.setlen( res )
}

property ustr vEdit.Text <result>
{   
   result = .pText   
}

property vEdit.Text( ustr val )
{
   if val != .pText
   {
      .pText = val
      this.fNewText = 1      
      .iSetText()
      this.fNewText = 0
   }
}

/*Свойство ustr MaxLen - Get Set
Получить, установить максимальную длину текста в символах
*/
method vEdit.iSetMaxLen()
{
   this.WinMsg( $EM_LIMITTEXT, .pMaxLen )
}

property uint vEdit.MaxLen
{
   return this.pMaxLen//this.WinMsg( $EM_GETLIMITTEXT )
}

property vEdit.MaxLen( uint val )
{
   if .pMaxLen != val
   {
      .pMaxLen = val
      .iSetMaxLen()
   }   
}

/*Свойство ustr Password - Get Set
Получить, установить режим ввода пароля
1 - режим ввода пароля включен
0 - режим ввода параоля отключен
*/
property uint vEdit.Password
{   
   return  .pPassword
}

property vEdit.Password( uint val )
{
   if .pPassword != val
   {   
      .pPassword = val
      this.WinMsg( $EM_SETPASSWORDCHAR, ?( val,'*', 0 ))
      .Invalidate()
   }
}

/*Свойство ustr Border - Get Set
Установить, получить наличие рамки у поля ввода
1 - рамка есть
0 - рамки нет
*/
property vEdit.Border( uint val )
{
   .pBorder = val
   uint style = GetWindowLong( this.hwnd, $GWL_EXSTYLE )
   if val : style |= $WS_EX_CLIENTEDGE
   else : style &= ~$WS_EX_CLIENTEDGE
   SetWindowLong( this.hwnd, $GWL_EXSTYLE, style )      
   SetWindowPos( this.hwnd, 0, 0, 0, 0, 0, $SWP_FRAMECHANGED | 
                  $SWP_NOACTIVATE | $SWP_NOZORDER | $SWP_NOMOVE | $SWP_NOSIZE )
}

property uint vEdit.Border
{   
   return .pBorder
}


/*Свойство ustr SelStart - Get Set
Получить, установить начало выделенного текста
*/
property uint vEdit.SelStart
{   
   uint start
   this.WinMsg( $EM_GETSEL, &start, 0 )
   return start  
}

property vEdit.SelStart( uint val )
{
   this.Sel( val, 0 )
}

/*Свойство ustr SelLen - Get Set
Получить, установить длину выделенного текста
*/
property uint vEdit.SelLen
{
   uint start, end   
   this.WinMsg( $EM_GETSEL, &start, &end )
   return end - start   
}

property vEdit.SelLen( uint val )
{
   this.Sel( this.SelStart, val )    
}

/*Свойство ustr SelStart - Get
Получить/вствавить вместо выделенный текст
*/
property ustr vEdit.SelText<result>
{
   uint start, end   
   this.WinMsg( $EM_GETSEL, &start, &end )
   result.substr( this.Text, start, end-start )
}

property vEdit.SelText( ustr val )
{
   uint start, end
   this.WinMsg( $EM_GETSEL, &start, &end )   
   this.pText.replace( start, end - start, val )
   .iSetText()
   this.WinMsg( $EM_SETSEL, start, start + *val )   
}


/*Свойство uint Changed - Get, Set
Получить, установить признак изменения текста
*/
property uint vEdit.Changed
{
   return this.pChanged
}

property vEdit.Changed( uint val )
{
   this.pChanged = val
}


/*Свойство uint Multiline - Get, Set
Получить, установить многострочный режим
*/
property uint vEdit.Multiline
{
   return this.pMultiline
}

property vEdit.Multiline( uint val )
{
   if this.pMultiline != val
   {
      this.pMultiline = val
      .Virtual( $mReCreateWin )
   }
}

/*Свойство uint WordWrap - Get, Set
Получить, установить режим переноса по словам, работает при Multiline = 1
*/
property uint vEdit.WordWrap
{
   return this.pWordWrap
}

property vEdit.WordWrap( uint val )
{
   if this.pWordWrap != val
   {
      this.pWordWrap = val
      .Virtual( $mReCreateWin )
   }
}


/*Свойство uint ScrollBars - Get, Set
Получить, установить режим отображения полос прокрутки
*/
property uint vEdit.ScrollBars
{
   return this.pScrollBars
}

property vEdit.ScrollBars( uint val )
{
   if this.pScrollBars != val
   {
      this.pScrollBars = val
      .Virtual( $mReCreateWin )
   }
}

/*------------------------------------------------------------------------------
   Virtual methods
*/
method vEdit vEdit.mCreateWin <alias=vEdit_mWin>()
{
   uint exstyle
   uint style = /*$ES_AUTOHSCROLL |*/ $WS_CHILD | $WS_CLIPSIBLINGS 
   if .pBorder : exstyle |= $WS_EX_CLIENTEDGE   
   if .pReadOnly : style |= $ES_READONLY
   if .pPassword : style |= $ES_PASSWORD
   if .pMultiline  
   {
      style |= $ES_WANTRETURN | $ES_MULTILINE | $ES_AUTOVSCROLL
      if !.pWordWrap : style |= $ES_AUTOHSCROLL
   }    
   else : style |= $ES_AUTOHSCROLL
   if .pScrollBars & $sbHorz : style |= $WS_HSCROLL
   if .pScrollBars & $sbVert : style |= $WS_VSCROLL
   .CreateWin( "EDIT".ustr(), exstyle, style )   
   this->vCtrl.mCreateWin()
   .iSetMaxLen()   
   .iSetText()   
   return this
}

method uint vEdit.mWinCmd <alias=vEdit_mWinCmd>( uint ntfcmd, uint id )
{
   if ntfcmd == $EN_CHANGE  
   {
      this.pChanged = !this.fNewText
      .iGetText()
      this.OnChange.Run( this )       
   }
   return 0
}

method vEdit.mFocus <alias=vEdit_mFocus> ( evparValUint eu )
{
   this->vCtrl.mFocus( eu )
   if !.pMultiline && eu.val && !( GetKeyState($VK_LBUTTON) & 0x1000 )
   {      
      this.SelAll()
   }   
}

/*Виртуальный метод uint vEdit.mSetName - Установка заголовка в режиме проектирования
*/
method uint vEdit.mSetName <alias=vEdit_mSetName>( str newname )
{
ifdef $DESIGNING {   
   if !.p_loading && .Text == .Name
   {
      .Text = newname.ustr()
   }
}   
   return 1 
}

/*------------------------------------------------------------------------------
   Registration
*/
method vEdit vEdit.init( )
{  
   this.pTypeId = vEdit
   
   this.pBorder = 1
   this.pTabStop = 1
   this.pCanFocus = 1   
   this.loc.width = 100
   this.loc.height = 25
   this.flgReCreate = 1
   this.pMaxLen = 0x8000       
   return this 
}  

func init_vEdit <entry>()
{
   regcomp( vEdit, "vEdit", vCtrl, $vCtrl_last, 
      %{ %{ $mCreateWin,    vEdit_mWin },
         %{ $mWinCmd,       vEdit_mWinCmd },
         %{ $mFocus,        vEdit_mFocus },
         %{ $mSetName,      vEdit_mSetName }
       },
      0->collection )   
      
ifdef $DESIGNING {
   cm.AddComp( vEdit, 1, "Windows", "edit" )
   
   cm.AddProps( vEdit, %{ 
//"TabOrder" , uint , 0,
"Text"     , ustr , 0,
"MaxLen"   , uint , 0,
"Border"   , uint , 1,
"Password" , uint , 0,
"Multiline", uint , 0,
"WordWrap" , uint , 0,
"ScrollBars", uint , 0,
"ReadOnly", uint, 0
   })
   
   cm.AddEvents( vEdit, %{
"OnChange"      , "evparEvent"
   })
   
   cm.AddPropVals( vEdit, "ScrollBars", %{ 
"sbNone", $sbNone,
"sbHorz", $sbHorz,     
"sbVert", $sbVert,
"sbBoth", $sbBoth
   })
}
}