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

import "sqlite3.dll"<cdeclare>{
  uint sqlite3_open(uint,uint)    // Функция открытия базы даных 
                                  // Пар: 1- название базы; 2- идентификатор открытой базы
  uint sqlite3_close(uint)        // Функция закрытия базы даных
                                  //  Пар: 1- идентификатор открытой базы
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
     uint,            	/* Database handle */
     uint,       	/* SQL statement, UTF-8 encoded */
     uint ,             /* Length of zSql in bytes. */
     uint,  		/* OUT: Statement handle */
     uint     		/* OUT: Pointer to unused portion of zSql */
  )
  uint sqlite3_prepare_v2(
     uint,            	/* Database handle */
     uint,       	/* SQL statement, UTF-8 encoded */
     uint ,             /* Length of zSql in bytes. */
     uint,  		/* OUT: Statement handle */
     uint     		/* OUT: Pointer to unused portion of zSql */
  )
  uint sqlite3_column_count(uint)
  uint sqlite3_data_count(uint)
  uint  sqlite3_step(uint)
  uint sqlite3_column_name(uint,int)
  uint  sqlite3_column_type(uint, int)
  uint sqlite3_column_blob(uint, int)
  int  sqlite3_column_bytes(uint, int)
  double sqlite3_column_double(uint,int)
  uint  sqlite3_column_int(uint,int)
  uint sqlite3_column_text(uint,int)
  uint  sqlite3_finalize(uint)
  uint sqlite3_last_insert_rowid(uint)
  uint  sqlite3_changes(uint)
  uint  sqlite3_busy_timeout(uint,int)
  uint sqlite3_create_function( uint, uint, uint, uint, uint, uint, uint, uint )
  uint sqlite3_value_text( uint )
  sqlite3_result_text( uint, uint, uint, uint )
  
  uint sqlite3_backup_init( uint, uint, uint, uint )
  int sqlite3_backup_step( uint, int )
  int sqlite3_backup_finish( uint )
  
  int sqlite3_bind_blob(uint, int, uint, int, uint )
  int sqlite3_bind_text(uint, int, uint, int, uint )
  int sqlite3_bind_int(uint, int, int);  
}

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
  arr col_val of arrstr // array of column values
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


method sqlite3.init()
{

}
/*-----------------------------------------------------------------------------
* @syntax [ sql3.open(db_name) ]
*
* @param [db_name] The name of the database.
*
* @return A database handle or error in error_message field
*
* Opens or creates a database. If the database does exist it gets opened, 
* else a new database with the name given is created.
-----------------------------------------------------------------------------*/
func LOWER(uint ctx, int narg, uint args )
{    
   //if (narg)
   {
   uint p = sqlite3_value_text( args->uint )
   str s
   s.copy( p )
   /*uint i
   fornum i, 10
   {
      print( "\((p+i)->ubyte) " )
   }
   */
   s.lower()
   //print( "lLL \(narg) \(s)\n" )
   //s = "tttt"
   sqlite3_result_text(ctx,s.ptr(), *s, -1 )
   }
}
func UPPER(uint ctx, int narg, uint args )
{  
print( "up1\n" )  
   //if (narg)
   {
   uint p = sqlite3_value_text( args->uint )
   str s
   s.copy( p )
 /*  uint i
   fornum i, 10
   {
      print( "\((p+i)->ubyte) " )
   }*/
   
   s.upper()
   //print( "lLL \(narg) \(s)\n" )
   //s = "tttt"
   sqlite3_result_text(ctx, s.ptr(), *s, -1 )
   }
print( "up2\n" )   
}
global { uint cbupper, cblower }
func cb<entry>()
{
   cbupper = callback(&UPPER,12)
   cblower = callback(&LOWER,12)
}

method int sqlite3.open(str db_name)
{
  int iRetData = 1
  if (!this.db) 
  {
    ustr us = db_name
    str  s 
    us.toutf8( s )
    this.rc = sqlite3_open(s.ptr(), &this.db)
    if( this.rc != $SQLITE_OK )
    {
     this.error_message.copy(sqlite3_errmsg(this.db))
     sqlite3_close(this.db)
     iRetData = 0
    }    
    //print( "upper \(cbupper)\n" )
    //sqlite3_create_function(this.db,"LOWER".ptr(),1,1,0,cblower,0,0)
    //sqlite3_create_function(this.db,"zzz".ptr(),1,1,0,cbupper,0,0)
    //this.error_message.copy(sqlite3_errmsg(this.db))
    //print( this.error_message )
  } 
  else : this.error_message= "A database is already open"
  return iRetData;
}

