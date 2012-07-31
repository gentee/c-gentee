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
   "geafile.g"
   $"..\windows\fileversion.g"
   "geacommon.g" 
}

import "gea.dll"<exe>
{
   uint  gea_init( uint  )
   uint  lzge_encode( uint, uint, uint, lzge )
   uint  lzge_decode( uint, uint, uint, lzge )
   uint  ppmd_encode( uint, uint, uint, uint, ppmd )
   uint  ppmd_decode( uint, uint, uint, uint, ppmd )
   uint  ppmd_start( uint )
         ppmd_stop( )
}

func geainit< entry >
{
   gea_init( gentee_ptr( 4 )) // GPTR_CALL
}

include
{
   "geae.g"
   "gead.g"
}
/*
 
func main//< main >
{
   uint  outsize i one
   buf in out decomp btemp 
   lzge lz lzd
   ppmd ppm
      uint osize
   
//   in.expand( 4200000 )
   out.expand( 4200000 )
   decomp.expand( 4200000 )
   in.read( "c:\\aa\\pcmassor.dbf" )
   btemp = in
   one = *in
   in += btemp
   in += btemp
   in += btemp
//   ppm.memory = 8
   ppm.order = 10  
   lz.order = 1
//   lz.solid = 1
   while i < *in 
   {
      lzge lzd
//      outsize += lzge_encode( in.ptr()+i, min( 2000000, *in - i ), out.ptr(), lz )
      print("Enter\n")
      outsize += lzge_encode( in.ptr() + i - lz.solidoff, 
               min( one, *in - i ) + lz.solidoff, out.ptr() + *out, lz )
      print("\nDecode \( outsize )\n")
      lzd.solidoff = lz.solidoff
      osize = lzge_decode( out.ptr() + *out, decomp.ptr(), lzd.solidoff +
                    min( one, *in - i ), lzd )
//      btemp.copy( out.ptr() + *out, osize )
//      btemp.write("c:\\aa\\decode1.bin")
//      lzge_decode( out.ptr() + *out, decomp.ptr(), lzd.solidoff +
//                    min( one, *in - i ), lzd )
//      decomp.use = min( 1000000, *in - i ) + lz.solidoff
      lz.solidoff += one//0x80000
//      outsize += ppmd_encode( in.ptr() + i, min( 1500000, *in - i ), out.ptr(), ppm )
      i += one
//      ppm.memory = 0
//      ppm.order = 1
      out.use = outsize  
      print("\nOK decomp=\( osize ) \( outsize )\n" )
//      ppmd_encode( in.ptr() + 3000000, *in - 3000000, out.ptr(), ppm )
   }
//   decomp.write("c:\\apps\\unpack")
   print("\nCompression \( outsize ) --------------------- \n")
   goto end
   
   mzero( &lz, sizeof( lzge ))
   lz.order = 1
   outsize = lzge_encode( in.ptr(), *in, out.ptr(), lz )
   print("\nDecompression \( outsize )\n")
   out.use = outsize
   print("0\n")
   decomp.use = lzge_decode( out.ptr(), decomp.ptr(), *in, lzd )
   print("\n1 \(decomp.use)\n")
   fornum i, *in
   {
      if in[ i ] != decomp[ i ]
      {
         congetch("Compare error \(i) ( \(in[i]) != \(decomp[i]) )\n" )
         break
      }
   }
   label end
   
   mzero( &lzd, sizeof( lzge ))
   lzd.order = 1
   lzd.solidoff = 0
   i = 0
   osize = 0   
   while i < *in 
   {
      print("\nDecode 0\n")
//      btemp.copy( out.ptr() + osize, 25 )
//      btemp.write("c:\\aa\\decode2.bin")
      osize += lzge_decode( out.ptr() + osize, decomp.ptr(), lzd.solidoff +
                    min( one, *in - i ), lzd )
      print("\nDecode \( osize )\n")
      lzd.solidoff += one
      decomp.use = lzd.solidoff
//      lz.solidoff += one//0x80000
//      outsize += ppmd_encode( in.ptr() + i, min( 1500000, *in - i ), out.ptr(), ppm )
      i += one
//      ppm.memory = 0
//      ppm.order = 1  
      print("\nOK \(decomp.use)\n" )
//      ppmd_encode( in.ptr() + 3000000, *in - 3000000, out.ptr(), ppm )
   }
//   decomp.use = lzge_decode( out.ptr(), decomp.ptr(), *in, lzd )
   print("\n1 \(decomp.use)\n")
   
   print("Summary: \(*in) \(outsize) = \( outsize * 100 / *in )")
   congetch("Press any key")
}      
*/
