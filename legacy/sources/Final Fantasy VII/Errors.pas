unit Errors;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TErrorForm = class(TForm)
    Memo: TMemo;
  private
    { Private declarations }
  public
    Procedure AddString(S: String; ShowForm: Boolean = True);
  end;

var
  ErrorForm: TErrorForm;

implementation

{$R *.dfm}

Procedure TErrorForm.AddString(S: String; ShowForm: Boolean = True);
begin
  Memo.Lines.Add(S);
  If ShowForm Then Show;
end;

end.
