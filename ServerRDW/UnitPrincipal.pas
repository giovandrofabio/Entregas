unit UnitPrincipal;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,

  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.Controls.Presentation,
  FMX.ScrollBox,
  FMX.Memo,

  uRESTDWBaseIDQX,
  uDWConsts,
  uDWJSONObject,
  uDWJSONTools,
  ServerUtils,
  DataSet.Serialize.Config;

type
  TFrmPrincipal = class(TForm)
    memo: TMemo;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
    RestDWServerQuickX: TRESTDWServerQXID;
  end;

var
  FrmPrincipal: TFrmPrincipal;

implementation

uses
  DataModule.Global,
  Controllers.Remessa;

{$R *.fmx}

procedure TFrmPrincipal.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   RestDWServerQuickX.Active := False;
   RestDWServerQuickX.Free;
end;

procedure TFrmPrincipal.FormShow(Sender: TObject);
begin
   RestDWServerQuickX := TRESTDWServerQXID.Create(nil);

   //Autentica??o...
   RestDWServerQuickX.AuthenticationOptions.AuthorizationOption := TRDWAuthOption.rdwAOBasic;
   TRDWAuthOptionBasic(RestDWServerQuickX.AuthenticationOptions.OptionParams).Username := '99coders';
   TRDWAuthOptionBasic(RestDWServerQuickX.AuthenticationOptions.OptionParams).Password := '112233';

   //CORS...
   RestDWServerQuickX.CORS := True;
   RestDWServerQuickX.CORS_CustomHeaders.Clear;
   RestDWServerQuickX.CORS_CustomHeaders.Add('Access-Control-Allow-Origin=*');
   RestDWServerQuickX.CORS_CustomHeaders.Add('Access-Control-Allow-Methods=GET, POST, PATCH, PUT, DELETE, OPTIONS');
   RestDWServerQuickX.CORS_CustomHeaders.Add('Access-Control-Allow-Headers=Content-Type, Origin, Accept, Authorization, X-CUSTOM-HEADER');

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
   Controllers.Remessa.RegistrarRotas(RestDWServerQuickX);

   //Subir a aplica??o...
   RestDWServerQuickX.Bind(3000, False);
end;

end.
