/******************************************************************************
*
* Copyright (C) 2004-2007, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: vis.form 15.10.07 0.0.A.
*
* Author: Alexander Krivonogov ( gentee )
*
******************************************************************************/
/* Компонента vScrollBox, порождена от vCtrl
События
   
*/


include {
   "panel.g"   
}

type vScrollBox <inherit = vCtrl>
{  
   uint     pBorder
   uint     pAutoScroll
   uint     flgScrolling
   //uint     ptest
   uint     pHorzRange
   uint     pVertRange
   //vPanel panel
 //  onevent  onScrolled
   evQuery OnBeforeScroll
   evEvent    OnAfterScroll
}

extern {
   method vScrollBox.mChildPosChanged ( vCtrl ctrl )
   method vScrollBox.UpdateScroll()
}

/* Свойство str vPanel.AutoScroll - Get Set
Усотанавливает или получает заколовок панели
*/
/*property uint vScrollBox.test
{
   return this.ptest
}

property vScrollBox.test( uint val )
{
   if this.ptest != val
   {
      this.ptest = val
      SCROLLINFO si
      si.fMask = $SIF_POS
      si.nPos = val
      SetScrollInfo( .hwnd, $SB_HORZ, si, 1 ) 
      .UpdateScroll()          
   } 
}
*/

method vScrollBox.iSetRange()
{
   SCROLLINFO si
   si.cbSize = sizeof(SCROLLINFO)
   si.fMask = $SIF_RANGE | $SIF_PAGE 
   si.nMin = 0
   si.nMax = ?( .pHorzRange, .pHorzRange, 1 )
   si.nPage = this.clloc.width + 1              
   SetScrollInfo( .hwnd, $SB_HORZ, si, 0 )
   //SetScrollRange( .hwnd, $SB_HORZ, 0, .pHorzRange, 1 )
            
   //SCROLLINFO si   
   si.cbSize = sizeof(SCROLLINFO)
   si.fMask = $SIF_RANGE | $SIF_PAGE 
   si.nMin = 0
   si.nMax = ?( .pVertRange, .pVertRange, 1 )
   si.nPage = this.clloc.height + 1              
   SetScrollInfo( .hwnd, $SB_VERT, si, 1 )
   
   //print( "Set range3 \(.Name) \(.pHorzRange) \(.pVertRange)\n" )
}


/* Свойство str vScrollBox.HorzRange - Get Set
Ширина прокручиваемого размера
*/
property uint vScrollBox.HorzRange
{
   return .pHorzRange
}

property vScrollBox.HorzRange( uint val )
{
   if .pHorzRange != val
   {
      .pHorzRange = val 
      .iSetRange()         
      .UpdateScroll()          
   } 
}

/* Свойство str vScrollBox.VertRange - Get Set
Высота прокручиваемого размера
*/
property uint vScrollBox.VertRange
{
   return .pVertRange
}

property vScrollBox.VertRange( uint val )
{
   if .pVertRange != val
   {
      .pVertRange = val 
      .iSetRange()         
      .UpdateScroll()          
   } 
}

/* Свойство str vPanel.AutoScroll - Get Set
Усотанавливает или получает заколовок панели
*/
property uint vScrollBox.AutoScroll
{
   return this.pAutoScroll
}

property vScrollBox.AutoScroll( uint val )
{
   if this.pAutoScroll != val
   {
      this.pAutoScroll = val
      if val
      {  
         .mChildPosChanged( 0->vCtrl )
      } 
      //   ShowScrollBar( .hwnd, $SB_VERT | $SB_HORZ, 0 )           
   } 
}


/* Свойство uint Border - Get Set
Усотанавливает или определяет рамку панели
Возможны следующие варианты:
brdNone        - нет рамки,
brdLowered     - рамка вдавлена,
brdDblRaised   - рамка выпуклая,
brdDblLowered  - рамка двойная выпуклая
*/
property uint vScrollBox.Border()
{
   return this.pBorder
}

