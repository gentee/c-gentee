/******************************************************************************
*
* Copyright (C) 2004-2008, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: vis.ctrl 25.03.08 0.0.A.
*
* Author: Alexander Krivonogov ( gentee )
*
******************************************************************************/
/*------------------------------------------------------------------------------
   Import
*/
type NOTIFYICONDATA {
   uint cbSize
   uint hWnd
   uint uID
   uint uFlags
   uint uCallbackMessage
   uint hIcon
   reserved  szTip[128*2]
   uint dwState
   uint dwStateMask
   reserved  szInfo[256*2]
   uint  uTimeout        
   reserved  szInfoTitle[64*2]
   uint dwInfoFlags        
} 

import "shell32.dll" {
   uint Shell_NotifyIconW( uint, NOTIFYICONDATA )->Shell_NotifyIcon
}

define {
   NIM_ADD         = 0x00000000
   NIM_MODIFY      = 0x00000001
   NIM_DELETE      = 0x00000002   
   NIM_SETFOCUS    = 0x00000003
   NIM_SETVERSION  = 0x00000004
   
   NIF_MESSAGE     = 0x00000001
   NIF_ICON        = 0x00000002
   NIF_TIP         = 0x00000004   
   NIF_STATE       = 0x00000008
   NIF_INFO        = 0x00000010
   
   WM_USERTRAY     = $WM_USER + 1
}

/* Компонент vTray, порождена от vComp
События
   onMouse - вызывается при сообщении от мышки над иконкой  
*/

type vTray <inherit = vComp>
{
//Hidden Fields
   locustr  pCaption  
   uint     pVisible
   ustr     pImage
   uint     pLBtnPopupMenu
   uint     pRBtnPopupMenu   
   uint     flgShow
   uint     flgDeleting  
   uint     oldProc   
   
//Events     
   evMouse  OnMouse
}

/*------------------------------------------------------------------------------
   Internal Methods
*/
/* Метод iUpdateTray
Обновляет настройки иконки
*/
method vTray.iUpdateTray( )
{   
   if this.p_designing : return 
   
   NOTIFYICONDATA nid
   uint nim   
   uint form as  this.GetMainForm()->vForm
   uint ptrImage as .GetImage( .pImage )
   uint caption as this.pCaption.Text( this )  
   if !.flgShow && .pOwner && form.hwnd && .pVisible && !.flgDeleting   
   {
      nim = $NIM_ADD
      .flgShow = 1
   }
   elif .flgShow
   {
      if !.pOwner || !.pVisible || .flgDeleting
      {     
         nim = $NIM_DELETE
         .flgShow = 0
      }
      else
      {
         nim = $NIM_MODIFY
      }
   }
   else : return 
   nid.cbSize = sizeof( NOTIFYICONDATA )
   
   nid.uCallbackMessage = $WM_USERTRAY
   if &ptrImage
   {       
      nid.hIcon = ptrImage.hImage
   } 
   nid.uFlags = $NIF_TIP | $NIF_ICON | $NIF_MESSAGE
   
   if *caption > 127 : caption.setlen( 127 )   
   mcopy( &nid.szTip, caption.ptr(), *caption->buf )
   nid.hWnd = ?( &form, form.hwnd, 0 )
      
   nid.uID = &this  
   
   Shell_NotifyIcon( nim, nid )
}

/*------------------------------------------------------------------------------
   Properties
*/
/* Свойство str vTray.Image - Get Set
Усотанавливает или получает картинку
*/
property ustr vTray.Image <result>
{
   result = this.pImage
}

property vTray.Image( ustr val )
{
   if val != this.pImage
   { 
      this.pImage = val
      .iUpdateTray()
   }  
}

/* Свойство uint vTray.Visible - Get Set
0 - иконка в трэе не видна
1 - иконка в трэе видна
*/
property uint vTray.Visible
{   
   return .pVisible
}

property vTray.Visible( uint val )
{
   if .pVisible != val
   {
      .pVisible = val      
      .iUpdateTray()            
   }
}

/* Свойство ustr vTray.Caption - Get Set
Устанавливает или определяет заголовок иконки
*/
property ustr vTray.Caption <result>
{
   result = this.pCaption.Value
}

property vTray.Caption( ustr val )
{  
   if val != this.pCaption.Value
   { 
      this.pCaption.Value = val
      .iUpdateTray()
   }         
}


/* Свойство uint LBtnPopupMenu - Get Set
Меню по левой кнопке мыши
*/
property vPopupMenu vTray.LBtnPopupMenu()
{
   return this.pLBtnPopupMenu->vPopupMenu
}

