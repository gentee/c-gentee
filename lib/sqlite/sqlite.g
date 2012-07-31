/******************************************************************************
*
* Copyright (C) 2009, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* Author: Alexander Antypenko ( santy ) v. 1.00
*
******************************************************************************/
define { SQLITEOLD = 1 }
define 
{
 SQLITE_OK          = 0   /* Successful result */
 SQLITE_ERROR       = 1   /* SQL error or missing database */
 SQLITE_INTERNAL    = 2   /* An internal logic error in SQLite */
 SQLITE_PERM        = 3   /* Access permission denied */
 SQLITE_ABORT       = 4   /* Callback routine requested an abort */
 SQLITE_BUSY        = 5   /* The database file is locked */
 SQLITE_LOCKED      = 6   /* A table in the database is locked */
 SQLITE_NOMEM       = 7   /* A malloc() failed */
 SQLITE_READONLY    = 8   /* Attempt to write a readonly database */
 SQLITE_INTERRUPT   = 9   /* Operation terminated by sqlite_interrupt() */
 SQLITE_IOERR       = 10   /* Some kind of disk I/O error occurred */
 SQLITE_CORRUPT     = 11   /* The database disk image is malformed */
 SQLITE_NOTFOUND    = 12   /* (Internal Only) Table or record not found */
 SQLITE_FULL        = 13   /* Insertion failed because database is full */
 SQLITE_CANTOPEN    = 14   /* Unable to open the database file */
 SQLITE_PROTOCOL    = 15   /* Database lock protocol error */
 SQLITE_EMPTY       = 16   /* (Internal Only) Database table is empty */
 SQLITE_SCHEMA      = 17   /* The database schema changed */
 SQLITE_TOOBIG      = 18   /* Too much data for one row of a table */
 SQLITE_CONSTRAINT  = 19   /* Abort due to contraint violation */
 SQLITE_MISMATCH    = 20   /* Data type mismatch */
 SQLITE_MISUSE      = 21   /* Library used incorrectly */
 SQLITE_NOLFS       = 22   /* Uses OS features not supported on host */
 SQLITE_AUTH        = 23   /* Authorization denied */
 SQLITE_ROW         = 100  /* sqlite_step() has another row ready */
 SQLITE_DONE        = 101  /* sqlite_step() has finished executing */
 SQLITE_ANY         = 5
 
 SQLITE_TRANSIENT   = -1
}

define 
{
 SQLITE_INTEGER  = 1
 SQLITE_FLOAT    = 2
 SQLITE_TEXT     = 3
 SQLITE_BLOB     = 4
 SQLITE_NULL     = 5
}

