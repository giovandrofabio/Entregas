unit UnitPrincipal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo;

type
  TFrmPrincipal = class(TForm)
    memo: TMemo;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmPrincipal: TFrmPrincipal;

implementation

uses
  DataModule.Global,
  Horse,
  Horse.BasicAuthentication,
  Horse.Jhonson,
  Horse.CORS,
  DataSet.Serialize.Config,
  Controllers.Remessa;

{$R *.fmx}

procedure TFrmPrincipal.FormShow(Sender: TObject);
begin
   THorse.Use(Jhonson());
   THorse.Use(CORS);

   THorse.Use(HorseBasicAuthentication(
   function(const AUsername, APassword: string): Boolean
   begin
      Result := AUsername.Equals('99coders') and APassword.Equals('112233');
   end));

   //Configura o DataSet Serialize...
   TDataSetSerializeConfig.GetInstance.CaseNameDefinition := cndLower;

   //conectar com o banco ...
   try
      DmGlobal.ConectarBanco;
      memo.Lines.Add('Conex?o com banco de dados: OK');
   except on ex:exception do
      memo.Lines.Add('Erro: ' + ex.Message);
   end;

   //Registrar as rotas...
   Controllers.Remessa.RegistrarRotas;

   //Subir a aplica??o...
   THorse.Listen(3000, procedure (Hose: THorse)
   begin
      memo.Lines.Add('Servidor executando na porta 3000');
   end);
end;

end.
