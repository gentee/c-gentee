/******************************************************************************
*
* Copyright (C) 2008, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* Author: Alexey Krivonogov ( gentee )
*
******************************************************************************/

type iBITMAPINFOHEADER{
  uint   biSize 
  uint   biWidth 
  uint   biHeight 
  ushort biPlanes 
  ushort biBitCount
  uint   biCompression
  uint   biSizeImage
  uint   biXPelsPerMeter
  uint   biYPelsPerMeter 
  uint   biClrUsed 
  uint   biClrImportant
} 

type iICONDIRENTRY
{
	ubyte	   bWidth                // Width of the image
	ubyte  	bHeight               // Height of the image (times 2)
	ubyte  	bColorCount           // Number of colors in image (0 if >=8bpp)
	ubyte  	bReserved             // Reserved
	ushort	wPlanes               // Color Planes
	ushort	wBitCount             // Bits per pixel
	uint  	dwBytesInRes          // how many bytes in this resource?
	uint  	dwImageOffset         // where in the file is this image
}

type iICONDIR
{
	ushort			idReserved   // Reserved
	ushort			idType       // resource type (1 for icons)
	ushort			idCount      // how many images?
}

type iconinfo
{
   iICONDIRENTRY  icondir
   buf           data
}

func uint geticoninfo( str iconame, arr result of iconinfo )
{
   buf  input
   uint dir i cur
      
   result.clear()
   input.read( iconame )
   if !*input : return 0
   dir as input.ptr()->iICONDIR
   cur = input.ptr() + sizeof( iICONDIR )
   
   fornum i, dir.idCount
   {
      uint bi
      
      result.expand( 1 )
      mcopy( &result[i].icondir, cur, sizeof( iICONDIRENTRY ))
      cur += sizeof( iICONDIRENTRY )
      result[i].data.copy( input.ptr() + result[i].icondir.dwImageOffset, 
                           result[i].icondir.dwBytesInRes )
      bi as result[i].data.ptr()->iBITMAPINFOHEADER
      
      result[i].icondir.wPlanes = bi.biPlanes 
      result[i].icondir.wBitCount = bi.biBitCount
      result[i].icondir.bColorCount = bi.biClrUsed 
   }
   return 1
}

