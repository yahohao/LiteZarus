{ Example widgetset.
  It does not have any useful implementation, it only provides the classes
  and published properties to define a child-parent relationship and some
  coordinates. The Lazarus designer will do the rest:
  Opening, closing, editing forms of this example widgetset.
  At designtime the TMyWidgetMediator will paint.


  Copyright (C) 2009 Mattias Gaertner mattias@freepascal.org

  This library is free software; you can redistribute it and/or modify it
  under the terms of the GNU Library General Public License as published by
  the Free Software Foundation; either version 2 of the License, or (at your
  option) any later version with the following modification:

  As a special exception, the copyright holders of this library give you
  permission to link this library with independent modules to produce an
  executable, regardless of the license terms of these independent modules,and
  to copy and distribute the resulting executable under terms of your choice,
  provided that you also meet, for each linked independent module, the terms
  and conditions of the license of that module. An independent module is a
  module which is not derived from or based on this library. If you modify
  this library, you may extend this exception to your version of the library,
  but you are not obligated to do so. If you do not wish to do so, delete this
  exception statement from your version.

  This program is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
  FITNESS FOR A PARTICULAR PURPOSE. See the GNU Library General Public License
  for more details.

  You should have received a copy of the GNU Library General Public License
  along with this library; if not, write to the Free Software Foundation,
  Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
}
unit Carpets;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Math, types;

type
  ICarpetDesigner = interface(IUnknown)
    procedure InvalidateRect(Sender: TObject; ARect: TRect; Erase: boolean);
  end;

  { forward }
  TCarpetCanvas = class;


  { TCustomCarpet }

  TCustomCarpet = class(TComponent)
  private
    FAlignment: TAlignment;
    FBorderBottom: integer;
    FBorderLeft: integer;
    FBorderRight: integer;
    FBorderTop: integer;
    FCanvas: TCarpetCanvas;
    FCaption: string;
    FChilds: TFPList; // list of TCarpet
    FHeight: integer;
    FLeft: integer;
    FParent: TCustomCarpet;
    FTop: integer;
    FVisible: boolean;
    FWidth: integer;
    function GetChilds(Index: integer): TCustomCarpet;
    procedure SetAlignment(AValue: TAlignment);
    procedure SetBorderBottom(const AValue: integer);
    procedure SetBorderLeft(const AValue: integer);
    procedure SetBorderRight(const AValue: integer);
    procedure SetBorderTop(const AValue: integer);
    procedure SetCaption(const AValue: string);
    procedure SetColor(AValue: Cardinal);
    procedure SetHeight(const AValue: integer);
    procedure SetLeft(const AValue: integer);
    procedure SetParent(const AValue: TCustomCarpet);
    procedure SetTop(const AValue: integer);
    procedure SetVisible(const AValue: boolean);
    procedure SetWidth(const AValue: integer);
  protected
    FAcceptChildrenAtDesignTime: boolean;
    FColor: Cardinal;
    procedure InternalInvalidateRect({%H-}ARect: TRect; {%H-}Erase: boolean); virtual;
    procedure SetName(const NewName: TComponentName); override;
    procedure SetParentComponent(Value: TComponent); override;
    procedure GetChildren(Proc: TGetChildProc; Root: TComponent); override;
    procedure RemoveCarpet(AChild: TCustomCarpet);
    procedure Paint; virtual;
    property Caption: string read FCaption write SetCaption;
    property Alignment : TAlignment read FAlignment write SetAlignment;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Parent: TCustomCarpet read FParent write SetParent;
    function ChildCount: integer;
    property Children[Index: integer]: TCustomCarpet read GetChilds;
    function HasParent: Boolean; override;
    function GetParentComponent: TComponent; override;
    procedure SetBounds(NewLeft, NewTop, NewWidth, NewHeight: integer); virtual;
    procedure InvalidateRect(ARect: TRect; Erase: boolean);
    procedure Invalidate;
    property AcceptChildrenAtDesignTime: boolean read FAcceptChildrenAtDesignTime;
    property Canvas : TCarpetCanvas read FCanvas write FCanvas;
    property BorderLeft: integer read FBorderLeft write SetBorderLeft;
    property BorderRight: integer read FBorderRight write SetBorderRight;
    property BorderTop: integer read FBorderTop write SetBorderTop;
    property BorderBottom: integer read FBorderBottom write SetBorderBottom;
  published
    property Left: integer read FLeft write SetLeft;
    property Top: integer read FTop write SetTop;
    property Width: integer read FWidth write SetWidth;
    property Height: integer read FHeight write SetHeight;
    property Visible: boolean read FVisible write SetVisible;
    property Color : Cardinal read FColor write SetColor;
  end;
  TCarpetClass = class of TCustomCarpet;


  { TMyGroupBox
    A widget that does allow children at design time }

  TCarpet = class(TCustomCarpet)
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Caption;
    property BorderLeft default 5;
    property BorderRight default 5;
    property BorderTop default 20;
    property BorderBottom default 5;
  end;


  { TCarpetLabel
    A widget that does not allow children at design time }

  TCarpetLabel = class(TCustomCarpet)
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Caption;
    property Color default $1FFFFFFF;
    property Alignment;
  end;

  { TMyForm }

  { TDataRoom }

  TDataRoom = class(TCustomCarpet)
  private
    FDesigner: ICarpetDesigner;
  protected
    procedure Paint; override;
    procedure InternalInvalidateRect(ARect: TRect; Erase: boolean); override;
  public
    constructor Create(AOwner: TComponent); override;
    property Designer: ICarpetDesigner read FDesigner write FDesigner;
    property BorderLeft default 2;
    property BorderRight default 2;
    property BorderTop default 2;
    property BorderBottom default 2;
  end;


  { TCarpetCanvas }

  TCarpetCanvas = class(TPersistent)
  public
    procedure FillRect(const X1,Y1,X2,Y2: Integer; const AColor: Cardinal); virtual;
    procedure Frame3D(var ARect: TRect; TopColor, BottomColor: Cardinal;
                      const FrameWidth: integer); virtual;
    procedure Rectangle(X1,Y1,X2,Y2: Integer; AColor: Cardinal); virtual;
    procedure StretchDraw(const DestRect: TRect; SrcGraphic: TObject); virtual;
    procedure TextOut(X,Y: Integer; const Text: String); virtual;
    procedure TextRect(ARect: TRect; const Text: string; Alignment: TAlignment); virtual;
  end;
  TCarpetCanvasClass = class of TCarpetCanvas;



  { assumed funcs & var below is taken from external lib }
