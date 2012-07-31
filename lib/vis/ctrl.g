/******************************************************************************
*
* Copyright (C) 2004-2007, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: vis.ctrl 17.07.07 0.0.A.
*
* Author: Alexander Krivonogov ( gentee )
*
******************************************************************************/
/* Компонента vCtrl, порождена от vComp
События
   
*/


include
{   
   "virtctrl.g"   
   //"addustr.g"   
}

type winmsg <inherit=MSG>{
   //uint hwnd   
   //uint msg
   //uint wpar
   //uint lpar
   uint flags 
}

type winmsgsh {
   uint hwnd
   uint msg
   ushort wparlo
   ushort wparhi
   ushort lparlo
   ushort lparhi
   uint flags 
}

type winmsgmouse{
   uint hwnd
   uint msg
   uint wpar
   short x
   short y
   uint flags
}

type winmsgcmd {
   uint hwnd
   uint msg   
   ushort id
   ushort ntf 
   uint ctrlhwnd
   uint flags
}      

/*
operator vloc =( vloc l, r )
{
   mcopy( &l, &r, sizeof(vloc) )
   return l
}

operator uint ==( vloc l, r )
{
   return l.left == r.left && l.top == r.top && l.width == r.width && l.height == r.height
}
*/


type vCtrl <inherit = vVirtCtrl>
{
//Hidden Fields

   uint prevwndproc         
   vloc clloc
   uint hwnd   
   
      
   uint pCanContain
   uint pCanFocus
   uint pTabStop      
   uint pAlign
   uint pRight
   uint pBottom
   uint pCtrls //Количество дочерних контролов
   str  pFont   
   //uint hFont    
   uint pPopupMenu
   ustr pHelpTopic
   
   str  pStyle
   uint aStyle 

   uint flgnoposchanged   
   uint flgXPStyle  //Контрол должен поддерживать обработку фона для XP
   uint flgRePaint //Принудительная перерисовка при изменении размеров нужна для STATIC
   uint flgNoPosChanging //Запрет на перемещение и изменение размеров
   uint flgReCreate //Флаг пересоздавать при пересоздании хозяина
   //uint flgPosChanging
   
   uint pMinWidth
   uint pMinHeight
   uint pMaxWidth
   uint pMaxHeight
   uint fMinMax
   
//Public Fields   
//   arr  ctrls of uint         

//Events            
   oneventpos  onposchanging
   evEvent     OnPosChanged
   evEvent     onownersize
   evMouse     OnMouse
   evKey       OnKey
   
   //oneventuint onfocus
   evValUint   OnFocus
   //uint oncomnotify
}

define <export>{   
   mReCreateWin  = $vVirtCtrl_last    
   mDestroyWin
   mPosChanged 
   //mPosChanging   
   mWinCmd
   mWinNtf
   mWinDrawItem
    mWinMeasureItem
   mFocus
   mKey
   mMouse   
   mFontChanged
   
   mDesChanging
   mDesChanged
   
   mGetHint   
   
   mClColor
   
   mSetDefFont
   
   vCtrl_last
}

extern {
func uint myproc( uint hwnd, uint msg, uint wpar, uint lpar )
property uint vCtrl.TabOrder
property vCtrl.TabOrder( uint newidx )
}


define {
   TAB_INSERT = 1
   TAB_REMOVE
   TAB_MOVE   
}


define <export> 
{   
   alhLeft       = 0x01
   alhClient     = 0x02
   alhRight      = 0x04     
   alhCenter     = 0x08
   alhLeftRight  = 0x10
   ALH_MASK      = 0xFF              
   
   alvTop        = 0x0100
   alvClient     = 0x0200   
   alvBottom     = 0x0400
   alvCenter     = 0x0800   
   alvTopBottom  = 0x1000
   ALV_MASK      = 0xFF00
}






func win_move( uint hwnd, int x y )
{
   SetWindowPos( hwnd, 0, x, y, 0, 0, $SWP_NOACTIVATE | $SWP_NOZORDER | $SWP_NOSIZE )
}

func win_loc( uint hwnd, int x y width height )
{   
   MoveWindow( hwnd, x, y, width, height, 1 )
}



