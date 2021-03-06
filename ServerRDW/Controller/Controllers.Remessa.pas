unit Controllers.Remessa;

interface

uses
  System.JSON,
  System.Classes,
  ServerUtils,
  System.SysUtils,
  uRESTDWBaseIDQX,
  uDWConsts,
  uDWJSONObject,
  Controllers.Comum,
  DAO.Remessa,
  DataModule.Global;

procedure RegistrarRotas(RestDWServerQuickX: TRESTDWServerQXID);
procedure ListarMinhasRemessas(Sender: TObject; RequestHeader: TStringList;
                               const Params: TDWParams; var ContentType: string;
                               var Result: string; const RequestType: TRequestType;
                               var StatusCode: Integer; var ErrorMessage: string;
                               var OutCustomHeader: TStringList);
procedure ListarEntregasDisponiveis(Sender: TObject; RequestHeader: TStringList;
                               const Params: TDWParams; var ContentType: string;
                               var Result: string; const RequestType: TRequestType;
                               var StatusCode: Integer; var ErrorMessage: string;
                               var OutCustomHeader: TStringList);
procedure ListarHistorico(Sender: TObject; RequestHeader: TStringList;
                               const Params: TDWParams; var ContentType: string;
                               var Result: string; const RequestType: TRequestType;
                               var StatusCode: Integer; var ErrorMessage: string;
                               var OutCustomHeader: TStringList);
procedure CadastrarRemessa(Sender: TObject; RequestHeader: TStringList;
                               const Params: TDWParams; var ContentType: string;
                               var Result: string; const RequestType: TRequestType;
                               var StatusCode: Integer; var ErrorMessage: string;
                               var OutCustomHeader: TStringList);
procedure EditarRemessa(Sender: TObject; RequestHeader: TStringList;
                               const Params: TDWParams; var ContentType: string;
                               var Result: string; const RequestType: TRequestType;
                               var StatusCode: Integer; var ErrorMessage: string;
                               var OutCustomHeader: TStringList);
procedure ExcluirRemessa(Sender: TObject; RequestHeader: TStringList;
                               const Params: TDWParams; var ContentType: string;
                               var Result: string; const RequestType: TRequestType;
                               var StatusCode: Integer; var ErrorMessage: string;
                               var OutCustomHeader: TStringList);
procedure AlterarStatusRemessa(Sender: TObject; RequestHeader: TStringList;
                               const Params: TDWParams; var ContentType: string;
                               var Result: string; const RequestType: TRequestType;
                               var StatusCode: Integer; var ErrorMessage: string;
                               var OutCustomHeader: TStringList);
procedure RotasRemessas(Sender: TObject; RequestHeader: TStringList;
                               const Params: TDWParams; var ContentType: string;
                               var Result: string; const RequestType: TRequestType;
                               var StatusCode: Integer; var ErrorMessage: string;
                               var OutCustomHeader: TStringList);

implementation

procedure RotasRemessas(Sender: TObject; RequestHeader: TStringList;
                               const Params: TDWParams; var ContentType: string;
                               var Result: string; const RequestType: TRequestType;
                               var StatusCode: Integer; var ErrorMessage: string;
                               var OutCustomHeader: TStringList);
begin
   case RequestType of
      rtGet   : ListarMinhasRemessas(Sender, RequestHeader, Params, ContentType, Result,
                                     RequestType, StatusCode, ErrorMessage, OutCustomHeader);

      rtPut   : EditarRemessa(Sender, RequestHeader, Params, ContentType, Result,
                              RequestType, StatusCode, ErrorMessage, OutCustomHeader);

      rtPost  : CadastrarRemessa(Sender, RequestHeader, Params, ContentType, Result,
                                 RequestType, StatusCode, ErrorMessage, OutCustomHeader);

      rtDelete: ExcluirRemessa(Sender, RequestHeader, Params, ContentType, Result,
                               RequestType, StatusCode, ErrorMessage, OutCustomHeader);
   end;
end;

procedure RegistrarRotas(RestDWServerQuickX: TRESTDWServerQXID);
begin
   with RestDWServerQuickX do
   begin
      AddUrl('remessas/disponivel',[crGet] , ListarEntregasDisponiveis, True);
      AddUrl('remessas/historico', [crGet], ListarHistorico, True);
      AddUrl('remessas/status',[crPut], AlterarStatusRemessa, True);
      AddUrl('remessas',[crGet,crPost, crPut, crDelete], RotasRemessas, True);
   end;
end;

