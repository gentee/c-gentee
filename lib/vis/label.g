/******************************************************************************
*
* Copyright (C) 2004-2007, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: vis.label 10.12.07 0.0.A.
*
* Author: Alexander Krivonogov ( gentee )
*
******************************************************************************/
/* Компонента vLabel, порождена от vCtrl
События   
*/
type vLabel <inherit = vCtrl>
{
//Hidden fields
   locustr  pCaption
   ustr     pResCaption
   uint     pTextHorzAlign
   uint     pTextVertAlign
   uint     pAutoSize
   uint     pWordWrap
   uint     brush
}

define <export>{
//Типы выравнивания текста
   talhLeft       = 0
   talhCenter     = 1   
   talhRight      = 2
   talvTop        = 0
   talvCenter     = 1   
}

/*------------------------------------------------------------------------------
   Internal Methods
*/
/* Метод iUpdateCaption
Связывает заголовок панели с визуальным отображением
*/
//method vLabel.iUpdateCaption
method vLabel.mSetCaption <alias=vLabel_mSetCaption>( ustr caption )
{  
   .pResCaption = caption   
   //SetWindowText( this.hwnd, .pResCaption.ptr() )
   this->vCtrl.mSetCaption( caption )  
}

/* Метод iUpdateAlignment
Связывает выравнивание текста 
*/
method vLabel.iUpdateAlignment
{
   uint style
   .SetStyle( $SS_RIGHT | $SS_CENTER | $SS_CENTERIMAGE, 0 )
   if .pWordWrap
   {
      switch .pTextHorzAlign
      {  
         case $talhLeft:
         case $talhCenter: style = $SS_CENTER 
         case $talhRight: style = $SS_RIGHT
         
      }
   }
   switch .pTextVertAlign 
   {  
      case $talvTop: 
      case $talvCenter: style |= $SS_CENTERIMAGE    
   }
   .SetStyle( style, 1 )   
   
}

/* Метод iUpdateSize
Автоматическое определение ширины/высоты текста
*/
method vLabel.iUpdateSize
{
   if .pAutoSize
   {      
      RECT r
      uint dc = GetDC( 0 )
      
      r.right = .clloc.width
      r.bottom = .clloc.height 
      
      SelectObject( dc, this.WinMsg( $WM_GETFONT ) ) 
      DrawText( dc, .pResCaption.ptr(), *.pResCaption, r, 
            $DT_CALCRECT | ? (.pWordWrap, $DT_WORDBREAK, 0  ))      
      ReleaseDC( 0, dc )
      
      if .pWordWrap :.Height = r.bottom      
      else 
      {
         .Height = r.bottom
         .Width = r.right
      }          
   }
}
/*------------------------------------------------------------------------------
   Properties
*/
/* Свойство str vLabel.Caption - Get Set
Усотанавливает или получает заколовок панели
*/
property ustr vLabel.Caption <result>
{
   result = this.pCaption.Value
}

property vLabel.Caption( ustr val )
{
   if val != this.pCaption.Value
   {       
      this.pCaption.Value = val
      //.iUpdateCaption()      
      .Virtual( $mSetCaption, this.pCaption.Text(this) )
      .iUpdateSize()      
   } 
}

/* Свойство str vLabel.TextHorzAlign - Get Set
Усотанавливает или получает выравнивание текста
*/
property uint vLabel.TextHorzAlign 
{
   return this.pTextHorzAlign
}

property vLabel.TextHorzAlign( uint val )
{
   if val != this.pTextHorzAlign
   { 
      this.pTextHorzAlign = val
      .iUpdateAlignment()
   } 
}

/* Свойство str vLabel.TextVertAlign - Get Set
Усотанавливает или получает выравнивание текста
*/
property uint vLabel.TextVertAlign 
{
   return this.pTextVertAlign
}

property vLabel.TextVertAlign( uint val )
{
   if val != this.pTextVertAlign
   { 
      this.pTextVertAlign = val
      .iUpdateAlignment()
   } 
}

/* Свойство str vLabel.AutoSize - Get Set
Усотанавливает или получает автоматическое изменение размеров
*/
property uint vLabel.AutoSize 
{
   return this.pAutoSize
}

property vLabel.AutoSize( uint val )
{
   if val != this.AutoSize
   { 
      this.pAutoSize = val
      .iUpdateSize()              
   } 
}

/* Свойство str vLabel.WordWrap - Get Set
Усотанавливает или получает автоматическое изменение размеров
*/
property uint vLabel.WordWrap 
{
   return this.pWordWrap
}

property vLabel.WordWrap( uint val )
{
   if val != this.WordWrap
   { 
      this.pWordWrap = val
      .iUpdateAlignment()
      .iUpdateSize() 
      .SetStyle( $SS_LEFTNOWORDWRAP, !val )
   } 
}