method vCtrl.ownerresize( vloc n )
{   
   if this.pOwner && this.pOwner != &App      
   {
       int width, height
      
      //n.left -= this.Owner->vCtrl.clloc.left
      //n.top -= this.Owner->vCtrl.clloc.top
      
   
      width = this.Owner->vCtrl.clloc.width
      height = this.Owner->vCtrl.clloc.height
    
      switch this.pAlign & $ALV_MASK
      {
         case $alvTop
         {
            //Привязать к позиции верхнего края
            //Ничего делать не надо            
         }
         case $alvClient 
         {              
            //Растянуть на всю высоту
            n.top = 0
            n.height = height            
         }
         case $alvBottom 
         {
            //Привязать к позиции нижнего края
            n.top = height - n.height - this.pBottom             
         }
         case $alvCenter 
         {          
            //Центрировать
            n.top = (height - n.height )>>1            
         }
         case $alvTopBottom
         {
            n.height = height - n.top - this.pBottom
         }
      }
      switch this.pAlign & $ALH_MASK
      {
         case $alhLeft
         {
            //Привязать к позиции верхнего края
            //Ничего делать не надо
         }
         case $alhClient 
         {           
            //Растянуть на всю высоту
            n.left = 0
            n.width = width
         }
         case $alhRight
         {       
            //Привязать к позиции нижнего края
            n.left = width - n.width - this.pRight             
         }
         case $alhCenter 
         {
            //Центрировать
            n.left = (width - n.width )>>1            
         }
         case $alhLeftRight 
         {           
            //Растягивать с отступами
            n.width = width - this.pRight - n.left
         }
      }
      if .fMinMax
      {
         if .pMinWidth
         {
            n.width = max( n.width, .pMinWidth )
         }
         if .pMaxWidth
         {
            n.width = min( n.width, .pMaxWidth )
         }
         if .pMinHeight
         {
            n.height = max( n.height, .pMinHeight )
         }
         if .pMaxHeight
         {
            n.height = min( n.height, .pMaxHeight )
         }          
      }
   }      
}

method vCtrl.Invalidate()
{
   if this.hwnd: InvalidateRect( this.hwnd, 0->RECT, 1 )
}


method vCtrl.CreateWin( ustr class, uint exstyle, uint style, ustr caption )
{   
   if .pVisible : style |= $WS_VISIBLE 
   if !.pEnabled : style |= $WS_DISABLED   
   this.hwnd = CreateWindowEx( exstyle, class.ptr(), caption.ptr(), style, 
      this.loc.left, this.loc.top, this.loc.width, this.loc.height, ?( this.pOwner && this.pOwner != &App, this.pOwner->vCtrl.hwnd, 0), 0, GetModuleHandle( 0 ), &this )
}

method vCtrl.CreateWin( ustr class, uint exstyle, uint style )
{
   .CreateWin( class, exstyle, style, "".ustr() )
}

func vCtrl getctrl( uint hwnd )
{  
   uint ctrl = GetWindowLong( hwnd, $GWL_USERDATA )
   while !ctrl && hwnd
   {
      hwnd = GetParent( hwnd )
      ctrl = GetWindowLong( hwnd, $GWL_USERDATA )
   }   
   return ctrl->vCtrl
}

method vCtrl.SetStyle( uint mask is )
{
   if this.hwnd 
   {
      uint style = GetWindowLong( this.hwnd, $GWL_STYLE )
      if is : style |= mask
      else : style &= ~mask
      SetWindowLong( this.hwnd, $GWL_STYLE, style )
      SetWindowPos( this.hwnd, 0, 0, 0, 0, 0,  
                        $SWP_NOACTIVATE | $SWP_NOZORDER | $SWP_NOMOVE | $SWP_NOSIZE )                     
      .Invalidate()
   }   
}
method uint vCtrl.GetStyle( uint mask )
{
   return ?(GetWindowLong( this.hwnd, $GWL_STYLE ) & mask == mask, 1,0)
}


method uint vCtrl.WinMsg( uint message )
{  
   return SendMessage( this.hwnd, message, 0, 0 )
}

method uint vCtrl.WinMsg( uint message wpar )
{
   return SendMessage( this.hwnd, message, wpar, 0 )
}

