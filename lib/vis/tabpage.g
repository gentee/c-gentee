/******************************************************************************
*
* Copyright (C) 2004-2007, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: vis.tabpage 24.07.07 0.0.A.
*
* Author: Alexander Krivonogov ( gentee )
*
******************************************************************************/

define {
//TCM_FIRST               0x1300
//TCM_INSERTITEMA  = 0x1307 //      (TCM_FIRST + 7)
//TCM_INSERTITEMW  = 0x133E //      (TCM_FIRST + 62)
}

type vTabPage <inherit = vCtrl>
{
   locustr pCaption
   uint    pPageIdx
//   onevent onclick   
}

/*------------------------------------------------------------------------------
   Internal methods
*/
method vTabPage.iUpdate()
{
   if this.pOwner
   {
      eventuint eu
      eu.code = $e_update
      eu.val = &this
      //this.p_owner->vCtrl.event(eu)
   }
}


/*------------------------------------------------------------------------------
   Properties
*/
/* Свойство ustr Caption - Get Set
Устанавливает или получает заголовок закладки
*/
property ustr vTabPage.Caption <result>
{
   result = .pCaption.Value
}

property vTabPage.Caption( ustr val )
{   
   .pCaption.Value = val
   .iUpdate()       
}

property uint vTabPage.Index
{
   return this.TabOrder
}

property vTabPage.Index( uint val )
{  
   if this.Owner && this.Owner->vCtrl.TypeIs( vTab )
   {
      uint i
      this.TabOrder = val      
      this.iUpdate()
      uint ctrls as this.Owner->vCtrl.ctrls    
      fornum i, *ctrls
      {
         if ctrls[i]->vCtrl.Visible : break
      }
      this.Owner->vTab.CurPage = i      
   }      
}
/*
method uint vTabPage.defproc( eventn ev )
{
   switch ev.code
   {
      case $e_poschanging
      {         
         if this.owner.typeis( vtab )
         {           
            uint evp as ev->eventpos         
            evp.loc = this.owner->vtab.adjloc                     
            if evp.move //&& evp.loc != this.loc
            {
               this.onposchanging.run( evp )            
               SetWindowPos( this.hwnd, 0, 
                     evp.loc.x, evp.loc.y, evp.loc.width, evp.loc.height, 
                     $SWP_NOACTIVATE | $SWP_NOZORDER )            
               RedrawWindow( this.hwnd, 0->RECT, 0, 0x507)
            }
         }
         return 0      
      }
   }  
   return this->vctrl.defproc( ev )   
}*/


/*------------------------------------------------------------------------------
   Virtual Methods
*/

method vTabPage vTabPage.mCreateWin <alias=vTabPage_mCreateWin>()
{
   this.CreateWin( "GVForm".ustr(), 0, 
                     $WS_CHILD | $WS_CLIPSIBLINGS | $WS_CLIPCHILDREN )
   this->vCtrl.mCreateWin()
   SendMessage( this.hwnd, $WM_SETFONT, GetStockObject( $DEFAULT_GUI_FONT ),0 )
   return this
}


/*------------------------------------------------------------------------------
   Registration
*/
method vTabPage vTabPage.init( )
{    
   this.pTypeId = vTabPage
   
   this.pCanContain = 1
   this.pVisible = 0
   return this 
}  

method vTabPage.getprops( uint typeid, compMan cm )
{
   this->vCtrl.getprops( typeid, cm)
  /* cm.addprops( typeid, 
%{ "caption"     , str, 0})*/                         
}
/*
method vTabPage.getevents()
{
   %{"onclick"}
}
*/

func init_vTabPage <entry>()
{
   regcomp( vTabPage, "vTabPage", vCtrl, $vCtrl_last,
      %{ %{$mCreateWin, vTabPage_mCreateWin }},
      0->collection )
} 
