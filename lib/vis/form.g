/******************************************************************************
*
* Copyright (C) 2004-2007, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: vis.form 17.07.07 0.0.A.
*
* Author: Alexander Krivonogov ( gentee )
*
******************************************************************************/
/* Компонента vForm, порождена от vCtrl
События
   
*/
/*define
{
   ETDT_DISABLE        = 0x00000001
   ETDT_ENABLE         = 0x00000002
   ETDT_USETABTEXTURE  = 0x00000004
   ETDT_ENABLETAB      = 0x00000006
}
*/
global
{ 
   uint isThemed   
   uint pIsAppThemed
   //uint pEnableThemeDialogTexture
   uint pDrawThemeParentBackground
   uint pOpenThemeData
   uint pDrawThemeBackground
   //uint pDrawThemeText
   arr  ThemeData[ $theme_max ] of uint
   uint cbnoenableproc
} 

include : $"..\windows\fileversion.g"
/*type VS_FIXEDFILEINFO { 
  uint dwSignature 
  uint dwStrucVersion 
  uint dwFileVersionMS 
  uint dwFileVersionLS 
  uint dwProductVersionMS 
  uint dwProductVersionLS 
  uint dwFileFlagsMask 
  uint dwFileFlags 
  uint dwFileOS 
  uint dwFileType 
  uint dwFileSubtype 
  uint dwFileDateMS 
  uint dwFileDateLS 
}

import "version.dll"
{
   uint GetFileVersionInfoSizeW( uint, uint ) -> GetFileVersionInfoSize
   uint GetFileVersionInfoW( uint, uint, uint, uint ) -> GetFileVersionInfo
   uint VerQueryValueW( uint, uint, uint, uint ) -> VerQueryValue
}
*/

import "shell32.dll"
{
   uint SHGetSpecialFolderLocation( uint, uint, uint ) 
   //uint SHGetPathFromIDListW( uint, uint ) -> SHGetPathFromIDList
}

    
func uint IsXPStyle()
{
   uint hi lo   
   getfversion( "comctl32.dll", &hi, &lo )
   
   //To OpenThemeData
   uint ids
   SHGetSpecialFolderLocation( 0, 0x001a, &ids )
   
   return hi >= 0x00060000 
   /*ustr filename = "comctl32.dll"
   uint res, size  
   buf  info
   uint pfi
   
   if size = GetFileVersionInfoSize( filename.ptr(), &res ) 
   {      
      info.expand( size ) 
      if GetFileVersionInfo( filename.ptr(), &res, size, info.ptr()) &&
         VerQueryValue( info.ptr(), "\\".ustr().ptr(), &pfi, &res )
      {             
         return pfi->VS_FIXEDFILEINFO.dwFileVersionMS >= 0x00060000 
      }            
   } 
   return 0*/
}
 
func loadthemefuncs <entry>
{
   uint hinstdll
   
   isThemed = 0 
   if (hinstdll = LoadLibrary("UxTheme.dll".ptr())) 
   { 
      //uint pIsAppThemed = GetProcAddress(hinstdll, "IsAppThemed".ptr())
      //pIsAppThemed->stdcall()
      uint pIsThemeActive = GetProcAddress(hinstdll, "IsThemeActive".ptr())
      
      //GetProcAddress(hinstdll, "EnableTheming".ptr() )->stdcall(1) 
      //pEnableThemeDialogTexture = GetProcAddress(hinstdll, "EnableThemeDialogTexture".ptr())
      if pDrawThemeParentBackground = GetProcAddress(hinstdll, "DrawThemeParentBackground".ptr())
      {       
         pDrawThemeBackground = GetProcAddress(hinstdll, "DrawThemeBackground".ptr())
         pOpenThemeData = GetProcAddress(hinstdll, "OpenThemeData".ptr())
         //pDrawThemeText = GetProcAddress(hinstdll, "DrawThemeText".ptr())
         
         isThemed = pIsThemeActive->stdcall() && IsXPStyle()         
         //if pIsAppThemed 
         {
             //isThemed = pIsAppThemed->stdcall()               
         }
         //isThemed = pIsThemeActive->stdcall() && pIsAppThemed->stdcall()        
      }  
      //FreeLibrary(hinstDll)
   }   
} 

func themeinit ()
{

   if isThemed 
   {
      
      ThemeData[$theme_button] = pOpenThemeData->stdcall( 0, "button".ustr().ptr() )
      ThemeData[$theme_toolbar] = pOpenThemeData->stdcall( 0, "toolbar".ustr().ptr() )      
      //print( "themeinit \(pOpenThemeData) \(ThemeData[$theme_button])\n" )
      //ThemeData[$theme_menu] = pOpenThemeData->stdcall( 0, "menu".ustr().ptr() )
      
   }   
}


/*
func uint IsAppThemed()
{
   if pIsAppThemed 
   {
      return pIsAppThemed->stdcall()  
   }
   return 0
}

func uint EnableThemeDialogTexture( uint hwnd, uint flag )
{
   if pEnableThemeDialogTexture 
   {
      return pEnableThemeDialogTexture->stdcall( hwnd, flag )
   }
   return 0
}

func setxpstyle( uint hwnd )
{
   if !isthemefuncs 
   {
      loadthemefuncs()
   }
   if IsAppThemed() 
   {
      \(EnableThemeDialogTexture( hwnd, $ETDT_USETABTEXTURE | $ETDT_ENABLETAB ))\n" )
   }
}*/

include {
   //"app.g"
   "ctrl.g"
}

type vForm <inherit = vCtrl>
{
   //arr components[] of uint
   locustr pCaption
   uint curtab
   //uint pFormStyle   
   
   uint lng
   uint pResult
   uint pBorder
   uint pWindowState
   ustr pIconName 
   uint pStartPos 
   uint pTopMost 
   uint pFormStyle
   uint pActivate
   
   uint fCreate
   uint fLoad
   
   uint pMenu   
   
   evQuery OnCloseQuery 
   evEvent OnCreate
   evEvent OnDestroy
   evEvent OnLanguage
   evValUint OnShow
   evValUint OnActivate
   
   uint hwndTip
}

define <export>{
   mForm = $vCtrl_last
   mHelp      
   vForm_last   
}

define <export>{
//Стили рамки формы Border
   fbrdNone       = 0
   fbrdSizeable   = 1   
   fbrdDialog     = 2   
   fbrdSizeToolWin  = 3
//Стили состояния окна WindowState   
   wsNormal    = 0
   wsMaximized = 1
   wsMinimized = 2  
//Начальная позиция окна
   spDesigned     = 0   
   spScreenCenter = 1
   spParentCenter = 2  
//FormStyle
   fsChild = 0
   fsPopup = 1
   fsModal = 2   
                     
}

//pFormStyle
define
{  
   fsPopup = 1
   fsModal = 2
}


method uint vCtrl.NextCtrl( uint curctrl, uint plevel, uint flgbrother )
{
   uint owner
   uint ctrl as curctrl->vVirtCtrl
   uint cidx 
   
   if !&ctrl
   {
      ctrl as this
      plevel->uint++
   }   
   elif ctrl.TypeIs( vCtrl) && ctrl->vCtrl.pCtrls/**ctrl.ctrls*/ && !flgbrother
   {
      
      ctrl as ctrl.Comps[0]->vVirtCtrl//ctrls[0]->vCtrl
      plevel->uint++
   }
   else
   {       
      while &ctrl != &this
      {         
         
         owner as ctrl.pOwner->vCtrl  
         cidx = ctrl.pIndex + 1//cidx + 1      
         if cidx < owner.pCtrls/**owner.ctrls*/
         {
            ctrl as owner.Comps[cidx]
            goto end
         } 
         ctrl as owner
         plevel->uint--              
      }  
      ctrl as 0    
   }
label end
   return &ctrl
}

method uint vCtrl.PrevCtrl( uint curctrl, uint plevel, uint flgbrother )
{
   uint owner
   uint ctrl as curctrl->vVirtCtrl
   int cidx 
    
   if !&ctrl
   {
      ctrl as this
      plevel->uint++
   }   
   elif ctrl.TypeIs( vCtrl) && ctrl->vCtrl.pCtrls/**ctrl.ctrls*/ && !flgbrother
   {
      ctrl as ctrl.Comps[ctrl->vCtrl.pCtrls-1]->vVirtCtrl/*ctrls[*ctrl.ctrls-1]->vCtrl*/
      plevel->uint++
   }
   else
   {       
      while &ctrl != &this//ctrl.p_owner//&ctrl != &this
      {         
         owner as ctrl.pOwner->vCtrl  
         cidx = ctrl.pIndex - 1//.cidx - 1      
         if cidx >= 0
         {
            ctrl as owner.Comps[cidx]//ctrls[cidx]
            goto end
         } 
         ctrl as owner
         plevel->uint--              
      }  
      ctrl as 0    
   }
label end
   return &ctrl
}

