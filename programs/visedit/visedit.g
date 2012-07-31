#charoem = 1
#include = %EXEPATH%\lib\stdlib.ge
#libdir = %EXEPATH%\lib
#libdir1 = %EXEPATH%\..\lib\vis
#silent = 1
#output = %EXEPATH%\visedit.exe
#exe=1 d g
//#debug=1
//#asm=1
//#!gentee.exe -f -p exe "%1"
//#wait=1


type mytype
{  
//uint prop
}


property uint mytype.prop
{
   return 0
}

method uint mytype.x
{
   uint z = this.prop
   this.prop
   //100~~100
   //xxx   
   return 0
}


/*property zz.y( uint x, y, s)
{
}*/

/*method zz.y( uint x )
{
}*/
/*
func test<main>
{
   zz x
   uint p
   //p = &x
   //x.y
 //x.y  
   p = &x.y+1
   getch()
     
}*/

include {
   "..\\..\\lib\\ini\\ini.g"
//   "..\\stdlib\\stdlib.ge"
//   "test1.g"
}
func z
{
   min(10,1)
}


define {
   DESIGNING = 1
}
ifdef !$DESIGNING 
{
   sss
 //  $aaaaaaa
}
define {   
   COMP = 0
}

include {
//   "..\\stdlib\\stdlib.g" 
   //"events.g"    
   "app.g"
   "images.g"   
   "btn.g"
   "panel.g"
   "scrollbox.g"
   "edit.g"
   "menu.g"
   "popupmenu.g"
   "treeview.g"
   "listview.g"
   "tab.g"
   "combobox.g"   
   "dialogs.g"
   "label.g"
   "labeled.g"
   "picture.g"
   "url.g"
   "btnpic.g"
   "tray.g"
   "splitter.g"
   "toolbar.g"
   "header.g"
   "datetimepick.g"
   "progressbar.g"
   
   "dlgbtns.g"
   
   "btnsys.g"
   "winedit.g"
   "proplist.g"   
   //"..\\gt\\gt.g"
}


ifdef $DESIGNING {
   include { 
   "design_menu.g"
   "design_tab.g" 
   }   
}

global {
   uint mi0
   uint mi1
   uint ed1
   uint ed2
   uint pm
   uint tt
   uint cbb
}

type project 
{
   str filename
   str runfile
   str resources
}

type myform <inherit=vForm>
{
   project   prj   
   //str srcfile
   vPropList props  
   vPropList events

   vMenu MainMenu 

   vTreeView objtv    //Список компонентов для добавления
   vEdit     edcurcomp //Текущий выбранный элемент
   
   uint   edform
   //vPropList x
   //vBtn btArrow
   uint curaddcomp //Тип выбранного объекта для добавления
   vOpenSaveDialog dlgOpen
   uint   desform  //Дополнительное окно редактирования
   
   str      gffile      //Содержимое gf файла
   str      filename    //Имя файла для сохранения
   filetime ftgf        //Время изменения gf файла
   uint     flgsaved    //Файлы были сохранены
   uint     flgchanged  //Были изменения
   uint     flggfchanged //Были изменения в gf файле
   str      curdir //текущая директория
   //vMenuDesign md
   //vLabel  Label
   vVEPanel VEPanel
   
   uint     CurCompEdit //Текущее окно дополнительного редактирования 
   
}

method myform myform.init( )
{
   return this
}

include 
{
   "main_save.g"
}

//Установка нового значения свойства
method myform.propset <alias=propset>( evparProp ev )
{    
   .flgchanged = 1
   cm.GetCompDescr( .VEPanel.Selected.TypeId ).FindProp( ev.name.str() ).SetVal( .VEPanel.Selected, ev.value )
   if ev.name.str() == "Name"
   {
      .GFSetHeaderf()
   }
   //.VEPanel.WE.green()
   //.VEPanel.WE.select( .VEPanel.WE.winn->vCtrl )
   //.VEPanel.Selected = .VEPanel.Selected
   .VEPanel.Selected = .VEPanel.Selected   
   .VEPanel.Virtual( $mDesChanged, .VEPanel.Selected )   
}

