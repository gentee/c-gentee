type evparQueryCreate <inherit=eventpos> 
{   
   uint Owner      
   uint TypeId
   uint NewComp
}

type evQueryCreate <inherit=evEvent>
{
}


method evQueryCreate evQueryCreate.init
{
   this.eventtypeid = evparQueryCreate
   return this
}


type vVEEdit <inherit=vCtrl>
{
   uint winn //Текущий выбранный элемент
   uint winparent   
   uint VEPanel //Главная панель
   uint VisPanel
   
   uint typ
   uint oper
   
   //RECT currt
   //uint mouseleft
   //uint mousetop
   
	RECT rectold
	uint offx, offy	
	uint  wdown	
	uint pen, brush, brushgr
   POINT discr
   uint flgadd
   
   /*vPanel panNoVis
   vPanel panVis*/

   evEvent  onSelect               
   evEvent  onDelete
   evEvent  onstartchange
   evQueryCreate onQueryCreate
   
}

type vVEPanel <inherit=vPanel>
{
   vScrollBox  VisPanel
   vListView   NoVisList
   vPanel      TopPanel
   vVEEdit     WE
   uint        pSelected
   uint        flgDesChanged
   
   evEvent            onSelect
   evQueryCreate   onQueryCreate
   evValUint OnDblClick
}
extern 
{
   property vComp vVEPanel.Selected()
   property vVEPanel.Selected( vComp newcomp )
   method vVEPanel.DblClick()
}

type vVEFrame <inherit=vCtrl>
{   
   uint WE
}

include {   
   "funcs.g"
}

extern
{
   method vVEEdit.releasecapture()
}

define {
   OPERMOVE = 0x1   //Перемещение 
   OPERSIZE = 0x2   //Изменение размеров
   OPERNEW  = 0x4   //Новый компонент
   OPERFIRST = 0x10000
   OPERCHANGE = 0x20000
   
   
}

method RECT.set( int x, int y )
{
	this.left = this.right = x
	this.top = this.bottom = y	
}

method RECT.reframe( uint wnd, RECT rnew )
{
	uint hdc
subfunc frame ( RECT r )
{
	MoveToEx( hdc, r.left, r.top, 0->POINT )
	LineTo( hdc, r.right - 1, r.top )
	LineTo( hdc, r.right - 1, r.bottom - 1 )
	LineTo( hdc, r.left, r.bottom - 1)
	LineTo( hdc, r.left, r.top )
}  
	hdc = GetDC( 0 )
	SetROP2( hdc, $R2_NOT )
	frame( this )	
	frame( rnew )	
	this = rnew
	ReleaseDC( 0, hdc )	
}

method RECT.frame_del( uint wnd )
{
	RECT rectnew
	rectnew.set( -0, -0 )
	this.reframe( wnd, rectnew )
}

method RECT.frame_sel( uint wnd, uint x y ) 
{
	RECT rectnew
		
	rectnew.left = this.left
	rectnew.top = this.top
	rectnew.right = x
	rectnew.bottom = y
	this.reframe( wnd, rectnew )   	
}

method RECT.frame_move( uint wnd int x y )
{
	RECT rectnew
	rectnew.left = x
	rectnew.top = y
	rectnew.right = x + this.right - this.left
	rectnew.bottom = y + this.bottom - this.top
	this.reframe( wnd, rectnew )
}

method vVirtCtrl.GetRect( RECT r )
{   
   if this.TypeIs( vCtrl ) 
   {   
      GetWindowRect( this->vCtrl.hwnd, r )
   }
   else
   {
      GetWindowRect( this.Owner->vCtrl.hwnd, r )
      RECT rr
      this.Owner->vCtrl.WinMsg( $WM_NCCALCSIZE, 0, &rr )        
      r.left += this.Left + rr.left
      r.top += this.Top + rr.top
      r.right = r.left + this.Width
      r.bottom = r.top + this.Height 
   }
}

method vVEEdit.green()
{
   if this.winn 
   {
      RECT r,a
      
      //GetWindowRect( this.winn->vCtrl.hwnd, r )
      this.winn->vVirtCtrl.GetRect( r )
      
      POINT p          
      p.x = r.left
      p.y = r.top 
      ScreenToClient( this.hwnd, p)
      r.left = p.x
      r.top = p.y
      p.x = r.right
      p.y = r.bottom 
      ScreenToClient( this.hwnd, p)
      r.right = p.x
      r.bottom = p.y
      this.wdown->vCtrl.loc.left = r.left - 2
      this.wdown->vCtrl.loc.top = r.top - 2
      
      //this.Owner->vScrollBox.AutoScroll = 0
      //.VisPanel->vScrollBox.AutoScroll = 0
      setrgn( this.wdown->vCtrl.hwnd, r )
      //this.Owner->vScrollBox.AutoScroll = 1
      //.VisPanel->vScrollBox.AutoScroll = 1
   }
}

method vVEEdit.refresh()
{
}

