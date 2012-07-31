
type vBtnSys <inherit = vCtrl>
{
   uint    fPush
   evEvent onclick
}

property vBtnSys.Push( uint val )
{
   if val : val = 1 
   if this.fPush != val
   {
      this.fPush = val
      .Invalidate()   
   }
}

property uint vBtnSys.Push()
{
   return this.fPush
}

/*method uint vBtnSys.defproc( eventn ev )
{
   switch ev.code
   {
      case $e_mouse
      {      
         switch ev->eventmouse.evmtype 
         {
            case $evmLDown 
            {            
               this.push = 1               
               SetCapture( this.hwnd )
               this.onclick.run()             
            }
            case $evmLUp 
            {
               this.push = 0               
               ReleaseCapture()
            }            
         }
      }      
   }
   return this->vctrl.defproc( ev )
}*/

method uint vBtnSys.wmpaint <alias=vBtnSys_wmpaint>( winmsg wmsg )
{
   uint         hdc
   PAINTSTRUCT  ps
   RECT         rect         
   
   hdc = BeginPaint( this.hwnd, ps )       
   rect.left = 0
   rect.top = 0
   rect.right = this.loc.width
   rect.bottom = this.loc.height
   DrawFrameControl( hdc, rect, 3, 1 | ?( this.fPush, 0x4200, 0 ))          
   EndPaint( this.hwnd, ps )
   return 0
}

method uint vBtnSys.wmlbuttondown <alias=vBtnSys_wmlbuttondown>( winmsg wmsg )
{            
   this.Push = 1               
   SetCapture( this.hwnd )
   this.onclick.run() 
   wmsg.flags = 1
   return 0            
}

method uint vBtnSys.wmlbuttonup <alias=vBtnSys_wmlbuttonup>( winmsg wmsg ) 
{
   this.Push = 0               
   ReleaseCapture()
   wmsg.flags = 1
   return 0
}

method vBtnSys vBtnSys.mCreateWin <alias=vBtnSys_mCreateWin>()
{   
   .CreateWin( "GVForm".ustr(), 0, 
                       $WS_CHILD | $WS_VISIBLE | $WS_CLIPCHILDREN | $WS_CLIPSIBLINGS | $WS_OVERLAPPED )
   this->vCtrl.mCreateWin()      
   .WinMsg( $WM_SETFONT, GetStockObject( $DEFAULT_GUI_FONT ) )                     
   return this
}

method vBtnSys vBtnSys.init( )
{    
   this.pTypeId = vBtnSys      
   this.Visible = 1
   return this 
}  

func init_vBtnSys <entry>()
{  
   regcomp( vBtnSys, "vBtnSys", vCtrl, $vCtrl_last, 
      %{ %{$mCreateWin,    vCustomBtn_mCreateWin}/*,
         %{$mWinCmd,       vBtn_mWinCmd},
         %{$mLangChanged, vBtn_mLangChanged }*/}, 
      %{ %{$WM_PAINT,      vBtnSys_wmpaint },
         %{$WM_LBUTTONDOWN,  vBtnSys_wmlbuttondown },
         %{$WM_LBUTTONUP,    vBtnSys_wmlbuttonup }
      } )
}