method uint vCtrl.WinMsg( uint message wpar lpar )
{
   return SendMessage( this.hwnd, message, wpar, lpar )
}

method vCtrl.ChangeStyle( uint addstyle remstyle )
{
   STYLESTRUCT stls
   uint style = GetWindowLong( this.hwnd, $GWL_STYLE )
   stls.styleOld = style
   style &= ~remstyle
   style |= addstyle
   stls.styleNew = style   
   SetWindowLong( this.hwnd, $GWL_STYLE, style )
   
   this.WinMsg( 0x7d, $GWL_STYLE, &stls)//$WM_STYLECHANGED )
   
}

/*method vCtrl.ReCreateWin()
{
   .Virtual( $mDestroyWin )   
   .Virtual( $mCreateWin )
   if .pOwner  
   {
      SetWindowLong( .hwnd, $GWL_STYLE, GetWindowLong( .hwnd, $GWL_STYLE ) | $WS_CHILD )     	   
      SetParent( .hwnd, .pOwner->vCtrl.hwnd )
      this.TabOrder = this.TabOrder
   }
}*/



/*------------------------------------------------------------------------------
   Propirties
*/
/*
property int vCtrl.Left
{ 
   //if this.Owner : return this.loc.left + this.Owner->vCtrl.clloc.left
   return this.loc.left
}

property vCtrl.Left( int val )
{  
   //if val != this.loc.left
   {      
      eventpos ep
      this.loc.left = val
      ep.loc = this.loc
      ep.loc.left = val
      ep.move = 1
      ep.code = $e_poschanging      
      .Virtual( $mPosChanging, ep )    
   } 
}

property int vCtrl.Top
{
   //if this.Owner : return this.loc.top + this.Owner->vCtrl.clloc.top
   return this.loc.top
}

property vCtrl.Top( int val )
{   
   //if val != this.loc.top
   {
      eventpos ep
      this.loc.top = val
      ep.loc = this.loc
      ep.loc.top = val
      ep.move = 1
      ep.code = $e_poschanging
      .Virtual( $mPosChanging, ep )
   }
}

property int vCtrl.Width
{
   return this.loc.width
}

property vCtrl.Width( int val )
{
   if val < 0 : val = 0   
   if val != this.loc.width
   {   
      eventpos ep      
      ep.loc = this.loc
      ep.loc.width = val
      ep.move = 1
      ep.code = $e_poschanging         
      .Virtual( $mPosChanging, ep )    
   }
}

property int vCtrl.Height
{
   return this.loc.height
}


property vCtrl.Height( int val )
{
   if val < 0 : val = 0
   if val != this.loc.height
   {
      
      eventpos ep
      ep.loc = this.loc
      ep.loc.height = val
      ep.move = 1
      ep.code = $e_poschanging      
      .Virtual( $mPosChanging, ep )       
   } 
}
*/
property int vCtrl.Right
{
   return this.pRight
}

property vCtrl.Right( int val )
{   
   if val != this.pRight 
   {
      this.pRight = val
      if this.pAlign & ( $alhRight | $alhLeftRight )
      {
         eventpos ep      
         ep.loc = this.loc      
         ep.move = 1
         ep.code = $e_poschanging
         .Virtual( $mPosChanging, ep )
      }
   }   
}

property int vCtrl.Bottom
{
   return this.pBottom
}

property vCtrl.Bottom( int val )
{   
   if val != this.pBottom 
   {
      this.pBottom = val
      if this.pAlign & ( $alvBottom | $alvTopBottom )
      {  
         eventpos ep      
         ep.loc = this.loc      
         ep.move = 1
         ep.code = $e_poschanging         
         .Virtual( $mPosChanging, ep )
      }      
   }   
}
method vCtrl.iCheckMinMax()
{
   if .pMinWidth || .pMaxWidth || .pMinHeight || .pMaxHeight
   {
      .fMinMax = 1
   }
   else : .fMinMax = 0
}

property uint vCtrl.MinWidth()
{
   return .pMinWidth
}

property vCtrl.MinWidth( uint val )
{
   .pMinWidth = val
   .iCheckMinMax()
}

property uint vCtrl.MaxWidth()
{
   return .pMaxWidth
}

property vCtrl.MaxWidth( uint val )
{
   .pMaxWidth = val
   .iCheckMinMax()
}

