/******************************************************************************
*
* Copyright (C) 2004-2007, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: vis.dlgbtns 19.06.09 0.0.A.
*
* Author: Alexander Krivonogov ( gentee )
*
******************************************************************************/

include {
   "btnpic.g"
   "panel.g"
}


type vDlgBtns <inherit = vPanel>
{
   uint    pIndent
   uint    pShowLine
   uint    pShowHelp
   uint    pShowApply
   uint    pShowCancel
   uint    pShowClose
   uint    pShowDone
   uint    pShowCustom
   uint    pDisableNext
   uint    pWizard
   uint    pCurWizard 
   uint    pMaxWizard
   ustr    pCustomCaption
   uint    pCustomWidth
   vPanel  pLine
   vBtnPic btnHelp
   vBtnPic btnCancel
   vBtnPic btnOk
   vBtnPic btnApply
   vBtnPic btnPrev
   vBtnPic btnNext
   vBtnPic btnClose
   vBtnPic btnCustom
   evEvent OnApply
   evValUint OnWizard 
   evEvent   OnCustomClick
   evEvent OnClose
       
}

define {
//Тип vDlgBtns.ShowDone
   dsdNone = 0 
   dsdAlways = 0x1
   dsdLast = 0x2
}

/*------------------------------------------------------------------------------
   Internal Methods
*/
method vDlgBtns.iUpdate()
{
//print( "iupdate1\n" )
   .pLine.Visible = .pShowLine
   .pLine.Left = .pIndent
   .pLine.Right = .pIndent
   
   .btnHelp.Visible = .pShowHelp
   .btnHelp.Left = .pIndent
   
   .btnApply.Visible = .pShowApply   
   
   .btnCancel.Visible = .pShowCancel 
   
   .btnCustom.Visible = .pShowCustom
    
   if .pWizard 
   {              
      .btnOk.Caption = "done".ustr()
      .btnPrev.Visible = 1
      .btnPrev.Enabled = .pCurWizard//.pWizard & 0x10
      .btnNext.Visible = ?( .pShowDone == $dsdLast, 0, 1 ) || ( .pCurWizard < .pMaxWizard )//(.pWizard & 0x01) 
      .btnNext.Enabled = (!.pDisableNext) && ( .pCurWizard < .pMaxWizard )//(.pWizard & 0x01) && 
      .btnOk.Visible = .pShowDone == $dsdAlways || ( .pShowDone == $dsdLast && !( .pCurWizard < .pMaxWizard ) )//!(.pWizard & 0x01)
      //.btnOk.Enabled = !.pDisableNext
      .btnClose.Visible = .pShowClose
   }
   else
   {
      .btnOk.Caption = "ok".ustr()
      .btnNext.Visible = 0
      .btnPrev.Visible = 0      
      .btnOk.Visible = !.pShowClose
      .btnClose.Visible = .pShowClose
   }
   
   
   uint right
   if .pShowApply 
   {
      .btnApply.Right = right + .pIndent   
      right = .btnApply.Right + .btnApply.Width
   } 
   if .btnCancel.Visible
   {  
      .btnCancel.Right = right + .pIndent   
      right = .btnCancel.Right + .btnCancel.Width
   }   
   right += .pIndent
   if .btnOk.Visible 
   {   
      .btnOk.Right = right     
      right = .btnOk.Right + .btnOk.Width
   }
   elif .btnClose.Visible
   {
      .btnClose.Right = right
      right = .btnClose.Right + .btnClose.Width + .pIndent
   }
   if .btnNext.Visible
   {
      .btnNext.Right = right   
      right = .btnNext.Right + .btnNext.Width
   }
   if .btnPrev.Visible
   {
      .btnPrev.Right = right
      right = .btnPrev.Right + .btnNext.Width
   }
   if .btnCustom.Visible
   {
      .btnCustom.Right = right + .pIndent
   }
//print( "iupdate10\n" )     
}
   
   
/*------------------------------------------------------------------------------
   Properties
*/
/* Свойство uint vDlgBtns.ShowHelp - Get Set
Показывать кнопку help
*/
property uint vDlgBtns.ShowHelp 
{
   return this.pShowHelp
}

property vDlgBtns.ShowHelp( uint val )
{
   if val != this.pShowHelp
   { 
      this.pShowHelp = val
      .iUpdate()
   } 
}   

/* Свойство uint vDlgBtns.ShowApply - Get Set
Показывать кнопку apply
*/
property uint vDlgBtns.ShowApply 
{
   return this.pShowApply
}

property vDlgBtns.ShowApply( uint val )
{
   if val != this.pShowApply
   { 
      this.pShowApply = val
      .iUpdate()
   } 
}   

/* Свойство uint vDlgBtns.ShowCancel - Get Set
Показывать кнопку cancel
*/
property uint vDlgBtns.ShowCancel 
{
   return this.pShowCancel
}