method vVEEdit.select( vComp w )
{
   if this.winn = &w
   {
      this.winparent = GetParent( w->vCtrl.hwnd )
      this.wdown->vCtrl.Visible = 1         
      this.green()         
      SetWindowPos( this.wdown->vCtrl.hwnd, 0, 0, 0, 0, 0, $SWP_NOACTIVATE | $SWP_NOMOVE | $SWP_NOSIZE )
   }
   else
   {    
      this.wdown->vCtrl.Visible = 0      
   }
/*   if w && this.winn != &w && w.p_designing
   {        
      if this.winn : this.refresh()        
      this.winn = &w
      //this.refresh()
      if w.TypeIs( vCtrl )
      {         
         this.winparent = GetParent( w->vCtrl.hwnd )
         this.wdown->vCtrl.Visible = 1         
         this.green()         
         SetWindowPos( this.wdown->vCtrl.hwnd, 0, 0, 0, 0, 0, $SWP_NOACTIVATE | $SWP_NOMOVE | $SWP_NOSIZE )
         
         //this.wdown->vCtrl.Visible = 1
      }  
      else
      {
         this.wdown->vCtrl.Visible = 0
      }    
   }    
   this.onSelect.run()
   */
   //->func(this.form)     
   //InvalidateRect( this.wdown->vCtrl.hwnd, 0->RECT, 1 )
}

method vVEEdit.nextobj( uint flgreserve )
{
   uint ctrl = this.winn    
   uint level           
   do
   {
      if flgreserve
      {                
         ctrl = this.winn->vForm.form->vForm.PrevCtrl( ctrl, &level, 0 )
      }
      else: ctrl = this.winn->vForm.form->vForm.NextCtrl( ctrl, &level, 0)              
   }
   while !ctrl || !ctrl->vCtrl.p_designing            
   //this.select( ctrl->vCtrl )
   .VEPanel->vVEPanel.Selected = ctrl->vComp  
}

func int align( int val off discr )
{
   int tail
   if tail = val % discr
   {      
      if tail < 0 : tail = discr + tail
      if off < 0 || ( !off && tail < discr / 2 )
      {
         val -= tail
      }   
      else
      {
         val += discr - tail
      }      
   }
   else
   {
      val += off * discr
   }
   return val
}

method int vVEEdit.alignx( int val, int off )
{
   return align( val, off, .discr.x )
}

method int vVEEdit.aligny( int val, int off )
{
   return align( val, off, .discr.y )
}


//method uint vVEFrame.mKey <alias=vVEFrame_mKey>( eventkey evk )
method uint vVEEdit.mKey <alias=vVEEdit_mKey>( evparKey evk )
{
   uint WE as this//.WE->vVEEdit
   if evk.evktype == $evkDown && WE.winn
   {
      if this.oper 
      {
         if evk.key == $VK_ESCAPE
         {  
            this.oper = 0                                                
            //Удаление остаточной рамки         	
            //this.framehide()
            //this.releasecapture()
            ReleaseCapture()
         }
         return 0
      }
      switch evk.key
      {
         case $VK_TAB
         {
            if evk.mstate & $mstCtrl
            {
               evk.mstate &= ~$mstCtrl
            }
            else
            {                  
               WE.nextobj( evk.mstate & $mstShift )          
               return 0   
            }
         }
         case $VK_LEFT//Влево
         {         
            if evk.mstate & $mstShift 
            {
               if evk.mstate & $mstAlt : WE.winn->vVirtCtrl.Width = WE.winn->vVirtCtrl.Width - 1 
               else : WE.winn->vVirtCtrl.Width = .alignx( WE.winn->vVirtCtrl.Width, -1 )
            } 
            else 
            {
               if evk.mstate & $mstAlt : WE.winn->vVirtCtrl.Left = WE.winn->vVirtCtrl.Left - 1 
               else : WE.winn->vVirtCtrl.Left = .alignx( WE.winn->vVirtCtrl.Left, -1 )
            }                                  
            return 0
         }
         case $VK_UP//0x26//Вверх
         {               
            if evk.mstate & $mstShift 
            {
               if evk.mstate & $mstAlt : WE.winn->vVirtCtrl.Height = WE.winn->vVirtCtrl.Height - 1 
               else : WE.winn->vVirtCtrl.Height = .aligny( WE.winn->vVirtCtrl.Height, -1 )
            } 
            else 
            {
               if evk.mstate & $mstAlt : WE.winn->vVirtCtrl.Top = WE.winn->vVirtCtrl.Top - 1 
               else : WE.winn->vVirtCtrl.Top = .aligny( WE.winn->vVirtCtrl.Top, -1 )
            }                        
            return 0
         }
         case $VK_RIGHT//0x27//Вправо
         {
            if evk.mstate & $mstShift 
            {
               if evk.mstate & $mstAlt : WE.winn->vVirtCtrl.Width = WE.winn->vVirtCtrl.Width + 1 
               else : WE.winn->vVirtCtrl.Width = .alignx( WE.winn->vVirtCtrl.Width, 1 )
            } 
            else 
            {
               if evk.mstate & $mstAlt : WE.winn->vVirtCtrl.Left = WE.winn->vVirtCtrl.Left + 1 
               else : WE.winn->vVirtCtrl.Left = .alignx( WE.winn->vVirtCtrl.Left, 1 )
            }         
            return 0
         }
         case $VK_DOWN//0x28//Вниз
         {            
            if evk.mstate & $mstShift 
            {
               if evk.mstate & $mstAlt : WE.winn->vVirtCtrl.Height = WE.winn->vVirtCtrl.Height + 1 
               else : WE.winn->vVirtCtrl.Height = .aligny( WE.winn->vVirtCtrl.Height, 1 )
            } 
            else 
            {
               if evk.mstate & $mstAlt : WE.winn->vVirtCtrl.Top = WE.winn->vVirtCtrl.Top + 1 
               else : WE.winn->vVirtCtrl.Top = .aligny( WE.winn->vVirtCtrl.Top, 1 )
            }                   
            return 0  
         }   
         case $VK_DELETE//0x2E//Удаление
         {
            if !WE.winn->vVirtCtrl.TypeIs( vForm )
            {
               uint owner as WE.winn->vCtrl.Owner
               uint delobj as WE.winn->vVirtCtrl
               .VEPanel->vVEPanel.Selected = owner             
               //WE.winn->vCtrl.DestroyComp()
               delobj.DestroyComp()
               
               
               /*uint ctrl = WE.winn
               WE.nextobj( 0 )
               ctrl->vCtrl.delcomp()//delete()
               WE.ondelete.run()*/
               //delcompdes( ctrl->vCtrl )
            }
         }   
      }
   }
   return 0
}

