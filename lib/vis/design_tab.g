include {
   "form.g"
   "listview.g"
}


/*define {
   mSelectComp = $vForm_last
   
   vCompEditForm_last 
} 
*/

type vTabDesign <inherit=vForm>
{   
   vListView lv
   vBtn      bAdd
   vBtn      bAddChild
   vBtn      bDel
   uint      flgnew
   uint      curitem
   uint      flgediting
   
   uint      Tab
   uint      MainForm
   
   //eventQueryCreate OnQueryCreate
   oneventpos OnQueryCreate
   evEvent    OnQuerySelect
   evEvent   OnDestroy
}


method vTabDesign.NewItem( /*LVRow newitem*/LVRow curitem )
{ 
   .lv.Selected = .lv.Rows.Insert( *.lv.Rows )//.lv.InsertItem( "New".ustr(), 0, curitem )
   .lv.Cells( .lv.Selected.Idx, 0 ) = "New".ustr() 
   //.lv.Selected.Tag = 0
    
   .flgnew = 1
   .lv.Edit()   
   uint he = FindWindowEx( .lv.hwnd, 0, "Edit".ustr().ptr(), 0 )
   if he
   {      
      .flgediting = 1      
      .lv.WinMsg( $WM_COMMAND, $EN_UPDATE << 16, he )       
   }   
}

method vTabDesign.bAdd_click <alias=vTabDesign_bAdd_click> ( evparEvent ev )
{
   /*uint curitem 
   curitem as this.lv.Selected()
   if &curitem
   {      
      curitem as curitem.Parent            
   }   
   if !&curitem   
   {      
      curitem as .lv.Root
   }     
   .NewItem( curitem.AppendChild( "New".ustr(), 0 ) )*/
   .NewItem( 0xFFFFFFFF->LVRow )
}

method vTabDesign.bIns_click <alias=vTabDesign_bIns_click> ( evparEvent ev )
{
   
   
   uint curitem, previtem as LVRow
   curitem as this.lv.Selected()
   if &curitem
   {
      curitem as curitem.Prev               
   }   
   .NewItem( curitem )     
   /*.NewItem( curitem.InsertChild( "New".ustr(), 0, previtem ))*/   
}


method vTabDesign.bDel_click <alias=vTabDesign_bDel_click> ( evparEvent ev )
{
   uint curitem 
   curitem as this.lv.Selected()      
   if &curitem
   {
      uint comp as curitem.Tag->vComp
      curitem.Del()
      if &comp//curitem.Tag
      {
         comp.DestroyComp()
         //curitem.Tag->vComp.DestroyComp()
      }
      
   }    
}

method vTabDesign.lv_AfterEdit <alias=vTabDesign_lv_AfterEdit> ( /*vComp sender,*/ evparTVEdit etve )
{  
   .flgediting = 0
   uint curLVRow as .lv.Selected
   
   if .flgnew 
   {
      
      .flgnew = 0
      if etve.flgCancel || !*etve.NewLabel
      {  
         etve.flgCancel = 1         
         curLVRow.Del()         
      }
      else
      {
              
         /*uint owner as vCustomMenu
         if (&curLVRow.Parent()) && (&curLVRow.Parent()) != (&.lv.Root()) 
         {            
            owner as curLVRow.Parent.Tag
         }
         else 
         {              
            owner as .Menu
         }*/
         
         evparQueryCreate eQC
         eQC.Owner = this.Tab
         eQC.TypeId = vTabItem
              
                      
         .OnQueryCreate.run( eQC )
                  
         uint cim as eQC.NewComp->vTabItem
         //uint cim as this.Tab->vTab.CreateComp( vTabItem )->vTabItem
                  
         if &cim
         {
            cim.Index = .lv.Selected.Idx                   
            cim.Caption = etve.NewLabel// curLVRow.Label            
            curLVRow.Tag = &cim            
            .lv.Selected = 0->LVRow
            .lv.Selected = curLVRow
         }
         else
         {            
            etve.flgCancel = 1         
            curLVRow.Del()       
         }                  
      }
   }
   else
   {
      if !etve.flgCancel
      {
         uint tabitem as .lv.Selected.Tag->vTabItem
         if &tabitem
         {
            tabitem.Caption = etve.NewLabel
            evparValUint eu
            eu.val = &tabitem
            .OnQuerySelect.run( eu )
         }
      } 
   }   
}

method vTabDesign.lv_Key <alias=vTabDesign_lv_Key>( /*vComp sender,*/ evparKey ek )
{
   if ek.evktype == $evkDown
   {      
      switch ek.key 
      {
         case $VK_INSERT: .bIns_click( 0->evparEvent )           
         case $VK_DELETE: .bDel_click( 0->evparEvent )
         case $VK_DOWN
         {   
            if !&(.lv.Selected()) || !&.lv.Selected().Next//( &(.lv.Selected()) == &(.lv.Root.LastChild()))
            {
               .bAdd_click( 0->evparEvent )
            }
         }            
      }      
   }   
}

