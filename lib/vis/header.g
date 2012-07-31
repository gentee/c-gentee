/******************************************************************************
*
* Copyright (C) 2004-2007, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: vis.headerpic 22.07.08 0.0.A.
*
* Author: Alexander Krivonogov ( gentee )
*
******************************************************************************/

include { "ctrlci.g" }

/* Компонента vHeader, порождена от vCtrl
*/
type vHeader <inherit = vCtrlCI>
{
//Hidden Fields   
//   uint     pLayout  
//   uint     pContVertAlign
//   uint     pContHorzAlign   
//   uint     pIndent
//   uint     pSpacing
//   uint     pWordWrap
//   uint     pAutoSize
     
//   uint     imgleft 
//   uint     imgtop
//   uint     txtleft
//   uint     txttop   
//Events      
}



/*define <export>{
//Расположение картинки и текста
   lPicLeft     = 0 
   lPicTop      = 1
   lPicRight    = 2
   lPicBottom   = 3
   lPicBack     = 4
   lPicSimple   = 5
   
   ptLeft       = 0
   ptCenter     = 1   
   ptRight      = 2
   
   ptTop        = 0
   ptVertCenter = 1
   ptBottom     = 2         
}*/

/*------------------------------------------------------------------------------
   Internal Methods
*/
/*Внутренний метод vHeader.iUpdateLayout 
Связывает взаимное расположение текста и картинки с визуальным отображением
*/
/*method vHeader.iUpdateLayout
{
   int pw, ph, pt, pl
   int tw, th, tt, tl
   int cw, ch
   int hoff, voff
   int maxw, maxh
   
   int spc = .pSpacing
   int off = .pIndent
   
   RECT r
   uint dc = GetDC( 0 )
   
   if .ptrImage
   {   
      pw = .ptrImage->Image.Width
      ph = .ptrImage->Image.Height                  
   }
   hoff = voff = off * 2
   if pw && ph
   {
      switch .pLayout 
      {
         case $lPicTop, $lPicBottom:  voff += ph + spc    
         case $lPicBack: 
         default : hoff += pw + spc
      }
   }
                                 
   r.right = maxw = max( .clloc.width - hoff, 10 )
   r.bottom = maxh = max( .clloc.height - voff, 10 )
   
   SelectObject( dc, this.WinMsg( $WM_GETFONT ) )
   DrawText( dc, this.pLangCaption.ptr(), *this.pLangCaption, r, 
         $DT_TOP | $DT_LEFT | $DT_CALCRECT | ?( .pWordWrap, $DT_WORDBREAK, 0 ) |
         $DT_NOPREFIX )
   
   ReleaseDC( 0, dc )
   tw = r.right
   th = r.bottom
   
   switch .pLayout
   {
      case $lPicTop
      {
         pt = 0
         if ph : tt = ph + spc
         cw = min( max( tw, pw ), maxw )
         ch = tt + th 
         pl = (cw - pw) / 2
         tl = (cw - tw) / 2        
      }
      case $lPicBottom
      {         
         tt = 0
         if th : pt = th + spc
         cw = min( max( tw, pw ), maxw )
         ch = pt + ph
         pl = (cw - pw) / 2
         tl = (cw - tw) / 2          
      }
      case $lPicLeft
      {
         pl = 0 
         if pw : tl = pw + spc
         cw = tl + tw 
         ch = min( max( th, ph ), maxh )  
         tt = (ch - th) / 2
         pt = (ch - ph) / 2
      }
      case $lPicRight
      {  
         tl = 0 
         if tw : pl = tw + spc         
         cw = pl + pw
         ch = min( max( th, ph ), maxh )
         tt = (ch - th) / 2
         pt = (ch - ph) / 2      
      }          
      case $lPicBack
      {         
         cw = min( max( tw, pw ), maxw )
         ch = min( max( th, ph ), maxh )
         pl = (cw - pw) / 2
         pt = (ch - ph) / 2
         tl = (cw - tw) / 2
         tt = (ch - th) / 2         
      }
      default
      {   
         pl = 0
         if pw : tl = pw + spc
         pt = 0 
         tt = 0
         cw = tl + tw
         ch = max( th, ph )                  
      }
   }
   
   if .pAutoSize
   {
      .Width = cw + 2 * off //tw + hoff
      .Height = ch + 2 * off //th + voff
   }
   switch .pContHorzAlign
   {
      case $ptRight : hoff = .clloc.width - cw - off
      case $ptCenter : hoff = ( .clloc.width - cw )/2
      default : hoff = off 
   }
   switch .pContVertAlign
   {
      case $ptBottom : voff = .clloc.height - ch - off
      case $ptVertCenter : voff = ( .clloc.height - ch )/2
      default : voff = off
   }   
   hoff = max( hoff, off )
   voff = max( voff, off )
   //print( "tw \(tw) \(th) \(pw) \(ph) \n" )
   //print( "i \(pl) \(pt) \(tl) \(tt ) \(hoff ) \(voff)\n" )
   .imgleft = max( pl + hoff, 0 )
   .imgtop = max( pt + voff, 0 )
   .txtleft = max( tl + hoff, 0 )
   .txttop = max( tt + voff, 0 )
   
   .Invalidate()  
}*/