import "sqlite3.dll"
{
   uint sqlite3_open16(uint,uint)  
   uint sqlite3_close(uint)        
   uint sqlite3_prepare16_v2(
      uint,    //1 Database handle
      uint,    //2 SQL statement, UTF-16 encoded 
      uint,    //3 Length of zSql in bytes. 
      uint,  	//4 OUT: Statement handle 
      uint     //5 OUT: Pointer to unused portion of zSql 
   )
   
   uint sqlite3_finalize(uint)   
   uint sqlite3_step(uint)
   
   uint sqlite3_column_blob(uint,uint)   
   uint sqlite3_column_bytes(uint,uint)
   uint sqlite3_column_bytes16(uint,uint)
   uint sqlite3_column_count(uint)
   uint sqlite3_column_name16(uint,uint)
   uint sqlite3_column_text16(uint,uint)
   uint sqlite3_column_text(uint,int)
   uint sqlite3_column_type(uint,uint)
   
   uint sqlite3_errmsg(uint)
   
   uint sqlite3_last_insert_rowid(uint)
   int sqlite3_bind_blob(uint, int, uint, int, uint )
   int sqlite3_bind_text16(uint, int, uint, int, uint )
   int sqlite3_bind_int(uint, int, int);  
   uint sqlite3_create_function16( uint, uint, uint, uint, uint, uint, uint, uint )
   uint sqlite3_create_function( uint, uint, uint, uint, uint, uint, uint, uint )
   uint sqlite3_value_text16( uint )
   uint sqlite3_result_text16( uint, uint, uint, uint )
   
   uint sqlite3_backup_init( uint, uint, uint, uint )
   int sqlite3_backup_step( uint, int )
   int sqlite3_backup_finish( uint ) 
/*  
  uint sqlite3_get_table(uint,uint,uint,uint,uint,uint) // Функция аналогична sqlite3_exec, но есть другие параметры                                                      //возврата
                                   // Пар.: 
                                  // 1. Идент. базы
                                  // 2. Строка операторов SQL
                                  // 3. Массив строк куда записиваются даные
                                  // 4. Количество строк
                                  // 5. Количество полей
                                  // 6. Строка куда записивается описание ошибки (адрес)
 
  uint sqlite3_exec(uint,uint,uint,uint,uint)// Функция запусу SQL операторов 
                                  // Пар.: 
                                  // 1. Идент. базы
                                  // 2. Строка операторов SQL
                                  // 3. Функция возврата callBack (в нашем функции нету -0)
                                  // 4. Первий аргумент в функцию возврата (0)
                                  // 5. Строка куда записивается описание ошибки (адрес)
  uint sqlite3_errmsg(uint)
  uint sqlite3_errcode(uint) 

  sqlite3_free(uint)
  sqlite3_free_table(uint)
 
  uint sqlite3_prepare(
     uint,            	/* Database handle 
     uint,       	/* SQL statement, UTF-8 encoded 
     uint ,             /* Length of zSql in bytes. 
     uint,  		/* OUT: Statement handle 
     uint     		/* OUT: Pointer to unused portion of zSql 
  )
  uint sqlite3_prepare_v2(
     uint,            	/* Database handle 
     uint,       	/* SQL statement, UTF-8 encoded 
     uint ,             /* Length of zSql in bytes. 
     uint,  		/* OUT: Statement handle 
     uint     		/* OUT: Pointer to unused portion of zSql 
  )
  uint sqlite3_data_count(uint)
  
  uint sqlite3_column_name(uint,int)
  uint  sqlite3_column_type(uint, int)
  uint sqlite3_column_blob(uint, int)
  int  sqlite3_column_bytes(uint, int)
  double sqlite3_column_double(uint,int)
  uint  sqlite3_column_int(uint,int)
  uint sqlite3_column_text(uint,int)
  
  
  uint  sqlite3_changes(uint)
  uint  sqlite3_busy_timeout(uint,int)
  uint sqlite3_create_function( uint, uint, uint, uint, uint, uint, uint, uint )
  uint sqlite3_value_text( uint )
  sqlite3_result_text( uint, uint, uint, uint )*/
}

ifdef $SQLITEOLD
{
type sqlite
{
   uint db
   uint Stmt
   arrustr col_names
   hash    hcol   
   arr     rows of arrustr // array of column values                 
   uint    sqliteold
}
}
else
{
type sqlite
{
   uint db
   uint Stmt
   arrustr col_names
   hash    hcol   
   arr     rows of arrustr // array of column values                 
}
}

method uint sqlite.close()
{
   if this.db
   {
      if sqlite3_close( this.db ) != $SQLITE_OK : return 0      
   }
   return 1
}

method uint sqlite.open( ustr filename )
{
   if (this.db) : .close()
   
   if sqlite3_open16( filename.ptr(), &this.db ) != $SQLITE_OK 
   {
      //this.error_message.copy(sqlite3_errmsg(this.db))
      return 0
   }
      
   return 1
}