/*method vTabDesign.lv_BeforeSelect <alias=TabDesign_lv_BeforeSelect>(  evparTVBefore etvb )
{   
   if ( !etvb.CurItem && *.lv.gttree.root() ) || 
      .flgediting 
   {
      etvb.flgCancel = 1
   }   
}*/

method vTabDesign.lv_Select <alias=TabDesign_lv_Select>( /*vComp sender,*/ evparValUint etva )
{
   if etva.val  
   {    
      uint comp
      if comp = etva.val->LVRow.Tag
      {
         evparValUint eu
         eu.val = comp         
         comp->vTabItem.Owner->vTab.CurIndex = comp->vTabItem.Index         
         .OnQuerySelect.run( eu )
      } 
   }
}

method vTabDesign.lv_ItemMoved <alias=TabDesign_lv_ItemMoved>( evparAfterMove evpIM )
{
   uint cur as evpIM.CurItem->LVRow.Tag->vTabItem
   switch evpIM.Flag
   {
      case $TREE_FIRST :
      case $TREE_LAST  
      {
         cur.Index = *cur.Owner->vTab.Comps - 1           
      }
      case $TREE_AFTER :       
      case $TREE_BEFORE
      {  
         if evpIM.DestItem  
         {
            uint next as evpIM.DestItem->LVRow.Tag->vTabItem
            cur.Index = *cur.Owner->vTab.Comps - 1                       
            if next
            {               
               cur.Index = next.Index //- 1  
            } 
         }
      }                  
   }
}

method vTabDesign.CloseQuery <alias=TabDesign_CloseQuery>( evparQuery evpQ )
{
   evpQ.flgCancel = 1
   this.DestroyComp()
}

method vTabDesign vTabDesign.mCreateWin <alias=vTabDesign_mCreateWin>( )   
{   
   this->vForm.mCreateWin()
   ustr ustmp
   uint comp
	comp as this   
	with comp
	{	
		.Caption="Tab Designer".ustr()		
		.Height=300				
		.Visible=0
		.Width=200
      .OnCloseQuery.Set( this, TabDesign_CloseQuery )
	}
	comp as this.lv
	comp.Owner = this
	with comp
	{
	   .HorzAlign = $alhClient
      .VertAlign = $alvTopBottom
      .Bottom = 25
      .ShowSelection = 1
      .ListViewStyle = $lvsList
      .LabelEdit = 1
      .OnAfterEdit.Set( this, vTabDesign_lv_AfterEdit )
      .OnKey.Set( this, vTabDesign_lv_Key )
      //.OnBeforeSelect.Set( this, TabDesign_lv_BeforeSelect )
      .OnAfterSelect.Set( this, TabDesign_lv_Select )
      .OnAfterMove.Set( this, TabDesign_lv_ItemMoved )
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
      .OnClick.Set(this,vTabDesign_bAdd_click)
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
      .OnClick.Set(this,vTabDesign_bDel_click)
	}	
	return this
}

method vTabDesign vTabDesign.init( )
{
   this.pTypeId = vTabDesign         
   return this
}

method vTabDesign.mSelectComp <alias=vTabDesign_mSelectComp> ( vComp newcomp )
{
   if &newcomp 
   {             
      uint curcomp as newcomp
      while &curcomp
      {         
         if &curcomp == this.Tab 
         {
            uint i
            fornum i = 0, *.lv.Rows 
            //uint LVRow as .lv.Rows[0]//.Child()            
            //while &LVRow
            { 
               uint row as .lv.Rows[i]              
               if row.Tag == &newcomp
               {  
                  row.Item.Label = newcomp->vTabItem.Caption                   
               }         
              // LVRow as LVRow.Next()               
            }            
            return
         } 
         curcomp as curcomp.Owner
      }
      this.DestroyComp()         
   }
}

method vTab.ToTabDesign( vTabDesign tdes )
{
   uint i   
   fornum i, *.Comps
   {
      uint tabitem as .Comps[i]->vTabItem     
      uint row as tdes.lv.Rows.Append()
      row.Item.Label( tabitem.Caption )
      row.Tag = &tabitem 
   }
}



method vForm vTab.Design( vForm mainform, uint QueryCreate, uint QuerySelect, uint CompEditDelete )
{
   uint win
   
   win as 0->vComp.CreateComp( vTabDesign )->vTabDesign
   win.FormStyle = $fsPopup
   win.Owner = mainform   
   
   win.OnQueryCreate.Set( mainform, QueryCreate )   
   win.OnQuerySelect.Set( mainform, QuerySelect )
   
   win.OnDestroy.Set( mainform, CompEditDelete )
       
   win.Visible = 1
   
   win.Tab = &this
   
   this.ToTabDesign( win)
   
   return win   
}

method vTabDesign.mPreDel <alias=vTabDesign_mPreDel>
{
   .OnDestroy.run( )
   this->vForm.mPreDel()
      
}

func init_vTabDesign <entry>()
{
   regcomp( vTabDesign, "vTabDesign", vForm, $vCompEditForm_last,
      %{ %{$mCreateWin,     vTabDesign_mCreateWin},
         %{$mSelectComp,    vTabDesign_mSelectComp},
         %{$mPreDel,        vTabDesign_mPreDel }},
      0->collection )     
}