{
  Copyright 2006-2010 Michalis Kamburelis.

  This file is part of "Kambi VRML game engine".

  "Kambi VRML game engine" is free software; see the file COPYING.txt,
  included in this distribution, for details about the copyright.

  "Kambi VRML game engine" is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

  ----------------------------------------------------------------------------
}

{ Easy game 3D sound manager (TGameSoundEngine). }
unit GameSoundEngine;

{$I kambiconf.inc}

interface

uses Classes, VectorMath, KambiOpenAL, ALSourceAllocator, SysUtils,
  KambiUtils, KambiXMLConfig, ALSoundEngine;

{$define read_interface}

const
  MaxSoundImportance = MaxInt;

const
  DefaultGameVolume = 0.5;
  DefaultMusicVolume = 1.0;

type
  { This is a unique sound type identifier for sounds used within
    TGameSoundEngine.

    This is actually just an index to appropriate
    TGameSoundEngine.SoundNames array, but you should always treat
    this as an opaque type. }
  TSoundType = Cardinal;

const
  { Special sound type that indicates that there is actually none sound.
    @link(TGameSoundEngine.Sound) and @link(TGameSoundEngine.Sound3d)
    will do nothing when called with this sound type. }
  stNone = 0;

type
  { This is an internal type used within TGameSoundEngine.

    Although you still may want to familiarize with it's fields,
    as they correspond to appropriate fields in your sounds/index.xml file.
    All of the fields besides Buffer are initialized only by ReadSoundInfos.

    From the point of view of end-user playing the game the number of sounds
    is constant for given game and their properties (expressed in
    TSoundInfo below) are also constant.
    However, for the sake of debugging/testing the game,
    and for content designers, the actual values of SoundInfos are loaded
    at initialization by ReadSoundInfos (called automatically by ALContextOpen)
    from sounds/index.xml file,
    and later can be changed by calling ReadSoundInfos once again during the
    game (debug menu may have command like "Reload sounds/index.xml"). }
  TSoundInfo = record
    { '' means that this sound is not implemented and will never
      have any OpenAL buffer associated with it. }
    FileName: string;

    { XxxGain are mapped directly on respective OpenAL source properties.
      Note that Gain > 1 is allowed (because OpenAL allows it),
      although OpenAL may clip them for the resulting sound (after all
      calculations taking into account 3d position will be done).
      MaxGain is not allowed to be > 1 (under Windows impl, Linux impl
      allows it, but that's about it).

      When sound is used for MusicPlayer.PlayedSound:
      1. MinGain, MaxGain are ignored
      2. Gain is always multiplied by MusicVolume when setting AL_GAIN
         of the music source. }
    Gain, MinGain, MaxGain: Single;

    { Importance, as passed to TALSourceAllocator.
      This is ignored when sound is used for MusicPlayer.PlayedSound. }
    DefaultImportance: Cardinal;

    { OpenAL buffer of this sound. Zero if buffer is not yet loaded,
      which may happen only if TGameSoundEngine.ALContextOpen was not yet
      called or when sound has FileName = ''. }
    Buffer: TALuint;
  end;

  TDynArrayItem_1 = TSoundInfo;
  PDynArrayItem_1 = ^TSoundInfo;
  {$define DYNARRAY_1_IS_STRUCT}
  {$define DYNARRAY_1_IS_INIT_FINI_TYPE}
  {$I dynarray_1.inc}
  TDynSoundInfoArray = TDynArray_1;

type
  TMusicPlayer = class;

  { Easy to use sound manager, using OpenAL, ALUtils and
    ALSourceAllocator underneath.

    At ALContextOpen, right before initializing OpenAL stuff,
    this reads sounds information from SoundsXmlFileName file.
    When OpenAL is initialized, it loads all sound files.
    Sound filenames are specified inside SoundsXmlFileName file
    (they may be relative filenames, relative to the location
    of SoundsXmlFileName file).

    So this assumes that you want to load all sound files
    at once (along with initializing OpenAL context) and free them at once
    when releasing AL context. And it requires that you place your
    sounds data and XML file in appropriate locations.

    So the basic principle of this unit is to
    load all files at once, and require file like sounds/index.xml.
    That's the price for having easy and comfortable unit.
    All these assumptions are perfectly OK for most games,
    for more general sound programs... not necessarily.
    If you need more flexibility, you should write your own sound
    manager (or heavily extend this), using ALUtils and
    ALSourceAllocator units directly. }
  TGameSoundEngine = class(TALSoundEngine)
  private
    FSoundImportanceNames: TStringList;
    FSoundNames: TStringList;
    FSoundsXmlFileName: string;

    SoundInfos: TDynSoundInfoArray;

    { This is the only allowed instance of TMusicPlayer class,
      created and destroyed in this class create/destroy. }
    FMusicPlayer: TMusicPlayer;
  public
    constructor Create;
    destructor Destroy; override;

    { In addition to initializing OpenAL context, this also loads sound files. }
    procedure ALContextOpen(const WasParam_NoSound: boolean); override;
    procedure ALContextClose; override;

    { The XML file that contains description of your sounds.
      See @code(examples/sample_sounds.xml) file for a heavily
      commented example.

      It's crucial that you create such file, and eventually adjust
      this property before calling ReadSoundInfos (or ALContextOpen,
      that always calls ReadSoundInfos).

      By default (in our constryctor) this is initialized to
      @code(ProgramDataPath + 'data' +
        PathDelim + 'sounds' + PathDelim + 'index.xml')
      which may be good location for most games. }
    property SoundsXmlFileName: string
      read FSoundsXmlFileName write FSoundsXmlFileName;

    { This is a list of sound names used by your game.
      Each sound has a unique name, used to identify sound in
      sounds/index.xml file and for SoundFromName function.
      These names are stored here.

      At the beginning, this list always contains exactly one item: empty string.
      This is a special "sound type" that has index 0 (should be always
      expressed as TSoundType value stNone) and name ''.
      stNone is a special sound as it actually means "no sound" in many cases.

      You can (and should !) fill this array with all sound names
      your game is using @bold(before calling ALContextOpen)
      (or ReadSoundInfos, but ReadSoundInfos is usually called
      for the first time by ALContextOpen).

      TODO: in the future this may be automatically filled when
      ReadSoundInfos is called. For now, ReadSoundInfos just
      read sounds information for all sounds mentioned here --- in the future,
      ReadSoundInfos may also just fill this list. }
    property SoundNames: TStringList read FSoundNames;

    { Return sound with given name.
      Available names are given in SoundNames,
      and inside ../data/sounds/index.xml.
      Always for SoundName = '' it will return stNone.
      @raises Exception On invalid SoundName }
    function SoundFromName(const SoundName: string): TSoundType;

    { Play given sound. This should be used to play sounds
      that are not spatial actually, i.e. have no place in 3D space.

      Returns used TALAllocatedSource (or nil if none was available).
      You don't have to do anything with this returned TALAllocatedSource. }
    function Sound(SoundType: TSoundType;
      const Looping: boolean = false): TALAllocatedSource;

    { Play given sound at appropriate position in 3D space.

      Returns used TALAllocatedSource (or nil if none was available).
      You don't have to do anything with this returned TALAllocatedSource.

      @noAutoLinkHere }
    function Sound3d(SoundType: TSoundType;
      const Position: TVector3Single;
      const Looping: boolean = false): TALAllocatedSource; overload;

    property Volume default DefaultGameVolume;

    { Sound importance names and values.
      Each item is a name (as a string) and a value (that is stored in Objects
      property of the item as a pointer; add new importances by
      AddSoundImportanceName for comfort).

      These can be used within sounds.xml file.
      Before using ALContextOpen, you can fill this list with values.
      Initially, it contains only the 'max' value associated with
      MaxSoundImportance. }
    property SoundImportanceNames: TStringList read FSoundImportanceNames;

    procedure AddSoundImportanceName(const Name: string; Importance: Integer);

    procedure ReadSoundInfos;

    property MusicPlayer: TMusicPlayer read FMusicPlayer;

    { These methods load/save into config file some sound properties.
      Namely: sound/music volume, min/max allocated sounds,
      and current ALCDevice. ALCDevice is technically declared in
      another unit, ALUtils, but still this is probably the best place
      to save/load it.

      Everything is loaded/saved under the path sound/ inside ConfigFile.

      @groupBegin }
    procedure LoadFromConfig(ConfigFile: TKamXMLConfig);
    procedure SaveToConfig(ConfigFile: TKamXMLConfig);
    { @groupEnd }
  end;

  { Music player. Objects of this class should be created only internally by
    TGameSoundEngine. }
  TMusicPlayer = class
  private
    { Engine that owns this music player. }
    FEngine: TGameSoundEngine;

    FPlayedSound: TSoundType;
    procedure SetPlayedSound(const Value: TSoundType);
  private
    { This is nil if we don't play music right now
      (because OpenAL is not initialized, or PlayedSound = stNone,
      or PlayerSound.FileName = '' (sound not existing)). }
    FAllocatedSource: TALAllocatedSource;

    procedure AllocatedSourceUsingEnd(Sender: TALAllocatedSource);

    { Called by ALContextOpen. You should check here if
      PlayedSound <> stNone and eventually initialize FAllocatedSource. }
    procedure AllocateSource;
  private
    FMusicVolume: Single;
    function GetMusicVolume: Single;
    procedure SetMusicVolume(const Value: Single);
  public
    constructor Create(AnEngine: TGameSoundEngine);
    destructor Destroy; override;

    { Currently played music.
      Set to stNone to stop playing music.
      Set to anything else to play that music.

      Changing value of this property (when both the old and new values
      are <> stNone and are different) restarts playing the music. }
    property PlayedSound: TSoundType read FPlayedSound write SetPlayedSound
      default stNone;

    { Music volume. This must always be within 0..1 range.
      0.0 means that there is no music (this case should be optimized).}
    property MusicVolume: Single read GetMusicVolume write SetMusicVolume
      default DefaultMusicVolume;
  end;

{$undef read_interface}

implementation

uses ProgressUnit, ALUtils,
  KambiFilesUtils, DOM, KambiXMLRead, KambiXMLUtils,
  SoundFile, VorbisFile, KambiStringUtils, KambiTimeUtils, KambiLog;

{$define read_implementation}
{$I dynarray_1.inc}

{ TGameSoundEngine ----------------------------------------------------------- }

constructor TGameSoundEngine.Create;
begin
  inherited;

  { Sound importance names and sound names are case-sensitive because
    XML traditionally is. Maybe in the future I'll relax this,
    there's no definite reason actually to not let them ignore case. }

  FSoundImportanceNames := TStringList.Create;
  FSoundImportanceNames.CaseSensitive := true;
  AddSoundImportanceName('max', MaxSoundImportance);

  Volume := DefaultGameVolume;

  FSoundNames := TStringList.Create;
  FSoundNames.CaseSensitive := true;
  FSoundNames.Append(''); { stNone entry }

  SoundInfos := TDynSoundInfoArray.Create;

  FMusicPlayer := TMusicPlayer.Create(Self);

  FSoundsXmlFileName := ProgramDataPath + 'data' +
    PathDelim + 'sounds' + PathDelim + 'index.xml';
end;

destructor TGameSoundEngine.Destroy;
begin
  FreeAndNil(FSoundImportanceNames);
  FreeAndNil(FSoundNames);
  FreeAndNil(SoundInfos);
  FreeAndNil(FMusicPlayer);
  inherited;
end;

procedure TGameSoundEngine.ALContextOpen(const WasParam_NoSound: boolean);
var
  ST: TSoundType;
begin
  inherited;
  if ALActive then
  begin
    ReadSoundInfos;

    Progress.Init(SoundInfos.Count - 1, 'Loading sounds');
    try
      { We do progress to "SoundInfos.Count - 1" because we start
        iterating from ST = 1 because ST = 0 = stNone never exists. }
      Assert(SoundInfos.Items[stNone].FileName = '');
      for ST := 1 to SoundInfos.High do
      begin
        if SoundInfos.Items[ST].FileName <> '' then
        begin
          SoundInfos.Items[ST].Buffer := LoadBuffer(
              SoundInfos.Items[ST].FileName);
        end;
        Progress.Step;
      end;
    finally Progress.Fini; end;

    MusicPlayer.AllocateSource;
  end;
end;

procedure TGameSoundEngine.ALContextClose;
var
  ST: TSoundType;
begin
  if ALActive then
  begin
    StopAllSources;
    for ST := 0 to SoundInfos.High do
      FreeBuffer(SoundInfos.Items[ST].Buffer);
  end;
  inherited;
end;

function TGameSoundEngine.Sound(SoundType: TSoundType;
  const Looping: boolean): TALAllocatedSource;
begin
  Result := PlaySound(
    SoundInfos.Items[SoundType].Buffer, false, Looping,
    SoundInfos.Items[SoundType].DefaultImportance,
    SoundInfos.Items[SoundType].Gain,
    SoundInfos.Items[SoundType].MinGain,
    SoundInfos.Items[SoundType].MaxGain,
    ZeroVector3Single);
end;

function TGameSoundEngine.Sound3d(SoundType: TSoundType;
  const Position: TVector3Single;
  const Looping: boolean): TALAllocatedSource;
begin
  Result := PlaySound(
    SoundInfos.Items[SoundType].Buffer, true, Looping,
    SoundInfos.Items[SoundType].DefaultImportance,
    SoundInfos.Items[SoundType].Gain,
    SoundInfos.Items[SoundType].MinGain,
    SoundInfos.Items[SoundType].MaxGain,
    Position);
end;

procedure TGameSoundEngine.ReadSoundInfos;
var
  ST: TSoundType;
  SoundConfig: TXMLDocument;
  SoundNode: TDOMNode;
  SoundElement: TDOMElement;
  SoundElements: TDOMNodeList;
  S: string;
  I, SoundImportanceIndex: Integer;
  SoundsXmlPath: string;
begin
  { This must be an absolute path, since SoundInfos[].FileName should be
    absolute (to not depend on the current dir when loading sound files. }
  SoundsXmlPath := ExtractFilePath(ExpandFileName(SoundsXmlFileName));

  try
    { ReadXMLFile always sets TXMLDocument param (possibly to nil),
      even in case of exception. So place it inside try..finally. }
    ReadXMLFile(SoundConfig, SoundsXmlFileName);

    Check(SoundConfig.DocumentElement.TagName = 'sounds',
      'Root node of sounds/index.xml must be <sounds>');

    { Init all SoundInfos to default values }
    SoundInfos.Count := SoundNames.Count;
    { stNone has specific info: FileName is '', Buffer is 0, rest doesn't matter }
    SoundInfos.Items[stNone].FileName := '';
    SoundInfos.Items[stNone].Buffer := 0;
    { initialize other than stNone sounds }
    for ST := 1 to SoundInfos.High do
    begin
      SoundInfos.Items[ST].FileName :=
        CombinePaths(SoundsXmlPath, SoundNames[ST] + '.wav');
      SoundInfos.Items[ST].Gain := 1;
      SoundInfos.Items[ST].MinGain := 0;
      SoundInfos.Items[ST].MaxGain := 1;
      SoundInfos.Items[ST].DefaultImportance := MaxSoundImportance;
      SoundInfos.Items[ST].Buffer := 0; {< initially, will be loaded later }
    end;

    SoundElements := SoundConfig.DocumentElement.ChildNodes;
    try
      for I := 0 to SoundElements.Count - 1 do
      begin
        SoundNode := SoundElements.Item[I];
        if SoundNode.NodeType = ELEMENT_NODE then
        begin
          SoundElement := SoundNode as TDOMElement;
          Check(SoundElement.TagName = 'sound',
            'Each child of sounds/index.xml root node must be the <sound> element');

          ST := SoundFromName(SoundElement.GetAttribute('name'));

          { I retrieve FileNameNode using DOMGetAttribute
            (that internally uses SoundElement.Attributes.GetNamedItem),
            because I have to distinguish between the case when file_name
            attribute is not present (in this case FileName is left as it was)
            and when it's present as set to empty string.
            Standard SoundElement.GetAttribute wouldn't allow me this. }
          if DOMGetAttribute(SoundElement, 'file_name',
            SoundInfos.Items[ST].FileName) and
            (SoundInfos.Items[ST].FileName <> '') then
            { Make FileName absolute, using SoundsXmlPath, if non-empty FileName
              was specified in XML file. }
            SoundInfos.Items[ST].FileName := CombinePaths(
              SoundsXmlPath,
              SoundInfos.Items[ST].FileName);

          DOMGetSingleAttribute(SoundElement, 'gain', SoundInfos.Items[ST].Gain);
          DOMGetSingleAttribute(SoundElement, 'min_gain', SoundInfos.Items[ST].MinGain);
          DOMGetSingleAttribute(SoundElement, 'max_gain', SoundInfos.Items[ST].MaxGain);

          { MaxGain is max 1. Although some OpenAL implementations allow > 1,
            Windows impl (from Creative) doesn't. For consistent results,
            we don't allow it anywhere. }
          if SoundInfos.Items[ST].MaxGain > 1 then
            SoundInfos.Items[ST].MaxGain := 1;

          if DOMGetAttribute(SoundElement, 'default_importance', S) then
          begin
            SoundImportanceIndex := SoundImportanceNames.IndexOf(S);
            if SoundImportanceIndex = -1 then
              SoundInfos.Items[ST].DefaultImportance := StrToInt(S) else
              SoundInfos.Items[ST].DefaultImportance :=
                PtrUInt(SoundImportanceNames.Objects[SoundImportanceIndex]);
          end;
        end;
      end;
    finally FreeChildNodes(SoundElements); end;
  finally
    FreeAndNil(SoundConfig);
  end;
end;

function TGameSoundEngine.SoundFromName(const SoundName: string): TSoundType;
var
  Index: Integer;
begin
  Index := SoundNames.IndexOf(SoundName);
  if Index = -1 then
    raise Exception.CreateFmt('Unknown sound name "%s"', [SoundName]) else
    Result := Index;
end;

procedure TGameSoundEngine.AddSoundImportanceName(const Name: string;
  Importance: Integer);
begin
  FSoundImportanceNames.AddObject(Name, TObject(Pointer(PtrUInt(Importance))));
end;

procedure TGameSoundEngine.LoadFromConfig(ConfigFile: TKamXMLConfig);
begin
  Volume := ConfigFile.GetFloat('sound/volume', DefaultGameVolume);
  MusicPlayer.MusicVolume := ConfigFile.GetFloat('sound/music/volume',
    DefaultMusicVolume);
  ALMinAllocatedSources := ConfigFile.GetValue(
    'sound/allocated_sources/min', DefaultALMinAllocatedSources);
  ALMaxAllocatedSources := ConfigFile.GetValue(
    'sound/allocated_sources/max', DefaultALMaxAllocatedSources);

  ALCDevice := ConfigFile.GetValue('sound/device', BestALCDevice);
end;

procedure TGameSoundEngine.SaveToConfig(ConfigFile: TKamXMLConfig);
begin
  ConfigFile.SetDeleteFloat('sound/volume', Volume, DefaultGameVolume);
  { This may be called from destructors and the like, so better check
    that MusicPlayer is not nil. }
  if MusicPlayer <> nil then
    ConfigFile.SetDeleteFloat('sound/music/volume',
      MusicPlayer.MusicVolume, DefaultMusicVolume);
  ConfigFile.SetDeleteValue('sound/allocated_sources/min',
    ALMinAllocatedSources, DefaultALMinAllocatedSources);
  ConfigFile.SetDeleteValue('sound/allocated_sources/max',
    ALMaxAllocatedSources, DefaultALMaxAllocatedSources);
  ConfigFile.SetDeleteValue('sound/device', ALCDevice, BestALCDevice);
end;

{ TMusicPlayer --------------------------------------------------------------- }

constructor TMusicPlayer.Create(AnEngine: TGameSoundEngine);
begin
  inherited Create;
  FMusicVolume := DefaultMusicVolume;
  FEngine := AnEngine;
end;

destructor TMusicPlayer.Destroy;
begin
  if FAllocatedSource <> nil then
    FAllocatedSource.DoUsingEnd;
  inherited;
end;

procedure TMusicPlayer.AllocateSource;
begin
  FAllocatedSource := FEngine.PlaySound(
    FEngine.SoundInfos.Items[PlayedSound].Buffer, false, true,
    MaxSoundImportance,
    MusicVolume * FEngine.SoundInfos.Items[PlayedSound].Gain, 0, 1,
    ZeroVector3Single);

  if FAllocatedSource <> nil then
    FAllocatedSource.OnUsingEnd :=
      {$ifdef FPC_OBJFPC} @ {$endif} AllocatedSourceUsingEnd;
end;

procedure TMusicPlayer.SetPlayedSound(const Value: TSoundType);
begin
  if Value <> FPlayedSound then
  begin
    if FAllocatedSource <> nil then
    begin
      FAllocatedSource.DoUsingEnd;
      { AllocatedSourceUsingEnd should set FAllocatedSource to nil. }
      Assert(FAllocatedSource = nil);
    end;

    FPlayedSound := Value;

    AllocateSource;
  end;
end;

procedure TMusicPlayer.AllocatedSourceUsingEnd(Sender: TALAllocatedSource);
begin
  Assert(Sender = FAllocatedSource);
  FAllocatedSource.OnUsingEnd := nil;
  FAllocatedSource := nil;
end;

function TMusicPlayer.GetMusicVolume: Single;
begin
  Result := FMusicVolume;
end;

procedure TMusicPlayer.SetMusicVolume(const Value: Single);
begin
  if Value <> FMusicVolume then
  begin
    FMusicVolume := Value;
    if FAllocatedSource <> nil then
      alSourcef(FAllocatedSource.ALSource,
        AL_GAIN,
        MusicVolume * FEngine.SoundInfos.Items[PlayedSound].Gain);
  end;
end;

end.
