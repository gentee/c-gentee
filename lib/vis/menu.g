/******************************************************************************
*
* Copyright (C) 2004-2007, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: vis.menu 18.07.07 0.0.A.
*
* Author: Alexander Krivonogov ( gentee )
*
******************************************************************************/

define {
SHORTKEY_MAX    = 0x7C
}

type shortkey 
{
   uint mstate
   uint key
   uint next
   /*uint altmstate
   uint altkey
   uint altnext*/
   str  pcaption
}

global {
   hash hshortkey of uint
}
func shortkey_init <entry>
{
   uint i
   collection names = %{ "Shift", "Ctrl", "Alt", "Win", "Win",  "BkSp", "Enter", "Esc", "Space", "PgUp", "PgDn", "End", "Home", "Left", "Up", "Right", "Down", "Ins", "Del", "Tab"}
   collection keys  = %{ 0x10   , 0x11,   0x12,  0x5b,  0x5c,   0x08 , 0x0D   , 0x1B , 0x20   , 0x21  , 0x22  , 0x23 , 0x24  , 0x25  , 0x26, 0x27   , 0x28  , 0x2D , 0x2E,  0x09 }
   hshortkey.ignorecase()
   fornum i = 0, *names
   {
      hshortkey[names[i]->str] = keys[i]
   }
   fornum i = 1, 11
   {
      hshortkey[ "F\(i)" ] = 0x6F + i
   }
   fornum i = 0, 10
   {
      hshortkey[ "\(i)" ] = 0x30 + i      
   }
   fornum i = 'A', 'Z' + 1
   {
      hshortkey[ "".appendch( i ) ] =  i        
   }   
   
}

property ustr shortkey.caption<result>() 
{
   result = .pcaption
}

method shortkey.setkey( uint key mstate )
{
   str caption
   subfunc add( str sadd )
{
   if *caption : caption@"+"
   caption@sadd
}  
   .pcaption.clear()
   .key = key
   .mstate = mstate   
   if .mstate & $mstShift : add( "Shift" )  
   if .mstate & $mstCtrl  : add( "Ctrl" )
   if .mstate & $mstAlt   : add( "Alt" )   
   if .mstate & $mstWin   : add( "Win" )
   if key < 16 || key > 18
   {
      foreach name, hshortkey.keys
      {
         if hshortkey[name] == .key
         {
            add( name )
            .pcaption = caption
            break;
         }
      }
   }
}

property shortkey.caption( str value )
{
   uint i, key, mstate 
   arrstr s
   value.split( s, '+', $SPLIT_NOSYS )    
   if *s 
   {  
      fornum i = 0, *s - 1
      {
         switch hshortkey[s[i]] 
         {
            case 0x10: mstate |= $mstShift
            case 0x11: mstate |= $mstCtrl
            case 0x12: mstate |= $mstAlt
            case 0x5b, 0x5c: mstate |= $mstWin      
         }
      }
      switch key = hshortkey[s[i]] 
      {
         case 0x10, 0x11, 0x12, 0x5b, 0x5c: key = 0            
      }
      if key 
      {
         .setkey( key, mstate )  
      }
   }
   else
   {   
      .key = 0
      .mstate = 0    
      .pcaption.clear()     
   }       
}



/* Компонента vCustomMenu, порождена от vComp, является заготовкой для 
vMenu, vMenuItem, vPopupMenu
*/

type vCustomMenu <index=vComp inherit = vComp> {
//Hidden Fields
   uint phMenu  //Хэндл меню
   uint pFake
}

/* Компонента vCustomMainMenu, порождена от vCustomMenu, может содержать vMenuItem 
*/
type vCustomMainMenu <inherit = vCustomMenu> {   
   reserved tblkey[ $SHORTKEY_MAX * 8] 
}

extern {
   method vCustomMenu.mInsert <alias=vCustomMenu_mInsert>( vComp comp )
   method vCustomMainMenu vCustomMenu.iMainMenu()
/*   method vCustomMainMenu.FreeShortKey( vCustomMenu item )
   method vCustomMainMenu.SetShortKey( vCustomMenu item )*/   
}


/* Компонента vMenu, порождена от vCustomMainMenu, может содержать vMenuItem 
*/
type vMenu <inherit = vCustomMainMenu> {
}

include {
   "menuitem.g"
}

method vCustomMainMenu.FreeShortKey( vMenuItem item )
{  
   uint key  
   if ( key = item.pShortKey.key ) && key < $SHORTKEY_MAX
   {      
      uint addr
      uint previtem as 
               (( addr = &.tblkey + ( key << 3 ))->uint )->vMenuItem
      if &previtem == &item
      {
         addr->uint = item.pShortKey.next                
      } 
      else
      {
         while &previtem  
         {
            if previtem.pShortKey.next == &item
            {
               previtem.pShortKey.next = item.pShortKey.next
               break
            }  
            previtem as previtem.pShortKey.next->vMenuItem
         } 
      }
   }
}