/*------------------------------------------------------------------------------
   Virtual methods
*/
/*Виртуальный метод vLabel vLabel.mCreateWin - Создание окна
*/
method vLabel vLabel.mCreateWin <alias=vLabel_mCreateWin>()
{
   uint style = /*$SS_ENDELLIPSIS |*/ /*$WS_CLIPCHILDREN | */$SS_NOTIFY | $WS_CHILD  | $WS_CLIPSIBLINGS /*| $WS_OVERLAPPED*/
   if !.pWordWrap : style |= $SS_LEFTNOWORDWRAP 
   style |= $SS_CENTER | $SS_CENTERIMAGE
   .CreateWin( "STATIC".ustr(), 0, style )
   this->vCtrl.mCreateWin()
   //.iUpdateCaption()
   .Virtual( $mSetCaption, this.pCaption.Text(this) ) 
   .iUpdateAlignment()
   .iUpdateSize()
   //this.WinMsg( $WM_SETFONT, GetStockObject( $DEFAULT_GUI_FONT ) )
   
   /*LOGBRUSH lb
   lb.lbColor = 0x02000000
   .brush = CreateBrushIndirect( lb )*/
   return this
}

/*Виртуальный метод vLabel.mSetName - Установка заголовка в режиме проектирования
*/
method uint vLabel.mSetName <alias=vLabel_mSetName>( str newname )
{
ifdef $DESIGNING {   
   if !.p_loading && .Caption == .Name
   {
      .Caption = newname.ustr()
   }
}   
   return 1 
}

/*Виртуальный метод uint vLabel.mLangChanged - Изменение текущего языка
*/
method vLabel.mLangChanged <alias=vLabel_mLangChanged>()
{   
   //.iUpdateCaption()
   .Virtual( $mSetCaption, this.pCaption.Text(this) )
   .iUpdateSize()
}

/*
method uint vLabel.mClColor <alias=vLabel_mClColor>( winmsg wmsg )
{


   if isThemed //&& .flgXPStyle
   {

      SetBkMode( wmsg.wpar, $TRANSPARENT )
      
 
      if .aStyle 
      {
         if .aStyle->Style.hTextColor 
         {
            SetTextColor( wmsg.wpar, .aStyle->Style.pTextColor  )
         }
         wmsg.flags = 1      
         if .aStyle->Style.hBrush
         {
            return .aStyle->Style.hBrush//GetStockObject(0)
         }
      }
   }
   return 0
}*/
/*method uint vLabel.wmclcolorstatic <alias=vLabel_wmclcolorstatic>(winmsg wmsg )
{
   if isThemed && .flgXPStyle
   { 
   
      uint hfont = GetCurrentObject( wmsg.wpar, $OBJ_FONT )
      SetBkMode( wmsg.wpar, $TRANSPARENT )      
      pDrawThemeParentBackground->stdcall( getctrl(wmsg.lpar).hwnd, wmsg.wpar, 0 )
      wmsg.flags = 1
      //SelectBrush(      
      SelectObject( wmsg.wpar, hfont )
      SetTextColor( wmsg.wpar, 0xFFFFFF )
      return GetStockObject(5)
   }
   return 0
}*/
/*------------------------------------------------------------------------------
   Registration
*/
method vLabel vLabel.init( )
{
   this.pTypeId = vLabel
   this.flgRePaint = 1
   this.flgXPStyle = 1
   this.loc.width = 100
   this.loc.height = 100
   return this 
}  

func init_vLabel <entry>()
{  
   regcomp( vLabel, "vLabel", vCtrl, $vCtrl_last,
      %{ %{$mCreateWin, vLabel_mCreateWin },
         %{$mSetName,   vLabel_mSetName },
         %{$mLangChanged, vLabel_mLangChanged },
         %{$mSetCaption, vLabel_mSetCaption }/*
         %{$mClColor,      vLabel_mClColor }*/
      },      
      0->collection )

ifdef $DESIGNING {      
   cm.AddComp( vLabel, 1, "Windows", "label" )
   
   cm.AddProps( vLabel, %{
"Caption"      , ustr, 0,
"TextHorzAlign", uint, 0,
"TextVertAlign", uint, 0,
"AutoSize"     , uint, $PROP_LOADAFTERCHILD,
"WordWrap"    , uint, 0
   })            

   cm.AddPropVals( vLabel, "TextHorzAlign", %{           
"talhLeft"        ,  $talhLeft,      
"talhCenter"      ,  $talhCenter,    
"talhRight"       ,  $talhRight } )

   cm.AddPropVals( vLabel, "TextVertAlign", %{           
"talvTop"         ,  $talvTop,       
"talvCenter"      ,  $talvCenter } )
}
}