
/******************************************************************************
*
* Copyright (C) 2004-2007, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: viseditor.proplist 30.07.07 0.0.A.
*
* Author: Alexander Krivonogov ( gentee )
*
******************************************************************************/

/*
define {
   PI_SIMPLE = 0x000
   PI_UPDOWN = 0x001
   PI_DLG    = 0x002
   PI_SEL    = 0x100
   
   PI_DEFVAL = 0x1000000
   PI_LIST   = 0x1000
}
*/
type evparProp <inherit=evparEvent>
{
   ustr name
   ustr value
}

type evProp <inherit=evEvent>
{
}

method evProp evProp.init
{
   this.eventtypeid = evparProp
   return this
}


type vSDraw <inherit = vCtrl>
{
   ustr    pCaption
   uint    off 
}


method uint vSDraw.wmpaint <alias=vSDraw_wmpaint>( winmsg wmsg )
{
   uint         hdc
   PAINTSTRUCT  ps
   RECT         rect      

   hdc = BeginPaint( this.hwnd, ps )
   rect.left = this.clloc.left
   rect.right = this.clloc.width
   rect.top = this.clloc.top
   rect.bottom = this.clloc.height
   DrawEdge( hdc,    
               rect,
               $BDR_SUNKENOUTER,     
               $BF_LEFT | $BF_RIGHT | $BF_TOP | $BF_BOTTOM  )         
   SelectObject( hdc, GetStockObject( $DEFAULT_GUI_FONT ) )         
   SetBkMode( hdc, $TRANSPARENT )
   SetTextColor( hdc, GetSysColor( $COLOR_HIGHLIGHT ) )
   rect.left +=5
   rect.top ++
   DrawText( hdc, this.pCaption.ptr(), -1, rect, $DT_LEFT | $DT_SINGLELINE  )   
   MoveToEx( hdc, this.off, 0, 0->POINT )
   LineTo( hdc, this.off, this.Height )
   EndPaint( this.hwnd, ps )
   return 0
}



method vSDraw vSDraw.mCreateWin <alias=vSDraw_mCreateWin>()
{
   this.CreateWin( "GVForm".ustr(), 0, 
$WS_CHILD | $WS_VISIBLE | $WS_CLIPCHILDREN | $WS_CLIPSIBLINGS | $WS_OVERLAPPED)
   this.prevwndproc = -1
   this->vCtrl.mCreateWin()
   //this.prevwndproc = 0
   this.WinMsg( $WM_SETFONT, GetStockObject( $DEFAULT_GUI_FONT ) )                     
   return this
}

property str vSDraw.Caption <result>
{
   result = this.pCaption
}

property vSDraw.Caption( ustr val )
{
   this.pCaption = val
   InvalidateRect( this.hwnd, 0->RECT, 1 ) 
}

type vPropList <inherit=vCtrl>
{
   uint ncount    //Количество строк
   uint nfirst    //Первая строка
   uint nviscount //Количество видимых строк
   uint nheight   //Высота строки
   uint ncur      //Номер текущей строки
   uint nleftwidth//Ширина левой части
   vSDraw curprop  
   vEdit  ed   
   vBtnSys bs
   uint sysfont
   uint pen
   arr ar of PropItem
   evProp onPropSet
   evEvent ongetlist   
   evEvent ondblclick
   vComboBox cb
   uint prevcap
   ustr lastprop
   //arr 
}

define {
   SETFIRST_ABS = 0
   SETFIRST_OFF = 1
   SETFIRST_PAGE = 2
}

method vPropList.calccur( )
{
   this.curprop.Top = ( this.ncur - this.nfirst ) * this.nheight 
}

method vPropList.setfirst( uint flag, int pos )
{
   int newpos = this.nfirst
   switch flag {   
      case $SETFIRST_ABS {
         if pos == -1 {
            newpos = this.ncount
         }         
         else {
            newpos = pos
         }           
      }
      case $SETFIRST_OFF {
         newpos += pos
      }
      case $SETFIRST_PAGE {
         newpos += this.nviscount * pos
      }
   }
   newpos = min( ?(newpos < 0, 0, newpos ), this.ncount - this.nviscount )    
   if newpos != this.nfirst
   {
      this.nfirst = newpos      
      SetScrollPos( this.hwnd, $SB_VERT, this.nfirst, 1 )
      InvalidateRect( this.hwnd, 0->RECT, 1 )
      this.calccur()
   } 
}

method vPropList.propset()
{
   evparProp ep
   ep.name = this.curprop.Caption
   ep.value = this.ed.Text   
   this.onPropSet.run( ep )
}