method vCtrl.mInsert <alias=vCtrl_mInsert>( vComp newcomp )
{
   if newcomp.TypeIs( vVirtCtrl )
   {   
      uint ctrl as newcomp->vVirtCtrl
      uint flgremove
      if this.pCanContain 
      {
        
         if ctrl.pOwner 
         {     
            ctrl.Owner.Virtual( $mRemove, ctrl )
            ctrl.pOwner = &this
            ctrl.form = this.GetForm()
            flgremove = 1
         }  
         else             
         {
            ctrl.pOwner = &this
            ctrl.form = this.GetForm()
            //if this.hwnd : ctrl.Virtual( $mCreateWin )                           
            if this.hwnd && !ctrl->vCtrl.hwnd: ctrl.Virtual( $mCreateWin )
         }      
         //ctrl.Virtual( $mSetOwner )
                 
         //ctrl.cidx = this.pCtrls//cidx
         ctrl.pIndex = this.pCtrls//ctrl.cidx
         this.Comps.insert( ctrl.pIndex )//cidx )
         this.Comps[ ctrl.pIndex ] = &ctrl//cidx ] = &ctrl
         uint i
         fornum i = ctrl.pIndex + 1, *this.Comps//cidx + 1, *this.Comps
         {
            this.Comps[i]->vComp.pIndex++
         }
          
         this.pCtrls++         
         if ctrl.TypeIs( vCtrl ) && ( !ctrl.TypeIs( vForm ) || !ctrl->vForm.pFormStyle )
         {            
            ctrl as vCtrl
            if flgremove 
            {
               SetWindowLong( ctrl.hwnd, $GWL_STYLE, GetWindowLong( ctrl.hwnd, $GWL_STYLE )/* | $WS_CHILD*/ )
               SetParent( ctrl.hwnd, this.hwnd )
            }                         
            BringWindowToTop( ctrl.hwnd )            
         }
         ctrl.Virtual( $mSetOwner, &this )
      }
      /*else 
      {
         this->vComp.mInsert( newcomp )
      } */
   }
   else
   {      
      this->vComp.mInsert( newcomp )
   }
}
/*
define {
 WM_CHANGEUISTATE  = 0x0127
 WM_UPDATEUISTATE  = 0x0128
 UIS_INITIALIZE    = 3
 UISF_ACTIVE       = 0x4
}
*//*
method vForm.mReCreateWin <alias=vForm_mReCreateWin> ()
{
   if this.hwnd
   {
      uint i
      uint oldhwnd = this.hwnd
      this.hwnd = 0
      if .pOwner && (.pOwner == &App || .pOwner->vCtrl.hwnd )
      {
         .Virtual( $mCreateWin )
      }
      fornum i = 0, .pCtrls
      {
         .Comps[i]->vCtrl.Virtual( $mReCreateWin )
               
      }
      if oldhwnd
      {
         SetWindowLong( oldhwnd, $GWL_USERDATA, 0 )
         DestroyWindow( oldhwnd )
      }
   }  
}

method vCtrl.mReCreateWin <alias=vCtrl_mReCreateWin> ()
{
   SetParent( this.hwnd, this.pOwner->vCtrl.hwnd )
}
*/

method vCtrl.mReCreateWin <alias=vCtrl_mReCreateWin> ()
{
   if this.hwnd
   {
      uint i
      uint oldhwnd = this.hwnd
      this.hwnd = 0
      //SetWindowLong( oldhwnd, $GWL_USERDATA, 0 )
      //SetParent( oldhwnd, 0 )
      //if .pOwner  
      //{
      //   SetWindowLong( .hwnd, $GWL_STYLE, GetWindowLong( .hwnd, $GWL_STYLE ) | $WS_CHILD )     	   
      //   SetParent( .hwnd, .pOwner->vCtrl.hwnd )
      //   this.TabOrder = this.TabOrder
      //}
      if .pOwner && (.pOwner == &App || .pOwner->vCtrl.hwnd )
      {
         .Virtual( $mCreateWin )
      }
      //if .pOwner && .pOwner != &App 
      //{
      //   SetWindowLong( .hwnd, $GWL_STYLE, GetWindowLong( .hwnd, $GWL_STYLE ) )     	   
       //  SetParent( .hwnd, .pOwner->vCtrl.hwnd )         
//         this.TabOrder = this.TabOrder         
  //    }
      fornum i = 0, .pCtrls
      {
         if .Comps[i]->vComp.TypeIs( vCtrl ) //&& (!.Comps[i]->vComp.TypeIs( vForm ) || !.Comps[i]->vForm.pFormStyle )         
         {
            
//            uint flgform
//            if .hwnd
//            {
//               ustr name
//               name.reserve( 255 )
//               GetClassName( .hwnd, name.ptr(), 255 )
//               name.setlenptr()
//               print( "$$$$$$$$$$$$$$$$  \(name.str())\n" ) 
//               if name == "GVForm"
//               { 
//                  print( "gvform\n" )
//                  flgform = 1
//               }  
//            }
            if .Comps[i]->vComp.TypeIs( vForm ) && .Comps[i]->vForm.pFormStyle
            {
               .Comps[i]->vCtrl.Virtual( $mReCreateWin )
            }
            else
            {
               if .Comps[i]->vCtrl.flgReCreate//.TypeIs( vForm ) //|| .TypeIs( vScrollBox )
               {            
                  .Comps[i]->vCtrl.Virtual( $mReCreateWin )
               }
               else
               {
                  SetParent( .Comps[i]->vCtrl.hwnd, this.hwnd )
   //               .Comps[i]->vCtrl.WinMsg( $WM_CHANGEUISTATE , ($UISF_ACTIVE << 16) | $UIS_INITIALIZE )
   //            this.WinMsg( $WM_CHANGEUISTATE , ($UISF_ACTIVE << 16) | $UIS_INITIALIZE)               
   //            .Comps[i]->vCtrl.WinMsg( $WM_UPDATEUISTATE, ($UISF_ACTIVE << 16) | $UIS_INITIALIZE)
   //            this.WinMsg( $WM_UPDATEUISTATE, ($UISF_ACTIVE << 16) | $UIS_INITIALIZE)
               }
            }
         }          
      }
      
      
//print( "recreate 110 \(oldhwnd) \(this.prevwndproc)\n" )      
      //SetWindowLong( oldhwnd, 
      if oldhwnd
      {
         SetWindowLong( oldhwnd, $GWL_USERDATA, 0 )
//         if this.form->vForm.curtab == &this
//         {
//            SetFocus( this.hwnd )
//         }
         DestroyWindow( oldhwnd )
      }
      //}
      //SetParent( oldhwnd, 0 )
   }  
}

method uint vComp.GetMainForm()
{  
   uint cur as this   
   while &cur && cur.pOwner != &App && ( !cur.TypeIs( vForm ) || ( cur->vForm.Owner && !cur->vForm.pFormStyle /*!= $fsModal*/ )) 
   {      
      cur as cur.Owner
   }        
   return &cur //->vForm 
}

method vForm.nexttab( uint flgreverse )
{  

   uint level
   uint curtab as this.curtab->vCtrl
   uint flgbrother, flgstart
   uint mainform as .GetMainForm()->vForm
   while 1
   {
      if curtab as ?(flgreverse,
                        mainform.PrevCtrl( &curtab, &level, flgbrother )->vCtrl,
                        mainform.NextCtrl( &curtab, &level, flgbrother )->vCtrl )
      {         
         if curtab.TypeIs( vCtrl ) && curtab.Visible && curtab.Enabled && !curtab.p_designing
         {
            if curtab.pTabStop : break         
            flgbrother = 0
         }
         else {
          flgbrother = 1
         }
      }
      else
      {  
         if flgstart : break
         flgstart = 1
      }     
   }  
   
   if &curtab
   {  
      if mainform.pActivate 
      {         
         SetFocus( curtab.hwnd )
      }
      else : mainform.curtab = &curtab      
   }

}     

method vCtrl.mPreDel <alias=vCtrl_mPreDel>()
{
//print( "predel \(this.TypeName) \(this.Name)\n" )
   if this.form && this.form->vForm.curtab == &this
   {
      this.form->vForm.nexttab( 1 )
   }
   this->vComp.mPreDel()   
   if this.hwnd
   {   
      DestroyWindow( this.hwnd )
      this.hwnd = 0
   }
//print( "predel end\n" )        
}            

method vCtrl.mSetEnabled <alias=vCtrl_mSetEnabled>( )// uint val )
{   
   /*if !.pEnabled 
   {
      uint form as .GetMainForm()->vForm
      uint curtab as form.curtab->vCtrl
      
      if &curtab
      {
      
         while &curtab != &form 
         { 
      
            if &curtab == &this            
            {
               
               form.nexttab( 0 )
            }
            curtab as curtab.Owner   
         }
      }
   }*/
   EnableWindow( .hwnd, .pEnabled )   
}                                                                                                                                    
          
                      
method uint vComp.GetForm()
{     
   uint cur as this   
   while &cur && cur.pOwner != &App && !cur.TypeIs( vForm ) 
   {      
      cur as cur.Owner
   }        
   return &cur //->vForm 
}


method vCtrl.SetFocus()
{
   uint owner as this
   uint noset
   uint form as this.GetMainForm()->vForm
   
   while &owner != &form
   {   
      if !owner.Visible || !owner.Enabled 
      {
         noset = 1
         break
      }
      owner as owner.Owner
   }
   if !noset 
   {
      form.curtab = &this
      if !.pTabStop : form.nexttab( 0 )
      elif form.pActivate : SetFocus( this.hwnd )      
   }
   /*if !form.curtab 
   {
      from.nexttab( 0 )  
   }*/ 
      
      /*
      if this.form->vForm.Visible
      {
         SetFocus( this.hwnd )   
         if !.pTabStop || !.pVisible || !.pEnabled 
         {
            .GetMainForm()->vForm.nexttab( 0 )
         }
      }
      else
      {
         this.form->vForm.curtab = &this
      }
   }*/
}

/* Метод iUpdateCaption
Связывает заголовок окна с визуальным отображением
*/
method vForm.iUpdateCaption
{
   SetWindowText( this.hwnd, this.pCaption.Text(this).ptr() )  
}

property ustr vForm.Caption<result>
{
   result = this.pCaption.Value
}

property vForm.Caption( ustr val )
{
   if this.pCaption.Value != val
   {
      this.pCaption.Value = val      
      .iUpdateCaption()  
   }
}     

/* Свойство uint StartPos - Get Set
Устанавливат/получает начальную позицию окна
*/
property uint vForm.StartPos()
{
   return .pStartPos
}

property vForm.StartPos( uint val )
{
   if .pStartPos != val
   {
      .pStartPos = val
   }
}

/* Свойство uint TopMost - Get Set
Устанавливат/получает положение окна в самом верху
*/
property uint vForm.TopMost()
{
   return .pTopMost
}

property vForm.TopMost( uint val )
{
   if .pTopMost != val
   {
      .pTopMost = val
      //SetWindowPos( .hwnd, ?( val, $HWND_TOPMOST, $HWND_NOTOPMOST ), 0, 0, 0, 0, $SWP_NOACTIVATE | $SWP_NOZORDER | $SWP_NOMOVE | $SWP_NOSIZE ) )\n" )
      ifdef !$DESIGNING {     
      .Virtual( $mReCreateWin )
      }
   }
}

