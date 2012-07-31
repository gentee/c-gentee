/******************************************************************************
*
* Copyright (C) 2004-2007, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: vis.tabpage 24.07.07 0.0.A.
*
* Author: Alexander Krivonogov ( gentee )
*
******************************************************************************/



/*------------------------------------------------------------------------------
   Internal Methods
*/
/*Метод vTabItem.iUpdate()
Обновить оконное представление
*/
method vTabItem.iUpdate()
{
   TCITEM tci
   tci.mask = $TCIF_TEXT | $TCIF_IMAGE
   /* | $TCIF_PARAM
   tci.lParam = &this*/
   tci.pszText = this.pCaption.Text(this).ptr()
   tci.iImage = .pImageIndex   
   .Owner->vTab.WinMsg( $TCM_SETITEMW, .pWinIndex, &tci )
   //InvalidateRect( .Owner->vTab.hwnd, 0->RECT, 0 )
   //.Owner->vTab.Invalidate()
   //UpdateWindow( .Owner->vTab.hwnd )
   .Owner->vTab.WinMsg( $WM_SIZE, $SIZE_RESTORED, .Owner->vTab.Width | (.Owner->vTab.Height << 16 ));   
}

/*------------------------------------------------------------------------------
   Properties
*/
/* Свойство ustr Caption - Get Set
Устанавливает или получает заголовок закладки
*/
property locustr vTabItem.Caption <result>
{
   result = .pCaption.Value
}

property vTabItem.Caption( ustr val )
{   
   .pCaption.Value = val
   .iUpdate()       
}


/* Свойство uint Index - Get Set
Устанавливает или получает индекс закладки
*/
property uint vTabItem.Index
{
   return this.TabOrder  
}

property vTabItem.Index( uint val )
{           
   if this.Owner && this.Owner->vCtrl.TypeIs( vTab )
   {
      if .pIndex != val//.cidx != val
      {
         uint i         
         //uint curenabled = .pEnabled
         //this.Enabled = 0
         this.TabOrder = val
         //this.Enabled = 1
         this.mSetEnabled()      
         this.iUpdate()
         uint ctrls as this.Owner->vCtrl.Comps//ctrls    
         fornum i, this.Owner->vCtrl.pCtrls/**ctrls*/
         {
            if ctrls[i]->vCtrl.Visible : break
         }
         
         this.Owner->vTab.CurIndex = i
      }      
   }      
}

/* Свойство ustr vTab.ImageId - Get Set
Устанавливает или получает картинку
*/
property ustr vTabItem.ImageId <result>
{
   result = this.pImageId
}

property vTabItem.ImageId( ustr val )
{
   if val != this.pImageId
   { 
      this.pImageId = val
      
      if &.Owner && .Owner->vTab.ptrImageList
      {              
         this.pImageIndex = .Owner->vTab.ptrImageList->ImageList.GetImageIdx( .Owner->vTab.iNumIml, val, 0 )         
      }
      else : this.pImageIndex = -1    
      .iUpdate()
      
   }   
}

/*------------------------------------------------------------------------------
   Virtual Methods
*/

method vTabItem vTabItem.mCreateWin <alias=vTabItem_mCreateWin>()
{
   //getch()
   this.CreateWin( /*"GVTransparent".ustr()*//*"Static".ustr()/*"#32770".ustr()*/ "GVForm".ustr(), /*0x00010400*/0, /* |*/
                     /*0x50000000/*0x50010444*/  $WS_CHILD | $WS_CLIPSIBLINGS | $WS_CLIPCHILDREN )   
   this.prevwndproc = -1
   this->vCtrl.mCreateWin()   
   //setxpstyle( this.hwnd )
   //SendMessage( this.hwnd, $WM_SETFONT, GetStockObject( $DEFAULT_GUI_FONT ),0 )      
//   setxpstyle( this.hwnd )
   //ShowWindow( this.hwnd, 1)
   return this
}

/*method uint vTabItem.mPosChanging <alias=vTabItem_mPosChanging>( evparEvent ev )
{  
   this->vCtrl.mPosChanging( ev )         
   if this.Owner.TypeIs( vTab )
   {           
      uint evp as ev->eventpos         
      evp.loc = this.Owner->vTab.pAdjLoc                     
      if evp.move //&& evp.loc != this.loc
      {
         print( "adj \(evp.loc.left), \(evp.loc.top), \(evp.loc.width), \(evp.loc.height)\n" )
         this.onposchanging.run( evp )
        // this.SetLocation( evp.loc.left, evp.loc.top, evp.loc.width, evp.loc.height )            
         /*SetWindowPos( this.hwnd, 0, 
               evp.loc.left, evp.loc.top, evp.loc.width, evp.loc.height, 
               $SWP_NOACTIVATE | $SWP_NOZORDER )            
         RedrawWindow( this.hwnd, 0->RECT, 0, 0x507)
   //   }
   }
   
   return 0        
}*/

