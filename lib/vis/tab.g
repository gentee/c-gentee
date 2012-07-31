/******************************************************************************
*
* Copyright (C) 2004-2007, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: vis.tab 24.07.07 0.0.A.
*
* Author: Alexander Krivonogov ( gentee )
*
******************************************************************************/

/* Компонента vTabItem, порождена от vCtrl, работает в паре vTab, может  
находиться только внутри vTab
*/
type vTabItem <inherit = vCtrl>
{
//Hidden Fields
   locustr  pCaption  //Заголовок
   uint     pWinIndex //Индекс закладки в оконном представлении
   ustr     pImageId   
   int      pImageIndex   
}

/* Компонента vTab, порождена от vCtrl, работает в паре vTabItem, может содеражть 
только vTabItem
События
   onChange - вызывается при смене закладки
*/
type vTab <index=vTabItem inherit = vCtrl>
{
//Hidden Fields
   vloc pAdjLoc       //Координат внутреннего окна
   uint pCurIndex     //Индекс текущего элемента, если пусто -1
   ustr pImageList
   uint ptrImageList
   uint iNumIml
   uint pTabStyle
   uint pFixedWidth
   uint flgDel
      
//Events      
   evValUint OnChange
}


extern {
   property vTab.CurIndex( uint val )
   property uint vTab.CurIndex( )
   method vTab.iCalcAdj()
}

include {  
  "tabitem.g"
}


define <export>{
//Стили закладок TabStyle
   tsTab     = 0 
   tsButtons = 1
   tsFlatButtons = 2
   tsNone    = 3
}

/*------------------------------------------------------------------------------
   Internal Methods
*/
/*Метод vTab.iCalcAdj()
Пересчитать размеры отводимые для странички
*/
method vTab.iCalcAdj()
{    
   RECT r
   r.left = 0
   r.top = 0
   r.right = this.loc.width
   r.bottom = this.loc.height
   this.WinMsg( $TCM_ADJUSTRECT, 0, &r )
   this.pAdjLoc.left = r.left
   this.pAdjLoc.top = r.top
   this.pAdjLoc.width = r.right - r.left
   this.pAdjLoc.height = r.bottom - r.top
}

/*Метод vTab.iSetCurIndex( uint val, flgchangetab )
Установить текущую страницу
val - номер страницы
flgchangetab - 1 - установить соответствующую закладку
*/
method vTab.iSetCurIndex( uint val, uint flgchangetab )
{
   val = max( int( min( int( val ), int(this.pCtrls)/**this.ctrls*/-1)), int(0) )   
   if /*val != this.pCurIndex &&*/ this.pCtrls
   {
      uint i, tabi
      if this.pCurIndex >= 0 && this.pCurIndex < this.pCtrls/**this.ctrls*/
      {
         this./*ctrls*/Comps[this.pCurIndex]->vTabItem.Visible = 0            
      }
      uint item as this./*ctrls*/Comps[val]->vTabItem             
      if !item.Enabled 
      {
         fornum val=0, this.pCtrls/**this.ctrls*/
         {
            item as this./*ctrls*/Comps[val]->vTabItem
            if item.Enabled :break
         }
      }
      if item.Enabled
      {         
         this.pCurIndex = val      
         if flgchangetab: this.WinMsg( $TCM_SETCURSEL, item.pWinIndex )
         this./*ctrls*/Comps[val]->vTabItem.Visible = 1
      }      
      else
      {
         this.pCurIndex = -1
      }
      evparValUint evp
      evp.val = this.pCurIndex
      .OnChange.Run( evp, this )
   }
}

/*Метод vTab.iUpdateImageList()
Обновить ImageList
*/
method vTab.iUpdateImageList()
{   
   .ptrImageList = &.GetImageList( .pImageList, &.iNumIml )               
   if .hwnd
   {   
      if .ptrImageList
      {//print( "xxxx \(.ptrImageList->ImageList.arrIml[.iNumIml].hIml)\n" )
         .WinMsg( $TCM_SETIMAGELIST, 0, .ptrImageList->ImageList.arrIml[.iNumIml].hIml )      
         .WinMsg( $TCM_SETMINTABWIDTH, 1, 1 )     
      }
      else 
      {      
         .WinMsg( $TCM_SETIMAGELIST, 0, 0 )
      }
      .Invalidate()
   }
}

