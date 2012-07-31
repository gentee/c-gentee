/******************************************************************************
*
* Copyright (C) 2009, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* Author: Alexey Krivonogov ( gentee )
*
******************************************************************************/

define
{
   RAS_MaxEntryName     = 256
   RAS_MaxDeviceName    = 128
   RAS_MaxDeviceType    = 16
   RAS_MaxPhoneNumber   = 128
   RAS_MaxCallbackNumber = $RAS_MaxPhoneNumber 
   MAX_PATH             = 260
   UNLEN                = 256
   PWLEN                = 256
   DNLEN                = 18 //15 
}

type RASCONN
{
   uint     dwSize
   uint     hrasconn
   reserved szEntryName[ $RAS_MaxEntryName + 1 ]
   reserved szDeviceType[ $RAS_MaxDeviceType + 1 ]
   reserved szDeviceName[ $RAS_MaxDeviceName + 1 ]
   reserved szPhonebook [ $MAX_PATH + 1 ]
   uint     dwSubEntry
   reserved unknown[16]
}

type RASDIALDLG
{
   uint dwSize
   uint hwndOwner
   uint dwFlags
   uint xDlg
   uint yDlg
   uint dwSubEntry
   uint dwError
   uint reserved
   uint reserved2
}

type RASDIALPARAMS
{
    uint      dwSize
    reserved  szEntryName[ $RAS_MaxEntryName + 1 ]
    reserved  szPhoneNumber[ $RAS_MaxPhoneNumber + 1 ]
    reserved  szCallbackNumber[ $RAS_MaxCallbackNumber + 1 ]
    reserved  szUserName[ $UNLEN + 1 ]
    reserved  szPassword[ $PWLEN + 1 ]
    reserved  szDomain[ $DNLEN + 1 ]
    uint      dwSubEntry
    uint      dwCallbackId
}

type RASENTRYNAME 
{ 
   uint     dwSize 
   reserved szEntryName[ $RAS_MaxEntryName + 1 ] 
   uint     dwFlags
   reserved szPhonebookPath[ $MAX_PATH + 1 ]
   reserved unknown[6]
} 


import "rasapi32.dll"
{
   uint RasDialA( uint, uint, RASDIALPARAMS, uint, uint, uint ) -> RasDial
   uint RasEnumConnectionsA( uint, uint, uint ) -> RasEnumConnections
   uint RasEnumEntriesA( uint, uint, uint, uint, uint ) -> RasEnumEntries
   uint RasHangUpA( uint ) -> RasHangUp
}

func uint ras_enumconnect( buf rascon, uint pnum )
{
   uint size pras
   buf  rascon
   
   size = 20 * sizeof( RASCONN ) 
   rascon.reserve( size )
   pras = rascon.ptr()
   pras->RASCONN.dwSize = sizeof( RASCONN )
   return ?( !RasEnumConnections( pras, &size, pnum ), pras, 0 )
} 

func uint ras_connections( arrstr entries )
{
   uint ret num pras
   buf  rascon
   
   entries.clear()
   if pras = ras_enumconnect( rascon, &num )
   {
      while num--
      {
         str stemp
         
         stemp.copy( &pras->RASCONN.szEntryName )
         entries += stemp      
         pras += sizeof( RASCONN )         
      }   
   }
   return ret
}

func uint ras_entries( arrstr entries )
{
   uint size ret num pras
   buf  rascon
   
   size = 20 * sizeof( RASENTRYNAME ) 
   rascon.reserve( size )
   entries.clear()
   pras = rascon.ptr()
   pras->RASENTRYNAME.dwSize = sizeof( RASENTRYNAME )
   if !( ret = RasEnumEntries( 0, 0, pras, &size, &num ))
   {
      while num--
      {
         str stemp
         
         stemp.copy( &pras->RASENTRYNAME.szEntryName )
         entries += stemp      
         pras += sizeof( RASENTRYNAME )         
      }   
   }
   return ret
}

func str ras_firstentry< result >( )
{
   arrstr astr
   
   ras_entries( astr )
   if *astr : result = astr[0]
}

func uint ras_dialdlg( uint wnd, str entry )
{
   RASDIALDLG rasdlg
   uint lib proc ret
   
   lib = LoadLibrary( "rasdlg.dll".ptr() )
   if !lib : return 0
   if !( proc = GetProcAddress( lib, "RasDialDlgA".ptr() )) : return 0
   
   rasdlg.dwSize = sizeof( RASDIALDLG )
   rasdlg.hwndOwner = wnd
   if !*entry : entry = ras_firstentry() 
   ret = proc->stdcall( 0, entry.ptr(), 0, rasdlg )
   return ret
}

func uint ras_dialup( str entry phone callback user psw domain )
{
   uint           hrascon
   RASDIALPARAMS  rdpar
      
   rdpar.dwSize = sizeof( RASDIALPARAMS )
   if !*entry : entry = ras_firstentry()
	mcopy( &rdpar.szEntryName, entry.ptr(), *entry + 1 )
   mcopy( &rdpar.szPhoneNumber, phone.ptr(), *phone + 1 )
   mcopy( &rdpar.szCallbackNumber, callback.ptr(), *callback + 1 )
   mcopy( &rdpar.szUserName, user.ptr(), *user + 1 )
   mcopy( &rdpar.szPassword, psw.ptr(), *psw + 1 )
   mcopy( &rdpar.szDomain, domain.ptr(), *domain + 1 )
   
   return !RasDial( 0, 0, rdpar, 0, 0, &hrascon )
}

func uint ras_disconnect( str entry )
{
   uint ret num pras
   buf  rascon
   
   if pras = ras_enumconnect( rascon, &num )
   {
      while num--
      {
         str stemp
         
         stemp.copy( &pras->RASCONN.szEntryName )
         if !*entry || stemp %== entry || entry == "*" 
         {
            ret = !RasHangUp( pras->RASCONN.hrasconn )
            if entry != "*" : return ret
         }
         pras += sizeof( RASCONN )         
      }   
   }
   return ret    
}

func uint ras_isconnected( str entry )
{
   uint num pras
   buf  rascon
   
   if pras = ras_enumconnect( rascon, &num )
   {
      while num--
      {
         str stemp
         
         stemp.copy( &pras->RASCONN.szEntryName )
         if !*entry || stemp %== entry : return 1
         pras += sizeof( RASCONN )         
      }   
   }
   return 0    
}
