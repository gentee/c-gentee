/******************************************************************************
*
* Copyright (C) 2004-2007, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: vis.panel 17.07.07 0.0.A.
*
* Author: Alexander Krivonogov ( gentee )
*
******************************************************************************/
/* Компонента vPanel, порождена от vCtrl
События   
*/
type vPanel <inherit = vCtrl>
{
//Hidden fields
   locustr  pCaption  
   uint     pBorder
}

define <export>{
//Стили рамки панели Border
   brdNone       = 0
   brdRaised     = 1   
   brdLowered    = 2
   brdDblRaised  = 3
   brdDblLowered = 4
   brdGroupBox   = 5   
}

/*------------------------------------------------------------------------------
   Internal Methods
*/
/* Метод iUpdateCaption
Связывает заголовок панели с визуальным отображением
*/
method vPanel.iUpdateCaption
{
   SetWindowText( this.hwnd, this.pCaption.Text( this ).ptr() )  
}


/*------------------------------------------------------------------------------
   Properties
*/
/* Свойство str vPanel.Caption - Get Set
Усотанавливает или получает заколовок панели
*/
property ustr vPanel.Caption <result>
{
   result = this.pCaption.Value
}

property vPanel.Caption( ustr val )
{
   if val != this.pCaption.Value
   { 
      this.pCaption.Value = val
      .iUpdateCaption()
   } 
}

/* Свойство uint Border - Get Set
Усотанавливает или определяет рамку панели
Возможны следующие варианты:
brdNone        - нет рамки,
brdRaised      - рамка выпуклая,
brdLowered     - рамка вдавленная,
brdDblRaised   - рамка двойная выпуклая,
brdDblLowered  - рамка двойная вдавленная,
brdGroupBox    - в виде группы элементов
*/
property uint vPanel.Border()
{
   return this.pBorder
}

property vPanel.Border( uint val )
{  
   uint style
   
   if this.pBorder != val
   {
      if val == $brdGroupBox || this.pBorder == $brdGroupBox
      {
         this.pBorder = val
         .Virtual( $mReCreateWin ) 
      }
      else
      {
         this.pBorder = val         
         style = GetWindowLong( this.hwnd, $GWL_EXSTYLE )
         style &= ~( $WS_EX_STATICEDGE | $WS_EX_WINDOWEDGE | $WS_EX_CLIENTEDGE | 
                     $WS_EX_DLGMODALFRAME)
         switch val
         {         
            case $brdLowered, $brdRaised :  style |= $WS_EX_STATICEDGE             	
            case $brdDblRaised :  style |= $WS_EX_DLGMODALFRAME   
            case $brdDblLowered :  style |= $WS_EX_CLIENTEDGE         
         }
         SetWindowLong( this.hwnd, $GWL_EXSTYLE, style )      
         SetWindowPos( this.hwnd, 0, 0, 0, 0, 0, $SWP_FRAMECHANGED | 
                     $SWP_NOACTIVATE | $SWP_NOZORDER | $SWP_NOMOVE | $SWP_NOSIZE )      
      }   
   }     
}

/*------------------------------------------------------------------------------
   Virtual methods
*/
/*Виртуальный метод vPanel vPanel.mCreateWin - Создание окна
*/
method vPanel vPanel.mCreateWin <alias=vPanel_mCreateWin>()
{
   if .pBorder == $brdGroupBox
   {       
      .CreateWin( "BUTTON".ustr(), /*$WS_EX_CONTROLPARENT*//*0x00010000*/0/*$WS_EX_TRANSPARENT*/, 
        $BS_GROUPBOX | $WS_CHILD | $WS_CLIPCHILDREN | $WS_CLIPSIBLINGS | $WS_OVERLAPPED )
      //setxpstyle( this.hwnd )         
   }
   else   
   {
      uint exstyle //= $WS_EX_CONTROLPARENT
      switch .pBorder
      {  
         case $brdLowered, $brdRaised:  exstyle |= $WS_EX_STATICEDGE             	
         case $brdDblRaised  :  exstyle |= $WS_EX_DLGMODALFRAME   
         case $brdDblLowered :  exstyle |= $WS_EX_CLIENTEDGE         
      }
      .CreateWin( "STATIC".ustr(), exstyle, 
         $SS_NOTIFY | $WS_CHILD | $WS_CLIPCHILDREN | $WS_CLIPSIBLINGS | $WS_OVERLAPPED )
     //.CreateWin( "STATIC".ustr(), exstyle, $WS_CHILD | //$WS_CLIPCHILDREN | 
     //$WS_CLIPSIBLINGS | $WS_OVERLAPPED )//| 0x004 )    
   }
   
   this->vCtrl.mCreateWin()   
   .iUpdateCaption()
/*   LOGFONT lf 
   with lf
   {
      .lfHeight = 10 
      .lfWidth  = 20
      .lfEscapement =0
      .lfOrientation =0
      .lfWeight = 400
      .lfItalic =0
      .lfUnderline=0 
      .lfStrikeOut =0
      .lfCharSet =0
      .lfOutPrecision=0 
      .lfClipPrecision =0
      .lfQuality =1
      .lfPitchAndFamily=0 
      mcopy( &.lfFaceName, "Times".ustr().ptr(), 10) 
   }

      uint f = CreateFontIndirect( lf )
      print( "font \(f)\n" )
   this.WinMsg( $WM_SETFONT, f )  */                                                         
   return this
}

