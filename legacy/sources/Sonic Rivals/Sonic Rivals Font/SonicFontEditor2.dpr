program SonicFontEditor2;

uses
  Forms,
  SFEditor2 in 'SFEditor2.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
