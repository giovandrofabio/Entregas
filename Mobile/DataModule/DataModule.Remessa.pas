unit DataModule.Remessa;

interface

uses
  System.SysUtils,
  System.Classes,
  RESTRequest4D,
  DataSet.Serialize.Config,

  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Param,
  FireDAC.Stan.Error,
  FireDAC.DatS,
  FireDAC.Phys.Intf,
  FireDAC.DApt.Intf,
  Data.DB,
  FireDAC.Comp.DataSet,
  FireDAC.Comp.Client,
  System.JSON;

type
  TDmRemessa = class(TDataModule)
    TabRemessas: TFDMemTable;
    TabRemessa: TFDMemTable;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure ListarMinhasRemessas(id_usuario: integer);
    procedure ListarEntregasDisponiveis(id_usuario: integer);
    procedure ListarRemessaId(id_remessa: integer);
    procedure ListarHistorico(id_usuario: integer);
    procedure InserirRemessa(descricao, origem, destino: string;
                             origem_latitude, origem_longitude, valor: Double; id_usuario: Integer);
    procedure EditarRemessa(id_remessa: Integer; descricao, origem,
                            destino: string; origem_latitude, origem_longitude, valor: Double);
    procedure ExcluirRemessa(id_remessa: Integer);
    procedure ColetarRemessa(id_remessa, id_entregador: Integer);
    procedure CancelarColetarRemessa(id_remessa: Integer);
    procedure FinalizarRemessa(id_remessa: Integer);
  end;

var
  DmRemessa: TDmRemessa;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

const
  BASE_URL = 'http://localhost:3000';
  USER_NAME = '99coders';
  PASSWORD = '112233';

procedure TDmRemessa.DataModuleCreate(Sender: TObject);
begin
   //Configurar o DataSet Serialize...
   TDataSetSerializeConfig.GetInstance.CaseNameDefinition := cndLower;
end;

procedure TDmRemessa.ListarMinhasRemessas(id_usuario: integer);
var
  resp: IResponse;
begin
    resp := TRequest.New.BaseURL(BASE_URL)
            .Resource('remessas')
            .AddParam('id_usuario', id_usuario.ToString)
            .Accept('application/json')
            .BasicAuthentication(USER_NAME,PASSWORD)
            .DataSetAdapter(TabRemessas)
            .Get;

    if (resp.StatusCode = 0) then
       raise Exception.Create('N?o foi poss?vel acessar o servidor')
    else if (resp.StatusCode <> 200) then
       raise Exception.Create(resp.Content);

end;

procedure TDmRemessa.ListarRemessaId(id_remessa: integer);
var
  resp: IResponse;
begin
    resp := TRequest.New.BaseURL(BASE_URL)
            .Resource('remessas')
            .ResourceSuffix(id_remessa.ToString)
            .Accept('application/json')
            .BasicAuthentication(USER_NAME,PASSWORD)
            .DataSetAdapter(TabRemessa)
            .Get;

    if (resp.StatusCode = 0) then
       raise Exception.Create('N?o foi poss?vel acessar o servidor')
    else if (resp.StatusCode <> 200) then
       raise Exception.Create(resp.Content);

end;


procedure TDmRemessa.ListarEntregasDisponiveis(id_usuario: integer);
var
  resp: IResponse;
begin
    resp := TRequest.New.BaseURL(BASE_URL)
            .Resource('remessas/disponivel')
            .AddParam('id_usuario', id_usuario.ToString)
            .Accept('application/json')
            .BasicAuthentication(USER_NAME,PASSWORD)
            .DataSetAdapter(TabRemessas)
            .Get;

    if (resp.StatusCode = 0) then
       raise Exception.Create('N?o foi poss?vel acessar o servidor')
    else if (resp.StatusCode <> 200) then
       raise Exception.Create(resp.Content);

end;

procedure TDmRemessa.InserirRemessa(descricao, origem, destino: string;
                                    origem_latitude, origem_longitude, valor: Double;
                                    id_usuario: Integer);
var
  resp: IResponse;
  Json: TJsonObject;
begin
    try
       Json := TJsonObject.Create;
       Json.AddPair('descricao', descricao);
       Json.AddPair('origem', origem);
       Json.AddPair('destino', destino);
       Json.AddPair('origem_latitude', TJSONNumber.Create(origem_latitude));
       Json.AddPair('origem_longitude', TJSONNumber.Create(origem_longitude));
       Json.AddPair('valor', TJSONNumber.Create(valor));
       Json.AddPair('id_usuario', TJSONNumber.Create(id_usuario));

       resp := TRequest.New.BaseURL(BASE_URL)
               .Resource('remessas')
               .AddBody(Json.ToJSON)
               .Accept('application/json')
               .BasicAuthentication(USER_NAME,PASSWORD)
               .Post;

       if (resp.StatusCode = 0) then
          raise Exception.Create('N?o foi poss?vel acessar o servidor')
       else if (resp.StatusCode <> 201) then
          raise Exception.Create(resp.Content);

    finally
       Json.DisposeOf;
    end;