type
  TGetBorderColorProc = function(const AColor: Cardinal): Cardinal;

var
  DefaultCanvasClass : TCarpetCanvasClass;
  GetBorderColor : TGetBorderColorProc;

implementation

const
  clNone    = $1FFFFFFF;

{ Misc funcs }

function GetBorderColorDummyProc(const AColor: Cardinal): Cardinal;
// it should be replaced by designtime func
begin
  result := AColor;
end;


{ TCarpetCanvas }

procedure TCarpetCanvas.FillRect(const X1, Y1, X2, Y2: Integer;
  const AColor: Cardinal);
begin

end;

procedure TCarpetCanvas.Frame3D(var ARect: TRect; TopColor,
  BottomColor: Cardinal; const FrameWidth: integer);
begin

end;

procedure TCarpetCanvas.Rectangle(X1, Y1, X2, Y2: Integer; AColor: Cardinal);
begin

end;

procedure TCarpetCanvas.StretchDraw(const DestRect: TRect; SrcGraphic: TObject);
begin

end;

procedure TCarpetCanvas.TextOut(X, Y: Integer; const Text: String);
begin

end;

procedure TCarpetCanvas.TextRect(ARect: TRect; const Text: string; Alignment: TAlignment);
begin

end;


{ TCarpet }

procedure TCarpet.Paint;
begin
  inherited Paint;
  with Canvas do begin
    Rectangle(0,0,Width,Height, GetBorderColor(Color));
    // inner frame
    //if AWidget.AcceptChildrenAtDesignTime then begin
      Rectangle(BorderLeft-1,BorderTop-1,
                Width-BorderRight+1,
                Height-BorderBottom+1, GetBorderColor(Color));

    // caption
    //Font.Style:=[fsBold];
    TextOut(5,2,Caption);
  end;
