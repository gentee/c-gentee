/******************************************************************************
*
* Copyright (C) 2004-2007, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: vis.app 17.07.07 0.0.A.
*
* Author: Alexander Krivonogov ( gentee )
*
******************************************************************************/
/* Компонента vApp, порождена от vComp, существует только одна глобальная 
переменная этого типа
События
   
*/
import "Kernel32.dll"{
   InitializeCriticalSection( uint )
   EnterCriticalSection( uint )
   LeaveCriticalSection( uint )
}

global {
   uint cs
}

define {
   VIRTMAX = 100
}


include {   
   "viswin.g"
   "images.g"
   "comp.g"   
   "fonts.g"
   "styles.g"
   "htmlhelp.g"
}


type vApp <inherit=vComp>{
   uint cursorArrow
   uint cursorDrag
   uint cursorNoDrag
   uint cursorSizeNS
   uint cursorSizeWE
   language       Lng
   ImageManager   ImgM   
   FontManager    FntM
   Styles         StyleM
   HelpManager    HelpM
   arr LoadForms of uint
   uint showmodalcnt
   evValUstr      OnHelp
   uint fLoad
   uint pDefFont
} 


global {
   vApp App
   vApp DesApp        
}


ifdef $DESIGNING {
global {   
   
}
}

ifdef $DESIGNING
{
include{
$"..\\..\\programs\\visedit\\manprops.g"
}

}

func init_vComp <entry>
{
   regcomp( vComp, "vComp", 0, $vComp_last,
      %{ %{$mNull,   vComp_mNull},
         %{$mInsert, vComp_mInsert },
         %{$mRemove, vComp_mRemove },
         %{$mPreDel, vComp_mPreDel },
         %{$mSetOwner, vComp_mSetOwner },
         %{$mLangChanged, vComp_mLangChanged },
         %{$mSetIndex, vComp_mSetIndex }
      },        
      0->collection )
      
ifdef $DESIGNING {
   cm.AddComp( vComp )         
   cm.AddProps( vComp, %{ 
"Name"     , str,  0,
"Tag"      , uint, 0,
"AutoLang" , uint, 0      
   })   
}      
}

extern {
   method Image vComp.GetImage( ustr pImage )
   //method Image vComp.GetImage( ustr pImage, uint disabled )
   method vApp.SettingChange()
   method vApp.SetDefFont( LOGFONT lf )
}

include {
   "locustr.g"
   "form.g"
}

/*------------------------------------------------------------------------------
   Public methods
*/

/*Метод Run
Запустить визуальное приложение
*/
method vApp.Run( /*vform form*/ )
{   
   MSG msg
   //print( "app.run 1\n")
   
   while GetMessage( &msg, 0, 0, 0 )
   {  
      TranslateMessage( &msg )
      DispatchMessage( &msg )    
   }
   //print( "app.run 2\n") 
}

/*------------------------------------------------------------------------------
   Virtual methods
*/

method vApp.mInsert <alias=vApp_mInsert>( vForm form )
{     
   if form.TypeIs( vForm )
   {      
      this->vComp.mInsert( form )
      /*form.pOwner = 0*/
      //form.Virtual( $mSetOwner, &this )
      if !form.hwnd : form.Virtual( $mCreateWin )
   }
}

/*------------------------------------------------------------------------------
   Registration
*/

