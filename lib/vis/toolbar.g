/******************************************************************************
*
* Copyright (C) 2004-2007, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: vis.toolbar 01.04.08 0.0.A.
*
* Author: Alexander Krivonogov ( gentee )
*
******************************************************************************/

/* ���������� vToolBar, ��������� �� vCtrl
*/
/*! � �����������: 
*/
type vToolBar <inherit = vCtrl>
{
//Hidden Fields
   ustr pImageList
   uint ptrImageList
   uint iNumIml
   uint pShowCaption
   uint pWrapable
   uint pShowDivider
   uint pAutoSize
   uint pVertical
//Events   
   
}

include {
   "toolbaritem.g"
}

define <export>{
//ShowCaption values:
   tscNone   = 0 //�� ���������� ������� � �������
   tscRight  = 1 //������� ������
   tscBottom = 2 //������� �����
   tscMixed =  3 //������� ������ ���������
   //tscAsHint = 3 //�� ���������� ������� �� ������������ �� ��� ���������  
}

/*------------------------------------------------------------------------------
   Internal Methods
*/
/*����� vToolBar.iUpdateImageList()
�������� ImageList
*/
method vToolBar.iUpdateImageList()
{
   .ptrImageList = &.GetImageList( .pImageList, &.iNumIml )
   if .ptrImageList
   {
      .WinMsg( $TB_SETIMAGELIST, 0, .ptrImageList->ImageList.arrIml[.iNumIml].hIml )
   }
   else 
   {
      .WinMsg( $TB_SETIMAGELIST, 0, 0 )
   }
   .Invalidate()
}

/*����� vToolBar.iUpdateSize()
����������� ������� ������ � ������� �������
*/
/*method vToolBar.iUpdateSize()
{
   uint width = ?( .pOrientation == $soVertical, this.Width, this.Height ) - 
                     .pToolBarWidth
   
   .pDistance = width - max( int( width - .pDistance ), int( .pRightMinSize ) )
   .pDistance = max( int( .pDistance ), int( .pLeftMinSize ) )
   .pDistance = min( width, int( .pDistance ))   
   
   if *.Comps && .Comps[0]->vComp.TypeIs( vCtrl )
   {
      uint left as .Comps[0]->vCtrl
      left.HorzAlign = $alhLeft
      left.VertAlign = $alvTop
      left.flgNoPosChanging = 0
      left.Left = 0
      left.Top = 0
      if .pOrientation == $soVertical
      { 
         left.Height = this.Height
         left.Width = .pDistance
      }
      else
      {
         left.Height = .pDistance
         left.Width = .Width
      }
      left.flgNoPosChanging = 1
   }
   if *.Comps > 1 && .Comps[1]->vComp.TypeIs( vCtrl )
   {   
      uint right as .Comps[1]->vCtrl
      right.HorzAlign = $alhLeft
      right.VertAlign = $alvTop
      right.flgNoPosChanging = 0
      
      if .pOrientation == $soVertical
      {
         right.Top = 0 
         right.Left = .pDistance + .pToolBarWidth       
         right.Height = this.Height
         right.Width = .Width - .pDistance - .pToolBarWidth
      }
      else
      {
         right.Top = .pDistance + .pToolBarWidth
         right.Left = 0      
         right.Width = this.Width
         right.Height = .Height - .pDistance - .pToolBarWidth
      }
      right.flgNoPosChanging = 1
   }
}*/

/*------------------------------------------------------------------------------
   Properties
*/
/* �������� str vToolBar.ImageList - Get Set
������������� ��� �������� ��� ������ ��������
*/
property ustr vToolBar.ImageList <result>
{
   result = this.pImageList
}

property vToolBar.ImageList( ustr val )
{
   if val != this.pImageList
   { 
      this.pImageList = val
      .Virtual( $mLangChanged )
      //.iUpdateImageList()
   }
}

/* �������� str vToolBar.ShowCaption - Get Set
����� ����������� ����������
*/
property uint vToolBar.ShowCaption
{
   return this.pShowCaption
}

