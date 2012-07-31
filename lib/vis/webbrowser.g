/******************************************************************************
*
* Copyright (C) 2004-2007, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: vis.label 10.12.07 0.0.A.
*
* Author: Alexander Krivonogov ( gentee )
*
******************************************************************************/
/* Компонента vWebBrowser, порождена от vCtrl
События   
*/
include { $"..\olecom\olecom.g" }
type vWebBrowser <inherit = vCtrl>
{
//Hidden fields   
}

import "atl.dll" {
   uint AtlAxWinInit()
   AtlAxGetControl( uint, uint )
}

/*------------------------------------------------------------------------------
   Virtual methods
*/
/*Виртуальный метод vWebBrowser vWebBrowser.mCreateWin - Создание окна
*/
global { oleobj xx }
method vWebBrowser vWebBrowser.mCreateWin <alias=vWebBrowser_mCreateWin>()
{
   uint style =  $WS_CHILD  | $WS_CLIPSIBLINGS /*| $WS_OVERLAPPED*/
   
   .CreateWin( "AtlAxWin".ustr(), 0, style, "{8856F961-340A-11D0-A96B-00C04FD705A2}".ustr() )
   this->vCtrl.mCreateWin()
   uint ppv, pcf, res
   AtlAxGetControl( .hwnd, &pcf )
   
   //sCLSID_IWebBrowser2 As String = "{D30C1661-CDAF-11D0-8A3E-00C04FC9E26E}"
   res = xx.check( ((pcf->uint )->uint)->stdcall(
                                    pcf, IDispatch.ptr(), &xx.ppv ))
   //res = xx.check( ((pcf->uint + 12 )->uint)->stdcall(
    //                                pcf, 0, IDispatch.ptr(), &xx.ppv ))
   //((pcf->uint + 8)->uint)->stdcall( pcf );
   xx~Navigate( "k:\\" )
   //.iUpdateCaption()
   //.WinMsg(AX_INPLACE,1)    
   
   return this
}


/*------------------------------------------------------------------------------
   Registration
*/
method vWebBrowser vWebBrowser.init( )
{
   AtlAxWinInit()
   this.pTypeId = vWebBrowser

   this.loc.width = 300
   this.loc.height = 300
   return this 
}  

func init_vWebBrowser <entry>()
{  
   regcomp( vWebBrowser, "vWebBrowser", vCtrl, $vCtrl_last,
      %{ %{$mCreateWin, vWebBrowser_mCreateWin }/*
         %{$mClColor,      vWebBrowser_mClColor }*/
      },      
      0->collection )

ifdef $DESIGNING {      
   cm.AddComp( vWebBrowser, 1, "Windows", "webbrowser" )
   
/*   cm.AddProps( vWebBrowser, %{
"Caption"      , ustr, 0,
"TextHorzAlign", uint, 0,
"TextVertAlign", uint, 0,
"AutoSize"     , uint, $PROP_LOADAFTERCHILD,
"WordWrap"    , uint, 0
   })            
*/
  
}
}