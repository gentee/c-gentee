/******************************************************************************
*
* Copyright (C) 2004-2007, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: vis.datetimepick 17.07.07 0.0.A.
*
* Author: Alexander Krivonogov ( gentee )
*
******************************************************************************/

/* Компонента vDateTimePick, порождена от vCtrl
События
   onChange - изменение текста
*/
type vDateTimePick <inherit = vCtrl>
{  
//Hidden fields
   uint pFormat
   uint pShowUpDown
   ustr pCustomFormat
   datetime pDT
   
//Events
   evEvent OnChange
}


define <export>{
//Формат выбора даты/времени
   dtpShort = 0
   dtpLong  = 1
   dtpTime  = 2
   dtpCustom = 3
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
/*property uint vDateTimePick.ReadOnly 
{
   return this.pReadOnly
}

property  vDateTimePick.ReadOnly( uint val )
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
property vDateTimePick.Border( uint val )
{
/*   .pBorder = val
   uint style = GetWindowLong( this.hwnd, $GWL_EXSTYLE )
   if val : style |= $WS_EX_CLIENTEDGE
   else : style &= ~$WS_EX_CLIENTEDGE
   SetWindowLong( this.hwnd, $GWL_EXSTYLE, style )      
   SetWindowPos( this.hwnd, 0, 0, 0, 0, 0, $SWP_FRAMECHANGED | 
                  $SWP_NOACTIVATE | $SWP_NOZORDER | $SWP_NOMOVE | $SWP_NOSIZE )*/
}

property uint vDateTimePick.Border
{   
   return 0//.pBorder
}

/*Свойство ustr Format - Get Set
Установить, получить формат dtp*
*/
method vDateTimePick.iSetCustomFormat()
{
   .WinMsg( $DTM_SETFORMATW, 0, 
         ?( .pFormat == $dtpCustom, .pCustomFormat.ptr(), 0 ) ) 
}

method uint vDateTimePick.iGetFormat()
{
   switch .pFormat 
   {      
      case $dtpLong : return $DTS_LONGDATEFORMAT     
      case $dtpTime : return $DTS_TIMEFORMAT
   }   
   return 0
} 
property vDateTimePick.Format( uint val )
{
   if .pFormat != val
   {      
      .SetStyle(.iGetFormat(), 0 )
      .pFormat = val
      .SetStyle(.iGetFormat(), 1 )
      .iSetCustomFormat()
   }    
}

property uint vDateTimePick.Format
{
   return .pFormat
}

/*Свойство ustr Format - Get Set
Установить, получить пользовательский формат даты/времени
*/
property vDateTimePick.CustomFormat( ustr val )
{
   if .pCustomFormat != val
   {  
      .pCustomFormat = val
      .iSetCustomFormat()
      //.SetStyle(.iGetFormat(), 1 )
   }    
}

property ustr vDateTimePick.CustomFormat<result>()
{   
   result = .pCustomFormat
}

/*Свойство ustr ShowUpDown - Get Set
Установить, получить формат кнопок управления слева
1 - кнопки вверх и вниз
0 - кнопка выпадающего списка
*/
property vDateTimePick.ShowUpDown( uint val )
{
   if .pShowUpDown != val
   {      
      .pShowUpDown = val
      .Virtual( $mReCreateWin )
   }    
}

property uint vDateTimePick.ShowUpDown
{   
   return .pShowUpDown
}

/*Свойство ustr ShowUpDown - Get Set
Установить, получить формат кнопок управления слева
1 - кнопки вверх и вниз
0 - кнопка выпадающего списка
*/
property vDateTimePick.DateTime( datetime val )
{
   if .pDT != val
   {      
      .pDT = val
      .WinMsg( $DTM_SETSYSTEMTIME, 0, &.pDT )
   }    
}

property datetime vDateTimePick.DateTime<result>
{   
   result = .pDT
}


/*------------------------------------------------------------------------------
   Virtual methods
*/
method vDateTimePick vDateTimePick.mCreateWin <alias=vDateTimePick_mCreateWin>()
{
   uint exstyle
   uint style = /*$ES_AUTOHSCROLL |*/ $WS_CHILD | $WS_CLIPSIBLINGS 
   style |= .iGetFormat()
   if .pShowUpDown : style |= $DTS_UPDOWN

   .CreateWin( "SysDateTimePick32".ustr(), exstyle, style )   
   this->vCtrl.mCreateWin()
   .iSetCustomFormat()
   .WinMsg( $DTM_GETSYSTEMTIME, 0, &.pDT )
   return this
}

method uint vDateTimePick.mWinNtf <alias=vDateTimePick_mWinNtf>( winmsg wmsg )
{
   uint nmtv as wmsg.lpar->NMHDR 
   switch nmtv.code
   {
      case $DTN_DATETIMECHANGE
      {  
         .WinMsg( $DTM_GETSYSTEMTIME, 0, &.pDT )
         this.OnChange.Run( this )   
      }       
   }
   return 0
}
/*
method vDateTimePick.mFocus <alias=vDateTimePick_mFocus> ( evparValUint eu )
{
   this->vCtrl.mFocus( eu )
   if !.pMultiline && eu.val && !( GetKeyState($VK_LBUTTON) & 0x1000 )
   {      
      this.SelAll()
   }   
}

*/

method vDateTimePick vDateTimePick.mOwnerCreateWin <alias=vDateTimePick_mOwnerCreateWin>()
{
   .Virtual( $mReCreateWin )
   return this
}
/*------------------------------------------------------------------------------
   Registration
*/
method vDateTimePick vDateTimePick.init( )
{  
   this.pTypeId = vDateTimePick
   
/*   this.pBorder = 1*/
   this.pTabStop = 1
   this.pCanFocus = 1   
   /*this.loc.width = 100
   this.loc.height = 25
   this.pMaxLen = 0x8000*/       
   return this 
}  

func init_vDateTimePick <entry>()
{
   regcomp( vDateTimePick, "vDateTimePick", vCtrl, $vCtrl_last, 
      %{ %{ $mCreateWin,    vDateTimePick_mCreateWin },
         %{ $mWinNtf,       vDateTimePick_mWinNtf },
         %{$mOwnerCreateWin, vDateTimePick_mOwnerCreateWin }/*
         %{ $mWinCmd,       vDateTimePick_mWinCmd },
         %{ $mFocus,        vDateTimePick_mFocus },
         %{ $mSetName,      vDateTimePick_mSetName }*/
       },
      0->collection )   
      
ifdef $DESIGNING {
   cm.AddComp( vDateTimePick, 1, "Windows", "datetimepick" )
   
   cm.AddProps( vDateTimePick, %{ 
"TabOrder" , uint , 0,
"Format"   , uint , 0,
"ShowUpDown", uint, 0,
"CustomFormat", ustr, 0
/*"Text"     , ustr , 0,
"MaxLen"   , uint , 0,
"Border"   , uint , 1,
"Password" , uint , 0,
"Multiline", uint , 0,
"WordWrap" , uint , 0,
"ScrollBars", uint , 0,
"ReadOnly", uint, 0*/
   })
   
   cm.AddEvents( vDateTimePick, %{
"OnChange"      , "evparEvent"
   })
   
   cm.AddPropVals( vDateTimePick, "Format", %{ 
"dtpShort", $dtpShort,
"dtpLong" , $dtpLong,     
"dtpTime" , $dtpTime,
"dtpCustom", $dtpCustom
   })
}
}