/*------------------------------------------------------------------------------
   Properties
*/
/* Свойство str vHeader.Layout - Get Set
Усотанавливает или получает взаимное расположение картинки текста
*/
property uint vHeader.Layout
{
   //return this.pLayout
   return .pPicText.Layout
}

property vHeader.Layout( uint val )
{
   .pPicText.Layout = val
   /*if val != this.pLayout
   {
      this.pLayout = val
      .iUpdateLayout()
   }*/
}

/* Свойство str vHeader.ContHorzAlign - Get Set
Устанавливает или получает расположение содежимого по горизонтали
*/
property uint vHeader.ContHorzAlign 
{
   //return this.pContHorzAlign
   return .pPicText.ContHorzAlign
}

property vHeader.ContHorzAlign( uint val )
{
/*   if val != .pContHorzAlign
   { 
      .pContHorzAlign = val
      .iUpdateLayout()
   }*/
   .pPicText.ContHorzAlign = val 
}

/* Свойство str vHeader.ContVertAlign - Get Set
Устанавливает или получает расположение содежимого по вертикали
*/
property uint vHeader.ContVertAlign 
{
   //return this.pContVertAlign
   return .pPicText.ContVertAlign
}

property vHeader.ContVertAlign( uint val )
{
   /*if val != .pContVertAlign
   { 
      .pContVertAlign = val
      .iUpdateLayout()
   } */
   .pPicText.ContVertAlign = val
}

/* Свойство str vHeader.Indent - Get Set
Устанавливает или получает отступ от края
*/
property uint vHeader.Indent
{
//   return this.pIndent
   return .pPicText.Indent
}

property vHeader.Indent( uint val )
{
   /*if val != .pIndent
   { 
      .pIndent = max( min( val, 25 ), 0 )
      .iUpdateLayout()
   } */
   .pPicText.Indent = val
}

/* Свойство str vHeader.Spacing - Get Set
Устанавливает или получает отступ между картинкой и текстом
*/
property uint vHeader.Spacing 
{
   //return this.pSpacing
   return .pPicText.Spacing 
}

property vHeader.Spacing( uint val )
{
   /*if val != .pSpacing 
   { 
      .pSpacing = max( min( val, 25 ), 0 )
      .iUpdateLayout()
   } */
   .pPicText.Spacing = val
}


/* Свойство str vHeader.WordWrap - Get Set
Режим переноса по словам
*/
property uint vHeader.WordWrap
{
   //return this.pWordWrap
   return .pPicText.WordWrap
}

property vHeader.WordWrap( uint val )
{
   /*if val != .pWordWrap
   { 
      .pWordWrap = val
      .iUpdateLayout()
   } */
   .pPicText.WordWrap = val
}

/* Свойство str vHeader.AutoSize - Get Set
Автоматическое изменение размеров
*/
property uint vHeader.AutoSize
{
   //return this.pAutoSize
   return .pPicText.AutoSize
}

property vHeader.AutoSize( uint val )
{
   /*if val != .pAutoSize
   { 
      .pAutoSize = val
      .iUpdateLayout()
   } */
   .pPicText.AutoSize = val
}
 
/*------------------------------------------------------------------------------
   Windows messages 
*/
/*Метод обработки сообщений uint vPanel.wmpaint 
Отрисовка заголовка 
*/
method uint vHeader.wmpaint <alias=vHeader_wmpaint>(winmsg wmsg)
{  
   uint hdc
   PAINTSTRUCT lp
   RECT r
   uint hbrush
      
   hdc = BeginPaint( this.hwnd, lp )   
   winmsg msg
   msg.wpar = hdc
   SelectObject( hdc, .pPicText.hFont )//this.WinMsg( $WM_GETFONT ) )      
   hbrush = .Virtual( $mClColor, &msg )
   
   if hbrush || !isThemed
   {
      if !hbrush : hbrush = $COLOR_BTNFACE + 1   
      r.left = 0
      r.top = 0
      r.right = this.loc.width
      r.bottom = this.loc.height   
      FillRect( hdc, r, hbrush )
   } 
   
   .pPicText.Draw( hdc, 0, 0 )
   /*SetBkMode( hdc, $TRANSPARENT )  
   if .ptrImage
   {  
      DrawIconEx( hdc, .imgleft, .imgtop , 
         ?( .Enabled, .ptrImage->Image.hImage, .ptrImage->Image.hDisImage ),
         .ptrImage->Image.Width, .ptrImage->Image.Height, 0, 0,
         $DI_COMPAT | $DI_NORMAL )      
   }
   
   r.left = .txtleft 
   r.top = .txttop 
   r.right = .clloc.width 
   r.bottom = .clloc.height     
   if !.Enabled
   {
      SetTextColor( hdc, GetSysColor(16) )
   }
   DrawText(hdc, .pLangCaption.ptr(), *.pLangCaption, r, $DT_TOP | $DT_LEFT | 
               ?( .pWordWrap, $DT_WORDBREAK, 0 ) | $DT_NOPREFIX )
   */                                                
   EndPaint( this.hwnd, lp )                        
   
	return 0	   
}