/* Свойство uint FormStyle - Get Set
Устанавливат/получает положение окна в самом верху
*/
property uint vForm.FormStyle()
{
   return .pFormStyle
}

property vForm.FormStyle( uint val )
{
   if .pFormStyle != val
   {
      .pFormStyle = val
      //SetWindowPos( .hwnd, ?( val, $HWND_TOPMOST, $HWND_NOTOPMOST ), 0, 0, 0, 0, $SWP_NOACTIVATE | $SWP_NOZORDER | $SWP_NOMOVE | $SWP_NOSIZE ) )\n" )
      ifdef !$DESIGNING {
      if .hwnd : .Virtual( $mReCreateWin )
      }
   }
}

/* Свойство uint Border - Get Set
*/
property uint vForm.Border()
{
   return this.pBorder
}

property vForm.Border( uint val )
{  
   uint style
   
   if this.pBorder != val
   {      
      this.pBorder = val
      ifdef !$DESIGNING {     
      .Virtual( $mReCreateWin )
      }
//      
//      .SetStyle( $WS_OVERLAPPEDWINDOW, ?( val == $fbrdNone, 0, 1 ) )
         /*style = GetWindowLong( this.hwnd, $GWL_EXSTYLE )
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
                     $SWP_NOACTIVATE | $SWP_NOZORDER | $SWP_NOMOVE | $SWP_NOSIZE )*/     
   }     
}

/* Свойство uint WindowState - Get Set
*/
property uint vForm.WindowState()
{
   return this.pWindowState
}

property vForm.WindowState( uint val )
{  
   uint style
   
   if this.pWindowState != val
   {   
      this.pWindowState = val
      .Virtual( $mSetVisible )     
   }     
}

/* Свойство uint Activate - Get Set
*/
property uint vForm.Activate()
{
   return this.pActivate
}

property vForm.Activate( uint val )
{  
   if this.hwnd 
   { 
      SetActiveWindow( this.hwnd )
   }     
}

property vCtrl vForm.ActiveControl()
{
   return .curtab->vCtrl
}

method vForm.iGetStyles( uint pstyle, uint pexstyle )
{
   uint style = $WS_CLIPSIBLINGS | $WS_CLIPCHILDREN | $WS_TABSTOP
   uint exstyle = $WS_EX_CONTROLPARENT
ifdef $DESIGNING {
   style |= $WS_OVERLAPPEDWINDOW
}
else {   
   switch this.pBorder
   {
      case $fbrdSizeable : style |= $WS_OVERLAPPEDWINDOW | 0x40
      case $fbrdDialog //: style |= $WS_SYSMENU
      {
         style = $WS_POPUPWINDOW | $WS_DLGFRAME | $DS_MODALFRAME | $WS_OVERLAPPED
         exstyle |= $WS_EX_DLGMODALFRAME | $WS_EX_WINDOWEDGE      
      }
      case $fbrdSizeToolWin 
      {
         style |= $WS_SYSMENU | $WS_POPUPWINDOW | $WS_CLIPSIBLINGS | $WS_DLGFRAME | $WS_THICKFRAME | $WS_OVERLAPPED
         exstyle |= $WS_EX_TOOLWINDOW
      }
   }
   if .pTopMost : exstyle |= $WS_EX_TOPMOST
}
   if this.pOwner && this.pOwner != &App 
   {
      style |= ?( this.pFormStyle, $WS_POPUP, $WS_CHILD ) 
   }
   if .pVisible : style |= $WS_VISIBLE    
   if .pWindowState == $wsMaximized
   {
      style |= $WS_MAXIMIZE   
   }
   elif .pWindowState == $wsMinimized
   {   
      style |= $WS_MINIMIZE            
   } 
   if pstyle : pstyle->uint = style
   if pexstyle : pexstyle->uint = exstyle
}

property uint vForm.ClientWidth()
{
   return .clloc.width
}

property vForm.ClientWidth( uint val )
{
   if val != .clloc.width
   {
      RECT r
      uint style
      r.right = val
      .iGetStyles( &style, 0 )
      AdjustWindowRect( r, style, this.pMenu )
      .Width = r.right - r.left
   } 
}

property uint vForm.ClientHeight()
{
   return .clloc.height
}

property vForm.ClientHeight( uint val )
{
   if val != .clloc.height
   {
      RECT r
      uint style
      r.bottom = val
      .iGetStyles( &style, 0 )
      AdjustWindowRect( r, style, this.pMenu )
      .Height = r.bottom - r.top
   } 
}
/* Свойство ustr IconName - Get Set
Имя иконки окна
*/
method vForm.iUpdateIcon()
{
   str sname = .pIconName
   arrstr path 
   sname.split( path, '[', $SPLIT_EMPTY )
   str name = path[0]
   if !*name
   {
      uint il as App.ImgM.find("resources")->ImageList      
      if &il
      {           
         foreach key, il.keys
         {            
            name = "resources\\\(key)"            
            break
         }
      }
   }
   uint im as this.GetImage( name.ustr() )
   if .pBorder != $fbrdDialog && &im
   {      
      .WinMsg( $WM_SETICON, 0, im.hImage )
      im as this.GetImage( name.ustr() + "[1]" )
      if &im : .WinMsg( $WM_SETICON, 1, im.hImage )
   }
   else
   {
      .WinMsg( $WM_SETICON, 0, 0 )
      .WinMsg( $WM_SETICON, 1, 0 )
   }
}

property ustr vForm.IconName <result> ()
{
   result = this.pIconName
}

property vForm.IconName( ustr val )
{  
   if this.pIconName != val
   {   
      this.pIconName = val   
      .iUpdateIcon()        
   }     
}


method vForm vForm.init( )
{
   this.pTypeId =vForm
   this.pCanContain = 1  
   this.loc.width = 600
   this.loc.height = 400
   this.pBorder = $fbrdSizeable
   this.flgReCreate = 1
   App.LoadForms[App.LoadForms.expand(1)] = &this
   return this
}

property uint vForm.Result()
{
   return .pResult 
}

property vForm.Result( uint val )
{
   if .pFormStyle == $fsModal && val
   {      
      .pResult = val
      //PostMessage( this.hwnd, $WM_USER, 0, 0 )
      //.WinMsg( $WM_USER + 1000 )
      //.WinMsg( $WM_CLOSE )
   } 
}
include {
   "menu.g"
   "popupmenu.g"
}
/* Свойство uint Menu - Get Set
*/
method vForm.iUpdateMenu()
{
   SetMenu( .hwnd, ?( this.pMenu, this.pMenu->vMenu.phMenu, 0 ) )
   DrawMenuBar( .hwnd )
}

property vMenu vForm.Menu()
{
   return this.pMenu->vMenu
}

property vForm.Menu( vMenu val )
{     
   if this.pMenu != &val
   {   
      this.pMenu = &val      
      .iUpdateMenu()    
   }     
}

method vForm.mInsert <alias=vForm_mInsert>( vComp newcomp )
{
   this->vCtrl.mInsert( newcomp )   
   if !.pMenu && newcomp.TypeIs( vMenu )
   {
      .Menu = newcomp->vMenu
   }   
}

method vForm.mRemove <alias=vForm_mRemove>( vComp remcomp )
{
   this->vCtrl.mRemove( remcomp )
   if .pMenu == &remcomp
   {
      .Menu = 0->vMenu  
   }   
}


/*method vCtrl.CreateChildren()
{
   uint i
   fornum i = 0, .pCtrls
   {
      if .Comps[i]->vComp.TypeIs( vCtrl )
      {
         .Comps[i]->vCtrl.Virtual( $mCreateWin )
         .Comps[i]->vCtrl.CreateChildren()
      }         
   }
}*/
global { uint addrmyproc }
func uint setmyproc<entry>()
{  
   addrmyproc = callback( &myproc, 4 )
   return 0
}
method vCtrl vCtrl.mCreateWin <alias=vCtrl_mCreateWin> ()
{  
   this.WinMsg( $WM_SETFONT, App.pDefFont )//GetStockObject( $DEFAULT_GUI_FONT ) )//App.FntM.GetFont("default_big").hFont)//
   SetWindowLong( this.hwnd, $GWL_USERDATA, &this )   
   uint addr
   if .prevwndproc == -1
   {
      addr = 1
      .prevwndproc = 0
   }  
   else : this.prevwndproc = SetWindowLong( this.hwnd, $GWL_WNDPROC, addrmyproc )
   //this.prevwndproc = SetWindowLong( this.hwnd, $GWL_WNDPROC, callback( &myproc, 4 ))
   if addr : .prevwndproc = 0
   RECT r
   GetClientRect( this.hwnd, r )   
   this.clloc.width  = r.right - r.left
   this.clloc.height = r.bottom - r.top
   
   int i
   for i = *.Comps-1, i >= 0, i--
   {
      if .Comps[i]->vComp.TypeIs( vCtrl ) && !.Comps[i]->vCtrl.hwnd 
      {         
         .Comps[i]->vCtrl.Virtual( $mCreateWin )         
      }
      else
      {
         .Comps[i]->vCtrl.Virtual( $mOwnerCreateWin )
      }   
            
   }
   
   if this.TypeIs( vForm ) && !( this.pOwner && this.pOwner != &App && !this->vForm.pFormStyle )
   {
      evparValUint evu
      evu.val = 1   
      .Virtual( $mPosChanged, evu )
   }
   else
   {     
//      print( "pching1 \(.Name)\n" )
      eventpos ep
      vloc loc = this.loc      
      ep.loc = this.loc      
      ep.move = 1
      ep.code = $e_poschanging
      .Virtual( $mPosChanging, ep )
//      print( "pching2 \(.Name)\n" )
      evparValUint evu
      evu.val = 0   
      .Virtual( $mPosChanged, evu )
      //this.Owner->vCtrl.Virtual( $mChildPosChanged, this )
   }
   
   .Virtual( $mFontChanged )
   if *.pHint.Value : .Virtual( $mSetHint )   
   //vloc l =.loc
   //SetWindowPos( this.hwnd, 0, 0,0,0,0, $SWP_NOACTIVATE | $SWP_NOZORDER )  
   //SetWindowPos( this.hwnd, 0, l.left, l.top, l.width, l.height, $SWP_NOACTIVATE | $SWP_NOZORDER )
   //SetWindowPos( this.hwnd, 0, .loc.left, .loc.top, .loc.width, .loc.height, $SWP_NOACTIVATE | $SWP_NOZORDER )
   //print( "Createwin30\n" ) 
   return this
}