end;

procedure TDmRemessa.EditarRemessa(id_remessa: Integer;
                                   descricao, origem, destino: string;
                                   origem_latitude, origem_longitude, valor: Double);
var
  resp: IResponse;
  Json: TJsonObject;
begin
    try
       Json := TJsonObject.Create;
       Json.AddPair('descricao', descricao);
       Json.AddPair('origem', origem);
       Json.AddPair('destino', destino);
       Json.AddPair('origem_latitude', TJSONNumber.Create(origem_latitude));
       Json.AddPair('origem_longitude', TJSONNumber.Create(origem_longitude));
       Json.AddPair('valor', TJSONNumber.Create(valor));

       resp := TRequest.New.BaseURL(BASE_URL)
               .Resource('remessas')
               .ResourceSuffix(id_remessa.ToString)
               .AddBody(Json.ToJSON)
               .Accept('application/json')
               .BasicAuthentication(USER_NAME,PASSWORD)
               .Put;

       if (resp.StatusCode = 0) then
          raise Exception.Create('N?o foi poss?vel acessar o servidor')
       else if (resp.StatusCode <> 200) then
          raise Exception.Create(resp.Content);

    finally
       Json.DisposeOf;
    end;
end;

procedure TDmRemessa.ExcluirRemessa(id_remessa: Integer);
var
  resp: IResponse;
begin
   resp := TRequest.New.BaseURL(BASE_URL)
           .Resource('remessas')
           .ResourceSuffix(id_remessa.ToString)
           .Accept('application/json')
           .BasicAuthentication(USER_NAME,PASSWORD)
           .Delete;

   if (resp.StatusCode = 0) then
      raise Exception.Create('N?o foi poss?vel acessar o servidor')
   else if (resp.StatusCode <> 200) then
      raise Exception.Create(resp.Content);
end;

procedure TDmRemessa.ListarHistorico(id_usuario: integer);
var
  resp: IResponse;
begin
    resp := TRequest.New.BaseURL(BASE_URL)
            .Resource('remessas/historico')
            .AddParam('id_usuario', id_usuario.ToString)
            .Accept('application/json')
            .BasicAuthentication(USER_NAME,PASSWORD)
            .DataSetAdapter(TabRemessas)
            .Get;

    if (resp.StatusCode = 0) then
       raise Exception.Create('N?o foi poss?vel acessar o servidor')
    else if (resp.StatusCode <> 200) then
       raise Exception.Create(resp.Content);

end;

procedure TDmRemessa.ColetarRemessa(id_remessa, id_entregador: Integer);
var
  resp: IResponse;
  Json: TJsonObject;
begin
    try
       Json := TJsonObject.Create;
       Json.AddPair('status', 'E');
       Json.AddPair('id_entregador', TJSONNumber.Create(id_entregador));

       resp := TRequest.New.BaseURL(BASE_URL)
               .Resource('remessas/status')
               .ResourceSuffix(id_remessa.ToString)
               .AddBody(Json.ToJSON)
               .Accept('application/json')
               .BasicAuthentication(USER_NAME,PASSWORD)
               .Put;

       if (resp.StatusCode = 0) then
          raise Exception.Create('N?o foi poss?vel acessar o servidor')
       else if (resp.StatusCode <> 200) then
          raise Exception.Create(resp.Content);

    finally
       Json.DisposeOf;
    end;
end;

procedure TDmRemessa.CancelarColetarRemessa(id_remessa: Integer);
var
  resp: IResponse;
  Json: TJsonObject;
begin
    try
       Json := TJsonObject.Create;
       Json.AddPair('status', 'P');

       resp := TRequest.New.BaseURL(BASE_URL)
               .Resource('remessas/status')
               .ResourceSuffix(id_remessa.ToString)
               .AddBody(Json.ToJSON)
               .Accept('application/json')
               .BasicAuthentication(USER_NAME,PASSWORD)
               .Put;

       if (resp.StatusCode = 0) then
          raise Exception.Create('N?o foi poss?vel acessar o servidor')
       else if (resp.StatusCode <> 200) then
          raise Exception.Create(resp.Content);

    finally
       Json.DisposeOf;
    end;
end;

procedure TDmRemessa.FinalizarRemessa(id_remessa: Integer);
var
  resp: IResponse;
  Json: TJsonObject;
begin
    try
       Json := TJsonObject.Create;
       Json.AddPair('status', 'F');

       resp := TRequest.New.BaseURL(BASE_URL)
               .Resource('remessas/status')
               .ResourceSuffix(id_remessa.ToString)
               .AddBody(Json.ToJSON)
               .Accept('application/json')
               .BasicAuthentication(USER_NAME,PASSWORD)
               .Put;

       if (resp.StatusCode = 0) then
          raise Exception.Create('N?o foi poss?vel acessar o servidor')
       else if (resp.StatusCode <> 200) then
          raise Exception.Create(resp.Content);

    finally
       Json.DisposeOf;
    end;
end;

end.
