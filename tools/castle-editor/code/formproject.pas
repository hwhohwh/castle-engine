{
  Copyright 2018-2018 Michalis Kamburelis.

  This file is part of "Castle Game Engine".

  "Castle Game Engine" is free software; see the file COPYING.txt,
  included in this distribution, for details about the copyright.

  "Castle Game Engine" is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

  ----------------------------------------------------------------------------
}

{ Project form (@link(TProjectForm)). }
unit FormProject;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, DOM, FileUtil, Forms, Controls, Graphics, Dialogs, Menus,
  ExtCtrls, ComCtrls, ShellCtrls, StdCtrls, ValEdit, ProjectUtils,
  CastleControl;

type
  { Main project management. }
  TProjectForm = class(TForm)
    CastleControl1: TCastleControl;
    MainMenu1: TMainMenu;
    MemoCommandOutput: TMemo;
    MenuItemModeRelease: TMenuItem;
    MenuItemPackage: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItemModeDebug: TMenuItem;
    MenuItemSeparator3: TMenuItem;
    MenuItemSeparator2: TMenuItem;
    MenuItemReference: TMenuItem;
    MenuItemManual: TMenuItem;
    MenuItemCgeWww: TMenuItem;
    MenuItemAbout: TMenuItem;
    MenuItemSeparator: TMenuItem;
    MenuItemHelp: TMenuItem;
    MenuItemClean: TMenuItem;
    MenuItemOnlyRun: TMenuItem;
    MenuItemCompileRun: TMenuItem;
    MenuItemCompile: TMenuItem;
    MenuItemSwitchProject: TMenuItem;
    MenuItemRun: TMenuItem;
    MenuItemFile: TMenuItem;
    MenuItemQuit: TMenuItem;
    PageControl1: TPageControl;
    PanelAboveTabs: TPanel;
    ShellListView1: TShellListView;
    ShellTreeView1: TShellTreeView;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    Splitter3: TSplitter;
    Splitter4: TSplitter;
    TabFiles: TTabSheet;
    TabCommandOutput: TTabSheet;
    TreeView1: TTreeView;
    ValueListEditor1: TValueListEditor;
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure MenuItemAboutClick(Sender: TObject);
    procedure MenuItemCgeWwwClick(Sender: TObject);
    procedure MenuItemCleanClick(Sender: TObject);
    procedure MenuItemCompileClick(Sender: TObject);
    procedure MenuItemCompileRunClick(Sender: TObject);
    procedure MenuItemManualClick(Sender: TObject);
    procedure MenuItemModeDebugClick(Sender: TObject);
    procedure MenuItemOnlyRunClick(Sender: TObject);
    procedure MenuItemPackageClick(Sender: TObject);
    procedure MenuItemQuitClick(Sender: TObject);
    procedure MenuItemReferenceClick(Sender: TObject);
    procedure MenuItemModeReleaseClick(Sender: TObject);
    procedure MenuItemSwitchProjectClick(Sender: TObject);
  private
    ProjectName: String;
    ProjectPath, ProjectPathUrl: String;
    BuildMode: TBuildMode;
    procedure BuildToolCall(const Commands: array of String);
  public
    procedure OpenProject(const ManifestUrl: String);
  end;

var
  ProjectForm: TProjectForm;

implementation

{$R *.lfm}

uses CastleXMLUtils, CastleLCLUtils, CastleOpenDocument, CastleURIUtils,
  CastleFilesUtils, CastleUtils, X3DNodes, CastleVectors, CastleColors,
  CastleScene,
  FormChooseProject, EditorUtils, ToolUtils;

procedure TProjectForm.MenuItemQuitClick(Sender: TObject);
begin
  // TODO ask only if unsaved things
//  if YesNoBox('Quit the editor?') then
    Application.Terminate;
end;

procedure TProjectForm.MenuItemReferenceClick(Sender: TObject);
begin
  OpenURL('https://castle-engine.io/apidoc/html/index.html');
end;

procedure TProjectForm.MenuItemModeReleaseClick(Sender: TObject);
begin
  BuildMode := bmRelease;
  MenuItemModeRelease.Checked := true;
end;

procedure TProjectForm.MenuItemCgeWwwClick(Sender: TObject);
begin
  OpenURL('https://castle-engine.io/');
end;

procedure TProjectForm.MenuItemAboutClick(Sender: TObject);
begin
  // TODO
  // Show logo, website link, Patreon link,
  // Copyright Michalis Kamburelis and many contributors (thank you!)
  // Show current (runtime) CGE, FPC version
  // Show CGE, FPC version when compiling editor
end;

procedure TProjectForm.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  // TODO ask only if unsaved things
  //if YesNoBox('Quit the editor?') then
    Application.Terminate;
