/******************************************************************************
*
* Copyright (C) 2004-2007, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: vis.labeled 17.07.07 0.0.A.
*
* Author: Alexander Krivonogov ( gentee )
*
******************************************************************************/

include {
   "edit.g"
   "btnpic.g"
   "combobox.g"
   "label.g"
}


type vLabelCon <inherit = vLabel>
{
   uint pLabelPos
   uint pAddColon
   uint LabeledCtrl
   uint fConCreate
}

/* Компонента vLabeledEditOld, порождена от vEdit
*/
/*type vLabeledEditOld <inherit = vEdit>
{
   vLabelCon LabelCon      
}*/

type vLabeledComboBox <inherit = vComboBox>
{  
   vLabelCon LabelCon     
}

type vLabeledEdit <inherit = vCtrl>
{
   vLabelCon LabelCon    
   vEdit     Edit
   //vBtnPic   Btn1
   //vBtnPic   Btn2
   ustr      pBtn1Image
   ustr      pBtn2Image
   
   locustr      pBtn1Hint
   locustr      pBtn2Hint
   
   uint      pBtn1
   uint      pBtn2
   
   uint      pLEStyle
   
   evEvent   OnBtn1Click
   evEvent   OnBtn2Click   
   evEvent   OnChange   
   evEvent   OnFocus 
}

define <export>{
//Положение подписи LabelPos
   lpLeft    = 0 
   lpAbove   = 1
   
//Стили LabeledEdit.LEStyle   
   lsSimple = 0
   lsOneBtn = 1
   lsTwoBtns = 2   
}

extern {
   method vLabelCon.ConPosChanging()
}

/*------------------------------------------------------------------------------
   Internal Methods
*/
method vLabeledEdit.iUpdateBtns()
{
   uint rightedit
   uint height
   if this.pBtn1
   {
      if this.Edit.Multiline : height = 25
      else : height = max( min( this.Edit.Height, 50 ), 20 )
      this.pBtn1->vBtnPic.Width = height
      this.pBtn1->vBtnPic.Height = height
      rightedit = 2 + height
      if this.pBtn2
      {  
         this.pBtn2->vBtnPic.Width = height
         this.pBtn2->vBtnPic.Height = height
         this.pBtn2->vBtnPic.Right = 0
         if this.Edit.Multiline && 
            this.Edit.Height > 50
         {
            this.pBtn2->vBtnPic.Top = height
            this.pBtn1->vBtnPic.Right = 0         
         }
         else
         {
            this.pBtn2->vBtnPic.Top = 0
            this.pBtn1->vBtnPic.Right = height            
            rightedit += this.pBtn2->vBtnPic.Width
         } 
      }   
      else 
      {
         this.pBtn1->vBtnPic.Right = 0
      }   
   }
   this.Edit.Width = .Width - rightedit   
   this.LabelCon.ConPosChanging()
}
   

/*------------------------------------------------------------------------------
   Properties
*/
/* Свойство str vLabeledEditOld.Caption - Get Set
Усотанавливает или получает заколовок панели
*/
/*property ustr vLabeledEditOld.Caption <result>
{
   result = .LabelCon.Caption  
}

property vLabeledEditOld.Caption( ustr val )
{
   .LabelCon.Caption = val    
}*/

property ustr vLabeledComboBox.Caption <result>
{
   result = .LabelCon.Caption  
}

property vLabeledComboBox.Caption( ustr val )
{
   .LabelCon.Caption = val    
}

property ustr vLabeledEdit.Caption <result>
{
   result = .LabelCon.Caption  
}

property vLabeledEdit.Caption( ustr val )
{
   .LabelCon.Caption = val    
}

property ustr vLabeledEdit.Hint <result>
{
   result = .Edit.Hint  
}

property vLabeledEdit.Hint( ustr val )
{
   .Edit.Hint = val    
}

method vLabelCon.mSetCaption <alias=vLabelCon_mSetCaption>( ustr caption )
{   
   if *caption && caption[ *caption - 1 ] != ':'
   {
      caption += ":"
   }
   this->vLabel.mSetCaption( caption )  
}

/*Виртуальный метод uint vLabel.mLangChanged - Изменение текущего языка
*/
method vLabelCon.mLangChanged <alias=vLabelCon_mLangChanged>()
{   
   this->vLabel.mLangChanged()
   .ConPosChanging()
}

method vLabelCon.mCreateWin <alias=vLabelCon_mCreateWin>()
{   
   this->vLabel.mCreateWin()
   .ConPosChanging()
}

