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
  FMX.Objects,
  FMX.TabControl,
  FMX.ListView.Types,
  FMX.ListView.Appearances,
  FMX.ListView.Adapters.Base,
  FMX.ListView,
  FMX.Controls.Presentation,
  FMX.StdCtrls,
  FMX.Ani,
  FMX.DialogService,
  uFunctions,
  uLoading,
  uSession;

type
  TFrmPrincipal = class(TForm)
    TabControl: TTabControl;
    TabItem1: TTabItem;
    TabItem2: TTabItem;
    TabItem3: TTabItem;
    recAbas: TRectangle;
    imgAba1: TImage;
    imgAba2: TImage;
    imgAba3: TImage;
    rectAbaSelecao: TRectangle;
    rectToolbar1: TRectangle;
    Image4: TImage;
    ImgAdd: TImage;
    Label1: TLabel;
    lvRemessa: TListView;
    Rectangle1: TRectangle;
    Label2: TLabel;
    Image5: TImage;
    imgRefreshEntrega: TImage;
    Rectangle2: TRectangle;
    Label3: TLabel;
    Image7: TImage;
    imgRefreshHistorico: TImage;
    imgBolaAmarela: TImage;
    imgBolaCinza: TImage;
    imgFundoValor: TImage;
    imgFundoValor2: TImage;
    imgLocais: TImage;
    imgLocais2: TImage;
    imgStatusAndamento: TImage;
    imgStatusFinalizado: TImage;
    lvEntrega: TListView;
    lvHistorico: TListView;
    procedure imgAba1Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ImgAddClick(Sender: TObject);
    procedure lvRemessaItemClick(const Sender: TObject;
      const AItem: TListViewItem);
    procedure lvEntregaItemClick(const Sender: TObject;
      const AItem: TListViewItem);
    procedure lvHistoricoItemClick(const Sender: TObject;
      const AItem: TListViewItem);
    procedure imgRefreshEntregaClick(Sender: TObject);
    procedure imgRefreshHistoricoClick(Sender: TObject);
  private
    imgAbaSelecionada: TImage;
    procedure SelecionarAba(img: TImage);
    procedure AddRemessa(id_remessa: Integer; status, descricao,
      endereco: string; valor: double);
    procedure ListarMinhasRemessas;
    procedure ThreadRemessasTerminate(Sender: TObject);
    procedure AddEntrega(id_entrega: integer; descricao, endereco_origem,
      endereco_destino: string; valor: double);
    procedure AddHistorico(id_remessa, id_usuario: Integer; status, dt_remessa,
      descricao, endereco_origem, endereco_destino: string; valor: double);
    procedure ListarEntregasDisponiveis;
    procedure ThreadEntregasTerminate(Sender: TObject);
    procedure ListarHistorico;
    procedure ThreadHistoricoTerminate(Sender: TObject);
    procedure ConfirmarColeta(id_remessa: Integer);
    procedure ThreadColetaTerminate(Sender: TObject);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmPrincipal: TFrmPrincipal;

implementation

uses
  UnitNovaRemessa, UnitStatusRemessa, DataModule.Remessa;

{$R *.fmx}

procedure TFrmPrincipal.AddRemessa(id_remessa: Integer;
                                   status, descricao, endereco: string;
                                   valor: double);
var
   item: TListViewItem;
begin
   item := lvRemessa.Items.Add;

   with item do
   begin
      Tag    := id_remessa;
      Height := 70;

      TListItemText(Objects.FindDrawable('txtDescricao')).Text := descricao;
      TListItemText(Objects.FindDrawable('txtValor')).Text     := FormatFloat('R$ #,##0.00',valor);
      TListItemText(Objects.FindDrawable('txtEndereco')).Text  := endereco;

      TListItemImage(Objects.FindDrawable('imgValor')).Bitmap  := imgFundoValor.Bitmap;

      if status = 'P' then
         TListItemImage(Objects.FindDrawable('imgIcone')).Bitmap  := imgBolaCinza.Bitmap
      else
         TListItemImage(Objects.FindDrawable('imgIcone')).Bitmap  := imgBolaAmarela.Bitmap;
   end;
end;

procedure TFrmPrincipal.ThreadRemessasTerminate(Sender: TObject);
begin
   TLoading.Hide;
   lvRemessa.EndUpdate;

   if ErroThread(Sender) then
      Exit;
end;

procedure TFrmPrincipal.AddEntrega(id_entrega: integer;
                                   descricao, endereco_origem, endereco_destino: string;
                                   valor: double);
var
   item: TListViewItem;
