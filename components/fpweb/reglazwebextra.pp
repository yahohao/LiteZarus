unit reglazwebextra;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpwebdata,
  sqldbwebdata,
  LazIDEIntf, SrcEditorIntf, IDEMsgIntf, ProjectIntf,
  {$IFDEF EnableNewExtTools}
  IDEExternToolIntf,
  {$ENDIF}
  fpextjs,
  extjsjson, extjsxml,
  fpjsonrpc, Controls, Dialogs, Forms,
  jstree,jsparser,
  fpextdirect,
  webjsonrpc;

Type

  { TFileDescWebProviderDataModule }

  TFileDescWebProviderDataModule = class(TFileDescPascalUnitWithResource)
  public
    constructor Create; override;
    function GetInterfaceUsesSection: string; override;
    function GetLocalizedName: string; override;
    function GetLocalizedDescription: string; override;
    function GetImplementationSource(const Filename, SourceName, ResourceName: string): string;override;
  end;

  { TFileDescWebJSONRPCModule }

  TFileDescWebJSONRPCModule = class(TFileDescPascalUnitWithResource)
  public
    constructor Create; override;
    function GetInterfaceUsesSection: string; override;
    function GetLocalizedName: string; override;
    function GetLocalizedDescription: string; override;
    function GetImplementationSource(const Filename, SourceName, ResourceName: string): string;override;
  end;


  { TFileDescExtDirectModule }

  TFileDescExtDirectModule = class(TFileDescPascalUnitWithResource)
  public
    constructor Create; override;
    function GetInterfaceUsesSection: string; override;
    function GetLocalizedName: string; override;
    function GetLocalizedDescription: string; override;
    function GetImplementationSource(const Filename, SourceName, ResourceName: string): string;override;
  end;

  { TSQLFileDescriptor }

  { TJSFileDescriptor }

  TJSFileDescriptor = class(TProjectFileDescriptor)
  public
    constructor Create; override;
    function GetLocalizedName: string; override;
    function GetLocalizedDescription: string; override;
    function GetResourceSource(const ResourceName: string): string; override;
    function CreateSource(const Filename, SourceName,
                          ResourceName: string): string; override;
    procedure UpdateDefaultPascalFileExtension(const DefPasExt: string); override;
  end;

  TJSSyntaxChecker = Class(TComponent)
  private
    FSFN: String;
  Public
    Procedure ShowMessage(Const Msg : String);
    Procedure ShowMessage(Const Fmt : String; Args : Array of const);
    Procedure ShowException(Const Msg : String; E : Exception);
    function CheckJavaScript (S : TStream): TModalResult;
    function CheckSource(Sender: TObject; var Handled: boolean): TModalResult;
    Property SourceFileName : String Read FSFN;
 end;

  { THTTPApplicationDescriptor }
  THTTPApplicationDescriptor = class(TProjectDescriptor)
  private
    FThreaded,
    fReg : Boolean;
    FDir,
    FLoc : String;
    FPort : Integer;
    function GetOPtions: TModalResult;
  public
    constructor Create; override;
    function GetLocalizedName: string; override;
    function GetLocalizedDescription: string; override;
    function InitProject(AProject: TLazProject): TModalResult; override;
    function CreateStartFiles(AProject: TLazProject): TModalResult; override;
  end;

Procedure Register;

resourcestring
  rsWebDataProvi = 'Web DataProvider Module';
  rsWEBDataProvi2 = 'WEB DataProvider Module%sA datamodule to handle data '
    +'requests for WEB (HTTP) applications using WebDataProvider components.';
  rsWebJSONRPCMo = 'Web JSON-RPC Module';
  rsWEBJSONRPCMo2 = 'WEB JSON-RPC Module%sA datamodule to dispatch JSON-RPC '
    +'requests in WEB (HTTP) applications using TJSONRPCHandler components.';
  rsWebExtDirect = 'Web Ext.Direct Module';
  rsWEBExtDirect2 = 'WEB Ext.Direct Module%sA datamodule to dispatch Ext.'
    +'Direct requests in WEB (HTTP) applications using TJSONRPCHandler '
    +'components.';
  rsHTTPAppli = 'HTTP server Application';
  rsHTTPAppli2 = 'HTTP server Application. Complete HTTP Server '
    +'program in Free Pascal using webmodules. The program source '
    +'is automatically maintained by Lazarus.';

