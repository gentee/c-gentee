/******************************************************************************
*
* Copyright (C) 2004-2007, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: vis.btn 17.07.07 0.0.A.
*
* Author: Alexander Krivonogov ( gentee )
*
******************************************************************************/

/* Компонента vCustomBtn, порождена от vCtrl
События
   onClick - вызывается при нажатии на кнопку
*/
type vCustomBtn <inherit = vCtrl>
{
//Hidden Fields
   locustr pCaption     
   uint    pChecked 
   uint    pBtnStyle
   uint    flgPushLike
   uint    flgOwnerRedraw
//Events   
   evEvent   OnClick
}

/*define {
   mUpdateCaption = $vCtrl_last
   vCustomBtn_last
}*/

type vBtn <inherit = vCustomBtn> :
type vCheckBox <inherit = vCustomBtn> :
type vRadioBtn <inherit = vCustomBtn> :

extern {
   method vCustomBtn.iUpdateChecked
}


define <export>{
//Стили кнопки BtnStyle
   bsClassic    = 0 
   bsAsRadioBtn = 3
   bsAsCheckBox = 4
}

/*------------------------------------------------------------------------------
   Internal Methods
*/


/*------------------------------------------------------------------------------
   Properties
*/
/* Свойство uint Checked - Get Set
Усотанавливает или определяет, находится ли кнопка в выбранном состоянии
Действует только для стилей кнопки $bsAsCheckBox или $bsAsRadioBtn
1 - кнопка выбрана
0 - кнопка не выбрана
*/
property uint vCustomBtn.Checked()
{  
   return this.pChecked
}

property vCustomBtn.Checked( uint val)
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
method vCustomBtn.iUpdateChecked
{
   if /*!.flgOwnerRedraw &&*/ ( this.pBtnStyle == $bsAsCheckBox ||
      this.pBtnStyle == $bsAsRadioBtn ) /*&&
      this.pChecked != (this.WinMsg( $BM_GETCHECK ) == $BST_CHECKED)*/
   {       
      this.WinMsg( $BM_SETCHECK, .pChecked )
      if .pBtnStyle == $bsAsRadioBtn && .pChecked
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
                  btn.pBtnStyle == $bsAsRadioBtn           
               {                  
                  btn.Checked = 0//( btn.WinMsg( $BM_GETCHECK ) == $BST_CHECKED )                  
               }  
            }
         }
      }     
      /*uint tabstop = GetFocus()      
      this.WinMsg( $BM_CLICK )
      SetFocus( tabstop )*/
      .Invalidate()
   }
   else
   {
      .Invalidate()
   }  
}

/* Свойство uint BtnStyle - Get Set
Усотанавливает или определяет стиль кнопки
Возможны следующие варианты:
bsClassic     - обычный вид,
bsAsRadioBtn  - работает как RadioBtn,
bsAsCheckBox  - работает как CheckBox
*/
property uint vCustomBtn.BtnStyle()
{
   return this.pBtnStyle
}

property vCustomBtn.BtnStyle( uint val)
{
   if this.pBtnStyle != val
   {  
      this.pBtnStyle = val
      .Virtual( $mReCreateWin )
      //this.WinMsg( $BM_SETCHECK, 0 )     
      /*uint checked = this.Checked
      uint remstyle = $BS_AUTORADIOBUTTON | $BS_AUTOCHECKBOX | $BS_PUSHLIKE
      uint addstyle
      this.WinMsg( $BM_SETCHECK, 0 )
      this.pChecked = 0
      if val == $bsAsRadioBtn
      {
         addstyle = $BS_AUTORADIOBUTTON | $BS_PUSHLIKE
      }
      elif val == $bsAsCheckBox
      {
         addstyle = $BS_AUTOCHECKBOX | $BS_PUSHLIKE  
      }      
      this.ChangeStyle( addstyle, remstyle ) 
      this.pBtnStyle = val  
      .iUpdateChecked()*/
   }
}

/* Свойство ustr Caption - Get Set
Устанавливает или определяет заголовок кнопки
*/
property ustr vCustomBtn.Caption <result>
{
   result = this.pCaption.Value
}

