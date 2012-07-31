#exe = 1
#norun = 1
#gefile = 0
#libdir = %EXEPATH%\lib
#libdir1 = %EXEPATH%\..\lib\vis
#include = %EXEPATH%\lib\stdlib.ge
//#wait = 1
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
  $"Pcre.g"
}


func pcre_demo <main>
{
 str version,sPattern //,sText
 str data,sDataConv
 int inData
 arrstr allData
 pcre reData

 data = reData.re_version()

 //print("data "+data+" \n")

 version = "Version " + data
 print("Using pcre.dll "+version +" \n")
 print("----------------------------------------------\n \n")

 ///////////////// MATCHGETALL
 
 reData.srcText ="www.google.com www.yahoo.com  192.8.23.226  YES UP   NO"
 sPattern = "(\\w+\\.\\w+\\.\\w+)\\s+(\\d+\\.\\d+\\.\\d+\\.\\d+)\\s+(\\w+).+\\s+(\\w+).*$"

 print("Subject is ... "+ reData.srcText + "  \n")
 print("Pattern is ... "+ sPattern + "\n")
 
 inData = reData.matchGetAll (sPattern, $PCRE_NOTEMPTY,allData)

 if (inData == $NULL) : print("No match! \n")
 elif (inData>0)
 {
   uint j;
   fornum j=0,*allData
   {
     sDataConv.clear();
     sDataConv.out4("%d",j);
     print("Capured substring # "+sDataConv+" "+allData[j]+"\n")
   }
 }
 print("----------------------------------------------\n \n")
 getch()
 // Get file name from full path
 allData.clear();
 reData.srcText = "C:\\Program Files\\Gentee\\bin\\gentee.exe"
 sPattern = "([^/:\\\\]+)$"
 
 print("Subject is ... "+ reData.srcText + "  ")
 print("Pattern is ... "+ sPattern + "\n")
 
 inData = reData.matchGetAll (sPattern, $PCRE_NOTEMPTY,allData)
 if (inData == $NULL) : print("No match!\n")
 elif (inData>0)
 {
   uint j;
   fornum j=0,*allData
   {
     sDataConv.clear();
     sDataConv.out4("%d",j);
     print("Capured substring #"+sDataConv+" "+allData[j]+"\n")
   }
 }
 print("----------------------------------------------\n \n")
 getch()

 // Get drive letter from full path
 allData.clear();
 reData.srcText = "C:\\Program Files\\gentee\\bin\\gentee.exe"
 sPattern = "^\\s*([^:])"
 print("Subject is ... "+ reData.srcText + "  ")
 print("Pattern is ... "+ sPattern + "\n")
 
 inData = reData.matchGetAll (sPattern, $PCRE_NOTEMPTY,allData)
 if (inData == $NULL) : print("No match! \n")
 elif (inData>0)
 {
   uint j;
   fornum j=0,*allData
   {
     sDataConv.clear();
     sDataConv.out4("%d",j);
     print("Capured substring #"+sDataConv+" "+allData[j]+"\n")
   }
 }
 print("----------------------------------------------\n \n")
 getch()
 /// wrong
 reData.srcText = "foooooo fo foa boo boa"
 sPattern = "((foo)"		// example of a wrong pattern
 allData.clear();
 print("Subject is ... "+ reData.srcText + "  ")
 print("Pattern is ... "+ sPattern + "\n")
 
 inData = reData.matchGetAll (sPattern, $PCRE_NOTEMPTY,allData)
 if (inData == $NULL) : str_print("No match!\n")
 elif (inData>0)
 {
   uint j;
   fornum j=0,*allData
   {
     sDataConv.clear();
     sDataConv.out4("%d",j);
     print("Capured substring #"+sDataConv+" "+allData[j]+"\n")
   }
 }
 print("----------------------------------------------\n \n")
 getch()
 ///////////////// MATCH
 
 // This is a match because we don't check for word boudaries
 reData.srcText = "foooooo fo foa boo boa"
 sPattern = "foo"

 print("Subject is ... "+ reData.srcText + "  ")
 print("Pattern is ... "+ sPattern + "\n")

 inData = reData.match(sPattern, $PCRE_NOTEMPTY)
 
 sDataConv.clear();
 sDataConv.out4("%d",inData);
 print("Result "+sDataConv+" match found \n") 

 print("----------------------------------------------\n \n") 
 getch()
 // This is a no match because there is no single word "foo"

 reData.srcText = "foooooo fo foa boo boa"
 sPattern = "\\bfoo\\b"

 print("Subject is ... "+ reData.srcText + "  ")
 print("Pattern is ... "+ sPattern + "\n")

 //print("MATCH 0\n")
 inData = reData.match(sPattern, $PCRE_NOTEMPTY)
 //print("MATCH 1\n")
 sDataConv.clear();
 sDataConv.out4("%d",inData);
 print("Result "+sDataConv+" match found \n") 
 
 print("----------------------------------------------\n \n")
 getch()
}
