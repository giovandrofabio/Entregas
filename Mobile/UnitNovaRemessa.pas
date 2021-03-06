unit UnitNovaRemessa;

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
  FMX.Objects,
  FMX.Controls.Presentation,
  FMX.StdCtrls,
  FMX.Edit,

  uLoading,
  uFunctions,
  uSession;

type
  TCallbackRemessa = procedure of object;

  TFrmNovaRemessa = class(TForm)
    rectToolbar1: TRectangle;
    lblTitulo: TLabel;
    imgVoltar: TImage;
    ImgSalvar: TImage;
    EdtDescricao: TEdit;
    edtValor: TEdit;
    edtDestino: TEdit;
    edtOrigem: TEdit;
    imgDelete: TImage;
    procedure imgVoltarClick(Sender: TObject);
    procedure ImgSalvarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure imgDeleteClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FId_Remessa: Integer;
    FExecuteOnClose: TCallbackRemessa;
    procedure ThreadLoadTerminate(Sender: TObject);
    procedure ThreadRemessaTerminate(Sender: TObject);
    { Private declarations }
  public
    property ExecuteOnClose: TCallbackRemessa read FExecuteOnClose write FExecuteOnClose;
    property Id_Remessa: Integer read FId_Remessa write FId_Remessa;
  end;

var
  FrmNovaRemessa: TFrmNovaRemessa;

implementation

{$R *.fmx}

uses DataModule.Remessa;

procedure TFrmNovaRemessa.ThreadLoadTerminate(Sender: TObject);
begin
   TLoading.Hide;

   if ErroThread(Sender) then
      Exit;
end;

procedure TFrmNovaRemessa.ThreadRemessaTerminate(Sender: TObject);
begin
   TLoading.Hide;

   if ErroThread(Sender) then
      Exit;

   Close;
end;

procedure TFrmNovaRemessa.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   if Assigned(ExecuteOnClose) then
      ExecuteOnClose;

   Action         := TCloseAction.caFree;
   FrmNovaRemessa := nil;
end;

procedure TFrmNovaRemessa.FormShow(Sender: TObject);
var
   t: TThread;
begin
   imgDelete.Visible := Id_Remessa > 0;

   if Id_Remessa > 0 then
   begin
      lblTitulo.Text := 'Editar Remessa';
      TLoading.Show(FrmNovaRemessa, '');

      t := TThread.CreateAnonymousThread(procedure
      begin
         DmRemessa.ListarRemessaId(Id_Remessa);

         with DmRemessa.TabRemessa do
         begin
            TThread.Synchronize(TThread.CurrentThread, procedure
            begin
               EdtDescricao.Text := FieldByName('descricao').AsString;
               edtOrigem.Text    := FieldByName('origem').AsString;
               edtDestino.Text   := FieldByName('destino').AsString;
               edtValor.Text     := FormatFloat('#,##0.00',FieldByName('valor').AsFloat);
            end);
         end;
      end);

      t.OnTerminate := ThreadLoadTerminate;
      t.Start;
   end;
end;

procedure TFrmNovaRemessa.imgDeleteClick(Sender: TObject);
var
   t : TThread;
begin
   TLoading.Show(FrmNovaRemessa, '');

   t := TThread.CreateAnonymousThread(procedure
   begin
      sleep(1500);

      DmRemessa.ExcluirRemessa(Id_Remessa);
   end);

   t.OnTerminate := ThreadRemessaTerminate;
   t.Start;
end;

procedure TFrmNovaRemessa.ImgSalvarClick(Sender: TObject);
var
   t : TThread;
begin
   TLoading.Show(FrmNovaRemessa, '');

   t := TThread.CreateAnonymousThread(procedure
   begin
      sleep(1500);

      if Id_Remessa = 0 then
         DmRemessa.InserirRemessa(EdtDescricao.Text,
                                  edtOrigem.Text,
                                  edtDestino.Text,
                                  0,
                                  0,
                                  uFunctions.StringToDouble(edtValor.Text),
                                  TSession.ID_USUARIO)
      else
          DmRemessa.EditarRemessa(Id_Remessa,
                                  EdtDescricao.Text,
                                  edtOrigem.Text,
                                  edtDestino.Text,
                                  0,
                                  0,
                                  uFunctions.StringToDouble(edtValor.Text));

   end);

   t.OnTerminate := ThreadRemessaTerminate;
   t.Start;
end;

procedure TFrmNovaRemessa.imgVoltarClick(Sender: TObject);
begin
   ExecuteOnClose := nil;
   Close;
end;

end.
