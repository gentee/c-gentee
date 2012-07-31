/******************************************************************************
*
* Copyright (C) 2004-2007, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: vis.picture 29.01.08 0.0.A.
*
* Author: Alexander Krivonogov ( gentee )
*
******************************************************************************/

type olepic
{
   uint ppv
   uint handle
   uint width
   uint height
   uint pixwidth
   uint pixheight
}

define 
{
   Release = 8
   get_Handle = 12
   get_Width = 24
   get_Height = 28
   Render = 32
}

method olepic.clear()
{
   if .ppv 
   {
      ((.ppv->uint + $Release )->uint)->stdcall(.ppv)
      .ppv = 0
   }
   .handle = 0
   .width = 0
   .height = 0
}

method uint olepic.load( ustr filename )
{
   .clear()
   OleLoadPicturePath( filename.ptr(), 0, 0, 0, IID_IPicture.ptr(), &.ppv )
   if .ppv 
   {
      ((.ppv->uint + $get_Handle)->uint)->stdcall(.ppv, &.handle)
      ((.ppv->uint + $get_Width)->uint)->stdcall(.ppv, &.width) 
      ((.ppv->uint + $get_Height)->uint)->stdcall(.ppv, &.height)
      uint hdc = CreateCompatibleDC(GetDC(0))
      .pixheight = .height * GetDeviceCaps(hdc, 88) /2540
      .pixwidth = .width * GetDeviceCaps(hdc, 90) /2540
      DeleteDC( hdc )  
      return 1
   }  
   return 0  
}

method uint olepic.render( uint hdc, uint x, uint y, uint cx, uint cy )
{
   if .ppv 
   {
      return ((.ppv->uint + $Render)->uint)->stdcall( 
            .ppv, hdc, x, y, cx, cy, 0, .height, .width, -.height )
   }
   return 0    
}

method olepic.delete()
{
   .clear()
}

/* Компонента vPicture, порождена от vCtrl
События   
*/
type vPicture <inherit = vCtrl>
{
//Hidden fields
   ustr     pImage
   uint     ptrImage      
   /*locustr  pCaption
   uint     pTextHorzAlign
   uint     pTextVertAlign*/
   uint     pAutoSize
   uint     pStretch
   uint     pIsImage
   
   ustr     pImageFile
   uint     olepicture
   //uint     olewidth
   //uint     oleheight
   //uint     pBitMap
   /*uint     pMultiLine*/
}

define <export>{
/*//Типы выравнивания текста
   talhLeft       = 0
   talhCenter     = 1   
   talhRight      = 2
   talvTop        = 0
   talvCenter     = 1*/   
}

/*------------------------------------------------------------------------------
   Internal Methods
*/
/* Метод iUpdateCaption
Связывает заголовок панели с визуальным отображением
*/


/* Метод iUpdateSize
Автоматическое определение ширины/высоты текста
*/
method vPicture.iUpdateSize
{
   if .pAutoSize && !.pStretch && .ptrImage
   {
      BITMAP b       
      //uint res = GetObject( .ptrImage, sizeof(BITMAP), &b )
      .Width = .ptrImage->Image.Width//b.bmWidth
      .Height = .ptrImage->Image.Height//b.bmHeight            
   }
}

method vPicture.iUpdateImage()
{
   .pIsImage = 0
   if .olepicture 
   {
      .olepicture->olepic.clear()
   }
   if *.pImageFile
   {  
      if !.olepicture: .olepicture = new( olepic )
      .pIsImage = .olepicture->olepic.load( .pImageFile )
      //OleLoadPicturePath( .pImageFile.ptr(), 0, 0, 0, IID_IPicture.ptr(), &.olepicture )
      //if .olepicture
      //{         
         //((.olepicture->uint + 52)->uint)->stdcall(.olepicture, 1 )
         //((.olepicture->uint + 24)->uint)->stdcall(.olepicture, &.olewidth)
         //((.olepicture->uint + 28)->uint)->stdcall(.olepicture, &.oleheight)
         //BITMAP bmpinfo
         //uint handle
         //((.olepicture->uint + 12)->uint)->stdcall(.olepicture, &handle)         
         //GetObject(handle,sizeof(BITMAP),&bmpinfo)
         //.olewidth = bmpinfo.bmWidth
         //.oleheight = bmpinfo.bmHeight         
         //DeleteObject( handle )
      //}
   }
   else
   {
      if .ptrImage = &this.GetImage( .pImage )
      {
         .pIsImage = 1
      } 
   }
   .iUpdateSize()
   /*uint im as .GetImage( .pImage )
   if &im 
   {
      .pBitMap = im.hImage
   }
   else
   {
      .pBitMap = 0
   }*/
   //.iUpdateImage()
   .Invalidate()
}