method vLabelCon.mPreDel <alias=vLabelCon_mPreDel>()
{   
   this->vLabel.mPreDel()
   .LabeledCtrl = 0
}


property uint vLabelCon.AddColon
{
   return .pAddColon  
}

property vLabelCon.AddColon( uint val )
{
   if .pAddColon != val
   {
      .pAddColon = val
      
   }
}

method vLabelCon.iSetLabelPos
{
   .AutoSize = 0
   if .pLabelPos == $lpLeft
   {
      .HorzAlign = $alhRight
   }
   else
   {       
         
      .HorzAlign = $alhLeft
      //.iUpdateSize()
   }
   .AutoSize = 1       
   .ConPosChanging()
}

property uint vLabelCon.LabelPos
{
   return .pLabelPos  
}

property vLabelCon.LabelPos( uint val )
{
   if .pLabelPos != val
   {
      .pLabelPos = val
      .iSetLabelPos()
   }   
}


/*property uint vLabeledEditOld.LabelPos
{
   return .LabelCon.LabelPos  
}

property vLabeledEditOld.LabelPos( uint val )
{
   .LabelCon.LabelPos = val   
}*/

property uint vLabeledComboBox.LabelPos
{
   return .LabelCon.LabelPos  
}

property vLabeledComboBox.LabelPos( uint val )
{
   .LabelCon.LabelPos  = val   
}  

property uint vLabeledEdit.LabelPos
{
   return .LabelCon.LabelPos  
}

property vLabeledEdit.LabelPos( uint val )
{
   .LabelCon.LabelPos  = val   
}  


property uint vLabeledComboBox.AddColon
{
   return .LabelCon.AddColon  
}

property vLabeledComboBox.AddColon( uint val )
{
   .LabelCon.AddColon  = val   
}  

property uint vLabeledEdit.AddColon
{
   return .LabelCon.AddColon  
}

property vLabeledEdit.AddColon( uint val )
{
   .LabelCon.AddColon  = val   
}  

property ustr vLabeledEdit.Text <result>
{
   result = .Edit.Text  
}

property vLabeledEdit.Text( ustr val )
{
   .Edit.Text  = val   
}


property vLabeledEdit.Enabled( uint val )
{   
   .Edit.Enabled  = val
   if .pBtn1 : .pBtn1->vBtnPic.Enabled = val
   if .pBtn2 : .pBtn2->vBtnPic.Enabled = val   
}

property uint vLabeledEdit.ReadOnly 
{
   return .Edit.ReadOnly  
}

property vLabeledEdit.ReadOnly( uint val )
{
   .Edit.ReadOnly = val   
}

property uint vLabeledEdit.Password
{   
   return  .Edit.pPassword
}

property vLabeledEdit.Password( uint val )
{
   .Edit.Password = val   
}

property uint vLabeledEdit.Multiline
{   
   return  .Edit.Multiline
}

property vLabeledEdit.Multiline( uint val )
{
   .Edit.Multiline = val
   .iUpdateBtns()   
}

property uint vLabeledEdit.WordWrap
{   
   return  .Edit.WordWrap
}

property vLabeledEdit.WordWrap( uint val )
{
   .Edit.WordWrap = val
   .iUpdateBtns()   
}

property uint vLabeledEdit.ScrollBars
{   
   return  .Edit.ScrollBars
}

property vLabeledEdit.ScrollBars( uint val )
{
   .Edit.ScrollBars = val   
}

property uint vLabeledEdit.MaxLen
{
   return .Edit.MaxLen  
}

property vLabeledEdit.MaxLen( uint val )
{
   .Edit.MaxLen = val   
}

property ustr vLabeledEdit.Btn1Image <result>
{   
   result = .pBtn1Image  
}

property vLabeledEdit.Btn1Image( ustr val )
{
   if .pBtn1Image != val
   {
      .pBtn1Image = val
      if .pBtn1
      {
         .pBtn1->vBtnPic.Image = val
      }  
   }   
}

property ustr vLabeledEdit.Btn2Image <result>
{   
   result = .pBtn2Image  
}

property vLabeledEdit.Btn2Image( ustr val )
{
   if .pBtn2Image != val
   {
      .pBtn2Image = val
      if .pBtn2
      {
         .pBtn2->vBtnPic.Image = val
      }  
   }   
}



property ustr vLabeledEdit.Btn1Hint <result>
{   
   result = .pBtn1Hint  
}

