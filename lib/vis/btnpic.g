/******************************************************************************
*
* Copyright (C) 2004-2007, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: vis.btnpic 07.02.07 0.0.A.
*
* Author: Alexander Krivonogov ( gentee )
*
******************************************************************************/

include {
   "btn.g"
   "ctrlci.g"
}
/* Компонента vBtnPic, порождена от vBtn
События
*/
type vBtnPic <inherit = vBtn>
{
//Hidden Fields
   ustr     pImage
   uint     pFlat   
   PicText  pPicText
   uint     flgEnter
   uint     flgDown
   uint     pNoFocus
//Events      
}


//Устаревшее 
define <export>{
//Расположение картинки и текста
   bplPicLeft = 0 
   bplPicTop  = 1   
}

/*------------------------------------------------------------------------------
   Internal Methods
*/


method vBtnPic.iUpdateImage()
{  
   .pPicText.PtrImage = &this.GetImage( .pImage )
}

/*------------------------------------------------------------------------------
   Properties
*/
/* Свойство ustr vBtnPic.Image - Get Set
Устанавливает или получает картинку
*/
property ustr vBtnPic.Image <result>
{
   result = this.pImage
}

property vBtnPic.Image( ustr val )
{
   if val != this.pImage
   { 
      this.pImage = val      
      .iUpdateImage()      
   }
}

/* Свойство str vBtnPic.Layout - Get Set
Усотанавливает или получает взаимное расположение картинки текста
*/
property uint vBtnPic.Layout
{   
   return .pPicText.Layout
}

property vBtnPic.Layout( uint val )
{  
   .pPicText.Layout = val
}

/* Свойство str vPicture.Flat - Get Set
Всплывающая кнопка как в toolbar
*/
property uint vBtnPic.Flat
{
   return this.pFlat
}

property vBtnPic.Flat( uint val )
{
   if val != this.pFlat
   {
      this.pFlat = val      
      .Invalidate()
   }
}

/* Свойство str vBtnPic.ContHorzAlign - Get Set
Устанавливает или получает расположение содежимого по горизонтали
*/
property uint vBtnPic.ContHorzAlign 
{   
   return .pPicText.ContHorzAlign
}

property vBtnPic.ContHorzAlign( uint val )
{
   .pPicText.ContHorzAlign = val 
}

/* Свойство uint vBtnPic.ContVertAlign - Get Set
Устанавливает или получает расположение содежимого по вертикали
*/
property uint vBtnPic.ContVertAlign 
{   
   return .pPicText.ContVertAlign
}

property vBtnPic.ContVertAlign( uint val )
{
   .pPicText.ContVertAlign = val
}

/* Свойство uin vBtnPic.NoFocus - Get Set
Устанавливает или получает режим без фокуса ввода
*/
property uint vBtnPic.NoFocus 
{   
   return .pNoFocus
}

property vBtnPic.NoFocus( uint val )
{
   if .pNoFocus != val
   {
      .pNoFocus = val
      if val : .TabStop = 0
      .Invalidate()
   }
}

/*------------------------------------------------------------------------------
   Registration
*/
/*Системный метод vBtnPic vBtnPic.init - Инициализация объекта
*/   
method vBtnPic vBtnPic.init( )
{   
   this.pTypeId = vBtnPic
     
   this.pCanFocus = 1
   this.pTabStop = 1      
   this.loc.width = 100   
   this.loc.height = 25
   this.flgOwnerRedraw = 1   
   
   this.pPicText.Ctrl = this
   return this 
}  
define {
  BSTATE_NORMAL = $TS_NORMAL
  BSTATE_PRESSED = $TS_PRESSED
  BSTATE_CHECKED = $TS_CHECKED
  BSTATE_HOT     = $TS_HOT
  BSTATE_HOTCHECKED = $TS_HOTCHECKED
  BSTATE_DISABLED = $TS_DISABLED 
}

