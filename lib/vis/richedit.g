/******************************************************************************
*
* Copyright (C) 2004-2007, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: vis.richedit 24.09.09 0.0.A.
*
* Author: Alexander Krivonogov ( gentee )
*
******************************************************************************/

include { "edit.g" }

define {
ECOOP_SET				= 0x0001
ECOOP_OR				   = 0x0002
ECOOP_AND				= 0x0003
ECOOP_XOR				= 0x0004

ECO_AUTOWORDSELECTION	= 0x00000001
ECO_AUTOVSCROLL			= 0x00000040
ECO_AUTOHSCROLL			= 0x00000080
ECO_NOHIDESEL			= 0x00000100
ECO_READONLY			= 0x00000800
ECO_WANTRETURN			= 0x00001000
ECO_SAVESEL				= 0x00008000
ECO_SELECTIONBAR		= 0x01000000
ECO_VERTICAL			= 0x00400000

EM_STREAMIN				= ($WM_USER + 73)
EM_STREAMOUT			= ($WM_USER + 74)
EM_SETOPTIONS		   = ($WM_USER + 77)

SF_TEXT			= 0x0001
SF_RTF			= 0x0002
SF_RTFNOOBJS	= 0x0003
SF_TEXTIZED	   = 0x0004

SF_UNICODE		= 0x0010
}

type EDITSTREAM {
    uint dwCookie
    uint dwError
    uint pfnCallback
}

/* Компонента vRichEdit, порождена от vCtrl
События
   onChange - изменение текста
*/
type vRichEdit <inherit = vCtrl>
{  
//Hidden fields
   uint fNewText
   uint pBorder
   uint pChanged
   uint pReadOnly 
   ustr pText  
   //uint pPassword
   //uint pMaxLen
   uint pMultiline
   uint pWordWrap
   uint pScrollBars
   buf data
   uint offdata
   
//Events
   evEvent OnChange
}

/*
define <export>{
//Режим отображения полос прокрутки ScrollBars
   sbNone = 0 
   sbHorz = 1
   sbVert = 2
   sbBoth = 3
}
*/
/*------------------------------------------------------------------------------
   Public methods
*/

/*Метод Sel( uint start, uint len )
Выделить часть текста
start - позизия начала выделения
len - длина выделения в символах
*/
/*method vRichEdit.Sel( uint start, uint len )
{
   this.WinMsg( $EM_SETSEL, start, start + len ) 
} 
*/
/*Метод SelAll()
Выделить весь текст
*/
/*method vRichEdit.SelAll()
{
   this.Sel( 0, -1 )
}*/


/*------------------------------------------------------------------------------
   Properties
*/
/* Свойство uint ReadOnly - Get Set
Усотанавливает или определяет можно ли изменять текст
1 - текст изменять нельзя
0 - текст изменять можно
*/
property uint vRichEdit.ReadOnly 
{
   return this.pReadOnly
}

property  vRichEdit.ReadOnly( uint val )
{
   if val != this.pReadOnly
   {
      this.pReadOnly = val
      this.WinMsg( $EM_SETOPTIONS, $ECOOP_SET, $ECO_READONLY )
   }
}

/*Свойство ustr Text - Get Set
Получить, установить редактируемый текст
*/
/*method vRichEdit.iSetText()
{
   SetWindowText( this.hwnd, .pText.ptr() )   
}

method vRichEdit.iGetText()
{
   uint res = GetWindowTextLength( this.hwnd )
   .pText.reserve( res + 1 )
   GetWindowText( this.hwnd, .pText.ptr(), res + 1 )    
   .pText.setlen( res )
}

property ustr vRichEdit.Text <result>
{   
   result = .pText   
}

property vRichEdit.Text( ustr val )
{
   if val != .pText
   {
      .pText = val
      this.fNewText = 1      
      .iSetText()
      this.fNewText = 0
   }
}*/

/*Свойство ustr MaxLen - Get Set
Получить, установить максимальную длину текста в символах
*/
/*method vRichEdit.iSetMaxLen()
{
   this.WinMsg( $EM_LIMITTEXT, .pMaxLen )
}

property uint vRichEdit.MaxLen
{
   return this.pMaxLen//this.WinMsg( $EM_GETLIMITTEXT )
}

property vRichEdit.MaxLen( uint val )
{
   if .pMaxLen != val
   {
      .pMaxLen = val
      .iSetMaxLen()
   }   
}*/