property uint vCtrl.MinHeight()
{
   return .pMinHeight
}

property vCtrl.MinHeight( uint val )
{
   .pMinHeight = val
   .iCheckMinMax()
}

property uint vCtrl.MaxHeight()
{
   return .pMaxHeight
}

property vCtrl.MaxHeight( uint val )
{
   .pMaxHeight = val
   .iCheckMinMax()
}
/*
property vCtrl.Visible( uint val )
{   
   if val != this.pVisible
   {   
      this.pVisible = val 
      if !this.p_designing
      {     
         .Virtual( $mUpdateVisible )                  
      }
   }
}

property uint vCtrl.Visible
{
   return this.pVisible
}

property vCtrl.Enabled( uint val )
{
   if val != this.pEnabled
   {
      .Virtual( $mSetEnabled, val )           
   }
}

property uint vCtrl.Enabled
{
   return this.pEnabled
}
*/
property uint vCtrl.TabStop
{
   return this.pTabStop
}

property vCtrl.TabStop( uint val )
{
   if val != this.pTabStop
   {
      this.pTabStop = val
   }
}


property uint vCtrl.TabOrder
{
   //return this.Index//.cidx
   return this.pIndex//.cidx
}

property vCtrl.TabOrder( uint newidx )
{
   this.CompIndex = newidx
/*   this.Index = newidx
   uint prevhwnd      
   if newidx > 0 : prevhwnd = ctrls[newidx-1]->vCtrl.hwnd
   else : prevhwnd = 1
   SetWindowPos( this.hwnd, prevhwnd, 0, 0, 0, 0, $SWP_NOACTIVATE | $SWP_NOSIZE | $SWP_NOMOVE )
*/
 /*  if this.pOwner && this.pOwner->vComp.TypeIs( vCtrl )
   {  
      uint ctrls as this.pOwner->vCtrl.Comps//ctrls
      uint oldidx, i      
      uint prevhwnd      
      newidx = min( max( -0, int( newidx )), *ctrls - 1 )          
      if newidx != this.pIndex//cidx
      {  
         oldidx = this.pIndex//cidx
         if newidx > oldidx
         {            
            fornum i = oldidx + 1, newidx + 1 
            {
               ctrls[i]->vCtrl.pIndex--//cidx--
               ctrls[i-1] = ctrls[i]
            }            
         }
         else
         {            
            for i = oldidx - 1, int(i) >= newidx, i--
            {
               ctrls[i]->vCtrl.pIndex++//cidx++
               ctrls[i+1] = ctrls[i]
            }
         }       
         ctrls[newidx] = &this
         this.pIndex = newidx//cidx = newidx         
         //if newidx < .pCtrls-1 : prevhwnd = ctrls[newidx+1]->vCtrl.hwnd
         if newidx > 0 : prevhwnd = ctrls[newidx-1]->vCtrl.hwnd
         else : prevhwnd = 1
         SetWindowPos( this.hwnd, prevhwnd, 0, 0, 0, 0, $SWP_NOACTIVATE | $SWP_NOSIZE | $SWP_NOMOVE )
      }
   }*/
}


property uint vCtrl.VertAlign
{
   return this.pAlign & $ALV_MASK
}


property vCtrl.VertAlign( uint flg )
{
   flg &= $ALV_MASK   
   
   this.pAlign = this.pAlign & $ALH_MASK | flg      
   if flg & ( $alvBottom | $alvTopBottom )
   {
      if this.p_designing && this.pOwner && this.pOwner != &App 
      {      
         this.pBottom = this.Owner->vCtrl.clloc.height - this.loc.top - this.loc.height
         
      } 
   }
   eventpos evp
   evp.code = $e_poschanging
   evp.loc = this.loc
   evp.move = 1
   .Virtual( $mPosChanging, evp )
}


property uint vCtrl.HorzAlign
{
   return this.pAlign & $ALH_MASK
}

property vCtrl.HorzAlign( uint flg )
{
   flg &= $ALH_MASK
   
   this.pAlign = this.pAlign & $ALV_MASK | flg   
   if flg & ( $alhRight | $alhLeftRight )
   {
      if this.p_designing && this.pOwner && this.pOwner != &App 
      {
         this.pRight = this.Owner->vCtrl.clloc.width - this.loc.left - this.loc.width
      } 
   }   
   eventpos evp
   evp.code = $e_poschanging
   evp.loc = this.loc
   evp.move = 1

   .Virtual( $mPosChanging, evp ) 
}


