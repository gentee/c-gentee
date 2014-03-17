/******************************************************************************
*
* Copyright (C) 2004-2012, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* Author: Alexander Krivonogov ( algen )
*
******************************************************************************/
/*
Пробный обработчик сообщений от объектов, нужно знать id события, 
как получать ID по имени надо разбираться
*/
define
{
   E_NOINTERFACE = 0x80004002
   S_OK          = 0x00000000
   E_NOTIMPL     = 0x80004001
}

type adviseitem
{
   uint ppv
   uint cookie
} 

type SED
{
    uint fserver
    uint internalrefcount
    uint xxx
    uint th
    uint ppv
    // IUnknown 
    uint QueryInterface;
    uint _AddRef;
    uint _Release;
    // IDispatch 
    uint GetTypeInfoCount
    uint GetTypeInfo
    uint GetIDsOfNames
    uint Invoke
    //property Server: TOleServer read FServer;
    //func uint ServerDisconnect :Boolean;
    uint pQueryInterface;
    uint p_AddRef;
    uint p_Release;
    // IDispatch 
    uint pGetTypeInfoCount
    uint pGetTypeInfo
    uint pGetIDsOfNames
    uint pInvoke
    
    arr  advises of adviseitem
    hash hproc of uint
}  

func uint SED_Invoke(
    uint ppv
    uint dispidMember,
    uint riid,
    uint lcid,
    uint wFlags,
    uint pdispparams,
    uint pvarResult,
    uint pexcepinfo,
    uint puArgErr)
{
   uint pfunc
   if pfunc = (ppv-20)->SED.hproc[dispidMember.str()]
   {
      pfunc->func(pdispparams)
   }
   //print( "zzzz \(dispidMember)\n" )
   /*if dispidMember==270
   {
      print( "disp \(pdispparams->DISPPARAMS.cArgs) \(pdispparams->DISPPARAMS.rgvarg->VARIANT.vt)\n" )
      //(pdispparams->DISPPARAMS.rgvarg )->VARIANT = VFALSE
      uint((pdispparams->DISPPARAMS.rgvarg )->VARIANT.val )->uint = 0xffff
      //->VARIANT.val)->uint = 0xffff
      print( "disp \(pdispparams->DISPPARAMS.cArgs) \((pdispparams->DISPPARAMS.rgvarg + sizeof( VARIANT ))->VARIANT.istrue())\n" )
      //getch()
   }*/
    return $S_OK
}

func int SED__AddRef( uint ppv)
{
  (ppv-20)->SED.internalrefcount++
  return (ppv-20)->SED.internalrefcount
}

func uint SED_QueryInterface(uint ppv, uint IID, uint Obj)
{
  Obj->uint = ppv  
  SED__AddRef( ppv )
  return $S_OK
  return $E_NOINTERFACE
}


func int SED__Release( uint ppv)
{
  (ppv-20)->SED.internalrefcount--  
  return (ppv-20)->SED.internalrefcount
}

func uint SED_GetTypeInfoCount(uint ppv, uint pCount)
{
  return $E_NOTIMPL
   //print( "gettypeinfocount \(pCount) \(pCount->int)\n" )
  pCount->int = 0
  return $S_OK
}

func uint SED_GetTypeInfo(uint ppv, int Index, int LocaleID, uint pTypeInfo)
{
   //print( "GETTYPEINFO \n" )
  pTypeInfo->uint = 0;
  return $E_NOTIMPL
}

func uint SED_GetIDsOfNames(uint ppv, uint IID, uint Names,
  uint NameCount, int LocaleID, uint DispIDsr)
{
  return $E_NOTIMPL
}


method SED.init()
{
   .ppv = &.QueryInterface
   .th = &this
   .pQueryInterface  = callback( &SED_QueryInterface  , 3 )
   .p_AddRef         = callback( &SED__AddRef         , 1 )
   .p_Release        = callback( &SED__Release        , 1 )
   .pGetTypeInfoCount= callback( &SED_GetTypeInfoCount, 2 )
   .pGetTypeInfo     = callback( &SED_GetTypeInfo     , 4 )
   .pGetIDsOfNames   = callback( &SED_GetIDsOfNames   , 6 )
   .pInvoke          = callback( &SED_Invoke          , 9 )
   
   .QueryInterface  = &.pQueryInterface  
   ._AddRef         = &.p_AddRef         
   ._Release        = &.p_Release          
   .GetTypeInfoCount= &.pGetTypeInfoCount        
   .GetTypeInfo     = &.pGetTypeInfo                
   .GetIDsOfNames   = &.pGetIDsOfNames                 
   .Invoke          = &.pInvoke
   
}

method SED.setproc( uint eventid, uint pfunc )
{
   .hproc[eventid.str()] = pfunc
}

method SED.disconnect()
{
   uint i
   fornum i=0, *.advises
   {
      (.advises[i].ppv->uint+24)->uint->stdcall( .advises[i].ppv, .advises[i].cookie )//release
   }
}

method SED.deinit
{
   .disconnect()
}

method uint SED.connect( oleobj obj )
{   
   .disconnect()
   if !obj.ppv : return 0
   
   ustr un
   buf ICPC
   ICPC.expand(16)
   //ID IConnectionPointContainer
   CLSIDFromString( un.unicode( "{B196B284-BAB4-101A-B69C-00AA00341D07}" ).ptr(), ICPC.ptr() )
   
   uint CPC_ppv, en_ppv
   //IConnectionPointContainer
   if (obj.ppv->uint)->uint->stdcall( obj.ppv, ICPC.ptr(), &CPC_ppv ) || //QueryInterface( IConnectionPointContainer
      (CPC_ppv->uint+12)->uint->stdcall( CPC_ppv, &en_ppv ) //EnumConnectionPoints
   {
      return 0  
   }
   uint b =0
   uint curppv   
   uint li
   do
   {      
      b=(en_ppv->uint+12)->uint->stdcall( en_ppv, 1, &curppv, &li )      
      if !b && curppv
      {
         uint cookie
         if !(curppv->uint+20)->uint->stdcall( curppv, .ppv, &cookie ) //advise
         {
            uint adv as .advises[.advises.expand(1)]
            adv.ppv = curppv
            adv.cookie = cookie
         }   
         //(curppv->uint+8)->uint->stdcall( curppv )//release              
      }            
   }
   while curppv && !b
   (CPC_ppv->uint+8)->uint->stdcall( CPC_ppv )//release
   return 1
}
