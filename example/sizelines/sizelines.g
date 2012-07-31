/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: sizelines 18.10.06 0.0.A.
*
* Author: Aleksandr Antypenko ( santy )
*
******************************************************************************/

type flinfo
{
  uint countsize
  uint countlines
}

/*
*   Function sizelines - 
*     
*   Parameters: 
*           uint addfinfo  -  addrees of flinfo structure
*           str filePath   -  path and pattern for search files
*
*   Return :
*        fill structure flinfo   
*
*/
func int sizelines(flinfo addfinfo,str filePath)
{
   str foundPattern,readstr,sDir
   ffind fd
   uint idfile
   arr proglines of str
   
   sDir.fgetdir(filePath)
   if !(direxist(sDir)) : print("Error. Directory not found. \n".char2oem()); return 0 
   if !(setcurdir(sDir)) :  print("Error. Can not set current directory. \n".char2oem()); return 0 
   foundPattern =filePath //+ patternFile  
   fd.init( foundPattern, $FIND_FILE | $FIND_RECURSE )
   foreach finfo cur,fd
   {
      idfile = open(cur.fullname,$OP_READONLY) 
      if !(idfile) : continue
      readstr.read(cur.fullname)
      readstr.lines(proglines,0)
      //print("Size -> \(getsize(idfile)) Lines -> \(*proglines) \n")
      addfinfo.countsize  += getsize(idfile)
      addfinfo.countlines += *proglines
      if !(close(idfile)): print("Error closing file \n")
   }
   return 1
}

 
