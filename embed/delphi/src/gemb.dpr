program gemb;

uses
  Forms,
  fmain in 'fmain.pas' {Form1},
  gentee in 'gentee.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