method vPicture.delete( )
{
   if .olepicture : destroy( .olepicture )
}

/*------------------------------------------------------------------------------
   Properties
*/
/* Свойство str vPicture.Image - Get Set
Усотанавливает или получает картинку
*/
property ustr vPicture.Image <result>
{
   result = this.pImage
}

property vPicture.Image( ustr val )
{
   if val != this.pImage
   { 
      this.pImage = val
      .iUpdateImage()      
   }
   //.iUpdateImage()
 /*        
      this.pCaption.Value = val
      .iUpdateCaption()
      .iUpdateSize()      
   }*/ 
}

/* Свойство str vPicture.ImageFile - Get Set
Усотанавливает или получает файл картинку
*/
property ustr vPicture.ImageFile <result>
{
   result = this.pImageFile
}

property vPicture.ImageFile( ustr val )
{
   if val != this.pImage
   { 
      this.pImageFile = val
      .iUpdateImage()      
   }
   //.iUpdateImage()
 /*        
      this.pCaption.Value = val
      .iUpdateCaption()
      .iUpdateSize()      
   }*/ 
}


/* Свойство str vLabel.AutoSize - Get Set
Усотанавливает или получает автоматическое изменение размеров
*/
property uint vPicture.AutoSize 
{
   return this.pAutoSize
}

property vPicture.AutoSize( uint val )
{
   if val != this.AutoSize
   { 
      this.pAutoSize = val
      .iUpdateSize()              
   } 
}

/* Свойство str vLabel.Stretch - Get Set
Усотанавливает или получает автоматическое изменение размеров
*/
property uint vPicture.Stretch 
{
   return this.pStretch
}

property vPicture.Stretch( uint val )
{
   if val != this.Stretch
   { 
      this.pStretch = val
      .SetStyle( $SS_CENTERIMAGE | $SS_REALSIZECONTROL, 0 )
      if !this.pStretch
      {
        .SetStyle( $SS_CENTERIMAGE | $SS_REALSIZECONTROL, 1 )
      }                    
   } 
}

property uint vPicture.IsImage()
{
   return .pIsImage
}
/*------------------------------------------------------------------------------
   Virtual methods
*/
/*Виртуальный метод vPicture vPicture.mCreateWin - Создание окна
*/
method vPicture vPicture.mCreateWin <alias=vPicture_mCreateWin>()
{
   uint style = /*$SS_ENDELLIPSIS |*/ $SS_NOTIFY | $WS_CHILD | $WS_CLIPSIBLINGS //| $WS_OVERLAPPED
   style |= $SS_ICON/*$SS_BITMAP*/ | $SS_CENTERIMAGE | $SS_REALSIZECONTROL //| $SS_RIGHTJUST
   .CreateWin( "STATIC".ustr(), 0, style )
   this->vCtrl.mCreateWin()
   //.pBitMap = LoadBitmap( 0,  32754 )
   //.pBitMap = LoadImage( 0, "k:\\bitmap2.bmp".ustr().ptr(), $IMAGE_BITMAP, 0, 0, $LR_LOADFROMFILE | $LR_DEFAULTSIZE/*| $LR_LOADTRANSPARENT*/ )
//.pBitMap = LoadBitmap( 0,  32754 )
   //.pBitMap = LoadImage( 0, "k:\\h_c.ico".ustr().ptr(), $IMAGE_ICON, 0, 0, $LR_LOADFROMFILE | $LR_DEFAULTSIZE/*| $LR_LOADTRANSPARENT*/ )
   //.iUpdateImage()
   //print( "bitmap \(.pBitMap)\n" )
    
   /*.iUpdateAlignment() 
   .iUpdateSize()*/
   return this
}


