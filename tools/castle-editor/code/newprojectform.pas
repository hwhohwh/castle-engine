unit NewProjectForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  Buttons, ButtonPanel, StdCtrls, EditBtn;

type
  { Determine new project settings. }

  { TNewProject }

  TNewProject = class(TForm)
    ButtonPanel1: TButtonPanel;
    EditLocation: TEditButton;
    EditProjectName: TEdit;
    GroupProjectTemplate: TGroupBox;
    LabelProjectLocation: TLabel;
    LabelTitle: TLabel;
    LabelProjectName: TLabel;
    SelectDirectoryDialog1: TSelectDirectoryDialog;
    ButtonTemplateEmpty: TSpeedButton;
    ButtonTemplateFpsGame: TSpeedButton;
    ButtonTemplate3DModel: TSpeedButton;
    ButtonTemplate2DGame: TSpeedButton;
    procedure EditLocationButtonClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormShow(Sender: TObject);
    procedure ButtonTemplateClick(Sender: TObject);
  private

  public

  end;

var
  NewProject: TNewProject;

implementation

{$R *.lfm}

uses LazFileUtils,
  CastleURIUtils, CastleConfig, CastleUtils,
  EditorUtils;

procedure TNewProject.FormShow(Sender: TObject);
var
  DefaultNewProjectDir, NewProjectDir: String;
begin
  { Initialize everything to default values }

  ButtonTemplateEmpty.Down := true;

  DefaultNewProjectDir := InclPathDelim(GetUserDir) + 'Castle Game Engine Projects';
  NewProjectDir := UserConfig.GetValue('new_project/default_dir', DefaultNewProjectDir);
  // SelectDirectoryDialog1.InitialDir := NewProjectDir; // not neeeded
  SelectDirectoryDialog1.FileName := NewProjectDir;
  EditLocation.Text := NewProjectDir;

  EditProjectName.Text := 'my-new-project';
end;

procedure TNewProject.ButtonTemplateClick(Sender: TObject);
begin
  (Sender as TSpeedButton).Down := true;
end;

procedure TNewProject.EditLocationButtonClick(Sender: TObject);
begin
  // SelectDirectoryDialog1.InitialDir := EditLocation.Text; // not neeeded
  SelectDirectoryDialog1.FileName := EditLocation.Text;
  if SelectDirectoryDialog1.Execute then
    EditLocation.Text := SelectDirectoryDialog1.FileName;
end;

procedure TNewProject.FormCloseQuery(Sender: TObject; var CanClose: boolean);
var
  ProjectDir: String;
begin
  if ModalResult = mrOK then
  begin
    if NewProject.EditLocation.Text = '' then
    begin
      ErrorBox('No Project Location chosen.');
      CanClose := false;
      Exit;
    end;

    ProjectDir := InclPathDelim(NewProject.EditLocation.Text) +
      NewProject.EditProjectName.Text;
    if DirectoryExists(ProjectDir) then
    begin
      ErrorBox(Format('Directory "%s" already exists, cannot create a project there. Please pick a project name that does not correspond to an already-existing directory.', [ProjectDir]));
      CanClose := false;
      Exit;
    end;

    UserConfig.SetValue('new_project/default_dir', NewProject.EditLocation.Text);
  end;
end;

end.