method vVEEdit.move( RECT rnew )
{
   this.refresh()
   POINT offp
               
   offp.x = rnew.left
   offp.y = rnew.top
   ScreenToClient( this.winparent, offp )    
   //Сдвиг окна		
	//MoveWindow( this.winn->vCtrl.hwnd, offp.Left, offp.Top,/*rnew.left + offp.Left, rnew.top + offp.Top,*/ rnew.right - rnew.left, rnew.bottom - rnew.top, 1 )
   /*this.winn->vCtrl.Left = offp.Left
   this.winn->vCtrl.Top = offp.Top
   this.winn->vCtrl.Width = rnew.right - rnew.left
   this.winn->vCtrl.Height = rnew.bottom - rnew.top*/
   eventpos ep   
   ep.loc.left = offp.x 
   ep.loc.top = offp.y 
   ep.loc.width = rnew.right - rnew.left
   ep.loc.height = rnew.bottom - rnew.top
   if this.winn->vComp.pOwner && this.winn->vComp.TypeIs( vCtrl)  
   {
      //ep.loc.left += this.winn->vCtrl.pOwner->vCtrl.clloc.left
      //ep.loc.top += this.winn->vCtrl.pOwner->vCtrl.clloc.top      
      if this.winn->vCtrl.pAlign & ( $alhRight | $alhLeftRight ) 
      {
         this.winn->vCtrl.pRight = this.winn->vCtrl.Owner->vCtrl.clloc.width - ep.loc.left - ep.loc.width 
      }
      if this.winn->vCtrl.pAlign & ( $alvBottom | $alvTopBottom ) 
      {
         this.winn->vCtrl.pBottom = this.winn->vCtrl.Owner->vCtrl.clloc.height - ep.loc.top - ep.loc.height 
      }
   }
   //print( "move \(ep.loc.top) \(ep.loc.height)\n" )   
   //this.wdown->vCtrl.Visible = 0
   ep.code = $e_poschanging
   ep.move = 1
   this.winn->vVirtCtrl.Virtual( $mPosChanging, &ep )   
   //this.refresh()
   //this.green()
   //this.wdown->vCtrl.Visible = 1  
   this.onSelect.run()//->func(this.form)   
    
}

method vVEEdit.framenew( POINT pnt )
{
   RECT rectnew//, rectold
   this.typ = 3	                                      	
	this.rectold.set( -0, -0 )   
   ScreenToClient( this.winparent, pnt )
   pnt.x = .alignx( pnt.x, 0 )
   pnt.y = .aligny( pnt.y, 0 )
   ClientToScreen( this.winparent, pnt )
   this.offx = pnt.x
   this.offy = pnt.y
   rectnew.left = pnt.x
   rectnew.top = pnt.y		
   rectnew.right = pnt.x
   rectnew.bottom = pnt.y   	
	this.rectold.reframe( this.hwnd, rectnew )	
}

method vVEEdit.frameshow( uint typ )
{
   RECT rectnew//, rectold
   this.typ = typ
	//GetWindowRect( this.winn->vCtrl.hwnd, rectnew )   
   this.winn->vVirtCtrl.GetRect( rectnew )                                    	
	this.rectold.set( -0, -0 )				
	this.rectold.reframe( this.hwnd, rectnew )	
}

method vVEEdit.framehide()
{
   RECT rectnew
   //RECT rectold
	//RECT rect               
   //Удаление остаточной рамки
	//rect = rectold
	rectnew.set( -0, -0 )				
	this.rectold.reframe( this.hwnd, rectnew )   	
}

method vVEEdit.framemove( POINT pnt )
{
   pnt.x -= this.offx
   pnt.y -= this.offy
   ScreenToClient( this.winparent, pnt )
   pnt.x = .alignx( pnt.x, 0 )
   pnt.y = .aligny( pnt.y, 0 )
   ClientToScreen( this.winparent, pnt )
   this.rectold.frame_move( this.hwnd, pnt.x, pnt.y )
}