method myform.eventset <alias=eventset>( evparProp ev )
{
   .flgchanged = 1
   uint event as cm.GetCompDescr( .VEPanel.Selected.TypeId ).FindEvent( ev.name.str() )
   str  oldval = event.GetVal( .VEPanel.Selected ) 
   
   uint resset = event.SetVal( .VEPanel.Selected, ev.value )
   
   uint descr as ManEvents.Descrs[*ManEvents.Descrs - 1]
   if resset & $EVENT_RENAME 
   {
      .GFSetMethodf( oldval, ev.value.str(), descr.EventType )
   }
   elif resset & $EVENT_NEW
   {  
      .GFSetMethodf( oldval, ev.value.str(), descr.EventType )
   }
   //.VEPanel.WE.green()
   //.VEPanel.WE.select( .VEPanel.WE.winn->vCtrl )
   .VEPanel.Selected = .VEPanel.Selected
}


method vComp.GetArrType( arr a of uint, uint typeid )
{
   uint i
   if this.TypeIs( typeid )
   {
      a[a.expand( 1 )] = &this
   }   
   fornum i=0, *this.Comps
   {      
      if this.Comps[i]->vComp.p_designing  
      {
         this.Comps[i]->vComp.GetArrType( a, typeid )
      }
   }
}  


method myform.getpropslist <alias=getpropslist>( evparEvent ev )
{  
   uint cd as cm.GetCompDescr( .VEPanel.Selected.TypeId )
   if &cd 
   {     
      uint p as cd.FindProp( .props.ar[ .props.ncur ].Name.str() )
      if p.PropType == uint || p.PropType == int
      {
         if p.Vals
         {
            .props.cb.Clear()
            foreach enval, p.Vals->arr of CompEnumVal  
            {
               .props.cb.AddItem( enval.Name.ustr(), 0->ustr, 0 )
            }
         }        
      }
      elif ( p.PropType == vComp || type_isinherit( p.PropType, vComp ))
      {
         arr a of uint
         .props.cb.Clear()
         .VEPanel.Selected.GetForm()->vComp.GetArrType( a, p.PropType )
         foreach item, a
         {
            .props.cb.AddItem( item->vComp.Name.ustr(), 0->ustr, 0 )     
         }
      }
   }
}

method myform.geteventslist <alias=geteventslist>( evparEvent ev )
{
   uint cd as cm.GetCompDescr( .VEPanel.Selected.TypeId )
   if &cd 
   {
      uint event as cd.FindEvent( .events.ar[ .events.ncur ].Name.str() )
    
      .events.cb.Clear()
    
      if &event
      {
         
         foreach descr, ManEvents.Descrs
         {
            if descr.EventType == event.EventType 
            {
    
               .events.cb.AddItem( descr.MethodName.ustr(), 0->ustr, 0 )
            }
         }  
      }
   }  
}



//Выбор текущего компонента
method myform.compselect <alias=compselect>( evparEvent ev )
{
   if &.VEPanel.Selected()//.VEPanel.WE.winn
   {
      .flgchanged = 1
      arr ap of PropItem
      arr ae of PropItem 
      cm.GetPropList( .VEPanel.Selected, ap, ae )   
      .props.setar( ap )       
      .events.setar( ae )   
      .edcurcomp.Text =  "     ".ustr() + .VEPanel.Selected.TypeName + "     " +.VEPanel.Selected.Name
      if .CurCompEdit
      {  
         .CurCompEdit->vForm.Virtual( $mSelectComp, .VEPanel.Selected )
      }
   }
}


method vComp myform.newcompdes( uint typeid, vComp owner )
{   
   uint comp as owner.CreateComp( typeid, 1 )->vComp
   if &comp
   {
      uint curn
      str name
      str typename = comp.TypeName            
      uint ar as new( arr of uint )->arr of uint
      //ar.expand( 1 )       
      ar.expand( *cm.GetCompDescr( typeid ).Events )
      comp.des1 = &ar
      if *comp.TypeName > 1 
      {  
         typename.substr( comp.TypeName, 1, *comp.TypeName-1 )
      }
      else
      {
         typename = comp.TypeName
      }
      do
      {         
         name = typename + "\(curn++)"               
      }
      while &(.edform->vForm.FindComp( name ))                     
      comp.Name = name
      comp.p_designing = 1      
      //.GetNoVis()
      .VEPanel.Update()
   }
   return comp
}