property vScrollBox.Border( uint val )
{  
   uint style
   
   if this.pBorder != val
   {
      this.pBorder = val
      style = GetWindowLong( this.hwnd, $GWL_EXSTYLE )
      style &= ~( $WS_EX_STATICEDGE | $WS_EX_WINDOWEDGE | $WS_EX_CLIENTEDGE | 
                  $WS_EX_DLGMODALFRAME)
      switch val
      {         
         case $brdLowered    :  style |= $WS_EX_STATICEDGE             	
         case $brdDblRaised :  style |= $WS_EX_DLGMODALFRAME   
         case $brdDblLowered :  style |= $WS_EX_CLIENTEDGE         
      }
      SetWindowLong( this.hwnd, $GWL_EXSTYLE, style )      
      SetWindowPos( this.hwnd, 0, 0, 0, 0, 0, $SWP_FRAMECHANGED | 
                  $SWP_NOACTIVATE | $SWP_NOZORDER | $SWP_NOMOVE | $SWP_NOSIZE )      
   }     
}

method vScrollBox.UpdateScroll()
{
   SCROLLINFO si
   si.cbSize = sizeof(SCROLLINFO)
   si.fMask = $SIF_POS | $SIF_RANGE | $SIF_PAGE           
   GetScrollInfo( .hwnd, $SB_VERT, si )
   uint newtop = si.nPos
   //print( "update scroll \(.Name) 1 \( newtop ) \(si.nMax) \(si.nPage) \n" )
   GetScrollInfo( .hwnd, $SB_HORZ, si )
   uint newleft = si.nPos
     
   //print( "update scroll \(.Name) 2 \( newleft ) \(si.nMax) \(si.nPage) \n" ) 
   uint i
   uint offx = newleft - this.clloc.left
   uint offy = newtop - this.clloc.top
   if offx || offy
   { 
      evparQuery pq
      
      .OnBeforeScroll.run( pq )
      if !pq.flgCancel
      { 
      .flgScrolling = 1
      //print( "Scroll \(offx) \(offy)\n" )
      this.clloc.top = newtop
      this.clloc.left = newleft
      
      /*uint r = CreateRectRgn( 0, 0, 1, 1 )
      uint a = CreateRectRgn( 0, 0, 1, 1 )      
      fornum i = 0, .pCtrls               
      {
         
         //.Comps[i]->vCtrl.Top = .Comps[i]->vCtrl.Top
         if .Comps[i]->vCtrl.HorzAlign != $alhLeft || .Comps[i]->vCtrl.VertAlign != $alvTop
         {
            GetWindowRgn( .Comps[i]->vCtrl.hwnd, a )
            //.Comps[i]->vCtrl.Visible = 0
            CombineRgn( r, r, a, $RGN_OR )
         }
         //.Comps[i]->vCtrl.hwnd )
         //RedrawWindow( this.hwnd, 0->RECT, 0, 0x507)
         //win_move( .Comps[i]->vCtrl.hwnd, ep.loc.left, ep.loc.top )
      }*/
      UpdateWindow( this.hwnd )
      ScrollWindowEx( this.hwnd, -offx, -offy, 0, 0, 0, 0,  7 )
      //DeleteObject( r )
      //UpdateWindow( this.hwnd )
      //Sleep( 1000 )
      //for i = .pCtrls-1, i >= 0, i--
      /*fornum i = 0, .pCtrls               
      {
         
         //.Comps[i]->vCtrl.Top = .Comps[i]->vCtrl.Top
         if .Comps[i]->vCtrl.HorzAlign != $alhLeft || .Comps[i]->vCtrl.VertAlign != $alvTop
         {
         print( "SCROLL \(.Comps[i]->vComp.Name ) \(.Comps[i]->vComp.TypeName )\n" )
         eventpos ep         
         ep.loc = .Comps[i]->vCtrl.loc
         ep.loc.left = ep.loc.left
         ep.loc.top = ep.loc.top 
         //ep.loc.left -= offx
         //ep.loc.top -= offy
         ep.move = 1
         ep.code = $e_poschanging      
         .Comps[i]->vCtrl.Virtual( $mPosChanging, ep )
         //.Comps[i]->vCtrl.Visible = 1
         }
         //UpdateWindow( this.hwnd )//.Comps[i]->vCtrl.hwnd )
         //RedrawWindow( this.hwnd, 0->RECT, 0, 0x507)
         //win_move( .Comps[i]->vCtrl.hwnd, ep.loc.left, ep.loc.top )
      }*/
      .flgScrolling = 0
         .OnAfterScroll.run( )
      }
      
   }
      
      /*else
      {
         if this.clloc.left != newpos
         { 
            this.clloc.left = newpos
            fornum i = 0, .pCtrls               
            {
               .Comps[i]->vCtrl.Left = .Comps[i]->vCtrl.Left
            }
         }
      }   */   
}

