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
  uFunctions;

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
  private
    imgAbaSelecionada: TImage;
    procedure SelecionarAba(img: TImage);
    procedure AddRemessa(id_remessa: Integer; status, descricao,
      endereco: string; valor: double);
    procedure ListarMinhasRemessas;
    procedure ThreadRemessasTerminate(Sender: TObject);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmPrincipal: TFrmPrincipal;

implementation

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
   if ErroThread(Sender) then
      Exit;
end;

procedure TFrmPrincipal.ListarMinhasRemessas;
var
   t: TThread;
begin
   lvRemessa.Items.Clear;
   lvRemessa.BeginUpdate;

   t := TThread.CreateAnonymousThread(procedure
   begin
      //Acessar a API em busca das remessas...
      sleep();

      AddRemessa(0, 'P', 'Entrega de Flores', 'Av. Paulista, 500 - CJ 60', 20);
      AddRemessa(0, 'P', 'Entrega de Documentos', 'Av. Ipiranga, 1000', 19.90);
      AddRemessa(0, 'P', 'Entrega de Contabilidade', 'Av. Paulista, 500 - CJ 60', 25);
      AddRemessa(0, 'P', 'Entrega de Pe�as', 'Av. Paulista, 500 - CJ 60', 30);
   end);

   t.OnTerminate := ThreadRemessasTerminate;
   t.Start;
end;

procedure TFrmPrincipal.SelecionarAba(img: TImage);
begin
   imgAbaSelecionada := img;

   TAnimator.AnimateFloat(rectAbaSelecao, 'Position.X', img.Position.X, 0.2,
                          TAnimationType.In, TInterpolationType.Circular);

   TabControl.GotoVisibleTab(img.Tag);
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

procedure TFrmPrincipal.imgAba1Click(Sender: TObject);
begin
   SelecionarAba(TImage(Sender));
end;

end.