method vVEEdit.framesize( POINT pnt )
{
   RECT rectnew   
   int tmp 
   rectnew = this.rectold
   ScreenToClient( this.winparent, pnt )
   pnt.x = .alignx( pnt.x, 0 )
   pnt.y = .aligny( pnt.y, 0 )
   ClientToScreen( this.winparent, pnt )      
   switch this.typ 
   {
      case 1
      {  
         rectnew.left = this.offx
         rectnew.right = pnt.x         
      }
      case 2
      {       
         rectnew.top = this.offy
         rectnew.bottom = pnt.y  
      }
      case 3
      {
         rectnew.left = this.offx
         rectnew.right = pnt.x
         rectnew.top = this.offy
         rectnew.bottom = pnt.y  
      } 
   }
   if rectnew.left > rectnew.right 
   {
      tmp = rectnew.left
      rectnew.left = rectnew.right
      rectnew.right = tmp  
   }
   if rectnew.top > rectnew.bottom
   {  
      tmp = rectnew.top
      rectnew.top = rectnew.bottom
      rectnew.bottom = tmp
   }     
   this.rectold.reframe( this.hwnd, rectnew )
}
method vVEEdit.setcapture()
{   
   RECT rt   
   uint wparent = this.winparent//GetParent( this.winn )
   if !wparent : wparent = GetDesktopWindow() 
   GetWindowRect( wparent, rt )   
   ClipCursor( rt )
   //SetWindowPos( wup, 0, 0, 0, 0, 0, $SWP_NOMOVE | $SWP_NOSIZE )
   SetCapture( this.hwnd )
   InvalidateRect( this.wdown->vCtrl.hwnd, 0->RECT, 1 )
   //UpdateWindow( this.wdown->vCtrl.hwnd )
   //SetForegroundWindow( this.hwnd )
}
method vVEEdit.releasecapture()
{
   this.oper = 0                                          
   //Удаление остаточной рамки   	
   this.framehide()
   ClipCursor( 0->RECT )
   //SetBackgroundWindow( this.hwnd )
   //SetForegroundWindow( this.hwnd )
//UpdateWindow( this.wdown->vCtrl.hwnd )
this.wdown->vCtrl.Visible = 0

this.wdown->vCtrl.Visible = 1

 InvalidateRect( this.wdown->vCtrl.hwnd, 0->RECT, 1 )
 UpdateWindow( this.wdown->vCtrl.hwnd )
  
}

method vVEEdit.startmove( POINT pnt )
{   
   this.oper = $OPERMOVE
   this.setcapture()
   this.frameshow( 0 )
	this.offx = pnt.x - this.rectold.left
	this.offy = pnt.y - this.rectold.top
   this.onstartchange.run()   
}

method vVEEdit.stop( uint flgsave )
{  
   if this.oper
   {
      RECT rect 
      uint curoper = this.oper
      rect = this.rectold      
      //this.releasecapture()
      ReleaseCapture()
      if flgsave && ( curoper & $OPERCHANGE ) 
      {
         if ( curoper & ( $OPERMOVE | $OPERSIZE ))
   	   {           
            //rect.left -= this.Owner->vCtrl.clloc.left
            //rect.top -= this.Owner->vCtrl.clloc.top              
            this.move( rect )  
            //this.releasecapture()         
         }
         elif curoper & $OPERNEW
         {            
          //  this.releasecapture()
            /*eventuint eu
            loc r
            eu.value = &r
            r.Left = rect.left
            r.Top = rect.right
            this.onnew.run( eu )*/
            POINT offp
              
            if this.winn->vComp.TypeIs( vCtrl )
            {
               offp.x = rect.left
               offp.y = rect.top
               ScreenToClient( this.winn->vCtrl.hwnd /*parent*/, offp )    
            }                          
            //Сдвиг окна		
         	//MoveWindow( this.winn->vCtrl.hwnd, offp.Left, offp.Top,/*rnew.left + offp.Left, rnew.top + offp.Top,*/ rnew.right - rnew.left, rnew.bottom - rnew.top, 1 )
            /*this.winn->vCtrl.Left = offp.Left
            this.winn->vCtrl.Top = offp.Top
            this.winn->vCtrl.Width = rnew.right - rnew.left
            this.winn->vCtrl.Height = rnew.bottom - rnew.top*/
            evparQueryCreate ep
            ep.loc.left = offp.x
            ep.loc.top = offp.y
            ep.loc.width = rect.right - rect.left
            ep.loc.height = rect.bottom - rect.top
            ep.Owner = .winn  
            this.onQueryCreate.run( ep )
            if ep.NewComp
            {  
               //.select( ep.NewComp->vComp )
               .VEPanel->vVEPanel.Selected = ep.NewComp->vComp
            }
         }
      }      
            
   }
}