method vPropList.setcur( uint val, uint flgstate )
{
   if val >= this.ncount : val = -1
   if val != this.ncur && val != -1
   {
      if this.ed.Changed 
      {      
         this.ed.Changed = 0
         this.propset()
      }
      
      this.ncur = val      
      this.curprop.Visible = 0      
      this.calccur()      
      this.curprop.Caption = this.ar[this.ncur].Name//"temp \( this.ncur)"      
      this.ed.Text = this.ar[this.ncur].Value
      
      if this.ar[this.ncur].Flags & $PI_LIST
      {
         this.bs.Width = this.nheight
      }
      else : this.bs.Width = 0 
      this.ed.Width = this.clloc.width - this.ed.Left - this.bs.Width
      this.bs.Left = this.clloc.width - this.bs.Width            
      if flgstate 
      {
         this.lastprop = this.ar[this.ncur].Name
      }
      //SetFocus( this.ed.hwnd )
            
      this.curprop.Visible = 1
      //SendMessage( this.ed.hwnd, $EM_SETSEL, 0, -1 )
      this.ed.SelAll()
   }
   if this.ncur < this.nfirst 
   {
      this.setfirst( $SETFIRST_ABS, this.ncur )
   }
   elif this.ncur >= this.nfirst + this.nviscount
   {
      this.setfirst( $SETFIRST_ABS, this.ncur - this.nviscount + 1 )
   }
}


method vPropList.calcviscount()
{
   if !this.nheight : return
   this.nviscount = min( this.clloc.height / this.nheight, this.ncount )
   
   
//   EnableScrollBar( this.hwnd, $SB_VERT, $ESB_ENABLE_BOTH)   
   if this.nviscount == this.ncount
   {  
      //st.fMask = $SIF_RANGE | $SIF_PAGE;
      //st.nMax = 0;	
		//st.nPage = 0;
      //ShowScrollBar( this.hwnd, $SB_VERT, 0 )
      SCROLLINFO si
      //ShowScrollBar( this.hwnd, $SB_VERT, 1 )
      si.cbSize = sizeof( SCROLLINFO )
      si.fMask = $SIF_RANGE | $SIF_PAGE | $SIF_POS
      si.nMin = 0
      si.nMax = 0//this.ncount-1// - this.nviscount	
		si.nPage = 0//this.nviscount
      si.nPos = 0;
      SetScrollInfo( this.hwnd, $SB_VERT, si, 1 )  
   }
   else
   {  
      
      SCROLLINFO si
      //ShowScrollBar( this.hwnd, $SB_VERT, 1 )
      si.cbSize = sizeof( SCROLLINFO )
      si.fMask = $SIF_RANGE | $SIF_PAGE | $SIF_POS
      si.nMin = 0
      si.nMax = this.ncount-1// - this.nviscount	
		si.nPage = this.nviscount
      si.nPos = this.nfirst//0;
      SetScrollInfo( this.hwnd, $SB_VERT, si, 1 )   
      
   }   
   this.setfirst( $SETFIRST_ABS, this.nfirst )
   
}

method vPropList.setcount( uint new )
{
   this.ncount = new
   this.nfirst = 0
   this.calcviscount()
}


/*method uint vPropList.findprop( str name )
{
   fornum i = 0, *this.ar
   {
      if this.ar[i].name == name
      {  
         return i
      }
   }
}*/

method vPropList.setar( arr ar of PropItem )
{
   uint i, ncur
   this.ar.clear()
   this.ar.expand( *ar )
   
   this.ncur = -1      
   fornum i=0, *ar
   {
      //print( "\(ar[i].name) \(this.lastprop) \(ar[i].name >= this.lastprop)\n" )
      if ar[i].Name == this.lastprop : ncur = i  
      this.ar[i].Name = ar[i].Name
      this.ar[i].Value = ar[i].Value
      this.ar[i].Flags = ar[i].Flags
   }
   
   this.ed.Changed = 0
   //this.nfirst = 0
   this.ncount = *ar   
   this.calcviscount()
   if this.ncount 
   {      
      this.setcur( ncur, 0 )
      this.curprop.Visible = 1   
   }
   else
   {  
      this.curprop.Visible = 0
   }
   InvalidateRect( this.hwnd, 0->RECT, 1 )
} 

method uint vPropList.edkey <alias=proplist_edkey>( /*vComp sender,*/ evparKey ek )
{  
   if ek.evktype == $evkDown
   {      
      switch ek.key 
      {
         case 0x0d 
         {         
            if ek.mstate & $mstCtrl :this.ondblclick.run() 
            else : this.propset()
            return 0
         }
         case 0x1B
         {
            this.ed.Text = this.ar[this.ncur].Value
            SendMessage( this.ed.hwnd, $EM_SETSEL, 0, -1 )
            return 0
         }
         case 0x26//Вверх
         {
            this.setcur( this.ncur - 1, 1 )
            return 0
         }
         case 0x28//Вниз
         {            
            if ek.mstate & $mstAlt
            {
               this.ongetlist.run()
//               this.pl.start()
            }
            else : this.setcur( this.ncur + 1, 1 )
            return 0
         }        
      }
   }   
   return 0
}

