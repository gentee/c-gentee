/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: default 17.11.06 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
******************************************************************************/

text C_default( gtitem gti )
\{
   uint    gtilist
   arrstr  files
   
   gtilist as gti.findrel("/content")
   if &gtilist
   {
      str  path filename out relpath
      
      gti.get( "fullpath", path )
      _gtp.prj.get( "project/output", out )
      gti.get( "path", relpath )
      out.faddname( relpath )
      files.loadtrim( gtilist.value )
      foreach curfile, files
      {
         str  dir
         
         ( filename = path ).faddname( curfile )
         ( dir = out ).faddname( curfile )
         dir.fgetdir( dir )
         copyfiles( filename, dir, $FIND_FILE | $COPYF_SAVEPATH, $COPY_NEWER, 
                    &defcopyproc )
      }
   }
}nofile\!