end;

procedure TProjectForm.MenuItemCleanClick(Sender: TObject);
begin
  BuildToolCall(['clean']);
end;

procedure TProjectForm.MenuItemCompileClick(Sender: TObject);
begin
  BuildToolCall(['compile']);
end;

procedure TProjectForm.MenuItemCompileRunClick(Sender: TObject);
begin
  BuildToolCall(['compile', 'run']);
end;

procedure TProjectForm.MenuItemManualClick(Sender: TObject);
begin
  OpenURL('https://castle-engine.io/manual_intro.php');
end;

procedure TProjectForm.MenuItemModeDebugClick(Sender: TObject);
begin
  BuildMode := bmDebug;
  MenuItemModeDebug.Checked := true;
end;

procedure TProjectForm.MenuItemOnlyRunClick(Sender: TObject);
begin
  BuildToolCall(['run']);
end;

procedure TProjectForm.MenuItemPackageClick(Sender: TObject);
begin
  BuildToolCall(['package']);
end;

procedure TProjectForm.MenuItemSwitchProjectClick(Sender: TObject);
begin
  // TODO ask only if unsaved things
  //if YesNoBox('Close this editor project?') then

  Free; // do not call Close, to avoid OnCloseQuery
  ChooseProjectForm.Show;
end;

procedure TProjectForm.BuildToolCall(const Commands: array of String);
var
  BuildToolExe, BuildToolOutput, Command, ModeString, AllOutput: String;
  BuildToolStatus: integer;
begin
  BuildToolExe := FindExe('castle-engine');
  if BuildToolExe = '' then
  begin
    ErrorBox('Cannot find build tool (castle-engine) on $PATH environment variable.');
    Exit;
  end;

  case BuildMode of
    bmDebug  : ModeString := '--mode=debug';
    bmRelease: ModeString := '--mode=release';
    else raise EInternalError.Create('BuildMode?');
  end;

  AllOutput := '';

  for Command in Commands do
  begin
    AllOutput := AllOutput +
      'Running "' + BuildToolExe + ' ' + ModeString + ' ' + Command + '"' +
      LineEnding + LineEnding;

    MyRunCommandIndir(ProjectPath, BuildToolExe,
      [ModeString, Command], BuildToolOutput, BuildToolStatus);

    AllOutput := AllOutput + BuildToolOutput +
      LineEnding + LineEnding +
      'Command finished with status ' + IntToStr(BuildToolStatus) + '.' +
      LineEnding + LineEnding;

    if BuildToolStatus <> 0 then
    begin
      PageControl1.ActivePage := TabCommandOutput;
      MemoCommandOutput.Lines.Text := AllOutput;
      Exit;
    end;
  end;

  PageControl1.ActivePage := TabCommandOutput;
  MemoCommandOutput.Lines.Text := AllOutput;
end;

procedure TProjectForm.OpenProject(const ManifestUrl: String);

  function CreateSceneRoot: TX3DRootNode;
  var
    Sphere: TSphereNode;
    Box: TBoxNode;
    SphereShape, BoxShape: TShapeNode;
    SphereTransform, BoxTransform: TTransformNode;
  begin
    Result := TX3DRootNode.Create;

    Sphere := TSphereNode.CreateWithTransform(SphereShape, SphereTransform);
    Result.AddChildren(SphereTransform);

    SphereShape.Material := TMaterialNode.Create;
    SphereShape.Material.DiffuseColor := YellowRGB;

    Box := TBoxNode.CreateWithTransform(BoxShape, BoxTransform);
    BoxTransform.Translation := Vector3(3, 0, 0);
    Result.AddChildren(BoxTransform);

    BoxShape.Material := TMaterialNode.Create;
    BoxShape.Material.DiffuseColor := BlueRGB;
  end;

var
  ManifestDoc: TXMLDocument;
  Scene: TCastleScene;
begin
  ManifestDoc := URLReadXML(ManifestUrl);
  try
    ProjectName := ManifestDoc.DocumentElement.AttributeString('name');
  finally FreeAndNil(ManifestDoc) end;

  ProjectPathUrl := ExtractURIPath(ManifestUrl);
  ProjectPath := URIToFilenameSafe(ProjectPathUrl);

  Caption := SQuoteLCLCaption(ProjectName) + ' | Castle Game Engine';

  ShellTreeView1.Root := ProjectPath;

  // TODO CastleControl1 should be TCastleControlCustom ?
  Scene := TCastleScene.Create(Self);
  Scene.Load(CreateSceneRoot, true);
  CastleControl1.SceneManager.Items.Add(Scene);
  CastleControl1.SceneManager.MainScene := Scene;
end;

end.