method vForm vForm.mCreateWin <alias=vForm_mCreateWin>( )
{  
   if !.fLoad
   {
      //print( "load \(.TypeName) \(.Name) \n" )
      .Virtual( $mLoad )
      .fLoad = 1
   }  
   uint style, exstyle
   .iGetStyles( &style, &exstyle )
   if !.fCreate //&& !.fLoad
   {  
      if .pStartPos == $spScreenCenter
      {
         .Left = ( GetSystemMetrics(0) - .Width ) / 2   
         .Top = ( GetSystemMetrics(1) - .Height ) / 2  
      }
      elif .pStartPos == $spParentCenter
      {         
         if this.pOwner && this.pOwner != &App && this.pFormStyle
         {
            .Left = .Owner->vForm.Left + (.Owner->vForm.Width - .Width ) / 2   
            .Top = .Owner->vForm.Top + (.Owner->vForm.Height - .Height ) / 2 
         }         
      }      
      .Left = max( .Left, 0 )
      .Top = max( .Top, 0 )
      
      this.hwndTip = CreateWindowEx( $WS_EX_TOPMOST, "tooltips_class32".ustr().ptr(), 0,
                            $WS_POPUP | 0x01 | 0x02, // | $TTS_NOPREFIX | $TTS_ALWAYSTIP,
                            0x80000000, 0x80000000,
                            0x80000000, 0x80000000, //$CW_USEDEFAULT,
                            0, 0, 0/*GetModuleHandle( 0 )*/, 0)
   }
      
   .CreateWin( "GVForm".ustr(), exstyle, /*0x94c800c4*/ style )
   /*this.hwnd = CreateWindowEx( 0x00010000, "GVForm".ustr().ptr(), "".ustr().ptr(), 
                     ?( this.p_owner,$WS_CHILD,0) |$WS_CLIPSIBLINGS | $WS_CLIPCHILDREN | $WS_OVERLAPPEDWINDOW	| $WS_OVERLAPPED | $WS_SYSMENU , 0, 0, 
                     500, 500, ?( this.p_owner, this.p_owner->vCtrl.hwnd, 0 ), 0, 0, &this )*/                        
   //setxpstyle( this.hwnd )                                 
   SCROLLINFO sci   
   sci.cbSize = sizeof( SCROLLINFO )
   sci.fMask = 0x17 
   sci.nMin = 0 
   sci.nMax = 500
   sci.nPage = 30
   sci.nPos = 100 
   
   this.prevwndproc = -1
   this->vCtrl.mCreateWin()
   //&DefWindowProc
   //sci.nTrackPos   
   //SetScrollInfo( this.hwnd, 1, sci, 1) 	                                            
    
   //this.f_defproc = getid( "@defproc", %{this.p_typeid, eventn } )
   this.pCanContain = 1
   //win_customproc( this.hwnd, &vCtrlproc )
   this.form = &this
   if this.pOwner && this.pOwner != &App && !this.pFormStyle
   {       
      SetParent( this.hwnd, this.pOwner->vCtrl.hwnd )
      //ShowWindow( this.hwnd, $SW_SHOWNORMAL )      
   }
   elif GetActiveWindow() == .hwnd
   {
      .pActivate = 1
   }
   /*else
   {
      SetParent( this.hwnd, 0 )
   }*/   
   /*if .pVisible
   {   
      
      ShowWindow( this.hwnd, $SW_SHOWNORMAL )
   }*/   

   
/*   if .pVisible
   {
      ShowWindow( this.hwnd, $SW_SHOWNORMAL )      
   }            */ 
   
   evparEvent ev
   ev.sender = &this
   if !.fCreate //&& !.fLoad
   {  
      .iUpdateMenu()
      this.OnCreate.Run( ev )
      .fCreate = 1      
   }
   .iUpdateCaption()
   .OnLanguage.Run( this )
   .iUpdateIcon() 
   if .GetMainForm() == &this && .pActivate   
   {      
      if .curtab : SetFocus( .curtab->vCtrl.hwnd )
      else : .nexttab( 0 )
   }
   /*else
   {
      .nexttab( 0 )         
   }*/
   return this                                        
}            


method vForm.mSetOwner <alias=vForm_mSetOwner>( vComp newowner )
{   
   if !.fLoad
   {
      //print( "load \(.TypeName) \(.Name) \n" )
      .Virtual( $mLoad )
      .fLoad = 1
   }  
   /*if newowner && newowner.TypeIs( vApp )
   {         
      .pOwner = 0      
   }
   else*/
   { 
      .pOwner = &newowner
      //???????Нужно ли делать recrete????????????????
      if .pFormStyle && &newowner : .Virtual( $mReCreateWin )
      /*else 
      {
         eventpos evp
         evp.code = $e_poschanging
         evp.loc = this.loc
         evp.move = 1
      
         .Virtual( $mPosChanging, evp ) 
      }*/
   }
}

method vForm.mPosChanging <alias=vForm_mPosChanging>( eventpos evp )
{
   if this.p_designing
   {  
      evp.loc.left = -this.Owner->vCtrl.clloc.left
      evp.loc.top = -this.Owner->vCtrl.clloc.top
   }
   this->vCtrl.mPosChanging( evp )  
}

method vCtrl.mSetVisible <alias=vCtrl_mSetVisible>( )
{  
   ShowWindow( this.hwnd, ?( .pVisible || this.p_designing, 
      $SW_SHOWNOACTIVATE, $SW_HIDE ))   
}

method vForm.mSetVisible <alias=vForm_mSetVisible>( )
{  
   
   uint newstate
   if !this.p_designing && this.hwnd
   {
      if .pVisible 
      {         
         switch .pWindowState 
         {  
            case $wsMaximized: newstate = $SW_MAXIMIZE   
            case $wsMinimized: newstate = $SW_MINIMIZE
            default : newstate = ?( .pFormStyle == $fsPopup, $SW_SHOWNOACTIVATE, $SW_SHOWNORMAL );             
         }
      }
      else: newstate = $SW_HIDE
                     
      ShowWindow( this.hwnd, newstate )
      if .pVisible && &this == .GetMainForm()
      { 
         if !.pFormStyle : BringWindowToTop( this.hwnd )
         /*if .GetMainForm()->vForm.pActivate
         { 
            if .curtab
            {
               SetFocus( .curtab->vCtrl.hwnd )       
            }
            else
            {
               .nexttab( 0 )         
            }
         } */       
      }
   }  
   
}

/*Виртуальный метод uint vCustomBtn.mLangChanged - Изменение текущего языка
*/
method vForm.mLangChanged <alias=vForm_mLangChanged>()
{
   .iUpdateCaption() 
   .iUpdateIcon()
   this->vCtrl.mLangChanged()
   .OnLanguage.Run( this )
}

/*method uint vForm.mKey <alias=vForm_mKey> ( evparKey ev )
{
 
}*/


/*method vForm.mPosChanged <alias=vForm_mPosChanged>( evparEvent ev )
{   
   this->vCtrl.mPosChanged( ev )    
   if this.p_designing
   {
      if this.Left || this.Top 
      {
         this.Left = 0
         this.Top = 0
      }
   }  
}*/

method vForm.Close()
{
   .WinMsg( $WM_CLOSE )
   //.Visible = 0
}


method uint vForm.wmclose <alias=vForm_wmclose>( winmsg wmsg )
{   
   evparQuery evpQ   
   .OnCloseQuery.Run( evpQ )
   //wmsg.flags = evpQ.flgCancel
   if evpQ.flgCancel
   {      
      wmsg.flags = 1
   }
   else 
   {
      switch this.pFormStyle  
      {
         case $fsModal
         {
            if !wmsg.flags && !.Result      
            { 
               .Result = -1
            } 
            wmsg.flags = 1
         }
         case $fsPopup
         {
            wmsg.flags = 1
            .Visible = 0
         }          
      }      
   }
   //DestroyWindow(this.hwnd )
   /*if App.
   PostQuitMessage( 0 )*/   
   return 0    
   //return evpQ.flgCancel    
}

method uint vForm.wmqueryendsession <alias=vForm_wmqueryendsession>( winmsg wmsg )
{
   evparQuery evpQ
   evpQ.val = 1
   .OnCloseQuery.Run( evpQ )
   //wmsg.flags = evpQ.flgCancel
   if evpQ.flgCancel
   {
      wmsg.flags = 1
      return 0
   }  
   return 1
}

//method uint vForm.wmdestroy <alias=vForm_wmdestroy>( winmsg wmsg )
method uint vCtrl.wmdestroy <alias=vForm_wmdestroy>( winmsg wmsg )
{
   evparEvent ev 
   ev.sender = &this
   if this.TypeIs( vForm )
   {
   this->vForm.OnDestroy.Run( ev )
   if this.pOwner == &App && App.Comps[0] == &this
   {
      //MsgBox( "progname".ustr(), "qitemdel".ustr(), $MB_YESNO | $MB_ICONQUESTION )
   //   this.DestroyComp()     
      PostQuitMessage( 0 )
   }
   }
   //elif !wmsg.flags
   //else 
   {      
      //this.hwnd = 0
      //this.fLoad = 0
      //this.fCreate = 0
      //this.mPreDel()
   }
   
   
   return 0    
   //return evpQ.flgCancel    
}