/*Виртуальный метод vPanel.mSetName - Установка заголовка в режиме проектирования
*/
method uint vPanel.mSetName <alias=vPanel_mSetName>( str newname )
{
ifdef $DESIGNING {   
   if !.p_loading && .Caption == .Name
   {      
      .Caption = newname.ustr()
   }
}   
   return 1 
}

/*Виртуальный метод uint vCustomBtn.mLangChanged - Изменение текущего языка
*/
method vPanel.mLangChanged <alias=vPanel_mLangChanged>()
{
   //.Virtual( $mUpdateCaption )
   this->vCtrl.mLangChanged()
   .iUpdateCaption()  
}

/*Виртуальный метод uint vPanel.wmpaint - отрисовка панели 
*/
method uint vPanel.wmpaint <alias=vPanel_wmpaint>(winmsg wmsg)
{  
   if .pBorder == $brdGroupBox
   {    
   	uint hdc
   	PAINTSTRUCT lp   
      hdc = BeginPaint( this.hwnd, lp )
      RECT r
      r.left = 0
      r.top = 0
      r.right = this.loc.width
      r.bottom = this.loc.height   
      FillRect( hdc, r, $COLOR_BTNFACE + 1 )                       
   	EndPaint( this.hwnd, lp )
      .Invalidate()                  
   }   
	return 0	   
}

/*Виртуальный метод uint vPanel.wmncpaint - отрисовка неклиенсткой части панели 
*/
method uint vPanel.wmncpaint <alias=vPanel_wmncpaint>(winmsg wmsg)
{  
   if .pBorder == $brdRaised
   {        
   	uint hdc   	   
      //dc = GetDCEx( this.hwnd, wmsg.wpar, $DCX_WINDOW | $DCX_INTERSECTRGN )
      //GetDCEx не работает
      PAINTSTRUCT lp         
      hdc = GetWindowDC( this.hwnd )
            
      RECT r
      GetWindowRect( this.hwnd, r )
      r.right = r.right - r.left
      r.bottom = r.bottom - r.top
      r.left = 0
      r.top = 0            
      DrawEdge( hdc, r, 4, 0xf )
   	ReleaseDC( this.hwnd, hdc )      
      wmsg.flags = 1      
   }   
	return 0	   
}

/*method uint vPanel.wmclcolorbtn <alias=vPanel_wmclcolorbtn>(winmsg wmsg )
{
   if isThemed 
   {
      pDrawThemeParentBackground->stdcall( getctrl(wmsg.lpar).hwnd, wmsg.wpar, 0 )
      wmsg.flags = 1
      return GetStockObject(5)
   }
   return 0
}

method uint vPanel.wmerasebkgnd <alias=vPanel_wmerasebkgnd>( winmsg wmsg )
{
   if isThemed
   {   
      pDrawThemeParentBackground->stdcall( this.hwnd, wmsg.wpar, 0 )
      wmsg.flags = 1
      return 1
   }
   return 0   
}*/
/*------------------------------------------------------------------------------
   Registration
*/
method vPanel vPanel.init( )
{
   this.pTypeId = vPanel
   this.pCanContain = 1
   this.flgXPStyle = 1
   this.pBorder = $brdRaised  
   this.loc.width = 100
   this.loc.height = 100
   return this 
}  

func init_vPanel <entry>()
{  
   regcomp( vPanel, "vPanel", vCtrl, $vCtrl_last,
      %{ %{$mCreateWin, vPanel_mCreateWin },
         %{$mSetName,   vPanel_mSetName },
         %{$mLangChanged,  vPanel_mLangChanged }
      },
      %{ %{ $WM_PAINT, vPanel_wmpaint },
         %{ $WM_NCPAINT, vPanel_wmncpaint }}/*,
         //%{$WM_CTLCOLORSTATIC, vPanel_wmclcolorbtn },
         //%{$WM_ERASEBKGND, vPanel_wmerasebkgnd }}*/ )

ifdef $DESIGNING {      
   cm.AddComp( vPanel, 1, "Windows", "panel" )
   
   cm.AddProps( vPanel, %{ 
//"TabOrder", uint, 0,
"Caption" , ustr, 0,
"Border"  , uint, 0
   })            

   cm.AddPropVals( vPanel, "Border", %{  
"brdNone"         ,  $brdNone      ,
"brdRaised"       ,  $brdRaised ,
"brdLowered"      ,  $brdLowered   ,       
"brdDblRaised"    ,  $brdDblRaised ,
"brdDblLowered"   ,  $brdDblLowered,
"brdGroupBox"     ,  $brdGroupBox
   })
}
}