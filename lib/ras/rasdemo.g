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

include : "ras.g"

func rasdemo<main>
{
   arrstr astr
   str    entry

   ras_entries( astr )
   print("RAS Entries ================\( sizeof( RASDIALPARAMS )) \n") 
   foreach ecur, astr
   {
      print("\(ecur)\l")  
   }
   entry = ras_firstentry() 
   print( "Disconnect: \( ras_disconnect( entry )) \n" )
   print("\( entry ): \( ?( ras_isconnected(  entry ), "YES", "NO" )) \n")
   print("Dialup: \( ras_dialup( "", "", "", "login", "*****", "" ))") 
//   ras_dialdlg( 0, entry )
   print("\( entry ): \( ?( ras_isconnected(  entry ), "YES", "NO" )) \n") 
   ras_connections( astr )
   print("Connections ================\n") 
   foreach ecur, astr
   {
      print("\(ecur)\l")  
   }   
   congetch("Press any key...")
}