method uint vForm.wmsettingchange <alias=vForm_wmsettingchange>( winmsg wmsg )
{  
   if App.Comps[0] == &this && wmsg.wpar = 0x2A
   {
      App.SettingChange()
   }   
   return 0    
   //return evpQ.flgCancel    
}

method uint vForm.wmactivate <alias=vForm_wmactivate>( winmsg wmsg )
{
   //if this.prevwndproc : CallWindowProc( this.prevwndproc, this.hwnd, wmsg.msg, wmsg.wpar, wmsg.lpar )
   //else : DefWindowProc( this.hwnd, wmsg.msg, wmsg.wpar, wmsg.lpar )
   evparValUint ev
   if ( wmsg.wpar & 0xFFFF ) != $WA_INACTIVE
   {        
       
      /*if .curtab
      {         
         //SetFocus( .curtab->vCtrl.hwnd )
                         
      }
      else*/
      if !.curtab
      {
         .nexttab( 0 )         
      }
      .pActivate = 1
      if .curtab
      {
         PostMessage( this.hwnd, $WM_COMMAND, 0xFFFF0000, this.hwnd )
      }
      
      wmsg.flags = 1
   }
   else : .pActivate = 0
   
   ev.val = .pActivate
   this.OnActivate.Run( ev, this )    
   /*$WA_ACTIVE

   $WA_CLICKACTIVE*/

      
   return 0    
   //return evpQ.flgCancel    
}

method uint vForm.wmshowwindow <alias=vForm_wmshowwindow>( winmsg wmsg )
{
   /*print( "wmShowdindow \(this.hwnd) \(wmsg.wpar)\n" )
   evparValUint ev
   ev.val = wmsg.wpar 
   this.OnShow.Run( ev, this )
         */
   return 0  
}

method vCtrl.mFocus <alias=vCtrl_mFocus>( evparValUint ev )
{
   if ev.val 
   {   
      uint form as this.GetMainForm()->vForm
      if &form && &form != &this : form.curtab = &this      
      if this.form != &this : this.form->vForm.curtab = &this   
   }
   this.OnFocus.Run( ev, this )
}

/* Свойство uint PopupMenu - Get Set
*/
property vPopupMenu vCtrl.PopupMenu()
{
   return this.pPopupMenu->vPopupMenu
}

property vCtrl.PopupMenu( vPopupMenu val )
{     
   if this.pPopupMenu != &val
   {   
      this.pPopupMenu = &val           
   }     
}

/* Свойство uint HelpTopic - Get Set
*/
property ustr vCtrl.HelpTopic <result>()
{
   result = this.pHelpTopic
}

property vCtrl.HelpTopic( ustr val )
{     
   if this.pHelpTopic != val
   {   
      this.pHelpTopic = val           
   }     
}

method uint vForm.mHelp <alias=vForm_mHelp>( vCtrl ctrl  )
{
   uint curctrl as ctrl
subfunc uint ev ( ustr helptopic )
{
   if App.OnHelp.id
   {
      evparValUstr evu
      evu.val = helptopic//"".ustr()
      evu.sender = &ctrl
      return App.OnHelp.Run( evu )
   }
   return 0
}   
   uint res
   
   while &curctrl && curctrl.TypeIs( vCtrl )
   {
      if *curctrl.HelpTopic 
      {         
         if res = ev( curctrl.HelpTopic ) : return res
         return App.HelpM.Topic( curctrl.HelpTopic )         
      }
      curctrl as curctrl.Owner
   }
   ustr us   
   if res = ev( us ) : return res       
   return App.HelpM.Index()  
}


method uint vForm.mWinCmd <alias=vForm_mWinCmd>( uint ntf, uint cmd  )
{
   if ntf == 0xFFFF && !cmd && .pActivate && this.curtab: SetFocus( this.curtab->vCtrl.hwnd )            
   return 0  
}

method vCtrl.Help()
{
   //if *App.HelpM.HelpFile
   .GetMainForm()->vForm.Virtual( $mHelp, this )
}

method uint vCtrl.mKey <alias=vCtrl_mKey> ( evparKey ev )
{
   ev.sender = &this  
   uint res = this.OnKey.Run(/* this,*/ ev )
   
   if !res && ev.evktype == $evkDown  
   {                  
      if ev.key == 0x09  
      {
         if !ev.mstate || ( ev.mstate & $mstShift )
         { 
            this.form->vForm.nexttab( ev.mstate & $mstShift )            
            return 1
         }
      }            
      
      if ev.key == $VK_F1 && !ev.mstate    
      {
         //uint curctrl as this        
         .Help()
         return 0
      }
      
      uint form as .GetMainForm()->vForm  
      if form.Menu && form.Menu.CheckShortKey( ev.mstate, ev.key )
      //if &this.form->vForm.Menu && this.form->vForm.Menu.CheckShortKey( ev.mstate, ev.key ) 
      {
         return 1  
      }  
      uint ctrl as this
      while &ctrl && ctrl.TypeIs( vCtrl ) 
      {
         if &ctrl.PopupMenu && ctrl.PopupMenu.CheckShortKey( ev.mstate, ev.key ) 
         {      
            return 1  
         }  
         ctrl as ctrl.Owner
      }  
      /*if &this.PopupMenu && this.PopupMenu.CheckShortKey( ev.mstate, ev.key ) 
      {      
         return 1  
      }*/     
      if ev.key == 0x1B && !ev.mstate && (form.pFormStyle & $fsModal)
      {
         form.Result = -1
      }
   }
   if ev.evktype == $evkPress
   {
      if ev.key == 0x09 && ( !ev.mstate || ( ev.mstate & $mstShift ) )
      {
         return 1
      }
   }
   //uint res = this.OnKey.Run(/* this,*/ ev )
   return res
}

method uint vCtrl.mMouse <alias=vCtrl_mMouse> ( evparMouse ev )
{
   ev.sender = &this
   
   /*if ev.evmtype == $evmRUp && &this.PopupMenu  
   {      
      POINT pnt
      pnt.x = ev.x
      pnt.y = ev.y
      ClientToScreen( this.hwnd, pnt )
      this.PopupMenu.Show( pnt.x, pnt.y )
      return 0  
   }   */
   return this.OnMouse.Run( /*this,*/ ev )
}
 
 

 
/*include {   
   "menu.g"
}*/
method uint vCtrl.wmcommand <alias=vCtrl_wmcommand>( winmsg wmsg )
{
   switch wmsg.lpar
   {  
      case 0 
      {
       
         uint c as wmsg.wpar->vComp
         c.Virtual( $mMenuClick )
      }
      case 1
      {
      
      }
      default 
      {
         uint msgcmd as wmsg->winmsgcmd
         uint c as getctrl( msgcmd.ctrlhwnd )
         if &c
         {
            c.Virtual( $mWinCmd, msgcmd.ntf, msgcmd.id )
         }  
      }
   }   
   return 0     
}

global 
{
   ustr curhint
}

method uint vCtrl.wmnotify <alias=vCtrl_wmnotify>( winmsg wmsg )
{ 
   uint nmhdr as wmsg.lpar->NMHDR
      
   if nmhdr.code == $TTN_GETDISPINFO
   {      
      nmhdr as NMTTDISPINFO
      //         \(nmhdr.lParam)\n" )
      TOOLINFO ti      
      ti.cbSize = sizeof( TOOLINFO )
      SendMessage( nmhdr.hdr.hwndFrom, $TTM_GETCURRENTTOOL, 0, &ti )      
      uint c as getctrl( ti.hwnd )      
      if &c
      {      
         //ustr curhint = "aaa1"
         curhint.clear()
         c.Virtual( $mGetHint, ti.uId, ti.lParam, curhint )
         if *curhint
         {
            nmhdr.lpszText = curhint.ptr()
         }
      }     
      /*if nmhdr.hdr.idFrom > 1000
      {
         nmhdr.lpszText = nmhdr.hdr.idFrom->vVirtCtrl.pHint.Text( this ).ptr()
      }*/
      //wmsg.flags = 1
      
   }
   elif nmhdr.hwndFrom 
   {
      
      uint c as getctrl( nmhdr.hwndFrom )
      
      if &c 
      {             
         //wmsg.flags = 1          
         return c.Virtual( $mWinNtf, wmsg )
      }
   }      
   return 0     
}

method uint vCtrl.wmdrawitem <alias=vCtrl_wmdrawitem>( winmsg wmsg )
{
   
   if this.prevwndproc : CallWindowProc( this.prevwndproc, this.hwnd, wmsg.msg, wmsg.wpar, wmsg.lpar )
   else : DefWindowProc( this.hwnd, wmsg.msg, wmsg.wpar, wmsg.lpar )
   uint c
   c as getctrl( wmsg.lpar->DRAWITEMSTRUCT.hwndItem )
    
   if !&c 
   {
      c as wmsg.lpar->DRAWITEMSTRUCT.itemID->vComp
   //   return 0
   }
   
   if &c
   {   
   //wmsg.flags = 0
      c.Virtual( $mWinDrawItem, wmsg.lpar->DRAWITEMSTRUCT )
   }           
   wmsg.flags = 1
   return 0     
}

method uint vCtrl.wmmeasureitem <alias=vCtrl_wmmeasureitem>( winmsg wmsg )
{

   if this.prevwndproc : CallWindowProc( this.prevwndproc, this.hwnd, wmsg.msg, wmsg.wpar, wmsg.lpar )
   else : DefWindowProc( this.hwnd, wmsg.msg, wmsg.wpar, wmsg.lpar )
   uint c as vComp
 //  c as getctrl( wmsg.lpar->MEASUREITEMSTRUCT.hwndItem ) 
   if !&c 
   {
      c as wmsg.lpar->MEASUREITEMSTRUCT.itemID->vComp
   //   return 0
   }
     
   if &c
   {
   //wmsg.flags = 0
      c.Virtual( $mWinMeasureItem, wmsg.lpar->MEASUREITEMSTRUCT )
   }           
   wmsg.flags = 1
   return 0     
}