/*------------------------------------------------------------------------------
   Virtual Methods
*/
/*Виртуальный метод vHeader vHeader.mCreateWin - Создание окна
*/
method vHeader vHeader.mCreateWin <alias=vHeader_mCreateWin>()
{
   .CreateWin( "STATIC".ustr(), 0, 
         $SS_NOTIFY | $WS_CHILD | $WS_CLIPCHILDREN | 
         $WS_CLIPSIBLINGS | $WS_OVERLAPPED )   
   this->vCtrl.mCreateWin()   
   
   //.pPicText.hFont = .WinMsg( $WM_GETFONT )
   //this.pPicText.Ctrl = this
   //.iUpdateLayout()                                                        
   return this
}


//Виртуальный метод vHeader.mSetCaption - Обновить заголовок

/*method vHeader.mSetCaption <alias=vHeader_mSetCaption>( ustr caption )
{
   .iUpdateLayout()  
}

//Виртуальный метод vHeader.mSetImage - Обновить картинку

method vHeader.mSetImage <alias=vHeader_mSetImage>( Image img )
{
   .iUpdateLayout()     
}*/

/*Виртуальный метод vHeader.mPosChanged - Изменились размеры
*/
method vHeader.mPosChanged <alias=vHeader_mPosChanged>(evparEvent ev)
{
   this->vCtrl.mPosChanged(ev)
   .pPicText.Width = .clloc.width
   .pPicText.Height = .clloc.height
   /*if !.pAutoSize
   {
      .iUpdateLayout()
   }*/
}

/*Виртуальный метод vHeader.mFontChanged - Изменился шрифт
*/
method vHeader.mFontChanged <alias=vHeader_mFontChanged>()
{
   this->vCtrl.mFontChanged()
   .pPicText.FontChanged()   
}

/*------------------------------------------------------------------------------
   Registration
*/
/*Системный метод vHeader vHeader.init - Инициализация объекта
*/   
method vHeader vHeader.init( )
{   
   this.pTypeId = vHeader   
   this.loc.width = 100
   this.loc.height = 25
   this.flgXPStyle = 1 
   
   this.pPicText.Ctrl = this
/*   this.pPicText.pIndent = 5
   this.pPicText.pSpacing = 5*/
   return this 
} 

func init_vHeader <entry>()
{  
   regcomp( vHeader, "vHeader", vCtrlCI, $vCtrl_last, 
      %{ %{$mCreateWin,      vHeader_mCreateWin },
         %{$mPosChanged,     vHeader_mPosChanged },
         %{$mFontChanged,     vHeader_mFontChanged }          
         //%{$mSetCaption,     vHeader_mSetCaption},
         //%{$mSetImage  ,     vHeader_mSetImage}
      }, 
      %{
         %{$WM_PAINT, vHeader_wmpaint } } )

            
ifdef $DESIGNING {
   cm.AddComp( vHeader, 1, "Additional", "header" )   
   
   cm.AddProps( vHeader, %{ 
"Image"   , ustr, 0,
"Caption" , ustr, 0,
"Layout"  , uint, 0,
"ContVertAlign", uint, 0,
"ContHorzAlign", uint, 0,
"Indent"  , uint, 0,
"Spacing" , uint, 0,
"WordWrap", uint, 0,
"AutoSize", uint, 0
   }) 

   cm.AddPropVals( vHeader, "Layout", %{ 
"lPicLeft",   $lPicLeft,  
"lPicTop",    $lPicTop,   
"lPicRight",  $lPicRight, 
"lPicBottom", $lPicBottom,
"lPicBack",   $lPicBack,
"lPicSimple", $lPicSimple
   })
   
   cm.AddPropVals( vHeader, "ContHorzAlign", %{
"ptLeft",    $ptLeft,     
"ptCenter",  $ptCenter,   
"ptRight",   $ptRight
   })    
   
   cm.AddPropVals( vHeader, "ContVertAlign", %{      
"ptTop",        $ptTop,                        
"ptVertCenter", $ptVertCenter,          
"ptBottom",     $ptBottom
   })    
}
      
}