/*------------------------------------------------------------------------------
   Windows Mesages Methods
*/
method uint vVEEdit.wmlbuttondown <alias=vVEEdit_wmlbuttondown>(winmsgmouse wmsg)
{
   POINT pnt
   SetFocus( this.hwnd )
   uint ww                  
   //Определение координат
   //mousetopoint( lpar, pnt )
   pnt.x = wmsg.x
   pnt.y = wmsg.y
   ClientToScreen( this.hwnd, pnt )
   //ScreenToClient( wnd, pnt ) 
   ww = gettopwindow( /*this.Owner->vCtrl.hwnd*/.VisPanel->vScrollBox.hwnd, pnt )
   //Захват окна
	if ww && ww != /*this.Owner->vCtrl.hwnd*/.VisPanel->vScrollBox.hwnd 
	{   
      
      uint ctrl as getctrl( ww )
      if &ctrl
      {
         //pnt.x -= ctrl.loc.left
         //pnt.y -= ctrl.loc.top
         POINT virtpnt = pnt
         ScreenToClient( ctrl.hwnd, virtpnt )
         int i   
         for i = *ctrl.Comps-1, i >= 0, i--
         {
            if ctrl.Comps[i]->vComp.TypeIs( vVirtCtrl ) &&
               !ctrl.Comps[i]->vComp.TypeIs( vCtrl )
            {
               ctrl.Comps[i]->vVirtCtrl.Virtual( $mPosUpdate )
               
               RECT r
               r.left = ctrl.Comps[i]->vVirtCtrl.loc.left
               r.top = ctrl.Comps[i]->vVirtCtrl.loc.top
               r.right = ctrl.Comps[i]->vVirtCtrl.loc.left + ctrl.Comps[i]->vVirtCtrl.loc.width
               r.bottom = ctrl.Comps[i]->vVirtCtrl.loc.top + ctrl.Comps[i]->vVirtCtrl.loc.height
               if PtInRect( r, virtpnt.x, virtpnt.y )
               {
                  ctrl as ctrl.Comps[i]->vVirtCtrl
                  break
               } 
            }
         }
         
         //Sleep( 1000 )
         //this.select( ctrl )         
         .VEPanel->vVEPanel.Selected = ctrl         
         //Sleep( 1000 )  
         /*POINT pnts 
         //mousetopoint( lpar, pnt )
         winmsgmouse wm
         pnts.Left = wmsg.Left//em.Left
         pnts.Top = wmsg.Top//em.Top
         ClientToScreen( this.hwnd, pnts )
         //ScreenToClient( this.hwnd, pnts )
         wm.Left = pnts.Left
         wm.Top = pnts.Top
         wm.wpar = wmsg.wpar 
         ctrl.WinMsg( $WM_NCLBUTTONDOWN, wm.wpar, wm->winmsg.lpar )*/
         if this.flgadd
         {
            //this.startmove( pnt )
            this.oper = $OPERNEW | $OPERCHANGE                 
            this.setcapture()    
            POINT pnt 
            if this.winn->vComp.TypeIs( vCtrl )
            {
               this.winparent = this.winn->vCtrl.hwnd 
            }
            else 
            {
               this.winparent = this.winn->vVirtCtrl.Owner->vCtrl.hwnd               
            }
            //mousetopoint( lpar, pnt )
            pnt.x = wmsg.x//em.Left
            pnt.y = wmsg.y//em.Top
            ClientToScreen( this.hwnd, pnt )              
            this.framenew( pnt )
            this.framesize( pnt )
         }
         else
         {   
            //this.mouseleft = wmsg.x
            //this.mouseright = wmsg.y
            this.startmove( pnt )
         }
      } 
   }
   return 0          
}

method uint vVEEdit.wmmousemove <alias=vVEEdit_wmmousemove>(winmsgmouse wmsg)
{ 
   //if this.oper & $OPERCHANGE 
   if this.oper 
   {
      if !( this.oper & $OPERFIRST ) //Первый move откидываем т.к. он генерируется SetCapture
      {
         this.oper |= $OPERFIRST
         return 0
      }
      this.oper |= $OPERCHANGE         	
   //	case 1 :	frame_sel( wnd, int( ( &lpar )->short ), int( ( &lpar + 2 )->short) )
      POINT pnt 
      //mousetopoint( lpar, pnt )
      pnt.x = wmsg.x
      pnt.y = wmsg.y
      ClientToScreen( this.hwnd, pnt )
   	if this.oper & $OPERMOVE : this.framemove( pnt )
      elif this.oper & $OPERSIZE : this.framesize( pnt )
      elif this.oper & $OPERNEW : this.framesize( pnt )            				
   }
   return 0			
}	
method uint vVEEdit.wmlbottonup <alias=vVEEdit_wmlbuttonup>(winmsg wmsg)
{
   this.stop( 1 )
   return 0
}

method uint vVEEdit.wmcapturechanged <alias=vVEEdit_wmcapturechanged>( winmsg wmsg )
{
   this.releasecapture()
   wmsg.flags = 1
   return 0
}

method uint vVEFrame.wmmousemove <alias=vVEFrame_wmmousemove>(winmsgmouse wmsg)
{
uint we as this.WE->vVEEdit//this.Owner->vVEEdit
   
   if !we.oper
   {
      POINT pnt
      uint t		         
      //Определение координат           
      //mousetopoint( lpar, pnt )
      pnt.x = wmsg.x
      pnt.y = wmsg.y
      //ClientToScreen( wnd, pnt )
      t = getcursorsize( this.hwnd, pnt )
      if t  
      {
         SetCursor( LoadCursor( 0, $IDC_SIZENWSE + ( t - 1 )%4 ) )
      }
      else : SetCursor( LoadCursor( 0, $IDC_ARROW ) )
   }         
   return 0
}
         
method uint vVEFrame.wmlbuttondown <alias=vVEFrame_wmlbuttondown>(winmsgmouse wmsg)
{         
uint we as this.WE->vVEEdit//this.Owner->vVEEdit
   POINT pnt
   uint t
   uint typ		         
   //Определение координат           
   pnt.x = wmsg.x
   pnt.y = wmsg.y
   t = getcursorsize( this.hwnd, pnt )
   if t  
   {     
          
      RECT r
      //GetWindowRect( we.winn->vCtrl.hwnd, r )
      we.winn->vVirtCtrl.GetRect( r )    
      arr art of uint
      arr arx of uint
      arr ary of uint 
      art = %{ 0, 3, 3, 1, 2, 3, 3, 1, 2 }            
      arx = %{ 0, 1, 0, 1,-1, 0, 1, 0,-1 }            
      ary = %{ 0, 1, 1,-1, 1, 0, 0,-1, 0 }
      we.offx = ?( arx[t], r.right, r.left )
      we.offy = ?( ary[t], r.bottom, r.top )
      typ = art[t]
      
      we.oper = $OPERSIZE
      we.setcapture()
      
      SetCursor( LoadCursor( 0, $IDC_SIZENWSE + ( t - 1 )%4 ) )
      we.frameshow( typ )
   }
   else
   {
      ClientToScreen( this.hwnd, pnt )            
      we.startmove( pnt )
   }     
   return 0    
}

