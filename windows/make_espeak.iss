; This is the script for "Inno Setup 5" to create the setup_espeak.exe installer for Windows

[Setup]
AppName=eSpeak
AppVerName=eSpeak version 1.26
DefaultDirName={pf}\eSpeak
DefaultGroupName=eSpeak
OutputBaseFilename=setup_espeak
Compression=lzma
SolidCompression=yes

[InstallDelete]
Type: files; Name: "{app}\espeak.dll"

[Dirs]
Name: "{app}\espeak-data\soundicons"
Name: "{app}\espeak-data\mbrola"

[Files]
Source: "espeak_sapi.dll"; DestDir: "{app}"; Flags: regserver promptifolder replacesameversion
Source: "TTSApp.exe"; DestDir:"{app}"
Source: "espeak-data\*"; DestDir: "{app}\espeak-data"; Flags: recursesubdirs
Source: "dictsource2\*"; DestDir: "{app}\dictsource"
Source: "docs\*"; DestDir: "{app}\docs"; Flags: recursesubdirs
Source: "command_line\*"; DestDir: "{app}\command_line"
Source: "Readme.txt"; DestDir: "{app}"; Flags: isreadme

[Registry]
Root: HKLM; Subkey: "Software\Microsoft\Speech\Voices\Tokens\eSpeak"; Flags: deletekey uninsdeletekey
Root: HKLM; Subkey: "Software\Microsoft\Speech\Voices\Tokens\eSpeak_1"; Flags: deletekey uninsdeletekey
Root: HKLM; Subkey: "Software\Microsoft\Speech\Voices\Tokens\eSpeak_2"; Flags: deletekey uninsdeletekey
Root: HKLM; Subkey: "Software\Microsoft\Speech\Voices\Tokens\eSpeak_3"; Flags: deletekey uninsdeletekey
Root: HKLM; Subkey: "Software\Microsoft\Speech\Voices\Tokens\eSpeak_4"; Flags: deletekey uninsdeletekey
Root: HKLM; Subkey: "Software\Microsoft\Speech\Voices\Tokens\eSpeak_5"; Flags: deletekey uninsdeletekey
Root: HKLM; Subkey: "Software\Microsoft\Speech\PhoneConverters\Tokens\eSpeak"; Flags: deletekey uninsdeletekey



[Code]
var
  UILanguage: Integer;
  UIVoice: String;
  Page: TInputQueryWizardPage;

const
  sEspeak = 'eSpeak-';
  RegVoice1 = 'Software\Microsoft\Speech\Voices\Tokens\eSpeak';
  RegPhConv = 'Software\Microsoft\Speech\PhoneConverters\Tokens';


function VoiceFromLanguage(language: Integer): String;
var
  lang_main: Integer;

begin
  lang_main := language and $3ff;
  Result := 'af';

  // translation from microsoft codes to language codes
  case lang_main of
  $05: Result := 'cs';
  $07: Result := 'de';
  $08: Result := 'el';
  $0a: Result := 'es';
  $0b: Result := 'fi';
  $0c: Result := 'fr';
  $0e: Result := 'hu';
  $10: Result := 'it';
  $13: Result := 'nl';
  $14: Result := 'no';
  $15: Result := 'pl';
  $16: Result := 'pt';
  $18: Result := 'ro';
  $19: Result := 'ru';
  $1a: Result := 'hr';
  $1b: Result := 'sk';
  $1d: Result := 'sv';
  $2a: Result := 'vi';
  $36: Result := 'af';
  $39: Result := 'hi';
  $41: Result := 'sw';
  $52: Result := 'cy';
  end;
end;


function LanguageFromVoice(voice: String): String;
var
  value: Integer;
  lang1: String;
  len: Integer;
begin
  value := $409;   // default en-us

  lang1 := Copy(voice,0,2);
  if lang1 = 'mb' then
  begin
    lang1 := Copy(voice,3,3);
    len := Length(voice);
    if len > 8 then
      lang1 := Copy(voice,8,6);  // eg. mb-de4-en, return 'en'
  end;
  
  case lang1 of
  'af': value := $436;
  'cs': value := $405;
  'cy': value := $452;
  'de': value := $407;
  'el': value := $408;
  'en': value := $409;
  'es': value := $40a;
  'fi': value := $40b;
  'fr': value := $40c;
  'hi': value := $439;
  'hr': value := $41a;
  'hu': value := $40e;
  'is': value := $40f;
  'it': value := $410;
  'nl': value := $413;
  'no': value := $414;
  'pl': value := $415;
  'pt': value := $416;
  'ro': value := $418;
  'ru': value := $419;
  'sk': value := $41b;
  'sv': value := $41d;
  'sw': value := $441;
  'vi': value := $42a;
  // mbrola voices
  '-af': value := $436;
  '-br': value := $416;
  '-ca': value := $c0c;
  '-cr': value := $41a;
  '-cz': value := $405;
  '-de': value := $407;
  '-en': value := $809;
  '-es': value := $40a;
  '-fr': value := $40c;
  '-gr': value := $408;
  '-hu': value := $40e;
  '-ic': value := $40f;
  '-in': value := $439;
  '-it': value := $410;
  '-mx': value := $80a;
  '-nl': value := $413;
  '-pl': value := $415;
  '-pt': value := $816;
  '-ro': value := $418;
  '-sw': value := $41d;
  '-us': value := $409;
  '-vz': value := $200a;
  end;

  // check for specific voices
  case voice of
  'pt-pt': value := $816;
  end;
  
  Result := Format('%X',[value]);
