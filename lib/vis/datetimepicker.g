/******************************************************************************
*
* Copyright (C) 2004-2007, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: vis.datetimepicker 17.07.07 0.0.A.
*
* Author: Alexander Krivonogov ( gentee )
*
******************************************************************************/

/* Компонента vDateTimePicker, порождена от vCtrl
События
   onChange - изменение текста
*/
type vDateTimePicker <inherit = vCtrl>
{  
//Hidden fields
/*   uint fNewText
   uint pBorder
   uint pChanged
   uint pReadOnly 
   ustr pText  
   uint pPassword
   uint pMaxLen
   uint pMultiline
   uint pWordWrap
   uint pScrollBars*/
   
//Events
   evEvent OnChange
}


define <export>{
//Режим отображения полос прокрутки ScrollBars
   /*sbNone = 0 
   sbHorz = 1
   sbVert = 2
   sbBoth = 3*/
}

/*------------------------------------------------------------------------------
   Public methods
*/


/*------------------------------------------------------------------------------
   Properties
*/
/* Свойство uint ReadOnly - Get Set
Усотанавливает или определяет можно ли изменять текст
1 - текст изменять нельзя
0 - текст изменять можно
*/
/*property uint vDateTimePicker.ReadOnly 
{
   return this.pReadOnly
}

property  vDateTimePicker.ReadOnly( uint val )
{
   if val != this.pReadOnly
   {
      this.pReadOnly = val
      this.WinMsg( $EM_SETREADONLY, val )
   }
}*/

/*Свойство ustr Border - Get Set
Установить, получить наличие рамки у поля ввода
1 - рамка есть
0 - рамки нет
*/
property vDateTimePicker.Border( uint val )
{
/*   .pBorder = val
   uint style = GetWindowLong( this.hwnd, $GWL_EXSTYLE )
   if val : style |= $WS_EX_CLIENTEDGE
   else : style &= ~$WS_EX_CLIENTEDGE
   SetWindowLong( this.hwnd, $GWL_EXSTYLE, style )      
   SetWindowPos( this.hwnd, 0, 0, 0, 0, 0, $SWP_FRAMECHANGED | 
                  $SWP_NOACTIVATE | $SWP_NOZORDER | $SWP_NOMOVE | $SWP_NOSIZE )*/
}

property uint vDateTimePicker.Border
{   
   return .pBorder
}


/*------------------------------------------------------------------------------
   Virtual methods
*/
method vDateTimePicker vDateTimePicker.mCreateWin <alias=vDateTimePicker_mWin>()
{
   uint exstyle
   uint style = /*$ES_AUTOHSCROLL |*/ $WS_CHILD | $WS_VISIBLE | $WS_CLIPSIBLINGS 
   /*if .pBorder : exstyle |= $WS_EX_CLIENTEDGE   
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
   */
   .CreateWin( "DATETIMEPICK".ustr(), exstyle, style )   
   this->vCtrl.mCreateWin()
   return this
}
/*
method uint vDateTimePicker.mWinCmd <alias=vDateTimePicker_mWinCmd>( uint ntfcmd, uint id )
{
   if ntfcmd == $EN_CHANGE  
   {
      this.pChanged = !this.fNewText
      .iGetText()
      this.OnChange.Run( this )       
   }
   return 0
}

method vDateTimePicker.mFocus <alias=vDateTimePicker_mFocus> ( evparValUint eu )
{
   this->vCtrl.mFocus( eu )
   if !.pMultiline && eu.val && !( GetKeyState($VK_LBUTTON) & 0x1000 )
   {      
      this.SelAll()
   }   
}

*/
/*------------------------------------------------------------------------------
   Registration
*/
method vDateTimePicker vDateTimePicker.init( )
{  
   this.pTypeId = vDateTimePicker
   
/*   this.pBorder = 1
   this.pTabStop = 1
   this.pCanFocus = 1   
   this.loc.width = 100
   this.loc.height = 25
   this.pMaxLen = 0x8000*/       
   return this 
}  

func init_vDateTimePicker <entry>()
{
   regcomp( vDateTimePicker, "vDateTimePicker", vCtrl, $vCtrl_last, 
      %{ %{ $mCreateWin,    vDateTimePicker_mWin }/*,
         %{ $mWinCmd,       vDateTimePicker_mWinCmd },
         %{ $mFocus,        vDateTimePicker_mFocus },
         %{ $mSetName,      vDateTimePicker_mSetName }*/
       },
      0->collection )   
      
ifdef $DESIGNING {
   cm.AddComp( vDateTimePicker, 1, "Windows", "datetimepicker" )
   
/*   cm.AddProps( vDateTimePicker, %{ 
"TabOrder" , uint , 0,
"Text"     , ustr , 0,
"MaxLen"   , uint , 0,
"Border"   , uint , 1,
"Password" , uint , 0,
"Multiline", uint , 0,
"WordWrap" , uint , 0,
"ScrollBars", uint , 0,
"ReadOnly", uint, 0
   })
   
   cm.AddEvents( vDateTimePicker, %{
"OnChange"      , "evparEvent"
   })
   
   cm.AddPropVals( vDateTimePicker, "ScrollBars", %{ 
"sbNone", $sbNone,
"sbHorz", $sbHorz,     
"sbVert", $sbVert,
"sbBoth", $sbBoth
   })
}*/
}