property vCustomBtn.Caption( ustr val )
{  
   if val != this.pCaption.Value
   { 
      this.pCaption.Value = val
      //.Virtual( $mUpdateCaption )
      .Virtual( $mSetCaption, this.pCaption.Text( this ) )
   }         
}


/*------------------------------------------------------------------------------
   Virtual Methods
*/
/*Виртуальный метод vCustomBtn vCustomBtn.mCreateWin - Создание окна
*/
method vCustomBtn vCustomBtn.mCreateWin <alias=vCustomBtn_mCreateWin>()
{
   uint style = $WS_CHILD | $WS_CLIPSIBLINGS 
   if .pTabStop : style | $WS_TABSTOP//| $BS_BITMAP
   if .flgOwnerRedraw 
   {
      style |= $BS_OWNERDRAW
   }
   else
   {
      switch .pBtnStyle
      {
         case $bsAsRadioBtn :  style |= $BS_AUTORADIOBUTTON | ?( .flgPushLike, $BS_PUSHLIKE, 0 )
         case $bsAsCheckBox :  style |= $BS_AUTOCHECKBOX | ?( .flgPushLike, $BS_PUSHLIKE, 0 )      
      }   
   }
   this.CreateWin( "BUTTON".ustr(), 0, style )
   //.WinMsg( $BM_SETIMAGE, $IMAGE_BITMAP, LoadBitmap( 0,  32754 )) 
   //.Virtual( $mUpdateCaption )
   .Virtual( $mSetCaption, this.pCaption.Text( this ) )
   .iUpdateChecked()
                     
   this->vCtrl.mCreateWin()  
                                
   return this
}

/*Виртуальный метод uint vCustomBtn.mWinCmd - Обработка windows сообщения с командой
*/
method uint vCustomBtn.mWinCmd <alias=vCustomBtn_mWinCmd>( uint ntfcmd, uint id )
{
   //print( "click\n" )
   /*if ntfcmd == $BN_CLICKED 
   {   
      if .pBtnStyle == $bsAsRadioBtn 
      {
         uint owner as this.Owner->vCtrl
         uint i
         if &owner
         {
            fornum i=0, owner.pCtrls
            {
               uint btn as owner.Comps[i]->vCustomBtn
               if btn.TypeIs( vCustomBtn ) && btn.pBtnStyle == $bsAsRadioBtn           
               {
                  
                  btn.pChecked = ( btn.WinMsg( $BM_GETCHECK ) == $BST_CHECKED )                  
               }  
            }
         }
      }
      elif .pBtnStyle == $bsAsCheckBox 
      {         
         .pChecked = ( .WinMsg( $BM_GETCHECK ) == $BST_CHECKED )
      }      
      evparEvent ev
      ev.sender = &this
      this.OnClick.run( ev )     
   }*/
   if ntfcmd == $BN_CLICKED 
   {         
      if .pBtnStyle == $bsAsRadioBtn 
      {
         .Checked = 1
       /*  uint owner as this.Owner->vCtrl
         uint i
         if &owner
         {
            fornum i=0, owner.pCtrls
            {
               uint btn as owner.Comps[i]->vCustomBtn
               if &btn == &this 
               {
                  btn.Checked = 1
               } 
               elif btn.TypeIs( vCustomBtn ) &&
                  btn.pBtnStyle == $bsAsRadioBtn           
               {                  
                  btn.Checked = 0//( btn.WinMsg( $BM_GETCHECK ) == $BST_CHECKED )                  
               }  
            }
         }*/
      }
      elif .pBtnStyle == $bsAsCheckBox 
      {           
         .Checked = !.pChecked//( .WinMsg( $BM_GETCHECK ) == $BST_CHECKED )
      }      
      evparEvent ev
      ev.sender = &this      
      this.OnClick.Run( ev, this )
   }
   return 0
}

/*Виртуальный метод uint vCustomBtn.mLangChanged - Изменение текущего языка
*/
method vCustomBtn.mLangChanged <alias=vCustomBtn_mLangChanged>()
{
   //.Virtual( $mUpdateCaption )
   .Virtual( $mSetCaption, this.pCaption.Text( this ) ) 
   this->vCtrl.mLangChanged() 
}