method uint vScrollBox.wmscroll <alias=vScrollBox_wmscroll> ( winmsg wmsg )
{   
 
   uint flag = ?( wmsg.msg == $WM_VSCROLL, $SB_VERT, $SB_HORZ )      
   int newpos
   SCROLLINFO si
   si.cbSize = sizeof(SCROLLINFO)
   si.fMask = $SIF_POS | $SIF_PAGE | $SIF_RANGE |$SIF_TRACKPOS           
   GetScrollInfo( .hwnd, flag, si )
   newpos = si.nPos
   switch wmsg.wpar & 0xFFFF
   {
      case $SB_LINEUP : newpos -= 10
      case $SB_LINEDOWN : newpos += 10
      case $SB_PAGEUP : newpos -= si.nPage
      case $SB_PAGEDOWN : newpos += si.nPage
      case $SB_TOP    : newpos = si.nMax
      case $SB_BOTTOM : newpos = si.nMin
      case $SB_THUMBPOSITION, $SB_THUMBTRACK 
      {  
         newpos = si.nTrackPos
      }
      default : return 0
   }            
   si.fMask = $SIF_POS      
   newpos = max( si.nMin, min( newpos, si.nMax ) )
//   print( "newpos = \(newpos)\n" )      
   si.nPos = newpos
   SetScrollInfo( .hwnd, flag, si, 1 )
   
   .UpdateScroll()                                      
               
   wmsg.flags = 1
   
   return 0
}

method vScrollBox.mPosChanged <alias=vScrollBox_mPosChanged>( evparEvent ev )
{
   //print( "PAGE \(.Name) \(this.clloc.height + 1) \(this.clloc.width + 1)\n" )
   .iSetRange()
   /*SCROLLINFO si
   si.cbSize = sizeof(SCROLLINFO) 
   si.fMask = $SIF_PAGE 
   si.nPage = this.clloc.height + 1//min( this.clloc.height + 1, this.pVertRange + 2 )                  
   SetScrollInfo( .hwnd, $SB_VERT, si, 1 )
      
   si.fMask = $SIF_PAGE 
   si.nPage = this.clloc.width + 1//min( this.clloc.width + 1, this.pHorzRange + 2 ) //?( .pHorzRange, this.clloc.width + 1, 0 )               
   SetScrollInfo( .hwnd, $SB_HORZ, si, 1 )*/
   //print( "poschanged \(this.clloc.height) \(this.clloc.width)\n" )
   this->vCtrl.mPosChanged( ev )   
   //print( "poschanged\n" )
   .UpdateScroll()
   //print( "poschanged end\n" )   
}

