unit fmain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, gentee, ExtCtrls, ComCtrls, StdCtrls, ToolWin, ImgList;

type
  TForm1 = class(TForm)
    ToolBar1: TToolBar;
    Memo1: TMemo;
    Memo2: TMemo;
    StatusBar1: TStatusBar;
    Splitter1: TSplitter;
    tlbNew: TToolButton;
    tlbOpen: TToolButton;
    tlbSave: TToolButton;
    ToolButton4: TToolButton;
    tlbCompile: TToolButton;
    tlbRun: TToolButton;
    ImageList1: TImageList;
    ToolBar2: TToolBar;
    ToolButton1: TToolButton;
    procedure FormCreate(Sender: TObject);
    procedure tlbNewClick(Sender: TObject);
    procedure tlbOpenClick(Sender: TObject);
    procedure tlbSaveClick(Sender: TObject);
    procedure tlbCompileClick(Sender: TObject);
    procedure tlbRunClick(Sender: TObject);
    procedure ToolButton1Click(Sender: TObject);
  private
    FFileName: string;
    FExeDir: string;
    FLibDir: string;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

//uses gemsgs;

{$R *.dfm}

function __msg(msg: PGeMsgInfo): cardinal; stdcall;
var
  st: string;
begin
  st := 'MSG: ' + string(msg^.pattern);
  if (msg^.flag and MSG_STR <> 0)or(msg^.flag and MSG_LEXNAME <> 0) then
    st := Format(st, [string(msg^.namepar)]);
  st := st + ' @ line: ' + IntToStr(msg^.line) + ' pos: ' + IntToStr(msg^.pos);

  Form1.Memo2.Lines.Add(st);

  Result := 0;
end;

procedure __print(str: PAnsiChar; num: cardinal); stdcall;
begin
  Form1.Memo2.Lines.Add(str);
end;

function __getch(str: PAnsiChar; num: cardinal): cardinal; stdcall;
begin
  Result := 0;
end;

// Функция, вызываемая из скрипта
// Получает строку при вызове, загоняет в ту же область памяти другую строку
// и посылает обратно

function funct0(str: pchar): integer; stdcall;
begin
  showmessage('Получено из скрипта: ' + str);
  // Возвращено в скрипт
  StrCopy(str, 'Строка из функции');
  Result := 1;
end;



function __export(Name: PAnsiChar): Pointer; stdcall;
begin
  Result := nil;
  if Name = 'funct0' then
    Result := @funct0;
end;








procedure TForm1.FormCreate(Sender: TObject);
begin
  FExeDir := ExtractFilePath(Application.ExeName);
  FLibDir := IncludeTrailingBackslash(FExeDir) + 'lib';
  
  geSetHandlerFuncs(__msg, __print, nil, __export);
end;

procedure TForm1.tlbNewClick(Sender: TObject);
begin
  Memo1.Clear;
  FFileName := '';
end;

procedure TForm1.tlbOpenClick(Sender: TObject);
begin
  with TOpenDialog.Create(nil) do
    begin
      Filter := 'Gentee source (*.g)|*.g';
      if Execute then
        begin
          if FileExists(FileName) then
            begin
              FFileName := FileName;
              Memo1.Lines.LoadFromFile(FileName);
            end
        end;
      Free
    end;
end;

procedure TForm1.tlbSaveClick(Sender: TObject);
var flg: boolean;
begin
  flg := (FFileName <> '');
  if not flg then
    with TSaveDialog.Create(nil) do
      begin
        FileName := 'untitled.g';
        if Execute then
          begin
            flg := TRUE;
            if FileExists(FileName) then
              flg := MessageDlg('File ' + FileName +' already exists. Replace it?', mtWarning, [mbYes, mbNo], 0) = mrYes;
            if flg then
              FFileName := FileName;
          end;
        Free;
      end;
  if flg then
    Memo1.Lines.SaveToFile(FFileName);
end;

procedure TForm1.tlbCompileClick(Sender: TObject);
var
  gename: string;
begin
  if FFileName = '' then
    tlbSaveClick(nil);
  if FFileName = '' then Exit;
  gename := ChangeFileExt(FFileName, '.ge');
  geCompileSource(Memo1.Lines, FALSE, gename, FLibDir);
end;

procedure TForm1.tlbRunClick(Sender: TObject);
begin
  geCompileSource(Memo1.Lines, TRUE, '', FLibDir);
end;

procedure TForm1.ToolButton1Click(Sender: TObject);
var
 instr: array[0..255] of ansichar;
 outstr: array[0..255] of ansichar;
 pres: integer;
begin
  Memo1.Lines.LoadFromFile('sample1.g');
  if geCompileSource(Memo1.Lines, TRUE, '', FLibDir) <> 0 then
    begin
      instr := 'some ANSI str с кириллицей'#0;
      geCallFunc('sample1Funct', @pres, [@instr, @outstr]);
      Memo2.Lines.Add('OUTSTR ' + outstr);
    end;
end;

end.
