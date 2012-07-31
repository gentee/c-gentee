method myform.resload()
{
   //this.btn1.caption = " textres( 143 )"
   //image = imageres(10)
   
}

method myform myform.compinit()
{   
  
   this.width = 400   
   this.height = 400   
   //this.p_typeid = myform
   this.caption = "Gentee Forms Designer (Demo version 0.1)".ustr()
   //this.onresize = getid( "@m_resize", %{myform} )
   
   panleft = &newcomp( vPanel, (&this)->vcomp )
   uint xpanleft = panleft
   xpanleft as vPanel 
   xpanleft.width = 203  
   xpanleft.x = 0   
   xpanleft.Border = $brdNone
   xpanleft.vertalign = $alvClient
   xpanleft.horzalign = $alhLeft//$ALIGN_VTOPBOTTOMOFF//$ALIGN_VCLIENT   
      
   //uint xpanright = &newcomp( vPanel, this )//(&this)->vcomp )
   this.panright.owner = this
   uint xpanright as this.panright
   xpanright.x = xpanleft.x + xpanleft.width + 4
   xpanright.vertalign = $alvClient
   xpanright.horzalign = $alhLeftRight
   xpanright.right = 0
   xpanright.name = "right"
      
   
   uint t as newcomp( vTab, panleft->vcomp )->vTab      
   t.y = 0
   t.height = 85
   t.horzalign = $alhClient   
   t.vertalign = $alvTop   
   /*uint tp as newcomp( vTabPage, t )->vTabPage   
   tp.caption = "Controls"   
   this.bt_arrow.owner = tp    
   uint bt_bt as this.bt_arrow
   bt_bt.caption = " "   
   bt_bt.btnstyle = $bsAsRadioBtn
   bt_bt.y =0
   bt_bt.x=0
   bt_bt.height = 20 
   bt_bt.width = 65
   bt_bt.onclick.set( this, "bt_arrowc" )
        
   
   //bt_bt as newcomp( vBtn, panleft->vcomp )
   this.bt_btn.owner = tp 
   bt_bt as this.bt_btn   
   bt_bt.x=65
   bt_bt.y = 0
   bt_bt.height =20
   bt_bt.width =65   
   bt_bt.caption = "Btn"   
   bt_bt.onclick.set( this, "bt_btnc" )
   //this.bt_arrow.checked = 1    
   bt_bt.btnstyle = $bsAsRadioBtn
   
   
   this.bt_panel.owner = tp
   bt_bt as this.bt_panel
   bt_bt.x=130
   bt_bt.y = 0
   bt_bt.height =20
   bt_bt.width =65
   bt_bt.caption = "Panel"   
   bt_bt.onclick.set( this, "bt_panelc" )
   bt_bt.btnstyle = $bsAsRadioBtn
      
   this.bt_edit.owner = tp
   bt_bt as this.bt_edit
   bt_bt.x=0
   bt_bt.y = 20
   bt_bt.height =20
   bt_bt.width =65
   bt_bt.caption = "Edit"   
   bt_bt.onclick.set( this, "bt_editc" )
   bt_bt.btnstyle = $bsAsRadioBtn
   
   uint h = 20
   uint y = 90
   bt_bt as newcomp( vBtn, panleft->vcomp )->vBtn
   bt_bt as vBtn   
   bt_bt.y = y
   bt_bt.height =h   
   bt_bt.caption = "Build"
   bt_bt.vertalign = $alvTop
   bt_bt.horzalign = $alhLeftRight
   bt_bt.x=10
   bt_bt.right =10
   bt_bt.onclick.set( this, "build" )//getid( "@build", %{myform} )
   
   y += h
   bt_bt as this.bsave
   bt_bt.owner = panleft->vcomp   
   bt_bt.y = y
   bt_bt.height =h   
   bt_bt.caption = "Save"
   bt_bt.vertalign = $alvTop
   bt_bt.horzalign = $alhLeftRight
   bt_bt.x=10
   bt_bt.right =10
   bt_bt.onclick.set( this, "save" )// =getid( "@save", %{myform} )
   
   y += h
   bt_bt as this.bopen
   bt_bt.owner = panleft->vcomp  
   bt_bt.y = y
   bt_bt.height =h   
   bt_bt.caption = "New"
   bt_bt.vertalign = $alvTop
   bt_bt.horzalign = $alhLeftRight
   bt_bt.x=10
   bt_bt.right =10
   bt_bt.onclick.set( this, "new" )// =getid( "@open", %{myform} )
   
   y += h
   bt_bt as this.babout
   bt_bt.owner = panleft->vcomp  
   bt_bt.y = y
   bt_bt.height =h   
   bt_bt.caption = "About"
   bt_bt.vertalign = $alvTop
   bt_bt.horzalign = $alhLeftRight
   bt_bt.x=10
   bt_bt.right =10
   bt_bt.onclick.set( this, "about" )
   
   this.edcur.owner = panleft->vcomp
   this.edcur.horzalign = $alhClient
   this.edcur.readonly = 1
   this.edcur.y = 175
   this.edcur.height = 24
   
   t as newcomp( vtab, panleft->vcomp )->vtab
      
   t.y = 200
   t.height = 200
   t.horzalign = $alhClient   
   t.vertalign = $alvTopBottom
   
   tp as newcomp( vtabpage, t )->vtabpage
 
   //print( "\(&tp)\n" )
   tp.caption = "Properties"   
  
   uint x as newcomp(vproplist, tp)->vproplist
   this.prl = &x         
   x.horzalign = $alhClient
   x.vertalign = $alvClient
   plist = &x
   x.onprop.set( this, "propset" )
   x.ongetlist.set( this, "getlist" )
     
   uint tpe as newcomp( vtabpage, t )->vtabpage
   tpe.caption = "Events"   
   //tpe.pageidx = 0
   x as newcomp(vproplist, tpe)->vproplist  
   this.evl = &x 
   x.horzalign = $alhClient
   x.vertalign = $alvClient//TopBottom   
   x.onprop.set( this, "eventset" )
   x.ondblclick.set( this, "eventdblclick" )
   //x.ongetlist.set( this, "getlist" )
     
   cm.addcomp( "vctrl", vctrl )
   cm.addcomp( "vBtn",  vBtn )
   cm.addcomp( "vPanel", vPanel )   
   cm.addcomp( "vEdit", vEdit )
   //cm.addcomp( "vlistbox", vlistbox )
   cm.addcomp( "vform", vform )
   */
   /*uint xwin as newcompdes( vform, xpanright )->vctrl
   edform = &xwin   
   xwin.name = this.getnewname( xwin->vform.typename )
   xwin.p_designing = 1
   xwin.x = 0
   xwin.y = 0*/ 
   /*wined = &newcomp( vwined, xpanright )   
   wined->vwined.onselect.set( this, "ctrlselect" )// =getid( "@ctrlselect", %{myform} )   
   wined->vwined.ondelete.set( this, "ctrldelete" )
   wined->vwined.onnew.set( this, "wineditnew" )
   this.srcfile = "example"
   wined->vwined.select( edform->vctrl )*/   
//print( "xxx\n" )
//   this.load()
//print( "xxx 2\n" ) 
   this.bt_arrow.Checked = 1
   return this
}