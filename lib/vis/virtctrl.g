/******************************************************************************
*
* Copyright (C) 2004-2007, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: vis.virtctrl 02.04.08 0.0.A.
*
* Author: Alexander Krivonogov ( gentee )
*
******************************************************************************/
/* Компонента vVirtCtrl, порождена от vComp
Виртуальный элемент управления (не имеет своего окна)
События
   
*/

include
{   
   "comp.g"
}

operator vloc =( vloc l r )
{
   mcopy( &l, &r, sizeof(vloc) )
   return l
}

operator uint ==( vloc l r )
{
   return l.left == r.left && l.top == r.top && l.width == r.width && l.height == r.height
}

type vVirtCtrl <inherit = vComp>
{
//Hidden Fields
   vloc    loc
   uint    pVisible
   uint    pEnabled
   locustr pHint
   
   //uint cidx  //Индекс контрола 
}

define <export>{
   mPosChanging = $vComp_last
   mChildPosChanged
   mPosUpdate   
   mCreateWin

   mSetEnabled
   mSetVisible
   mSetHint
   mSetCaption
   mSetImage

   
   vVirtCtrl_last
}
/*------------------------------------------------------------------------------
   Propirties
*/

property int vVirtCtrl.Left
{   
   .Virtual( $mPosUpdate )
   return this.loc.left
}

property vVirtCtrl.Left( int val )
{  
   if val != this.loc.left
   {      
      eventpos ep
      this.loc.left = val
      ep.loc = this.loc
      ep.loc.left = val
      ep.move = 1
      ep.code = $e_poschanging      
      .Virtual( $mPosChanging, ep )    
   } 
}

property int vVirtCtrl.Top
{
   .Virtual( $mPosUpdate )
   return this.loc.top
}

property vVirtCtrl.Top( int val )
{   
   if val != this.loc.top
   {
      eventpos ep
      this.loc.top = val
      ep.loc = this.loc
      ep.loc.top = val
      ep.move = 1
      ep.code = $e_poschanging
      .Virtual( $mPosChanging, ep )
   }
}

property int vVirtCtrl.Width
{
   .Virtual( $mPosUpdate )
   return this.loc.width
}

property vVirtCtrl.Width( int val )
{
   if val < 0 : val = 0   
   if val != this.loc.width
   {   
      eventpos ep      
      ep.loc = this.loc
      ep.loc.width = val
      ep.move = 1
      ep.code = $e_poschanging         
      .Virtual( $mPosChanging, ep )    
   }
}

property int vVirtCtrl.Height
{
   .Virtual( $mPosUpdate )   
   return this.loc.height
}


property vVirtCtrl.Height( int val )
{
   if val < 0 : val = 0
   if val != this.loc.height
   {      
      eventpos ep
      ep.loc = this.loc
      ep.loc.height = val
      ep.move = 1
      ep.code = $e_poschanging      
      .Virtual( $mPosChanging, ep )       
   } 
}


method vVirtCtrl.SetLocation( uint left top width height )
{  
   eventpos ep
   ep.loc = this.loc
   ep.loc.left = left
   ep.loc.top = top
   ep.loc.width = width
   ep.loc.height = height
   ep.move = 1
   ep.code = $e_poschanging   
   .Virtual( $mPosChanging, ep )  
}


/* Свойство uint Visible - Get Set
Видимость элемента управления
*/
property vVirtCtrl.Visible( uint val )
{   
   if val != this.pVisible
   {  
      this.pVisible = val
      .Virtual( $mSetVisible )
      if &this.Owner()
      {
         this.Owner->vVirtCtrl.Virtual( $mChildPosChanged, this )
      }
   }
}

property uint vVirtCtrl.Visible
{
   return this.pVisible
}


/* Свойство uint Visible - Get Set
Доступность элемента управления
*/
property vVirtCtrl.Enabled( uint val )
{
   if val != this.pEnabled
   {
      this.pEnabled = val
      .Virtual( $mSetEnabled )           
   }
}

property uint vVirtCtrl.Enabled
{
   return this.pEnabled
}


/* Свойство ustr vVirtCtrl.Hint - Get Set
Всплывающая подсказка
*/
property ustr vVirtCtrl.Hint <result>
{
   result = this.pHint.Value
}

property vVirtCtrl.Hint( ustr val )
{  
   if val != this.pHint.Value
   { 
      this.pHint.Value = val
      .Virtual( $mSetHint )
   }         
}


/*Виртуальный метод uint vCustomBtn.mLangChanged - Изменение текущего языка
*/
method vVirtCtrl.mLangChanged <alias=vVirtCtrl_mLangChanged>()
{
   .Virtual( $mSetHint ) 
   this->vComp.mLangChanged() 
}



/*------------------------------------------------------------------------------
   Registration
*/


method vVirtCtrl vVirtCtrl.init()
{
   this.pTypeId = vVirtCtrl
   this.pVisible = 1
   this.pEnabled = 1   
   return this
}
/*
func init_vVirtCtrl <entry>()
{
   
   regcomp( vVirtCtrl, "vVirtCtrl", vComp, $vVirtCtrl_last,
       %{ %{$mLangChanged,  vVirtCtrl_mLangChanged },
          %{$mSetIndex,     vVirtCtrl_mSetIndex } },
      0->collection )      
ifdef $DESIGNING {
   cm.AddComp( vVirtCtrl )
   cm.AddProps( vVirtCtrl,  %{ 
"Visible"  , uint, $PROP_LOADAFTERCREATE,//0,//$PROP_LOADAFTERCHILD,
"Enabled"  , uint, 0,
"Hint"     , ustr, 0
})
      
                                                   
}

 //print( "reg vform 2\n" )         
}
*/