method uint vPropList.edmouse <alias=proplist_edmouse>( /*vComp sender,*/ evparMouse evm )
{   
   if evm.evmtype == $evmLDbl
   {
      this.ondblclick.run()
   } 
   return 0
}

method uint vPropList.edfocus <alias=proplist_edfocus>( evparValUint eu )
{  
   if !eu.val && this.ed.Changed: this.propset()
   return 1
}


method uint vPropList.bsclick <alias=proplist_bsclick>( evparEvent ev )
{
   this.ongetlist.run()
   this.cb.DropDown()      
   return 0
}

method uint vPropList.cbcloseup<alias=proplist_cbcloseup>( evparEvent ev )
{
   //print( "CLOSE\n" )
   this.bs.Push = 0
   return 0
}

method uint vPropList.plselect <alias=proplist_plselect>( evparValUstr ev )
{
   evparProp ep
   this.ed.Text = ev.val   
   ep.name = this.curprop.Caption
   ep.value = this.ed.Text   
   this.onPropSet.run( ep )
   return 0
}


method vPropList vPropList.mCreateWin <alias=vPropList_mCreateWin>()
{

//   this->vSDraw.mCreateWin()
   .CreateWin( "GVForm".ustr(), /*$WS_EX_STATICEDGE*/0,
$WS_CHILD | $WS_VISIBLE | $WS_CLIPCHILDREN | $WS_CLIPSIBLINGS | $WS_OVERLAPPED )
//   setxpstyle( this.hwnd )   
   this.prevwndproc = -1
   this->vCtrl.mCreateWin()
   //this.prevwndproc = 0

   this.WinMsg( $WM_SETFONT, GetStockObject( $DEFAULT_GUI_FONT ) )
   
   this.sysfont = GetStockObject( $DEFAULT_GUI_FONT )
   this.pen = CreatePen( $PS_SOLID, 1, GetSysColor($COLOR_INACTIVECAPTION))//$COLOR_WINDOWFRAME) )
   uint hdc = GetDC( this.hwnd )
   SelectObject( hdc, this.sysfont )
   TEXTMETRIC tm
   GetTextMetrics( hdc, tm )    
   ReleaseDC( this.hwnd, hdc )
                                                                       
   this.nheight = tm.tmHeight + 2
   this.setcount( 0 )   
   this.nleftwidth = 90      
   this.ncur = -1
   
//   this->vPanel.Border = $brdLowered
                   
                              
   this.curprop.Owner = this    
   this.curprop.Top = 0
   this.curprop.Width =100
   this.curprop.Height = this.nheight + 1
   this.curprop.off = this.nleftwidth
   
   
   this.curprop.VertAlign = $alvTop
   this.curprop.HorzAlign = $alhClient
   this.curprop.Name = "x"
   
   this.ed.Owner = this.curprop
   this.ed.Left = this.nleftwidth + 1
   this.ed.Top = 1//0
   this.ed.Height = this.nheight          
   this.ed.VertAlign = $alvTop              
   this.ed.HorzAlign = $alhLeft
   this.ed.Border = 0  
 
   this.ed.OnKey.Set( this, proplist_edkey )
   this.ed.OnFocus.Set( this, proplist_edfocus )
   this.ed.OnMouse.Set( this, proplist_edmouse )
   this.curprop.OnMouse.Set( this, proplist_edmouse )   
   
   this.bs.Owner = this.curprop
   this.bs.VertAlign = $alvTop
   this.bs.HorzAlign = $alhLeft
   this.bs.Width = this.nheight - 1
   this.bs.Height = this.nheight - 1
   
   this.bs.Top = 1 
   this.bs.onclick.Set( this, proplist_bsclick )
//?   this.bs.onmouse.set( this, proplist_bsmouse )
      
   this.cb.Owner = this.curprop
   //this.cb.Height = 10
   this.cb.Sorted = 1   
   this.cb.CBStyle = $cbsDropDownList
   this.cb.Left = this.ed.Left - 1
   this.cb.Top = this.curprop.Height - this.cb.Height
   this.cb.OnSelect.Set( this, proplist_plselect )
   this.cb.oncloseup.Set( this, proplist_cbcloseup )   
   this.cb.Visible = 0
   return this
}

method vPropList.mPosChanged <alias=vPropList_mPosChanged> (evparEvent ev )
{   
   this->vCtrl.mPosChanged( ev )     
   this.ed.Width = this.clloc.width - this.ed.Left - this.bs.Width
   this.cb.Width = this.clloc.width - this.cb.Left
   this.bs.Left = this.clloc.width - this.bs.Width
   this.calcviscount()
}