end;


// is the language number already in a PhoneConvertor ?
function CheckPhoneConvertors(Lcode: String): Integer;
var
  Convertors: TArrayOfString;
  ix: Integer;
  len: Integer;
  s1: String;
  s2: String;
  sLangs: String;
begin
  Result := 0;
  len := Length(Lcode);
  if RegGetSubkeyNames(HKEY_LOCAL_MACHINE, RegPhConv, Convertors) then
  begin
    for ix := 0 to GetArrayLength(Convertors) - 1 do
    begin
      s1 := RegPhConv + '\' + Convertors[ix] + '\Attributes';
      if RegQueryStringValue(HKEY_LOCAL_MACHINE, s1, 'Language', sLangs) then
      begin
        s2 := Copy(sLangs, 1, len);
        if s2 = Lcode then
          Result := 1;
        if sLangs = Lcode then
          Result := 1;
        if Pos(';' + Lcode, sLangs) > 0 then
          Result := 1;
      end;
    end;
  end;
end;

// ensure the language number is included in a PhoneConvertor
procedure SetPhoneConvertor(Lcode: String);
var
  done: Boolean;
  s1: String;
  sLangs: String;
begin
  if CheckPhoneConvertors(Lcode) = 0 then
  begin
    done := False;
    s1 := RegPhConv + '\Universal\Attributes';
    if RegQueryStringValue(HKEY_LOCAL_MACHINE, s1, 'Language', sLangs) then
    begin
      done := RegWriteStringValue(HKEY_LOCAL_MACHINE, s1, 'Language', Lcode + ';' + sLangs);
    end;

    if done = False then
    begin
      s1 := RegPhConv + '\eSpeak\Attributes';
      if RegQueryStringValue(HKEY_LOCAL_MACHINE, s1, 'Language', sLangs) = False then
      begin
        // add 'eSpeak' dummy PhoneConvertor
        RegWriteStringValue(HKEY_LOCAL_MACHINE, RegPhConv + '\eSpeak', 'CLSID','{9185F743-1143-4C28-86B5-BFF14F20E5C8}');
        RegWriteStringValue(HKEY_LOCAL_MACHINE, RegPhConv + '\eSpeak', 'PhoneMap','- 0001');
        RegWriteStringValue(HKEY_LOCAL_MACHINE, s1, 'Language','');
      end;
      
      if RegQueryStringValue(HKEY_LOCAL_MACHINE, s1, 'Language', sLangs) then
      begin
        done := RegWriteStringValue(HKEY_LOCAL_MACHINE, s1, 'Language', Lcode + ';' + sLangs);
      end;
    end;
  end;
end;


procedure SetupVoice(Voice, Lcode: String; Index: Integer);
var
  RegVoice2: String;
  RegVoice2a: String;
  VoiceUC: String;
  
begin
  if Index = 0 then
    RegVoice2 := RegVoice1
  else
    RegVoice2 := RegVoice1 + Format('_%d',[Index]);
    
  RegVoice2a := RegVoice2 + '\Attributes';

  if Voice = 'default' then
    VoiceUC := 'default'
  else
    VoiceUC := Uppercase(Voice);
    
  RegWriteStringValue(HKEY_LOCAL_MACHINE,RegVoice2,'',sEspeak+VoiceUC);
  RegWriteStringValue(HKEY_LOCAL_MACHINE,RegVoice2,'CLSID','{BE985C8D-BE32-4A22-AA93-55C16A6D1D91}');
  RegWriteStringValue(HKEY_LOCAL_MACHINE,RegVoice2,'Path',ExpandConstant('{app}'));
  RegWriteStringValue(HKEY_LOCAL_MACHINE,RegVoice2,'VoiceName',Voice);

  RegWriteStringValue(HKEY_LOCAL_MACHINE,RegVoice2a,'Name',sEspeak+Voice);
  RegWriteStringValue(HKEY_LOCAL_MACHINE,RegVoice2a,'Gender','Male');
  RegWriteStringValue(HKEY_LOCAL_MACHINE,RegVoice2a,'Age','Adult');
  RegWriteStringValue(HKEY_LOCAL_MACHINE,RegVoice2a,'Language',Lcode);
  RegWriteStringValue(HKEY_LOCAL_MACHINE,RegVoice2a,'Vendor','Jonathan Duddington');
  
  SetPhoneConvertor(Lcode);
end;



procedure CurStepChanged(CurStep: TSetupStep);
var
  ix: Integer;
begin
  if CurStep = ssPostInstall then
  begin

    for ix := 0 to 5 do begin
      if Page.Values[ix] <> '' then
       SetUpVoice(Page.Values[ix],LanguageFromVoice(Page.Values[ix]),ix);
    end;
  end;
end;


procedure InitializeWizard;
var
  lang: String;
begin
  // Create the language selection page
  lang := ActiveLanguage;
  Page := CreateInputQueryPage(wpSelectDir,
  'Select which voices to install', 'or press Enter to accept defaults',
  'Enter voice names, eg: (for Portuguese)   pt,  or with a variant, eg: pt+13');
  
  // Add items (False means it's not a password edit)
  Page.Add('', False);
  Page.Add('', False);
  Page.Add('', False);
  Page.Add('', False);
  Page.Add('', False);
  Page.Add('', False);

  UILanguage := GetUILanguage;
  UIVoice := VoiceFromLanguage(UILanguage);

  // Set initial values (optional)
  Page.Values[0] := 'en';
  Page.Values[1] := UIVoice;
  Page.Values[2] := 'en-r';

end;