/* Свойство str vCtrl.Font - Get Set
Усотанавливает или получает псевдоним( настройки шрифта контрола )
*/
property str vCtrl.Font <result>
{
   result = this.pFont
}

property vCtrl.Font( str val )
{   
   if val != this.pFont
   {  
      //App.FntM.Default()
      this.pFont = val     
      .Virtual( $mFontChanged )
   }
}

property str vCtrl.Style <result>
{
   result = this.pStyle
}

property vCtrl.Style( str val )
{   
   if val != this.pStyle
   {  
      //App.FntM.Default()
      this.pStyle = val     
      .Virtual( $mFontChanged )
   }
}

/*------------------------------------------------------------------------------
   Windows Mesages Methods
*/


method uint vCtrl.wmmoving_sizing <alias=vCtrl_wmmoving_sizing>( winmsg wmsg )
{
   uint lpar = wmsg.lpar
   eventpos ev_p
   ev_p.loc.left = lpar->RECT.left 
   ev_p.loc.top = lpar->RECT.top
   ev_p.loc.width = lpar->RECT.right - lpar->RECT.left
   ev_p.loc.height = lpar->RECT.bottom - lpar->RECT.top
   ev_p.code = $e_poschanging
   //this.event( ev_p )   
   this.Virtual( $mPosChanging, ev_p )
   lpar->RECT.left = ev_p.loc.left 
   lpar->RECT.top = ev_p.loc.top
   lpar->RECT.right = ev_p.loc.left + ev_p.loc.width  
   lpar->RECT.bottom = ev_p.loc.top +  ev_p.loc.height
   wmsg.flags = 1   
   return 1
}          

method uint vCtrl.wmfocus <alias=vCtrl_wmfocus> ( winmsg wmsg )
{
   evparValUint eu
   eu.code = $e_focus
   eu.val = ( wmsg.msg == $WM_SETFOCUS )   
   SendMessage (this.hwnd, 0x0128/*$WM_UPDATEUISTATE*/, (0x01/*$UISF_HIDEFOCUS*/<<16)|2/*$UIS_CLEAR*/, 0);
   this.Virtual( $mFocus, eu )
   /*if this.Virtual( $mFocus, eu )
   {
      wmsg.flags = 1
      return 1
   }*/              
   return 0            
}

method uint vCtrl.wmkey <alias=vCtrl_wmkey> ( winmsg wmsg )
{
   subfunc uint key( uint evktype )
   {         
      evparKey ek             
      ek.evktype = evktype               
      ek.code = $e_key          
      ek.key = wmsg.wpar                     
      if GetKeyState( $VK_MENU ) & 0x8000 : ek.mstate |= $mstAlt
      if GetKeyState( $VK_CONTROL ) & 0x8000 : ek.mstate |= $mstCtrl
      if GetKeyState( $VK_SHIFT ) & 0x8000 : ek.mstate |= $mstShift
      if GetKeyState( $VK_RWIN ) & 0x8000 || 
         GetKeyState( $VK_LWIN ) & 0x8000 : ek.mstate |= $mstWin
      wmsg.flags = this.Virtual( $mKey, ek )                   
      return 0
   }  
   
   switch wmsg.msg
   {
      case $WM_KEYDOWN, $WM_SYSKEYDOWN
      {               
         return key( $evkDown )                                              
      }
      case $WM_KEYUP, $WM_SYSKEYUP
      {
         return key( $evkUp )               
      }            
      case $WM_CHAR, $WM_SYSCHAR
      {
         return key( $evkPress )
      }
      default : return 0
   }   
}