method uint vPropList.wmpaint <alias=vPropList_wmpaint>(winmsg wmsg)
{
   uint         hdc
   PAINTSTRUCT  ps
   RECT         rect
   str          temp
   
   hdc = BeginPaint( this.hwnd, ps )
    
   SetBkMode( hdc, $TRANSPARENT )
   uint i
   SelectObject( hdc, this.sysfont )   
   SelectObject( hdc, this.pen )
       
   rect.top = 0             
   SetTextColor( hdc, GetSysColor( $COLOR_WINDOWTEXT ) )     
   fornum i=0, this.nviscount
   {  
      rect.right = this.nleftwidth
      rect.bottom = rect.top + this.nheight 
      rect.top++ 
      rect.left = 5                
      DrawText( hdc, this.ar[i+ this.nfirst].Name.ptr(), -1, rect, $DT_LEFT | $DT_SINGLELINE )                  
      rect.left = this.nleftwidth + 2      
      rect.right = this.clloc.width      
      rect.top++
      DrawText( hdc, this.ar[i+ this.nfirst].Value.ptr(), -1, rect, $DT_LEFT | $DT_SINGLELINE )
      rect.top--
      rect.top--
      MoveToEx( hdc, 0, rect.bottom, 0->POINT )
      LineTo( hdc, rect.right, rect.bottom )           
      rect.top += this.nheight                              
   }   
   MoveToEx( hdc, this.nleftwidth, 0, 0->POINT )
   LineTo( hdc, this.nleftwidth, this.clloc.height )
   EndPaint( this.hwnd, ps )
  
   return 0
}

method uint vPropList.wmlbuttondown <alias=vPropList_wmlbuttondown>(winmsgmouse wmsg)
{
   uint n = wmsg.y / this.nheight               
   if n < this.nviscount 
   {
      this.setcur( n + this.nfirst, 1 )  
      SetFocus( this.ed.hwnd )
   }
   return 0
}

method uint vPropList.wmmousewheel <alias=vPropList_wmmousewheel>(winmsg wmsg)
{
   if ((&wmsg->winmsgsh.wparhi)->short ) > 0 : this.setfirst( $SETFIRST_OFF, -3 )
   else : this.setfirst( $SETFIRST_OFF, 3 )   
   return 0
}

method uint vPropList.wmvscroll <alias=vPropList_wmvscroll>(winmsg wmsg)
{
   uint nScrollCode = wmsg->winmsgsh.wparlo
   uint npos = wmsg->winmsgsh.wparhi
   switch nScrollCode
   {
      case $SB_LINEUP {
         this.setfirst( $SETFIRST_OFF, -1 )                     
      }   
      case $SB_LINEDOWN {
         this.setfirst( $SETFIRST_OFF, 1 )                     
      }                    
      case $SB_PAGEUP {
         this.setfirst( $SETFIRST_PAGE, -1 )
      }                                         
      case $SB_PAGEDOWN {
         this.setfirst( $SETFIRST_PAGE, 1 )                     
      }                           
      case $SB_THUMBTRACK {
         SCROLLINFO si
         si.cbSize = sizeof( SCROLLINFO )
         si.fMask = $SIF_TRACKPOS
         GetScrollInfo( this.hwnd, $SB_VERT, si )
         this.setfirst( $SETFIRST_ABS, si.nTrackPos )                     
      } 
   }
   return 0
}


method vSDraw vSDraw.init( )
{        
   this.pTypeId = vSDraw   
   this.pCanContain = 1  
    
   return this 
}  

method vPropList vPropList.init( )
{     
//print( "vPropList.init 1\n" )
   this.pTypeId = vPropList
   this.pCanContain = 1
   //this.flgXPStyle = 1
//print( "vPropList.init 2\n" )
   return this 
}  

func init_vPropList <entry>()
{ 
   regcomp( vSDraw, "vSDraw", vCtrl, $vCtrl_last, 
      %{ %{$mCreateWin,    vSDraw_mCreateWin}//,
         //%{$mWinCmd,       vBtn_mWinCmd}
         }, 
      %{ %{$WM_PAINT, vSDraw_wmpaint }
      })                             
   
   regcomp( vPropList, "vPropList", vCtrl, $vCtrl_last,       
      %{ %{$mCreateWin,    vPropList_mCreateWin},
         %{$mPosChanged,   vPropList_mPosChanged}         
         }, 
      %{ %{$WM_PAINT, vPropList_wmpaint },  
         %{$WM_LBUTTONDOWN, vPropList_wmlbuttondown },
         %{$WM_MOUSEWHEEL, vPropList_wmmousewheel },
         %{$WM_VSCROLL, vPropList_wmvscroll }
      })    
}