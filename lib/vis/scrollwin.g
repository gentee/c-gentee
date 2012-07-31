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
   vPanel panel
}


method vScrollBox.mPosChanged <alias=vScrollBox_mPosChanged>( eventn ev )
{
   SCROLLINFO si
 /*  si.cbSize = sizeof(SCROLLINFO)
   si.fMask = $SIF_RANGE 
   GetScrollInfo( .hwnd, $SB_VERT, si )
     */
   si.fMask = $SIF_PAGE 
   si.nPage = this.clloc.height               
   SetScrollInfo( .hwnd, $SB_VERT, si, 1 )
      
   this->vCtrl.mPosChanged( ev )
}

method uint vScrollBox.wmscroll <alias=vScrollBox_wmscroll> ( winmsg wmsg )
{
   //print( "scroll 1 \(wmsg.wpar)\n" )
   //if (wmsg.wpar & 0xFFFF) == $SB_ENDSCROLL
   {
      //print( "scroll 2\n" )
      switch wmsg.msg 
      {  
         case $WM_VSCROLL
         {  
            uint newpos
            SCROLLINFO si
            si.cbSize = sizeof(SCROLLINFO)
            si.fMask = $SIF_POS | $SIF_PAGE | $SIF_TRACKPOS           
            GetScrollInfo( .hwnd, $SB_VERT, si )
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
            }            
            si.fMask = $SIF_POS
            si.nPos = newpos
            .panel.Top = -newpos
            //print( "scroll 4 \(si.nPos)\n" )                        
            SetScrollInfo( .hwnd, $SB_VERT, si, 1 )
            
            wmsg.flags = 1
         }
      }
   }
   return 0
}

method vScrollBox vScrollBox.mCreateWin <alias=vScrollBox_mCreateWin>()
{
   uint style = $WS_CHILD | $WS_VISIBLE | $WS_CLIPCHILDREN | $WS_CLIPSIBLINGS | 
                $WS_OVERLAPPED | $WS_VSCROLL | $WS_HSCROLL 
   .CreateWin( /*"GvScrollBox".ustr()*/"GvForm".ustr(), 0, style )
   SCROLLINFO si
   si.cbSize = sizeof(SCROLLINFO)
   si.fMask = $SIF_RANGE 
   si.nMin = 0
   si.nMax = 1000              
   SetScrollInfo( .hwnd, $SB_VERT, si, 1 )
   this.prevwndproc = -1      
   this->vCtrl.mCreateWin()  
   .panel.Owner = this                                                 
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
   this.panel.pAlign = $alhClient | $alvClient   
   this.panel.pBorder = 0
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
         %{$mPosChanged, vScrollBox_mPosChanged }
      },
      %{ %{$WM_VSCROLL, vScrollBox_wmscroll },
         %{$WM_HSCROLL, vScrollBox_wmscroll }
      } )
      
ifdef $DESIGNING {
   cm.AddComp( vScrollBox, 1, "Windows" )
   cm.AddProps( vScrollBox,  %{ 
"Caption"  , ustr,  0
   })     
}
      
}