/*method sqlite3.getColumnsValue(uint colnum, uint uLich)
{
   uint itypeCol = sqlite3_column_type( this.Smtp, colnum )
   
  uint i  
  this.col_val.expand(1)     
  this.col_val[*this.col_val-1].values.expand(num_columns)
  fornum i=0, num_columns
  {
    str sqarray// = "sss"
    
    switch (this.col_types[i])
    {
      case $SQLITE_INTEGER 
       {               
        // sqarray = "\(*this.col_val-1)" 
         uint int_ptr = sqlite3_column_text(this.compiled_sql_ptr,i)
         if (int_ptr):  sqarray.copy(int_ptr)
       }
      case $SQLITE_FLOAT
       {               
         uint float_ptr = sqlite3_column_text(this.compiled_sql_ptr,i)
         if (float_ptr) : sqarray.copy(float_ptr)
       }
      case $SQLITE_TEXT 
       {         
         uint text_ptr = sqlite3_column_text(this.compiled_sql_ptr,i)
         uint err
         if (text_ptr)  : sqarray.copy(text_ptr)
            
         
         
       }
      case $SQLITE_BLOB 
       {                       
         uint blob_ptr = sqlite3_column_blob(this.compiled_sql_ptr,i)
         uint blob_len = sqlite3_column_bytes(this.compiled_sql_ptr,i) 
         if (blob_ptr)  : sqarray.load(blob_ptr,blob_len)
       }
      case $SQLITE_NULL : sqarray=""
    }
    //print( "add \(*this.col_val-1) \(i) = \(sqarray)\n" )
    this.col_val[*this.col_val-1].values[i] = sqarray    
  }
}
*/


method uint sqlite.execute( ustr sql, collection bind )
{  
   uint res
   uint i, idx
  //print( "z1 \(sql.str())\n" )
   if sqlite3_prepare16_v2( this.db, sql.ptr(), *sql->buf, &.Stmt, 0 ) == $SQLITE_OK 
   {
      if &bind 
      {
         fornum i=0, *bind
         {
            switch bind.gettype( i )
            {
               case uint
               {
                  if sqlite3_bind_int( .Stmt, i + 1, bind[i] ) != $SQLITE_OK
                  {  
                     return 0
                  }
               }
               case ustr
               {  
                  if sqlite3_bind_text16( .Stmt, i + 1, bind[i]->buf.ptr(), *bind[i]->buf - 1, $SQLITE_TRANSIENT ) != $SQLITE_OK
                  {  
                     return 0
                  }
               }
               case buf
               {                  
                  if sqlite3_bind_blob( .Stmt, i + 1, bind[i]->buf.ptr(), *bind[i]->buf, $SQLITE_TRANSIENT ) != $SQLITE_OK
                  {  
                     return 0
                  }
               }
            }
         }
      }
   
   //print( "z2 \(sql.str())\n" )  
      uint numcols = sqlite3_column_count( .Stmt )

      this.col_names.clear()      
      this.col_names.expand(numcols)
      this.hcol.clear()
      
      fornum i = 0, numcols
      {
         this.col_names[i].copy( sqlite3_column_name16( .Stmt, i ) )
         this.hcol[this.col_names[i].str()] = i
      }

      this.rows.clear()      
      while 1 
      {    
         switch sqlite3_step( this.Stmt )
         {
            case $SQLITE_ROW  
            {            
               .rows[.rows.expand(1)].expand(numcols)
               fornum i = 0, numcols
               {
                  switch sqlite3_column_type( .Stmt, i )
                  {
                     case $SQLITE_INTEGER, $SQLITE_FLOAT, $SQLITE_TEXT
                     {                        
ifdef $SQLITEOLD
{                       if .sqliteold
                        {
                           str tmp
                           tmp.copy( sqlite3_column_text( .Stmt, i ) , 
                                       sqlite3_column_bytes( .Stmt, i ) )
                                
                           .rows[idx][i] = tmp.ustr()
                        }  
                        else
                        {
                           .rows[idx][i]->buf.copy( sqlite3_column_text16( .Stmt, i ) , 
                                    sqlite3_column_bytes16( .Stmt, i ) + 2 )
                        }
}
else
{
                        .rows[idx][i]->buf.copy( sqlite3_column_text16( .Stmt, i ) , 
                                    sqlite3_column_bytes16( .Stmt, i ) + 2 )
}                                                            
                     }                      
                     case $SQLITE_BLOB 
                     {                       
                        .rows[idx][i]->buf.copy( sqlite3_column_blob( .Stmt, i ), 
                                    sqlite3_column_bytes( .Stmt, i ) )
                     }
                  }
               }               
               idx+=1   
            } 
            case $SQLITE_DONE 
            {
               res = 1
               break
            } 
            default 
            {  
               break
            }  
         }
      }
      sqlite3_finalize( .Stmt )    
   }  
   
   return res
} 

method uint sqlite.execute( ustr sql )
{
   return .execute( sql, 0->collection )
}