method uint vVEEdit.wmlbuttondblclk <alias=vVEEdit_wmlbuttondblclk>(winmsgmouse wmsg)
{
   .VEPanel->vVEPanel.DblClick()    
   return 0
}

method uint vVEFrame.wmpaint <alias=vVEFrame_wmpaint>(winmsg wmsg)
{  
   uint we as this.WE->vVEEdit//as this.Owner->vVEEdit
	uint hdc
	PAINTSTRUCT lp
   uint r = CreateRectRgn( 0, 0, 1, 1 )
   GetWindowRgn( this.hwnd, r )
   InvalidateRgn( this.hwnd, r, 0 )
   //RECT r
   //GetWindowRect( this.hwnd, r )
   //InvalidateRect( this.hwnd, r, 0 )
   hdc = BeginPaint( this.hwnd, lp )   
   FillRgn( hdc, r, ?( we.oper, we.brushgr, we.brush ) )   
	EndPaint( this.hwnd, lp )
   DeleteObject( r )   
   wmsg.flags = 1
	return 0		   
}

/*method uint vVEEdit.wmpaint <alias=vVEEdit_wmpaint>(winmsg wmsg)
{     
	PAINTSTRUCT lp  
   uint hdc 
   hdc = BeginPaint( this.hwnd, lp )			
	EndPaint( this.hwnd, lp )
   wmsg.flags = 1
	return 1		   
}*/
/*------------------------------------------------------------------------------
   Virtual Methods
*/

method vVEFrame vVEFrame.mCreateWin <alias=vVEFrame_mCreateWin>()
{
   //uint we as this.Owner->vVEEdit
   
   //gclass_register( "GWDown", 0, 0, 0, we.brush, gwapp, 
   //             &gw_app, &gwapp_setnotify, &gwapp_getnotify )
   //this.loc.left = -1
   //this.loc.top = -1
   //this.Owner->vCtrl.CreateWin( "GVForm".ustr(), 0, $WS_OVERLAPPED | $WS_CLIPSIBLINGS  | $WS_CHILD | $WS_VISIBLE )
   /*this.hwnd = CreateWindowEx(  //$WS_EX_TRANSPARENT
   0, "STATIC".ustr().ptr(), "w".ustr().ptr(), 
   //  $WS_OVERLAPPED  
   $WS_CLIPSIBLINGS  | $WS_CLIPCHILDREN | $WS_CHILD | $WS_VISIBLE, 
      -1, -1, 1, 1, this.Owner->vCtrl.Owner->vCtrl.hwnd, 0, 0, &this )*/
   //this.CreateWin( "STATIC".ustr(), /*$WS_EX_TRANSPARENT*/0,/* $WS_CHILD |*/ $WS_VISIBLE | $WS_CLIPCHILDREN | $WS_CLIPSIBLINGS | $WS_OVERLAPPED )
   this.CreateWin( "GVTr".ustr(), 0, $WS_CHILD | $WS_VISIBLE | $WS_CLIPCHILDREN | $WS_CLIPSIBLINGS | $WS_OVERLAPPED )
   this.prevwndproc = -1   
   this->vCtrl.mCreateWin() 
   //this.prevwndproc = 0     
   this.VertAlign = $alvTop
   this.HorzAlign = $alhLeft
     
   
   
   return this
}

method vVEEdit vVEEdit.mCreateWin <alias=vVEEdit_mCreateWin>()
{
   
   this.discr.x = 5 
   this.discr.y = 5   
   this.brush = CreateSolidBrush( GetSysColor( 13))//0xFF00 )//COLOR_HIGHLIGHT
   this.brushgr = CreateSolidBrush( GetSysColor( 16) )//0x666666 ) //COLOR_BTNSHADOW     
	this.pen = CreatePen( $PS_INSIDEFRAME	| $PS_SOLID, 1, 0xFF00 )   
   
  	//gclass_register( "GWUp", 0, 0, 0, 0, gwapp, 
   //             &gw_app, &gwapp_setnotify, &gwapp_getnotify )	
   
   this.CreateWin( "GVTr".ustr(), $WS_EX_TRANSPARENT, $WS_TABSTOP | $WS_VISIBLE | $WS_CHILD /*| $WS_CLIPSIBLINGS*/ )
   this.prevwndproc = -1
   this->vCtrl.mCreateWin() 
   //this.prevwndproc = 0
   //this.Caption = "wup".ustr()
   /*this.hwnd = CreateWindowEx(  $WS_EX_TRANSPARENT , "GVUp".ustr().ptr(), "wup".ustr().ptr(),                    
      $WS_TABSTOP | $WS_VISIBLE | $WS_CHILD , 
      0, 0, 300, 300, this.p_owner->vCtrl.hwnd, 0, 0, &this )*/     
   //win_customproc( this.hwnd, &upproc )
   SetParent( this.hwnd, this.Owner->vCtrl.hwnd )
        
   //this.wdown = &newcomp( vVEFrame, this )
   this.wdown = &this.Owner.CreateComp( vVEFrame )
   this.wdown->vVEFrame.WE = &this
   //this.wdown = &this.CreateComp( vVEFrame )   
   //SetParent( this.wdown->vVEFrame.hwnd, this.Owner->vCtrl.hwnd )
   //SetWindowPos( this.wdown->vVEFrame.hwnd, 0, 0, 0, 0, 0, $SWP_NOACTIVATE | $SWP_NOMOVE | $SWP_NOSIZE )   
   this.VertAlign = $alvClient
   this.HorzAlign = $alhClient
   /*
   .panVis.Owner = this
   .panVis.VertAlign = $alvTopBottom
   .panVis.Top = 0
   .panVis.Bottom = 100
   .panVis.HorzAlign = $alhClient   
   
   .panNoVis.Owner = this
   .panNoVis.Height = .panVis.Bottom
   .panNoVis.Bottom = 0 
   .panNoVis.VertAlign = $alvBottom
   .panNoVis.HorzAlign = $alhClient   
   */
   //gui_showapp( wup, $SW_MAXIMIZE, 0 )   
   //DeleteObject( brush )
   //DeleteObject( pen )
   //gui_deinit()
   return this
}