/*Свойство ustr Password - Get Set
Получить, установить режим ввода пароля
1 - режим ввода пароля включен
0 - режим ввода параоля отключен
*/
/*property uint vRichEdit.Password
{   
   return  .pPassword
}

property vRichEdit.Password( uint val )
{
   if .pPassword != val
   {   
      .pPassword = val
      this.WinMsg( $EM_SETPASSWORDCHAR, ?( val,'*', 0 ))
      .Invalidate()
   }
}
*/
/*Свойство ustr Border - Get Set
Установить, получить наличие рамки у поля ввода
1 - рамка есть
0 - рамки нет
*/
property vRichEdit.Border( uint val )
{
   .pBorder = val
   uint style = GetWindowLong( this.hwnd, $GWL_EXSTYLE )
   if val : style |= $WS_EX_CLIENTEDGE
   else : style &= ~$WS_EX_CLIENTEDGE
   SetWindowLong( this.hwnd, $GWL_EXSTYLE, style )      
   SetWindowPos( this.hwnd, 0, 0, 0, 0, 0, $SWP_FRAMECHANGED | 
                  $SWP_NOACTIVATE | $SWP_NOZORDER | $SWP_NOMOVE | $SWP_NOSIZE )
}

property uint vRichEdit.Border
{   
   return .pBorder
}


/*Свойство ustr SelStart - Get Set
Получить, установить начало выделенного текста
*/
/*property uint vRichEdit.SelStart
{   
   uint start
   this.WinMsg( $EM_GETSEL, &start, 0 )
   return start  
}

property vRichEdit.SelStart( uint val )
{
   this.Sel( val, 0 )
}*/

/*Свойство ustr SelLen - Get Set
Получить, установить длину выделенного текста
*/
/*property uint vRichEdit.SelLen
{
   uint start, end   
   this.WinMsg( $EM_GETSEL, &start, &end )
   return end - start   
}

property vRichEdit.SelLen( uint val )
{
   this.Sel( this.SelStart, val )    
}*/

/*Свойство ustr SelStart - Get
Получить/вствавить вместо выделенный текст
*/
/*property ustr vRichEdit.SelText<result>
{
   uint start, end   
   this.WinMsg( $EM_GETSEL, &start, &end )
   result.substr( this.Text, start, end-start )
}

property vRichEdit.SelText( ustr val )
{
   uint start, end
   this.WinMsg( $EM_GETSEL, &start, &end )   
   this.pText.replace( start, end - start, val )
   .iSetText()
   this.WinMsg( $EM_SETSEL, start, start + *val )   
}
*/

/*Свойство uint Changed - Get, Set
Получить, установить признак изменения текста
*/
property uint vRichEdit.Changed
{
   return this.pChanged
}

property vRichEdit.Changed( uint val )
{
   this.pChanged = val
}


/*Свойство uint Multiline - Get, Set
Получить, установить многострочный режим
*/
property uint vRichEdit.Multiline
{
   return this.pMultiline
}

property vRichEdit.Multiline( uint val )
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
property uint vRichEdit.WordWrap
{
   return this.pWordWrap
}

property vRichEdit.WordWrap( uint val )
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
property uint vRichEdit.ScrollBars
{
   return this.pScrollBars
}

property vRichEdit.ScrollBars( uint val )
{
   if this.pScrollBars != val
   {
      this.pScrollBars = val
      .Virtual( $mReCreateWin )
   }
}

func uint EditStreamCallback( uint cookie, uint pbuf, uint cb, uint pcb )
{
   uint read1
   uint data as cookie->vRichEdit.data
   uint off  = cookie->vRichEdit.offdata
   read1 = min( cb, *data - off )
   mcopy( pbuf, data.ptr() + off, read1 )//*cookie->buf )
   pcb->uint = read1 //cookie->buf
   //cookie->vRichEdit.offdata = cookie->vRichEdit.offdata + read1
   uint x = &cookie->vRichEdit.offdata
   x->uint = x->uint + read1
   return 0 
}


property buf vRichEdit.Data <result>
{
}

property vRichEdit.Data( buf data )
{
   EDITSTREAM es
   .data = data
   .offdata = 0
   es.dwCookie = &this
   es.pfnCallback = callback( &EditStreamCallback, 4 )   
   SendMessage( .hwnd, $EM_STREAMIN, $SF_RTF | $SF_UNICODE, &es )     
}