property vLabeledEdit.Btn1Hint( ustr val )
{
   if .pBtn1Hint != val
   {
      .pBtn1Hint = val
      if .pBtn1
      {
         .pBtn1->vBtnPic.Hint = val
      }  
   }   
}

property ustr vLabeledEdit.Btn2Hint <result>
{   
   result = .pBtn2Hint  
}

property vLabeledEdit.Btn2Hint( ustr val )
{
   if .pBtn2Hint != val
   {
      .pBtn2Hint = val
      if .pBtn2
      {
         .pBtn2->vBtnPic.Hint = val
      }  
   }   
}

property uint vLabeledEdit.LEStyle()
{
   return .pLEStyle
}

property vLabeledEdit.LEStyle( uint val )
{
   if .pLEStyle != val
   {
      .pLEStyle = val
      .Virtual( $mReCreateWin )
   }
}

/*------------------------------------------------------------------------------
   Virtual methods
*/
method vLabelCon.ConCreateWin( vCtrl LabeledCtrl )
{    
   if !.fConCreate 
   {
      .fConCreate = 1
      .LabeledCtrl = &LabeledCtrl      
      //.Caption = "a".ustr()
      .AutoSize = 1   
      .TextVertAlign = $talvCenter
      //.HorzAlign = $alhRight   
      .AddColon = 1   
      .iSetLabelPos()   
   }   
}

method vLabelCon.ConSetOwner()
{
   .Owner = .LabeledCtrl->vCtrl.Owner
}

method vLabelCon.ConSetName( str newname )
{
   ifdef $DESIGNING {      
   if .LabeledCtrl && !.LabeledCtrl->vCtrl.p_loading && ( !*.Caption || .Caption == newname.ustr() )
   {
      .Caption = newname.ustr()
   }
}  
   return 
}

method vLabelCon.ConPosChanging()
{  
   if .LabeledCtrl
   {   
      if .pLabelPos == $lpLeft
      {
         .Top = .LabeledCtrl->vCtrl.Top
         .Height = .LabeledCtrl->vCtrl.Height         
         .Right = .LabeledCtrl->vCtrl.Owner->vCtrl.clloc.width - .LabeledCtrl->vCtrl.Left + 5
      }
      else   
      {
         
         .Left = .LabeledCtrl->vCtrl.Left + 5
         //.Width = .LabeledCtrl->vCtrl.Width
         .Top = .LabeledCtrl->vCtrl.Top - .Height - 3
      }
   }
}

/*method vLabeledEditOld vLabeledEditOld.mCreateWin <alias=vLabeledEditOld_mCreateWin>()
{  
   this->vEdit.mCreateWin()   
   this.LabelCon.ConCreateWin( this )      
   return this
}

method vLabeledEditOld.mSetOwner <alias=vLabeledEditOld_mSetOwner>( vComp newowner )
{
   this->vEdit.mSetOwner( newowner )
   this.LabelCon.ConSetOwner( )
}

method uint vLabeledEditOld.mSetName <alias=vLabeledEditOld_mSetName>( str newname )
{
   this.LabelCon.ConSetName( newname )
   return 1 
}

method vLabeledEditOld.mPosChanging <alias=vLabeledEditOld_mPosChanging>( eventpos evp )
{  
   this->vEdit.mPosChanging( evp )
   this.LabelCon.ConPosChanging()
}
*/
method vLabeledComboBox vLabeledComboBox.mCreateWin <alias=vLabeledComboBox_mCreateWin>()
{  
   this->vComboBox.mCreateWin()
   this.LabelCon.ConCreateWin( this )   
   return this
}


method vLabeledComboBox.mSetOwner <alias=vLabeledComboBox_mSetOwner>( vComp newowner )
{
   if newowner : this.LabelCon.LabeledCtrl = &this
   else : this.LabelCon.LabeledCtrl = 0
   this->vComboBox.mSetOwner( newowner )
   if newowner : this.LabelCon.ConSetOwner( )
}

method uint vLabeledComboBox.mSetName <alias=vLabeledComboBox_mSetName>( str newname )
{
   this.LabelCon.ConSetName( newname )
   return 1 
}

method vLabeledComboBox.mPosChanging <alias=vLabeledComboBox_mPosChanging>( eventpos evp )
{  
   this->vComboBox.mPosChanging( evp )
   this.LabelCon.ConPosChanging()
}

method vLabeledComboBox.mSetVisible <alias=vLabeledComboBox_mSetVisible>( )
{
   this->vCtrl.mSetVisible()
   .LabelCon.Visible = .Visible
}