method uint vCtrl.wmmove <alias=vCtrl_wmmove>( winmsg wmsg )
{    
   RECT r
   POINT p              
   GetWindowRect(this.hwnd, r )
   if &this.Owner() && !( this.TypeIs( vForm ) && this->vForm.pFormStyle ) 
   { 
      p.x = r.left
      p.y = r.top
      ScreenToClient( this.Owner->vCtrl.hwnd, p )
      r.left = p.x// + this.Owner->vCtrl.clloc.left //для скролирования
      r.top = p.y// + this.Owner->vCtrl.clloc.top    
   }
   
   
   this.loc.left = r.left
   this.loc.top = r.top      
   evparValUint evu      
   .Virtual( $mPosChanged, evu )
   .flgnoposchanged = 0   
   return 0
}

method uint vCtrl.wmsize <alias=vCtrl_wmsize>( winmsg wmsg )
{
   RECT r
   this.clloc.width  = wmsg.lpar & 0x7FFF
   this.clloc.height = (wmsg.lpar >> 16 ) & 0x7FFF

   GetWindowRect( this.hwnd, r )
   
   this.loc.width = r.right - r.left
   this.loc.height = r.bottom - r.top
   evparValUint evu   
   evu.val = 1   
   .Virtual( $mPosChanged, evu )
   
   .flgnoposchanged = 0
  
   return 0
}

method uint vForm.wmsize <alias=vForm_wmsize>( winmsg wmsg )
{
   if !this.p_designing && .pVisible 
   {  
      if wmsg.wpar == $SIZE_MAXIMIZED : .pWindowState = $wsMaximized
      elif wmsg.wpar == $SIZE_MINIMIZED : .pWindowState = $wsMinimized         
      else : .pWindowState = $wsNormal      
   }
   return this->vCtrl.wmsize( wmsg )
}


method uint vCtrl.wmwindowposchanged <alias=vCtrl_wmwindowposchanged>( winmsg wmsg )
{
   .flgnoposchanged = 1
   if this.prevwndproc : CallWindowProc( this.prevwndproc, this.hwnd, wmsg.msg, wmsg.wpar, wmsg.lpar )
   else : DefWindowProc( this.hwnd, wmsg.msg, wmsg.wpar, wmsg.lpar )
   if .flgnoposchanged && ( !(( wmsg.lpar->WINDOWPOS.flags & $SWP_NOMOVE ) &&
        ( wmsg.lpar->WINDOWPOS.flags & $SWP_NOSIZE ) )/* || 
        wmsg.lpar->WINDOWPOS.flags & $SWP_FRAMECHANGED*/ )
   {
      RECT r
      POINT p              
      GetWindowRect(this.hwnd, r )
      this.loc.width  = r.right - r.left
      this.loc.height = r.bottom - r.top
      if &this.Owner() && !( this.TypeIs( vForm ) && this->vForm.pFormStyle ) 
      { 
         p.x = r.left
         p.y = r.top
         ScreenToClient( this.Owner->vCtrl.hwnd, p )
         r.left = p.x// + this.Owner->vCtrl.clloc.left //для скролирования
         r.top = p.y// + this.Owner->vCtrl.clloc.top    
      }   
      this.loc.left = r.left
      this.loc.top  = r.top      
      evparValUint evu  
      evu.val = !(wmsg.lpar->WINDOWPOS.flags & $SWP_NOSIZE)  
      .Virtual( $mPosChanged, evu )
      .flgnoposchanged = 0
   } 
   wmsg.flags = 1   
   return 0   
   /*if !(( wmsg.lpar->WINDOWPOS.flags & $SWP_NOMOVE ) &&
        ( wmsg.lpar->WINDOWPOS.flags & $SWP_NOSIZE ) ) ||
      ( wmsg.lpar->WINDOWPOS.flags & $SWP_FRAMECHANGED )
   {   
   if this.prevwndproc : CallWindowProc( this.prevwndproc, this.hwnd, wmsg.msg, wmsg.wpar, wmsg.lpar )
   else : DefWindowProc( this.hwnd, wmsg.msg, wmsg.wpar, wmsg.lpar )
   
   RECT r
   GetWindowRect( this.hwnd, r )
   
   POINT p
   p.x = r.left
   p.y = r.top
   if &this.Owner() 
   {
      ScreenToClient( this.Owner->vCtrl.hwnd, p ) 
   }
   
   this.loc.left = p.x//r.left
   this.loc.top = p.y//r.top
   this.loc.width  = r.right - r.left
   this.loc.height = r.bottom - r.top
   
   GetClientRect( this.hwnd, r )
   this.clloc.width  = r.right - r.left
   this.clloc.height = r.bottom - r.top
        
   evparValUint evu
   if !(wmsg.lpar->WINDOWPOS.flags & $SWP_NOSIZE) ||
      ( wmsg.lpar->WINDOWPOS.flags & $SWP_FRAMECHANGED )
   {   
      evu.val = 1
   }
   
   .Virtual( $mPosChanged, evu )
   
   wmsg.flags = 1
   
   }
   
   return 0*/
}

method uint vForm.wmwindowposchanged <alias=vForm_wmwindowposchanged>( winmsg wmsg )
{
   evparValUint ev
   this->vCtrl.wmwindowposchanged( wmsg )
   if wmsg.lpar->WINDOWPOS.flags & $SWP_SHOWWINDOW 
   {
      ev.val = 1   
   }   
   elif !( wmsg.lpar->WINDOWPOS.flags & $SWP_HIDEWINDOW ): return 0
   this.OnShow.Run( ev, this )
   return 0   
}

func uint MouseMsg ( winmsg wmsg, evparMouse em )
{   
   subfunc uint mouse( uint evmtype )
   {  
      uint wpar = wmsg.wpar
      uint lpar = wmsg.lpar
      
      em.evmtype = evmtype
      em.code = $e_mouse
      em.x = int( ( &lpar )->short )
      em.y = int( ( &lpar + 2 )->short )
      if wpar & $MK_CONTROL : em.mstate |= $mstCtrl	
      if wpar & $MK_LBUTTON : em.mstate |= $mstLBtn	
      if wpar & $MK_MBUTTON :	em.mstate |= $mstMBtn
      if wpar & $MK_RBUTTON :	em.mstate |= $mstRBtn
      if wpar & $MK_SHIFT	 : em.mstate |= $mstShift       
      if GetKeyState( $VK_MENU ) & 0x8000 : em.mstate |= $mstAlt
      return 1
   }   
   switch wmsg.msg
   {
      case $WM_MOUSEMOVE
      {
         return mouse( $evmMove )
      }
      case $WM_LBUTTONDOWN
      {      
         return mouse( $evmLDown )
      }
      case $WM_LBUTTONUP 
      {
         return mouse( $evmLUp )
      }    
      case $WM_LBUTTONDBLCLK
      {
         return mouse( $evmLDbl )
      }
      case $WM_RBUTTONDOWN
      {
      
         return mouse( $evmRDown )
      }
      case $WM_RBUTTONUP 
      {
         return mouse( $evmRUp )
      }    
      case $WM_RBUTTONDBLCLK
      {
         return mouse( $evmRDbl )
      }
      case $WM_MOUSELEAVE
      {
         return mouse( $evmLeave )
      }
      case $WM_MOUSEACTIVATE
      {
         return mouse( $evmActivate )
      }
      case $WM_MOUSEWHEEL
      {
         return mouse( ?( int(wmsg.wpar & 0xFFFF0000 >> 16 ) >0, $evmWhellUp, $evmWhellDown ))
      }
   }
   return 0
}

method uint vForm.MsgBox( ustr message, ustr caption, uint flags )
{
   //print( "this \(&this) \(?(&this, this.Name, "" ))\n" )
   return MessageBox( ?( &this, this.hwnd, GetActiveWindow() ), caption->locustr.Text( this ).ptr(), message->locustr.Text( this ).ptr(), flags )
} 

method uint vCtrl.wmMouse <alias=vCtrl_wmMouse>( winmsg wmsg )
{
   evparMouse em
   if MouseMsg( wmsg, em )
   {
      uint form
      /*if form = .GetForm()
      {
         //MSG msg
         SendMessage( form->vForm.hwndTip, $TTM_RELAYEVENT, 0, &wmsg )
         //SendMessage(  form->vForm.hwndTip, $TTM_ACTIVATE, 1, 0 )
         //SendMessage(  form->vForm.hwndTip, $TTM_POPUP, 0, 0 )
      }*/
      wmsg.flags = this.Virtual( $mMouse, em )       
      return em.ret
   }
   return 0
   /*subfunc uint mouse( uint evmtype )
   {  
      uint wpar = wmsg.wpar
      uint lpar = wmsg.lpar
      evparMouse em
      em.evmtype = evmtype
      em.code = $e_mouse
      em.x = int( ( &lpar )->short )
      em.y = int( ( &lpar + 2 )->short )
      if wpar & $MK_CONTROL : em.mstate |= $mstCtrl	
      if wpar & $MK_LBUTTON : em.mstate |= $mstLBtn	
      if wpar & $MK_MBUTTON :	em.mstate |= $mstMBtn
      if wpar & $MK_RBUTTON :	em.mstate |= $mstRBtn
      if wpar & $MK_SHIFT	 : em.mstate |= $mstShift       
      if GetKeyState( $VK_MENU ) & 0x8000 : em.mstate |= $mstAlt                        
      return this.Virtual( $mMouse, em )
   }
   switch wmsg.msg
   {
      case $WM_MOUSEMOVE
      {
         return mouse( $evmMove )
      }
      case $WM_LBUTTONDOWN
      {      
         return mouse( $evmLDown )
      }
      case $WM_LBUTTONUP 
      {
         return mouse( $evmLUp )
      }    
      case $WM_LBUTTONDBLCLK
      {
         return mouse( $evmLDbl )
      }
      case $WM_RBUTTONDOWN
      {
      
         return mouse( $evmRDown )
      }
      case $WM_RBUTTONUP 
      {
         return mouse( $evmRUp )
      }    
      case $WM_RBUTTONDBLCLK
      {
         return mouse( $evmRDbl )
      }
      case $WM_MOUSELEAVE
      {
         return mouse( $evmLeave )
      }
   }
   return 0*/
}