method vCustomMainMenu.SetShortKey( vMenuItem item )
{
   uint key
   if ( key = item.pShortKey.key ) && key < $SHORTKEY_MAX
   {      
      uint addr      
      uint nextitem as
          ( (addr = &.tblkey + ( key << 3 ))->uint )->vMenuItem
      addr->uint = &item      
      item.pShortKey.next = &nextitem               
   }         
}

method vCustomMainMenu.UpdateShortKey( vMenuItem item )
{
   .SetShortKey( item )
   uint i
   fornum i=0, *item.Comps
   {
      .UpdateShortKey( item.Comps[i]->vMenuItem )
   }   
}

method uint vCustomMainMenu.CheckShortKey( uint mstate key )
{
   if key && key < $SHORTKEY_MAX
   {
      uint nextitem as 
               ( &.tblkey + (key << 3 ) )->uint->vMenuItem
      while &nextitem
      {         
         if nextitem.Enabled && nextitem.pShortKey.mstate == mstate 
         {
            nextitem.mMenuClick()
            //nextitem.OnClick.Run( nextitem )
            return 1  
         }
         nextitem as nextitem.pShortKey.next  
      }               
   }   
   return 0
}

/*Метод vMenuItem.iMainMenu()
Получить основное меню
*/
method vCustomMainMenu vCustomMenu.iMainMenu()
{
   uint mainmenu as this   
   while mainmenu.Owner.TypeIs( vCustomMenu )
   {   
      mainmenu as mainmenu.Owner
   }   
   return mainmenu as vCustomMainMenu
}


/*------------------------------------------------------------------------------
   Properties
*/
/*Количество элементов uint *vMenu
Возвращает количество закладок
*/
operator uint *( vCustomMenu menu )
{
   return *menu.Comps
}

/*Индекс vMenuItem vMenu[index] 
Возвращает закладку с текущим номером
*/
method vMenuItem vCustomMenu.index( uint index )
{
   if index != -1 && index < *.Comps
   {   
      return .Comps[ index ]->vMenuItem
   }
   return 0->vMenuItem 
}

/*------------------------------------------------------------------------------
   Virtual methods
*/
method vCustomMenu.mInsert  /*<alias = vCustomMenu_mInsert> */( vComp comp )
{   
   /*if !this.TypeIs( vMenu )
   {
      int i
      for i=30*(*.Comps/30), i >= 0, i -= 30
      { 
         RemoveMenu( .phMenu, i, 0x00000400 )
      }
   }*/
   if !this.TypeIs( vMenu )
   {
      if !.pFake
      {
         .pFake = &App.CreateComp( vFakeMenuItem )
         .pFake->vFakeMenuItem.pMenu = &this      
      }
   }
   if comp.TypeIs( vMenuItem ) && comp->vMenuItem.pVisible
   {   
      uint i, pos   
      fornum i=0, *.Comps
      {
         if .Comps[i]->vMenuItem.pVisible : pos++
      }   
      this->vComp.mInsert( comp )
      MENUITEMINFO mi
      mi.cbSize = sizeof( MENUITEMINFO )
      mi.fMask = $MIIM_ID | $MIIM_DATA         
      mi.wID = &comp
      mi.dwItemData = pos
      InsertMenuItem( .phMenu, 1, 0, mi )
      comp->vMenuItem.iUpdate()
      this.iMainMenu().UpdateShortKey( comp->vMenuItem )//SetShortKey( comp->vMenuItem )
      
      if !this.TypeIs( vMenu ) 
      {
      //MENUITEMINFO mi
      mi.cbSize = sizeof( MENUITEMINFO )
      mi.fMask = $MIIM_ID | $MIIM_TYPE | $MIIM_DATA  
      mi.fType = $MFT_SEPARATOR | $MFT_OWNERDRAW
      mi.dwItemData = pos      
      mi.wID = .pFake      
      InsertMenuItem( .phMenu, 1, 0, mi )
      }
   }
   /*if !this.TypeIs( vMenu )
   {
      if .pFake
      {
         RemoveMenu( .phMenu, .pFake, 0 )
      }
      else
      {
         .pFake = &App.CreateComp( vFakeMenuItem )      
      }   
      /*uint i
      for i=0, i < *.Comps, i += 30
      { 
         MENUITEMINFO mi
         mi.cbSize = sizeof( MENUITEMINFO )
         mi.fMask = $MIIM_ID | $MIIM_TYPE 
         mi.fType =  $MFT_OWNERDRAW      
         mi.wID = .pFake
         .pFake->vFakeMenuItem.pMenu = &this
         InsertMenuItem( .phMenu, i, 1, mi )
      }
      MENUITEMINFO mi
      mi.cbSize = sizeof( MENUITEMINFO )
      mi.fMask = $MIIM_ID | $MIIM_TYPE 
      mi.fType = $MFT_SEPARATOR | $MFT_OWNERDRAW      
      mi.wID = .pFake
      .pFake->vFakeMenuItem.pMenu = &this
      InsertMenuItem( .phMenu, GetMenuItemCount( .phMenu ) - 1, 1, mi )
   }*/
}