method uint vLabeledEdit.EditChange <alias=vLabeledEdit_EditChange>( evparEvent evn )
{
   evn.sender = &this   
   return .OnChange.Run( evn )
}

method uint vLabeledEdit.EditFocus <alias=vLabeledEdit_EditFocus>( evparValUint evn )
{
   evn.sender = &this
   return .OnFocus.Run( evn )
}

method uint vLabeledEdit.EditKey <alias=vLabeledEdit_EditKey>( evparValUint evn )
{
   evn.sender = &this
   return .OnKey.Run( evn )
}



method uint vLabeledEdit.Btn1Click <alias=vLabeledEdit_Btn1Click>( evparEvent evn )
{
   evn.sender = &this
   return .OnBtn1Click.Run( evn )
}

method uint vLabeledEdit.Btn2Click <alias=vLabeledEdit_Btn2Click>( evparEvent evn )
{
   evn.sender = &this
   return .OnBtn2Click.Run( evn )
}

method vLabeledEdit vLabeledEdit.mCreateWin <alias=vLabeledEdit_mCreateWin>()
{
   .CreateWin( "STATIC".ustr(), 0, 
         $SS_NOTIFY | $WS_CHILD | $WS_CLIPCHILDREN | $WS_CLIPSIBLINGS | $WS_OVERLAPPED )
   this->vCtrl.mCreateWin()
   
   this.LabelCon.ConCreateWin( this )
   this.pCanContain = 1
   
   //17.02.10 так и не понятно зачем recreate, без него сообщения не приходят
   if this.Edit.Owner
   {
      this.Edit.Virtual( $mReCreateWin )
   }
   else
   {
      this.Edit.Owner = this
   }
      
   this.Edit.Visible = 1
   this.Edit.Left = 0
   this.Edit.Top = 0
   this.Edit.VertAlign = $alvClient
   this.Edit.Width = 100
   this.Edit.OnChange.Set( this, vLabeledEdit_EditChange )
   this.Edit.OnFocus.Set( this, vLabeledEdit_EditFocus )
   this.Edit.OnKey.Set( this, vLabeledEdit_EditKey )
   //}
   if this.pBtn1 
   {
      this.pBtn1->vBtnPic.DestroyComp()
      this.pBtn1 = 0
   }
   if this.pBtn2 
   {
      this.pBtn2->vBtnPic.DestroyComp()
      this.pBtn2 = 0
   }
   
   uint i
   fornum i = 0, min( .pLEStyle, $lsTwoBtns )
   {
      uint btn 
      btn as this.CreateComp( vBtnPic )->vBtnPic
      btn.Top = 0
      btn.VertAlign = $alvTop   
      btn.HorzAlign = $alhRight
      btn.Width = 100
      btn.Right = 0
      btn.pCanContain = 0
      btn.Flat = 1
      if i
      {
         btn.OnClick.Set( this, vLabeledEdit_Btn2Click )
         btn.Image = .pBtn2Image
         btn.Hint = .pBtn2Hint
         this.pBtn2 = &btn                     
      }
      else
      {  
         btn.OnClick.Set( this, vLabeledEdit_Btn1Click )
         btn.Image = .pBtn1Image
         btn.Hint = .pBtn1Hint
         this.pBtn1 = &btn
      }
      
   }    
   
   eventpos evp
   evp.loc = this.loc
   evp.move = 0
   .Virtual( $mPosChanging, evp )
   return this
}

method vLabeledEdit.mSetOwner <alias=vLabeledEdit_mSetOwner>( vComp newowner )
{
 /*  this.LabelCon.LabeledCtrl = &this
   this->vCtrl.mSetOwner( newowner )
   this.LabelCon.ConSetOwner( )*/
   if newowner : this.LabelCon.LabeledCtrl = &this
   else : this.LabelCon.LabeledCtrl = 0
   this->vCtrl.mSetOwner( newowner )
   if newowner : this.LabelCon.ConSetOwner( )   
}

method uint vLabeledEdit.mSetName <alias=vLabeledEdit_mSetName>( str newname )
{
   this.LabelCon.ConSetName( newname )
   return 1 
}

method vLabeledEdit.mPosChanging <alias=vLabeledEdit_mPosChanging>( eventpos evp )
{           
   this->vCtrl.mPosChanging( evp )   
   .iUpdateBtns()
}

method vLabeledEdit.mSetVisible <alias=vLabeledEdit_mSetVisible>( )
{
   this->vCtrl.mSetVisible()
   .LabelCon.Visible = .Visible
}
/*------------------------------------------------------------------------------
   Registration
*/
/*method vLabeledEditOld vLabeledEditOld.init( )
{     
   this.pTypeId = vLabeledEditOld          
   return this 
}*/

