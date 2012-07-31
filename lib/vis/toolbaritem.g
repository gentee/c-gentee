/******************************************************************************
*
* Copyright (C) 2004-2007, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: vis.toolbaritem 02.04.08 0.0.A.
*
* Author: Alexander Krivonogov ( gentee )
*
******************************************************************************/


/* Компонента vToolBar, порождена от vCtrl
*/
/*! В перспективе: 
*/
type vToolBarItem <inherit = vVirtCtrl>
{
//Hidden Fields
   uint    pTBIStyle
   locustr pCaption
   ustr    pImageId   
   int     pImageIndex
   uint    pState
   uint    pDropDownMenu
   uint    pMenuItem
   uint    pChecked
   uint    pShowCaption
   
//Events   
   evEvent OnClick
}

define <export>{
//TBIStyle values:
   tbsButton     = 0 //Кнопка   
   tbsSeparator  = 1 //Разделитель
   tbsDropDown   = 2 //Выпадающее меню
   tbsAsCheckBox = 3 //Кнопка с фиксацией
   tbsAsRadioBtn = 4 //Кнопка как radiobutton
}     

extern {
method vToolBarItem.mPosUpdate()
method vToolBarItem.iUpdateChecked()
property vToolBarItem.Checked( uint val)
property uint vToolBarItem.Checked
}

/*------------------------------------------------------------------------------
   Internal Methods
*/
/*Метод vToolBarItem.iUpdate()
Обновить элемент
*/
define 
{
   TB_HIDEBUTTON = $WM_USER + 4
}
method vToolBarItem.iUpdate()
{
   if &this.Owner && this.Owner.TypeIs( vToolBar )
   {
      TBBUTTONINFO tbi
      uint mask
      uint state
      
      switch .pTBIStyle       
      {
         case $tbsButton : tbi.fsStyle = $TBSTYLE_BUTTON         
         case $tbsSeparator {
            tbi.fsStyle = $TBSTYLE_SEP
            //tbi.iImage = 100
            //mask = $TBIF_IMAGE   
         }          
         case $tbsDropDown  : tbi.fsStyle = $TBSTYLE_DROPDOWN          
         case $tbsAsCheckBox : tbi.fsStyle = $TBSTYLE_CHECK         
         case $tbsAsRadioBtn : tbi.fsStyle = $TBSTYLE_CHECK | $TBSTYLE_GROUP
      }
      if .pTBIStyle != $tbsSeparator 
      {
         if ( this.pTBIStyle == $tbsAsCheckBox ||
            this.pTBIStyle == $tbsAsRadioBtn ) && this.pChecked
         {
            state |= $TBSTATE_CHECKED 
         } 
         tbi.iImage = .pImageIndex
         //print( "IMAGE IDX = \(.pImageIndex)\n" )
      }
      else
      {
         tbi.iImage = 10
      }
      if .pShowCaption 
      {
         tbi.fsStyle |= $BTNS_SHOWTEXT
      }
      if .pEnabled : state |= $TBSTATE_ENABLED 
      if !.p_designing 
      {
         /*if !.pVisible 
         {
            //state |= $TBSTATE_HIDDEN
            this.Owner->vToolBar.WinMsg( $TB_HIDEBUTTON, this.pIndex, 1 )
         }*/         
      } 
      else
      {
         state |= $TBSTATE_PRESSED 
      }
      
      tbi.pszText = this.pCaption.Text( this ).ptr()
    
        
      //print( ".pEnabled \(.pEnabled) \(state )\n" )
      //print( ".pVisible \(.pVisible) \(state )\n" )
      tbi.fsState = state
      tbi.cbSize = sizeof( TBBUTTONINFO )
      tbi.dwMask = mask | $TBIF_STYLE | $TBIF_STATE | $TBIF_TEXT | $TBIF_IMAGE 
      /*if !.pVisible
      {  
         this.Owner->vToolBar.WinMsg( $TB_HIDEBUTTON, this.pIndex, 1 ) 
      }
      else
      {
       */
      if .pVisible
      {  
         this.Owner->vToolBar.WinMsg( $TB_SETBUTTONINFO, /*&this*/this.pIndex, &tbi )//cidx, &tbi ) 
      }         
      //this.Owner->vToolBar.WinMsg( $TB_SETBUTTONINFO, /*&this*/this.pIndex, &tbi )//cidx, &tbi )
      .mPosUpdate() 
      this.Owner->vToolBar.WinMsg( $TB_AUTOSIZE )
      /*if !.p_designing && !.pVisible 
      {
         //state |= $TBSTATE_HIDDEN
         this.Owner->vToolBar.WinMsg( $TB_HIDEBUTTON, this.pIndex, 1 )
      }*/
   }
}