property vToolBar.ShowCaption( uint val )
{
   if val != this.pShowCaption
   { 
      this.pShowCaption = val
      .Virtual( $mReCreateWin )   
/*      uint style = .WinMsg( $TB_GETSTYLE )
      style &= ~( $TBSTYLE_LIST | $TBSTYLE_TRANSPARENT )
      switch val
      {
         case $tscRight: style |= $TBSTYLE_LIST
         case $tscBottom: style |= $TBSTYLE_TRANSPARENT
      }     
      .WinMsg( $TB_SETSTYLE, 0, style )
*/            
   }
}

/* �������� str vToolBar.Wrapable - Get Set
����� ����������� ����������
*/
property uint vToolBar.Wrapable
{
   return this.pWrapable
}

property vToolBar.Wrapable( uint val )
{
   if val != this.pWrapable
   { 
      this.pWrapable = val
      .Virtual( $mReCreateWin )
   }
}


/* �������� str vToolBar.ShowDivider - Get Set
����� ����������� ����������
*/
property uint vToolBar.ShowDivider
{
   return this.pShowDivider
}

property vToolBar.ShowDivider( uint val )
{
   if val != this.pShowDivider
   { 
      this.pShowDivider = val
      .Virtual( $mReCreateWin )
   }
}

/* �������� str vToolBar.AutoSize - Get Set
����� ����������� ����������
*/
property uint vToolBar.AutoSize
{
   return this.pAutoSize
}

property vToolBar.AutoSize( uint val )
{
   if val != this.pAutoSize
   { 
      this.pAutoSize = val
      .Virtual( $mReCreateWin )
   }
}

/* �������� str vToolBar.ButtonWidth - Get Set
����� ����������� ����������
*/
/*property uint vToolBar.AutoSize
{
   return this.pAutoSize
}

property vToolBar.AutoSize( uint val )
{
   if val != this.pAutoSize
   { 
      this.pAutoSize = val
      .Virtual( $mReCreateWin )
   }
}*/

/* �������� str vToolBar.Vertical - Get Set
������������ �����, ��� ������ ������������ �� ������ 
*/
property uint vToolBar.Vertical
{
   return this.pVertical
}

property vToolBar.Vertical( uint val )
{
   if val != this.pVertical
   { 
      this.pVertical = val
      .Virtual( $mReCreateWin )
   }
}

/*------------------------------------------------------------------------------
   Virtual Methods
*/
/*����������� ����� vToolBar vToolBar.mCreateWin 
�������� ����
*/
method vToolBar.AddButton( vToolBarItem newcomp, uint idx )
{
   TBBUTTON tb
   tb.iBitmap = -1
   tb.fsStyle = $TBSTYLE_BUTTON
   tb.fsState = 4
   tb.dwData  = &newcomp   
   tb.idCommand = idx//&newcomp   
   //if newcomp.pStyle == $tbsSeparator : tb.idCommand = -1   
   if .pShowCaption == $tscRight ||  
      .pShowCaption == $tscBottom : tb.iString = "".ustr().ptr() 
   .WinMsg( $TB_INSERTBUTTON, idx, &tb )
}


method vToolBar vToolBar.mCreateWin <alias=vToolBar_mCreateWin>()
{
   //.Visible = 0
   uint style = $WS_CHILD  | $WS_CLIPCHILDREN | 
         /*$WS_CLIPSIBLINGS |*/ $CCS_NOPARENTALIGN | $TBSTYLE_FLAT | 
         $WS_OVERLAPPED | $CCS_NOMOVEY    
   uint exstyle = $TBSTYLE_EX_DRAWDDARROWS    
   //if !.p_designing : style |=     
   if .pWrapable : style |= $TBSTYLE_WRAPABLE
   switch .pShowCaption
   {
      case $tscRight: style |= $TBSTYLE_LIST
      case $tscBottom: style |= $TBSTYLE_TRANSPARENT
      case $tscMixed
      {
         style |= $TBSTYLE_LIST
         exstyle |= $TBSTYLE_EX_MIXEDBUTTONS 
      } 
   }        
   if !.pShowDivider : style |= $CCS_NODIVIDER
   if !.pAutoSize : style |= $CCS_NORESIZE 
         
   .CreateWin( "ToolbarWindow32".ustr(), 0, style )            
   this->vCtrl.mCreateWin()
   .WinMsg( $TB_BUTTONSTRUCTSIZE, sizeof( TBBUTTON ) )
   .WinMsg( $TB_SETEXTENDEDSTYLE, 0, exstyle )
   .WinMsg( $TB_SETTOOLTIPS, this.GetForm()->vForm.hwndTip )
   .WinMsg( $TB_SETINDENT, 2 )
    
   /*SetWindowPos( .hwnd, 0, 0, 0, .Width, .Height-1, $SWP_NOACTIVATE | $SWP_NOMOVE |
      $SWP_NOZORDER)*/
   /*SetWindowPos( .hwnd, 0, 0, 0, .Width, .Height, $SWP_NOACTIVATE | $SWP_NOMOVE |
      $SWP_NOZORDER)*/   
   //.WinMsg( $TB_SETMAXTEXTROWS, 1 )
   //.WinMsg( $TB_SETBUTTONWIDTH, 0,0x400040 )
   //.WinMsg( $TB_SETBUTTONSIZE, 0, 0x100010 )   
   //.Visible = 1  
   uint i 
   .Virtual( $mLangChanged )
   if .pVertical
   {
      .WinMsg( $TB_SETINDENT, 0 )
   }
   
   fornum i = 0, .pCtrls
   {
      .AddButton( .Comps[i]->vToolBarItem, i )
      .Comps[i]->vToolBarItem.iUpdate()
      .Comps[i]->vToolBarItem.mSetVisible()      
   }              
   return this
}