method vLabelCon vLabelCon.init( )
{
   this.pTypeId = vLabelCon   
   return this 
}  

method vLabeledComboBox vLabeledComboBox.init( )
{     
   this.pTypeId = vLabeledComboBox        
   return this 
}

method vLabeledEdit vLabeledEdit.init( )
{     
   this.flgXPStyle = 1
   this.pTypeId = vLabeledEdit
   return this 
}    


func init_vLabeledEditOld <entry>()
{
   /*regcomp( vLabeledEditOld, "vLabeledEditOld", vEdit, $vCtrl_last, 
      %{ %{ $mCreateWin,    vLabeledEditOld_mCreateWin },
         %{ $mSetOwner,     vLabeledEditOld_mSetOwner },
         %{ $mSetName,     vLabeledEditOld_mSetName },
         %{ $mPosChanging, vLabeledEditOld_mPosChanging }
       },
      0->collection )*/
   regcomp( vLabelCon, "vLabelCon", vLabel, $vCtrl_last, 
      %{ %{ $mSetCaption,    vLabelCon_mSetCaption },
         %{ $mLangChanged, vLabelCon_mLangChanged },
         %{ $mCreateWin,    vLabelCon_mCreateWin },
         %{ $mPreDel,       vLabelCon_mPreDel } },
      0->collection )
         
      
   regcomp( vLabeledEdit, "vLabeledEdit", vCtrl, $vCtrl_last, 
      %{ %{ $mCreateWin,    vLabeledEdit_mCreateWin },
         %{ $mSetOwner,     vLabeledEdit_mSetOwner },
         %{ $mSetName,     vLabeledEdit_mSetName },
         %{ $mPosChanging, vLabeledEdit_mPosChanging },
         %{ $mSetVisible, vLabeledEdit_mSetVisible }
       },
      0->collection )      
      
   regcomp( vLabeledComboBox, "vLabeledComboBox", vComboBox, $vCtrl_last, 
      %{ %{ $mCreateWin,    vLabeledComboBox_mCreateWin },
         %{ $mSetOwner,     vLabeledComboBox_mSetOwner },
         %{ $mSetName,     vLabeledComboBox_mSetName },
         %{ $mPosChanging, vLabeledComboBox_mPosChanging },
         %{ $mSetVisible, vLabeledComboBox_mSetVisible }   
       },
      0->collection )      
                                 
      
ifdef $DESIGNING {
   //cm.AddComp( vLabeledEditOld, 1, "Windows", "labeled" )
   cm.AddComp( vLabeledComboBox, 1, "Windows", "labeled" )
   cm.AddComp( vLabeledEdit, 1, "Windows", "labeled" )
   
   uint propcol as %{
"Caption"   , ustr , 0,
"LabelPos"  , uint , 0,
"AddColon"  , uint , 0
   } 
   uint lpcol as %{ 
"lpLeft",    $lpLeft,
"lpAbove",   $lpAbove
   }   
   
   //cm.AddProps( vLabeledEditOld, propcol )   
   cm.AddProps( vLabeledComboBox, propcol )   
   cm.AddProps( vLabeledEdit, propcol@
         %{ "Text"     , ustr , 0,
            "Password" , uint , 0,
            "MaxLen"   , uint , 0,
            "Btn1Image", ustr , 0,
            "Btn2Image", ustr , 0,
            "Btn1Hint", ustr , 0,
            "Btn2Hint", ustr , 0,
            "LEStyle", uint, 0,
            "Multiline", uint, 0,
            "ScrollBars", uint, 0,
            "ReadOnly", uint, 0,
            "WordWrap", uint, 0
             } )
   cm.AddEvents( vLabeledEdit, %{
"OnBtn1Click"   , "evparEvent",
"OnBtn2Click"   , "evparEvent",
"OnChange"      , "evparEvent"
   })                
 
   //cm.AddPropVals( vLabeledEditOld, "LabelPos", lpcol )
   cm.AddPropVals( vLabeledComboBox, "LabelPos", lpcol )
   cm.AddPropVals( vLabeledEdit, "LabelPos", lpcol )      
   
   cm.AddPropVals( vLabeledEdit, "LEStyle",
%{ "lsSimple",  $lsSimple, 
   "lsOneBtn",  $lsOneBtn, 
   "lsTwoBtns", $lsTwoBtns })
}
}