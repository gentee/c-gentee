/*******************************************************************************
<fieldsql>
<fieldsql.g>
<copyright author="Alexander Krivonogov" year=2006 
file="This file is part of the Gentee ODBC library."></>
<place root=Libraries curgroup="ODBC Library"></>
   <description>
Definition of 'win' type.
   </>
</>
*******************************************************************************/

include {
"odbcfield.g" }

type odbcquery {
//private
   uint hstmt     //Дескриптор курсора
   uint hconn
   uint podbc     //Указатель на odbc   
//public
   uint rowcount //Количество строк результата
   uint fieldcount //Количество полей
   uint open      //Флаг открытого запроса   
   str  sqlstr    //Строка запроса
   arr  fields of odbcfield      
   uint timeout
}
extern {
   method uint odbcquery.first()
   method uint odbcquery.geterror( str state message )   
}

/*-----------------------------------------------------------------------------
* Id: odbcquery_close F3
*
* Summary: Close a result set. Closes a result set. This method is used after
           the SQL query of the #b(SELECT...) type has been executed. While
           calling the #a(odbcquery_run) method, the given method is 
           automatically called.
*
-----------------------------------------------------------------------------*/

method odbcquery.close()
{
   if this.open 
   {
      this.open = 0
      SQLFreeStmt( this.hstmt, $SQL_UNBIND )  
      SQLFreeStmt( this.hstmt, $SQL_CLOSE )
   }
}

method odbcquery.freeodbc()
{
   this.close()
   if this.hstmt 
   { 
      SQLFreeHandle( $SQL_HANDLE_STMT, this.hstmt )
      this.hstmt = 0
   }
   this.hconn = 0
   this.podbc = 0
      
}

method odbcquery.free()
{   
   this.freeodbc()
}

method uint odbcquery.setodbc( odbc podbc )
{
   this.freeodbc()
   this.podbc = &podbc
   return 0
}

/*-----------------------------------------------------------------------------
* Id: odbcquery_settimeout F2
*
* Summary: Set query timeout. Sets the number of seconds to wait for a 
           SQL query execution.
*
* Params: timeout - The number of seconds to wait for a SQL query execution. /
          If it is equal to 0, then there is no timeout.   
*
-----------------------------------------------------------------------------*/

method odbcquery.settimeout( uint timeout )
{
   this.timeout = timeout 
   if this.hstmt
   {     
      SQLSetStmtAttr( this.hstmt, 0,//$SQL_ATTR_QUERY_TIMEOUT, 
               timeout, $SQL_IS_UINTEGER ) 
   }
}

