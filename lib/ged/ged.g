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

define
{
   // Type of fields
   FT_BYTE   = 1   // byte
   FT_UBYTE  = 2   // unsigned byte
   FT_SHORT  = 3   // short
   FT_USHORT = 4   // unsigned short
   FT_INT    = 5   // int
   FT_UINT   = 6   // unsigned int
   FT_LONG   = 7   // long
   FT_ULONG  = 8   // unsigned long
   FT_FLOAT  = 9   // float
   FT_DOUBLE = 10   // double
   FT_STR    = 11   // ANSI string ( 1-255 )
   FT_USTR   = 12   // Unicode string ( 1-255 )

// Flags for _gedfield.param
   FTF_AUTO   = 0x10000000   // Auto-increment (for FT_BYTE - FT_LONG)

   SF_END   =  0   // Finish of commands
   SF_ALL   =  1   // All records (exclude deleted)
   SF_EQ    =  2   // field == ival
   SF_LESS  =  3   // field < ival
   SF_GREAT =  4   // field > ival

   SF_NOT   =  0x10000000  // Not flag for commands
   SF_OR    =  0x20000000  // OR to the next command, by default AND

// Index flags
   IF_DESC   = 0x10000000  // Descend order
   IF_END    = 0xFFFF      // End of the index list

// Error codes
   GDE_OK     = 0   // No error
   GDE_GEDEXIST
   GDE_OPENFILE     // Cannot open file - filename in ged->dbfile
   GDE_WRITEFILE    // Cannot write file - filename in ged->dbfile
   GDE_FORMAT       // Format of database files is wrong
   GDE_READFILE     // Cannot read file - filename in ged->dbfile
}

// Database header
type gedhead
{
   uint     ext       // GED string
   ubyte    size      // Sizeof of the header structure
   uint     oversize  // Size of all header information
   ushort   numfields // Amount of columns
   ushort   autoid;    // The number of autoincrement field from 1
}

// Field init
type gedfieldinit
{
   uint   ftype
   uint   name
} 

// Database column info
type gedfield
{
   uint    ftype
   uint    name
   uint    width
   uint    offset
}  

type gedfields <inherit=arr index=gedfieldinit> 
{
}

type ged 
{
   uint         filename       // Name of database file
   uint         call           // gentee_call notify function
   uint         nfyparam       // The first parameter of gentee_call
   uint         error          // Error code
   uint         autoid         // The latest auto id for open 
                               // for create == autoincrement field from 1

   uint         head      // Database header
   uint         fields    // Pointer to columns info
   uint         db        // Pointer to the first record
   uint         handle    // Handle of the ged file
   uint         fsize     // The size of the field
   uint         reccount  // The count of records
   uint         reccur    // The current record
   uint         recptr    // The pointer to the record
   uint         gm
}

type gedsel
{
   uint         pdb       // Database
   uint         reccount  // The count of records
   uint         reccur    // The current record from 1 
   uint         sm
}

import "ged.dll"<exe>
{
   uint ged_append( ged, uint )
   uint ged_close( ged )
   uint ged_create( ged, uint )
   uint ged_eof( ged )
   uint ged_field( ged, uint )
   uint ged_fieldptr( ged, uint, uint )
   uint ged_findfield( ged, uint )
   uint ged_getuint( ged, uint, uint )
   long ged_getlong( ged, uint, uint )
   float  ged_getfloat( ged, uint, uint )
   double ged_getdouble( ged, uint, uint )
   uint ged_goto( ged, uint )
   uint ged_isdel( ged )
   uint ged_open( ged )
   uint ged_recno( ged )
   
   uint ges_select( gedsel, ged, uint, uint )
   uint ges_close( gedsel )
   uint ges_goto( gedsel, uint )
   uint ges_recno( gedsel )
   uint ges_eof( gedsel )
   uint ges_reverse( gedsel )
   uint ges_updateindex( gedsel )
   uint ges_update( gedsel )

/*   
   uint ged_goto( uint, uint )
   uint ged_records( uint )*/
}

include 
{
   "gedbase.g"
   "gedfield.g"
   "gedrecord.g"
   "gedselect.g"
}
