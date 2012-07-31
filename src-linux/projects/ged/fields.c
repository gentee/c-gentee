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

#include "ged.h"

uint  ged_findfield( pged pdb, pubyte name )
{
   uint i, len = mem_len( name ) + 1;

   for ( i = 0; i< pdb->head->numfields; i++ )
   {
      if ( !mem_cmpign( pdb->fields[ i ].name, name, len ))
         return i + 1;
   }
   return 0;
}

pgedfield  ged_field( pged pdb, uint ind )
{
   return pdb->fields + ind;
}

pubyte  ged_fieldptr( pged pdb, uint ind, uint ifield )
{
   if ( !ind )
      return buf_ptr( PRECORD );
   return pdb->db + ( ind - 1 ) * pdb->fsize + pdb->fields[ ifield ].offset;
}

uint    ged_getuint( pged pdb, uint ind, uint ifield )
{
   puint pval = ( puint )ged_fieldptr( pdb, ind, ifield );

   if ( pdb->fields[ ifield ].ftype <= FT_UBYTE )
      return *( pubyte )pval;
   if ( pdb->fields[ ifield ].ftype <= FT_USHORT )
      return *( pushort )pval;
   return *pval;
}

long64     ged_getlong( pged pdb, uint ind, uint ifield )
{
   return *( plong64 )ged_fieldptr( pdb, ind, ifield );
}

float      ged_getfloat( pged pdb, uint ind, uint ifield )
{
   return *( float* )ged_fieldptr( pdb, ind, ifield );
}

double     ged_getdouble( pged pdb, uint ind, uint ifield )
{
   return *( double* )ged_fieldptr( pdb, ind, ifield );
}