Var
   FileDescriptorWebProviderDataModule: TFileDescWebProviderDataModule;
   ProjectDescriptorHTTPApplication : THTTPApplicationDescriptor;
     FileDescriptorJSONRPCModule : TFileDescWebJSONRPCModule;
   FileDescriptorExtDirectModule : TFileDescExtDirectModule;
   AChecker : TJSSyntaxChecker;

implementation

uses propedits,FormEditingIntf, frmrpcmoduleoptions,frmnewhttpapp,
     sqlstringspropertyeditordlg, registersqldb, weblazideintf;

Procedure Register;

begin
   RegisterComponents('fpWeb',[TWebdataInputAdaptor,TFPWebDataProvider, TSQLDBWebDataProvider,
                               TExtJSJSonWebdataInputAdaptor,TExtJSJSONDataFormatter,
                               TExtJSXMLWebdataInputAdaptor,TExtJSXMLDataFormatter,
                               TJSONRPCHandler,TJSONRPCDispatcher,TSessionJSONRPCDispatcher,
                               TJSONRPCContentProducer,
                               TExtDirectDispatcher,TExtDirectContentProducer]);
   FileDescriptorWebProviderDataModule:=TFileDescWebProviderDataModule.Create;
   FileDescriptorJSONRPCModule:=TFileDescWebJSONRPCModule.Create;
   FileDescriptorExtDirectModule:=TFileDescExtDirectModule.Create;
   RegisterProjectFileDescriptor(FileDescriptorWebProviderDataModule);
   RegisterProjectFileDescriptor(FileDescriptorJSONRPCModule);
   RegisterProjectFileDescriptor(FileDescriptorExtDirectModule);
   FormEditingHook.RegisterDesignerBaseClass(TFPCustomWebProviderDataModule);
   FormEditingHook.RegisterDesignerBaseClass(TFPWebProviderDataModule);
   FormEditingHook.RegisterDesignerBaseClass(TJSONRPCModule);
   FormEditingHook.RegisterDesignerBaseClass(TExtDirectModule);
   AChecker:=TJSSyntaxChecker.Create(Nil);
   LazarusIDE.AddHandlerOnQuickSyntaxCheck(@AChecker.CheckSource,False);
   RegisterPropertyEditor(TStrings.ClassInfo, TSQLDBWebDataProvider,  'SelectSQL', TSQLStringsPropertyEditor);
   RegisterPropertyEditor(TStrings.ClassInfo, TSQLDBWebDataProvider,  'InsertSQL', TSQLStringsPropertyEditor);
   RegisterPropertyEditor(TStrings.ClassInfo, TSQLDBWebDataProvider,  'DeleteSQL', TSQLStringsPropertyEditor);
   RegisterPropertyEditor(TStrings.ClassInfo, TSQLDBWebDataProvider,  'UpdateSQL', TSQLStringsPropertyEditor);
   ProjectDescriptorHTTPApplication:=THTTPApplicationDescriptor.Create;
   RegisterProjectDescriptor(ProjectDescriptorHTTPApplication);
end;

{ THTTPApplicationDescriptor }

constructor THTTPApplicationDescriptor.Create;
begin
  inherited Create;
  Name:='FPHTTPApplication';
end;

function THTTPApplicationDescriptor.GetLocalizedName: string;
begin
  Result:=rsHTTPAppli;
end;

