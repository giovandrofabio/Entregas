unit DAO.Remessa;

interface

uses
    FireDAC.Comp.Client,
    FireDAC.DApt,
    Data.DB,
    System.JSON,
    System.SysUtils,
    DataSet.Serialize,
    StrUtils;

type
  TRemessa = class
  private
    FConn: TFDConnection;
    FID_USUARIO: Integer;
    FDESCRICAO: string;
    FORIGEM: string;
    FDESTINO: string;
    FVALOR: double;
    FSTATUS: string;
    FORIGEM_LATITUDE: double;
    FORIGEM_LONGITUDE: double;
    FID_ENTREGADOR: Integer;
    FID_REMESSA: Integer;
  public
    constructor Create(conn: TFDConnection);

    property ID_USUARIO: Integer read FID_USUARIO write FID_USUARIO;
    property ID_REMESSA: Integer read FID_REMESSA write FID_REMESSA;
    property DESCRICAO: string read FDESCRICAO write FDESCRICAO;
    property ORIGEM: string read FORIGEM write FORIGEM;
    property DESTINO: string read FDESTINO write FDESTINO;
    property VALOR: double read FVALOR write FVALOR;
    property STATUS: string read FSTATUS write FSTATUS;
    property ORIGEM_LATITUDE: double read FORIGEM_LATITUDE write FORIGEM_LATITUDE;
    property ORIGEM_LONGITUDE: double read FORIGEM_LONGITUDE write FORIGEM_LONGITUDE;
    property ID_ENTREGADOR: Integer read FID_ENTREGADOR write FID_ENTREGADOR;

    function ListarMinhasRemessas : TJSONArray;
    function ListarMinhasRemessasDisponiveis: TJSONArray;
    function ListarHistorico: TJSONArray;
    procedure Inserir;
    procedure Editar;
    procedure Excluir;
    procedure ColetarRemessa;
    procedure CancelarColetarRemessa;
    procedure FinalizarEntrega;
  end;

implementation

{ TRemessa }

constructor TRemessa.Create(conn: TFDConnection);
begin
   FConn := conn;
end;

function TRemessa.ListarMinhasRemessas: TJSONArray;
var
   qry: TFDQuery;
begin
   try
      qry := TFDQuery.Create(nil);
      qry.Connection := FConn;

      with qry do
      begin
         Active := False;
         SQL.Clear;
         SQL.Add('SELECT * FROM REMESSA');
         SQL.Add('WHERE ID_REMESSA >0');

         if ID_USUARIO > 0 then
         begin
            SQL.Add('AND ID_USUARIO = :ID_USUARIO');
            ParamByName('ID_USUARIO').Value := ID_USUARIO;
         end;

         if ID_REMESSA > 0 then
         begin
            SQL.Add('AND ID_REMESSA = :ID_REMESSA');
            ParamByName('ID_REMESSA').Value := ID_REMESSA;
         end;

         if STATUS <> '' then
         begin
            SQL.Add('AND STATUS = :STATUS');
            ParamByName('STATUS').Value := STATUS;
         end;

         SQL.Add('ORDER BY ID_REMESSA DESC');
         Active := True;
      end;

      Result  := qry.ToJSONArray;

   finally
      qry.DisposeOf;
   end;
end;

function TRemessa.ListarMinhasRemessasDisponiveis: TJSONArray;
var
   qry: TFDQuery;
begin
   try
      qry := TFDQuery.Create(nil);
      qry.Connection := FConn;

      with qry do
      begin
         Active := False;
         SQL.Clear;
         SQL.Add('SELECT * FROM REMESSA');
         SQL.Add('WHERE ID_USUARIO <> :ID_USUARIO');
         SQL.Add('AND STATUS = :STATUS');
         SQL.Add('ORDER BY ID_REMESSA DESC');

         ParamByName('ID_USUARIO').Value := ID_USUARIO;
         ParamByName('STATUS').Value     := 'P';

         Active := True;
      end;

      Result  := qry.ToJSONArray;

   finally
      qry.DisposeOf;
   end;
end;

function TRemessa.ListarHistorico: TJSONArray;
var
   qry: TFDQuery;
begin
   try
      qry := TFDQuery.Create(nil);
      qry.Connection := FConn;

      with qry do
      begin
         Active := False;
         SQL.Clear;
         SQL.Add('SELECT * FROM REMESSA');
         SQL.Add('WHERE (ID_USUARIO = :ID_USUARIO OR ID_ENTREGADOR = :ID_ENTREGADOR)');
         SQL.Add('AND STATUS IN (''E'', ''F'')');
         SQL.Add('ORDER BY ID_REMESSA DESC');

         ParamByName('ID_USUARIO').Value    := ID_USUARIO;
         ParamByName('ID_ENTREGADOR').Value := ID_USUARIO;

         Active := True;
      end;

      Result  := qry.ToJSONArray;

   finally
      qry.DisposeOf;
   end;
end;

procedure TRemessa.Inserir;
var
   qry: TFDQuery;