method vScrollBox.mChildPosChanged <alias=vScrollBox_mChildPosChanged>( vCtrl ctrl )
{
   
   if .pAutoScroll && !.flgScrolling
   {      
      uint i
      int maxwidth, maxheight
      fornum i = 0, .pCtrls               
      {
         if .Comps[i]->vCtrl.HorzAlign == $alhLeft
         {
            maxwidth = max( maxwidth, .Comps[i]->vCtrl.Left + .Comps[i]->vCtrl.Width )
         }
         if .Comps[i]->vCtrl.VertAlign == $alvTop
         {
            maxheight = max( maxheight, .Comps[i]->vCtrl.Top + .Comps[i]->vCtrl.Height )
         }
      }
      .pHorzRange = maxwidth
      .pVertRange = maxheight
      .iSetRange()
      //print( "Childpos 2\n" )
      /*SCROLLINFO si
      si.cbSize = sizeof(SCROLLINFO)
      si.fMask = $SIF_RANGE 
      si.nMin = 0
      si.nMax = maxheight              
      SetScrollInfo( .hwnd, $SB_VERT, si, 1 )
      si.nMax = maxwidth
      SetScrollInfo( .hwnd, $SB_HORZ, si, 1 )*/
      .UpdateScroll()
   }      
}

method vScrollBox vScrollBox.mCreateWin <alias=vScrollBox_mCreateWin>()
{
   uint style = $WS_CHILD | $WS_CLIPCHILDREN | $WS_CLIPSIBLINGS | 
                $WS_OVERLAPPED //| $WS_VSCROLL | $WS_HSCROLL 
   .CreateWin( /*"GvScrollBox".ustr()*/"GvForm".ustr(), 0, style )
   /*SCROLLINFO si
   si.cbSize = sizeof(SCROLLINFO)
   si.fMask = $SIF_RANGE 
   si.nMin = 0
   si.nMax = 500              
   SetScrollInfo( .hwnd, $SB_VERT, si, 1 )
   si.nMax = 800
   SetScrollInfo( .hwnd, $SB_HORZ, si, 1 )*/
   this.prevwndproc = -1      
   this->vCtrl.mCreateWin()  
   if this.pBorder 
   {
      uint border = this.pBorder 
      this.pBorder = 0
      this.Border = border
   }
   .iSetRange()
   .UpdateScroll()
   //.panel.Owner = this                                                 
   return this
}



/*------------------------------------------------------------------------------
   Registration
*/
method vScrollBox vScrollBox.init( )
{
   this.pTypeId = vScrollBox
   this.pCanContain = 1
   //this.pBorder = $brdLowered   
   this.loc.width = 100
   this.loc.height = 100
   //this.panel.pAlign = $alhClient | $alvClient   
   this.pBorder = $brdLowered
   return this 
}  




func init_vScrollBox <entry>()
{
   /*WNDCLASSEX visclass
   ustr classname = "GvScrollBox"    
   with visclass
   {
      .cbSize      = sizeof( WNDCLASSEX )
      //.style       = $CS_HREDRAW | $CS_VREDRAW
      .lpfnWndProc = callback( &myproc, 4 )      
      .hInstance   = GetModuleHandle( 0 )      
      .hCursor     = LoadCursor( 0, $IDC_ARROW )
      .hbrBackground = 1      
      .lpszClassName = classname.ptr()      
   } 
   uint hclass = RegisterClassEx( &visclass )
*/  
   regcomp( vScrollBox, "vScrollBox", vCtrl, $vCtrl_last,
      %{ %{$mCreateWin, vScrollBox_mCreateWin }, 
         %{$mPosChanged, vScrollBox_mPosChanged },
         %{$mChildPosChanged, vScrollBox_mChildPosChanged }         
      },
      %{ %{$WM_VSCROLL, vScrollBox_wmscroll },
         %{$WM_HSCROLL, vScrollBox_wmscroll }
      } )
      
ifdef $DESIGNING {
   cm.AddComp( vScrollBox, 1, "Windows", "scrollbox" )
   cm.AddProps( vScrollBox,  %{ 
"Caption"  , ustr,  0,
"Border",   uint, 0,
"AutoScroll", uint, 0,
"HorzRange", uint, 0,
"VertRange", uint, 0
   })     
   cm.AddPropVals( vScrollBox, "Border", %{  
"brdNone"         ,  $brdNone      ,
"brdLowered"      ,  $brdLowered   ,       
"brdDblRaised"    ,  $brdDblRaised ,
"brdDblLowered"   ,  $brdDblLowered
   })
}
      
}