method uint sqlite.lastrowid()
{
  if this.db : return sqlite3_last_insert_rowid( this.db )
  else : return  0
}

method uint sqlite.bind( uint numpar, buf value )
{
   if sqlite3_bind_blob( .Stmt, numpar, value.ptr(), *value, $SQLITE_TRANSIENT ) ==
      $SQLITE_OK
   {
      return 1
   }
   /*str s 
   s.copy( sqlite3_errmsg(this.db) )
   print( "err \(s)\n" )
   print( "noblo\n" )*/
   return 0
}

method uint sqlite.createfunc( str name, uint addr, uint numpar ) 
{   
   //uint addr = callback(addr,3,$CB_CDECL )
   //print( "addr \(name) \(addr )\n" )
   //return sqlite3_create_function(.db,name.ptr(),numpar,$SQLITE_ANY,0,addr,0,0)
   return sqlite3_create_function(.db,name.ptr(),numpar,$SQLITE_ANY,0,callback(addr,3,$CB_CDECL ),0,0)
}

method uint sqlite.colindex( ustr colname )
{
   uint item
   if item = this.hcol.find( colname.str() ) : return item->uint
   return -1
}


method uint sqlite.backup( ustr destbase )
{
   uint bcdb
   uint res 
   if sqlite3_open16( destbase.ptr(), &bcdb ) == $SQLITE_OK
   {    
      uint bc = sqlite3_backup_init( bcdb, "main".ptr(), this.db, "main".ptr() )
      if bc 
      {
         uint step
         do 
         { 
            step = sqlite3_backup_step( bc, -1 )            
         }
         while step == $SQLITE_OK
         if step == $SQLITE_DONE : res = 1 
         sqlite3_backup_finish( bc )         
      }
      sqlite3_close( bcdb )
   }
   return res       
}