/* Метод iUpdateChecked 
Связывает состояние кнопки с визуальным отображением
*/
method vToolBarItem.iUpdateChecked
{
   .iUpdate()
   if this.pTBIStyle == $tbsAsRadioBtn  
   {
      if .pChecked
      {
         uint owner as this.Owner->vCtrl
         uint i
         if &owner
         {            
            //print( "cidx = \(.cidx )\n" )
            for i = .pIndex - 1, int(i) >= 0, i--//.cidx - 1, int(i) >= 0, i--
            {  
               uint item as owner.Comps[i]->vToolBarItem
               if item.TypeIs( vToolBarItem ) &&
                  item.pTBIStyle == $tbsAsRadioBtn           
               {           
                  //print( "clear \(i)\n" )
                  item.Checked = 0                  
               }  
               else : break
            }
            fornum i = .pIndex + 1, owner.pCtrls//.cidx + 1, owner.pCtrls
            {
               uint item as owner.Comps[i]->vToolBarItem
               if item.TypeIs( vToolBarItem ) &&
                  item.pTBIStyle == $tbsAsRadioBtn           
               {
                  //print( "clear \(i)\n" )                  
                  item.Checked = 0                  
               }  
               else : break
            }
         }
      }
   }   
}



/*------------------------------------------------------------------------------
   Properties
*/
/* Свойство uint TBIStyle - Get Set
Положение сплиттера (расстояние от левого или верхнего края
*/
property uint vToolBarItem.TBIStyle()
{  
   return this.pTBIStyle
}

property vToolBarItem.TBIStyle( uint val)
{   
   if this.pTBIStyle!= val
   {  
      this.pTBIStyle = val
      .iUpdate()
      if &this.Owner
      {
         this.Owner->vCtrl.Invalidate()
      }       
   }
}

/* Свойство ustr vToolBarItem.Caption - Get Set
Заголовок кнопки
*/
property ustr vToolBarItem.Caption <result>
{
   result = this.pCaption.Value
}

property vToolBarItem.Caption( ustr val )
{  
   if val != this.pCaption.Value
   { 
      this.pCaption.Value = val
      .iUpdate()
   }         
}


/* Свойство uint Checked - Get Set
Усотанавливает или определяет, находится ли кнопка в выбранном состоянии
Действует только для стилей кнопки $bsAsCheckBox или $bsAsRadioBtn
1 - кнопка выбрана
0 - кнопка не выбрана
*/
property uint vToolBarItem.Checked()
{  
   return this.pChecked
}

property vToolBarItem.Checked( uint val)
{
   if this.pChecked != val
   {    
      this.pChecked = val
      .iUpdateChecked()
   }
}

/* Метод iUpdateChecked 
Связывает состояние кнопки с визуальным отображением
*/
/*method vToolBarItem.iUpdateChecked
{
   if ( this.pTBIStyle == $bsAsCheckBox ||
      this.pTBIStyle == $bsAsRadioBtn ) 
   {*/       
      /*this.WinMsg( $BM_SETCHECK, .pChecked )
      if .pBtnTBIStyle == $bsAsRadioBtn && .pChecked
      {
         uint owner as this.Owner->vCtrl
         uint i
         if &owner
         {
            fornum i=0, owner.pCtrls
            {
               uint btn as owner.Comps[i]->vCustomBtn
               if &btn != &this && 
                  btn.TypeIs( vCustomBtn ) &&
                  btn.pBtnTBIStyle == $bsAsRadioBtn           
               {                  
                  btn.Checked = 0//( btn.WinMsg( $BM_GETCHECK ) == $BST_CHECKED )                  
               }  
            }
         }
      }
      InvalidateRect( this.hwnd, 0->RECT, 1 )
      */
 /*  }
     
}*/

/* Свойство ustr vToolBarItem.DropDownMenu - Get Set
Заголовок кнопки
*/
property vPopupMenu vToolBarItem.DropDownMenu
{
   return this.pDropDownMenu->vPopupMenu
}