end;

constructor TCarpet.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FBorderLeft:=5;
  FBorderRight:=5;
  FBorderBottom:=5;
  FBorderTop:=20;
end;

{ TCarpet }

function TCustomCarpet.GetChilds(Index: integer): TCustomCarpet;
begin
  Result:=TCustomCarpet(FChilds[Index]);
end;

procedure TCustomCarpet.SetAlignment(AValue: TAlignment);
begin
  if FAlignment=AValue then Exit;
  FAlignment:=AValue;
  Invalidate;
end;

procedure TCustomCarpet.SetBorderBottom(const AValue: integer);
begin
  if FBorderBottom=AValue then exit;
  FBorderBottom:=AValue;
  Invalidate;
end;

procedure TCustomCarpet.SetBorderLeft(const AValue: integer);
begin
  if FBorderLeft=AValue then exit;
  FBorderLeft:=AValue;
  Invalidate;
end;

procedure TCustomCarpet.SetBorderRight(const AValue: integer);
begin
  if FBorderRight=AValue then exit;
  FBorderRight:=AValue;
  Invalidate;
end;

procedure TCustomCarpet.SetBorderTop(const AValue: integer);
begin
  if FBorderTop=AValue then exit;
  FBorderTop:=AValue;
  Invalidate;
end;

procedure TCustomCarpet.SetCaption(const AValue: string);
begin
  if FCaption=AValue then exit;
  FCaption:=AValue;
  Invalidate;
end;

procedure TCustomCarpet.SetColor(AValue: Cardinal);
begin
  if FColor=AValue then Exit;
  FColor:=AValue;
  Invalidate;
end;

procedure TCustomCarpet.SetHeight(const AValue: integer);
begin
  SetBounds(Left,Top,Width,AValue);
end;

procedure TCustomCarpet.SetLeft(const AValue: integer);
begin
  SetBounds(AValue,Top,Width,Height);
end;

procedure TCustomCarpet.SetParent(const AValue: TCustomCarpet);
begin
  if FParent=AValue then exit;
  if FParent<>nil then begin
    //Invalidate;
    FParent.RemoveCarpet(Self);
  end;
  if (AValue is TCustomCarpet) or (AValue = nil) then //allowed to use outside dataroom (such form, datamodule)
    FParent:=AValue;
  if FParent<>nil then begin
    FParent.FChilds.Add(Self);
  end;
  Invalidate;
end;

procedure TCustomCarpet.SetTop(const AValue: integer);
begin
  SetBounds(Left,AValue,Width,Height);
end;

procedure TCustomCarpet.SetVisible(const AValue: boolean);
begin
  if FVisible=AValue then exit;
  FVisible:=AValue;
  Invalidate;
end;

procedure TCustomCarpet.SetWidth(const AValue: integer);
begin
  SetBounds(Left,Top,AValue,Height);
end;

procedure TCustomCarpet.InternalInvalidateRect(ARect: TRect; Erase: boolean);
begin
  // see TMyForm
end;

procedure TCustomCarpet.SetName(const NewName: TComponentName);
begin
  if Name=Caption then Caption:=NewName;
  inherited SetName(NewName);
end;

procedure TCustomCarpet.SetParentComponent(Value: TComponent);
begin
  if (Value is TCustomCarpet) or (Value = nil) then
    Parent:=TCustomCarpet(Value);
end;

function TCustomCarpet.HasParent: Boolean;
begin
  Result:=Parent<>nil;
end;

function TCustomCarpet.GetParentComponent: TComponent;
begin
  Result:=Parent;
end;

procedure TCustomCarpet.GetChildren(Proc: TGetChildProc; Root: TComponent);
var
  i: Integer;