method vTabItem.mSetVisible <alias=vTabItem_mSetVisible>( )
{  
   
   if this.pVisible
   { 
      uint owner = &this.GetMainForm()->vForm.ActiveControl
      while owner
      {
         if &owner->vComp.Owner == &this.Owner
         {
            //this.GetMainForm()->vForm.nexttab( 1 )
            //this.nexttab(1)
            this.SetFocus()
            this.GetMainForm()->vForm.nexttab( 0 )
            break
         }
         owner = &owner->vComp.Owner
      }
   }   
   ShowWindow( this.hwnd, ?( this.pVisible, $SW_SHOWNOACTIVATE, $SW_HIDE ))
}

method vTabItem.mSetEnabled <alias=vTabItem_mSetEnabled>( )
{
   uint i
   /*if .pEnabled != val
   {*/
      if !.pEnabled
      {
         .Owner->vCtrl.WinMsg( $TCM_DELETEITEM, .pWinIndex )
         fornum i = .pIndex + 1, this.Owner->vCtrl.pCtrls//.cidx + 1, this.Owner->vCtrl.pCtrls
         {
            uint item as .Owner->vCtrl./*ctrls*/Comps[i]->vTabItem
            if item.Enabled 
            {
               item.pWinIndex--
            }
         }
         .pWinIndex = -1
         if .Owner->vTab.CurIndex == .pIndex//.cidx 
         {           
            .Owner->vTab.CurIndex = .pIndex - 1//.cidx - 1            
         }
      }
      else
      {      
         TCITEM tci
         //tci.mask= $TCIF_TEXT | $TCIF_IMAGE
         //tci.iImage = -1
         uint i, winindex         
         fornum i = 0, .pIndex//.cidx
         {
            uint item as .Owner->vCtrl./*ctrls*/Comps[i]->vTabItem            
            if item.Enabled
            {
               winindex++
            }
         }
         .pWinIndex = winindex
         fornum i = .pIndex + 1, this.Owner->vCtrl.pCtrls//.cidx + 1, this.Owner->vCtrl.pCtrls
         {
            uint item as .Owner->vCtrl./*ctrls*/Comps[i]->vTabItem
            if item.Enabled 
            {               
               item.pWinIndex++
            }
         }
         /*tci.mask = $TCIF_PARAM
         tci.lParam = &this
         print( "param1 = \(tci.lParam)\n" )*/
         .Owner->vCtrl.WinMsg( $TCM_INSERTITEMW, .pWinIndex, &tci )
         .iUpdate()
         if .Owner->vTab.CurIndex == -1
         {
            .Owner->vTab.CurIndex = 0  
         }
         //this->vCtrl.mSetEnabled()
      }
      this->vCtrl.mSetEnabled()
      .Owner->vTab.iCalcAdj()
   //}
}

/*Виртуальный метод uint vTabItem.mLangChanged - Изменение текущего языка
*/
method vTabItem.mLangChanged <alias=vTabItem_mLangChanged>()
{   
   .iUpdate()
   this->vCtrl.mLangChanged()  
}
/*method vTabItem.mSetOwner <alias = vTabItem_mSetOwner> ( vComp newowner )
{   
   if newowner && newowner.TypeIs( vTab )
   {
      this->vCtrl.mSetOwner( newowner )  
      TCITEM tci               
      .Owner->vTab.WinMsg( $TCM_INSERTITEMW, 0, &tci )
      .Owner->vTab.iCalcAdj()
      .iUpdate()    
      eventpos evp
      evp.code = $e_poschanging 
      evp.move = 1
      .Virtual( $mPosChanging, &evp )            
   } 
   else
   {
      .pOwner = 0
   }
}*/

/*------------------------------------------------------------------------------
   Registration
*/
method vTabItem vTabItem.init( )
{    
   this.pTypeId = vTabItem
   
   this.pCanContain = 1
   this.pVisible = 0
   ///this.pEnabled = 0
   this.flgXPStyle = 1
   
   /*WNDCLASSEX visclass
   ustr classname = "GVTransparent"   
   with visclass
   {
      .cbSize      = sizeof( WNDCLASSEX )
      //.style       = $CS_HREDRAW | $CS_VREDRAW
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
   uint hclass = RegisterClassEx( &visclass )*/ 
   return this 
}  

/*method vTabItem.getprops( uint typeid, compMan cm )
{
   this->vCtrl.getprops( typeid, cm)
   cm.addprops( typeid, 
%{ "caption"     , str, 0})                         
}*/
/*
method vTabItem.getevents()
{
   %{"onclick"}
}
*/

func init_vTabItem <entry>()
{
   regcomp( vTabItem, "vTabItem", vCtrl, $vCtrl_last,
      %{ %{$mCreateWin,    vTabItem_mCreateWin },
         //%{$mPosChanging,  vTabItem_mPosChanging },
         %{$mSetEnabled,   vTabItem_mSetEnabled },
         %{$mSetVisible,   vTabItem_mSetVisible },
         %{$mLangChanged,  vTabItem_mLangChanged }
      },
      /*%{
      //%{$WM_CTLCOLORBTN, vTabItem_wmclcolorbtn },
      %{$WM_CTLCOLORSTATIC, vTabItem_wmclcolorbtn },
      %{$WM_ERASEBKGND, vTabItem_wmerasebkgnd }}*/
      0->collection )
} 