property vToolBarItem.DropDownMenu( vPopupMenu val )
{  
   if &val != this.pDropDownMenu
   { 
      this.pDropDownMenu = &val      
   }         
}

/* Свойство ustr vToolBarItem.ImageId - Get Set
Устанавливает или получает картинку
*/
property ustr vToolBarItem.ImageId <result>
{
   result = this.pImageId
}

property vToolBarItem.ImageId( ustr val )
{
   if val != this.pImageId
   { 
      this.pImageId = val
      
      if &.Owner && .Owner->vToolBar.ptrImageList
      {
         //print( "item.image \( val.str())\n")      
         this.pImageIndex = .Owner->vToolBar.ptrImageList->ImageList.GetImageIdx( .Owner->vToolBar.iNumIml, val, 0 )
      }
      else : this.pImageIndex = -1
//      print( "item.image \( this.pImageIndex )\n")    
      .iUpdate()
      
   }   
}


/* Свойство ustr vToolBarItem.ShowCaption - Get Set
Устанавливает или получает флаг показывать текст для mixed режима
*/
property uint vToolBarItem.ShowCaption 
{
   return this.pShowCaption
}

property vToolBarItem.ShowCaption( uint val )
{
   if val != this.pShowCaption
   { 
      this.pShowCaption = val       
      .iUpdate()      
   }   
}

/*------------------------------------------------------------------------------
   Virtual Methods
*/

method vToolBarItem vToolBarItem.mCreateWin <alias=vToolBarItem_mCreateWin>()
{
   
   return this
}

method vToolBarItem.mPosUpdate <alias=vToolBarItem_mPosUpdate>()
{
   //print( "posupdate\n" )
   if &this.Owner && this.Owner.TypeIs( vToolBar )
   {
      RECT r
      this.Owner->vToolBar.WinMsg( $TB_GETITEMRECT, this.Owner->vToolBar.WinMsg( $TB_COMMANDTOINDEX, this.pIndex ), &r )//this.cidx/*&this*/ ), &r )
      this.loc.left = r.left
      this.loc.top = r.top
      this.loc.width = r.right - r.left 
      this.loc.height = r.bottom - r.top   
   }
   
}

/*Виртуальный метод vToolBarItem.mSetVisible
Установка видимости
*/
method vToolBarItem.mSetVisible <alias=vToolBarItem_mSetVisible>()
{
   //.iUpdate()
   if .p_designing
   {
      .iUpdate()
   }
   else 
   {
      this.Owner->vToolBar.WinMsg( $TB_HIDEBUTTON, this.pIndex, !.pVisible )
      if .pVisible : .iUpdate()
   }
}

/*Виртуальный метод vToolBarItem.mSetVisible
Установка доступности
*/
method vToolBarItem.mSetEnabled <alias=vToolBarItem_mSetEnabled>()
{
   .iUpdate()
}

/*Виртуальный метод  vToolBarItem.mLangChanged - Изменение текущего языка
*/
method vToolBarItem.mLangChanged <alias=vToolBarItem_mLangChanged>()
{
   //.iUpdateImageList()
   if &.Owner && .Owner->vToolBar.ptrImageList
   {
      this.pImageIndex = .Owner->vToolBar.ptrImageList->ImageList.GetImageIdx( .Owner->vToolBar.iNumIml, .pImageId, 0 )
   }
   else : this.pImageIndex = -1
   .iUpdate()
   //this->vCtrl.mLangChanged() 
}

/*Виртуальный метод vToolBarItem.mSetName - Установка заголовка в режиме проектирования
*/
method uint vToolBarItem.mSetName <alias=vToolBarItem_mSetName>( str newname )
{
ifdef $DESIGNING {   
   if !.p_loading && .Caption == .Name
   {
      .Caption = newname.ustr()
   }
}   
   return 1
}


/*Виртуальный метод vToolBarItem.mSetIndex - Установка текущего индекска элемента
*/
method vToolBarItem.mSetIndex <alias=vToolBarItem_mSetIndex>( uint newidx )
{
   if &.Owner 
   {  
      uint oldpos = .pIndex      
      this->vVirtCtrl.mSetIndex( newidx )
      .Owner->vToolBar.WinMsg( $TB_MOVEBUTTON, oldpos, .pIndex )
      uint i
      fornum i=0, *.Owner->vToolBar.Comps
      {
         .Owner->vToolBar.WinMsg( $TB_SETCMDID, i, i )   
      } 
   }
}