method myform.QueryCreate <alias=myform_QueryCreate >( evparQueryCreate  evpQ )
{
   //uint b as .newcompdes( .VEPanel.WE.flgadd, .VEPanel.WE.winn->vComp )
      
   //uint b as this.newctrl( typeid )
   if evpQ.NewComp = &.newcompdes( ?( evpQ.TypeId, evpQ.TypeId, .VEPanel.WE.flgadd ) , evpQ.Owner->vComp ) 
   {         
      uint b as evpQ.NewComp->vComp
      if b.TypeIs( vVirtCtrl )
      {         
         b as vVirtCtrl
         b.Left = evpQ.loc.left
         b.Top = evpQ.loc.top
         if evpQ.loc.width : b.Width = evpQ.loc.width
         if evpQ.loc.height : b.Height = evpQ.loc.height
      }  
      //this.bt_arrow.checked = 1
      .GFSetHeaderf()      
      //.GFSetProps()
      .flgchanged = 1      
      if .objtv.Selected && .objtv.Selected.Tag 
      {
         .objtv.Selected = .objtv.Selected.Parent
      }
      //.btArrow.Checked = 1
   }    
   
   //arr ap of PropItem 
   //cm.GetPropList( .VEPanel.WE.winn->vComp, ap )   
   //.props.setar( ap )
}



method myform.New()
{
   if .flgchanged: .GFSave( 1 )
   if .edform
   {
      .edform->vComp.DestroyComp()
      .VEPanel.NoVisList.Rows.Clear()
      ManEvents.Descrs.clear()
   }
   ManEvents.Descrs.expand(1)
      
   uint newform as .VEPanel.VisPanel->vComp.CreateComp( vForm )->vForm
   uint ar as new( arr of uint )->arr of uint            
   ar.expand( *cm.GetCompDescr( vForm ).Events )
   newform.des1 = &ar
   
   newform.p_designing = 1
   newform.TabOrder = 0      
   .edform = &newform
   newform.Name = "Form0"   
   .GFSetNew()      
   .Caption = "New".ustr()
   .VEPanel.WE.select( newform->vCtrl )   
   .VEPanel.Selected = newform   
   .VEPanel.Virtual( $mDesChanged, .VEPanel.Selected )
   .flgchanged = 0
   .flgsaved = 0 
   
           
}

type aftercreate
{
   uint prop
   uint comp
   ustr  val
}

method vComp vComp.Load( gtitem gi, arr after of aftercreate )
{   
   uint typeid = gettypeid( gi.get( "TypeName" ) )
   
   if typeid
   {
      uint comp as this.CreateComp( typeid, 1 )->vComp      
      //comp.p_designing = 1    
      comp.p_loading = 1
      uint ar as new( arr of uint )->arr of uint            
      ar.expand( *cm.GetCompDescr( typeid ).Events )
      comp.des1 = &ar      
      uint props as gi.findrel( "/Properties" )
      if &props
      {
         foreach prop, props  
         {            
            ustr val            
            val.fromutf8( prop->gtitem.value )            
            uint compprop as cm.GetCompDescr( typeid ).FindProp( prop->gtitem.name )
            if &compprop 
            {            
               if compprop.PropFlags & $PROP_LOADAFTERCREATE
               {
                  uint curafter as after[after.expand(1)]
                  curafter.comp = &comp
                  curafter.val = val
                  curafter.prop = &compprop
               }
               else : compprop.SetVal( comp, val )
            }           
         }                                 
      }      
      uint events as gi.findrel( "/Events" )
      if &events
      {      
         foreach event, events  
         {            
            ustr val
            val.fromutf8( event->gtitem.value )            
            uint compevent as cm.GetCompDescr( typeid ).FindEvent( event->gtitem.name )            
            if &compevent : compevent.SetVal( comp, val )            
         }                      
      }            
      uint children as gi.findrel( "/Children" )
      if &children   
      {     
         foreach obj, children  
         {            
            comp.Load( obj->gtitem, after) 
         }
      }
      props as gi.findrel( "/PropertiesAfter" )
      if &props
      {
         foreach prop, props  
         {            
            ustr val
            val.fromutf8( prop->gtitem.value )
            uint compprop as cm.GetCompDescr( typeid ).FindProp( prop->gtitem.name )
            if &compprop : compprop.SetVal( comp, val )           
         }                                 
      }
      comp.p_loading = 0
      return comp
   }   
   return 0->vComp
}

