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

#include "windows.h"
#include "../../common/types.h"
#include "../../os/user/defines.h"
#include "../../algorithm/qsort.h"

// Type of fields
#define  FT_BYTE    1   // byte
#define  FT_UBYTE   2   // unsigned byte
#define  FT_SHORT   3   // short
#define  FT_USHORT  4   // unsigned short
#define  FT_INT     5   // int
#define  FT_UINT    6   // unsigned int
#define  FT_LONG    7   // long
#define  FT_ULONG   8   // unsigned long
#define  FT_FLOAT   9   // float
#define  FT_DOUBLE  10   // double
#define  FT_STR     11   // ANSI string ( 1-255 )
#define  FT_USTR    12   // Unicode string ( 1-255 )

// Select filter commands
#define  SF_END     0   // Finish of commands
#define  SF_ALL     1   // All records (exclude deleted)
#define  SF_EQ      2   // field == value
#define  SF_LESS    3   // field < value
#define  SF_GREAT   4   // field > value

#define  SF_NOT     0x10000000  // Not flag for commands
#define  SF_OR      0x20000000  // OR to the next command, by default AND

// Index flags
#define  IF_DESC    0x10000000  // Descend order
//#define  IF_END     0xFFFF      // End of the index list

/* Code for additonal information
[gedhead]
ubyte  code
ushort size of the information
       information
*/
#define  GEI_GENTEE    1   // Gentee information

// Error codes
#define  GDE_OK        0   // No error
#define  GDE_GEDEXIST  1   // ged base exists. What to do 
                           // 0 - overwrite 1 - error default - error
#define  GDE_OPENFILE  2   // Cannot open file - filename in ged->dbfile
#define  GDE_WRITEFILE 3   // Cannot write file - filename in ged->dbfile
#define  GDE_FORMAT    4   // Format of database files is wrong
#define  GDE_READFILE  5   // Cannot read file - filename in ged->dbfile

#define  GED_STRING  0x00444547   // 'GE' string

typedef uint  ( __cdecl *gentee_call )( uint, puint, ... );
typedef int   ( __stdcall *cmp_func )( const pvoid, const pvoid );

// Database header
typedef struct _gedhead
{
   uint     ext;       // GED string
   ubyte    size;      // Sizeof of the header structure
   uint     oversize;  // Size of all header information
   ushort   numfields; // Amount of columns
   ushort   autoid;    // The number of autoincrement field from 1
} gedhead, * pgedhead;

// Field init
typedef struct _gedfieldinit
{
   uint    ftype;        // hiword size for FT_STR & FT_USTR
   pubyte  name;
} gedfieldinit, * pgedfieldinit; 

// Database column info
typedef struct _gedfield
{
   uint    ftype;
   pubyte  name;
   uint    width;
   uint    offset;
} gedfield, * pgedfield; 

typedef struct _gedmem
{
   buf          record;   // Temporary record
   buf          head;
   buf          data;     // Database 
   str          dbfile;   // Name of database file
   str          dbname;   // Name of database
} gedmem, * pgedmem;

typedef struct _ged
{
   pubyte       filename;       // Name of database file
   gentee_call  call;           // gentee_call notify function
   uint         nfyparam;       // The first parameter of gentee_call
   uint         error;          // Pointer to error
   uint         autoid;         // The latest auto id for open 
                                // for create == autoincrement field from 1

   pgedhead     head;     // Database header
   pgedfield    fields;   // Pointer to columns info
   pubyte       db;       // Pointer to the first record
   uint         handle;   // Handle of the ged file
   uint         fsize;    // The size of the field
   uint         reccount; // The count of records
   uint         reccur;   // The current record
   pubyte       recptr;   // The pointer to the record
   pgedmem      gm;
} ged, * pged;

typedef struct _pselmem
{
   buf   selected;   // selected records
   buf   index;      // indexes
   buf   filter;     // filters
} selmem, * pselmem;

typedef struct _gedsel
{
   pged         pdb;      // Database
   uint         reccount; // The count of records
   uint         reccur;   // The current record from 1 
   pselmem      sm;
} gedsel, * pgedsel;


BOOL   ged_close( pged pdb );
BOOL   ged_create( pged pdb, pgedfieldinit pfi );
BOOL   ged_open( pged pdb );
uint   ged_goto( pged pdb, uint pos );
BOOL   ged_eof( pged pdb );
uint   ged_recno( pged pdb );

pgedfield  ged_field( pged pdb, uint ind );
uint       ged_findfield( pged pdb, pubyte name );
pubyte     ged_fieldptr( pged pdb, uint ind, uint ifield );
uint       ged_getuint( pged pdb, uint ind, uint ifield );
long64     ged_getlong( pged pdb, uint ind, uint ifield );
float      ged_getfloat( pged pdb, uint ind, uint ifield );
double     ged_getdouble( pged pdb, uint ind, uint ifield );

uint   ged_append( pged pdb, puint ptr );
uint   ged_isdel();

BOOL   ged_write( pged pdb, pubyte data, long64 pos, uint size );

BOOL   ges_select( pgedsel psel, pged pdb, puint filter, puint index );
BOOL   ges_close( pgedsel psel );
uint   ges_goto( pgedsel psel, uint pos );
BOOL   ges_index( pgedsel psel, puint index );
uint   ges_recno( pgedsel psel );
BOOL   ges_eof( pgedsel psel );
BOOL   ges_update( pgedsel psel );
BOOL   ges_updateindex( pgedsel psel );
BOOL   ges_reverse( pgedsel psel );


int   cmpubyte( pubyte left, pubyte right, uint len );
int   cmpushort( pushort left, pushort right, uint len );
int   cmpuint( puint left, puint right, uint len );
int   cmpbyte( char* left, char* right, uint len );
int   cmpshort( pshort left, pshort right, uint len );
int   cmpint( pint left, pint right, uint len );
int   cmpstr( pubyte left, pubyte right, uint len );
int   cmpustr( pushort left, pushort right, uint len );

#define PDATA &pdb->gm->data
#define PFILE &pdb->gm->dbfile
#define PHEAD &pdb->gm->head
#define PRECORD &pdb->gm->record

#define PSELECT &psel->sm->selected
#define PINDEX  &psel->sm->index
#define PFILTER &psel->sm->filter
//pubyte gedsel_goto( pgedsel psel, uint pos );