/*func uint rtffile( uint wnd, str stemp )
{
   uint mask
   
   rtfi = 0

   mask = SendMessage( wnd, 0x0400 + 59 //$EM_GETEVENTMASK
                , 0, 0);
   SendMessage( wnd, 0x0400 + 69 // EM_SETEVENTMASK
                 , 0, mask | 0x04000000 // $ENM_LINK
                );
   SendMessage( wnd, 0x0400 + 91 //$EM_AUTOURLDETECT
               , 1, 0 )

   es.dwCookie = &stemp
   es.pfnCallback = callback( &EditStreamCallback, 4 )
   print("RTF \(*stemp)\n")
   SendMessage( wnd,0x0400 + 73 //$EM_STREAMIN
                , 2 //$SF_RTF
                , &es )
                
   SendMessage( wnd,0x0400 + 72 //$EM_SETTARGETDEVICE
             , 0, 0 )
   loadrtffile( wnd, stemp.ptr(), *stemp )
   return 1
}*/

/*------------------------------------------------------------------------------
   Virtual methods
*/
method vRichEdit vRichEdit.mCreateWin <alias=vRichEdit_mWin>()
{
   uint exstyle
   uint style = /*$ES_AUTOHSCROLL |*/ $WS_CHILD | $WS_CLIPSIBLINGS 
   /*if .pBorder : exstyle |= $WS_EX_CLIENTEDGE   
   if .pReadOnly : style |= $ES_READONLY
   //if .pPassword : style |= $ES_PASSWORD*/
   if .pMultiline  
   {
      style |= $ES_WANTRETURN | $ES_MULTILINE | $ES_AUTOVSCROLL
      if !.pWordWrap : style |= $ES_AUTOHSCROLL
   }    
   /*else : style |= $ES_AUTOHSCROLL
   if .pScrollBars & $sbHorz : style |= $WS_HSCROLL
   if .pScrollBars & $sbVert : style |= $WS_VSCROLL
   */
   .CreateWin( "RichEdit20W".ustr(), exstyle, style )   
   this->vCtrl.mCreateWin()
   //.iSetMaxLen()   
   //.iSetText()   
   return this
}

/*method uint vRichEdit.mWinCmd <alias=vRichEdit_mWinCmd>( uint ntfcmd, uint id )
{
   if ntfcmd == $EN_CHANGE  
   {
      this.pChanged = !this.fNewText
      .iGetText()
      this.OnChange.Run( this )       
   }
   return 0
}

method vRichEdit.mFocus <alias=vRichEdit_mFocus> ( evparValUint eu )
{
   this->vCtrl.mFocus( eu )
   if !.pMultiline && eu.val && !( GetKeyState($VK_LBUTTON) & 0x1000 )
   {      
      this.SelAll()
   }   
}*/

/*Виртуальный метод uint vRichEdit.mSetName - Установка заголовка в режиме проектирования
*/
/*method uint vRichEdit.mSetName <alias=vRichEdit_mSetName>( str newname )
{
ifdef $DESIGNING {   
   if !.p_loading && .Text == .Name
   {
      .Text = newname.ustr()
   }
}   
   return 1 
}
*/
/*------------------------------------------------------------------------------
   Registration
*/
method vRichEdit vRichEdit.init( )
{  
   this.pTypeId = vRichEdit
   LoadLibrary( "Riched20.dll".ptr() )
   //hres = LoadLibraryEx( "Riched20.dll".ptr(), 0, 0x00000002/*$LOAD_LIBRARY_AS_DATAFILE*/ )
   this.pBorder = 1
   this.pTabStop = 1
   this.pCanFocus = 1   
   this.loc.width = 100
   this.loc.height = 25
   //this.pMaxLen = 0x8000       
   return this 
}  

func init_vRichEdit <entry>()
{
   regcomp( vRichEdit, "vRichEdit", vCtrl, $vCtrl_last, 
      %{ %{ $mCreateWin,    vRichEdit_mWin }//,
   //      %{ $mWinCmd,       vRichEdit_mWinCmd },
   //      %{ $mFocus,        vRichEdit_mFocus },
    //     %{ $mSetName,      vRichEdit_mSetName }
       },
      0->collection )   
      
ifdef $DESIGNING {
   cm.AddComp( vRichEdit, 1, "Windows", "RichEdit" )
   
   cm.AddProps( vRichEdit, %{ 
//"TabOrder" , uint , 0,
//"Text"     , ustr , 0,
//"MaxLen"   , uint , 0,
"Border"   , uint , 1,
//"Password" , uint , 0,
"Multiline", uint , 0,
//"WordWrap" , uint , 0,
"ScrollBars", uint , 0,
"ReadOnly", uint, 0
   })
   
   cm.AddEvents( vRichEdit, %{
"OnChange"      , "evparEvent"
   })
   
   cm.AddPropVals( vRichEdit, "ScrollBars", %{ 
"sbNone", $sbNone,
"sbHorz", $sbHorz,     
"sbVert", $sbVert,
"sbBoth", $sbBoth
   })
}
}