method myform.Open ( str filename )
{
   gt g   
   
   .filename = filename
   
   if !.gffile.read( .filename + ".gf" ) : return 
   g.read( .filename + ".frm" ) 
   .Caption = .filename.ustr() + ".gf"
   
   //0->vComp.Load( g.root().findrel( "/Object" ) )
   ManEvents.Descrs.clear()
   ManEvents.Descrs.expand(1)
   
   foreach obj, g.root()
   {
   
      arr after of aftercreate      
      uint newform as .VEPanel.VisPanel->vComp.Load( obj->gtitem, after )->vForm      
      uint i
      fornum i = 0, *after
      {
         uint curafter as after[i]
         curafter.prop->CompProp.SetVal( curafter.comp->vComp, curafter.val )
      }
      
      if &newform 
      {
      
         if .edform
         {
            .edform->vForm.DestroyComp()
            .VEPanel.NoVisList.Rows.Clear()
         }
         .edform = &newform
         newform.p_designing = 1
         newform.TabOrder = 0
         //.VEPanel.WE.select( newform->vCtrl )
         .VEPanel.Selected = newform
         .VEPanel.Virtual( $mDesChanged, .VEPanel.Selected )
         
      }
      break
      
   }
   .VEPanel.Update()
   .flgchanged = 0
   .flgsaved = 1   
}

method myform.OpenQuery
{      
   if .flgchanged: .GFSave( 1 )
   
   .dlgOpen.DefExt = ".gf".ustr()
   .dlgOpen.Filters[0]= "Gentee form (*.gf)\\*.gf".ustr()
   .dlgOpen.FileName = "".ustr()
   if !.dlgOpen.ShowOpenFile() : return
   str dir, fname   
   .dlgOpen.FileName.str().fgetparts( dir, fname, 0->str )
   .Open( dir + "\\" + fname )
      //this.Save( ev )
}

method myform.btnRun_click <alias=btnRun_click> ( evparEvent ev )
{   
   //.md.Owner = this
   //.md.Visible = 1
   
   .GFSave( 0 )     
   if .flgsaved
   {
      if *.prj.runfile
      {   
         //process( "\"\( getmodulepath( "", "gentee.exe" ) )\" \"\(.prj.runfile)\"", "".fgetdir(.prj.runfile), 0 )
         setcurdir( "".fgetdir( .prj.runfile ) )
         shell( .prj.runfile ) 
      }      
      else
      {             
         //process( "\"\( getmodulepath( "", "gentee.exe" ) )\" \"\(.filename).g\"", "".fgetdir(.filename), 0 )
         shell( "\(.filename).g" )
      }
   }
}


method myform.objtv_afterselect <alias=myform_objtv_afterselect> ( evparValUint eva )
{
   if eva.val
   {
      this.VEPanel.WE.flgadd = eva.val->TVItem.Tag
   }
   else : this.VEPanel.WE.flgadd = 0
}

method myform.NewFile <alias=NewFile> ( evparEvent ev) 
{
   this.New()
}

method myform.OpenFile <alias=OpenFile> (evparEvent ev) 
{
   this.OpenQuery()
}

method myform.OpenProject( str filename )
{
   gt g    
   uint gi, gc
   g.read( filename )
   gi as g.root().findrel( "/project" )
   if &gi 
   {    
      .prj.filename = filename
      gc as gi.findrel( "/runfile" )
      if &gc : .prj.runfile = gc.value 
      gc as gi.findrel( "/resources" )
      if &gc : .prj.resources = gc.value
      if &gc 
      {
         .prj.resources = gc.value
         DesApp.Lng.load( .prj.resources + "\\language", "english", "english" )
         DesApp.ImgM.MainDir = .prj.resources + "images" 
         DesApp.ImgM.Load( "default", 1 )
         .edform->vForm.Virtual( $mLangChanged )
         
      } 
   }  
}

method myform.OpenProjectQuery <alias=OpenProjectQuery> (evparEvent ev) 
{  
   .dlgOpen.DefExt = ".gp".ustr()
   .dlgOpen.Filters[0]= "Gentee project (*.gp)\\*.gp".ustr()
   .dlgOpen.FileName = "".ustr()
   if !.dlgOpen.ShowOpenFile() : return   
   .OpenProject( .dlgOpen.FileName.str() )  
   
   //.prj.resources = 
   
   //0->vComp.Load( g.root().findrel( "/Object" ) )
   
   //Open( dir + "\\" + fname )
}

method myform.SaveFile <alias=SaveFile> (evparEvent ev) 
{
   .GFSave( 0 )   
}

method myform.SaveAsFile <alias=SaveAsFile> (evparEvent ev) 
{
   .GFSave( 1 )   
}


method myform.QuerySelect <alias=myform_QuerySelect>( evparValUint eQS )
{   
   //.VEPanel.WE.select( eQS.val->vComp )
   .VEPanel.Selected = eQS.val->vComp     
}

