type locustr <inherit=ustr>
{
   //ustr    Value
   //ustr    pText
   //onevent onChange   
}

property ustr locustr.Value <result>
{
   result = this   
}

property locustr.Value( ustr val )
{
   this = val
}


method ustr locustr.Text <result>( vComp curcomp )
{
   uint comp as curcomp
   if !&comp: comp as App
   if !comp.pAutoLang 
   {
      result = this.Value
      return 
   }
ifdef $DESIGNING {
   ustr ret
   uint form as comp.GetForm()->vComp
      
   if &form && ( ( form.p_designing && *DesApp.Lng.getlang( this.Value, result ) ) ||
      ( !form.p_designing && *App.Lng.getlang( this.Value, result ) ) )
   {
      
   //ret = app.getlangid( this )
   //print( "Textss \n" )
   /*if &ret
   {
      return ret
   }*/
   }   
   else
   {
      result = this.Value
   }   
}
else {   
   ustr ret 
   if *App.Lng.getlang( this.Value, result )
   {
   //ret = app.getlangid( this )
   //print( "Textss \n" )
   /*if &ret
   {
      return ret
   }*/
   }
   else
   {
      result = this.Value
   }
}
   //return this.Value    
}
/*
property ustr locustr.Value
{
   return this.pValue
}

property locustr.Value( ustr newval )
{
str t
   if this.pValue != newval
   {
      print( "newwal \(newval.str()))\n" )
      this.pValue = newval//"newval"
      //t = .pValue
      //print( "aa"@t@"xx \(*t)" )
      //print( "pval \(.pValue.str())\n" )
      //print( "pval \(newval.use) \(newval.size) \(newval.data)\n" )
      //print( "pval \(&this) \(this.pValue.use) \(this.pValue.size) \(this.pValue.data) \(this.onChange.obj)\n" )
      //this.onChange.run()
   }
}*/