//method s
/*
type arr_str
{
  arrstr values;
}

operator arr_str =(arr_str aLeft,arrstr aRight) 
{
	aLeft.values=aRight
	return aLeft;
}


type sqlite3
{
  uint db            // database handle
  uint db_ptr        // ptr to database handle
  str error_message
  arrstr col_names      // array of column headers
  arr    col_types of uint  // array of column types
  arr col_val of arr_str // array of column values
  uint compiled_sql_ptr  // ptr to compiled sql
  uint  rc               // result data
  byte transStarted  
}
extern 
{
 method int sqlite3.sql_execute(str sql_code)
 method sqlite3.getColumnsValue(uint num_columns,uint uLich)
 method sqlite3.getColumnsType(uint num_columns)
 method sqlite3.getColumnNames(uint num_columns)   
} 

/*-----------------------------------------------------------------------------
* @syntax [ sql3.tables(arrstr arrTables) ]
*
* @return A array of tables names in the database.
-----------------------------------------------------------------------------*x
method uint sqlite3.tables(arrstr arrTables)
{
  uint uretData = 0
  this.col_val.clear()
  if this.db 
  {
    uretData=this.sql_execute("select tbl_name from sqlite_master;")
    uint i
    fornum i=0,*this.col_val  : arrTables+=this.col_val[i].values[0]
  }
  return  uretData
}

/*-----------------------------------------------------------------------------
* @syntax [ sql3.columns(str aTableName,arrstr asColumns) ]
*
* @return A arrstr of column names for a table.
-----------------------------------------------------------------------------*x
method uint sqlite3.columns(str aTableName, arrstr asColumns)
{
  str sql_text = "select * from "+aTableName+" where 0;"
  uint uretData = 0
  if this.db {
    uretData=this.sql_execute(sql_text)
    asColumns = this.col_names
  }
  return uretData
}

/*-----------------------------------------------------------------------------
* @syntax  [ sql3.change() ]
*
* @return The Number of rows changed/affected by the last SQL statement.
-----------------------------------------------------------------------------*x
method uint sqlite3.changes()
{
  if this.db : return sqlite3_changes(this.db)
  else : return  0
}

/*-----------------------------------------------------------------------------
* @syntax  [ sql3.rollbackTrans() ]
*
* @return RollBack changed data 
-----------------------------------------------------------------------------*x
method int sqlite3.rollbackTrans()
{
  uint uretData = 0
  if this.db {
     this.transStarted = 0
     uretData=this.sql_execute("ROLLBACK")
  }
  return  uretData
}

/*-----------------------------------------------------------------------------
* @syntax  [ sql3.beginTrans() ]
*
* @return Start transaction for current data 
-----------------------------------------------------------------------------*x
method int sqlite3.beginTrans()
{
  uint uretData = 0
  if this.db {
     this.transStarted = 1
     uretData=this.sql_execute("BEGIN")
  }
  return  uretData
}

/*-----------------------------------------------------------------------------
* @syntax  [ sql3.commitTrans() ]
*
* @return set changed data in the current database
-----------------------------------------------------------------------------*x
method int sqlite3.commitTrans()
{
  uint uretData = 0
  if this.db {
     this.transStarted = 0
     uretData=this.sql_execute("COMMIT")
  }
  return  uretData
}

/*-----------------------------------------------------------------------------
* @syntax  [ sql3.vacuumData() ]
*
* @return Pack database space after drop (delete) data from current database
-----------------------------------------------------------------------------*x
method int sqlite3.vacuumData()
{
  uint uretData = 0
  if this.db {
     uretData=this.sql_execute("VACUUM")
  }
  return  uretData
}

/*-----------------------------------------------------------------------------
* @syntax  [ sql3.columnsCount() ]
*
* @return Return count of columns after sql query for current database
-----------------------------------------------------------------------------*x
method int sqlite3.columnsCount() :   return *this.col_names

/*-----------------------------------------------------------------------------
* @syntax  [ sql3.recordsCount() ]
*
* @return Return count of records after sql query for current database
-----------------------------------------------------------------------------*x
method int sqlite3.recordsCount() :   return *this.col_val

/*-----------------------------------------------------------------------------
* @syntax [ sql3.allIndexes(arrstr arrIndexes)]
*
* @return A array of indexes names in the database.
-----------------------------------------------------------------------------*x
method uint sqlite3.allIndexes(arrstr arrIndexes)
{
  uint uretData = 0
  this.col_val.clear()
  if this.db 
  {
    uretData=this.sql_execute("select name from sqlite_master where type = 'index';")
    uint i
    fornum i=0,*this.col_val  : arrIndexes+=this.col_val[i].values[0]
  }
  return  uretData
}

/*-----------------------------------------------------------------------------
* @syntax [ sql3.indexesOfTable(str sTable,arrstr arrIndOfTable)]
*
* @return A array of indexes names in the given table.
-----------------------------------------------------------------------------*x
method uint sqlite3.indexesOfTable(str sTable, arrstr arrIndOfTable)
{
  uint uretData = 0
  this.col_val.clear()
  if this.db 
  {
    uretData=this.sql_execute("select name from sqlite_master where type = 'index' and tbl_name='+sTable+';")
    uint i
    fornum i=0,*this.col_val  : arrIndOfTable+=this.col_val[i].values[0]
  }
  return  uretData
}

/*-----------------------------------------------------------------------------
* @syntax [ sql3.allViews(arrstr arrViews)]
*
* @return A array of indexes names in the database.
-----------------------------------------------------------------------------*x
method uint sqlite3.allViews(arrstr arrViews)
{
  uint uretData = 0
  this.col_val.clear()
  if this.db 
  {
    uretData=this.sql_execute("select name from sqlite_master where type = 'view';")
    uint i
    fornum i=0,*this.col_val  : arrViews+=this.col_val[i].values[0]
  }
  return  uretData
}

/*-----------------------------------------------------------------------------
* @syntax [ sql3.columnName(int iColumnIndex) ]
*
* @return A array of indexes names in the database.
-----------------------------------------------------------------------------*x
method str sqlite3.columnName(int iColumnIndex) : return this.col_names[iColumnIndex]                                              

*/




import "user32" {
   uint CharLowerW( uint )
   uint CharUpperW( uint )
}
 
func lower(uint ctx, int narg, uint args )
{    
   uint p 
   if p = sqlite3_value_text16( args->uint )
   {
      print( "lower\n" )
      CharLowerW( p )
      sqlite3_result_text16(ctx, p, -1, $SQLITE_TRANSIENT )
   }
   return
}