method vTab.iSetFixedWidth( uint val )
{
   .pFixedWidth = val
   if .hwnd
   {  
      .SetStyle( $TCS_FIXEDWIDTH, val )
      .WinMsg( $TCM_SETITEMSIZE, 0, val  ) 
   }   
}
/*------------------------------------------------------------------------------
   Properties
*/
/*Количество элементов uint *vTab
Возвращает количество закладок
*/
operator uint *( vTab tab )
{
   return tab.pCtrls/**tab.ctrls*/
}

/*Индекс vTabItem vTab[index] 
Возвращает закладку с текущим номером
*/
method vTabItem vTab.index( uint index )
{
   if index != -1 && index < .pCtrls/**.ctrls*/
   {   
      return ./*ctrls*/Comps[ index ]->vTabItem
   }
   return 0->vTabItem 
}

/* Свойство uint CurIndex - Get Set
Усотанавливает или определяет номер открытой закладки
*/
property uint vTab.CurIndex()
{
   return this.pCurIndex  
}

property vTab.CurIndex( uint val )
{
   if val != .pCurIndex
   {
      this.iSetCurIndex( val, 1 )
   }
}

/* Свойство vTabItem CurItem - Get
Получить текущую страницу
*/
property vTabItem vTab.CurItem()
{
   return this[.pCurIndex]->vTabItem   
}

/* Свойство str vTab.ImageList - Get Set
Устанавливает или получает имя списка картинок
*/
property ustr vTab.ImageList <result>
{
   result = this.pImageList
}

property vTab.ImageList( ustr val )
{
   if val != this.pImageList
   { 
      this.pImageList = val
      .Virtual( $mLangChanged )      
   }
}

/* Свойство uint TabStyle - Get Set
Усотанавливает или определяет вид закладок
*/
property uint vTab.TabStyle()
{
   return this.pTabStyle 
}

property vTab.TabStyle( uint val )
{
   if val != .pTabStyle
   {
      .pTabStyle = val
      .Virtual( $mReCreateWin )
   }
}

/* Свойство uint FixedWidth - Get Set
Усотанавливает или определяет номер открытой закладки
*/
property uint vTab.FixedWidth()
{
   return this.pFixedWidth  
}

property vTab.FixedWidth( uint val )
{
   if val != .pFixedWidth
   {
      this.iSetFixedWidth( val )
   }
}


/*------------------------------------------------------------------------------
   Virtual Methods
*/
method vTab.mInsert <alias=vTab_mInsert>( vTabItem item )
{
   if item.TypeIs( vTabItem )
   {     
      this->vCtrl.mInsert( item )
      //uint curenabled = item.pEnabled
      //item.pEnabled = 0 
      //item.Enabled = curenabled
      item.mSetEnabled()
      //setxpstyle( item.hwnd )
      /*eventpos evp
      evp.code = $e_poschanging 
      evp.move = 1
      item.Virtual( $mPosChanging, &evp )*/
      evparValUint evu
      evu.val = 1   
      .Virtual( $mPosChanged, evu )
      if .CurIndex == -1 
      {
         .CurIndex = 0
      }            
   }
}

method vTab.mRemove <alias=vTab_mRemove>( vTabItem item )
{   
   uint i
   fornum i = item.pIndex + 1, .pCtrls//cidx + 1, .pCtrls
   {
      uint nextitem as .Comps[i]->vTabItem
      if nextitem.Enabled 
      {
         nextitem.pWinIndex--
      }
   }
   this.WinMsg( $TCM_DELETEITEM, item.pIndex )//item.cidx )
   this->vCtrl.mRemove( item )
   uint curindex = this.pCurIndex
   this.pCurIndex = -1
   if !.flgDel
   {
      if curindex >= .pCtrls : curindex--
      this.CurIndex = curindex
   }
}

method vTab vTab.mCreateWin <alias=vTab_mCreateWin>()
{  
   uint style = $WS_CHILD | $WS_CLIPSIBLINGS | $WS_CLIPCHILDREN
   switch .pTabStyle
   {
      case $tsButtons : style |= $TCS_BUTTONS 
      case $tsFlatButtons : style |= $TCS_BUTTONS | $TCS_FLATBUTTONS 
   }
ifdef !$DESIGNING {    
   if .pTabStyle == $tsNone
   {
      this.CreateWin( "GVForm".ustr(), 0, style )
      this.prevwndproc = -1
   }
   else
}   
   {
      this.CreateWin( "SysTabControl32".ustr(), 0, style )
   }
   this->vCtrl.mCreateWin()   
   .iUpdateImageList()
   .WinMsg( $TCM_SETTOOLTIPS, this.GetForm()->vForm.hwndTip )   
   uint i   
   fornum i = 0, this.pCtrls
   {
      uint item as .Comps[i]->vTabItem
      if item.Enabled 
      {  
         item.mSetEnabled()         
      }      
   }
   evparValUint evu
   evu.val = 1   
   .Virtual( $mPosChanged, evu )   
   .iSetCurIndex( .pCurIndex, 1 )  
   .iSetFixedWidth( .pFixedWidth )   
   return this
}