method uint odbcquery.run()
{
   uint codbc
   uint ret
    
   codbc as this.podbc->odbc
   this.close()
   if codbc->uint && codbc.connected 
   {
      if !this.hstmt || codbc.hconn != this.hconn
      {
         if this.hstmt : SQLFreeHandle( $SQL_HANDLE_STMT, this.hstmt )
         this.hconn = codbc.hconn
         if !chsql( SQLAllocHandle( $SQL_HANDLE_STMT, this.hconn, &this.hstmt ))
         {
            return 0
         }
         SQLSetStmtAttr( this.hstmt, $SQL_ATTR_CURSOR_TYPE, 
               $SQL_CURSOR_STATIC, $SQL_IS_INTEGER )
         this.settimeout( this.timeout )              
         //SQLSetStmtOption( this.hstmt, $SQL_CURSOR_TYPE, $SQL_CURSOR_STATIC )
      }   
      //if *this.sqlstr >= $ODBC_POCKET_SIZE : return 0
        
      ret = SQLExecDirect( this.hstmt, this.sqlstr.ptr(), *this.sqlstr/*$SQL_NTS*/ ) & 0xFFFF
      if ret == $SQL_NO_DATA : return 1      
      if ret == $SQL_SUCCESS || ret == $SQL_SUCCESS_WITH_INFO
      {
             
         //uint colnums 
         uint i    
         uint f
         uint ctype        
         SQLNumResultCols( this.hstmt, &this.fieldcount )
         /*                  
         SQLFetchScroll( this.hstmt, $SQL_FETCH_LAST, 0 )                  
         SQLGetStmtAttr( this.hstmt, $SQL_ATTR_ROW_NUMBER, &this.rowcount, 
               $SQL_IS_INTEGER, &ret )
         */           
         //print( "ROWNCOUNT = \(this.rowcount)\n")        
         this.fields.expand( this.fieldcount )
                      
         fornum i = 0, this.fieldcount 
         {
            uint collenname, coltype, coldec, colnull
            f = &this.fields[i]
            f as odbcfield
            collenname = 256                    
            f.name.reserve( collenname )
            SQLDescribeCol( this.hstmt, i + 1, f.name.ptr(), collenname, 
                  &collenname, &f.sqltype, &f.sqlsize, &f.sqldecdig, &f.sqlind )
            f.name.setlen( collenname )            
            switch f.sqltype
            {
               case $SQL_INTEGER, $SQL_SMALLINT, $SQL_TINYINT, $SQL_BIT {
                  f.vtype = int
                  f.sqlsize = sizeof( int )        
                  ctype = $SQL_INTEGER 
               }  
               case $SQL_CHAR, $SQL_VARCHAR, $SQL_LONGVARCHAR, 
                    $SQL_WCHAR, $SQL_WVARCHAR, $SQL_WLONGVARCHAR {                                      
                  f.vtype = str                  
                  ctype = $SQL_CHAR
						//print( "col=\( i ); name=\( f.name ); sqlsize=\(f.sqlsize); sqlind=\(f.sqlind)\n" )
                  if f.sqlsize > $MAXFIELDSIZE 
                  {
                     f.sqlind = f.sqlsize   
                     f.sqlsize = 0
                  }               
               }
               case $SQL_FLOAT, $SQL_REAL, $SQL_DOUBLE {
                  f.vtype = double
                  f.sqlsize = sizeof( double )   
                  ctype = $SQL_DOUBLE 
               }
               case $SQL_BIGINT {
                  f.vtype = long
                  f.sqlsize = sizeof( long )  
                  ctype = $SQL_BIGINT 
               }                  
               case $SQL_NUMERIC, $SQL_DECIMAL {                  
                  f.vtype = numeric
                  f.sqlsize = $NUMERIC_SIZE
                  ctype = $SQL_CHAR 
               }
               case $SQL_BINARY, $SQL_VARBINARY, $SQL_LONGVARBINARY {
                  f.vtype = buf
                  ctype = $SQL_BINARY
                  if f.sqlsize > $MAXFIELDSIZE 
                  {
                     f.sqlind = f.sqlsize
                     f.sqlsize = 0                                            
                  }             
               }
               case $SQL_TYPE_DATE, $SQL_TYPE_TIME, $SQL_TYPE_TIMESTAMP  {
                  f.vtype = datetime
                  f.sqlsize = sizeof( timestamp )
                  ctype = $SQL_TYPE_TIMESTAMP 
               }            
               default {               
                  f.vtype = buf
                  ctype = f.sqltype                                 
               }
            }
            f.val->buf.expand( f.sqlsize + 1 )
            f.hstmt = this.hstmt
            f.index = i              
            if f.sqlsize  
            {            
               SQLBindCol( this.hstmt, i + 1, ctype, f.val.ptr(), 
                  f.sqlsize + 1, &f.sqlind )
            }                              
         }         
         //SQLFetchScroll( this.hstmt, $SQL_FETCH_FIRST, 0 )                                    
         this.open = 1
         this.first()
         return 1
      }
   }
   return 0   
}

/*-----------------------------------------------------------------------------
* Id: odbcquery_run F2
*
* Summary: SQL query execution.
*
* Params: sqlstr - String that contains the SQL query.   
*  
* Return: #lng/retf# 
*
-----------------------------------------------------------------------------*/

method uint odbcquery.run( str sqlstr )
{
   this.sqlstr = sqlstr
   return this.run()
} 

method odbcquery.fieldsnull()
{
   uint i
   fornum i=0, this.fieldcount
   {
      if !this.fields[i].sqlsize
      {
         SQLGetData( this.hstmt, i + 1, this.fields[i].sqltype, this.fields[i].val.ptr(),
               0, &this.fields[i].sqlind )
         this.fields[i].val.setlen( 0 )
      } 
   }  
}

/*-----------------------------------------------------------------------------
* Id: odbcquery_next F3
*
* Summary: Move the cursor to the next record in the result set. 
*
* Return: If the cursor has been moved, it returns nonzero; otherwise, 
          it returns zero. If the current record is the last, it returns zero.  
*
-----------------------------------------------------------------------------*/

method uint odbcquery.next()
{
   uint res = chsql( SQLFetch( this.hstmt ))
   if res : this.fieldsnull()
   return res
}

