unit DataModule.Global;

interface

uses
  System.SysUtils,
  System.Classes,
  System.IniFiles,

  Data.DB,

  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.UI.Intf,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Def,
  FireDAC.Stan.Pool,
  FireDAC.Stan.Async,
  FireDAC.Phys,
  FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef,
  FireDAC.Stan.ExprFuncs,
  FireDAC.FMXUI.Wait,
  FireDAC.Comp.Client;

type
  TDmGlobal = class(TDataModule)
    conn: TFDConnection;
  private
    { Private declarations }
  public
   procedure ConectarBanco;
    { Public declarations }
  end;

var
  DmGlobal: TDmGlobal;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

procedure TDmGlobal.ConectarBanco;
var
  ini: TIniFile;
  arquivo_ini: string;
begin
   try
      //Busca arquivo ini na mesma pasta do Exe
      arquivo_ini := System.SysUtils.GetCurrentDir + '\servidor.ini';

      if not FileExists(arquivo_ini) then
         raise Exception.Create('Arquivo INI n?o encontrado: ' + arquivo_ini);

      // Instanciar arquivo INI...
      ini := TIniFile.Create(arquivo_ini);
      conn.DriverName := ini.ReadString('Banco de dados', 'DriverID', '');

      //Buscar dados do arquivo fisico...
      with conn.Params do
      begin   
         Clear;
         Add('DriverID=' + ini.ReadString('Banco de Dados', 'DriverID', ''));
         Add('Database=' + ini.ReadString('Banco de Dados', 'Database', ''));
         Add('User_Name=' + ini.ReadString('Banco de Dados', 'User_name', ''));
         Add('Password=' + ini.ReadString('Banco de Dados', 'Password', ''));
         Add('Protocol=TCPIP');

         if ini.ReadString('Banco de Dados', 'Server', '') <> '' then
            Add('Server=' + ini.ReadString('Banco de Dados', 'Server', ''));
                                    
         if ini.ReadString('Banco de Dados', 'Port', '') <> '' then
            Add('Port=' + ini.ReadString('Banco de Dados', 'Port', ''));             

//         if ini.ReadString('Banco de Dados', 'VendedorLib', '') <> '' then
//            FDPhysDriverLink.VendedorLib := ini.ReadString('Banco de Dados', 'VendedorLib', '');             
      end;

      try
         conn.Connected := True;  
      except on ex: Exception do
         raise Exception.Create('Erro ao acessar o banco: ' + ex.Message);
      end;
       
   finally
      if Assigned(ini) then
         ini.DisposeOf;
   end;
end;

end.