begin
   item := lvEntrega.Items.Add;

   with item do
   begin
      Tag    := id_entrega;
      Height := 130;

      TListItemText(Objects.FindDrawable('txtDescricao')).Text := descricao;
      TListItemText(Objects.FindDrawable('txtValor')).Text     := FormatFloat('R$ #,##0.00',valor);
      TListItemText(Objects.FindDrawable('txtOrigem')).Text  := endereco_origem;
      TListItemText(Objects.FindDrawable('txtDestino')).Text  := endereco_destino;

      TListItemImage(Objects.FindDrawable('imgValor')).Bitmap  := imgFundoValor.Bitmap;
      TListItemImage(Objects.FindDrawable('imgLocal')).Bitmap  := imgLocais.Bitmap;
   end;
end;

procedure TFrmPrincipal.AddHistorico(id_remessa, id_usuario: Integer;
                                     status, dt_remessa, descricao, endereco_origem, endereco_destino: string;
                                     valor: double);
var
   item: TListViewItem;
begin
   item := lvHistorico.Items.Add;

   with item do
   begin
      Tag    := id_remessa;
      Height := 150;

      TListItemText(Objects.FindDrawable('txtDescricao')).Text := descricao;
      TListItemText(Objects.FindDrawable('txtData')).Text      := Copy(dt_remessa, 1, 16);
      TListItemText(Objects.FindDrawable('txtValor')).Text     := FormatFloat('R$ #,##0.00',valor);
      TListItemText(Objects.FindDrawable('txtOrigem')).Text    := endereco_origem;
      TListItemText(Objects.FindDrawable('txtDestino')).Text   := endereco_destino;

      TListItemImage(Objects.FindDrawable('imgValor')).Bitmap  := imgFundoValor2.Bitmap;
      TListItemImage(Objects.FindDrawable('imgLocal')).Bitmap  := imgLocais2.Bitmap;

      if status = 'F' then
         TListItemImage(Objects.FindDrawable('imgStatus')).Bitmap  := imgStatusFinalizado.Bitmap
      else
         TListItemImage(Objects.FindDrawable('imgStatus')).Bitmap  := imgStatusAndamento.Bitmap;
   end;
end;

procedure TFrmPrincipal.ListarMinhasRemessas;
var
   t: TThread;
begin
   TLoading.Show(FrmPrincipal, 'Consultando..');
   lvRemessa.Items.Clear;
   lvRemessa.BeginUpdate;

   t := TThread.CreateAnonymousThread(procedure
   begin
      DmRemessa.ListarMinhasRemessas(TSession.ID_USUARIO);

      with DmRemessa.TabRemessas do
      begin
         while not Eof do
         begin
            TThread.Synchronize(TThread.CurrentThread, procedure
            begin
               AddRemessa(FieldByName('id_remessa').AsInteger,
                          FieldByName('status').AsString,
                          FieldByName('descricao').AsString,
                          FieldByName('destino').AsString,
                          FieldByName('valor').AsFloat);
            end);
            Next;
         end;
      end;
   end);

   t.OnTerminate := ThreadRemessasTerminate;
   t.Start;
end;

procedure TFrmPrincipal.ThreadColetaTerminate(Sender: TObject);
begin
   TLoading.Hide;

   if ErroThread(Sender) then
      Exit;

   ListarEntregasDisponiveis;
end;


procedure TFrmPrincipal.ConfirmarColeta(id_remessa: Integer);
var
   t : TThread;
begin
   TLoading.Show(FrmPrincipal, '');

   t := TThread.CreateAnonymousThread(procedure
   begin
      sleep(1000);

      DmRemessa.ColetarRemessa(Id_Remessa, TSession.ID_USUARIO);
   end);

   t.OnTerminate := ThreadColetaTerminate;
   t.Start;
end;

procedure TFrmPrincipal.lvEntregaItemClick(const Sender: TObject;
  const AItem: TListViewItem);
begin
   TDialogService.MessageDialog('Confirma a solicita??o de coleta?',
                                TMsgDlgType.mtConfirmation,
                                [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo],
                                TMsgDlgBtn.mbNo,
                                0,
                                procedure(const AResult: TModalResult)
                                begin
                                   if AResult = mrYes then
                                      ConfirmarColeta(AItem.Tag);
                                end);
end;

procedure TFrmPrincipal.lvHistoricoItemClick(const Sender: TObject;
  const AItem: TListViewItem);
begin
   if not Assigned(FrmStatusRemessa) then
      Application.CreateForm(TFrmStatusRemessa, FrmStatusRemessa);

   FrmStatusRemessa.ExecuteOnClose := ListarHistorico;
   FrmStatusRemessa.Id_Remessa     := AItem.Tag;
   FrmStatusRemessa.Show;
end;

procedure TFrmPrincipal.lvRemessaItemClick(const Sender: TObject;
  const AItem: TListViewItem);
begin
   if not Assigned(FrmNovaRemessa) then
      Application.CreateForm(TFrmNovaRemessa, FrmNovaRemessa);

   FrmNovaRemessa.Id_Remessa     := AItem.Tag;
   FrmNovaRemessa.ExecuteOnClose := ListarMinhasRemessas;
   FrmNovaRemessa.Show;