method vToolBar vToolBar.mOwnerCreateWin <alias=vToolBar_mOwnerCreateWin>()
{
   .Virtual( $mReCreateWin )
   return this
}
/*����������� ����� vToolBar.mInsert 
������� �������� ���������
*/


method vToolBar.mInsert <alias=vToolBar_mInsert>( vComp newcomp )
{     
   if newcomp.TypeIs( vToolBarItem ) 
   {   
      this->vCtrl.mInsert( newcomp )
      .AddButton( newcomp->vToolBarItem, *.Comps - 1 )                    
          
//      print( "insert \( &newcomp )\n" )               
   }      
}

method vToolBar.mReCreateWin <alias=vToolBar_mReCreateWin> ()
{
   uint i
   this->vCtrl.mReCreateWin()
   
   
   //.iUpdateImageList()   
}

/*����������� ����� vToolBar.mRemove 
�������� �������� ���������
*/
method vToolBar.mRemove <alias=vToolBar_mRemove>( vComp item )
{  
   if item.TypeIs( vToolBarItem ) 
   {
      //print( "remove\n" )   
      .WinMsg( $TB_DELETEBUTTON, .WinMsg( $TB_COMMANDTOINDEX, item->vVirtCtrl.pIndex ))//cidx ) )
   }
   this->vCtrl.mRemove( item )
}


type NMCUSTOMDRAWINFO {
    NMHDR hdr;
    uint dwDrawStage;
    uint hdc;
    RECT rc;
    uint dwItemSpec;
    uint uItemState;
    uint lItemlParam;
}

/*����������� ����� vToolBar.mWinNtf 
��������� ��������� WM_COMMAND
*/
method uint vToolBar.mWinCmd <alias=vToolBar_mWinCmd>( uint ntfcmd, uint id )
{
   if id < *.Comps
   {
      uint item as .Comps[id]->vToolBarItem
      if item.pTBIStyle == $tbsAsRadioBtn 
      {         
         item.Checked = 1         
      }
      elif item.pTBIStyle == $tbsAsCheckBox 
      {                          
         item.Checked = !item.pChecked//( .WinMsg( $BM_GETCHECK ) == $BST_CHECKED )                
      }
      evparEvent ev
      ev.sender = &item
      item.OnClick.Run( ev )
   }    
   return 0
}