method myform.CompEditDelete <alias=myform_CompEditDelete>( evparEvent ev )
{
   .CurCompEdit = 0
}


method myform.VEPanel_DblClick <alias=myform_VEPanel_DblClick> ( evparValUint evn )
{
   
   uint comp as .VEPanel.Selected
   
   if &comp && !.CurCompEdit 
   {  
      if comp.TypeIs( vCustomMenu )
      {
         .CurCompEdit = &comp->vCustomMenu.Design( this, myform_QueryCreate, myform_QuerySelect, myform_CompEditDelete )
      }
      elif comp.TypeIs( vTab )
      {         
         .CurCompEdit = &comp->vTab.Design( this, myform_QueryCreate, myform_QuerySelect, myform_CompEditDelete )  
      }
      elif comp.TypeIs( vToolBar ) 
      {
         //newcompdes( vToolBarItem, comp )
         evparQueryCreate eQC
         eQC.Owner = &comp
         eQC.TypeId = vToolBarItem                  
         .QueryCreate( eQC )
         
         //.flgchanged = 1  
      }
      if .CurCompEdit
      {
         POINT pos
         pos.x = .VEPanel.Left
         pos.y = .VEPanel.Top
         ClientToScreen( this.hwnd, pos )
         .CurCompEdit->vForm.Left = pos.x//.VEPanel.Left
         .CurCompEdit->vForm.Top = pos.y//.VEPanel.Top
         SetFocus( .CurCompEdit->vForm.hwnd )
      }                                
   }
}



method myform.CloseQuery <alias=myform_CloseQuery>( evparQuery evpQ )
{   
   if .flgchanged : .GFSave( 1 )   
   if .flgsaved 
   {
   
      ini prefs
      prefs.setvalue( "PROJECT", "last", .filename )
      prefs.setvalue( "PROJECT", "project", .prj.filename )
      prefs.write( .curdir + "\\visedit.ini" )
   }
   //evpQ.flgCancel = 1
   //this.DestroyComp()
}


global
{
ustr xxx 
}