//method uint vBtn.wmpaint <alias=vBtn_wmpaint>( winmsg wmsg )
method vBtnPic.mWinDrawItem <alias=vBtnPic_mWinDrawItem>( DRAWITEMSTRUCT ds )
{
   uint off   
   if ds.itemState & $ODS_SELECTED : off = 1
   
   uint state
   if .pEnabled
   {
      if ds.itemState & $ODS_SELECTED || ( .flgDown && .flgEnter )
      {
         state = $BSTATE_PRESSED
      }
      else 
      {
         if .pChecked && ( this.pBtnStyle == $bsAsCheckBox ||
                  this.pBtnStyle == $bsAsRadioBtn )
         {
            if .flgEnter : state = $BSTATE_HOTCHECKED
            else : state = $BSTATE_CHECKED
         }
         else
         {
            if .flgEnter : state = $BSTATE_HOT
            else : state = $BSTATE_NORMAL
         }         
         
      }     
   }
   else
   {
      state = $PBS_DISABLED
   }
   if isThemed 
   {
      if !.pFlat
      {
         if state == $BSTATE_CHECKED : state = $PBS_PRESSED 
         elif state == $BSTATE_HOTCHECKED : state = $PBS_HOT         
      }            
ifdef $DESIGNING {
      if .p_designing && .pFlat && state == $BSTATE_NORMAL : state = $TS_HOT
}      
      pDrawThemeParentBackground->stdcall( this.hwnd, ds.hDC, 0 );
      pDrawThemeBackground->stdcall( 
            ThemeData[?( .pFlat, $theme_toolbar, $theme_button )], 
            ds.hDC, $BP_PUSHBUTTON, state, ds.rcItem, 0 )
   }   
   else
   {
      
      if .pFlat
      {
         FillRect( ds.hDC, ds.rcItem, ?( state == $BSTATE_CHECKED, 
               $COLOR_BTNHIGHLIGHT, $COLOR_BTNFACE) + 1 )               
         if state == $BSTATE_CHECKED || state == $BSTATE_HOTCHECKED || 
            state == $BSTATE_PRESSED
         {
            state = 2
         } 
         elif state == $BSTATE_HOT :  state = 4
         else 
         {
            state = 0
ifdef $DESIGNING {
            if .p_designing: state = 4  
}
            
         }
         
         if state 
         {            
            DrawEdge( ds.hDC, ds.rcItem, state, 0xf )
         }   
      }   
      else
      {
         if state == $BSTATE_CHECKED || state == $BSTATE_HOTCHECKED
         {
            state = 0x410
         } 
         elif state == $BSTATE_PRESSED 
         {
            state = 0x210
         }
         else : state = 0x010         
         DrawFrameControl( ds.hDC, ds.rcItem, 4, state )
      }
   }   
   RECT r
   .pPicText.Draw( ds.hDC, off, off )   
   
   if GetFocus() == this.hwnd 
   {
      r.left = 3 
      r.top = 3
      r.right = .clloc.width - 3
      r.bottom = .clloc.height - 3
      DrawFocusRect( ds.hDC, r )      
   }    
   //wmsg.flags = 1   
   return 
}

/*Виртуальный метод vBtnPic.mSetCaption - Обновить заголовок
*/
method vBtnPic.mSetCaption <alias=vBtnPic_mSetCaption>( ustr caption )
{ 
   this->vBtn.mSetCaption( caption )
   .pPicText.LangCaption = this.pCaption.Text( this )
}

/*Виртуальный метод vBtnPic.mPosChanged - Изменились размеры
*/
method vBtnPic.mPosChanged <alias=vBtnPic_mPosChanged>(evparEvent ev)
{
   this->vCtrl.mPosChanged(ev)
   .pPicText.Width = .clloc.width
   .pPicText.Height = .clloc.height
}

/*Виртуальный метод vURL.mMouse - События от мыши
*/
method uint vBtnPic.mMouse <alias=vBtnPic_mMouse>( evparMouse em )
{  
   switch em.evmtype
   {
      case $evmLDown
      {
         if .pNoFocus
         {
            SetCapture(.hwnd)
            .flgDown = 1
            .Invalidate()            
            return 1
         }
      }
      case $evmLUp
      {
         if .pNoFocus
         {
            ReleaseCapture()
            if .flgDown
            {
               .flgDown = 0
               .Invalidate()
               if .flgEnter 
               {
                  .Owner->vCtrl.WinMsg( $WM_COMMAND, $BN_CLICKED << 16, .hwnd )
               } 
            }
            return 1
         }
      }
      case $evmMove 
      {  
         if .pNoFocus && .flgDown
         {
            POINT pnt
            GetCursorPos( pnt )
            if WindowFromPoint( pnt.x, pnt.y ) != .hwnd
            {
               if .flgEnter
               {
                  .flgEnter = 0
                  .Invalidate()
               }   
            }
            elif !.flgEnter
            {            
               .flgEnter = 1
               .Invalidate()
            }            
         }
         elif !.flgEnter
         {
            .flgEnter = 1      
            TRACKMOUSEEVENT tm
             
            tm.cbSize    = sizeof( TRACKMOUSEEVENT )    
            tm.dwFlags   = $TME_LEAVE
            tm.hwndTrack = .hwnd
            tm.dwHoverTime = 40   
            TrackMouseEvent(tm)      
            .Invalidate()
         }
      }
      case $evmLeave
      {  
         .flgEnter = 0
         .Invalidate()
      }
      /*case $evmActivate
      {
      print( "NOACT 1\n" ) 
         em.ret = 3//$MA_NOACTIVATE
         return 1
      }*/ 
   }
   return 0
}