method uint vCtrl.mClColor <alias=vCtrl_mClColor>( winmsg wmsg )
{
   uint hbrush
   if .aStyle 
   {
      hbrush = DefWindowProc( wmsg.hwnd, wmsg.msg, wmsg.wpar, wmsg.lpar )
      SetBkMode( wmsg.wpar, $TRANSPARENT )
      if .aStyle->Style.fTextColor 
      {
         SetTextColor( wmsg.wpar, .aStyle->Style.pTextColor  )
      }
      wmsg.flags = 1
      if .aStyle->Style.hBrush
      {      
         hbrush = .aStyle->Style.hBrush//GetStockObject(0)                  
      }      
      //else : hbrush = GetStockObject(5) 
      //SelectObject( wmsg.wpar, hbrush )      
      return hbrush//GetStockObject(18)
   }   
   
   if isThemed  && .flgXPStyle
   {      
      uint hfont = GetCurrentObject( wmsg.wpar, $OBJ_FONT )
      SetBkMode( wmsg.wpar, $TRANSPARENT )
      pDrawThemeParentBackground->stdcall( /*getctrl(wmsg.lpar)*/.hwnd, wmsg.wpar, 0 )
      wmsg.flags = 1
      SelectObject( wmsg.wpar, hfont )
      if !hbrush: hbrush = GetStockObject(5)       
   }   
   //if wmsg.flags : return hbrush
   return hbrush
}

method uint vCtrl.wmclcolorbtn <alias=vCtrl_wmclcolorbtn>(winmsg wmsg )
{
   uint ctrl as getctrl(wmsg.lpar)
   if &ctrl :  return ctrl.Virtual( $mClColor, wmsg )
   //return 5
   return 0
/*   if isThemed && .flgXPStyle
   { 
      uint hfont = GetCurrentObject( wmsg.wpar, $OBJ_FONT )
      SetBkMode( wmsg.wpar, $TRANSPARENT )
      pDrawThemeParentBackground->stdcall( getctrl(wmsg.lpar).hwnd, wmsg.wpar, 0 )
      wmsg.flags = 1
      SelectObject( wmsg.wpar, hfont )
      return GetStockObject(5)
   }
   return 0*/
}

method uint vCtrl.wmerasebkgnd <alias=vCtrl_wmerasebkgnd>( winmsg wmsg )
{
   if isThemed && .flgXPStyle
   {
      RECT r      
      r.right = this.Width//.clloc.width      
      r.bottom = this.Height//.clloc.height
      pDrawThemeParentBackground->stdcall( this.hwnd, wmsg.wpar, &r )
      wmsg.flags = 1
      return 1
   }
   /*uint hdc
   	PAINTSTRUCT lp   
   //   hdc = BeginPaint( this.hwnd, lp )
      RECT r
      r.left = 0
      r.top = 0
      r.right = this.loc.width
      r.bottom = this.loc.height   
      FillRect( wmsg.wpar, r, $COLOR_BTNFACE + 1 ) -*/                      
   //	EndPaint( this.hwnd, lp )
 //     InvalidateRect( this.hwnd, 0->RECT, 0 )  
   return 0   
}
/*------------------------------------------------------------------------------
   Virtual Methods
*/


method vCtrl.mDestroyWin <alias=vCtrl_mDestroyWin> ()
{
   if this.hwnd 
   {
      DestroyWindow( this.hwnd )   
      this.hwnd = 0
   }   
}


method vCtrl.mPosChanging <alias=vCtrl_mPosChanging>( evparEvent ev )
{
if .flgNoPosChanging : return

   uint evp as ev->eventpos

   this.ownerresize( evp.loc )
             
   if evp.move 
   {   
ifdef $DESIGNING {
   uint owner
   owner as vCtrl
   if this.p_designing && evp.loc != this.loc
   {   
      owner as this
      do 
      {
         owner as ?( owner.pOwner && owner.pOwner != &App, owner.pOwner->vComp, 0->vComp ) 
      }
      while owner && owner.p_designing             
      if owner : owner as ?( owner.pOwner && owner.pOwner != &App, owner.pOwner->vComp, 0->vComp )
      //if owner : owner as owner.Owner
      if owner : owner.Virtual( $mDesChanging, &this )        
   }     
}
      //.flgPosChanging = 1 
      this.onposchanging.run( evp )
      //SetWindowPos( this.hwnd, 0, evp.loc.left, evp.loc.top, evp.loc.width, evp.loc.height, $SWP_NOACTIVATE | $SWP_NOZORDER /*| $SWP_NOCOPYBITS*/ )
      if this.hwnd : MoveWindow( this.hwnd, evp.loc.left, evp.loc.top, evp.loc.width, evp.loc.height, 1 )
      else : this.loc = evp.loc

      //SetWindowPos( this.hwnd, 0, evp.loc.left, evp.loc.top, evp.loc.width, evp.loc.height, $SWP_NOACTIVATE | $SWP_NOZORDER /*| $SWP_NOCOPYBITS*/ )       
      //.flgPosChanging = 0
      /*UpdateWindow( 0 )
      if this.Owner
      { 
      UpdateWindow( this.Owner->vCtrl.hwnd )
      }      */
      //RedrawWindow( this.hwnd, 0->RECT, 0, 0x507)
/*ifdef $DESIGNING {
   if owner : owner.Virtual( $mDesChanged, &this )
} */     
   }  

}

