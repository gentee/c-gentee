include {
   "form.g"
   "treeview.g"
}


define {
   mSelectComp = $vForm_last
   
   vCompEditForm_last 
} 


type vMenuDesign <inherit=vForm>
{   
   vTreeView tv
   vBtn      bAdd
   vBtn      bAddChild
   vBtn      bDel
   uint      flgnew
   uint      curitem
   uint      flgediting
   
   uint      Menu
   uint      MainForm
   
   //eventQueryCreate OnQueryCreate
   oneventpos OnQueryCreate
   evEvent    OnQuerySelect
   evEvent   OnDestroy
}


method vMenuDesign.NewItem( TVItem newitem )
{ 
   .tv.Selected = newitem   
   .flgnew = 1
   .tv.Edit()
   uint he = FindWindowEx( .tv.hwnd, 0, "Edit".ustr().ptr(), 0 )
   if he
   {      
      .flgediting = 1
      //SendMessage( he, $EM_SETMODIFY, 1, 0 )
      .tv.WinMsg( $WM_COMMAND, $EN_UPDATE << 16, he )
      //SendMessage( .tv.hwnd, $WM_COMMAND, ($EN_CHANGE << 16) /*| 0x01*/, he ) 
   }
   //print( "Newitem 2\n" )
}

method vMenuDesign.bAdd_click <alias=vMenuDesign_bAdd_click> ( evparEvent ev )
{
   uint curitem 
   curitem as this.tv.Selected()
   if &curitem
   {
      //previtem as curitem.Prev
      curitem as curitem.Parent
      //print( "previtem =\( &previtem )\n" )      
   }   
   if !&curitem   
   {      
      curitem as .tv.Root
   }     
   .NewItem( curitem.AppendChild( "New".ustr(), 0 ) )   
}

method vMenuDesign.bIns_click <alias=vMenuDesign_bIns_click> ( evparEvent ev )
{
   uint curitem, previtem as TVItem
   curitem as this.tv.Selected()
   if &curitem
   {
      previtem as curitem.Prev
      curitem as curitem.Parent
     // print( "previtem =\( &previtem )\n" )      
   }   
   if !&curitem   
   {      
      curitem as .tv.Root
   }     
   .NewItem( curitem.InsertChild( "New".ustr(), 0, 0->ustr, previtem ))   
}

method vMenuDesign.bAddChild_click <alias=vMenuDesign_bAddChild_click> ( evparEvent ev )
{
   uint curitem 
   curitem as this.tv.Selected()      
   if !&curitem   
   {      
      curitem as .tv.Root
   }     
   curitem.Expanded = 1
   .NewItem( curitem.AppendChild( "New child".ustr(), 0 ) )    
}

method vMenuDesign.bDel_click <alias=vMenuDesign_bDel_click> ( evparEvent ev )
{
   uint curitem 
   curitem as this.tv.Selected()      
   if &curitem
   {
      if curitem.Tag
      {
         curitem.Tag->vComp.DestroyComp()
      }
      curitem.Del()
   }   
    
}

method vMenuDesign.tv_AfterEdit <alias=MenuDesign_tv_AfterEdit> ( /*vComp sender,*/ evparTVEdit etve )
{  
   .flgediting = 0
   uint curtvitem as etve.Item->TVItem//.tv.Selected
   if .flgnew 
   {
      .flgnew = 0
      if etve.flgCancel || !*etve.NewLabel
      {  
         etve.flgCancel = 1         
         curtvitem.Del()         
      }
      else
      {
         uint owner as vCustomMenu
         if (&curtvitem.Parent()) && (&curtvitem.Parent()) != (&.tv.Root()) 
         {            
            owner as curtvitem.Parent.Tag
         }
         else 
         {              
            owner as .Menu
         } 
         //uint cim as .Owner->newcompdes( vMenuItem, owner )->vMenuItem
         evparQueryCreate eQC
         eQC.Owner = &owner
         eQC.TypeId = vMenuItem
         //print( "1a \(eQC.Owner) \(eQC.TypeId)\n" )         
         .OnQueryCreate.run( eQC )
         //print( "1b\n" )
         uint cim as eQC.NewComp->vMenuItem
         //print( "1c\n" )
         if &cim
         {
            //print( "2 \(curtvitem.Label.str())\n" )
            cim.Caption = etve.NewLabel// curtvitem.Label
            curtvitem.Tag = &cim
            .tv.Selected = 0->TVItem
            .tv.Selected = curtvitem
         }
         else
         {
            //print( "3\n" )
            etve.flgCancel = 1         
            curtvitem.Del()       
         }         
      }
   }
   else
   {
      if !etve.flgCancel
      {
         uint menuitem as .tv.Selected.Tag->vMenuItem
         if &menuitem
         {
            menuitem.Caption = etve.NewLabel
            evparValUint eu
            eu.val = &menuitem
            .OnQuerySelect.run( eu )
         }
      } 
   }
   
}

