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

method gedfields.init()
{
   this->arr.oftype( gedfieldinit )
}

method uint ged.close()
{
   return ged_close( this )
}

method uint ged.create( str filename, collection cfield, uint notify )
{
   uint i
   gedfields fields
 
   .filename = filename.ptr()
   fornum i, *cfield
   {
      uint field
     
      field as fields[ fields.expand(1)]
      field.ftype = cfield[i++]
      if cfield.gettype( i ) != str : break
      field.name = cfield[i]->str.ptr()
      if field.ftype & $FTF_AUTO : .autoid = i
      field.ftype &= 0xFFFFFF
   }
   fields.expand(1)
   
   if notify
   {
      .call = gentee_ptr( 4 ) // GPTR_CALL
      .nfyparam = notify
   }

   return ged_create( this, fields.ptr() )
}

method uint ged.open( str filename, uint notify )
{
   .filename = filename.ptr()
   if notify
   {
      .call = gentee_ptr( 4 ); // GPTR_CALL
      .nfyparam = notify;
   }

   return ged_open( this )
}

operator uint *( ged pdb)
{
   return pdb.reccount
}

method uint ged.eof( fordata fd )
{
   return ged_eof( this )
}

method uint ged.first( fordata fd )
{
   return ged_goto( this, 1 )   
}

method uint ged.next( fordata fd )
{
   return ged_goto( this, this.reccur + 1 )   
}
