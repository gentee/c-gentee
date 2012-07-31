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

include
{
   $"..\gea\gea.g" 
}

func makebin<main>
{
   lzge lz 
   str  input
   buf  out in
   
   out.expand( 420000 )
   in.read( "..\\..\\exe\\res\\linker\\genteert.dll" )
   lz.order = 10
   out.use = lzge_encode( in.ptr(), *in, out.ptr() + 4, lz ) + 4
   out.ptr()->uint = *in
   print("Dll name: genteert.dll\nDLL size: \(*in)\nBIN size: \( *out )\n")
   out.write( "..\\..\\exe\\res\\linker\\genteert.bin" )
   
   congetch( "Press any key..." )
}