/*Виртуальный метод vCustomBtn.mSetName - Установка заголовка в режиме проектирования
*/
method uint vCustomBtn.mSetName <alias=vCustomBtn_mSetName>( str newname )
{
ifdef $DESIGNING {   
   if !.p_loading && .Caption == .Name
   {
      .Caption = newname.ustr()
   }
}   
   return 1
}

/*Виртуальный метод vCustomBtn.mUpdateCaption - Обновить заголовок
*/
/*method vCustomBtn.mUpdateCaption <alias=vCustomBtn_mUpdateCaption>()
{
   SetWindowText( this.hwnd, this.pCaption.Text( this ).ptr() )  
}*/

/*------------------------------------------------------------------------------
   Registration
*/
/*Системный метод vCustomBtn vCustomBtn.init - Инициализация объекта
*/   
method vCustomBtn vCustomBtn.init( )
{   
   this.pTypeId = vCustomBtn
     
   this.pCanFocus = 1
   this.pTabStop = 1 
   this.flgXPStyle = 1     
   this.loc.width = 100
   this.loc.height = 25   
   //this.flgReCreate = 1
   return this 
}  

method vBtn vBtn.init( )
{   
   this.pTypeId = vBtn     
   this.flgPushLike = 1   
   return this 
}

method vCheckBox vCheckBox.init( )
{   
   this.pTypeId = vCheckBox
   this.pBtnStyle = $bsAsCheckBox
   return this 
}

method vRadioBtn vRadioBtn.init( )
{   
   this.pTypeId = vRadioBtn  
   this.pBtnStyle = $bsAsRadioBtn
   return this 
}


/*method uint vBtn.wmerasebkgnd <alias=vBtn_wmerasebkgnd>( winmsg wmsg )
{
//if this.Type == vBtn 
{      
   //print( "erase 100000 \(this.Name)\n" )
 //  pDrawThemeParentBackground->stdcall( this.hwnd, wmsg.wpar, 0 );
   wmsg.flags = 1
}    
   return 1   
}*/

func init_vCustomBtn <entry>()
{  
   regcomp( vCustomBtn, "vCustomBtn", vCtrl, $vCtrl_last, 
      %{ %{$mCreateWin,    vCustomBtn_mCreateWin},
         %{$mWinCmd,       vCustomBtn_mWinCmd},
         %{$mLangChanged,  vCustomBtn_mLangChanged },
         %{$mSetName,      vCustomBtn_mSetName}//, 
         //%{$mWinDrawItem,  vCustomBtn_mWinDrawItem},
         //%{$mUpdateCaption,vCustomBtn_mUpdateCaption}
      }, 
      0->collection )
      //%{
        // %{$WM_ERASEBKGND, vBtn_wmerasebkgnd } } )//, 
         //%{$WM_PAINT, vBtn_wmpaint } } )
         //%{$WM_DRAWITEM , vBtn_wmpaint } } )
      
   regcomp( vBtn,      "vBtn", vCustomBtn, $vCtrl_last, 
      0->collection, 0->collection )
            
   regcomp( vCheckBox, "vCheckBox", vCustomBtn, $vCtrl_last, 
      0->collection, 0->collection )
   
   regcomp( vRadioBtn, "vRadioBtn", vCustomBtn, $vCtrl_last, 
      0->collection, 0->collection )
            
ifdef $DESIGNING {
   cm.AddComp( vCustomBtn )   
   
   cm.AddProps( vCustomBtn, %{ 
//"TabOrder", uint, 0,
"Caption",  ustr, 0,
"Checked", uint, 0 
   }) 
   
   cm.AddEvents( vCustomBtn, %{
"OnClick"      , "evparEvent"
   })
   
   cm.AddComp( vBtn, 1, "Windows", "btn" )   
   
   cm.AddProps( vBtn, %{
"BtnStyle", uint, 0
   }) 
   
   cm.AddPropVals( vBtn, "BtnStyle", %{ 
"bsClassic",      $bsClassic,
"bsAsRadioBtn",   $bsAsRadioBtn,     
"bsAsCheckBox",   $bsAsCheckBox
   })
   
   cm.AddComp( vCheckBox, 1, "Windows", "btn" )
   cm.AddComp( vRadioBtn, 1, "Windows", "btn" )         
}
      
}