/*Обновляет окно всплывающего меню для отрисовки картинок vFakeMenuItem*/
global {
uint lastmenuhandle
}
method uint vCtrl.wmmenuselect <alias=vCtrl_wmmenuselect>( winmsg wmsg )
{ 
   uint flginval
   if wmsg.msg == $WM_MENUSELECT
   {            
      lastmenuhandle = wmsg.lpar
      goto inval
   }
   else 
   {        
      if lastmenuhandle 
      {
         POINT p
         GetCursorPos( p )        
         if MenuItemFromPoint( 0, lastmenuhandle, p.x, p.y ) == -1
         {  
            lastmenuhandle = 0
            goto inval
         }
      }
   }
   return 0
label inval   
   uint hwnd
   while hwnd = FindWindowEx( 0, hwnd, 32768, 0 )
   {
      InvalidateRect( hwnd, 0->RECT, 0 )
   }
   return 0
}


method uint vCtrl.wmcontextmenu <alias=vCtrl_wmcontextmenu>( winmsg wmsg )
{
   if &this.PopupMenu
   {       
      int x = ( &wmsg.lpar )->short
      int y = ( &wmsg.lpar + 2 )->short
      if x == -1 || y == -1
      {
         POINT pnt
         pnt.x = 10
         pnt.y = 10
         ClientToScreen( this.hwnd, pnt )         
         x = pnt.x
         y = pnt.y              
      }      
      this.PopupMenu.Show( this, x, y )
      wmsg.flags = 1
   }
   return 0
}


/*method vCtrl.iRemoveHint( vVirtCtrl ctrl )
{
   
}
*/
method vForm.iUpdateHint( vVirtCtrl ctrl )
{
   if ctrl.TypeIs( vCtrl )
   { 
      TOOLINFO ti
      uint res
      ustr txt = ctrl.pHint.Text( this )
       
      ti.cbSize = sizeof( TOOLINFO )
      ti.hwnd = ctrl->vCtrl.hwnd
      ti.uId = ctrl->vCtrl.hwnd
      
      res = SendMessage( this.hwndTip, $TTM_GETTOOLINFO, 0, &ti )
            
      if *txt
      {
         ti.uFlags = $TTF_SUBCLASS | $TTF_IDISHWND //| $TTF_SUBCLASS //$TTF_IDISHWND |
         ti.hwnd = ctrl->vCtrl.hwnd 
         ti.uId = ctrl->vCtrl.hwnd         
         ti.lpszText = txt.ptr()
         ti.lParam = &ctrl 
         SendMessage( this.hwndTip, 
               ?( res, $TTM_SETTOOLINFO, $TTM_ADDTOOL ), 0, &ti )
      }
      elif res
      {
         SendMessage( this.hwndTip, $TTM_DELTOOL, 0, &ti )
      }
   }
   /*elif ctrl.pOwner
   {
      TOOLINFO ti
      uint res
      ustr txt = ctrl.pHint.Text( this )
       
      ti.cbSize = sizeof( TOOLINFO )
      ti.hwnd = ctrl.Owner->vCtrl.hwnd
      ti.uId = &ctrl      
      
      res = SendMessage( this.hwndTip, $TTM_GETTOOLINFO, 0, &ti )
            
      if *txt
      {   
         ti.uFlags = $TTF_SUBCLASS //| $TTF_IDISHWND //| $TTF_SUBCLASS //$TTF_IDISHWND |
         ti.hwnd = ctrl.Owner->vCtrl.hwnd 
         ti.uId = &ctrl         
         ti.lpszText = txt.ptr()
         ti.lParam = &ctrl 
         ti.rect.left = ctrl.Left
         ti.rect.top = ctrl.Top
         ti.rect.right = ctrl.Left + ctrl.Width
         ti.rect.bottom = ctrl.Top + ctrl.Height
         
      }
      elif res
      {
         SendMessage( this.hwndTip, $TTM_DELTOOL, 0, &ti )
      }  
   }*/
}

method vCtrl.mSetHint <alias=vCtrl_mSetHint>()
{
   if this.hwnd && this.form 
   {      
      this.GetMainForm()->vForm.iUpdateHint( this )      
   }
}


/*method uint vCtrl.wmclcolorbtn <alias=vCtrl_wmclcolorbtn>(winmsg wmsg )
{
   RECT rc
   

   SetBkMode( wmsg.wpar, $TRANSPARENT )

   //SetBrushOrgEx( wmsg.wpar, -rc.left, -rc.top, 0 )
   
   wmsg.flags = 1
   return 0
}*/






func init_vForm <entry>()
{   

   regcomp( vVirtCtrl, "vVirtCtrl", vComp, $vVirtCtrl_last,
       %{ %{$mLangChanged,  vVirtCtrl_mLangChanged },
          %{$mSetIndex,     vVirtCtrl_mSetIndex } },
      0->collection )      
ifdef $DESIGNING {
   cm.AddComp( vVirtCtrl )
   cm.AddProps( vVirtCtrl,  %{ 
"Visible"  , uint, $PROP_LOADAFTERCREATE,//0,//$PROP_LOADAFTERCHILD,
"Enabled"  , uint, 0,
"Hint"     , ustr, 0
   })
}

   //mcopy( &formproctbl.tbl, &vCtrlproctbl.tbl, $WM_USER << 2 )
   //(&formproctbl.tbl[ $WM_SIZE << 2 ])->uint = getid( "wmsize", 1, %{vForm, uint, uint, uint} )
   WNDCLASSEX visclass
   ustr classname = "GVForm"    
   with visclass
   {
      .cbSize      = sizeof( WNDCLASSEX )
//      .style       = $CS_HREDRAW | $CS_VREDRAW
      .lpfnWndProc = callback( &myproc, 4 )
      .cbClsExtra  = 0
      .cbWndExtra  = 0
      .hInstance   = GetModuleHandle( 0 )
      .hIcon       = 0
      .hCursor     = LoadCursor( 0, $IDC_ARROW )
      .hbrBackground = 16
      .lpszMenuName  = 0
      .lpszClassName = classname.ptr()
      .hIconSm     = 0
   } 
   uint hclass = RegisterClassEx( &visclass )
   regcomp( vCtrl, "vCtrl", vVirtCtrl, $vCtrl_last,
      %{ %{$mCreateWin,    vCtrl_mCreateWin},
         %{$mReCreateWin,  vCtrl_mReCreateWin },
         %{$mDestroyWin,   vCtrl_mDestroyWin},
         %{$mInsert,       vCtrl_mInsert},
         %{$mRemove,       vCtrl_mRemove},
         %{$mPreDel,       vCtrl_mPreDel},
         %{$mPosChanged,   vCtrl_mPosChanged},
         %{$mPosChanging,  vCtrl_mPosChanging},
         %{$mFocus,        vCtrl_mFocus },
         %{$mKey,          vCtrl_mKey },
         %{$mMouse,        vCtrl_mMouse },
         %{$mSetEnabled,   vCtrl_mSetEnabled },
         %{$mSetVisible,   vCtrl_mSetVisible },
         %{$mFontChanged,  vCtrl_mFontChanged },         
         %{$mSetHint,      vCtrl_mSetHint },
         %{$mSetCaption,   vCtrl_mSetCaption },
         %{$mClColor,      vCtrl_mClColor },
         %{$mSetIndex,     vCtrl_mSetIndex },
         %{$mSetDefFont,   vCtrl_mSetDefFont }
       },
      %{ %{$WM_SIZE,       vCtrl_wmsize},
         %{$WM_MOVE,       vCtrl_wmmove},
         %{$WM_COMMAND ,   vCtrl_wmcommand},
         %{$WM_NOTIFY  ,   vCtrl_wmnotify},
         %{$WM_DRAWITEM,   vCtrl_wmdrawitem},
         %{$WM_MEASUREITEM,vCtrl_wmmeasureitem},
         %{$WM_SETFOCUS,   vCtrl_wmfocus},
         %{$WM_KILLFOCUS,  vCtrl_wmfocus},
         
         %{$WM_KEYDOWN,    vCtrl_wmkey},
         %{$WM_SYSKEYDOWN, vCtrl_wmkey},
         %{$WM_KEYUP,      vCtrl_wmkey},
         %{$WM_SYSKEYUP,   vCtrl_wmkey},
         %{$WM_CHAR,       vCtrl_wmkey},
         %{$WM_SYSCHAR,    vCtrl_wmkey},
         %{$WM_MOUSEMOVE,  vCtrl_wmMouse},
         %{$WM_LBUTTONDOWN,  vCtrl_wmMouse},
         %{$WM_LBUTTONUP,  vCtrl_wmMouse},
         %{$WM_LBUTTONDBLCLK,  vCtrl_wmMouse},
         %{$WM_RBUTTONDOWN,  vCtrl_wmMouse},
         %{$WM_RBUTTONUP,  vCtrl_wmMouse},
         %{$WM_RBUTTONDBLCLK,  vCtrl_wmMouse},
         %{$WM_MOUSELEAVE   ,  vCtrl_wmMouse},
         %{$WM_MOUSEACTIVATE,  vCtrl_wmMouse},
         %{$WM_MOUSEWHEEL, vCtrl_wmMouse},

         %{$WM_WINDOWPOSCHANGED, vCtrl_wmwindowposchanged },             
         %{$WM_MOVING,     vCtrl_wmmoving_sizing},
         %{$WM_SIZING,     vCtrl_wmmoving_sizing},         
         %{$WM_CTLCOLORBTN, vCtrl_wmclcolorbtn },
         %{$WM_CTLCOLOREDIT, vCtrl_wmclcolorbtn },
         %{$WM_CTLCOLORSTATIC, vCtrl_wmclcolorbtn },
         %{$WM_ERASEBKGND, vCtrl_wmerasebkgnd },
         %{$WM_CONTEXTMENU, vCtrl_wmcontextmenu },
         %{$WM_MENUSELECT, vCtrl_wmmenuselect },
         %{$WM_ENTERIDLE, vCtrl_wmmenuselect },
         %{$WM_DESTROY,  vForm_wmdestroy }                 
       } )         

  
   regcomp( vForm, "vForm", vCtrl, $vForm_last,
      %{ %{$mCreateWin, vForm_mCreateWin},
         //%{$mReCreateWin, vForm_mReCreateWin},
         //%{$mPosChanged, vForm_mPosChanged},
         %{$mPosChanging, vForm_mPosChanging},
         %{$mSetOwner,   vForm_mSetOwner},
         %{$mSetVisible,vForm_mSetVisible },
         %{$mInsert,       vForm_mInsert},
         %{$mRemove,       vForm_mRemove},
         %{$mLangChanged,  vForm_mLangChanged },
         %{$mHelp,         vForm_mHelp },
         %{$mWinCmd, vForm_mWinCmd }/*,
         %{$mKey,          vForm_mKey }*/
      },
      %{ %{$WM_SIZE,     vForm_wmsize},
         %{$WM_CLOSE,    vForm_wmclose },
         %{$WM_QUERYENDSESSION, vForm_wmqueryendsession }, 
//         %{$WM_DESTROY,  vForm_wmdestroy },
         %{$WM_SETTINGCHANGE, vForm_wmsettingchange },
         %{$WM_ACTIVATE, vForm_wmactivate },
         %{$WM_SHOWWINDOW, vForm_wmshowwindow },
         %{$WM_WINDOWPOSCHANGED, vForm_wmwindowposchanged }       
          } )
      
ifdef $DESIGNING {   
      
   cm.AddComp( vCtrl )   
      
   cm.AddProps( vCtrl,  %{ 
"Left"     , int,  0,
"Top"      , int,  0, 
"Width"    , uint, 0,
"Height"   , uint, 0,
"Right"    , int,  $PROP_LOADAFTERCREATE,
"Bottom"   , int,  $PROP_LOADAFTERCREATE,
"VertAlign", uint, 0,
"HorzAlign", uint, 0,
"Style"    , str,  0,
"PopupMenu", vPopupMenu, $PROP_LOADAFTERCREATE,
"HelpTopic", ustr, 0,
"TabOrder",  uint, 0
   })       
   
   cm.AddPropVals( vCtrl, "HorzAlign", %{ 
"alhLeft",      $alhLeft,    
"alhClient",    $alhClient,
"alhRight",     $alhRight,        
"alhCenter",    $alhCenter,              
"alhLeftRight", $alhLeftRight 
   })
      
   cm.AddPropVals( vCtrl, "VertAlign", %{ 
"alvTop",       $alvTop,     
"alvClient",    $alvClient,
"alvBottom",    $alvBottom,        
"alvCenter",    $alvCenter,              
"alvTopBottom", $alvTopBottom 
   })
   
   cm.AddEvents( vCtrl, %{
"OnPosChanged", "evparEvent",
"OnMouse", "evparMouse",
"OnKey", "evparKey",
"OnFocus", "evparValUint"  
   })
   
   cm.AddComp( vForm )
   cm.AddProps( vForm,  %{ 
"Caption"  , ustr,  0,
"Border", uint, 0,
"WindowState", uint, 0,
"Menu"     , vMenu, $PROP_LOADAFTERCHILD,
"IconName", ustr, 0,
"StartPos", uint, 0,
"TopMost", uint, 0,
"FormStyle", uint, 0,
"ClientWidth", uint, $PROP_LOADAFTERCHILD, //$PROP_LOADAFTERCREATE,
"ClientHeight", uint, $PROP_LOADAFTERCHILD//$PROP_LOADAFTERCREATE
   })
   
   cm.AddEvents( vForm, %{
"OnCreate"      , "evparEvent",
"OnDestroy"     , "evparEvent",
"OnCloseQuery"  , "evparQuery",
"OnLanguage"    , "evparEvent",
"OnShow"        , "evparValUint",
"OnActivate"    , "evparValUint"

   })     
   
   cm.AddPropVals( vForm, "Border", %{
"fbrdNone",     $fbrdNone,       
"fbrdSizeable", $fbrdSizeable,      
"fbrdDialog",   $fbrdDialog,
"fbrdSizeToolWin", $fbrdSizeToolWin
   })
   
   cm.AddPropVals( vForm, "WindowState", %{
"wsNormal",     $wsNormal,  
"wsMaximized",  $wsMaximized,                                          
"wsMinimized",  $wsMinimized 
   })         
   
   cm.AddPropVals( vForm, "StartPos", %{
"spDesigned",     $spDesigned,     
"spScreenCenter", $spScreenCenter,        
"spParentCenter", $spParentCenter 
   })
   
cm.AddPropVals( vForm, "FormStyle", %{
"fsChild",     $fsChild,     
"fsPopup",     $fsPopup 
   })                                                                                           
                                                                                                                                    
}
}