method vCtrl.mPosChanged <alias=vCtrl_mPosChanged>( evparEvent ev )
{     
   uint evu as ev->evparValUint
   uint i   
   if evu.val
   {   
      //foreach chctrl, this.ctrls
      fornum i = 0, .pCtrls               
      {                
         uint chctrl as this.Comps[ i ]->vCtrl//vCtrl         
         eventpos ep                  
         ep.loc = chctrl.loc
         ep.move = 1
         chctrl.Virtual( $mPosChanging, ep )                  
      }   
   }
   if this.pOwner && this.pOwner != &App
   {      
      this.Owner->vCtrl.Virtual( $mChildPosChanged, this )
   }
   this.OnPosChanged.run( ev )
   if .flgRePaint: .Invalidate()
   
   ifdef $DESIGNING {
   uint owner
   owner as vCtrl
   if this.p_designing 
   {   
      owner as this
      do 
      {
         owner as owner as ?( owner.pOwner && owner.pOwner != &App, owner.pOwner->vComp, 0->vComp )
      }
      while owner && owner.p_designing             
      if owner : owner as ?( owner.pOwner && owner.pOwner != &App, owner.pOwner->vComp, 0->vComp )
      //if owner : owner as owner.Owner
      if owner : owner.Virtual( $mDesChanged, &this )  
   }     
}
}




method vCtrl.mRemove <alias=vCtrl_mRemove>( vComp remcomp )
{
   if remcomp.TypeIs( vVirtCtrl )
   {
      uint ctrl as remcomp->vVirtCtrl       
      uint ar as this.Comps//ctrls
      uint i
      //this.childtaborder( ctrl, 0, $TAB_REMOVE )      
      if ar[ctrl.pIndex] == &ctrl//cidx] == &ctrl
      {
      
         ar.del(ctrl.pIndex,1)//cidx,1)
               
         fornum i = ctrl.pIndex, *ar//cidx, *ar 
         {
            //ar[i]->vCtrl.cidx--//cidx
            ar[i]->vComp.pIndex--
         }
        
         this.pCtrls--
      }      
      remcomp.Virtual( $mSetOwner, 0 )      
   }
   else
   {
      this->vComp.mRemove( remcomp )
   }
}



method vCtrl.mSetCaption <alias=vCtrl_mSetCaption>( ustr caption )
{  
   SetWindowText( this.hwnd, caption.ptr() )   
}


method vCtrl.mFontChanged <alias=vCtrl_mFontChanged>( )
{
   /*uint hFont as App.FntM.GetFont( .pFont )
   if &hFont
   {  
      .hFont = hFont->Font.hFont
   }
   else
   {
      .hFont = GetStockObject( $DEFAULT_GUI_FONT )  
   }
   this.WinMsg( $WM_SETFONT, .hFont )
   */   
   .aStyle = &App.StyleM.GetStyle( .pStyle )  
   if .aStyle && .aStyle->Style.hFont
   {  
      this.WinMsg( $WM_SETFONT, .aStyle->Style.hFont )
   }
   .Invalidate()
}

method vCtrl.mSetDefFont <alias=vCtrl_mSetDefFont>( )
{
   uint aStyle = &App.StyleM.GetStyle( .pStyle )  
   if !(aStyle && aStyle->Style.hFont )
   {  
      this.WinMsg( $WM_SETFONT, App.pDefFont )      
      .Virtual( $mLangChanged )
      .Invalidate()
   }
   uint i
   fornum i = 0, .pCtrls               
   {                
      this.Comps[ i ]->vCtrl.Virtual( $mSetDefFont )
   }   
}   