property vComp vVEPanel.Selected()
{
   return .pSelected->vComp 
}

property vVEPanel.Selected( vComp newcomp )
{   
   uint curcomp as newcomp
   while !curcomp.p_designing
   {
      curcomp as curcomp.Owner
      if &curcomp == &this : return
   } 
   if curcomp.p_designing 
   {      
      if .pSelected != &curcomp
      {
         if curcomp    
         {
            //.pSelected != &newcomp
            .pSelected = &curcomp         
            //this.refresh()
            if curcomp.TypeIs( vVirtCtrl )
            {         
               .NoVisList.Selected = 0->LVRow
               .WE.select( curcomp )
            }  
            else
            {               
               .WE.select( 0->vComp )               
               foreach item, .NoVisList.Rows
               {             
                  if item.Tag == &curcomp
                  {                   
                     .NoVisList.Selected = item->LVRow                   
                     break
                  }
               }    
            }
         }
         else
         {
            .WE.select( 0->vComp )
         }
      }
      this.onSelect.run()
   }
}

method vVEPanel.WESelect <alias=vVEPanel_WESelect> ( evparEvent ev )
{
   this.onSelect.run()
   //.Selected = .WE.winn->vComp  
}

method vVEPanel.WEQueryCreate <alias=vVEPanel_WEQueryCreate> ( evparQueryCreate  evpQ )
{
   .onQueryCreate.run( evpQ ) 
}

  

method vVEPanel.BeforeScroll <alias=vVEPanel_BeforeScroll> ( evparQuery  pQ )
{
   .WE.Visible =0     
}

method vVEPanel.AfterScroll <alias=vVEPanel_AfterScroll> ( evparEvent ev )
{
   .WE.Visible =1    
}


method vVEPanel.NoVisList_Select <alias=vVEPanel_NoVisList_Select> ( /* vComp sender,*/ evparValUint ea )  
{
   uint comp as  ea.val->LVRow.Tag->vComp
   if &comp
   {
      //.VEPanel.WE.select( comp )
      
      this.Selected = comp
   }
}

/*method vVEPanel.NoVisList_Focus <alias=vVEPanel_NoVisList_Focus> (eventuint ev) 
{
   if ev.val 
   {
      if &this.NoVisList.Selected()
      {
         uint comp as this.NoVisList.Selected.Tag->vComp
         if &comp
         {
            //.VEPanel.WE.select( comp )
            this.Selected = comp            
         }         
      }
   }   
}
*/
method vVEPanel.DblClick()
{
   evparValUint eu
   eu.val = &.Selected()
   .OnDblClick.run( eu )   
}

method uint vVEPanel.Mouse <alias=vVEPanel_Mouse> (/*vComp sender,*/evparMouse evm) 
{
   if evm.evmtype == $evmLDbl && &.Selected()
   {  
      .DblClick()
   }
   return 0   
}

method vVEPanel.NoVisList_Key <alias=vVEPanel_NoVisList_Key> (/*vComp sender,*/evparKey evk) 
{
   if evk.evktype == $evkDown && evk.key == $VK_DELETE && &.NoVisList.Selected()
   {        
      uint owner as .Selected.Owner
      uint curcomp as .Selected
      .NoVisList.Selected.Del()
      if ( !&.NoVisList.Selected() )
      {  
         .Selected = owner
      }      
      curcomp.DestroyComp()
   }   
}

method vVEPanel.Update()
{
   .NoVisList.Rows.Clear()   
   foreach comp, .VisPanel.Comps[0]->vForm.Comps
   {
      comp as vComp              
      if !comp.TypeIs( vCtrl  ) 
      {
         uint row as .NoVisList.Rows.Append( )
         row.Item.Label = comp->vComp.Name.ustr()
         row.Tag = &comp    
         //.NoVisList.Append( comp->vComp.Name.ustr(), &comp )
      }
   } 

}

method vVEPanel.mDesChanging <alias=vVEPanel_mDesChanging>( vCtrl ctrl )
{   
   if this.WE.winn
   {
      this.WE.wdown->vCtrl.Visible = 0
      UpdateWindow( this.WE.wdown->vCtrl.hwnd )
      if this.WE.winn->vComp.TypeIs( vCtrl )
      {
         UpdateWindow( this.WE.winn->vCtrl.hwnd )
      }
      else
      {
         UpdateWindow( this.WE.winn->vVirtCtrl.Owner->vCtrl.hwnd )
      }
   }
}