method vMenuDesign.tv_Key <alias=MenuDesign_tv_Key>( /*vComp sender,*/ evparKey ek )
{
   if ek.evktype == $evkDown
   {      
      switch ek.key 
      {
         case $VK_INSERT: .bIns_click( 0->evparEvent )           
         case $VK_DELETE: .bDel_click( 0->evparEvent )
         case $VK_DOWN
         {           
            //print( "KEY\n" ) 
            if (ek.mstate == $mstShift) || !&(.tv.Selected()) || ( &(.tv.Selected()) == &(.tv.Root.LastChild()) && !&.tv.Root.LastChild.Child() )
            {
               .bAdd_click( 0->evparEvent )
            }
         }
         case $VK_RIGHT
         {            
            if  /*(ek.mstate == $mstCtrl) ||*/ !&(.tv.Selected()) || ( &(.tv.Selected()) && !&(.tv.Selected.Child()) )
            {
               .bAddChild_click( 0->evparEvent )   
            }
         }                  
      }      
   }  
    
}

method vMenuDesign.tv_BeforeSelect <alias=MenuDesign_tv_BeforeSelect>( /*vComp sender,*/ evparQuery etvb )
{
   if .flgediting 
   {
      etvb.flgCancel = 1
   }   
}

method vMenuDesign.tv_Select <alias=MenuDesign_tv_Select>( /*vComp sender,*/ evparValUint etva )
{
   
   //print( "sel 1 \(etva.CurItem) \n" )
   if etva.val 
   {
   //print( "sel 2\n" )
      uint comp
      if comp = etva.val->TVItem.Tag
      {
      //print( "sel \(comp)3\n" )
         evparValUint eu
         eu.val = comp
         .OnQuerySelect.run( eu )
      } 
   }
}

method vMenuDesign.tv_ItemMoved <alias=MenuDesign_tv_ItemMoved>( evparAfterMove evpIM )
{
   uint cur as evpIM.CurItem->TVItem.Tag->vMenuItem
   switch evpIM.Flag
   {
      case $TREE_FIRST :
      case $TREE_LAST  
      {         
         if evpIM.DestItem  
         {          
            uint owner as evpIM.DestItem->TVItem.Tag->vMenuItem            
            if &owner && &owner != &cur.Owner()
            {
               cur.Owner = owner
            }
            else
            {
               cur.CompIndex = *cur.Owner.Comps - 1
            }                       
            
         }
      }
      case $TREE_AFTER :       
      case $TREE_BEFORE
      {         
         if evpIM.DestItem  
         {
            uint next as evpIM.DestItem->TVItem.Tag->vMenuItem
            //uint newidx = next.CompIndex
            uint owner as next.Owner->vMenuItem
            cur.Owner = 0->vComp
            //if &owner && &owner != &cur.Owner()
            //print( "
            {
               cur.Owner = owner
            }
            //else            
            //if next
            {               
               cur.CompIndex = next.CompIndex//newidx 
            } 
         }
      }                  
   }
}

method vMenuDesign.MenuDesign_CloseQuery <alias=MenuDesign_CloseQuery>( evparQuery evpQ )
{
   //print( "CLOSEQUERY\n" )   
   evpQ.flgCancel = 1
   this.DestroyComp()
}