func t<main>
{
   
   uint mybtn
   myform x
   getcurdir( x.curdir )   
   App.ImgM.MainDir = x.curdir + "\\images" 
   App.ImgM.Load( "default", 1 )
   App.Load()   
   if App.Lng.load( x.curdir + "\\language", "english", "english")
   {
      ustr u
   }
      
   x.Owner = App
   
   
   
   //ti.lParam = 
   x.OnCloseQuery.Set( x, myform_CloseQuery )
   /*x.hwndTip = CreateWindowEx( 0, "tooltips_class32".ustr().ptr(), 0,
                            $WS_POPUP | 0x01 | 0x02, // | $TTS_NOPREFIX | $TTS_ALWAYSTIP,
                            0x80000000, 0x80000000,
                            0x80000000, 0x80000000, //$CW_USEDEFAULT,
                            0, 0, GetModuleHandle( 0 ), 0)
   SetWindowPos(x.hwndTip, $HWND_TOPMOST,0, 0, 0, 0,
             $SWP_NOMOVE | $SWP_NOSIZE | $SWP_NOACTIVATE)
                             
   TOOLINFO ti
   ti.cbSize = sizeof( TOOLINFO ) + 10
   ti.uFlags = $TTF_SUBCLASS//0//$TTF_IDISHWND //| $TTF_SUBCLASS //$TTF_IDISHWND |
   ti.hwnd = x.hwnd 
   ti.uId = x.hwnd
   ti.rect.right = 200
   ti.rect.bottom = 200
   //ti.hinst = GetModuleHandle( 0 )   
   ti.lpszText = "test sdddddddddddddddddd".ustr().ptr()
   //ti.lParam = 
   */
   
//FreeConsole()
   with x.VEPanel
   {
      .Owner = x
      .Left = 200
      .Width = x.Width - .Left
      .HorzAlign = $alhLeftRight
      .VertAlign = $alvClient
      
   }  
   
   x.MainMenu.Owner = x
   uint cim, csim
   cim as x.MainMenu.CreateComp( vMenuItem )->vMenuItem
   cim.Caption = "file".ustr()
   csim as cim.CreateComp( vMenuItem )->vMenuItem
   csim.OnClick.Set( x, NewFile )
   csim.Caption = "New".ustr()
   csim as cim.CreateComp( vMenuItem )->vMenuItem
   csim.Caption = "Open".ustr()
   csim.OnClick.Set( x, OpenFile )
   csim as cim.CreateComp( vMenuItem )->vMenuItem
   csim.Caption = "Save".ustr()
   csim.OnClick.Set( x, SaveFile )
   csim as cim.CreateComp( vMenuItem )->vMenuItem
   csim.Caption = "Save as".ustr()
   csim.OnClick.Set( x, SaveAsFile )
   csim as cim.CreateComp( vMenuItem )->vMenuItem
   csim.Caption = "Open project".ustr()
   csim.OnClick.Set( x, OpenProjectQuery ) 
   
   uint panleft as x.CreateComp( vPanel )->vPanel
   panleft.HorzAlign = $alhLeft
   panleft.Width = 200   
   panleft.VertAlign = $alvClient
   //panleft.Visible = 0   
   //panleft.Border = $brdLowered
   //panleft.Border = 0
   
   mybtn as panleft.CreateComp( vBtn )->vBtn   
   mybtn.Top = 0
   mybtn.HorzAlign = $alhCenter
   mybtn.Caption = "Run".ustr()
   mybtn.OnClick.Set(x,btnRun_click)
   //x.Label.Owner = panleft->vComp
    
   with x.objtv
   {
      .Owner = panleft
      .HorzAlign = $alhClient
      .Top = mybtn.Top + mybtn.Height
      .Height = 150      
      //.VertAlign = $alvTopBottom      
      .ShowSelection = 1
      .RowSelect = 1
      .OnAfterSelect.Set( x, myform_objtv_afterselect )
   
      uint winlist as x.objtv.Root.AppendChild( "Windows objects".ustr(), 0 )
      winlist.SortType = $TVSORT_SORT
      foreach descr, cm.Descrs
      {  
         if descr.VisComp 
         {         
            str typename
            typename.substr( descr.TypeName, 1, *descr.TypeName-1 )
            winlist.AppendChild( typename.ustr(), descr.TypeId )            
         }      
      }
      winlist.Expanded = 1
   }
   
   with x.edcurcomp
   {
      .Owner = panleft
      .Border = 0
      .Top = x.objtv.Top + x.objtv.Height
      .Height = 20
      .HorzAlign = $alhClient
      .ReadOnly = 1
      .TabStop = 0
      //.Enabled = 0
   }
 
   uint tabbottom as panleft.CreateComp( vTab )->vTab   
   tabbottom.Top = x.edcurcomp.Top + x.edcurcomp.Height   
   tabbottom.VertAlign = $alvTopBottom
   tabbottom.HorzAlign = $alhClient
   tabbottom.Bottom = 0   
   uint tiProperties as tabbottom.CreateComp( vTabItem )->vTabItem   
   tiProperties.Caption = "Properties".ustr()   
   uint tiEvents as tabbottom.CreateComp( vTabItem )->vTabItem   
   tiEvents.Caption = "Events".ustr()
     
   x.props.Owner = tiProperties   
   x.props.HorzAlign = $alhClient   
   x.props.VertAlign = $alvClient   
   x.props.onPropSet.Set( x, propset )      
   x.props.ongetlist.Set( x, getpropslist )   
   x.events.Owner = tiEvents   
   x.events.HorzAlign = $alhClient
   x.events.VertAlign = $alvClient
   x.events.onPropSet.Set( x, eventset )
   x.events.ongetlist.Set( x, geteventslist )      
//   x.VEPanel.WE.Owner = x.panEdVis
//   x.VEPanel.WE.onSelect.set( x, compselect )
//   x.VEPanel.WE.onNew.set( x, myform_QueryCreate )

   x.VEPanel.onSelect.Set( x, compselect )
   x.VEPanel.onQueryCreate.Set( x, myform_QueryCreate )
   x.VEPanel.OnDblClick.Set( x, myform_VEPanel_DblClick )
   

   x.dlgOpen.Owner = x
   x.dlgOpen.DefExt = "gf".ustr()
   
   x.dlgOpen.Filters.expand(2)         
   x.dlgOpen.InitialDir = $"K:\gentee\".ustr()
   
   ini prefs
   str filename
   prefs.read( x.curdir + "\\visedit.ini" )
   if prefs.getvalue( "PROJECT", "last", filename, "" ) &&
      *filename
   {      
      x.Open( filename )
      filename.clear()
      prefs.getvalue( "PROJECT", "project", filename, "" )
      x.OpenProject( filename )
   }
   else
   {
      x.New()   
   }
   
   App.Run()   
}