/*-----------------------------------------------------------------------------
* Id: odbcquery_first F3
*
* Summary: Move the cursor to the first record in the result set. 
*
* Return: If the cursor has been moved, it returns nonzero.  
*
-----------------------------------------------------------------------------*/

method uint odbcquery.first()
{   
   uint res = chsql( SQLFetchScroll( this.hstmt, $SQL_FETCH_FIRST, 0 ))
   if res : this.fieldsnull()   
   return res  
}

/*-----------------------------------------------------------------------------
* Id: odbcquery_last F3
*
* Summary: Move the cursor to the last record in the result set.
*
* Return: If the cursor has been moved, it returns nonzero.  
*
-----------------------------------------------------------------------------*/

method uint odbcquery.last()
{
   uint res = chsql( SQLFetchScroll( this.hstmt, $SQL_FETCH_LAST, 0 ))
   if res : this.fieldsnull()
   return res
}

/*-----------------------------------------------------------------------------
* Id: odbcquery_prior F3
*
* Summary: Move the cursor to the prior record in the result set.
*
* Return: If the cursor has been moved, it returns nonzero.  
*
-----------------------------------------------------------------------------*/

method uint odbcquery.prior()
{
   uint res = chsql( SQLFetchScroll( this.hstmt, $SQL_FETCH_PRIOR, 0 )) 
   if res : this.fieldsnull()
   return res
}

/*-----------------------------------------------------------------------------
* Id: odbcquery_moveby F2
*
* Summary: Move the cursor to a position relative to its current position.
*
* Params: off - Indicates the number of records to move the cursor. If the /
          number is negative, the cursor is moved backward.   
*  
* Return: If the cursor has been moved, it returns nonzero.  
*
-----------------------------------------------------------------------------*/

method uint odbcquery.moveby( int off )
{
   uint res = chsql( SQLFetchScroll( this.hstmt, $SQL_FETCH_RELATIVE, off )) 
   if res : this.fieldsnull()
   return res
}

/*-----------------------------------------------------------------------------
* Id: odbcquery_fieldbyname F2
*
* Summary: Find a field based on a specified field name. 
*
* Params: name - Field name.   
*  
* Return: Returns the field or zero if fields with the same name are 
          not found.  
*
-----------------------------------------------------------------------------*/

method odbcfield odbcquery.fieldbyname( str name )
{
   uint i
   fornum i = 0, *this.fields
   {
      if this.fields[i].name == name : return this.fields[i]
   }
   return 0->odbcfield
}

/*-----------------------------------------------------------------------------
* Id: odbcquery_geterror F2
*
* Summary: Get the last error message. Gets the message if the last 
           error occured while running the SQL query.
*
* Params: state - This string will contain the current state. 
          message - This string will contain an error message. 
*  
* Return: Returns the last error code.  
*
-----------------------------------------------------------------------------*/

method uint odbcquery.geterror( str state, str message )
{
   return this.podbc->odbc.err( $SQL_HANDLE_STMT, this.hstmt, state, message ) 
}

/*-----------------------------------------------------------------------------
* Id: odbcquery_active F3
*
* Summary: Checks whether a result set exists after the SQL query execution. 
           If the SQL query of the #b('"SELECT ..."') type has been executed
           successfully, this method returns nonzero. 
*  
* Return: Returns nonzero if a result set exists.  
*
-----------------------------------------------------------------------------*/

method uint odbcquery.active()
{
   return this.open 
}

/*-----------------------------------------------------------------------------
* Id: odbcquery_getrecordcount F3
*
* Summary: Get the total number of records in a result set. Gets the total
           number of records in a result set when the SQL query of the 
           #b('"SELECT ..."') type has been executed. 
*  
* Return: Returns the the total number of records; if the total number 
          of records is not determined, it returns -1.  
*
-----------------------------------------------------------------------------*/

method uint odbcquery.getrecordcount()
{
   uint curpos, rowcount = -1
   uint res, ret
   
   if res = chsql( SQLGetStmtAttr( this.hstmt, $SQL_ATTR_ROW_NUMBER, &curpos, 
      $SQL_IS_INTEGER, &ret ))   
   {
      if res = chsql( SQLFetchScroll( this.hstmt, $SQL_FETCH_LAST, 0 ) )
      {                  
         res = chsql( SQLGetStmtAttr( this.hstmt, $SQL_ATTR_ROW_NUMBER, &rowcount, 
            $SQL_IS_INTEGER, &ret ))
         SQLFetchScroll( this.hstmt, $SQL_FETCH_ABSOLUTE, curpos )
      }
   }
   if res : return rowcount
   return -1
}