function THTTPApplicationDescriptor.GetLocalizedDescription: string;
begin
  Result:=rsHTTPAppli2;
end;

function THTTPApplicationDescriptor.GetOPtions : TModalResult;

begin
  With TNewHTTPApplicationForm.Create(Application) do
    try
      Result:=ShowModal;
      if Result=mrOK then
        begin
        FThreaded:=Threaded;
        FPort:=Port;
        FReg:=ServeFiles;
        if Freg then
          begin
          FLoc:=Location;
          FDir:=Directory;
          end;
        end;
    finally
      Free;
    end;
end;
function THTTPApplicationDescriptor.InitProject(AProject: TLazProject
  ): TModalResult;

Var
  S : string;
  le: string;
  NewSource: String;
  MainFile: TLazProjectFile;

begin
  inherited InitProject(AProject);
  Result:=GetOptions;
  if Result<>mrOK then
    Exit;
  MainFile:=AProject.CreateProjectFile('httpproject1.lpr');
  MainFile.IsPartOfProject:=true;
  AProject.AddFile(MainFile,false);
  AProject.MainFileID:=0;
  // create program source
  le:=LineEnding;
  NewSource:='program httpproject1;'+le
    +le
    +'{$mode objfpc}{$H+}'+le
    +le
    +'uses'+le;
  if FReg then
    NewSource:=NewSource+'  fpwebfile,'+le;
  NewSource:=NewSource
    +'  fphttpapp;'+le
    +le
    +'begin'+le;
  if Freg then
    begin
    S:=Format('  RegisterFileLocation(''%s'',''%s'');',[FLoc,FDir]);
    NewSource:=NewSource+S+le
    end;
  NewSource:=NewSource
    +'  Application.Title:=''httpproject1'';'+le
    +Format('  Application.Port:=%d;'+le,[FPort]);
  if FThreaded then
    NewSource:=NewSource+'  Application.Threaded:=True;'+le;
  NewSource:=NewSource
    +'  Application.Initialize;'+le
    +'  Application.Run;'+le
    +'end.'+le
    +le;
  AProject.MainFile.SetSourceText(NewSource);

  // add
  AProject.AddPackageDependency('FCL');
  AProject.AddPackageDependency('WebLaz');
  AProject.AddPackageDependency('LazWebExtra');

  // compiler options
  AProject.LazCompilerOptions.Win32GraphicApp:=false;
  AProject.Flags := AProject.Flags - [pfMainUnitHasCreateFormStatements];
  Result:= mrOK;
end;

function THTTPApplicationDescriptor.CreateStartFiles(AProject: TLazProject
  ): TModalResult;
begin
  LazarusIDE.DoNewEditorFile(FileDescriptorWebModule,'','',
                         [nfIsPartOfProject,nfOpenInEditor,nfCreateDefaultSrc]);
  Result:= mrOK;
end;

{ TFileDescWebProviderDataModule }

constructor TFileDescWebProviderDataModule.Create;
begin
  inherited Create;
  Name:='Web DataProvider Module';
  ResourceClass:=TFPWebProviderDataModule;
  UseCreateFormStatements:=False;
end;

function TFileDescWebProviderDataModule.GetInterfaceUsesSection: string;
begin
  Result:=inherited GetInterfaceUsesSection;
  Result:=Result+', HTTPDefs, websession, fpHTTP, fpWeb, fpwebdata';
end;

function TFileDescWebProviderDataModule.GetLocalizedName: string;
begin
  Result:=rsWebDataProvi;
end;