func noenableproc( uint hwnd, uint lParam )
{   
   uint modallist as lParam->arr of uint
   if IsWindowVisible( hwnd ) && IsWindowEnabled( hwnd )
   {      
      modallist += hwnd
      EnableWindow( hwnd, 0 )
   }
}

method vForm.ShowPopup( vComp owner )
{
   if &owner
   {
      this.Owner = owner
   }
   elif !&this.Owner
   {
      uint activewnd = GetActiveWindow()
      if activewnd 
      {
         this.Owner = getctrl( activewnd )
      }
      elif *App.Comps
      {  
         this.Owner = App.Comps[0]->vComp
      }
      else : this.Owner = App
   }   
   
   //if this.Owner && this.Visible : return 
   //print( "formstyle \(this.pFormStyle)\n" )
   this.pFormStyle = $fsPopup
   
   //this.Owner = owner
   this.Visible = 1
}

method vForm.ShowPopup()
{
   .ShowPopup( 0->vComp )
}

define {
QS_KEY             = 0x0001
QS_MOUSEMOVE       = 0x0002
QS_MOUSEBUTTON     = 0x0004
QS_POSTMESSAGE     = 0x0008
QS_TIMER           = 0x0010
QS_PAINT           = 0x0020
QS_SENDMESSAGE     = 0x0040
QS_HOTKEY          = 0x0080
QS_ALLPOSTMESSAGE  = 0x0100
QS_RAWINPUT        = 0x0400
QS_MOUSE           = $QS_MOUSEMOVE | $QS_MOUSEBUTTON
QS_INPUT           =($QS_MOUSE|$QS_KEY|$QS_RAWINPUT)
QS_ALLEVENTS       =($QS_INPUT|$QS_POSTMESSAGE|$QS_TIMER|$QS_PAINT|$QS_HOTKEY)
QS_ALLINPUT        =($QS_INPUT|$QS_POSTMESSAGE|$QS_TIMER|$QS_PAINT|$QS_HOTKEY|$QS_SENDMESSAGE)
}
method uint vForm.ShowModal( vComp owner )
{
   arr  modallist of uint
   uint thread
   uint activewnd = GetActiveWindow()   
   //if &this.Owner && this.Visible : return 0
   //this.pFormStyle = $fsModal
   this.pResult = 0
   //uint flgnew
   .FormStyle = $fsModal
   
//   print( "SHOWMODAL \(.hwnd) \(.Name) \(.Width) \n" )  
   if &owner && &owner != &App
   {
      this.Owner = owner.GetMainForm()->vForm
   }   
   elif !&this.Owner 
   { 
      if activewnd
      {  
         this.Owner = getctrl( activewnd )
      }
      elif *App.Comps
      {
         this.Owner = App.Comps[0]->vComp
      }
      else : this.Owner = App
   }
   // $fsModal
   
   //this.Owner = App   
   /*if !&this.Owner() : flgnew = 1
   if &owner
   {
      this.Owner = owner
      if flgnew && owner.TypeIs( vForm ) 
      {
         this.Left =  max( owner.Left + ( owner.Width - this.Width ) / 2, 20 ) 
         this.Top =  max( owner.Top + ( owner.Height - this.Height ) / 2, 20 )
      }
   }
   else :this.Owner = App*/   
   //this.Visible = 0  
   this.curtab = 0
   
   
//   print( "zz-1\n" )
//   Sleep( 2000 )
   //uint callbackproc = callback( &noenableproc, 2 )
   EnumThreadWindows( thread = GetCurrentThreadId(), cbnoenableproc, &modallist )
//   print( "zz0\n" )
//   Sleep( 2000 )
   this.Visible = 1
//   print( "zz1\n" )
//   Sleep( 2000 )
   SetActiveWindow( this.hwnd )
//   print( "zz2\n" )
//   Sleep( 2000 )
   
   MSG msg    
   uint exit   
   
   App.showmodalcnt++   
   
   while (exit=GetMessage( &msg, 0, 0, 0 )) && !.Result && this.Visible 
   {
   /*   "AAAAAAAAAAAAA\n"
   "VVVVVVVVVVVVVV\n"
   "DDDDDDDDDDDDDDDD\n"
   "AAAAAAAAAAAAA\n"
   "VVVVVVVVVVVVVV\n"
   "DDDDDDDDDDDDDDDD\n"*/      
      TranslateMessage( &msg )
      DispatchMessage( &msg )
      //if !GetQueueStatus( $QS_ALLINPUT) && .Result : break
   }
   App.showmodalcnt--
   uint i   
   fornum i = 0, *modallist
   {      
      if !IsWindowEnabled( modallist[i] )
      {
         EnableWindow( modallist[i], 1 )
      }
   }
   this.Visible = 0
   if IsWindowVisible( .hwnd )
   {        
      .Visible = 1
      .Visible = 0
   }       
     
   SetActiveWindow( ?( &owner && &owner != &App && this.Owner.TypeIs( vForm ), this.Owner->vForm.hwnd, activewnd) )
   
   //print( "ex \(ex )\n" )
   if !exit : PostQuitMessage( 0 )  
   //this.Visible = 0   
   return .Result
}

method uint vForm.ShowModal( )
{
   return .ShowModal( 0->vForm )
}
