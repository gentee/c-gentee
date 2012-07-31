include {
   "viseditor.g"
   //"application.g"
   //"ctrl.g"
}

/*global {
   app application
}*/
func main<main>
{   
   uint i
   //myform mm   
   myform1->vform.v_win()
         
   myform1.enable =  1
   myform1.visible = 1
         
   myform1.compinit()
   print( ".\n" )
   ShowWindow( myform1.hwnd, 1 )
   print( ".\n" )
   UpdateWindow( myform1.hwnd )
   
   app.run( )//myform1 )
   //getch()   
/*      
   gui_init()
   myform1->vform.win()   
   myform1.compinit()  
   print( "x\(&myform1)\n" )   
   gui_showapp( myform1.hwnd, $SW_NORMAL, 0 )        
   gui_deinit()
   getch()*/
}
//onclick.set( this, "btnonclick" )