method vVirtCtrl.mSetIndex <alias=vVirtCtrl_mSetIndex>( uint newidx )
{
   if this.pOwner && this.pOwner->vComp.TypeIs( vCtrl )
   {       
      this->vComp.mSetIndex( min( newidx, this.pOwner->vCtrl.pCtrls - 1 ) ) 
   }
}

method vCtrl.mSetIndex <alias=vCtrl_mSetIndex>( uint newidx )
{
   if this.pOwner && this.pOwner->vComp.TypeIs( vCtrl )
   {
      this->vVirtCtrl.mSetIndex( newidx )
      uint prevhwnd
      if .pIndex > 0 : prevhwnd = .pOwner->vCtrl.Comps[.pIndex-1]->vCtrl.hwnd
      else : prevhwnd = 1
      SetWindowPos( this.hwnd, prevhwnd, 0, 0, 0, 0, $SWP_NOACTIVATE | $SWP_NOSIZE | $SWP_NOMOVE )
   }
}

/*------------------------------------------------------------------------------
   Registration
*/


method vCtrl vCtrl.init()
{
   this.pTypeId = vCtrl   
   
   //this.pVisible = 1
   //this.pEnabled = 1 
   this.loc.width = 20  
   this.loc.height = 20
   this.pAlign = $alvTop | $alhLeft
   return this
}

/*method vCtrl.getevents( uint typeid, compMan cm )
{   

}
*/
/*method vCtrl.v_focus <alias=vCtrl_focus>( eventuint ev )
{
   if ev.val : this.form->vform.curtab = &this
      this.onfocus.run( ev )
}
*/


func uint myproc( uint hwnd, uint msg, uint wpar, uint lpar )
{
   //print( "h \(hwnd) \(msg) \(wpar) \(lpar) \n" )
   uint ctrl = GetWindowLong( hwnd, $GWL_USERDATA )   
   if ctrl
   {     
      uint res
      if ctrl->vCtrl.pTypeDef 
      {    
         //uint msgtbl = min( msg, $WM_USER )
         winmsg mymsg
         uint addr //= (&ctrl->vCtrl.curproctbl->proctbl.tbl[ msg << 2 ])->uint
         if msg < $WM_USER
         {
            addr = (ctrl->vCtrl.pTypeDef->tTypeDef.ProcTbl.data + ( msg << 2 ))->uint
         }
         else
         {         
            uint i
            for i = 0, i < *ctrl->vCtrl.pTypeDef->tTypeDef.ProcUserTbl, i += 2
            {            
               if ctrl->vCtrl.pTypeDef->tTypeDef.ProcUserTbl[i] == msg
               {
                  addr = ctrl->vCtrl.pTypeDef->tTypeDef.ProcUserTbl[ i + 1 ]                  
                  break
               }  
            }
         }                  
         mymsg.flags = 0      
         if addr 
         {           
            mymsg.msg = msg
            mymsg.hwnd = hwnd
            mymsg.wpar = wpar
            mymsg.lpar = lpar            
            res = addr->func( ctrl, &mymsg )
            if mymsg.flags 
            {           
               //print( "h2 \(hwnd) \(msg) \(wpar) \(lpar) \n" )     
               return res
            }
         }               
      }      
 
      if ctrl->vCtrl.prevwndproc  
      {         
         //print( "h2 \(hwnd) \(msg) \(wpar) \(lpar) \n" )
         return CallWindowProc( ctrl->vCtrl.prevwndproc, hwnd, msg, wpar, lpar )         
      }
      
/*      if msg == $WM_DESTROY {
         PostQuitMessage( 0 )
         return 1
      }*/
      
      
   }
   /*else   
   {
      print( "zero------------1 \(msg) \(wpar) \(lpar)\n" )
      uint x = DefWindowProc( hwnd, msg, wpar, lpar );
      print( "zero------------2\n" )
      return x  
   }*/
   //print( "h2 \(hwnd) \(msg) \(wpar) \(lpar) \n" )
   return DefWindowProc( hwnd, msg, wpar, lpar );   
}
