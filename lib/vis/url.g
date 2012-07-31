/******************************************************************************
*
* Copyright (C) 2004-2007, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: vis.url 05.02.08 0.0.A.
*
* Author: Alexander Krivonogov ( gentee )
*
******************************************************************************/

include { 
   "header.g"
}

/* Компонента vURL, порождена от vHeader
События   
*/
type vURL <inherit = vHeader>
{
//Hidden fields
/*   ustr     pImage   
   PicText  pPicText

   locustr  pCaption*/   
   locustr  pUrlCaption 
   locustr  pURL
   uint     pColorUnvis 
   uint     pColorVis
   uint     pChangeColor
   uint     flgVisited
   uint     flgClick
   uint     hFont   
   
//Events   
   evEvent   OnClick   
}

extern {
   method vURL.mFontChanged ()
}


/*------------------------------------------------------------------------------
   Internal Methods
*/
/*Внутренний метод vHeader.iUpdateUrl 
Определяет реальный заголовок
*/
method vURL.iUpdateUrl
{
   this->vHeader.Caption = ?( *.pUrlCaption.Value, .pUrlCaption.Value, .pURL.Value )   
} 

/*------------------------------------------------------------------------------
   Properties
*/
/* Свойство str vURL.Caption - Get Set
Устанавливает или получает заколовок ссылки
*/
property ustr vURL.Caption <result>
{
   result = this.pUrlCaption.Value
}

property vURL.Caption( ustr val )
{
   if val != this.pUrlCaption.Value
   {       
      this.pUrlCaption.Value = val   
      .iUpdateUrl()          
   } 
}

/* Свойство str vURL.ChangeColor - Get Set
Устанавливает или получает флаг изменять цвет после клика
*/
property uint vURL.ChangeColor 
{
   return this.pChangeColor
}

property vURL.ChangeColor( uint val )
{
   if val != this.pChangeColor
   {       
      this.pChangeColor = val
   }   
}

/* Свойство str vURL.URL - Get Set
Устанавливает или получает строку запуска
*/
property ustr vURL.URL <result>
{
   result = this.pURL.Value
}

property vURL.URL( ustr val )
{
   if val != this.pURL.Value
   {        
      this.pURL.Value = val   
      .iUpdateUrl()
   } 
}

/*------------------------------------------------------------------------------
   Windows messages
*/
/*Обработка WM_PAINT - отрисовка ссылки
*/
method uint vURL.wmpaint <alias=vURL_wmpaint>(winmsg wmsg)
{
   uint hdc
   PAINTSTRUCT lp   
   hdc = BeginPaint( this.hwnd, lp )
   
   RECT r
   uint hbrush = .Virtual( $mClColor, &wmsg )
   if hbrush || !isThemed
   {      
      if !hbrush : hbrush = $COLOR_BTNFACE + 1   
      r.left = 0
      r.top = 0
      r.right = this.loc.width
      r.bottom = this.loc.height   
      FillRect( hdc, r, hbrush )
   }
   elif isThemed 
   {
      pDrawThemeParentBackground->stdcall( this.hwnd, hdc, 0 );
   }   
   SetTextColor( hdc, ?(.pChangeColor && .flgVisited, .pColorVis, .pColorUnvis ))
   SetBkMode( hdc, $TRANSPARENT )
   
   SelectObject( hdc, .pPicText.hFont )
   .pPicText.Draw( hdc, 0, 0 )
   
   EndPaint( this.hwnd, lp )   
	return 1	   
}

/*------------------------------------------------------------------------------
   Virtual methods
*/

/*Виртуальный метод vURL.mMouse - События от мыши
*/
method uint vURL.mMouse <alias=vURL_mMouse>( evparMouse em )
{
   if em.evmtype == $evmLDown
   {   
      SetCapture( .hwnd )
      .flgClick = 1
   }
   elif em.evmtype == $evmLUp
   {         
      ReleaseCapture()
      if .flgClick 
      {  
         .flgClick = 0
         .flgVisited = 1
         POINT pt
         RECT rect      
         GetCursorPos( pt ) 
         GetWindowRect( .hwnd, rect )
         if PtInRect( rect, pt.x, pt.y )         
         {
            evparEvent ev
            ev.sender = &this
            .OnClick.run( ev )
            if *.pURL.Text(this)
            {
               shell( .pURL.Text(this).str() )
            }
            .Invalidate()            
         }
      }
   }   
   return 1 
}

/*Виртуальный метод vURL vURL.mCreateWin - Создание окна
*/
method vURL vURL.mCreateWin <alias=vURL_mCreateWin>()
{    
   //this->vHeader.mCreateWin()
   .CreateWin( "GVUrl".ustr(), 0, $SS_NOTIFY | $WS_CHILD | $WS_CLIPSIBLINGS )
   this->vCtrl.mCreateWin()
   //this.prevwndproc = -1
   this.pPicText.Ctrl = this
      
   //.mFontChanged()     
   return this
}

/*Виртуальный метод vURL vURL.mDestroyWin - Удаление окна
*/
method vURL.mDestroyWin <alias=vURL_mDestroyWin> ()
{
   this->vCtrl.mDestroyWin()
   DeleteObject( .hFont )
}

/*Виртуальный метод vURL vURL.mFontChanged - изменение шрифта окна
*/
method vURL.mFontChanged <alias=vURL_mFontChanged> ()
{  
   this->vCtrl.mFontChanged()
   DeleteObject( .hFont )   
      
   LOGFONT lf
   GetObject( this.WinMsg( $WM_GETFONT ), sizeof( LOGFONT ), &lf)
   lf.lfUnderline=1   
   .hFont = CreateFontIndirect( lf )
   .pPicText.hFont = .hFont   
   //.iUpdateSize()
   .pPicText.iCalc()
}

/*------------------------------------------------------------------------------
   Registration
*/
method vURL vURL.init( )
{
   this.pTypeId = vURL
   //this.flgRePaint = 1
   this.loc.width = 100
   this.loc.height = 100
   this.pColorVis = 0x800080
   this.pColorUnvis = 0xFF0000
   this.pPicText.pAutoSize = 1
   this.pPicText.pContHorzAlign = $ptLeft
   this.pPicText.pContVertAlign = $ptTop
   this.pChangeColor = 1
   return this 
}  

func init_vURL <entry>()
{  
   WNDCLASSEX visclass
   ustr classname = "GVUrl"
   visclass.cbSize      = sizeof( WNDCLASSEX )
   GetClassInfo( 0, "STATIC".ustr().ptr(), visclass )       
   
   visclass.hInstance   = GetModuleHandle( 0 )
   visclass.hCursor     = LoadCursor( 0, $IDC_HAND )
   //visclass.hbrBackground = 16
   visclass.lpszClassName = classname.ptr()   
   uint hclass = RegisterClassEx( &visclass )
   
   regcomp( vURL, "vURL", vHeader, $vCtrl_last,
      %{ %{$mCreateWin,   vURL_mCreateWin },         
         %{$mMouse,       vURL_mMouse },
         %{$mFontChanged, vURL_mFontChanged },
         %{$mDestroyWin,  vURL_mDestroyWin }
      },
      //0->collection 
      %{ %{ $WM_PAINT, vURL_wmpaint } 
      }      
 )

ifdef $DESIGNING {      
   cm.AddComp( vURL, 1, "Additional", "url" )
   
   cm.AddProps( vURL, %{
"Caption"      , ustr, 0,
"URL"          , ustr, $PROP_LOADAFTERCHILD,
"ChangeColor"  , uint, 0
   })
   
   cm.AddEvents( vURL, %{
"OnClick"      , "evparEvent"
   })
}
}