/*Виртуальный метод uint vBtnPic.mWinCmd - Обработка windows сообщения с командой
*/
method uint vBtnPic.mWinCmd <alias=vBtnPic_mWinCmd>( uint ntfcmd, uint id )
{
   if ntfcmd == $BN_CLICKED 
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
               if &btn == &this 
               {
                  btn.Checked = 1
               } 
               elif btn.TypeIs( vCustomBtn ) &&
                  btn.pBtnStyle == $bsAsRadioBtn           
               {                  
                  btn.Checked = 0                  
               }  
            }
         }
      }
      elif .pBtnStyle == $bsAsCheckBox 
      {           
         .Checked = !.pChecked
      }      
      evparEvent ev
      ev.sender = &this
      this.OnClick.Run( ev, this )     
   }
   return 0
}

/*Виртуальный метод uint vCustomBtn.mLangChanged - Изменение текущего языка
*/
method vBtnPic.mLangChanged <alias=vBtnPic_mLangChanged>()
{
   this->vBtn.mLangChanged()
   .iUpdateImage()  
}

/*Виртуальный метод vBtnPic.mFontChanged - Изменился шрифт
*/
method vBtnPic.mFontChanged <alias=vBtnPic_mFontChanged>()
{
   this->vCtrl.mFontChanged()
   .pPicText.FontChanged()   
}

/*Виртуальный метод vBtnPic.mFocus - Установка фокуса
*/
/*method uint vBtnPic.mFocus <alias=vBtnPic_mFocus>( evparValUint eu )
{
   this->vCtrl.mFocus( eu )
   return 1
}
*/
func init_vBtnPic <entry>()
{  
   regcomp( vBtnPic, "vBtnPic", vBtn, $vCtrl_last, 
      %{ //%{$mCreateWin,    vBtnPic_mCreateWin},         
         %{$mPosChanged,     vBtnPic_mPosChanged },          
         %{$mSetCaption,     vBtnPic_mSetCaption},
         %{$mWinDrawItem,    vBtnPic_mWinDrawItem},
         %{$mLangChanged,    vBtnPic_mLangChanged},
         %{$mMouse,          vBtnPic_mMouse},
         %{$mFontChanged,     vBtnPic_mFontChanged }/*,
         %{$mFocus,          vBtnPic_mFocus}*/
      },       
      0->collection )      

            
ifdef $DESIGNING {
   cm.AddComp( vBtnPic, 1, "Additional", "btnpic" )   
   
   cm.AddProps( vBtnPic, %{ 
"Image"  , ustr, 0,
"Layout"   , uint, 0,
"Flat"     , uint, 0,
"ContVertAlign", uint, 0,
"ContHorzAlign", uint, 0,
"TabStop", uint, 0,
"NoFocus", uint, 0
   }) 
   
   cm.AddPropVals( vBtnPic, "Layout", %{ 
"lPicLeft", $lPicLeft,  
"lPicTop",  $lPicTop  
   })
   
   cm.AddPropVals( vBtnPic, "ContHorzAlign", %{
"ptLeft",    $ptLeft,     
"ptCenter",  $ptCenter,   
"ptRight",   $ptRight
   })    
   
   cm.AddPropVals( vBtnPic, "ContVertAlign", %{      
"ptTop",        $ptTop,                        
"ptVertCenter", $ptVertCenter,          
"ptBottom",     $ptBottom
   })    
      
            
}
      
}