/*����������� ����� vToolBar.mWinNtf 
��������� ��������� WM_NOTIFY
*/
method uint vToolBar.mWinNtf  <alias=vToolBar_mWinNtf >( winmsg wmsg )//NMHDR ntf )
{   
   uint ntf as wmsg.lpar->NMHDR
   switch  ntf.code
   {
      case $NM_CLICK
      {
         /*uint ntftb = &ntf
         ntftb as NMTOOLBAR
         if ntftb.iItem && ntftb.iItem !=-1
         {
            if ntftb.iItem->vToolBarItem.pTBIStyle == $tbsAsRadioBtn 
            {
               ntftb.iItem->vToolBarItem.Checked = 1
             
            }
            elif ntftb.iItem->vToolBarItem.pTBIStyle == $tbsAsCheckBox 
            {                          
               ntftb.iItem->vToolBarItem.Checked = !ntftb.iItem->vToolBarItem.pChecked//( .WinMsg( $BM_GETCHECK ) == $BST_CHECKED )                
            }
         //print( "Click \(ntf.idFrom) \(ntf.code) \(ntftb.iItem)\n" )
            evparEvent ev
            ev.sender = ntftb.iItem      
            ntftb.iItem->vToolBarItem.OnClick.Run( ev )
         }*/
      }
      case $TBN_DROPDOWN 
      {     
         ntf as NMTOOLBAR
         //uint ntftb as (&ntf)->NMTOOLBAR
         //ntftb as NMTOOLBAR
         uint item as .Comps[ntf.iItem]->vToolBarItem
         //if //ntftb.iItem && ntftb.iItem !=-1
         {         
            if /*ntftb.iItem->vToolBarItem*/item.pDropDownMenu
            {
               POINT pnt
               pnt.x = item.Left//ntftb.iItem->vToolBarItem.Left
               pnt.y = item.Top + item.Height//ntftb.iItem->vToolBarItem.Top + ntftb.iItem->vToolBarItem.Height
               ClientToScreen( this.hwnd, pnt )
               /*ntftb.iItem->vToolBarItem*/item.DropDownMenu.Show( item, pnt.x, pnt.y )
            }
         }  
      }
      case $NM_CUSTOMDRAW
      {
         if !isThemed
         {
            //uint ntftb = &ntf
            ntf as NMCUSTOMDRAWINFO            
            FillRect( ntf.hdc, ntf.rc, GetSysColorBrush($COLOR_BTNFACE)  )
         }
      }
   }
   return 0
}


/*����������� �����  vToolBar.mLangChanged - ��������� �������� �����
*/
method vToolBar.mLangChanged <alias=vToolBar_mLangChanged>()
{
   .iUpdateImageList()
   this->vCtrl.mLangChanged() 
}

method vToolBar.mGetHint <alias=vToolBar_mGetHint>( uint id, uint lpar, ustr resstr )
{
   uint item as this.Comps[id]->vToolBarItem//id->vToolBarItem
   if  !*item.pHint.Text( this ) //.pShowCaption == $tscAsHint && 
   {      
      resstr = item.pCaption.Text( this )   
   }  
   else :resstr = item.pHint.Text( this )     
}

/*����������� ����� vToolBar.mPosChanged - ���������� �������
*/
method vToolBar.mPosChanged <alias=vToolBar_mPosChanged>(evparEvent ev)
{
   this->vCtrl.mPosChanged(ev)
   if .pVertical 
   {
      .WinMsg( $TB_SETBUTTONWIDTH, 0, (.clloc.width - 2 ) << 16 | .clloc.width - 2 )
      .WinMsg( $TB_AUTOSIZE )
   }   
}

method vToolBar.mSetDefFont <alias=vToolBar_mSetDefFont>( )
{
   .Virtual( $mReCreateWin )  
}   

/*����������� ����� vToolBar.mPosChanging 
��������� ��������
*/
/*method vToolBar.mPosChanging <alias=vToolBar_mPosChanging>( eventpos evp )
{
   this->vCtrl.mPosChanging( evp )
   switch .pFixedPart
   {
      case $sfpRight
      {
         .pDistance += evp.loc.width - .Width 
      }
      case $sfpNone
      {
         .pDistance = uint(  .pProportion * double( evp.loc.width ) )
      }
   }
   .iUpdateSize()
}
*/
/*����������� ����� vToolBar.mMouse
��������� �� �����
*/
/*method uint vToolBar.mMouse <alias=vToolBar_mMouse> ( evparMouse ev )
{ 
   switch ev.evmtype 
   {
      case $evmMove
      {
         if .fDrag
         {              
            .Distance = ?( .pOrientation == $soVertical, ev.x, ev.y )            
         }
      }
      case $evmLDown 
      {
         if !.fDrag
         {
            .fDrag = 1
            SetCapture( .hwnd )
         }
      }
      case $evmLUp
      {
         if .fDrag : ReleaseCapture()
      }      
   }
   
   if .pOrientation == $soVertical
   { 
      if ev.x > .pDistance && ev.x <= .pDistance + .pToolBarWidth
      {
         SetCursor( App.cursorSizeWE )
      }
   }
   else
   {
      if ev.y > .pDistance && ev.y <= .pDistance + .pToolBarWidth
      {
         SetCursor( App.cursorSizeNS )            
      }
   } 
   return this->vCtrl.mMouse( ev )
}
*/