method vVEPanel.mDesChanged <alias=vVEPanel_mDesChanged>( vCtrl ctrl )
{

   if ctrl.TypeIs( vForm ) && !.flgDesChanged 
      {
         .flgDesChanged = 1
         if ctrl.HorzAlign == $alhLeft
         {
            this.VisPanel.HorzRange = ctrl.Width//this.WE.winn->vCtrl.Width
         }
         else : this.VisPanel.HorzRange = 0
         
         if ctrl.VertAlign == $alvTop
         {
            this.VisPanel.VertRange = ctrl.Height//this.WE.winn->vCtrl.Height
         }
         else : this.VisPanel.VertRange = 0
         .flgDesChanged = 0
      }
   if this.WE.winn
   {
      this.WE.green()
      this.WE.wdown->vCtrl.Visible = 1      
      //UpdateWindow( this.winn->vCtrl.hwnd )    
      //WE.Visible = 1
      //WE.SetFocus()
      if &ctrl == &this.WE.winn//Selected() 
      {      
         this.WE.onSelect.run()
      }
   }   
   
} 

method vVEPanel vVEPanel.mCreateWin <alias=vVEPanel_mCreateWin>()
{
   this->vPanel.mCreateWin()
      
   with .NoVisList
   {      
      
      .Owner = this
      .Height = 100
      .Top = this.Height - .Height
      .HorzAlign = $alhClient
      .VertAlign = $alvBottom
      .ShowSelection = 1
      .ListViewStyle = $lvsList
      .OnAfterSelect.Set( this, vVEPanel_NoVisList_Select )
      //.onfocus.set( this, vVEPanel_NoVisList_Focus )
      .OnMouse.Set( this, vVEPanel_Mouse )
      .OnKey.Set( this, vVEPanel_NoVisList_Key )
   }
   /*with .TopPanel
   {
      .Owner = this      
      .Top = 0
      .HorzAlign = $alhClient
      .VertAlign = $alvTopBottom
      .Bottom = this.NoVisList.Height  
   }*/
   with .VisPanel
   {  
      .Owner = this//.TopPanel     
      //.Top = 0
      //.Name = "xxxxxxxx\n" 
      .AutoScroll = 0//1
      .HorzAlign = $alhClient
      .VertAlign = $alvTopBottom
      .Bottom = this.NoVisList.Height
      
      .OnBeforeScroll.Set( this, vVEPanel_BeforeScroll )
      .OnAfterScroll.Set( this, vVEPanel_AfterScroll )      
   } 
   
   .WE.VEPanel = &this
   .WE.VisPanel = &.VisPanel
   .WE.Owner = .VisPanel
   
   .WE.onSelect.Set( this, vVEPanel_WESelect )
   .WE.onQueryCreate.Set( this, vVEPanel_WEQueryCreate )
   .WE.OnMouse.Set( this, vVEPanel_Mouse )
   return this
}
        
/*------------------------------------------------------------------------------
   Registration
*/
method vVEFrame vVEFrame.init()
{    
   this.pTypeId = vVEFrame
   return this
}

method vVEEdit vVEEdit.init()
{
   this.pTypeId = vVEEdit
   this.pCanContain = 1
   this.pTabStop = 1
   return this
}

method vVEPanel vVEPanel.init()
{
   this.pTypeId = vVEPanel
   this.pCanContain = 1
   this.pTabStop = 1
   return this
}

func init_vVEEdit <entry>()
{
   WNDCLASSEX visclass
   ustr classname = "GVTr"    
   with visclass
   {
      .cbSize      = sizeof( WNDCLASSEX )
      .style       = $CS_HREDRAW | $CS_VREDRAW | $CS_DBLCLKS 
      .lpfnWndProc = callback( &myproc, 4 )
      .cbClsExtra  = 0
      .cbWndExtra  = 0
      .hInstance   = GetModuleHandle( 0 )
      .hIcon       = 0
      .hCursor     = LoadCursor( 0, $IDC_ARROW )
      .hbrBackground = 0
      .lpszMenuName  = 0
      .lpszClassName = classname.ptr()
      .hIconSm     = 0
   } 
   uint hclass = RegisterClassEx( &visclass )
   
   regcomp( vVEEdit, "vVEEdit", vCtrl, $vCtrl_last,      
      %{ %{$mCreateWin,          vVEEdit_mCreateWin},
         %{$mKey,                vVEEdit_mKey}
       },
      %{ %{$WM_LBUTTONDOWN, vVEEdit_wmlbuttondown},
         %{$WM_LBUTTONUP, vVEEdit_wmlbuttonup},
         %{$WM_MOUSEMOVE ,  vVEEdit_wmmousemove},
         %{$WM_LBUTTONDBLCLK, vVEEdit_wmlbuttondblclk},
         //%{$WM_MBUTTONDBLCLK,  vVEEdit_wmlbuttondblclk},
         %{$WM_CAPTURECHANGED, vVEEdit_wmcapturechanged} /*,
         %{$WM_PAINT ,  vVEEdit_wmpaint}          */        
       })
  
   regcomp( vVEFrame, "vVEFrame", vCtrl, $vCtrl_last,
      %{ %{$mCreateWin,          vVEFrame_mCreateWin}/*,
         %{$mKey,                vVEFrame_mKey}*/},
       %{ %{$WM_LBUTTONDOWN, vVEFrame_wmlbuttondown},
         %{$WM_MOUSEMOVE ,  vVEFrame_wmmousemove},
         %{$WM_PAINT ,  vVEFrame_wmpaint}
                    
       })
       
   regcomp( vVEPanel, "vVEPanel", vPanel, $vCtrl_last,
      %{ %{$mCreateWin,          vVEPanel_mCreateWin},
         %{$mDesChanging,  vVEPanel_mDesChanging },
         %{$mDesChanged,  vVEPanel_mDesChanged }},
      0->collection )
      
}