function TFileDescWebProviderDataModule.GetLocalizedDescription: string;
begin
  Result:=Format(rsWEBDataProvi2, [#13]);
end;

function TFileDescWebProviderDataModule.GetImplementationSource(const Filename,
  SourceName, ResourceName: string): string;
begin
  Result:=Inherited GetImplementationSource(FileName,SourceName,ResourceName);
  if GetResourceType = rtRes then
    Result:=Result+'initialization'+LineEnding;
  Result:=Result+'  RegisterHTTPModule(''T'+ResourceName+''',T'+ResourceName+');'+LineEnding;
end;



{ TFileDescWebJSONFPCModule }

constructor TFileDescWebJSONRPCModule.Create;
begin
  inherited Create;
  Name:='JSON-RPC Module';
  ResourceClass:=TJSONRPCModule;
  UseCreateFormStatements:=False;
end;

function TFileDescWebJSONRPCModule.GetInterfaceUsesSection: string;
begin
  Result:=inherited GetInterfaceUsesSection;
  Result:=Result+', HTTPDefs, websession, fpHTTP, fpWeb, fpjsonrpc, webjsonrpc';
end;

function TFileDescWebJSONRPCModule.GetLocalizedName: string;
begin
  Result:=rsWebJSONRPCMo;
end;

function TFileDescWebJSONRPCModule.GetLocalizedDescription: string;
begin
  Result:=Format(rsWEBJSONRPCMo2, [#13]);
end;

function TFileDescWebJSONRPCModule.GetImplementationSource(const Filename,
  SourceName, ResourceName: string): string;

Var
  RH,RM : Boolean;
  CN,HP : String;

begin
  RH:=False;
  RM:=False;
  CN:=ResourceName;
  HP:=ResourceName;
  With TJSONRPCModuleOptionsForm.Create(Application) do
    try
      If (ShowModal=mrOK) then
        begin
        RH:=RegisterHandlers;
        If RH Then
          CN:=JSONRPCClass;
        RM:=RegisterModule;
        If RM then
          HP:=HTTPPath;
        end;
    finally
      Free;
    end;
  Result:=Inherited GetImplementationSource(FileName,SourceName,ResourceName);
  if (GetResourceType = rtRes) and (RM or RH) then
    Result:=Result+'Initialization'+sLineBreak;
  If RM then
    Result:=Result+'  RegisterHTTPModule('''+HP+''',T'+ResourceName+');'+LineEnding;
  If RH then
    Result:=Result+'  JSONRPCHandlerManager.RegisterDatamodule(T'+ResourceName+','''+HP+''',);'+LineEnding;
end;

{ TFileDescExtDirectModule }

constructor TFileDescExtDirectModule.Create;
begin
  inherited Create;
  Name:='Ext.Direct Module';
  ResourceClass:=TExtDirectModule;
  UseCreateFormStatements:=False;
end;

function TFileDescExtDirectModule.GetInterfaceUsesSection: string;
begin
  Result:=inherited GetInterfaceUsesSection;
  Result:=Result+', HTTPDefs, websession, fpHTTP, fpWeb, fpjsonrpc, webjsonrpc, fpextdirect';
end;

function TFileDescExtDirectModule.GetLocalizedName: string;
begin
  Result:=inherited GetLocalizedName;
  Result:=rsWebExtDirect;
end;

function TFileDescExtDirectModule.GetLocalizedDescription: string;
begin
  Result:=Format(rsWEBExtDirect2, [#13]);
end;

function TFileDescExtDirectModule.GetImplementationSource(const Filename,
  SourceName, ResourceName: string): string;

Var
  RH,RM : Boolean;
  CN,HP : String;

begin
  RH:=False;
  RM:=False;
  CN:=ResourceName;
  HP:=ResourceName;
  With TJSONRPCModuleOptionsForm.Create(Application) do
    try
      If (ShowModal=mrOK) then
        begin
        RH:=RegisterHandlers;
        If RH Then
          CN:=JSONRPCClass;
        RM:=RegisterModule;
        If RM then
          HP:=HTTPPath;
        end;
    finally
      Free;
    end;
  Result:=Inherited GetImplementationSource(FileName,SourceName,ResourceName);
  if (GetResourceType = rtRes) and (RM or RH) then
    Result:=Result+'Initialization'+sLineBreak;
  If RM then
    Result:=Result+'  RegisterHTTPModule('''+HP+''',T'+ResourceName+');'+LineEnding;
  If RH then
    Result:=Result+'  JSONRPCHandlerManager.RegisterDatamodule(T'+ResourceName+','''+HP+''',);'+LineEnding;
end;

{ TJSSyntaxChecker }


procedure TJSSyntaxChecker.ShowMessage(const Msg: String);
begin
  {$IFDEF EnableNewExtTools}
  IDEMessagesWindow.AddCustomMessage(mluImportant,Msg,SourceFileName);
  {$ELSE}
  IDEMessagesWindow.AddMsg(SourceFileName+' : '+Msg,'',0,Nil);
  {$ENDIF}
end;

procedure TJSSyntaxChecker.ShowMessage(const Fmt: String;
  Args: array of const);
begin
  ShowMessage(Format(Fmt,Args));
end;

procedure TJSSyntaxChecker.ShowException(const Msg: String; E: Exception);
begin
  If (Msg<>'') then
    ShowMessage(Msg+' : '+E.Message)
  else
    ShowMessage(Msg+' : '+E.Message);
end;

function TJSSyntaxChecker.CheckJavaScript(S : TStream): TModalResult;

Var
  P : TJSParser;
  E : TJSElement;
begin
  P:=TJSParser.Create(S);
  try
    try
      E:=P.Parse;
      E.Free;
      ShowMessage('Javascript syntax OK');
    except
      On E : Exception do
        ShowException('Javascript syntax error',E);
    end;
  finally
    P.free;
  end;
end;

function TJSSyntaxChecker.CheckSource(Sender: TObject; var Handled: boolean
  ): TModalResult;

Var
  AE : TSourceEditorInterface;
  E : String;
  S : TStringStream;

begin
  {$IFNDEF EnableNewExtTools}
  IDEMessagesWindow.BeginBlock(False);
  {$ENDIF}
  try
    try
    Handled:=False;
    result:=mrNone;
    AE:=SourceEditorManagerIntf.ActiveEditor;
    If (AE<>Nil) then
      begin
      E:=ExtractFileExt(AE.FileName);
      FSFN:=ExtractFileName(AE.FileName);
      Handled:=CompareText(E,'.js')=0;
      If Handled then
        begin
        S:=TStringStream.Create(AE.SourceText);
        try
          CheckJavaScript(S);
          Result:=mrOK;
        finally
          S.Free;
        end;
        end;
      end;
    except
      On E : Exception do
        ShowException('Error during syntax check',E);
    end;
  finally
    {$IFNDEF EnableNewExtTools}
    IDEMessagesWindow.EndBlock;
    {$ENDIF}
  end;
end;

{ TJSFileDescriptor }

constructor TJSFileDescriptor.Create;
begin
  Name:='SQL Script file';
  DefaultFilename:='script.sql';
  DefaultResFileExt:='';
  DefaultFileExt:='.sql';
  VisibleInNewDialog:=true;
end;

function TJSFileDescriptor.GetLocalizedName: string;
begin
  Result:=inherited GetLocalizedName;
end;

function TJSFileDescriptor.GetLocalizedDescription: string;
begin
  Result:=inherited GetLocalizedDescription;
end;

function TJSFileDescriptor.GetResourceSource(const ResourceName: string
  ): string;
begin
  Result:=inherited GetResourceSource(ResourceName);
end;

function TJSFileDescriptor.CreateSource(const Filename, SourceName,
  ResourceName: string): string;
begin
  Result:=inherited CreateSource(Filename, SourceName, ResourceName);
end;

procedure TJSFileDescriptor.UpdateDefaultPascalFileExtension(
  const DefPasExt: string);
begin
  inherited UpdateDefaultPascalFileExtension(DefPasExt);
end;

finalization
  FreeAndNil(AChecker);

end.