method vApp vApp.init()
{   
   this.pTypeId = vApp  
   .cursorArrow = LoadCursor( 0, $IDC_ARROW )
   .cursorNoDrag = LoadCursor( 0, $IDC_NO )
   .cursorSizeNS = LoadCursor( 0, $IDC_SIZENS )
   .cursorSizeWE = LoadCursor( 0, $IDC_SIZEWE )
   
   ICONINFO pi
   RECT r
   uint hdc = CreateCompatibleDC( 0 )                     
   GetIconInfo( this.cursorArrow, pi )  
   uint osb = SelectObject( hdc, pi.hbmMask )   
   
   uint i   
   fornum i= 0,2
   {
      r.left   = 15 + i
      r.right  = 32 - i
      r.top    = 15 + i
      r.bottom = 32 - i
      FrameRect( hdc, r, CreateSolidBrush( 0 ))
   }   
   SelectObject( hdc, osb )      
   DeleteDC( hdc )   
   .cursorDrag = CreateIconIndirect( pi )      
   DeleteObject( pi.hbmMask )   
   DeleteObject( pi.hbmColor )
   .FntM.Default()
   
   LOGFONT lf      
   GetObject( GetStockObject( $DEFAULT_GUI_FONT ), sizeof( LOGFONT ), &lf )   
   .SetDefFont( lf )  
   

/*   fornum i=0, 64
   {
      fornum j=0, 32
      {
         //print ( "\(hex2strl( GetPixel( sdc, i, j) )) " )
         switch GetPixel( sdc, j, i) 
         {
            case 0         : print( "0" )
            case 0xFFFFFF  : print( "X" )
            case 0xFFFFFFFF: print( "F" )
            default : print( "." )
         }
         
      }
      print( "\n" )
   }*/          
   return this
}

method vApp.SettingChange()
{      
   loadthemefuncs()
   themeinit()
   .StyleM.Update()
   return
}

method vApp.delete()
{
   //print( "app delete\n" )
}

method Image vComp.GetImage( ustr pImage/*, uint disabled*/ )
{
ifdef $DESIGNING { 
   uint curcomp as this
   while !curcomp.p_designing && &curcomp.Owner
   {         
      curcomp as curcomp.Owner
      if &curcomp == &App || &curcomp == &DesApp: break
   }
   if ( curcomp.p_designing ) 
   {       
      return DesApp.ImgM.GetImage( pImage )   
   }
}
   return App.ImgM.GetImage( pImage )
}
/*
method Image vComp.GetImage( ustr pImage )
{
   return GetImage( pImage, 0 )
}*/

method ImageList vComp.GetImageList( ustr pImage, uint ptrNumIml )
{
ifdef $DESIGNING { 
   if ( this.p_designing ) {    
   return DesApp.ImgM.GetImageList( pImage, ptrNumIml )
   
}
}
   return App.ImgM.GetImageList( pImage, ptrNumIml )
}

method vApp.Load()
{
   themeinit()
   uint i
   fornum i, *.LoadForms
   {            
      .LoadForms[i]->vForm.pTypeDef = &gettypedef( .LoadForms[i]->vForm.pTypeId )
      .LoadForms[i]->vForm.Virtual( $mLoad )
      .LoadForms[i]->vForm.fLoad = 1
   }
}


method vApp.mLangChanged <alias=vApp_mLangChanged> ( )
{
   this->vComp.mLangChanged()
   uint i
   fornum i, *.LoadForms
   {            
      if !.LoadForms[i]->vForm.pOwner
      {      
         .LoadForms[i]->vForm.Virtual( $mLangChanged )
      }
   }
}

method vApp.SetDefFont( LOGFONT lf )
{  
   if .pDefFont : DeleteObject( .pDefFont )
   .pDefFont = CreateFontIndirect( lf )
   uint i
   fornum i, *.Comps
   {            
      if .Comps[i]->vCtrl.TypeIs( vCtrl )
      {  
         .Comps[i]->vCtrl.Virtual( $mSetDefFont )
      }
   }
} 

func init_vApp <entry>()
{  
   regcomp( vApp, "vApp", vComp, $vComp_last,      
      %{ %{$mInsert, vApp_mInsert},
         %{$mLangChanged, vApp_mLangChanged}
      },
      0->collection )
   App.pTypeDef = &gettypedef( App.pTypeId ) 
   //InitCommonControls()
   INITCOMMONCONTROLSEX iccex
   iccex.dwICC = 0x1FF//ICC_DATE_CLASSES | ICC_WIN95_CLASSES;
   iccex.dwSize = sizeof(INITCOMMONCONTROLSEX)    
   InitCommonControlsEx( iccex )   
   
   //  cs = mem_alloc( 1024 )
   uint hmem = GlobalAlloc( $GMEM_MOVEABLE, 1024 )
   cs = GlobalLock( hmem )
   //cs = GlobalAlloc( 0/*$GMEM_MOVEABLE/, 1024 )
   InitializeCriticalSection( cs )
   
   cbnoenableproc = callback( &noenableproc, 2 )
}