property vDlgBtns.ShowCancel( uint val )
{
   if val != this.pShowCancel
   { 
      this.pShowCancel = val
      .iUpdate()
   } 
}

/* Свойство uint vDlgBtns.ShowClose - Get Set
Показывать кнопку close вместо cancel
*/
property uint vDlgBtns.ShowClose 
{
   return this.pShowClose
}

property vDlgBtns.ShowClose( uint val )
{
   if val != this.pShowClose
   { 
      this.pShowClose = val
      .iUpdate()
   } 
}

/* Свойство uint vDlgBtns.ShowCustom - Get Set
Показывать кнопку Custom 
*/
property uint vDlgBtns.ShowCustom 
{
   return this.pShowCustom
}

property vDlgBtns.ShowCustom( uint val )
{
   if val != this.pShowCustom
   { 
      this.pShowCustom = val
      .iUpdate()
   } 
}         

/* Свойство uint vDlgBtns.ShowLine - Get Set
Показывать кнопку help
*/
property uint vDlgBtns.ShowLine
{
   return this.pShowLine
}

property vDlgBtns.ShowLine( uint val )
{
   if val != this.pShowLine
   { 
      this.pShowLine = val
      .iUpdate()
   } 
}

/* Свойство uint vDlgBtns.ShowDone - Get Set
Показывать кнопку готово если включен Wizard
*/
property uint vDlgBtns.ShowDone
{
   return this.pShowDone
}

property vDlgBtns.ShowDone( uint val )
{
   if val != this.pShowDone
   { 
      this.pShowDone = val
      .iUpdate()
   } 
}

/* Свойство uint vDlgBtns.Wizard - Get Set
Показывать кнопки Назад Далее Готово
*/
property uint vDlgBtns.Wizard
{
   return this.pWizard
}

property vDlgBtns.Wizard( uint val )
{
   if val != this.pWizard
   { 
      this.pWizard = val
      .iUpdate()
   } 
}

/* Свойство uint vDlgBtns.CurWizard - Get Set
Текущее положение Wizard
*/
property uint vDlgBtns.CurWizard
{
   return this.pCurWizard
}

property vDlgBtns.CurWizard( uint val )
{
   val == min( val, .pMaxWizard )
   if val != this.pCurWizard
   {  
      this.pCurWizard = val
      .iUpdate()
      evparValUint evp
      evp.val = .pCurWizard
      .OnWizard.Run(evp, this)
   } 
}

/* Свойство uint vDlgBtns.MaxWizard - Get Set
Текущее положение Wizard
*/
property uint vDlgBtns.MaxWizard
{
   return this.pMaxWizard
}

property vDlgBtns.MaxWizard( uint val )
{
   if val != this.pMaxWizard
   { 
      this.pMaxWizard = val
      .iUpdate()
   } 
}

/* Свойство uint vDlgBtns.DisableNext - Get Set
Показывать кнопки Назад Далее Готово
*/
property uint vDlgBtns.DisableNext
{
   return this.pDisableNext
}

property vDlgBtns.DisableNext( uint val )
{
   if val != this.pDisableNext
   { 
      this.pDisableNext = val
      .iUpdate()
   } 
}

/* Свойство uint vDlgBtns.Indent - Get Set
Значение отступа
*/
property uint vDlgBtns.Indent
{
   return this.pIndent
}

property vDlgBtns.Indent( uint val )
{
   if val != this.pIndent
   { 
      this.pIndent = val
      .iUpdate()
   } 
}


/* Свойство ustr vDlgBtns.CustomCaption - Get Set
Заголовок custom кнопки
*/
property ustr vDlgBtns.CustomCaption <result> ()
{
   result = .pCustomCaption
}

property vDlgBtns.CustomCaption( ustr val )
{
   if .pCustomCaption != val
   {
      .pCustomCaption = val
      this.btnCustom.Caption = val
   }    
}

/* Свойство uint vDlgBtns.CustomWidth - Get Set
Ширина custom кнопки
*/
property uint vDlgBtns.CustomWidth ()
{
   return .pCustomWidth
}

property vDlgBtns.CustomWidth( uint val )
{
   if .pCustomWidth != val
   {
      .pCustomWidth = val
      this.btnCustom.Width = val
   }    
}

/*------------------------------------------------------------------------------
   Event Processor
*/
method uint vDlgBtns.Ok <alias=vDlgBtns_Ok>( evparEvent evn )
{   
   if !.OnApply.id || .OnApply.Run(evn) : .GetMainForm()->vForm.Result = 1
   return 0
}

method uint vDlgBtns.Wizard <alias=vDlgBtns_Wizard>( evparEvent evn )
{   
   evparValUint evp
   uint val = .pCurWizard
   if evn.sender == &.btnNext : val++
   else : val--
   .CurWizard = val 
   //evp.val = .pCurWizard
   //if !.pCurWizard : .Wizard = $dbFirst
   //else : .Wizard = $dbMedium 
   //.OnWizard.Run(evp, this) 
   return 0
}