method uint vTab.mPosChanged <alias=vTab_mPosChanged>( evparEvent ev )
{  
   this.iCalcAdj()
   this->vCtrl.mPosChanged( ev )
   uint i
   fornum i = 0, this.pCtrls
   {
      uint item as .Comps[i]->vTabItem
      uint loc as .pAdjLoc
      item.SetLocation( loc.left, loc.top, loc.width, loc.height )
   }    
   return 0
}

method uint vTab.mWinNtf <alias=vTab_mWinNtf>( winmsg wmsg )//NMHDR ntf )
{
   uint ntf as wmsg.lpar->NMHDR 
   if ntf.code == $TCN_SELCHANGE
   {  
      uint i
      uint tabi = this.WinMsg( $TCM_GETCURSEL )
      uint curi
      fornum i, this.pCtrls/**this.ctrls*/
      {
         if this.Comps[i]->vTabItem.pWinIndex == tabi : break
         /*if this.Comps[i]->vTabItem.Enabled
         {
            if curi == tabi : break
            curi++ 
         }*/ 
      }
      .iSetCurIndex( i, 0 )
   }   
   return 0
}

method vTab.mGetHint <alias=vTab_mGetHint>( uint id, uint lpar, ustr resstr )
{   
   uint i, curi 
   
   fornum i, this.pCtrls
   {
      if this.Comps[i]->vTabItem.Enabled
      {
         if curi == id 
         {            
            resstr = this.Comps[i]->vTabItem.pHint.Text( this )            
            break
         }
         curi++ 
      } 
   }                
}

/*Виртуальный метод  vTab.mLangChanged - Изменение текущего языка
*/
method vTab.mLangChanged <alias=vTab_mLangChanged>()
{
   .iUpdateImageList()
   this->vCtrl.mLangChanged() 
}

/*Виртуальный метод  vTab.mPreDel - удаление
*/
method vTab.mPreDel <alias=vTab_mPreDel>
{
   .flgDel = 1
   this->vCtrl.mPreDel()
   .flgDel = 0
}



/*------------------------------------------------------------------------------
   Registration
*/
method vTab vTab.init( )
{
   this.pTypeId = vTab
   
   this.pCanContain = 1
   this.pTabStop = 1   
   this.pCurIndex = -1
   //this.flgXPStyle = 1
   return this 
}  
/*
method vTab.getprops( uint typeid, compMan cm )
{
   this->vCtrl.getprops( typeid, cm)
   cm.addprops( typeid, 
%{ "caption"     , str, 0})                         
}*/

/*
method vTab.getevents()
{
   %{"onclick"}
}
*/
func init_vTab <entry>()
{  
   regcomp( vTab, "vTab", vCtrl, $vCtrl_last,
      %{ %{$mInsert,       vTab_mInsert },
         %{$mRemove,       vTab_mRemove },
         %{$mCreateWin,    vTab_mCreateWin },         
         %{$mPosChanged,   vTab_mPosChanged },
         %{$mWinNtf,       vTab_mWinNtf },
         %{$mGetHint,      vTab_mGetHint },
         %{$mLangChanged,  vTab_mLangChanged },
         %{$mPreDel,       vTab_mPreDel }
      },
      0->collection )
             
ifdef $DESIGNING {      
   cm.AddComp( vTab, 1, "Windows", "tab" )
   
   cm.AddProps( vTab, %{ 
//"TabOrder", uint, 0,
"CurIndex", uint, $PROP_LOADAFTERCHILD,
"ImageList", ustr, 0,
"TabStyle", uint, 0,
"FixedWidth", uint, 0
   })
   
   cm.AddEvents( vTab, %{
"OnChange"      , "evparValUint"    
   })               
   
   cm.AddPropVals( vTab, "TabStyle", %{
"tsTab",         $tsTab,      
"tsButtons",     $tsButtons, 
"tsFlatButtons", $tsFlatButtons,
"tsNone",        $tsNone       
   })
   
   cm.AddComp( vTabItem )
   
   cm.AddProps( vTabItem, %{ 
"Caption", ustr, 0,
"ImageId", ustr, 0
   })
   
         

}                  
}