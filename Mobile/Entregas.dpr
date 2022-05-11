program Entregas;

uses
  System.StartUpCopy,
  FMX.Forms,
  UnitPrincipal in 'UnitPrincipal.pas' {FrmPrincipal},
  uFunctions in 'Units\uFunctions.pas',
  uLoading in 'Units\uLoading.pas',
  UnitNovaRemessa in 'UnitNovaRemessa.pas' {FrmNovaRemessa},
  UnitStatusRemessa in 'UnitStatusRemessa.pas' {FrmStatusRemessa};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFrmPrincipal, FrmPrincipal);
  Application.CreateForm(TFrmNovaRemessa, FrmNovaRemessa);
  Application.CreateForm(TFrmStatusRemessa, FrmStatusRemessa);
  Application.Run;
end.