method vCustomMenu.mRemove <alias = vCustomMenu_mRemove> ( vComp comp )
{   
   if comp.TypeIs( vMenuItem )
   {  
      if !this.TypeIs( vMenu )
      {
         uint i, pos   
         fornum i=0, *.Comps
         {
            if .Comps[i] == &comp
            {
               RemoveMenu( .phMenu, pos * 2 + 1, 0x400 )
            } 
            if .Comps[i]->vMenuItem.pVisible : pos++
         }
      }
      RemoveMenu( .phMenu, &comp, 0 )            
   }
   this->vComp.mRemove( comp )
}

/*method vMenu.Activate( vComp owner)
{
      if &owner && owner.TypeIs( vForm )
      {
         SetMenu( owner->vForm.hwnd, .phMenu )
         DrawMenuBar( owner->vForm.hwnd )      
      }
   //}    
}*/

/*method vMenu.mSetOwner <alias = vMenu_mSetOwner>( vComp newowner )
{      
   if this.pOwner
   {
      SetMenu( .Owner->vForm.hwnd, 0 )
      DrawMenuBar( .Owner->vForm.hwnd )
   }   
   this->vComp.mSetOwner( newowner )   
   //.Activate( .Owner ) 
   if &.Owner && .Owner.TypeIs( vForm )
   {  
      SetMenu( .Owner->vForm.hwnd, .phMenu )
      DrawMenuBar( .Owner->vForm.hwnd )      
   }    
}*/

/*------------------------------------------------------------------------------
   Registration
*/
method vCustomMenu vCustomMenu.init( )
{
   this.pTypeId = vCustomMenu   
   return this 
}

method vCustomMenu vCustomMainMenu.init( )
{
   this.pTypeId = vCustomMainMenu      
   return this 
}


method vMenu vMenu.init( )
{
   this.pTypeId = vMenu   
   this.phMenu = CreateMenu()
   return this 
}  

method vCustomMenu.delete( )
{
   if this.phMenu
   {
      DestroyMenu( this.phMenu )
   }
}


func init_vMenu <entry>()
{
   regcomp( vCustomMenu, "vCustomMenu", vComp, $vComp_last,
      %{ %{$mInsert,       vCustomMenu_mInsert },
         %{$mRemove,       vCustomMenu_mRemove }
      },
      0->collection )
    
   regcomp( vMenu, "vMenu", vCustomMenu, $vComp_last,
      /*%{ %{$mSetOwner, vMenu_mSetOwner }
      },*/
      0->collection,
      0->collection )
      
   regcomp( vMenuItem, "vMenuItem", vCustomMenu, $vCtrl_last,
      %{ %{$mInsert,       vMenuItem_mInsert },/*
         %{$mSetOwner,     vMenuItem_mSetOwner },*/
         %{$mMenuClick,    vMenuItem_mMenuClick },
         %{$mLangChanged,  vMenuItem_mLangChanged }
         /*,
         %{$mWinDrawItem,  vMenuItem_mWinDrawItem },
         %{$mWinMeasureItem,  vMenuItem_mWinMeasureItem }*/
      },
      0->collection )
      
  regcomp( vFakeMenuItem, "vFakeMenuItem", vComp, $vCtrl_last,
      %{ 
         %{$mWinDrawItem,  vFakeMenuItem_mWinDrawItem },
         %{$mWinMeasureItem,  vFakeMenuItem_mWinMeasureItem }
      },
      0->collection )    
      
ifdef $DESIGNING {
   cm.AddComp( vMenu, 1, "Windows", "menu" )
   
   cm.AddComp( vMenuItem )
   cm.AddProps( vMenuItem, %{
"Caption",     ustr, 0,
"Visible",     uint, 0,
"Enabled",     uint, 0,
"Separator",   uint, 0,
"Checked",     uint, 0,
"RadioCheck",  uint, 0,
"AutoCheck",   uint, 0,
"ShortKey",    ustr, 0,
"Image",       ustr, 0,
"Ellipsis",    uint, 0
   }) 
   
   cm.AddEvents( vMenuItem, %{
"OnClick"    , "evparEvent"
   })
   
   
}
                                                                                                              
}



