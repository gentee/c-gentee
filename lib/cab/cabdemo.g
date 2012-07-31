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

include : $"cab.g"

func uint notify( uint code, str param, cabinfo cabi )
{
   switch code
   {
      case $FLN_ERROR: congetch( param )
      case $FLN_FILEBEGIN
      {
         print( "\(param) 0% ")
         cabi.cabsize = 0
         cabi.percent = 0
      }
      case $FLN_PROGRESS
      {
         uint percent
          
         cabi.cabsize += &param
         percent = uint( 100.0 * double( cabi.cabsize ) / double( cabi.filesize ));
         percent = min( 100, percent )
         if percent > cabi.percent
         { 
            cabi.percent = percent
            print( " \( percent )%")
         }
      }
      case $FLN_FILEEND
      {
         print( " 100%\n")
      }
      case $FLN_ERROPEN
      {
         return !conrequest( "Cannot open file \( param )...Retry/Abort? [R/A]", 
                             "Rr|Aa" )
      }
   }
   return 0
}

func uint denotify( uint code, str param, decabinfo decab )
{
   switch code
   {
      case $FLN_ERROR: congetch( param )
      case $FLN_ERROPEN
      {
         return !conrequest( "Cannot open file \( param )...Retry/Abort? [R/A]", 
                             "Rr|Aa" )
      }
      case $FLN_NOTVALID
      {
         return congetch( "File \( param ) is not a cabinet archive!\n" )
      }
      case $FLN_FILEBEGIN
      {
         str stemp
         
         stemp.fgetdir( decab.destfile )
         verifypath( stemp, 0->arrstr )
         decab.percent = 0
         decab.cursize = 0    
         if fileexist( decab.destfile )
         {
            setattribnormal( decab.destfile )
            deletefile( decab.destfile )
         }
         print("Unpack \( decab.fileinfo->finfo.fullname ) 0%")
         return 1
      }
      case $FLN_PROGRESS
      {
         uint percent
         
         decab.cursize += &param;
         percent = min( 100, uint( 100.0 * double( decab.cursize ) / 
                                 double( decab.fileinfo->finfo.sizelo )));
         if percent > decab.percent
         { 
            decab.percent = percent
            print( " \( percent )%")
         }
      }
      case $FLN_FILEEND
      {
         print(" 100%\n")
      }
   }
   return 0
}

func main<main>
{
   cabinit cabi
   arrstr  files = %{ "c:\\temp\\*.*" }
   arr     flags of uint 
   
   flags = %{ $FL_FILES  //$FL_EMPTYFLD//$FL_RECURSIVE 
   }
 
   cabi.exclude = %{ "*.exe", "ci", "*.cab", "my" }
   cabi.notify = &notify
//   cabi.level = 2       
   cabi.volumesize = 300000
   //cabi.disk = "mydisk"
   cab_create( $"c:\temp\my.cab", files, flags, cabi )
   print("==============================\n")
   arr cablist of finfo
   cab_list( $"c:\temp\my.cab", cablist, &denotify )
   foreach curi, cablist
   {
      str date time
      getfiledatetime( curi.lastwrite, date, time )
      print("\( curi.fullname ) size = \(curi.sizelo ) date = \(date) time =\(time) \n")
   }
   print("==============================\n")
   cab_decode( $"c:\temp\my.cab", $"c:\temp\my", &denotify )
  
   congetch("Press any key...")   
}