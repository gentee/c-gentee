/******************************************************************************
*
* Copyright (C) 2005, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: samefiles 17.10.06 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
******************************************************************************/

type  finf
{
   str   name
   uint  size
   uint  owner
}

global
{
   arr dirs  of finf
   arr files of finf
   arr sizes of uint
   str output
}

func uint newdir( str name, uint owner )
{
   uint i
   
   i = dirs.expand( 1 )
   dirs[ i ].name = name
   dirs[ i ].owner = owner
   return i
}

func uint newfile( str name, uint size owner )
{
   uint i
   
   i = files.expand( 1 )
   files[ i ].name = name
   files[ i ].size = size
   files[ i ].owner = owner
   return i
}

func scanfolder( str wildcard, uint owner )
{
   ffind fd
   
   fd.init( wildcard, $FIND_FILE | $FIND_DIR )
   foreach cur, fd
   {
      if cur.attrib & $FILE_ATTRIBUTE_DIRECTORY
      {
         scanfolder( cur.fullname + "\\*.*", newdir( cur.name, owner ))
      }
      elif !cur.sizehi : newfile( cur.name, cur.sizelo, owner )      
   }
} 

func scaninit( str folder )
{
   str wildcard

   folder.fdelslash()   
   @"Scanning \( folder )\n"
   scanfolder( (wildcard = folder ).faddname( "*.*" ), newdir( folder, 0 ))
}

func int sortsize( uint left right )
{
   return int( files[ left->uint ].size ) - int( files[ right->uint ].size )
}

func sortfiles
{
   uint i
   
   @"Sorting...\n"
   sizes.expand( *files )
   fornum i, *sizes : sizes[ i ] = i

   sizes.sort( &sortsize ) 
}

func str getdir( uint id, str ret )
{
   uint owner = dirs[ id ].owner

   if owner : getdir( owner, ret )
   return ret.faddname( dirs[ id ].name )
}

func str getfile( uint id, str ret )
{
   ret.clear()
   
   getdir( files[ id ].owner, ret )
   return ret.faddname( files[ id ].name )
}

func compare
{
   uint i id next j found count
   str  idname nextname 
   
   @"Looking for duplicates...\n"
   
   fornum i, *sizes - 1
   {
      id = sizes[ i ]

      if !*files[ id ].name : continue

      found = 0            
      next = sizes[ j = i + 1 ]
      
      while files[ id ].size == files[ next ].size
      {
         if *files[ next ].name &&
             isequalfiles( getfile( id, idname ), getfile( next, nextname ))
         {
            if !found
            {
               output @ "\lSize: \(files[ id ].size) ========\l\( idname )\l" 
            }
            count++
            ( output @ nextname ) @"\l"
            
            found = 1
            files[ next ].name.clear()
         }
         if ++j == *sizes : break
         next = sizes[ j ]
      }
      if i && !( i & 0x3F ) 
      {
         @ "\rApproved files: \(i) Found the same files: \(count)"
      }
   }   
   output @ "\l=================\lApproved files: \(*files) Found the same files: \(count)\l"
}

func init
{
   dirs.reserve( 1000 )
   files.reserve( 20000 )
   output.reserve( 1000000 )
   dirs.expand( 1 )
}

func search
{
   @"All files : \( *files )\n"
  
   if !*files : return
   sortfiles()
   compare()
   output.write("samefiles.txt")
   shell( "samefiles.txt" )
}

func main<main>
{
   str  folder 
   
   init()
      
   congetstr("Specify a folder or a drive (C:) for searching: \n", folder )
   scaninit( folder )
   search()   
}