procedure ListarMinhasRemessas(Sender: TObject; RequestHeader: TStringList;
                               const Params: TDWParams; var ContentType: string;
                               var Result: string; const RequestType: TRequestType;
                               var StatusCode: Integer; var ErrorMessage: string;
                               var OutCustomHeader: TStringList);
var
   rem : TRemessa;
   JsonArray: TJSONArray;
begin
   try
      rem := TRemessa.Create(DmGlobal.conn);

      try
         try
            rem.ID_REMESSA := Params.ItemsString['0'].asInteger;
         except
            rem.ID_REMESSA := 0;
         end;

         try
            rem.ID_USUARIO := Params.ItemsString['id_usuario'].AsInteger;
         except
            rem.ID_USUARIO := 0;
         end;

         try
            rem.STATUS := Params.ItemsString['status'].AsString;
         except
            rem.STATUS := '';
         end;

         JsonArray := rem.ListarMinhasRemessas;
         Result    := JsonArray.ToJSON;
         JsonArray.DisposeOf;

         StatusCode := 200;

      except on ex: Exception do
         begin
            Result     := ex.Message;
            StatusCode := 500;
         end;
      end;

   finally
      rem.DisposeOf;
   end;
end;

procedure ListarEntregasDisponiveis(Sender: TObject; RequestHeader: TStringList;
                               const Params: TDWParams; var ContentType: string;
                               var Result: string; const RequestType: TRequestType;
                               var StatusCode: Integer; var ErrorMessage: string;
                               var OutCustomHeader: TStringList);
var
   rem : TRemessa;
   JsonArray: TJSONArray;
begin
   try
      rem := TRemessa.Create(DmGlobal.conn);

      try
         try
            rem.ID_USUARIO := Params.ItemsString['id_usuario'].AsInteger;
         except
            rem.ID_USUARIO := 0;
         end;

         JsonArray := rem.ListarMinhasRemessasDisponiveis;
         Result    := JsonArray.ToJSON;
         JsonArray.DisposeOf;

         StatusCode := 200;

      except on ex: Exception do
         begin
            Result     := ex.Message;
            StatusCode := 500;
         end;
      end;

   finally
      rem.DisposeOf;
   end;
end;

procedure ListarHistorico(Sender: TObject; RequestHeader: TStringList;
                               const Params: TDWParams; var ContentType: string;
                               var Result: string; const RequestType: TRequestType;
                               var StatusCode: Integer; var ErrorMessage: string;
                               var OutCustomHeader: TStringList);
var
   rem : TRemessa;
   JsonArray: TJSONArray;
begin
   try
      rem := TRemessa.Create(DmGlobal.conn);

      try
         try
            rem.ID_USUARIO := Params.ItemsString['id_usuario'].AsInteger;
         except
            rem.ID_USUARIO := 0;
         end;

         JsonArray := rem.ListarHistorico;
         Result    := JsonArray.ToJSON;
         JsonArray.DisposeOf;

         StatusCode := 200;

      except on ex: Exception do
         begin
            Result     := ex.Message;
            StatusCode := 500;
         end;
      end;

   finally
      rem.DisposeOf;
   end;
end;

procedure CadastrarRemessa(Sender: TObject; RequestHeader: TStringList;
                               const Params: TDWParams; var ContentType: string;
                               var Result: string; const RequestType: TRequestType;
                               var StatusCode: Integer; var ErrorMessage: string;
                               var OutCustomHeader: TStringList);
var
   rem : TRemessa;
   body: System.JSON.TJSONValue;
   json: TJSONObject;
begin
   try
      rem := TRemessa.Create(DmGlobal.conn);

      try
         body                 := ParseBody(Params.RawBody.AsString);
         rem.DESCRICAO        := body.GetValue<string>('descricao', '');
         rem.ORIGEM           := body.GetValue<string>('origem', '');
         rem.DESTINO          := body.GetValue<string>('destino', '');
         rem.VALOR            := body.GetValue<double>('valor', 0);
         rem.ORIGEM_LATITUDE  := body.GetValue<double>('origem_latitude', 0);
         rem.ORIGEM_LONGITUDE := body.GetValue<double>('origem_longitude', 0);
         rem.ID_USUARIO       := body.GetValue<integer>('id_usuario', 0);
         body.DisposeOf;

         rem.Inserir;

         //Montar Json de retorno...
         json := TJSONObject.Create;
         json.AddPair('id_remessa', TJSONNumber.Create(rem.ID_REMESSA));

         Result     := json.ToJSON;
         StatusCode := 201;

         json.DisposeOf;

      except on ex: Exception do
         begin
            Result     := ex.Message;
            StatusCode := 500;
         end;
      end;

   finally
      rem.DisposeOf;
   end;