property vTray.LBtnPopupMenu( vPopupMenu val )
{     
   if this.pLBtnPopupMenu != &val
   {   
      this.pLBtnPopupMenu = &val           
   }     
}

/* Свойство uint RBtnPopupMenu - Get Set
Меню по правой кнопке мыши
*/
property vPopupMenu vTray.RBtnPopupMenu()
{
   return this.pRBtnPopupMenu->vPopupMenu
}

property vTray.RBtnPopupMenu( vPopupMenu val )
{     
   if this.pRBtnPopupMenu != &val
   {
      this.pRBtnPopupMenu = &val           
   }     
}

/*------------------------------------------------------------------------------
   Virtual Methods
*/
/*Виртуальный метод uint vCustomBtn.mLangChanged - Изменение текущего языка
*/
method vTray.mLangChanged <alias=vTray_mLangChanged>()
{
   this->vCtrl.mLangChanged()
   .iUpdateTray()       
}


method uint vForm.wmusertray <alias=vForm_wmusertray>( winmsg wmsg )
{
   uint tray as wmsg.wpar->vTray   
   if &tray && tray.GetForm() == &this 
   {  
      if wmsg.msg == $WM_USERTRAY 
      {      
         winmsg mmsg
         mmsg.msg = wmsg.lpar
         evparMouse em         
         if MouseMsg( mmsg, em )
         {  
            if em.evmtype == $evmRDown && &tray.RBtnPopupMenu  
            {
               SetForegroundWindow( this.hwndTip )
               tray.RBtnPopupMenu.Show( this )               
               return 0  
            }
            elif em.evmtype == $evmLDown && &tray.LBtnPopupMenu
            {
               SetForegroundWindow( this.hwndTip )
               tray.LBtnPopupMenu.Show( this )
               return 0               
            }  
            return tray.OnMouse.Run( em )  
         }  
         /*elif wmsg.lpar == $WM_CONTEXT
         {
            
         }  */     
      }
      /*elif tray.oldProc 
      {
         return tray.oldProc->func( &this, &wmsg )
      }*/
   }   
   return 0  
}

method vTray.mSetOwner <alias = vTray_mSetOwner>( vComp newowner )
{       
   if this.pOwner
   {
      gettypedef( this.Owner->vCtrl.GetForm()->vComp.pTypeId ).delproc( $WM_USERTRAY, .oldProc )
      //gettypedef( this.Owner->vCtrl.GetForm()->vComp.pTypeId ).ProcTbl[ $WM_USER ]  = .oldProc    
   }   
   this->vComp.mSetOwner( newowner )   
   if &newowner
   {
      .oldProc = gettypedef( this.Owner->vCtrl.GetForm()->vComp.pTypeId ).setproc( $WM_USERTRAY, vForm_wmusertray )  
      /*uint addr = &gettypedef( newowner.GetForm()->vComp.pTypeId ).ProcTbl[ $WM_USER ]
      
      .oldProc = addr->uint
      addr->uint = vForm_wmusertray*/
   }   
   .iUpdateTray()
}

method vTray.mPreDel <alias=vTray_mPreDel>
{   
   .flgDeleting = 1
   .iUpdateTray()
   this->vComp.mPreDel()
}

method vTray.mOwnerCreateWin <alias=vTray_mOwnerCreateWin>
{  
   .iUpdateTray()   
}

/*------------------------------------------------------------------------------
   Registration
*/
method vTray vTray.init( )
{
   this.pTypeId = vTray
   return this 
}

func init_vTray <entry>()
{     
   regcomp( vTray,      "vTray", vComp, $vComp_last, 
      %{ %{$mSetOwner,     vTray_mSetOwner }, 
         %{$mPreDel,       vTray_mPreDel },
         %{$mLangChanged,  vTray_mLangChanged },
         %{$mOwnerCreateWin,  vTray_mOwnerCreateWin }
      },
      0->collection )
            
            
ifdef $DESIGNING {
   cm.AddComp( vTray, 1, "Windows", "tray" )   
   
   cm.AddProps( vTray, %{ 
"Caption", ustr, 0,
"Visible", uint, 0,
"Image"  , ustr, 0,
"LBtnPopupMenu", vPopupMenu, $PROP_LOADAFTERCREATE,
"RBtnPopupMenu", vPopupMenu, $PROP_LOADAFTERCREATE
   }) 
   
   cm.AddEvents( vTray, %{
"OnMouse"      , "evparMouse"
   })
               
}
      
}