func upper(uint ctx, int narg, uint args )
{    
   uint p
   if p = sqlite3_value_text16( args->uint )
   {
      print( "upper\n" )
      CharUpperW( p )
      sqlite3_result_text16(ctx, p, -1, $SQLITE_TRANSIENT )
   }
   return
}
/*global { uint cbupper, cblower }
func cb<entry>()
{
   //cbupper = callback(&UPPER,12)
   cblower = callback(&LOWER,12)
}*/

func a<main>
{
   sqlite s
   print( "\(s.open( $"K:\Gentee\Open Source\mclip\db\mclip.db".ustr() ))\n" )
//s.execute( "TRUNCATE TABLE notice".ustr() )
/*s.execute( "TRUNCATE TABLE noticeitems".ustr() )
s.execute( "DROP TABLE noticegroups".ustr() )
s.execute( "DROP TABLE notice".ustr() )
//s.execute( "DROP TABLE noticeitems".ustr() )
   s.execute( "CREATE TABLE noticegroups
(
id          INTEGER PRIMARY KEY AUTOINCREMENT,
idowner     INTEGER,
inlist      INTEGER,
caption     CHAR(256),
comment     CHAR(256),
flags       INTEGER,
prefix      CHAR(20),
autotext    CHAR(20),
postfix     CHAR(20)
)".ustr() )   
         
   s.execute( "CREATE TABLE notice
(
id          INTEGER PRIMARY KEY AUTOINCREMENT,
changed     DATE,
caption     CHAR( 256 ),
format      INTEGER,
idowner     INTEGER,
hotkey      INTEGER,
flags       INTEGER,
prefix      CHAR(20),
autotext    CHAR(20),
postfix     CHAR(20)
)".ustr() )*/
/*
   s.execute( "CREATE TABLE noticeitems
(
id          INTEGER PRIMARY KEY AUTOINCREMENT,
histid      INTEGER,
formatid    INTEGER,
formatname  CHAR( 256 ),
value       BLOB
)".ustr() )   
*/
   
/*   s.execute( "DROP TABLE history".ustr() )
   s.execute( "DROP TABLE histitems".ustr() )
   s.execute( "CREATE TABLE history
(
id          INTEGER PRIMARY KEY AUTOINCREMENT,
fileexe     CHAR( 256 ),
wincaption  CHAR( 256 ),
changed     DATE,
caption     CHAR( 256 ),
format      INTEGER
)".ustr() )

   s.execute( "CREATE TABLE historyitems
(
id          INTEGER PRIMARY KEY AUTOINCREMENT,
histid      INTEGER,
formatid    INTEGER,
formatname  CHAR( 256 ),
value       BLOB
)".ustr() )
/*
   s.execute( "CREATE TABLE fast
(
id          INTEGER PRIMARY KEY AUTOINCREMENT,
fileexe     CHAR( 256 ),
wincaption  CHAR( 256 ),
changed     DATE,
caption     CHAR( 256 ),
format      INTEGER
)".ustr() )

   s.execute( "CREATE TABLE fastitems
(
id          INTEGER PRIMARY KEY AUTOINCREMENT,
histid      INTEGER,
formatid    INTEGER,
formatname  CHAR( 256 ),
value       BLOB
)".ustr() )*/
   //s.createfunc( "LOWER", &lower, 1 )   
   //s.createfunc( "UPPER", &upper, 1 )
   uint t, x 
   /*fornum t=0, 100000000
      {
         x++ 
      }*/
   //print( "\(s.execute( "DELETE FROM history WHERE caption=''".ustr() ))\n" )
   //print( "\(s.execute( "SELECT value FROM histitems WHERE formatid=13 ORDER by trim(value)".ustr() ))\n" )
   
   //print( "\(s.execute( "SELECT * FROM historyitems".ustr() ))\n" )
   print( "\(s.execute( "SELECT * FROM noticeitems".ustr() ))\n" )
   uint i, j
   fornum i = 0, *s.rows
   {      
      fornum j = 0, *s.col_names
      {
         print( "[\(s.rows[i][j].str())]\n" )
      }
      //if !(i % 20) : 
      getch()
   }  //р с т у ф └ ┴ ┬ ├ ─
   getch()
   s.close()
   
}

