#exe = 1
#libdir = %EXEPATH%\lib
#libdir1 = %EXEPATH%\..\lib\vis
#include = %EXEPATH%\lib\stdlib.ge
/******************************************************************************
*
* Copyright (C) 2009, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* Author: Alexander Antypenko ( santy )
*
******************************************************************************/

include
{
 $"zlib.g"
}

func zlib_demo<main>
{
  print("DEMO COMPRESS (UNCOMPRESS) FUNCTIONS \n\n")
  str demo_string = "It is demonstration function from zlib library"
  str out_string = squeeze(demo_string)
  print("text : \(out_string) -- Length : \(*out_string) \n")
  getch()
  str out_string1= unsqueeze(out_string)
  print("text : \(out_string1) -- Length : \(*out_string1) \n")
  getch()
  print("\n\n DEMO WORK WITH GZ FILES FUNCTIONS \n\n")
  out_string1 = out_string1 + " DEMO WORK WITH GZ FILES FUNCTIONS DEMO WORK WITH GZ FILES FUNCTIONS"
  uint CountBytes = gzfile_write("demo_arh.gz", out_string1)    
  print("CountBytes -> \(CountBytes) \n")
  getch()
  str dest_buffer = gzfile_read("demo_arh.gz")
  print("Result  \(dest_buffer) \n")
  getch()
}