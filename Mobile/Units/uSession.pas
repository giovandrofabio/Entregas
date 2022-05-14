unit uSession;

interface

type
  TSession = class
    private
      class var FEMAIL: string;
      class var FNOME: string;
      class var FID_USUARIO: Integer;
    public
      class property ID_USUARIO: Integer read FID_USUARIO write FID_USUARIO;
      class property EMAIL: string read FEMAIL write FEMAIL;
      class property NOME: string read FNOME write FNOME;
  end;

implementation

end.