method vMenuDesign vMenuDesign.mCreateWin <alias=vMenuDesign_mCreateWin>( )   
{   
   this->vForm.mCreateWin()
   ustr ustmp
   uint comp
	comp as this
   //print( "create des 1\n" )
	with comp
	{	
		.Caption="Menu Designer".ustr()		
		.Height=300				
		.Visible=0
		.Width=200
      .OnCloseQuery.Set( this, MenuDesign_CloseQuery )
	}
	comp as this.tv
	comp.Owner = this
	with comp
	{
	   .HorzAlign = $alhClient
      .VertAlign = $alvTopBottom
      .Bottom = 25
      .ShowSelection = 1      
      .RowSelect = 1
      .LabelEdit = 1
      .AutoDrag = 1
      .OnAfterEdit.Set( this, MenuDesign_tv_AfterEdit )
      .OnKey.Set( this, MenuDesign_tv_Key )
      .OnBeforeSelect.Set( this, MenuDesign_tv_BeforeSelect )
      .OnAfterSelect.Set( this, MenuDesign_tv_Select )
      .OnBeforeMove.Set( this, MenuDesign_tv_ItemMoved )      
	}
   uint left = 0
   uint width = 70
   comp as this.bAdd
	comp.Owner = this
	with comp
	{	   
      .VertAlign = $alvBottom
      .Caption = "New".ustr()
      .Bottom = 0
      .Left = left
      .Width = width
      left += .Width
      .OnClick.Set(this,vMenuDesign_bAdd_click)
	}
   comp as this.bAddChild
	comp.Owner = this
	with comp
	{	   
      .VertAlign = $alvBottom
      .Caption = "New child".ustr()
      .Bottom = 0
      .Left = left
      .Width = width
      left += .Width
      .OnClick.Set(this,vMenuDesign_bAddChild_click)
	}
   comp as this.bDel
	comp.Owner = this
	with comp
	{	   
      .VertAlign = $alvBottom
      .Caption = "Delete".ustr()
      .Bottom = 0
      .Left = left
      .Width = width
      left += .Width
      .OnClick.Set(this,vMenuDesign_bDel_click)
	}
	//print( "create des 10\n" )
	return this
}

method vMenuDesign vMenuDesign.init( )
{
   this.pTypeId = vMenuDesign         
   return this
}

method vMenuDesign.mSelectComp <alias=vMenuDesign_mSelectComp> ( vComp newcomp )
{
//print( "menudes 0 \(&this)\n" )
   if &newcomp 
   {      
   //print( "menudes 1\n" )
      uint tvitem as .tv.Root()       
      while tvitem
      {
      //print( "menudes 2\n" )         
         if tvitem.Tag == &newcomp
         {       
            tvitem.Label = newcomp->vMenuItem.Caption
            return 
         }         
         tvitem as tvitem.NextInList         
      
      }         
      this.DestroyComp()         
   }
}

method vCustomMenu.ToMenuDesign( TVItem ownertvitem )
{
   uint i
   //print( "tomenu \(*.Comps)\n" )
   fornum i, *.Comps
   {
      uint submenu as .Comps[i]->vMenuItem
      //print( "submenu \(.Comps[i]->vComp.Name)\n" )
      submenu.ToMenuDesign( ownertvitem.AppendChild( submenu.Caption, &submenu ) )
   }
}



method vForm vCustomMenu.Design( vForm mainform, uint QueryCreate, uint QuerySelect, uint CompEditDelete )
{
   uint win
   //print( "zdes 1\n" )
   /*win as new( vMenuDesign )->vMenuDesign   
   win.fDynamic = 1  
   win.flgpopup = 1*/   
   win as 0->vComp.CreateComp( vMenuDesign )->vMenuDesign   
   //win.flgpopup = 1
   //win.Owner = mainform
   
   //win as mainform.CreateComp( vMenuDesign )->vMenuDesign
   //SetParent( win.hwnd, 0 ) 
   //SetWindowPos(win.hwnd, $HWND_TOPMOST, 0, 0, 0, 0, $SWP_NOMOVE |
   //       $SWP_NOSIZE | $SWP_NOACTIVATE);
   //print( "zdes 2\(&mainform), \(QueryCreate) \n" )
   win.OnQueryCreate.Set( mainform, QueryCreate )   
   win.OnQuerySelect.Set( mainform, QuerySelect )
   //print( "zdes 4\n" )
   win.OnDestroy.Set( mainform, CompEditDelete )
   //print( "zdes 5\n" )
      
   
   //print( "zdes 6 \(&this)\n" )
   win.Menu = &this
   //print( "zdes 7 \( &win.tv->vTreeView.Root() )\n" )   
   win.ShowPopup( mainform )
   
   this->vMenuItem.ToMenuDesign( win.tv->vTreeView.Root )
   
   
   //win.ShowModal()
   //win.Visible = 1   
   //print( "zdes 8\n" )
   return win   
}

method vMenuDesign.mPreDel <alias=vMenuDesign_mPreDel>
{
//print( "mPreDel menudesign 1\n" )
   .OnDestroy.run( )
   this->vForm.mPreDel()
//print( "mPreDel menudesign 2\n" )      
}

func init_vMenuDesign <entry>()
{
   regcomp( vMenuDesign, "vMenuDesign", vForm, $vCompEditForm_last,
      %{ %{$mCreateWin,     vMenuDesign_mCreateWin},
         %{$mSelectComp,    vMenuDesign_mSelectComp},
         %{$mPreDel,        vMenuDesign_mPreDel }},
      0->collection )     
}