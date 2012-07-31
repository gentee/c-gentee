#output = %EXEPATH%\gmanager.exe
#norun = 1
#exe = 1 d g
#optimizer = 1
#icon = ..\..\res\icons\gentee_c.ico
#wait = 3

//#!gentee.exe -s -p vis "%1"
define
{
   DESIGNING = 0
   COMP = 0   
}

include {   
   $"gmanager.gf"
}

global {
   vForm0 Form0
}

func run<main>
{
   App.Load()
   Form0.Owner = App
   App.Run()
}