method uint vDlgBtns.Cancel <alias=vDlgBtns_Cancel>( evparEvent evn )
{
   .GetMainForm()->vForm.Result = -1   
   return 0
}

method uint vDlgBtns.Close <alias=vDlgBtns_Close>( evparEvent evn )
{
   if .OnClose.id
   {    
      evparEvent evn
      .GetMainForm()->vForm.Result = .OnClose.Run( evn, this )
   }
   else : .GetMainForm()->vForm.Result = -1   
   return 0
}

method uint vDlgBtns.Custom <alias=vDlgBtns_Custom>( evparEvent evn )
{
   .OnCustomClick.Run( evn )   
   return 0
}

method uint vDlgBtns.Help <alias=vDlgBtns_Help>( evparEvent evn )
{   
   .GetForm()->vCtrl.Help()
   return 0
}

method uint vDlgBtns.Apply <alias=vDlgBtns_Apply>( evparEvent evn )
{
   .OnApply.Run( evn )   
   return 0
}

/*------------------------------------------------------------------------------
   Registration
*/

method vDlgBtns vDlgBtns.init( )
{
   this.pTypeId = vDlgBtns
   .pAlign =  $alhClient | $alvBottom
   .loc.height = 60
   .pBorder = $brdNone
   .pShowHelp = 1
   .pShowLine = 1   
   .pShowCancel = 1
   .pIndent = 15
   .pCustomWidth = 100
   return this 
}  

method vDlgBtns vDlgBtns.mCreateWin <alias=vDlgBtns_mCreateWin>()
{   
   uint indent = 5
   collection ccaption = %{ "prev", "next", "ok", "cancel", "help", "apply", "close", "" }
   collection cimage = %{ "", "", "main\\bok", "main\\bcancel", "main\\bhelp", "main\\brefresh", "main\\bcancel", "" }
   collection cbtn = %{ &.btnPrev, &.btnNext, &.btnOk, &.btnCancel, &.btnHelp, &.btnApply, &.btnClose, &.btnCustom }
   collection cevent = %{ vDlgBtns_Wizard, vDlgBtns_Wizard, vDlgBtns_Ok, vDlgBtns_Cancel, vDlgBtns_Help, vDlgBtns_Apply, vDlgBtns_Close, vDlgBtns_Custom }
   uint i, left 
   this->vPanel.mCreateWin()
   fornum i=0, *cbtn
   {
      uint btn as cbtn[i]->vBtnPic      
      btn.Caption = ccaption[i]->str.ustr()
      btn.Image = cimage[i]->str.ustr()
      btn.VertAlign = $alvCenter      
      btn.Owner = this
      btn.Height = 30 
      btn.OnClick.Set( &this, cevent[i] )
      if &btn != &.btnHelp :  btn.HorzAlign = $alhRight      
   }
   
   .pLine.Top = 0   
   .pLine.Border = $brdLowered
   .pLine.Caption = "".ustr()
   .pLine.HorzAlign = $alhLeftRight
   .pLine.Owner = this
   .pLine.Height = 2
   .Caption = "".ustr()
   .btnCustom.Caption = .pCustomCaption
   .btnCustom.Width = .pCustomWidth
   .iUpdate()
   return this 
}

func init_vDlgBtns <entry>()
{
   
   regcomp( vDlgBtns, "vDlgBtns", vPanel, $vCtrl_last,        
         %{ %{ $mCreateWin, vDlgBtns_mCreateWin },
            %{ $mSetName,   0 } },
      0->collection )                        
      
ifdef $DESIGNING {
   cm.AddComp( vDlgBtns, 1, "Windows", "dlgbtns" )
   cm.AddProps( vDlgBtns, %{ 
            "ShowLine" , uint, 0,
            "ShowHelp" , uint, 0,
            "ShowApply", uint, 0,
            "ShowCancel", uint, 0,
            "ShowClose", uint, 0,
            "ShowDone", uint, 0,
            "ShowCustom", uint, 0,
            "DisableNext", uint, 0,
            "Wizard", uint, 0,
            "Indent"   , uint, 0,
            "CurWizard", uint, 0,
            "MaxWizard", uint, 0,
            "CustomCaption", ustr, 0,
            "CustomWidth", uint, 0
             } )
    cm.AddEvents( vDlgBtns, %{
"OnApply"    , "evparEvent",
"OnWizard"   , "evparValUint",
"OnCustomClick"    , "evparEvent",
"OnClose"    , "evparEvent"
   } )
   
   cm.AddPropVals( vDlgBtns, "ShowDone", %{
"dsdNone"    ,$dsdNone,
"dsdAlways"   ,$dsdAlways,          
"dsdLast"  ,$dsdLast
   })    
}
} 