/*------------------------------------------------------------------------------
   Windows messages 
*/

/*------------------------------------------------------------------------------
   Registration
*/
/*��������� ����� vToolBar vToolBar.init
������������� �������
*/   
method vToolBar vToolBar.init( )
{  
   this.pTypeId     = vToolBar
   this.pCanContain = 1      
   this.loc.width   = 200
   this.loc.height  = 100
   return this 
}

method vToolBarItem vToolBarItem.init( )
{  
   this.pTypeId     = vToolBarItem
   this.loc.left    = 0
   this.loc.top     = 0
   this.loc.width   = 100
   this.loc.height  = 100   
   this.pImageIndex = -1
   return this 
}    

//������� �����������
func init_vToolBar <entry>()
{  
   regcomp( vToolBar, "vToolBar", vCtrl, $vCtrl_last, 
      %{ %{$mCreateWin,  vToolBar_mCreateWin},
         %{$mReCreateWin,vToolBar_mReCreateWin},
         %{$mInsert,     vToolBar_mInsert },
         %{$mRemove,     vToolBar_mRemove },
         %{$mLangChanged,vToolBar_mLangChanged},
         %{$mWinNtf,     vToolBar_mWinNtf },
         %{$mGetHint,    vToolBar_mGetHint },
         %{$mWinCmd,     vToolBar_mWinCmd },
         %{$mPosChanged, vToolBar_mPosChanged },
         %{$mOwnerCreateWin, vToolBar_mOwnerCreateWin },
         %{$mSetDefFont, vToolBar_mSetDefFont }
      },       
      0->collection
      /*%{ %{$WM_CAPTURECHANGED, vToolBar_wmcapturechanged }
      }*/)
      
   regcomp( vToolBarItem, "vToolBarItem", vVirtCtrl, $vVirtCtrl_last, 
      %{ %{$mCreateWin,  vToolBarItem_mCreateWin},
         %{$mPosUpdate,  vToolBarItem_mPosUpdate},
         %{$mSetVisible, vToolBarItem_mSetVisible},
         %{$mSetEnabled, vToolBarItem_mSetEnabled},
         %{$mLangChanged,vToolBarItem_mLangChanged},
         %{$mSetName,    vToolBarItem_mSetName},
         %{$mSetIndex,   vToolBarItem_mSetIndex}         
      },
      //0->collection, 
      0->collection
      /*%{ %{$WM_CAPTURECHANGED, vToolBar_wmcapturechanged }
      }*/)                  
            
ifdef $DESIGNING {
   cm.AddComp( vToolBar, 1, "Windows", "toolbar" )
   cm.AddProps( vToolBar, %{
"ImageList", ustr, 0,
"ShowCaption", uint, 0,
"Wrapable",    uint, 0,
"ShowDivider", uint, 0,
"AutoSize",    uint, 0,
"Vertical",    uint, 0
   })
   
      cm.AddPropVals( vToolBar, "ShowCaption", %{ 
"tscNone",  $tscNone,  
"tscRight", $tscRight,  
"tscBottom",$tscBottom,
"tscMixed", $tscMixed/*, 
"tscAsHint",$tscAsHint*/
   })
   
   cm.AddComp( vToolBarItem ) 
   cm.AddProps( vToolBarItem, %{
"TBIStyle", uint, 0,
"Caption", ustr, 0,
"Checked", uint, 0,
"ImageId", ustr, 0,
"DropDownMenu", vPopupMenu, $PROP_LOADAFTERCREATE,
"ShowCaption", uint, 0,
"Index", uint, 0
   })
   
   cm.AddPropVals( vToolBarItem, "TBIStyle", %{ 
"tbsButton",      $tbsButton,    
"tbsSeparator",   $tbsSeparator,  
"tbsDropDown",    $tbsDropDown,   
"tbsAsCheckBox",  $tbsAsCheckBox,      
"tbsAsRadioBtn",  $tbsAsRadioBtn
   })
   
  cm.AddEvents( vToolBarItem, %{
"OnClick"      , "evparEvent"
   }) 
}
      
}
