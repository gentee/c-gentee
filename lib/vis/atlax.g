/******************************************************************************
*
* Copyright (C) 2004-2007, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: vis.atlax 30.09.09 0.0.A.
*
* Author: Alexander Krivonogov ( gentee )
*
******************************************************************************/
/* Компонента vAtlAx, порождена от vCtrl 
*/
include { $"..\olecom\olecom.g" }
type vAtlAx <inherit = vCtrl>
{
   oleobj Obj        
//Hidden fields
   ustr   pProgId   
   uint   prevuserdata 
}

import "atl.dll" {
   uint AtlAxWinInit()
   AtlAxGetControl( uint, uint )
   uint AtlAxWinTerm()
}

global { uint atlaxcnt }


/*------------------------------------------------------------------------------
   Properties
*/
/* Свойство ustr ProgId - Get Set
This string can be a CLSID (with braces), a ProgID, a URL, or raw HTML (prefixed with MSHTML:)
*/
property ustr vAtlAx.ProgId <result>
{   
   result = .pProgId   
}

property vAtlAx.ProgId( ustr val )
{
   if val != .pProgId
   {
      .pProgId = val
      .Virtual( $mReCreateWin )
   }
}


/*------------------------------------------------------------------------------
   Virtual methods
*/
/*Виртуальный метод vAtlAx vAtlAx.mCreateWin - Создание окна
*///{8856F961-340A-11D0-A96B-00C04FD705A2}
method vAtlAx vAtlAx.mCreateWin <alias=vAtlAx_mCreateWin>()
{
   uint style =  $WS_CHILD  | $WS_CLIPSIBLINGS //| $WS_OVERLAPPED

//   .CreateWin( "AtlAxWin".ustr(), 0, style, 
//      ?( *.pProgId, .pProgId, "shell.explorer".ustr()))
      
   if .pVisible : style |= $WS_VISIBLE 
   if !.pEnabled : style |= $WS_DISABLED   
   this.hwnd = CreateWindowEx( 0, "AtlAxWin".ustr().ptr(), "shell.explorer".ustr().ptr(), style, 
      this.loc.left, this.loc.top, this.loc.width, this.loc.height, ?( this.pOwner && this.pOwner != &App, this.pOwner->vCtrl.hwnd, 0), 0, GetModuleHandle( 0 ), 0 )      
   .prevuserdata = GetWindowLong( this.hwnd, $GWL_USERDATA )
   this->vCtrl.mCreateWin()
   uint pcf, res
   AtlAxGetControl( .hwnd, &pcf )
   res = .Obj.check( ((pcf->uint )->uint)->stdcall( pcf, IDispatch.ptr(), &.Obj.ppv ))
   //.Obj~Navigate( "http://www9.pirit.info/" )       
   return this
}

/*------------------------------------------------------------------------------
   Registration
*/
method vAtlAx vAtlAx.init( )
{
//print( "atl init \(atlaxcnt)\n" )
   if !atlaxcnt: AtlAxWinInit()
   atlaxcnt++
   this.pTypeId = vAtlAx

   this.loc.width = 300
   this.loc.height = 300
   return this 
}  

method vAtlAx.delete( )
{   
   .Obj.ppv = 0
   atlaxcnt--
//   if !atlaxcnt: AtlAxWinTerm()   
}

method vAtlAx.mPreDel <alias=vAtlAx_mPreDel>()
{
 //  .Obj.release()
   SetWindowLong( this.hwnd, $GWL_WNDPROC, .prevwndproc )
   SetWindowLong( this.hwnd, $GWL_USERDATA, .prevuserdata )   
   this->vCtrl.mPreDel()
}

method uint vAtlAx.wmdestroy <alias=vAtlAx_wmdestroy>( winmsg wmsg )
{
   SetWindowLong( this.hwnd, $GWL_WNDPROC, .prevwndproc )
   SetWindowLong( this.hwnd, $GWL_USERDATA, .prevuserdata )    
   return 0    
}


func init_vAtlAx <entry>()
{  
   regcomp( vAtlAx, "vAtlAx", vCtrl, $vCtrl_last,
      %{ %{$mCreateWin, vAtlAx_mCreateWin },
         //%{$mDestroyWin, vAtlAx_mDestroyWin },
         %{$mPreDel,       vAtlAx_mPreDel}
      },      
      %{%{$WM_DESTROY,  vAtlAx_wmdestroy }} )

ifdef $DESIGNING {      
   cm.AddComp( vAtlAx, 1, "Windows", "AtlAx" )
   
   cm.AddProps( vAtlAx, %{
"ProgId"      , ustr, 0
   })            
  
}
}