begin
  for i:=0 to ChildCount-1 do
    if Children[i].Owner=Root then
      Proc(Children[i]);

  if Root = self then
    for i:=0 to ComponentCount-1 do
      if Components[i].GetParentComponent = nil then
        Proc(Components[i]);
end;

constructor TCustomCarpet.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FChilds:=TFPList.Create;
  FColor := $0079FD9A;
  FWidth :=136;
  FHeight := 112;
  FAcceptChildrenAtDesignTime:=true;
  if DefaultCanvasClass <> nil then
    FCanvas := DefaultCanvasClass.Create;
end;

destructor TCustomCarpet.Destroy;
var i : integer;
begin
  Parent:=nil;
  for i := ChildCount-1 downto 0 do
    Children[i].Free;
  FreeAndNil(FChilds);
  if assigned(FCanvas) then
     FCanvas.Free;
  inherited Destroy;
end;

function TCustomCarpet.ChildCount: integer;
begin
  Result:=FChilds.Count;
end;

procedure TCustomCarpet.RemoveCarpet(AChild: TCustomCarpet);
begin
  if FChilds.IndexOf(AChild) >= 0 then
  begin
    FChilds.Remove(AChild);
    AChild.Parent := nil;
  end;
end;

procedure TCustomCarpet.Paint;
begin
  if Color <> clNone then
    FCanvas.FillRect(0,0,Width,Height, self.Color);
end;

procedure TCustomCarpet.SetBounds(NewLeft, NewTop, NewWidth, NewHeight: integer);
begin
  if (Left=NewLeft) and (Top=NewTop) and (Width=NewWidth) and (Height=NewHeight) then
    exit;
  Invalidate;
  FLeft:=NewLeft;
  FTop:=NewTop;
  FWidth:=NewWidth;
  FHeight:=NewHeight;
  Invalidate;
end;

procedure TCustomCarpet.InvalidateRect(ARect: TRect; Erase: boolean);
begin
  ARect.Left:=Max(0,ARect.Left);
  ARect.Top:=Max(0,ARect.Top);
  ARect.Right:=Min(Width,ARect.Right);
  ARect.Bottom:=Max(Height,ARect.Bottom);
  if Parent<>nil then begin
    OffsetRect(ARect,Left+Parent.BorderLeft,Top+Parent.BorderTop);
    Parent.InvalidateRect(ARect,Erase);
  end else begin
    InternalInvalidateRect(ARect,Erase);
  end;
end;

procedure TCustomCarpet.Invalidate;
begin
  if not (csDestroying in ComponentState) then
    InvalidateRect(Rect(0,0,Width,Height),false);
end;

{ TMyForm }

procedure TDataRoom.Paint;
const
  clBtnShadow = $80000010;
  cl3DHiLight = $80000014;
  cl3DDkShadow= $80000015;
  clBtnFace   = $8000000F;
var r : TRect;
begin
  inherited Paint;
  r := Rect(0,0,Width,Height);
  Canvas.Frame3D(r, clBtnShadow, cl3DHiLight, 1);
  Canvas.Frame3d(r, cl3DDkShadow, clBtnFace, 1);
end;

procedure TDataRoom.InternalInvalidateRect(ARect: TRect; Erase: boolean);
begin
  if (Parent=nil) and (Designer<>nil) then
    Designer.InvalidateRect(Self,ARect,Erase);
end;

constructor TDataRoom.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FBorderLeft:=2;
  FBorderRight:=2;
  FBorderBottom:=2;
  FBorderTop:=2;
  FWidth  := 150;
  FHeight := 150;
  FColor  := $80000005; //clWindow
end;

{ TCarpetLabel }

procedure TCarpetLabel.Paint;
begin
  inherited Paint;
  Canvas.TextRect(Rect(BorderLeft, BorderTop, Width-BorderRight, Height-BorderBottom), Caption, self.Alignment);
end;

constructor TCarpetLabel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FColor := clNone;
  FAcceptChildrenAtDesignTime:=false;
end;


initialization
  DefaultCanvasClass := TCarpetCanvas; //it will replaced by real implemented method
  GetBorderColor := @GetBorderColorDummyProc;

end.