/*-----------------------------------------------------------------------------
* @syntax [ sql3.close() ]
*
* Closes the currently open database.
-----------------------------------------------------------------------------*/
method sqlite3.close()
{
  if (this.db) 
  {
     sqlite3_close(this.db)
     this.db = 0
  } 
}

/*-----------------------------------------------------------------------------
* @syntax [ sql3.sql_execute(str sql_code) ]
*
* @param <sql_code> The SQL statement.
*
* Executes the SQL statement in <sql_code>. For 'select' statements an array 
* of the result set is returned (col_val)
-----------------------------------------------------------------------------*/

/*method int sqlite3.sql_execute(str sql_code)
{
  uint tail_ptr,num_cols=0,ich=0
  int done=0,result1 = 0,retCode=0  
  
  int iErr = sqlite3_prepare_v2(this.db,sql_code.ptr(),*sql_code,&this.compiled_sql_ptr,0) //&tail_ptr
  if (iErr == $SQLITE_OK) 
  {  
    this.col_val.clear()
    num_cols = sqlite3_column_count(this.compiled_sql_ptr)
    this.getColumnNames(num_cols)         
    while (!done) 
    {
         
         result1 = sqlite3_step(this.compiled_sql_ptr)
         uint i
         if (result1 == $SQLITE_ROW)  {
            
          this.getColumnsValue(num_cols,ich)
                      
         } 
         else : done = 1 
         ich+=1   
    }
    if(result1 == $SQLITE_DONE )
    {         
         retCode=1
    }  
    sqlite3_finalize(this.compiled_sql_ptr)
    
  }  
  return retCode
}*/
method uint sqlite3.sql_execute( str sql_code, collection bind )
{  
   uint res
   uint i, idx
  //print( "z1 \(sql.str())\n" )
   if sqlite3_prepare_v2( this.db, sql_code.ptr(), *sql_code->buf, &.compiled_sql_ptr, 0 ) == $SQLITE_OK 
   {
      if &bind 
      {
         fornum i=0, *bind
         {
            switch bind.gettype( i )
            {
               case uint
               {
                  if sqlite3_bind_int( .compiled_sql_ptr, i + 1, bind[i] ) != $SQLITE_OK
                  {  
                     return 0
                  }
               }
               case str
               {  
                  if sqlite3_bind_text( .compiled_sql_ptr, i + 1, bind[i]->buf.ptr(), *bind[i]->buf - 1, $SQLITE_TRANSIENT ) != $SQLITE_OK
                  {  
                     return 0
                  }
               }
               case buf
               {                  
                  if sqlite3_bind_blob( .compiled_sql_ptr, i + 1, bind[i]->buf.ptr(), *bind[i]->buf, $SQLITE_TRANSIENT ) != $SQLITE_OK
                  {  
                     return 0
                  }
               }
            }
         }
      }
   
      uint numcols = sqlite3_column_count( .compiled_sql_ptr )
      
      this.col_names.clear()      
      this.col_names.expand(numcols)
      //this.hcol.clear()
      
      fornum i = 0, numcols
      {
         this.col_names[i].copy( sqlite3_column_name( .compiled_sql_ptr, i ) )
         //this.hcol[this.col_names[i].str()] = i
      }

      this.col_val.clear()      
      while 1 
      {    
         switch sqlite3_step( this.compiled_sql_ptr )
         {
            case $SQLITE_ROW  
            {
               this.col_val[this.col_val.expand(1)].expand(numcols)
               fornum i = 0, numcols
               {
                  switch sqlite3_column_type( .compiled_sql_ptr, i )
                  {
                     case $SQLITE_INTEGER, $SQLITE_FLOAT, $SQLITE_TEXT
                     {                        
/*ifdef $SQLITEOLD
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
{*/
                        .col_val[idx][i]->buf.copy( sqlite3_column_text( .compiled_sql_ptr, i ) , 
                                    sqlite3_column_bytes( .compiled_sql_ptr, i ) + 1 )
//}                                                            
                     }                      
                     case $SQLITE_BLOB 
                     {                       
                        .col_val[idx][i]->buf.copy( sqlite3_column_blob( .compiled_sql_ptr, i ), 
                                    sqlite3_column_bytes( .compiled_sql_ptr, i ) )
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
      sqlite3_finalize( .compiled_sql_ptr )    
   }  
   
   return res
} 

method uint sqlite3.sql_execute( str sql )
{
   return .sql_execute( sql, 0->collection )
}
global { uint x }
method sqlite3.getColumnsValue(uint num_columns,uint uLich)
{
  uint i  
  this.col_val.expand(1)     
  this.col_val[*this.col_val-1].expand(num_columns)
  fornum i=0, num_columns
  {
    str sqarray// = "sss"
    
    switch (sqlite3_column_type( this.compiled_sql_ptr, i ))//this.col_types[i])
    {
      /*case $SQLITE_INTEGER 
       {               
        // sqarray = "\(*this.col_val-1)" 
         uint int_ptr = sqlite3_column_text(this.compiled_sql_ptr,i)
         if (int_ptr):  sqarray.copy(int_ptr)
       }*/
    /*  case $SQLITE_FLOAT
       {               
         uint float_ptr = sqlite3_column_text(this.compiled_sql_ptr,i)
         if (float_ptr) : sqarray.copy(float_ptr)
       }*/
      case $SQLITE_INTEGER, $SQLITE_FLOAT, $SQLITE_TEXT
       {         
         uint text_ptr = sqlite3_column_text(this.compiled_sql_ptr,i)
         uint err
         if (text_ptr) 
         {
            this.col_val[*this.col_val-1][i]->buf.copy(text_ptr, sqlite3_column_bytes( this.compiled_sql_ptr, i ) + 1)
            continue
         }
         /*ustr x 
         x.fromutf8( sqarray )
         print( "\(x.str())\n" )*/
            /*if (err = sqlite3_errcode(this.db)) && err !=100
            {
                print("error \(sqarray) \(err)\n")
                //getch()
            } */
         /*fornum i = 0 , 100000
         {
         text_ptr = sqlite3_column_text(this.compiled_sql_ptr,i)
            uint err
            if err = sqlite3_errcode(this.db)
            {
                print("error \(i) \(err)")
                getch()
            } 
         }
         //text_ptr = sqlite3_column_text(this.compiled_sql_ptr,i)
         x++
         if ( x > 4818 )
         {  
         getch()
          print( "\(x)\n" )
         }*/
         
       }
      /*case $SQLITE_BLOB 
       {                       
         uint blob_ptr = sqlite3_column_blob(this.compiled_sql_ptr,i)
         uint blob_len = sqlite3_column_bytes(this.compiled_sql_ptr,i) 
         if (blob_ptr)  : sqarray.load(blob_ptr,blob_len)
       }*/
      //case $SQLITE_NULL : 
    }
    //print( "add \(*this.col_val-1) \(i) = \(sqarray)\n" )
    this.col_val[*this.col_val-1][i]=""
  }
}

method sqlite3.getColumnNames(uint num_columns)
{
  uint i
  str sColName

  this.col_names.clear()
  for i=0,i < num_columns,i++
  {
     sColName.copy(sqlite3_column_name(this.compiled_sql_ptr, i))
     this.col_names += sColName
     sColName.clear()   
  }
}

method sqlite3.getColumnsType(uint num_columns)
{
  uint i
//  print( "ct1 \(*this.col_types) \(this.col_types.use)\n" )
  this.col_types.clear()
  //print( "ct2 \(*this.col_types) \(this.col_types.use)\n" )  
  if (num_columns > 0) {
   this.col_types.expand( num_columns )   
   for i=0,i < num_columns,i++ 
   {
     uint itypeCol = sqlite3_column_type(this.compiled_sql_ptr, i)
     //this.col_types += str(itypeCol)
     this.col_types[i] = $SQLITE_TEXT//itypeCol
   }
  }
}

/*-----------------------------------------------------------------------------
* @syntax [ sql3.rowid() ]
*
* @return The last row id from last 'insert'.
-----------------------------------------------------------------------------*/
method uint sqlite3.rowid()
{
  if this.db : return sqlite3_last_insert_rowid(this.db)
  else : return  0
}

/*-----------------------------------------------------------------------------
* @syntax [ sql3.tables(arrstr arrTables) ]
*
* @return A array of tables names in the database.
-----------------------------------------------------------------------------*/
method uint sqlite3.tables(arrstr arrTables)
{
  uint uretData = 0
  this.col_val.clear()
  if this.db 
  {
    uretData=this.sql_execute("select tbl_name from sqlite_master;")
    uint i
    fornum i=0,*this.col_val  : arrTables+=this.col_val[i][0]
  }
  return  uretData
}

/*-----------------------------------------------------------------------------
* @syntax [ sql3.columns(str aTableName,arrstr asColumns) ]
*
* @return A arrstr of column names for a table.
-----------------------------------------------------------------------------*/
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
-----------------------------------------------------------------------------*/
method uint sqlite3.changes()
{
  if this.db : return sqlite3_changes(this.db)
  else : return  0
}

/*-----------------------------------------------------------------------------
* @syntax  [ sql3.rollbackTrans() ]
*
* @return RollBack changed data 
-----------------------------------------------------------------------------*/
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
-----------------------------------------------------------------------------*/
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
-----------------------------------------------------------------------------*/
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
-----------------------------------------------------------------------------*/
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
-----------------------------------------------------------------------------*/
method int sqlite3.columnsCount() :   return *this.col_names

/*-----------------------------------------------------------------------------
* @syntax  [ sql3.recordsCount() ]
*
* @return Return count of records after sql query for current database
-----------------------------------------------------------------------------*/
method int sqlite3.recordsCount() :   return *this.col_val

/*-----------------------------------------------------------------------------
* @syntax [ sql3.allIndexes(arrstr arrIndexes)]
*
* @return A array of indexes names in the database.
-----------------------------------------------------------------------------*/
method uint sqlite3.allIndexes(arrstr arrIndexes)
{
  uint uretData = 0
  this.col_val.clear()
  if this.db 
  {
    uretData=this.sql_execute("select name from sqlite_master where type = 'index';")
    uint i
    fornum i=0,*this.col_val  : arrIndexes+=this.col_val[i][0]
  }
  return  uretData
}

/*-----------------------------------------------------------------------------
* @syntax [ sql3.indexesOfTable(str sTable,arrstr arrIndOfTable)]
*
* @return A array of indexes names in the given table.
-----------------------------------------------------------------------------*/
method uint sqlite3.indexesOfTable(str sTable, arrstr arrIndOfTable)
{
  uint uretData = 0
  this.col_val.clear()
  if this.db 
  {
    uretData=this.sql_execute("select name from sqlite_master where type = 'index' and tbl_name='+sTable+';")
    uint i
    fornum i=0,*this.col_val  : arrIndOfTable+=this.col_val[i][0]
  }
  return  uretData
}

/*-----------------------------------------------------------------------------
* @syntax [ sql3.allViews(arrstr arrViews)]
*
* @return A array of indexes names in the database.
-----------------------------------------------------------------------------*/
method uint sqlite3.allViews(arrstr arrViews)
{
  uint uretData = 0
  this.col_val.clear()
  if this.db 
  {
    uretData=this.sql_execute("select name from sqlite_master where type = 'view';")
    uint i
    fornum i=0,*this.col_val  : arrViews+=this.col_val[i][0]
  }
  return  uretData
}

/*-----------------------------------------------------------------------------
* @syntax [ sql3.columnName(int iColumnIndex) ]
*
* @return A array of indexes names in the database.
-----------------------------------------------------------------------------*/
method str sqlite3.columnName(int iColumnIndex) : return this.col_names[iColumnIndex]                                              

method uint sqlite3.backup( str destbase )
{
   uint bcdb
   uint res
   
   ustr us = destbase
   str  s 
   us.toutf8( s )
   if sqlite3_open( s.ptr(), &bcdb ) == $SQLITE_OK
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

