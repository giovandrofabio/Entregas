unit UnitNovaRemessa;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Edit;

type
  TFrmNovaRemessa = class(TForm)
    rectToolbar1: TRectangle;
    Label1: TLabel;
    imgVoltar: TImage;
    ImgSalvar: TImage;
    EdtDescricao: TEdit;
    edtValor: TEdit;
    edtDestino: TEdit;
    edtOrigem: TEdit;
    imgDelete: TImage;
    procedure imgVoltarClick(Sender: TObject);
    procedure ImgSalvarClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmNovaRemessa: TFrmNovaRemessa;

implementation

{$R *.fmx}

procedure TFrmNovaRemessa.ImgSalvarClick(Sender: TObject);
begin
   Close;
end;

procedure TFrmNovaRemessa.imgVoltarClick(Sender: TObject);
begin
   Close;
end;

end.
