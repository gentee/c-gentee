
// Поиск окна находящегося сверху данной точки экрана
func uint gettopwindow( uint wd POINT pnt ) 
{
   POINT pntcl //Координаты переведенные под текущее окно
	uint /*wd,*/ ww, wp, wc
   uint flgtr 
   
   //Инициализация, окно экрана            
   //wd = GetDesktopWindow()
   wc = wd
   ww = 0         
   flgtr = $CWP_SKIPTRANSPARENT   
   //Получение первого потомка
   while wc && wc != ww
   {    
      pntcl = pnt
      ScreenToClient( wc, pntcl )
      wp = ww
      ww = wc            
      wc = ChildWindowFromPointEx( wc, pntcl.x, pntcl.y, $CWP_SKIPINVISIBLE | flgtr )      
      flgtr = 0            
   }
   /*
   if wp != wd 
   {  //Поиск потомка лежащего сверху            
      ww = GetWindow( ww, $GW_HWNDLAST )
      while ww
      {       
         print( "ww=\(ww)\n" )
         if GetWindowLong( ww, $GWL_STYLE ) & $WS_VISIBLE 
         {   
            pntcl = pnt
            ScreenToClient( ww, pntcl )
            wc = ChildWindowFromPointEx( ww, pntcl.x, pntcl.y, $CWP_SKIPINVISIBLE )
            if wc: break;
            wc = ww
         }               
         ww = GetWindow( ww, $GW_HWNDPREV )               
      }      
   }*/   
   return ww
} 

func setrgn( uint w, RECT r )
{
   uint ar, br
   int mx, my, hx, hy
subfunc sm( int x, int y )
{
   SetRectRgn( br, x, y, x + 6, y + 6 )
   CombineRgn( ar, ar, br, $RGN_OR )
}
   //flgnopaint = 1
   //ShowWindow( w, $SW_HIDE )
   //SetWindowLong( w, $GWL_STYLE, GetWindowLong( w, $GWL_STYLE ) & ~ $WS_VISIBLE )
   //SetWindowRgn( w, 0, 1 ) 
   ////SetWindowRgn( w, 0, 1 )  
   //MoveWindow( w, 0, 0, 0, 0, 1 )
   //ShowWindow( w, $SW_HIDE )
   //MoveWindow( w, 0, 0, 0, 0, 1 )
   //SetWindowPos( w, 0, 0, 0, 1, 1, $SWP_NOMOVE | $SWP_NOACTIVATE | $SWP_NOSENDCHANGING)
       
   //SetWindowRgn( w, 0, 0 )
         
   mx = r.right - r.left 
   my = r.bottom - r.top 
   hx = mx / 2 - 1
   hy = my / 2 - 1
   ar = CreateRectRgn( 2, 2, mx + 2, my + 2 )
   br = CreateRectRgn( 4, 4, mx, my )
   CombineRgn( ar, ar, br, $RGN_DIFF )
   mx -= 2
   my -= 2  
   sm( -0, -0 )
   sm( hx, -0 )
   sm( mx, -0 )
   sm( -0, hy )
   sm( mx, hy )
   sm( -0, my )
   sm( hx, my )
   sm( mx, my )
   //uint br = CreateRectRgn( 2, 2, r.right - r.left - 2, r.bottom - r.top - 2 )
      
   DeleteObject( br )
   //flgnopaint = 0
   //ShowWindow( w, $SW_HIDE )
   SetWindowRgn( w, ar, 1 )
   
   MoveWindow( w, r.left - 2, r.top - 2, r.right - r.left + 4, r.bottom - r.top + 4, 1 )
   //ShowWindow( w, $SW_SHOW )
   //InvalidateRgn( w, ar, 1 )
   //UpdateWindow( w )
   //Sleep(1000)
   /*print( "setrgn   
\(r.right - r.left + 4)    
\(r.bottom - r.top + 4)
\n" )*/
   
   //ShowWindow( w, $SW_SHOW )
   //Sleep(1000)
   //InvalidateRect( w, 0->RECT, 1 )
      
   //ShowWindow( w, $SW_SHOW )
   //SetWindowLong( w, $GWL_STYLE, GetWindowLong( w, $GWL_STYLE ) | $WS_VISIBLE )
}

func uint getcursorsize( uint w, POINT pnt )
{
   RECT r
   int mx, hx, my, hy
   uint res = 0
   GetWindowRect( w, r )
   mx = r.right - r.left - 6
   hx = mx/2
   my = r.bottom - r.top - 6
   hy = my/2
   if pnt.y >= my 
   {
      if pnt.x >= mx : res = 5
      elif pnt.x >= hx && pnt.x < hx + 6 :res = 8
      elif pnt.x < 6 : res = 6   
   }
   elif pnt.y >= hy && pnt.y < hy + 6
   {
      if pnt.x >= mx : res = 7     
      elif pnt.x < 6 : res = 3
   }
   elif pnt.y < 6
   {
      if pnt.x >= mx : res = 2
      elif pnt.x >= hx && pnt.x < hx + 6 : res = 4
      elif pnt.x < 6 : res = 1
   }   
   return res  
}

func mousetopoint( uint lpar, POINT pnt )
{    
   pnt.x = int( ( &lpar )->short )
	pnt.y = int( ( &lpar + 2 )->short )
}

/*

  

func ffr( uint w, x, y )
{		
	MoveWindow( w, x-2, y-2, 5,5, 1 )
}
  
func outnamewin( uint wp )
{
   str c, b
   c.reserve( 256 )
   GetClassName( wp, c.ptr(), 256 )
   c.setlenptr()
   b.reserve( 256 )
   SendMessage( wp, $WM_GETTEXT, 256, b.ptr() )
   b.setlenptr()
   print( hex2stru("",wp) + "   " + c + "   " + b + " "+ hex2stru( "", GetWindowLong( wp, $GWL_STYLE )) +"\n" )
}
*/  