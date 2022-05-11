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
  uLoading;

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
    Image6: TImage;
    Rectangle2: TRectangle;
    Label3: TLabel;
    Image7: TImage;
    Image8: TImage;
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
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmPrincipal: TFrmPrincipal;

implementation

uses
  UnitNovaRemessa, UnitStatusRemessa;

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
      //Acessar a API em busca das remessas...
      sleep(1500);

      TThread.Synchronize(TThread.CurrentThread, procedure
      begin
        AddRemessa(0, 'P', 'Entrega de Flores', 'Av. Paulista, 500 - CJ 60', 20);
        AddRemessa(0, 'E', 'Entrega de Documentos', 'Av. Ipiranga, 1000', 19.90);
        AddRemessa(0, 'E', 'Entrega de Contabilidade', 'Av. Paulista, 500 - CJ 60', 25);
        AddRemessa(0, 'P', 'Entrega de Pe�as', 'Av. Paulista, 500 - CJ 60', 30);
      end);
   end);

   t.OnTerminate := ThreadRemessasTerminate;
   t.Start;
end;

procedure TFrmPrincipal.lvEntregaItemClick(const Sender: TObject;
  const AItem: TListViewItem);
begin
   TDialogService.MessageDialog('Confirma a solicita��o de coleta?',
                                TMsgDlgType.mtConfirmation,
                                [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo],
                                TMsgDlgBtn.mbNo,
                                0,
                                procedure(const AResult: TModalResult)
                                begin
                                   if AResult = mrYes then
                                      showmessage('Reserva a Entrega');
                                end);
end;

procedure TFrmPrincipal.lvHistoricoItemClick(const Sender: TObject;
  const AItem: TListViewItem);
begin
   if not Assigned(FrmStatusRemessa) then
      Application.CreateForm(TFrmStatusRemessa, FrmStatusRemessa);

   FrmStatusRemessa.Show;
end;

procedure TFrmPrincipal.lvRemessaItemClick(const Sender: TObject;
  const AItem: TListViewItem);
begin
   if not Assigned(FrmNovaRemessa) then
      Application.CreateForm(TFrmNovaRemessa, FrmNovaRemessa);

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
      sleep(2500);

      //Buscar entregas no servidor

      TThread.Synchronize(TThread.CurrentThread, procedure
      begin
         AddEntrega(0,'Entrega de Flores','Av. Paulista, 8000','Av. Ipiranga, 1500',40);
         AddEntrega(0,'Entrega de documentos','Rua Libano, 100','Av. do Estado, 600',60);
         AddEntrega(0,'Entrega de processos','Rua 13 de maio, 60','Av. Tiradentes, 456',14.90);
         AddEntrega(0,'Entrega de pacotes','Av. Rubem Berta, 250','Rua dos Passaros, 300',30);
      end);
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
      //Acessar a API em busca das remessas...
      sleep(2500);

      //Buscar entregas no servidor

      TThread.Synchronize(TThread.CurrentThread, procedure
      begin
         AddHistorico(0,1,'P','10/05/2022 08:15','Entrega da Contabilidade',
                      'Rua Indiana, 482','Av. Interlagos, 6541', 55);
         AddHistorico(0,1,'F','10/05/2022 08:15','Entrega de Projetos',
                      'Av. 23 de maio, 5411','Rua Sabi�, 258', 21);
      end);
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

   FrmNovaRemessa.Show;
end;

end.
