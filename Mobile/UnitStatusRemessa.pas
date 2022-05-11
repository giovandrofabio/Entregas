unit UnitStatusRemessa;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts;

type
  TFrmStatusRemessa = class(TForm)
    rectToolbar1: TRectangle;
    Label1: TLabel;
    imgVoltar: TImage;
    lblDescricao: TLabel;
    Layout1: TLayout;
    Image1: TImage;
    lblOrigem: TLabel;
    lblDestino: TLabel;
    lblValor: TLabel;
    rectCancelar: TRectangle;
    Label6: TLabel;
    Rectangle1: TRectangle;
    Label7: TLabel;
    procedure imgVoltarClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmStatusRemessa: TFrmStatusRemessa;

implementation

{$R *.fmx}

procedure TFrmStatusRemessa.imgVoltarClick(Sender: TObject);
begin
   Close;
end;

end.