end;

procedure TFrmPrincipal.ThreadEntregasTerminate(Sender: TObject);
begin
   TLoading.Hide;
   lvEntrega.EndUpdate;

   if ErroThread(Sender) then
      Exit;
end;

procedure TFrmPrincipal.ListarEntregasDisponiveis;
var
   t: TThread;
begin
   TLoading.Show(FrmPrincipal, 'Consultando..');
   lvEntrega.Items.Clear;
   lvEntrega.BeginUpdate;

   t := TThread.CreateAnonymousThread(procedure
   var
      i : Integer;
   begin
      //Acessar a API em busca das remessas...
      DmRemessa.ListarEntregasDisponiveis(TSession.ID_USUARIO);

      //Buscar entregas no servidor
      with DmRemessa.TabRemessas do
      begin
         while not Eof do
         begin
            TThread.Synchronize(TThread.CurrentThread, procedure
            begin
               AddEntrega(FieldByName('id_remessa').AsInteger,
                          FieldByName('descricao').AsString,
                          FieldByName('origem').AsString,
                          FieldByName('destino').AsString,
                          FieldByName('valor').AsFloat);
            end);
            Next;
         end;
      end;
   end);

   t.OnTerminate := ThreadEntregasTerminate;
   t.Start;
end;

procedure TFrmPrincipal.ThreadHistoricoTerminate(Sender: TObject);
begin
   TLoading.Hide;
   lvHistorico.EndUpdate;

   if ErroThread(Sender) then
      Exit;
end;


procedure TFrmPrincipal.ListarHistorico();
var
   t: TThread;
begin
   TLoading.Show(FrmPrincipal, 'Consultando..');
   lvHistorico.Items.Clear;
   lvHistorico.BeginUpdate;

   t := TThread.CreateAnonymousThread(procedure
   var
      i : Integer;
   begin
      DmRemessa.ListarHistorico(TSession.ID_USUARIO);

      //Buscar entregas no servidor
      with DmRemessa.TabRemessas do
      begin
         while not Eof do
         begin
            TThread.Synchronize(TThread.CurrentThread, procedure
            begin
               AddHistorico(FieldByName('id_remessa').AsInteger,
                            FieldByName('id_usuario').AsInteger,
                            FieldByName('status').AsString,
                            UTCtoDateBR(FieldByName('dt_cadastro').AsString),
                            FieldByName('descricao').AsString,
                            FieldByName('origem').AsString,
                            FieldByName('destino').AsString,
                            FieldByName('valor').AsFloat);
            end);
            Next;
         end;
      end;
   end);

   t.OnTerminate := ThreadHistoricoTerminate;
   t.Start;
end;


procedure TFrmPrincipal.SelecionarAba(img: TImage);
begin
   imgAbaSelecionada := img;

   TAnimator.AnimateFloat(rectAbaSelecao, 'Position.X', img.Position.X, 0.2,
                          TAnimationType.In, TInterpolationType.Circular);

   TabControl.GotoVisibleTab(img.Tag);

   if img.Tag = 1 then
      ListarEntregasDisponiveis
   else if img.Tag = 2 then
      ListarHistorico
end;

procedure TFrmPrincipal.FormCreate(Sender: TObject);
begin
  SelecionarAba(imgAba1);
end;

procedure TFrmPrincipal.FormResize(Sender: TObject);
begin
   if Assigned(imgAbaSelecionada) then
   begin
      rectAbaSelecao.Position.X := imgAbaSelecionada.Position.X;
      rectAbaSelecao.Width      := imgAbaSelecionada.Width;
   end;
end;

procedure TFrmPrincipal.FormShow(Sender: TObject);
begin
  // Dados do Login...
  TSession.ID_USUARIO := 3;
  TSession.NOME       := 'Giovandro';
  TSession.EMAIL      := 'giovandrofabiosantos@hotmail.com';
  //----------------------
  ListarMinhasRemessas;
end;

procedure TFrmPrincipal.imgAba1Click(Sender: TObject);
begin
   SelecionarAba(TImage(Sender));
end;

procedure TFrmPrincipal.ImgAddClick(Sender: TObject);
begin
   if not Assigned(FrmNovaRemessa) then
      Application.CreateForm(TFrmNovaRemessa, FrmNovaRemessa);

   FrmNovaRemessa.Id_Remessa     := 0;
   FrmNovaRemessa.ExecuteOnClose := ListarMinhasRemessas;
   FrmNovaRemessa.Show;
end;

procedure TFrmPrincipal.imgRefreshEntregaClick(Sender: TObject);
begin
   ListarEntregasDisponiveis;
end;

procedure TFrmPrincipal.imgRefreshHistoricoClick(Sender: TObject);
begin
   ListarHistorico;
end;

end.