end;

procedure EditarRemessa(Sender: TObject; RequestHeader: TStringList;
                               const Params: TDWParams; var ContentType: string;
                               var Result: string; const RequestType: TRequestType;
                               var StatusCode: Integer; var ErrorMessage: string;
                               var OutCustomHeader: TStringList);
var
   rem : TRemessa;
   body: System.JSON.TJSONValue;
   json: TJSONObject;
begin
   try
      rem := TRemessa.Create(DmGlobal.conn);

      try
         try
            rem.ID_REMESSA := Params.ItemsString['0'].AsInteger;
         except
            rem.ID_REMESSA := 0;
         end;

         body                 := ParseBody(Params.RawBody.AsString);
         rem.DESCRICAO        := body.GetValue<string>('descricao', '');
         rem.ORIGEM           := body.GetValue<string>('origem', '');
         rem.DESTINO          := body.GetValue<string>('destino', '');
         rem.VALOR            := body.GetValue<double>('valor', 0);
         rem.ORIGEM_LATITUDE  := body.GetValue<double>('origem_latitude', 0);
         rem.ORIGEM_LONGITUDE := body.GetValue<double>('origem_longitude', 0);
         body.DisposeOf;

         rem.Editar;

         //Montar Json de retorno...
         json := TJSONObject.Create;
         json.AddPair('id_remessa', TJSONNumber.Create(rem.ID_REMESSA));

         Result     := json.ToJSON;
         StatusCode := 200;

         json.DisposeOf;

      except on ex: Exception do
         begin
            Result     := ex.Message;
            StatusCode := 500;
         end;
      end;

   finally
      rem.DisposeOf;
   end;
end;

procedure ExcluirRemessa(Sender: TObject; RequestHeader: TStringList;
                               const Params: TDWParams; var ContentType: string;
                               var Result: string; const RequestType: TRequestType;
                               var StatusCode: Integer; var ErrorMessage: string;
                               var OutCustomHeader: TStringList);
var
   rem : TRemessa;
   json: TJSONObject;
begin
   try
      rem := TRemessa.Create(DmGlobal.conn);

      try
         try
            rem.ID_REMESSA := Params.ItemsString['0'].AsInteger;
         except
            rem.ID_REMESSA := 0;
         end;

         rem.Excluir;

         //Montar Json de retorno...
         json := TJSONObject.Create;
         json.AddPair('id_remessa', TJSONNumber.Create(rem.ID_REMESSA));

         Result     := json.ToJSON;
         StatusCode := 200;

         json.DisposeOf;

      except on ex: Exception do
         begin
            Result     := ex.Message;
            StatusCode := 500;
         end;
      end;

   finally
      rem.DisposeOf;
   end;
end;

procedure AlterarStatusRemessa(Sender: TObject; RequestHeader: TStringList;
                               const Params: TDWParams; var ContentType: string;
                               var Result: string; const RequestType: TRequestType;
                               var StatusCode: Integer; var ErrorMessage: string;
                               var OutCustomHeader: TStringList);
var
   rem : TRemessa;
   body: System.JSON.TJSONValue;
   json: TJSONObject;
begin
   try
      rem := TRemessa.Create(DmGlobal.conn);

      try
         try
            rem.ID_REMESSA := Params.ItemsString['0'].AsInteger;
         except
            rem.ID_REMESSA := 0;
         end;

         body                 := ParseBody(Params.RawBody.AsString);
         rem.ID_ENTREGADOR    := body.GetValue<Integer>('id_entregador', 0);
         rem.STATUS           := body.GetValue<string>('status', '');
         body.DisposeOf;

         if rem.STATUS = 'P' then
            rem.CancelarColetarRemessa
         else
         if rem.STATUS = 'E' then
            rem.ColetarRemessa
         else
         if rem.STATUS = 'F' then
            rem.FinalizarEntrega
         else
            raise Exception.Create('Status in v?lido');

         //Montar Json de retorno...
         json := TJSONObject.Create;
         json.AddPair('id_remessa', TJSONNumber.Create(rem.ID_REMESSA));

         Result     := json.ToJSON;
         StatusCode := 200;

         json.DisposeOf;

      except on ex: Exception do
         begin
            Result     := ex.Message;
            StatusCode := 500;
         end;
      end;

   finally
      rem.DisposeOf;
   end;
end;

end.
