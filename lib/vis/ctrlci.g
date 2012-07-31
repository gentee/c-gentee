/******************************************************************************
*
* Copyright (C) 2004-2007, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: vis.btnpic 22.07.08 0.0.A.
*
* Author: Alexander Krivonogov ( gentee )
*
******************************************************************************/

type PicText
{
   uint  pCtrl
   
   ustr  pLangCaption    
   uint  pPtrImage   
   uint  pLayout
   uint  pSpacing
   uint  pIndent
   uint  pWidth
   uint  pHeight
   
   uint  pWordWrap
   uint  pAutoSize
   uint  pContHorzAlign
   uint  pContVertAlign   
   
   uint  imgleft 
   uint  imgtop
   uint  txtleft
   uint  txttop
   uint  hFont
}

define <export>{
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
} 

method PicText.iCalc
{
   if .pCtrl
   {      
       //if .pCtrl->vCtrl.TypeName == "vBtnPic" : print( "iCalc\n" )
      //if !.hFont : .hFont = .pCtrl->vCtrl.WinMsg( $WM_GETFONT )
      int pw, ph, pt, pl
      int tw, th, tt, tl
      int cw, ch
      int hoff, voff
      int maxw, maxh
      
      int spc = .pSpacing
      int off = .pIndent
      
      RECT r
      uint dc = GetDC( 0 )
      
      if .pPtrImage
      {   
         pw = .pPtrImage->Image.Width
         ph = .pPtrImage->Image.Height                  
      }
      if !.pPtrImage || !*this.pLangCaption
      {
         spc = 0
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
                                    
      r.right = maxw = max( .pWidth - hoff, 10 )
      r.bottom = maxh = max( .pHeight - voff, 10 )
      
      SelectObject( dc, .hFont )
      DrawText( dc, .pLangCaption.ptr(), *this.pLangCaption, r, 
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
         .pCtrl->vCtrl.Width = cw + 2 * off //tw + hoff
         .pCtrl->vCtrl.Height = ch + 2 * off //th + voff
      }
      switch .pContHorzAlign
      {
         case $ptRight : hoff = .pWidth - cw - off
         case $ptCenter : hoff = ( .pWidth - cw )/2
         default : hoff = off 
      }
      switch .pContVertAlign
      {
         case $ptBottom : voff = .pHeight - ch - off
         case $ptVertCenter : voff = ( .pHeight - ch )/2
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
      
      .pCtrl->vCtrl.Invalidate()
   }
}

property PicText.Ctrl( vCtrl val )
{
   .pCtrl = &val
   .iCalc()   
}

property PicText.LangCaption( ustr val )
{
   if .pLangCaption != val
   {
      .pLangCaption = val
      .iCalc()
   }
}
   
property PicText.PtrImage( uint val )
{
   if .pPtrImage != val
   {
      .pPtrImage = val
      .iCalc()
   }
}

property PicText.Width( uint val )
{
   if .pWidth != val
   {
      .pWidth = val
      .iCalc()
   }
}

property PicText.Height( uint val )
{  
   if .pHeight != val
   {
      .pHeight = val
      .iCalc()
   }
}


property PicText.Layout( uint val ) 
{
   if .pLayout != val
   {
      .pLayout = val
      .iCalc()
   }
}

property uint PicText.Layout
{
   return .pLayout
}

property PicText.Spacing( uint val ) 
{
   if .pSpacing != val 
   {
      .pSpacing = val
      .iCalc()
   }
}

property uint PicText.Spacing
{
   return .pSpacing
}

property PicText.Indent( uint val ) 
{
   if .pIndent != val
   {
      .pIndent = val
      .iCalc()
   }
}

property uint PicText.Indent
{
   return .pIndent
}
   
property PicText.WordWrap( uint val ) 
{
   if .pWordWrap != val 
   {
      .pWordWrap = val
      .iCalc()
   }
}

property uint PicText.WordWrap
{
   return .pWordWrap
}   

property PicText.AutoSize( uint val ) 
{
   if .pAutoSize != val
   {
      .pAutoSize = val
      .iCalc()
   }
}

property uint PicText.AutoSize
{
   return .pAutoSize
}

property PicText.ContHorzAlign( uint val ) 
{
   if .pContHorzAlign != val
   {   
      .pContHorzAlign = val
      .iCalc()
   }
}

property uint PicText.ContHorzAlign
{
   return .pContHorzAlign
}

property PicText.ContVertAlign( uint val ) 
{
   if .pContVertAlign != val
   {
      .pContVertAlign = val
      .iCalc()
   }
} 

property uint PicText.ContVertAlign
{
   return .pContVertAlign
}
 
method PicText.FontChanged()
{   
   .hFont = .pCtrl->vCtrl.WinMsg( $WM_GETFONT )
   .iCalc()
} 
 
method PicText.Draw( uint hdc, uint left, uint top )
{
   RECT r
   
   SetBkMode( hdc, $TRANSPARENT )
   if .pPtrImage
   {  
      DrawIconEx( hdc, left + .imgleft, top + .imgtop , 
         ?( .pCtrl->vCtrl.Enabled, .pPtrImage->Image.hImage, .pPtrImage->Image.hDisImage ),
         .pPtrImage->Image.Width, .pPtrImage->Image.Height, 0, 0,
         $DI_COMPAT | $DI_NORMAL )      
   }
   
   r.left = left + .txtleft 
   r.top = top + .txttop 
   r.right = left + .pWidth 
   r.bottom = top + .pHeight     
   if !.pCtrl->vCtrl.Enabled
   {
      SetTextColor( hdc, GetSysColor(16) )
   }
   DrawText(hdc, .pLangCaption.ptr(), *.pLangCaption, r, $DT_TOP | $DT_LEFT | 
               ?( .pWordWrap, $DT_WORDBREAK, 0 ) | $DT_NOPREFIX )
   
}

/*Системный метод vHeader vHeader.init - Инициализация объекта
*/   
method PicText PicText.init( )
{      
   .pIndent = 5
   .pSpacing = 5
   .pContHorzAlign = $ptCenter
   .pContVertAlign = $ptVertCenter
   return this 
}

/* Компонента vCtrlCI, порождена от vCtrl
События
*/
type vCtrlCI <inherit = vCtrl>
{
//Hidden Fields
   PicText    pPicText
   
   locustr pCaption
   //ustr    pLangCaption
   ustr    pImage   
   //uint    ptrImage
//Events      
}


/*------------------------------------------------------------------------------
   Internal Methods
*/
/*Внутренний метод vCtrlCI.iUpdateImage()
Обновить картинку
*/
method vCtrlCI.iUpdateImage()
{  
   .pPicText.PtrImage = &this.GetImage( .pImage )
   /*uint oldimage = .ptrImage   
   .ptrImage = &this.GetImage( .pImage )
   if oldimage != .ptrImage : .Virtual( $mSetImage, .ptrImage )*/ 
}

/*Внутренний метод vCtrlCI.iUpdateImage()
Обновить заголовок
*/
method vCtrlCI.iUpdateCaption()
{  
   .pPicText.LangCaption = this.pCaption.Text( this )
   /*ustr oldcaption = .pLangCaption
   .pLangCaption = this.pCaption.Text( this )
   if oldcaption != .pLangCaption : .Virtual( $mSetCaption, &.pLangCaption )*/ 
}

/*------------------------------------------------------------------------------
   Properties
*/
/* Свойство ustr vCtrlCI.Image - Get Set
Устанавливает или получает картинку
*/
property ustr vCtrlCI.Image <result>
{
   result = this.pImage
}

property vCtrlCI.Image( ustr val )
{
   if val != this.pImage
   {    
      this.pImage = val      
      .iUpdateImage()
   } 
}

/* Свойство str vCtrlCI.Caption - Get Set
Усотанавливает или получает заколовок
*/
property ustr vCtrlCI.Caption <result>
{
   result = this.pCaption.Value
}

property vCtrlCI.Caption( ustr val )
{
   if val != this.pCaption.Value
   { 
      this.pCaption.Value = val
      .iUpdateCaption()
   } 
}

/*------------------------------------------------------------------------------
   Virtual Methods
*/
/*Виртуальный метод uint vCtrlCI.mLangChanged 
Изменение текущего языка
*/
method vCtrlCI.mLangChanged <alias=vCtrlCI_mLangChanged>()
{   
   this->vCtrl.mLangChanged()
   .iUpdateCaption()  
   .iUpdateImage()
}

/*Виртуальный метод vLabel.mSetName
Установка заголовка в режиме проектирования
*/
method uint vCtrlCI.mSetName <alias=vCtrlCI_mSetName>( str newname )
{
ifdef $DESIGNING {   
   if !.p_loading && .Caption == .Name
   {
      .Caption = newname.ustr()
   }
}   
   return 1 
}

/*Виртуальный метод vCtrlCI vCtrlCI.mFontChanged - изменение шрифта окна
*/
/*method vCtrlCI.mFontChanged <alias=vCtrlCI_mFontChanged> ()
{ 
   this->vCtrl.mFontChanged()
   .pPicText.hFont = .WinMsg( $WM_GETFONT )
}*/

/*------------------------------------------------------------------------------
   Registration
*/
/*Системный метод vCtrlCI vCtrlCI.init - Инициализация объекта
*/   
method vCtrlCI vCtrlCI.init( )
{   
   this.pTypeId = vCtrlCI        
   return this 
}  


func init_vCtrlCI <entry>()
{  
   regcomp( vCtrlCI, "vCtrlCI", vCtrl, $vCtrl_last, 
      %{ 
         %{$mSetName,        vCtrlCI_mSetName }, 
         %{$mLangChanged,    vCtrlCI_mLangChanged }/*,
         %{$mFontChanged,    vCtrlCI_mFontChanged }*/
      }, 
      0->collection )
}