begin
   //Validate('Inserir');

   try
      qry := TFDQuery.Create(nil);
      qry.Connection := FConn;
      try
         with qry do
         begin
            Active := False;
            SQL.Clear;
            SQL.Add('INSERT INTO REMESSA(DESCRICAO, ORIGEM, DESTINO, VALOR, STATUS, ORIGEM_LATITUDE,');
            SQL.Add('ORIGEM_LONGITUDE, ID_USUARIO, DT_CADASTRO)');
            SQL.Add('VALUES (:DESCRICAO, :ORIGEM, :DESTINO, :VALOR, :STATUS, :ORIGEM_LATITUDE,');
            SQL.Add(':ORIGEM_LONGITUDE, :ID_USUARIO, DATETIME());');
            SQL.Add('SELECT last_insert_rowid() AS ID_REMESSA ');  //SQLLite
            //SQL.Add('RETURNING ID_REMESSA '); //Firebird

            ParamByName('DESCRICAO').Value        := DESCRICAO;
            ParamByName('ORIGEM').Value           := ORIGEM;
            ParamByName('DESTINO').Value          := DESTINO;
            ParamByName('VALOR').Value            := VALOR;
            ParamByName('STATUS').Value           := 'P';
            ParamByName('ORIGEM_LATITUDE').Value  := ORIGEM_LATITUDE;
            ParamByName('ORIGEM_LONGITUDE').Value := ORIGEM_LONGITUDE;
            ParamByName('ID_USUARIO').Value       := ID_USUARIO;

            Active := True;
            id_REMESSA := FieldByName('ID_REMESSA').AsInteger;
         end;

      except on ex: Exception do
         raise Exception.Create(ex.Message);
      end;

   finally
      qry.DisposeOf;
   end;
end;

procedure TRemessa.Editar;
var
   qry: TFDQuery;
begin
   //Validate('Editar');

   try
      qry := TFDQuery.Create(nil);
      qry.Connection := FConn;
      with qry do
      begin
         Active := False;
         SQL.Clear;
         SQL.Add('UPDATE REMESSA SET DESCRICAO=:DESCRICAO, ORIGEM=:ORIGEM, DESTINO=:DESTINO, VALOR=:VALOR, ');
         SQL.Add('ORIGEM_LATITUDE=:ORIGEM_LATITUDE,ORIGEM_LONGITUDE=:ORIGEM_LONGITUDE');
         SQL.Add('WHERE ID_REMESSA=:ID_REMESSA');

         ParamByName('DESCRICAO').Value        := DESCRICAO;
         ParamByName('ORIGEM').Value           := ORIGEM;
         ParamByName('DESTINO').Value          := DESTINO;
         ParamByName('VALOR').Value            := VALOR;
         ParamByName('ORIGEM_LATITUDE').Value  := ORIGEM_LATITUDE;
         ParamByName('ORIGEM_LONGITUDE').Value := ORIGEM_LONGITUDE;
         ParamByName('ID_REMESSA').Value       := ID_REMESSA;
         ExecSQL;
      end;
   finally
      qry.DisposeOf;
   end;
end;

procedure TRemessa.Excluir;
var
   qry: TFDQuery;
begin
   //Validate('Excluir');

   try
      qry := TFDQuery.Create(nil);
      qry.Connection := FConn;
      with qry do
      begin
         //Valida se algum entregador j? pegou a remessa...
         Active := False;
         SQL.Clear;
         SQL.Add('SELECT STATUS FROM REMESSA WHERE ID_REMESSA = :ID_REMESSA');
         ParamByName('ID_REMESSA').Value    := ID_REMESSA;
         Active := True;

         if FieldByName('STATUS').AsString <> 'P' then
            raise Exception.Create('A remessa n?o pode ser exclu?da (entregador j? iniciou a entrega)');

         Active := False;
         SQL.Clear;
         SQL.Add('DELETE FROM REMESSA WHERE ID_REMESSA=:ID_REMESSA');
         ParamByName('ID_REMESSA').Value := ID_REMESSA;
         ExecSQL;
      end;

   finally
      qry.DisposeOf;
   end;
end;

procedure TRemessa.ColetarRemessa;
var
   qry: TFDQuery;
begin
   //Validate('ColetarRemessa');

   try
      qry := TFDQuery.Create(nil);
      qry.Connection := FConn;
      with qry do
      begin
         Active := False;
         SQL.Clear;
         SQL.Add('UPDATE REMESSA SET STATUS = ''E'', ID_ENTREGADOR=:ID_ENTREGADOR ');
         SQL.Add('WHERE ID_REMESSA=:ID_REMESSA');

         ParamByName('ID_ENTREGADOR').Value := ID_ENTREGADOR;
         ParamByName('ID_REMESSA').Value    := ID_REMESSA;
         ExecSQL;
      end;

   finally
      qry.DisposeOf;
   end;
end;

procedure TRemessa.CancelarColetarRemessa;
var
   qry: TFDQuery;
begin
   //Validate('CancelarColetarRemessa');

   try
      qry := TFDQuery.Create(nil);
      qry.Connection := FConn;

      with qry do
      begin
         Active := False;
         SQL.Clear;
         SQL.Add('UPDATE REMESSA SET STATUS = ''P'', ID_ENTREGADOR=NULL ');
         SQL.Add('WHERE ID_REMESSA=:ID_REMESSA');

         ParamByName('ID_REMESSA').Value    := ID_REMESSA;
         ExecSQL;
      end;

   finally
      qry.DisposeOf;
   end;
end;

procedure TRemessa.FinalizarEntrega;
var
   qry: TFDQuery;
begin
   //Validate('FinalizarEntrega');

   try
      qry := TFDQuery.Create(nil);
      qry.Connection := FConn;

      with qry do
      begin
         Active := False;
         SQL.Clear;
         SQL.Add('UPDATE REMESSA SET STATUS = ''F'' ');
         SQL.Add('WHERE ID_REMESSA=:ID_REMESSA');

         ParamByName('ID_REMESSA').Value    := ID_REMESSA;
         ExecSQL;
      end;

   finally
      qry.DisposeOf;
   end;
end;

end.