method uint vPicture.wmpaint <alias=vPicture_wmpaint>( winmsg wmsg )
{
      uint hdc
   	PAINTSTRUCT lp
      
      //UpdateWindow( this.Owner->vCtrl.hwnd )
      //.WinMsg( this.Owner->vCtrl.hwnd, $WM_ERASEBKGND, hdc )   
      hdc = BeginPaint( this.hwnd, lp )
      uint hbrush = this.Owner->vCtrl.WinMsg( $WM_CTLCOLORSTATIC, hdc, this.hwnd )
      if !hbrush: hbrush = GetSysColorBrush( $COLOR_BTNFACE ) 
      if !isThemed 
      {         
         RECT r
         r.left = 0
         r.top = 0
         r.right = this.loc.width
         r.bottom = this.loc.height   
         POINT p           
         FillRect( hdc, r, hbrush) //GetCurrentObject( hdc, $OBJ_BRUSH ) )//$COLOR_BTNFACE + 1 )
      }
      /*else
      {
         pDrawThemeParentBackground->stdcall( this.hwnd, hdc, 0 );         
      }*/
      SetBkMode( hdc, $TRANSPARENT )
      //DrawIcon( hdc, 5 , 5 , .pBitMap )
      uint width, height
      if this.pStretch
      {
         width = this.Width
         height = this.Height 
      }
      if .olepicture && .olepicture->olepic.ppv
      {         
         uint w = this.Width
         uint h = this.Height
         uint ow = .olepicture->olepic.pixwidth
         uint oh = .olepicture->olepic.pixheight 
         if  ow <= w && oh <= h  
         {
            w = ow
            h = oh
         }
         else
         {
            double ph, pw
            pw = double( ow )/double( w )
            ph = double( oh )/double( h )
            if pw > ph
            {
               h = uint( double( oh )/pw )
            }
            else
            {
               w = uint( double( ow )/ph )
            }
         }
         
         .olepicture->olepic.render( hdc, ( this.Width - w ) >> 1, ( this.Height - h ) >> 1, w, h )     
      }
      elif .ptrImage
      {
         DrawIconEx( hdc, 0, 0, ?( .Enabled, .ptrImage->Image.hImage, .ptrImage->Image.hDisImage ), width, height, 0, 0, $DI_COMPAT | $DI_NORMAL )
      }                           
   	EndPaint( this.hwnd, lp )
      /*UpdateWindow( this.Owner->vCtrl.hwnd )*/
      
      wmsg.flags = 1 
      return 0
}

/*Виртуальный метод uint vPicture.mLangChanged - Изменение текущего языка
*/
method vPicture.mLangChanged <alias=vPicture_mLangChanged>()
{   
   .iUpdateImage()  
}

/*------------------------------------------------------------------------------
   Registration
*/
method vPicture vPicture.init( )
{
   this.pTypeId = vPicture
   this.flgRePaint = 1
   this.loc.width = 100
   this.loc.height = 100
   this.flgXPStyle = 1
   return this 
}  

func init_vPicture <entry>()
{  
   regcomp( vPicture, "vPicture", vCtrl, $vCtrl_last,
      %{ %{$mCreateWin, vPicture_mCreateWin },         
         %{$mLangChanged, vPicture_mLangChanged }
      },
      %{ %{$WM_PAINT, vPicture_wmpaint } } )
      //0->collection )

ifdef $DESIGNING {      
   cm.AddComp( vPicture, 1, "Windows", "picture" )
   
   cm.AddProps( vPicture, %{
"Image"      , ustr, 0,
"ImageFile"  , ustr, 0,
/*"TextHorzAlign", uint, 0,
"TextVertAlign", uint, 0,*/
"AutoSize"     , uint, $PROP_LOADAFTERCHILD,
"Stretch"      , uint, 0
//"MultiLine"    , uint, 0*/
   })            

/*   cm.AddPropVals( vPicture, "TextHorzAlign", %{           
"talhLeft"        ,  $talhLeft,      
"talhCenter"      ,  $talhCenter,    
"talhRight"       ,  $talhRight } )

   cm.AddPropVals( vPicture, "TextVertAlign", %{           
"talvTop"         ,  $talvTop,       
"talvCenter"      ,  $talvCenter } )*/
}
}