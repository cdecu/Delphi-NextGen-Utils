unit rmxFastXML;

interface

{$M-}

uses
  System.Types, System.RTLConsts,
  System.SysUtils, System.DateUtils, System.Classes, System.Generics.Collections,
  System.IniFiles;

type
  TrmxFastXML = class;
  EFastXMLError = class(Exception);
  TrmxFastXMLElem = class;
  TrmxFastXMLElems = class;
  TrmxFastXMLProps = class;
  TrmxFastXMLElemsProlog = class;
  TrmxFastXMLElemComment = class;
  TrmxFastXMLElemClassic = class;
  TrmxFastXMLElemCData = class;
  TrmxFastXMLElemDocType = class;
  TrmxFastXMLElemText = class;
  TrmxFastXMLElemHeader = class;
  TrmxFastXMLElemProcessingInstruction = class;

  TrmxFastXMLOptions = set of (
    sxoAutoCreate,
    sxoAutoIndent,
    sxoAutoEncodeValue,
    sxoAutoEncodeEntity,
    sxoDoNotSaveProlog,
    sxoTrimPrecedingTextWhitespace,
    sxoTrimFollowingTextWhitespace,
    sxoKeepWhitespace,
    sxoDoNotSaveBOM
    );

  TrmxFastXMLEncodeEvent = procedure(Sender: TObject; var Value: string) of object;
  TrmxFastXMLEncodeStreamEvent = procedure(Sender: TObject; InStream, OutStream: TStream) of object;


  ///	<summary>
  ///	  Base XML Item Class
  ///	</summary>
  TrmxFastXMLBaseItem = class(TObject)
  private
    FName     : string;
    FValue    : string;
    FNameSpace: string;

    function GetFullName:string;
    function GetBoolValue: Boolean;
    procedure SetBoolValue(const Val: Boolean);
    function GetIntValue: Int64;
    procedure SetIntValue(const Val: Int64);
    function GetXMLFloatValue: Extended;
    procedure SetXMLFloatValue(const Val: Extended);
    function GetXMLDateValue: TDateTime;
    procedure SetXMLDateValue(const Val: TDateTime);
    function GetXMLTimeValue: TDateTime;
    procedure SetXMLTimeValue(const Val: TDateTime);
    function GetXMLDateTimeValue: TDateTime;
    procedure SetXMLDateTimeValue(const Val: TDateTime);

  protected
    procedure SetName(const Value: string); virtual;

  public
    constructor Create; overload; virtual;
    constructor Create(const AName: string); overload;
    constructor Create(const AName, AValue: string); overload;

    property Name        : string     read FName               write SetName;
    property NameSpace   : string     read FNameSpace          write FNameSpace;
    property FullName    : string     read GetFullName;
    property Value       : string     read FValue              write FValue;
    property IntValue    : Int64      read GetIntValue         write SetIntValue;
    property BoolValue   : Boolean    read GetBoolValue        write SetBoolValue;
    property XMLFloat    : Extended   read GetXMLFloatValue    write SetXMLFloatValue;
    property XMLDate     : TDateTime  read GetXMLDateValue     write SetXMLDateValue;
    property XMLTime     : TDateTime  read GetXMLTimeValue     write SetXMLTimeValue;
    property XMLDateTime : TDateTime  read GetXMLDateTimeValue write SetXMLDateTimeValue;
  end;

  TrmxFastXMLProp = class(TrmxFastXMLBaseItem)
  private
    FParent: TrmxFastXMLElem;
  protected
    function GetSimpleXML: TrmxFastXML;
    procedure SetName(const Value: string); override;
  public
    constructor Create(AParent: TrmxFastXMLElem; const AName, AValue: string);
    procedure SaveToStringStream(Const StringStream: TStringStream);
    property Parent: TrmxFastXMLElem read FParent;
    property SimpleXML: TrmxFastXML read GetSimpleXML;
  end;

  TrmxFastXMLPropsEnumerator = class
  private
    FIndex: Integer;
    FList: TrmxFastXMLProps;
  public
    constructor Create(AList: TrmxFastXMLProps);
    function GetCurrent: TrmxFastXMLProp; inline;
    function MoveNext: Boolean;
    property Current: TrmxFastXMLProp read GetCurrent;
  end;

  TrmxFastXMLProps = class(TObject)
  private
    FProperties: TStringList;
    FParent: TrmxFastXMLElem;
    function GetCount: Integer;
    function GetItemNamedDefault(const Name, Default: string): TrmxFastXMLProp;
    function GetItemNamed(const Name: string): TrmxFastXMLProp;

  protected
    function GetSimpleXML: TrmxFastXML;
    function GetItem(const Index: Integer): TrmxFastXMLProp;
    procedure DoItemRename(Value: TrmxFastXMLProp; const Name: string);
    procedure Error(const S: string);
    procedure FmtError(const S: string; const Args: array of const);
    procedure InternalLoad;

  public
    constructor Create(AParent: TrmxFastXMLElem);
    destructor Destroy; override;

    procedure Clear; virtual;

    function Add(const Name, Value: string): TrmxFastXMLProp; overload;
    function Add(const Name: string; const Value: Int64): TrmxFastXMLProp; overload;
    function Add(const Name: string; const Value: Boolean): TrmxFastXMLProp; overload;
    function Insert(const Index: Integer; const Name, Value: string): TrmxFastXMLProp; overload;
    function Insert(const Index: Integer; const Name: string; const Value: Int64): TrmxFastXMLProp; overload;
    function Insert(const Index: Integer; const Name: string; const Value: Boolean): TrmxFastXMLProp; overload;
    procedure Delete(const Index: Integer); overload;
    procedure Delete(const Name: string); overload;

    function IndexOf(const aName: string): Integer; overload;
    function PropertyByName(const Name: string;Out p: TrmxFastXMLProp):Boolean;

    function GetEnumerator: TrmxFastXMLPropsEnumerator;

    function Value(const Name: string; const Default: string = ''): string;
    function IntValue(const Name: string; const Default: Int64 = -1): Int64;
    function BoolValue(const Name: string; Default: Boolean = True): Boolean;
    function XMLFloat(const Name: string; const Default: Extended = 0): Extended;
    procedure SaveToStringStream(Const StringStream: TStringStream);

    property Item[const Index: Integer]: TrmxFastXMLProp read GetItem; default;
    property ItemNamed[const Name: string]: TrmxFastXMLProp read GetItemNamed;
    property Count: Integer read GetCount;
    property Parent: TrmxFastXMLElem read FParent;
  end;

  TrmxFastXMLElemsPrologEnumerator = class
  private
    FIndex: Integer;
    FList: TrmxFastXMLElemsProlog;
  public
    constructor Create(AList: TrmxFastXMLElemsProlog);
    function GetCurrent: TrmxFastXMLElem; inline;
    function MoveNext: Boolean;
    property Current: TrmxFastXMLElem read GetCurrent;
  end;

  TrmxFastXMLElemsProlog = class(TObject)
  private
    FSimpleXML: TrmxFastXML;
    FElems: TObjectList<TrmxFastXMLElem>;
    function GetCount: Integer;
    function GetItem(const Index: Integer): TrmxFastXMLElem;
    function GetEncoding: string;
    function GetStandAlone: Boolean;
    function GetVersion: string;
    procedure SetEncoding(const Value: string);
    procedure SetStandAlone(const Value: Boolean);
    procedure SetVersion(const Value: string);

  protected
    function FindHeader: TrmxFastXMLElem;
    procedure Error(const S: string);
    procedure FmtError(const S: string; const Args: array of const);
    procedure InternalLoad;

  public
    constructor Create(ASimpleXML: TrmxFastXML);
    destructor Destroy; override;
    function AddComment(const AValue: string): TrmxFastXMLElemComment;
    function AddDocType(const AValue: string): TrmxFastXMLElemDocType;
    procedure Clear;
    function AddStyleSheet(const AType, AHRef: string): TrmxFastXMLElemProcessingInstruction;
    function AddMSOApplication(const AProgId : string): TrmxFastXMLElemProcessingInstruction;
    procedure SaveToStringStream(Const StringStream: TStringStream);
    function GetEnumerator: TrmxFastXMLElemsPrologEnumerator;
    property Item[const Index: Integer]: TrmxFastXMLElem read GetItem; default;
    property Count: Integer read GetCount;
    property Encoding: string read GetEncoding write SetEncoding;
    property SimpleXML: TrmxFastXML read FSimpleXML;
    property StandAlone: Boolean read GetStandAlone write SetStandAlone;
    property Version: string read GetVersion write SetVersion;
  end;

  TrmxFastXMLElemsEnumerator = class
  private
    FIndex: Integer;
    FList: TrmxFastXMLElems;
  public
    constructor Create(AList: TrmxFastXMLElems);
    function GetCurrent: TrmxFastXMLElem; inline;
    function MoveNext: Boolean;
    property Current: TrmxFastXMLElem read GetCurrent;
  end;

  TrmxFastXMLElemCompare = function(Elems: TrmxFastXMLElems; Index1, Index2: Integer): Integer of object;

  TrmxFastXMLElems = class(TObject)
  private
    FParent: TrmxFastXMLElem;
    FElems: TObjectList<TrmxFastXMLElem>;

    function GetCount: Integer;

    function GetItemNamed(const aName: string): TrmxFastXMLElem;
    function GetItemNamedDef(const aName: string;const DefaultVal: string): TrmxFastXMLElem;

    function GetItemNamedAsStr(const aName: string):String;
    function GetItemNamedAsStrDef(const aName: string;const DefaultVal: string = ''): String;
    function GetItemNamedAsInt(const aName: string):Integer;
    function GetItemNamedAsIntDef(const aName: string;const DefaultVal: Integer = 0): Integer;
    function GetItemNamedAsXMLFloat(const aName: string):Extended;
    function GetItemNamedAsXMLFloatDef(const aName: string;const DefaultVal: Extended = 0): Extended;
    function GetItemNamedAsXMLDate(const aName: string):TDateTime;
    function GetItemNamedAsXMLDateDef(const aName: string;const DefaultVal: TDateTime = 0): TDateTime;
    function GetItemNamedAsXMLTime(const aName: string):TDateTime;
    function GetItemNamedAsXMLTimeDef(const aName: string;const DefaultVal: TDateTime = 0): TDateTime;
    function GetItemNamedAsXMLDateTime(const aName: string):TDateTime;
    function GetItemNamedAsXMLDateTimeDef(const aName: string;const DefaultVal: TDateTime = 0): TDateTime;

  protected
    function GetItem(const Index: Integer): TrmxFastXMLElem;
    procedure AddChild(const Value: TrmxFastXMLElem);
    procedure AddChildFirst(const Value: TrmxFastXMLElem);
    procedure InsertChild(const Value: TrmxFastXMLElem; Index: Integer);
    procedure CreateElems;
    procedure InternalLoad;
    function SimpleCompare(Elems: TrmxFastXMLElems; Index1, Index2: Integer): Integer;

  public
    constructor Create(AParent: TrmxFastXMLElem);
    destructor Destroy; override;

    // Use notify to indicate to a list that the given element is removed
    // from the list so that it doesn't delete it as well as the one
    // that insert it in itself. This method is automatically called
    // by AddChild and AddChildFirst if the Container property of the
    // given element is set.
    procedure Notify(Const Value: TrmxFastXMLElem;Const Operation: TOperation);

    function Add(const Name: string): TrmxFastXMLElemClassic; overload;
    function Add(const Name, Value: string): TrmxFastXMLElemClassic; overload;
    function Add(const Name: string; const Value: Int64): TrmxFastXMLElemClassic; overload;
    function Add(const Name: string; const Value: Boolean): TrmxFastXMLElemClassic; overload;
    function Add(const Name: string; Value: TStream): TrmxFastXMLElemClassic; overload;
    function Add(Value: TrmxFastXMLElem): TrmxFastXMLElem; overload;
    function AddFirst(Value: TrmxFastXMLElem): TrmxFastXMLElem; overload;
    function AddFirst(const Name: string): TrmxFastXMLElemClassic; overload;
    function AddComment(const Name: string; const Value: string): TrmxFastXMLElemComment;
    function AddCData(const Name: string; const Value: string): TrmxFastXMLElemCData;
    function AddText(const Name: string; const Value: string): TrmxFastXMLElemText;
    function Insert(Value: TrmxFastXMLElem; Index: Integer): TrmxFastXMLElem; overload;
    function Insert(const Name: string; Index: Integer): TrmxFastXMLElemClassic; overload;

    procedure Clear; virtual;
    procedure Delete(const Index: Integer); overload;
    procedure Delete(const aName: string); overload;
    function Remove(Const Value: TrmxFastXMLElem): Integer;
    procedure Move(const CurIndex, NewIndex: Integer);

    function GetEnumerator: TrmxFastXMLElemsEnumerator;

    function IndexOf(const Value: TrmxFastXMLElem): Integer; overload;
    function IndexOf(const aName: string): Integer; overload;
    function ItemByName(const aName: string;Out n: TrmxFastXMLElem):Boolean;

    procedure SaveToStringStream(Const StringStream: TStringStream; const Level: string = '');
    procedure Sort;
    procedure CustomSort(Const AFunction: TrmxFastXMLElemCompare);
    property Parent: TrmxFastXMLElem read FParent;

    property Item[const Index: Integer]: TrmxFastXMLElem read GetItem; default;

    property ItemNamed[const Name: string]: TrmxFastXMLElem read GetItemNamed;
    property ItemNamedDef[const Name: string;const DefaultVal: string]: TrmxFastXMLElem read GetItemNamedDef;
    property ItemNamedValAsStr[const Name: string]: String  read GetItemNamedAsStr;
    property ItemNamedValAsStrDef[const Name: string;const DefaultVal: string ]: String  read GetItemNamedAsStrDef;
    property ItemNamedValAsInt[const Name: string]: Integer read GetItemNamedAsInt;
    property ItemNamedValAsIntDef[const Name: string;const DefaultVal: Integer ]: Integer read GetItemNamedAsIntDef;
    property ItemNamedValAsXMLFloat[const Name: string]: Extended read GetItemNamedAsXMLFloat;
    property ItemNamedValAsXMLFloatDef[const Name: string;const DefaultVal: Extended ]: Extended read GetItemNamedAsXMLFloatDef;
    property ItemNamedValAsXMLDate[const Name: string]: TDateTime read GetItemNamedAsXMLDate;
    property ItemNamedValAsXMLDateDef[const Name: string;const DefaultVal: TDateTime ]: TDateTime read GetItemNamedAsXMLDateDef;
    property ItemNamedValAsXMLTime[const Name: string]: TDateTime read GetItemNamedAsXMLTime;
    property ItemNamedValAsXMLTimeDef[const Name: string;const DefaultVal: TDateTime ]: TDateTime read GetItemNamedAsXMLTimeDef;
    property ItemNamedValAsXMLDateTime[const Name: string]: TDateTime read GetItemNamedAsXMLDateTime;
    property ItemNamedValAsXMLDateTimeDef[const Name: string;const DefaultVal: TDateTime ]: TDateTime read GetItemNamedAsXMLDateTimeDef;

    property Count: Integer read GetCount;
  end;

  TrmxFastXMLElem = class(TrmxFastXMLBaseItem)
  private
    FParent   : TrmxFastXMLElem;
    FSimpleXML: TrmxFastXML;
    FItems: TrmxFastXMLElems;
    FProps: TrmxFastXMLProps;
    function GetHasItems: Boolean;
    function GetHasProperties: Boolean;
    function GetItemCount: Integer;
    function GetPropertyCount: Integer;

  protected
    function GetChildsCount: Integer;
    function GetProps: TrmxFastXMLProps;
    function GetItems: TrmxFastXMLElems;
    procedure Error(const S: string);
    procedure FmtError(const S: string; const Args: array of const);
    procedure InternalLoad;virtual; abstract;

  public
    constructor Create(ASimpleXML: TrmxFastXML); overload;
    destructor Destroy; override;
    procedure Assign(Const Value: TrmxFastXMLElem); virtual;
    procedure Clear; virtual;
    procedure SaveToStringStream(Const StringStream: TStringStream; const Level: string = ''); virtual;abstract;
    function SaveToUnicodeString: string;
    function GetChildIndex(const AChild: TrmxFastXMLElem): Integer;

    property SimpleXML : TrmxFastXML read FSimpleXML;

    property Parent       : TrmxFastXMLElem    read FParent;
    property ChildsCount  : Integer            read GetChildsCount;
    property HasItems     : Boolean            read GetHasItems;
    property HasProperties: Boolean            read GetHasProperties;
    property ItemCount    : Integer            read GetItemCount;
    property PropertyCount: Integer            read GetPropertyCount;
    property Items        : TrmxFastXMLElems   read GetItems;
    property Properties   : TrmxFastXMLProps   read GetProps;
    end;
  TrmxFastXMLElemClass = class of TrmxFastXMLElem;

  TrmxFastXMLElemComment = class(TrmxFastXMLElem)
  public
    procedure InternalLoad;override;
    procedure SaveToStringStream(Const StringStream: TStringStream; const Level: string = ''); override;
  end;

  TrmxFastXMLElemClassic = class(TrmxFastXMLElem)
  protected
    procedure InternalLoad;override;
  public
    procedure SaveToStringStream(Const StringStream: TStringStream; const Level: string = ''); override;
  end;

  TrmxFastXMLElemCData = class(TrmxFastXMLElem)
  protected
    procedure InternalLoad;override;
  public
    procedure SaveToStringStream(Const StringStream: TStringStream; const Level: string = ''); override;
  end;

  TrmxFastXMLElemText = class(TrmxFastXMLElem)
  protected
    procedure InternalLoad;override;
  public
    procedure SaveToStringStream(Const StringStream: TStringStream; const Level: string = ''); override;
  end;

  TrmxFastXMLElemProcessingInstruction = class(TrmxFastXMLElem)
  protected
    procedure InternalLoad;override;
  public
    procedure SaveToStringStream(Const StringStream: TStringStream; const Level: string = ''); override;
  end;

  TrmxFastXMLElemHeader = class(TrmxFastXMLElemProcessingInstruction)
  private
    function GetEncoding: string;
    function GetStandalone: Boolean;
    function GetVersion: string;
    procedure SetEncoding(const Value: string);
    procedure SetStandalone(const Value: Boolean);
    procedure SetVersion(const Value: string);
  protected
    procedure InternalLoad;override;
  public
    constructor Create; override;

    procedure SaveToStringStream(Const StringStream: TStringStream; const Level: string = ''); override;
    property Version: string read GetVersion write SetVersion;
    property StandAlone: Boolean read GetStandalone write SetStandalone;
    property Encoding: string read GetEncoding write SetEncoding;
  end;

  TrmxFastXMLElemDocType = class(TrmxFastXMLElem)
  protected
    procedure InternalLoad;override;
  public
    procedure SaveToStringStream(Const StringStream: TStringStream; const Level: string = ''); override;
  end;

  TrmxFastXML = class(TObject)
  protected
    FEncoding           : TEncoding;
    FFileName           : TFileName;
    FOptions            : TrmxFastXMLOptions;
    FRoot               : TrmxFastXMLElemClassic;
    FProlog             : TrmxFastXMLElemsProlog;
    FIndentString       : string;
    FBaseIndentString   : string;
    FOnEncodeValue      : TrmxFastXMLEncodeEvent;
    FOnDecodeValue      : TrmxFastXMLEncodeEvent;
    FOnDecodeStream     : TrmxFastXMLEncodeStreamEvent;
    FOnEncodeStream     : TrmxFastXMLEncodeStreamEvent;

    fDataStream         : string;
    fDataStreamPos      : Integer;
    fDataStreamCodePage : Cardinal;


    procedure SetIndentString(const Value: string);
    procedure SetBaseIndentString(const Value: string);
    procedure SetFileName(const Value: TFileName);
  protected
    procedure DoEncodeValue(var Value: string); virtual;
    procedure DoDecodeValue(var Value: string); virtual;
    procedure GetEncodingFromXMLHeader(var HeaderEncoding: TEncoding);
  public
    constructor Create;
    destructor Destroy; override;
    procedure LoadFromString(const Value: string);
    procedure LoadFromFile(const FileName: TFileName;Const aEncoding: TEncoding=nil);
    procedure LoadFromStream(Const Stream: TStream; Const aEncoding: TEncoding=nil);
    procedure LoadFromStringStream(Const StringStream: TStringStream);
    procedure LoadFromResourceName(Const Instance: THandle; const ResName: string; Const aEncoding: TEncoding=nil);
    procedure SaveToFile(const FileName: TFileName; Const aEncoding: TEncoding);
    procedure SaveToStream(Const aStream: TStream; Const aEncoding: TEncoding);
    procedure SaveToStringStream(Const StringStream: TStringStream);
    function SaveToString: string;

    property Prolog           : TrmxFastXMLElemsProlog        read FProlog           write FProlog;
    property Root             : TrmxFastXMLElemClassic        read FRoot;
    property XMLData          : string                        read SaveToString      write LoadFromString;
    property FileName         : TFileName                     read FFileName         write SetFileName;
    property IndentString     : string                        read FIndentString     write SetIndentString;
    property BaseIndentString : string                        read FBaseIndentString write SetBaseIndentString;
    property Options          : TrmxFastXMLOptions            read FOptions          write FOptions;
    property OnEncodeValue    : TrmxFastXMLEncodeEvent        read FOnEncodeValue    write FOnEncodeValue;
    property OnDecodeValue    : TrmxFastXMLEncodeEvent        read FOnDecodeValue    write FOnDecodeValue;
    property OnEncodeStream   : TrmxFastXMLEncodeStreamEvent  read FOnEncodeStream   write FOnEncodeStream;
    property OnDecodeStream   : TrmxFastXMLEncodeStreamEvent  read FOnDecodeStream   write FOnDecodeStream;
  end;

///	<summary>
///	  PopDigit from String from Position ...
///	</summary>
function PopDigit(Const aVal:String;Var Idx:Integer;Out Digit:Word;Const MaxWidth:Integer):Boolean;inline;

// Encodes a string into an internal format:
// any character TAB,LF,CR,#32..#127 is preserved
// all other characters are converted to hex notation except
// for some special characters that are converted to XML entities
function FastXMLEncode(const S: string): string;

// Decodes a string encoded with FastXMLEncode:
// any character TAB,LF,CR,#32..#127 is preserved
// all other characters and substrings are converted from
// the special XML entities to characters or from hex to characters
// NB! Setting TrimBlanks to true will slow down the process considerably
procedure FastXMLDecode(var S: string);

// Encodes special characters (', ", <, > and &) into XML entities (@apos;, &quot;, &lt;, &gt; and &amp;)
function EntityEncode(const S: string): string;
// Decodes XML entities (@apos;, &quot;, &lt;, &gt; and &amp;) into special characters (', ", <, > and &)
function EntityDecode(const S: string): string;

///<SUMMARY>Convert XML Str to Date</SUMMARY>
function XML2Date(Const Value:String;Out aDte:TDateTime):Boolean;
///<SUMMARY>Convert XML Str to Date</SUMMARY>
function Date2XML(Const Value:TDateTime):String;

///<SUMMARY>Convert XML Str to Time</SUMMARY>
function XML2Time(Const Value:String;Out aTime:TDateTime):Boolean;
///<SUMMARY>Convert XML Str to Date</SUMMARY>
function Time2XML(Const Value:TDateTime):String;

///<SUMMARY>Convert XML</SUMMARY>
function XML2DateTime(Const Value:String;Out aDte:TDateTime):Boolean;
///<SUMMARY>Convert XML Str to Date</SUMMARY>
function DateTime2XML(Const Value:TDateTime):String;

///<SUMMARY>Convert XML</SUMMARY>
function XML2Float(Const Value:String;Out Tot:Extended):Boolean;
///<SUMMARY>Convert XML</SUMMARY>
function Float2XML(Const Value:Extended):String;

implementation

Uses
  {$IFDEF MSWINDOWS}Winapi.Windows,{$ENDIF MSWINDOWS}
  System.Character;

const
  cBufferSize = 8192;

const
  // Misc. often used character definitions
  NativeNull = Char(#0);
  NativeSoh = Char(#1);
  NativeStx = Char(#2);
  NativeEtx = Char(#3);
  NativeEot = Char(#4);
  NativeEnq = Char(#5);
  NativeAck = Char(#6);
  NativeBell = Char(#7);
  NativeBackspace = Char(#8);
  NativeTab = Char(#9);
  NativeLineFeed = Char(#10);
  NativeVerticalTab = Char(#11);
  NativeFormFeed = Char(#12);
  NativeCarriageReturn = Char(#13);
  NativeCrLf = string(#13#10);
  NativeSo = Char(#14);
  NativeSi = Char(#15);
  NativeDle = Char(#16);
  NativeDc1 = Char(#17);
  NativeDc2 = Char(#18);
  NativeDc3 = Char(#19);
  NativeDc4 = Char(#20);
  NativeNak = Char(#21);
  NativeSyn = Char(#22);
  NativeEtb = Char(#23);
  NativeCan = Char(#24);
  NativeEm = Char(#25);
  NativeEndOfFile = Char(#26);
  NativeEscape = Char(#27);
  NativeFs = Char(#28);
  NativeGs = Char(#29);
  NativeRs = Char(#30);
  NativeUs = Char(#31);
  NativeSpace = Char(' ');
  NativeComma = Char(',');
  NativeBackslash = Char('\');
  NativeForwardSlash = Char('/');

  NativeDoubleQuote = Char('"');
  NativeSingleQuote = Char('''');

  NativeLineBreak = string(#13#10);

resourcestring
  RsENoCharset                            = 'No matching charset';
  RsENoHeader                             = 'No Header';
  RsEInvalidXMLElementUnexpectedCharacte  = 'Invalid XML Element: Unexpected character in property declaration ("%s" found at position %d)';
  RsEInvalidXMLElementUnexpectedCharacte_ = 'Invalid XML Element: Unexpected character in property declaration. Expecting " or '' but "%s"  found at position %d';
  RsEUnexpectedValueForLPos               = 'Unexpected value for lPos at position %d';
  RsEInvalidXMLElementExpectedBeginningO  = 'Invalid XML Element: Expected beginning of tag but "%s" found at position %d';
  RsEInvalidXMLElementExpectedEndOfTagBu  = 'Invalid XML Element: Expected end of tag but "%s" found at position %d';
  RsEInvalidXMLElementMalformedTagFoundn  = 'Invalid XML Element: malformed tag found (no valid name) at position %d';
  RsEInvalidXMLElementErroneousEndOfTagE  = 'Invalid XML Element: Erroneous end of tag, expecting </%0:s> but </%1:s> found at position %d';
  RsEInvalidCommentExpectedsButFounds     = 'Invalid Comment: expected "%0:s" but found "%1:s" at position %d';
  RsEInvalidCommentNotAllowedInsideComme  = 'Invalid Comment: "--" not allowed inside comments at position %d';
  RsEInvalidCommentUnexpectedEndOfData    = 'Invalid Comment: Unexpected end of data at position %d';
  RsEInvalidCDATAExpectedsButFounds       = 'Invalid CDATA: expected "%0:s" but found "%1:s" at position %d';
  RsEInvalidCDATAUnexpectedEndOfData      = 'Invalid CDATA: Unexpected end of data at position %d';
  RsEInvalidHeaderExpectedsButFounds      = 'Invalid Header: expected "%0:s" but found "%1:s" at position %d';
  RsEInvalidStylesheetExpectedsButFounds  = 'Invalid Stylesheet: expected "%0:s" but found "%1:s" at position %d';
  RsEInvalidStylesheetUnexpectedEndOfDat  = 'Invalid Stylesheet: Unexpected end of data at position %d';
  RsEInvalidMSOExpectedsButFounds         = 'Invalid MSO: expected "%0:s" but found "%1:s" at position %d';
  RsEInvalidMSOUnexpectedEndOfDat         = 'Invalid MSO: Unexpected end of data at position %d';
  RsEInvalidDocumentUnexpectedTextInFile  = 'Invalid Document: Unexpected text in file prolog at position %d';

{______________________________________________________________________________}
{______________________________________________________________________________}
{______________________________________________________________________________}
function PopDigit(Const aVal:String;Var Idx:Integer;Out Digit:Word;Const MaxWidth:Integer):Boolean;
Var len,cnt:Integer;
    c:Char;
Begin
  cnt:=0;
  Digit:=0;
  Result:=False;
  len:=aVal.Length;
  While (Idx<len) do Begin
    c:=aVal.Chars[Idx];
    Case c of
      '0'..'9':Begin
        Break;
        end;
      else Begin
        Inc(Idx);
    end end end;
  While (Idx<len)and(cnt<MaxWidth) do Begin
    c:=aVal.Chars[Idx];Inc(Idx);
    Case c of
      '0'..'9':Begin
        Digit:=Ord(c)-Ord('0')+Digit*10;
        Result:=True;
        Inc(cnt);
        end;
      else Begin
        Break;
    end end end;
End;
{______________________________________________________________________________}
procedure AddEntity(var Res: string; var ResIndex, ResLen: Integer; const Entity: string);
var EntityIndex, EntityLen: Integer;
begin
  EntityLen := Length(Entity);
  if (ResIndex + EntityLen) > ResLen then begin
    if ResLen <= EntityLen then
      ResLen := ResLen * EntityLen
    else
      ResLen := ResLen * 2;
    SetLength(Res, ResLen);
    end;

  for EntityIndex := 1 to EntityLen do begin
    Res[ResIndex] := Entity[EntityIndex];
    Inc(ResIndex);
  end;
end;
{______________________________________________________________________________}
function EntityEncode(const S: string): string;
var C: Char;
    SIndex, SLen, RIndex, RLen: Integer;
    Tmp: string;
begin
  SLen := Length(S);
  RLen := SLen;
  RIndex := 1;
  SetLength(Tmp, RLen);
  for SIndex := 1 to SLen do begin
    C := S[SIndex];
    case C of
      '"':
        AddEntity(Tmp, RIndex, RLen, '&quot;');
      '&':
        AddEntity(Tmp, RIndex, RLen, '&amp;');
      #39:
        AddEntity(Tmp, RIndex, RLen, '&apos;');
      '<':
        AddEntity(Tmp, RIndex, RLen, '&lt;');
      '>':
        AddEntity(Tmp, RIndex, RLen, '&gt;');
      else Begin
        if RIndex > RLen then begin
          RLen := RLen * 2;
          SetLength(Tmp, RLen);
          end;
        Tmp[RIndex] := C;
        Inc(RIndex);
    end end end;

  if RIndex > 1 then
    SetLength(Tmp, RIndex - 1);

  Result := Tmp;
end;
{______________________________________________________________________________}
function EntityDecode(const S: string): string;
var I, J, L: Integer;
begin
  Result := S;
  I := 1;
  J := 1;
  L := Length(Result);

  while I <= L do begin
    if Result[I] = '&' then begin
      if SameText(Copy(Result, I, 5), '&amp;') then begin
        Result[J] := '&';
        Inc(J);
        Inc(I, 4);
      end else
      if SameText(Copy(Result, I, 4), '&lt;') then begin
        Result[J] := '<';
        Inc(J);
        Inc(I, 3);
      end else
      if SameText(Copy(Result, I, 4), '&gt;') then begin
        Result[J] := '>';
        Inc(J);
        Inc(I, 3);
      end else
      if SameText(Copy(Result, I, 6), '&apos;') then begin
        Result[J] := #39;
        Inc(J);
        Inc(I, 5);
      end else
      if SameText(Copy(Result, I, 6), '&quot;') then begin
        Result[J] := '"';
        Inc(J);
        Inc(I, 5);
      end else begin
        Result[J] := Result[I];
        Inc(J);
      end;
    end else begin
      Result[J] := Result[I];
      Inc(J);
      end;
    Inc(I);
    end;
  if J > 1 then
    SetLength(Result, J - 1) else
    SetLength(Result, 0);
end;
{______________________________________________________________________________}
function FastXMLEncode(const S: string): string;
var C: Char;
    SIndex, SLen, RIndex, RLen: Integer;
    Tmp: string;
begin
  SLen := Length(S);
  RLen := SLen;
  RIndex := 1;
  SetLength(Tmp, RLen);
  for SIndex := 1 to SLen do begin
    C := S[SIndex];
    case C of
      '"':
        AddEntity(Tmp, RIndex, RLen, '&quot;');
      '&':
        AddEntity(Tmp, RIndex, RLen, '&amp;');
      #39:
        AddEntity(Tmp, RIndex, RLen, '&apos;');
      '<':
        AddEntity(Tmp, RIndex, RLen, '&lt;');
      '>':
        AddEntity(Tmp, RIndex, RLen, '&gt;');
      NativeNull..NativeBackspace, // NativeTab, NativeLineFeed
      NativeVerticalTab..NativeFormFeed, // NativeCarriageReturn
      NativeSo..NativeUs,
      Char(128)..Char(255):
        AddEntity(Tmp, RIndex, RLen, Format('&#x%.2x;', [Ord(C)]));
      Char(256)..High(Char):
        AddEntity(Tmp, RIndex, RLen, Format('&#x%.4x;', [Ord(C)]));
      else Begin
        if RIndex > RLen then begin
          RLen := RLen * 2;
          SetLength(Tmp, RLen);
          end;
        Tmp[RIndex] := C;
        Inc(RIndex);
    end end end;

  if RIndex > 1 then
    SetLength(Tmp, RIndex - 1);

  Result := Tmp;
end;
{______________________________________________________________________________}
procedure FastXMLDecode(var S: string);
Const StringOffset  = {$IFDEF NEXTGEN}0{$ELSE}1{$ENDIF};
  {____________________________________________________________________________}
  procedure DecodeEntity(var S: string; StringLength: Cardinal;
  var ReadIndex, WriteIndex: Cardinal);
  const cHexPrefix: array [Boolean] of string = ('', '$');
  var I: Cardinal;
      Value: Integer;
      IsHex: Boolean;
  begin
    Inc(ReadIndex, 2);
    IsHex := (ReadIndex <= StringLength) and ((S.Chars[ReadIndex] = 'x') or (S.Chars[ReadIndex] = 'X'));
    Inc(ReadIndex, Ord(IsHex));
    I := ReadIndex;
    while ReadIndex <= StringLength do begin
      if S.Chars[ReadIndex] = ';' then begin
        Value := StrToIntDef(cHexPrefix[IsHex] + S.Substring( I, ReadIndex - I), -1); // no characters are less than 0
        if Value >= 0 then Begin
          S[StringOffset+WriteIndex] := Chr(Value)
        end else
          ReadIndex := I - (2 + Cardinal(IsHex)); // reset to start
        Exit;
      end;
      Inc(ReadIndex);
    end;
    ReadIndex := I - (2 + Cardinal(IsHex)); // reset to start
  end;
var StringLength, ReadIndex, WriteIndex: Cardinal;
begin
  ReadIndex := 0;
  WriteIndex := 0;
  StringLength := S.Length;
  while ReadIndex < StringLength do begin
    if S.Chars[ReadIndex] = '&' then begin
      if (ReadIndex < StringLength) and (S.Chars[ReadIndex + 1] = '#') then begin
        DecodeEntity(S, StringLength, ReadIndex, WriteIndex);
        Inc(WriteIndex);
      end else
      if SameStr(S.Substring(ReadIndex, 5), '&amp;') then begin
        S[StringOffset+WriteIndex] := '&';
        Inc(WriteIndex);
        Inc(ReadIndex, 4);
      end
      else
      if SameStr(S.Substring(ReadIndex, 4), '&lt;') then begin
        S[StringOffset+WriteIndex] := '<';
        Inc(WriteIndex);
        Inc(ReadIndex, 3);
      end else
      if SameStr(S.Substring(ReadIndex, 4), '&gt;') then begin
        S[StringOffset+WriteIndex] := '>';
        Inc(WriteIndex);
        Inc(ReadIndex, 3);
      end else
      if SameStr(S.Substring(ReadIndex, 6), '&apos;') then begin
        S[StringOffset+WriteIndex] := #39;
        Inc(WriteIndex);
        Inc(ReadIndex, 5);
      end else
      if SameStr(S.Substring(ReadIndex, 6), '&quot;') then begin
        S[StringOffset+WriteIndex] := '"';
        Inc(WriteIndex);
        Inc(ReadIndex, 5);
      end else begin
        S[StringOffset+WriteIndex] := S.Chars[ReadIndex];
        Inc(WriteIndex);
      end;
    end else begin
      S[StringOffset+WriteIndex] := S.Chars[ReadIndex];
      Inc(WriteIndex);
      end;
    Inc(ReadIndex);
    end;
  if WriteIndex > 0 then
    SetLength(S, WriteIndex) else
    SetLength(S, 0);
end;
{______________________________________________________________________________}
function Date2XML(Const Value:TDateTime):String;
Begin
  Result:=FormatDateTime('yyyy-mm-dd',Value);
End;
{______________________________________________________________________________}
function XML2Date(Const Value:String;Out aDte:TDateTime):Boolean;
Var yy,mm,dd:Word;
    Idx:Integer;
Begin
  Idx:=0;
  if PopDigit(Value,idx,yy,4) and PopDigit(Value,idx,mm,2) and PopDigit(Value,idx,dd,2) then Begin
    Result:=TryEncodeDate(yy,mm,dd,aDte)
  end else
    Result:=False;
end;
{______________________________________________________________________________}
function Time2XML(Const Value:TDateTime):String;
Begin
  Result:=FormatDateTime('hh:nn:ss',Value);
End;
{______________________________________________________________________________}
function XML2Time(Const Value:String;Out aTime:TDateTime):Boolean;
Var hh,nn,ss,zzz:Word;
    Idx:Integer;
Begin
  Idx:=0;
  if PopDigit(Value,idx,hh,2) then Begin
    PopDigit(Value,idx,nn,2);
    PopDigit(Value,idx,ss,2);
    PopDigit(Value,idx,zzz,3);
    Result:=TryEncodeTime(hh,nn,ss,zzz,aTime)
  end else
    Result:=False;
end;
{______________________________________________________________________________}
function DateTime2XML(Const Value:TDateTime):String;
Begin
  Result:=FormatDateTime('yyyy-mm-dd hh:nn:ss',Value);
End;
{______________________________________________________________________________}
function XML2DateTime(Const Value:String;Out aDte:TDateTime):Boolean;
Var yy,mm,dd,hh,nn,ss,zzz:Word;
    Idx:Integer;
Begin
  Idx:=0;
  if PopDigit(Value,idx,yy,4) and PopDigit(Value,idx,mm,2) and PopDigit(Value,idx,dd,2) then Begin
    if PopDigit(Value,idx,hh,2) then Begin
      PopDigit(Value,idx,nn,2);
      PopDigit(Value,idx,ss,2);
      PopDigit(Value,idx,zzz,3);
      Result:=TryEncodeDateTime(yy,mm,dd,hh,nn,ss,zzz,aDte)
    end else
      Result:=TryEncodeDate(yy,mm,dd,aDte)
  end else
    Result:=False
end;
{______________________________________________________________________________}
function Float2XML(Const Value:Extended):String;
Var fmt:TFormatSettings;
begin
  fmt:=TFormatSettings.Create;
  fmt.DecimalSeparator:='.';
  Result := FloatToStr(Value,fmt);
end;
{______________________________________________________________________________}
function XML2Float(Const Value:String;Out Tot:Extended):Boolean;
Var Sign,DecPart,DecFact:Integer;
    Idx,len:Integer;
    IntPart:Int64;
    c:Char;
Begin
  Idx:=0;
  Tot:=0;
  Sign:=+1;
  IntPart:=0;
  DecPart:=0;
  DecFact:=1;
  len:=length(Value);
  While (Idx<len) do Begin
    c:=Value.Chars[Idx];inc(Idx);
    if c.IsWhiteSpace then
      Continue;
    Case c of
      '0'..'9':Begin
        IntPart:=Ord(c)-Ord('0')+IntPart*10;
        end;
      '+','-':Begin
        if c='-' then
          Sign:=-1;
        While (Idx<len) do Begin
          c:=Value.Chars[Idx];inc(Idx);
          Case c of
            '0'..'9':Begin
              IntPart:=Ord(c)-Ord('0')+IntPart*10;
              end;
            '.':Begin
              While (Idx<len) do Begin
                c:=Value.Chars[Idx];inc(Idx);
                Case c of
                  '0'..'9':Begin
                    DecPart:=Ord(c)-Ord('0')+DecPart*10;
                    DecFact:=DecFact*10;
                    end;
                  else Begin
                    Result:=False;
                    exit;
              end end end end;
            else Begin
              Result:=False;
              exit;
        end end end end;
      '.':Begin
        While (Idx<len) do Begin
          c:=Value.Chars[Idx];inc(Idx);
          Case c of
            '0'..'9':Begin
              DecPart:=Ord(c)-Ord('0')+DecPart*10;
              DecFact:=DecFact*10;
              end;
            else Begin
              Result:=False;
              exit;
        end end end end;
      else Begin
        Result:=False;
        exit;
    end end end;

  Tot:=IntPart;
  Tot:=Tot+(DecPart/DecFact);
  Tot:=Sign*Tot;
  Result:=True;
end;
{______________________________________________________________________________}
{______________________________________________________________________________}
{______________________________________________________________________________}
constructor TrmxFastXMLBaseItem.Create;
begin
  inherited Create;
end;
{______________________________________________________________________________}
constructor TrmxFastXMLBaseItem.Create(const AName: string);
begin
  inherited Create;
  FName := AName;
end;
{______________________________________________________________________________}
constructor TrmxFastXMLBaseItem.Create(const AName, AValue: string);
begin
  inherited Create;
  FName := AName;
  FValue := AValue;
end;
{______________________________________________________________________________}
procedure TrmxFastXMLBaseItem.SetName(const Value: string);
begin
  FName := Value;
end;
{______________________________________________________________________________}
function TrmxFastXMLBaseItem.GetFullName: string;
begin
  if NameSpace <> '' then
    Result := NameSpace + ':' + Name else
    Result := Name;
end;
{______________________________________________________________________________}
function TrmxFastXMLBaseItem.GetBoolValue: Boolean;
begin
  Result := StrToBoolDef(fValue, False);
end;
{______________________________________________________________________________}
function TrmxFastXMLBaseItem.GetIntValue: Int64;
begin
  Result := StrToInt64Def(fValue, -1);
end;
{______________________________________________________________________________}
procedure TrmxFastXMLBaseItem.SetIntValue(const Val: Int64);
begin
  FValue := IntToStr(Val);
end;
{______________________________________________________________________________}
procedure TrmxFastXMLBaseItem.SetBoolValue(const Val: Boolean);
begin
  FValue := BoolToStr(Val);
end;
{______________________________________________________________________________}
function TrmxFastXMLBaseItem.GetXMLFloatValue: Extended;
Var Tot:Extended;
Begin
  if XML2Float(FValue,Tot) then Begin
    Result:=Tot
  End else
    Result := 0.0;
end;
{______________________________________________________________________________}
procedure TrmxFastXMLBaseItem.SetXMLFloatValue(const Val: Extended);
Var fmt:TFormatSettings;
begin
  fmt:=TFormatSettings.Create;
  fmt.DecimalSeparator:='.';
  FValue := FloatToStr(Val,fmt);
end;
{______________________________________________________________________________}
function TrmxFastXMLBaseItem.GetXMLDateValue:TDateTime;
Var dte:TDateTime;
begin
  if XML2Date(FValue,dte) then Begin
    Result:=dte
  End else
    Result := 0.0;
end;
{______________________________________________________________________________}
procedure TrmxFastXMLBaseItem.SetXMLDateValue(const Val: TDateTime);
begin
  FValue:=FormatDateTime('yyyy-mm-dd',Val);
end;
{______________________________________________________________________________}
function TrmxFastXMLBaseItem.GetXMLTimeValue:TDateTime;
Var dte:TDateTime;
begin
  if XML2Time(FValue,dte) then Begin
    Result:=dte
  End else
    Result := 0.0;
end;
{______________________________________________________________________________}
procedure TrmxFastXMLBaseItem.SetXMLTimeValue(const Val: TDateTime);
begin
  FValue:=FormatDateTime('hh:nn:ss',Val);
end;
{______________________________________________________________________________}
function TrmxFastXMLBaseItem.GetXMLDateTimeValue:TDateTime;
Var dte:TDateTime;
begin
  if XML2DateTime(FValue,dte) then Begin
    Result:=dte
  End else
    Result := 0.0;
end;
{______________________________________________________________________________}
procedure TrmxFastXMLBaseItem.SetXMLDateTimeValue(const Val: TDateTime);
begin
  FValue:=FormatDateTime('yyyy-mm-dd hh:nn:ss',Val);
end;
{______________________________________________________________________________}
{______________________________________________________________________________}
{______________________________________________________________________________}
constructor TrmxFastXML.Create;
begin
  inherited Create;
  FRoot := TrmxFastXMLElemClassic.Create(Self);
  FProlog := TrmxFastXMLElemsProlog.Create(Self);
  FOptions := [sxoAutoIndent, sxoAutoEncodeValue, sxoAutoEncodeEntity];
  FIndentString := '  ';
end;
{______________________________________________________________________________}
destructor TrmxFastXML.Destroy;
begin
  FreeAndNil(FRoot);
  FreeAndNil(FProlog);
  inherited Destroy;
end;
{______________________________________________________________________________}
procedure TrmxFastXML.DoDecodeValue(var Value: string);
begin
  if sxoAutoEncodeValue in Options then Begin
    FastXMLDecode(Value)
  end else
  if sxoAutoEncodeEntity in Options then Begin
    Value := EntityDecode(Value);
    end;

  if Assigned(FOnDecodeValue) then
    FOnDecodeValue(Self, Value);
end;
{______________________________________________________________________________}
procedure TrmxFastXML.DoEncodeValue(var Value: string);
begin
  if Assigned(FOnEncodeValue) then Begin
    FOnEncodeValue(Self, Value);
    end;

  if sxoAutoEncodeValue in Options then Begin
    Value := FastXMLEncode(Value)
  end else
  if sxoAutoEncodeEntity in Options then Begin
    Value := EntityEncode(Value);
    end;
end;
{______________________________________________________________________________}
procedure TrmxFastXML.LoadFromFile(const FileName: TFileName;Const aEncoding: TEncoding);
var Stream: TMemoryStream;
begin
  Stream := TMemoryStream.Create;
  try Stream.LoadFromFile(FileName);
      LoadFromStream(Stream,aEncoding);
  finally
      Stream.Free;
  end;
end;
{______________________________________________________________________________}
procedure TrmxFastXML.LoadFromResourceName(Const Instance: THandle; const ResName: string; Const aEncoding: TEncoding);
var Stream: TResourceStream;
begin
  Stream := TResourceStream.Create(Instance, ResName, RT_RCDATA);
  try LoadFromStream(Stream,aEncoding);
  finally
    Stream.Free;
  end;
end;
{______________________________________________________________________________}
procedure TrmxFastXML.LoadFromStream(Const Stream: TStream; Const aEncoding: TEncoding);
var OwnedStream,DecodedStream:TStream;
    StringStream:TStringStream;
    BOMEncoding:TEncoding;
    BOMLength:Integer;
    Buff: TBytes;
begin
  FRoot.Clear;
  FProlog.Clear;

  OwnedStream := nil;
  StringStream := nil;
  try // Decode iff needed (ZIP ???)
      if Assigned(FOnDecodeStream) then begin
        OwnedStream := TMemoryStream.Create;
        FOnDecodeStream(Self, Stream, OwnedStream);
        OwnedStream.Seek(0, soBeginning);
        DecodedStream := OwnedStream;
      end else
        DecodedStream := Stream;

      // Copy to Buff
      SetLength(Buff,DecodedStream.Size);
      DecodedStream.Read(Buff,MaxInt);
      FreeAndNil(OwnedStream);

      // Unicode Decoding
      BOMEncoding:=nil;
      if aEncoding<>nil then
        BOMLength := TEncoding.GetBufferEncoding(Buff, BOMEncoding,aEncoding) else
        BOMLength := TEncoding.GetBufferEncoding(Buff, BOMEncoding,fEncoding);
      if BOMEncoding=nil then
        BOMEncoding:=TEncoding.UTF8;
      StringStream:=TStringStream.Create(BOMEncoding.GetString(Buff, BOMLength, Length(Buff) - BOMLength),BOMEncoding.CodePage);
      LoadFromStringStream(StringStream);

      // save codepage and encoding for future saves
      if fEncoding=nil then
        BOMEncoding:=fEncoding;

  finally
      FreeAndNil(StringStream);
      FreeAndNil(OwnedStream);
  end;
end;
{______________________________________________________________________________}
procedure TrmxFastXML.LoadFromStringStream(Const StringStream: TStringStream);
begin
  fDataStreamPos:=0;
  fDataStream:=StringStream.DataString;
  fDataStreamCodePage:=StringStream.Encoding.CodePage;

  // Read doctype and so on
  FProlog.InternalLoad;

  // Read elements
  FRoot.InternalLoad;

  fDataStream:=EmptyStr;
  fDataStreamPos:=0;
end;
{______________________________________________________________________________}
procedure TrmxFastXML.LoadFromString(const Value: string);
begin
  fDataStreamPos:=0;
  fDataStream:=Value;
  fDataStreamCodePage:=TEncoding.Unicode.CodePage;

  // Read doctype and so on
  FProlog.InternalLoad;

  // Read elements
  FRoot.InternalLoad;

  fDataStream:=EmptyStr;
  fDataStreamPos:=0;
end;
{______________________________________________________________________________}
procedure TrmxFastXML.GetEncodingFromXMLHeader(var HeaderEncoding: TEncoding);
var XMLHeader: TrmxFastXMLElemHeader;
    I: Integer;
begin
  XMLHeader := nil;
  for I := 0 to Prolog.Count - 1 do begin
    if Prolog.Item[I] is TrmxFastXMLElemHeader then begin
      XMLHeader := TrmxFastXMLElemHeader(Prolog.Item[I]);
      Break;
    end end;

  if Assigned(XMLHeader) then begin
    // TODO find generic utils fct to convert
    if XMLHeader.Encoding = 'ANSI' then
      HeaderEncoding := TEncoding.Default else
    if XMLHeader.Encoding = 'ASCII' then
      HeaderEncoding := TEncoding.ASCII else
    if XMLHeader.Encoding = 'Unicode' then
      HeaderEncoding := TEncoding.Unicode else
    if XMLHeader.Encoding = 'Big Endian Unicode' then
      HeaderEncoding := TEncoding.BigEndianUnicode else
    if XMLHeader.Encoding = 'UTF-7' then
      HeaderEncoding := TEncoding.UTF7  else
    if XMLHeader.Encoding = 'UTF-8' then
      HeaderEncoding := TEncoding.UTF8 else
      HeaderEncoding := FEncoding;
  end else begin
    // restore from previous load
    HeaderEncoding := FEncoding;
    end;
end;
{______________________________________________________________________________}
procedure TrmxFastXML.SaveToFile(const FileName: TFileName; Const aEncoding: TEncoding);
var Stream: TMemoryStream;
begin
  Stream := TMemoryStream.Create;
  try SaveToStream(Stream, aEncoding);
      Stream.SaveToFile(FileName);
  finally
      Stream.Free;
  end;
end;
{______________________________________________________________________________}
procedure TrmxFastXML.SaveToStream(Const aStream: TStream; Const aEncoding: TEncoding);
var StringStream: TStringStream;
    StreamEncoding: TEncoding;
    EncodedStream: TStream;
    Preamble: TBytes;
begin
  StringStream:=nil;
  EncodedStream:=nil;
  try
      if aEncoding=nil then Begin
        GetEncodingFromXMLHeader(StreamEncoding);
      End else
        StreamEncoding:=aEncoding;

      StringStream := TStringStream.Create(EmptyStr,StreamEncoding);
      if not (sxoDoNotSaveBOM in Options) then Begin
        Preamble := StreamEncoding.GetPreamble;
        if Length(Preamble) > 0 then
          StringStream.WriteBuffer(Preamble, Length(Preamble));
        end;
      SaveToStringStream(StringStream);

      if Assigned(FOnEncodeStream) then begin
        EncodedStream:=TMemoryStream.Create;
        FOnEncodeStream(Self, StringStream, EncodedStream);
        aStream.CopyFrom(EncodedStream,-1)
      end else
        aStream.CopyFrom(StringStream,-1)

  finally
      FreeAndNil(EncodedStream);
      FreeAndNil(StringStream);
  end;
end;
{______________________________________________________________________________}
procedure TrmxFastXML.SaveToStringStream(Const StringStream: TStringStream);
begin
  if not (sxoDoNotSaveProlog in FOptions) then
    Prolog.SaveToStringStream(StringStream);
  Root.SaveToStringStream(StringStream, BaseIndentString);
end;
{______________________________________________________________________________}
function TrmxFastXML.SaveToString: string;
var Stream: TStringStream;
begin
  Stream := TStringStream.Create('',FEncoding);
  try SaveToStream(Stream,FEncoding);
      Result := Stream.DataString;
  finally
      Stream.Free;
  end;
end;
{______________________________________________________________________________}
procedure TrmxFastXML.SetBaseIndentString(const Value: string);
Var c:Char;
begin
  // test if the new value is only made of spaces or tabs
  for c in Value do
    if not c.IsWhiteSpace then
      exit;

  FBaseIndentString := Value;
end;
{______________________________________________________________________________}
procedure TrmxFastXML.SetFileName(const Value: TFileName);
begin
  FFileName := Value;
  LoadFromFile(Value);
end;
{______________________________________________________________________________}
{______________________________________________________________________________}
{______________________________________________________________________________}
constructor TrmxFastXMLElem.Create(ASimpleXML: TrmxFastXML);
begin
  Create;
  FSimpleXML := ASimpleXML;
end;
{______________________________________________________________________________}
destructor TrmxFastXMLElem.Destroy;
begin
  FSimpleXML := nil;
  FParent := nil;
  Clear;
  FreeAndNil(FItems);
  FreeAndNil(FProps);
  inherited Destroy;
end;
{______________________________________________________________________________}
procedure TrmxFastXMLElem.Error(const S: string);
begin
 raise EFastXMLError.Create(S);
end;
{______________________________________________________________________________}
procedure TrmxFastXMLElem.FmtError(const S: string;const Args: array of const);
begin
  Error(Format(S, Args));
end;
{______________________________________________________________________________}
procedure TrmxFastXMLElem.Clear;
begin
  if FItems <> nil then
    FItems.Clear;
  if FProps <> nil then
    FProps.Clear;
end;
{______________________________________________________________________________}
procedure TrmxFastXMLElem.Assign(Const Value: TrmxFastXMLElem);
var Elems: TrmxFastXMLElem;
  SrcElem, DestElem: TrmxFastXMLElem;
  I: Integer;
  SrcProps, DestProps: TrmxFastXMLProps;
  SrcProp: TrmxFastXMLProp;
  SrcElems, DestElems: TrmxFastXMLElems;
begin
  Clear;

  if Value = nil then
    Exit;

  Elems := TrmxFastXMLElem(Value);
  Name := Elems.Name;
  Self.Value := Elems.Value;
  SrcProps := Elems.FProps;
  if Assigned(SrcProps) then begin
    DestProps := Properties;
    for I := 0 to SrcProps.Count - 1 do begin
      SrcProp := SrcProps.Item[I];
      DestProps.Add(SrcProp.Name, SrcProp.Value);
    end end;

  SrcElems := Elems.FItems;
  if Assigned(SrcElems) then begin
    DestElems := Items;
    for I := 0 to SrcElems.Count - 1 do begin
      // Create from the class type, so that the virtual constructor is called
      // creating an element of the correct class type.
      SrcElem := SrcElems.Item[I];
      DestElem := TrmxFastXMLElemClass(SrcElem.ClassType).Create(SrcElem.Name, SrcElem.Value);
      DestElem.Assign(SrcElem);
      DestElems.Add(DestElem);
    end end;
end;
{______________________________________________________________________________}
function TrmxFastXMLElem.GetChildIndex(const AChild: TrmxFastXMLElem): Integer;
begin
  if FItems <> nil then Begin
    Result := FItems.FElems.IndexOf(AChild);
  end else
    Result := -1
end;
{______________________________________________________________________________}
function TrmxFastXMLElem.GetChildsCount: Integer;
var I: Integer;
begin
  Result := 1;
  if FItems <> nil then
    for I := 0 to FItems.Count - 1 do
      Result := Result + FItems[I].ChildsCount;
end;
{______________________________________________________________________________}
function TrmxFastXMLElem.GetHasItems: Boolean;
begin
  Result := Assigned(FItems) and (FItems.Count > 0);
end;
{______________________________________________________________________________}
function TrmxFastXMLElem.GetHasProperties: Boolean;
begin
  Result := Assigned(FProps) and (FProps.Count > 0);
end;
{______________________________________________________________________________}
function TrmxFastXMLElem.GetItemCount: Integer;
begin
  if Assigned(FItems) then begin
    Result := FItems.Count;
  end else
    Result := 0;
end;
{______________________________________________________________________________}
function TrmxFastXMLElem.GetItems: TrmxFastXMLElems;
begin
  if FItems = nil then
    FItems := TrmxFastXMLElems.Create(Self);
  Result := FItems;
end;
{______________________________________________________________________________}
function TrmxFastXMLElem.GetPropertyCount: Integer;
begin
  if Assigned(FProps) then Begin
    Result := FProps.Count;
  end else
    Result := 0;
end;
{______________________________________________________________________________}
function TrmxFastXMLElem.GetProps: TrmxFastXMLProps;
begin
  if FProps = nil then
    FProps := TrmxFastXMLProps.Create(Self);
  Result := FProps;
end;
{______________________________________________________________________________}
function TrmxFastXMLElem.SaveToUnicodeString: string;
var StrStream: TStringStream;
begin
  StrStream := TStringStream.Create('',TEncoding.Unicode);
  try SaveToStringStream(StrStream);
      Result := StrStream.DataString;
  finally
      StrStream.Free;
  end;
end;
{______________________________________________________________________________}
{______________________________________________________________________________}
{______________________________________________________________________________}
constructor TrmxFastXMLElemsEnumerator.Create(AList: TrmxFastXMLElems);
begin
  inherited Create;
  FIndex := -1;
  FList := AList;
end;
{______________________________________________________________________________}
function TrmxFastXMLElemsEnumerator.GetCurrent: TrmxFastXMLElem;
begin
  Result := FList[FIndex];
end;
{______________________________________________________________________________}
function TrmxFastXMLElemsEnumerator.MoveNext: Boolean;
begin
  Result := FIndex < FList.Count - 1;
  if Result then
    Inc(FIndex);
end;
{______________________________________________________________________________}
{______________________________________________________________________________}
{______________________________________________________________________________}
constructor TrmxFastXMLElems.Create(AParent: TrmxFastXMLElem);
begin
  inherited Create;
  FParent := AParent;
end;
{______________________________________________________________________________}
destructor TrmxFastXMLElems.Destroy;
begin
  Self.Clear;
  FParent := nil;
  FreeAndNil(FElems);
  inherited Destroy;
end;
{______________________________________________________________________________}
procedure TrmxFastXMLElems.Clear;
begin
  if FElems<> nil then Begin
    FElems.Clear;
    end;
end;
{______________________________________________________________________________}
function TrmxFastXMLElems.GetCount: Integer;
begin
  if FElems <> nil then Begin
    Result := FElems.Count;
  end else
    Result := 0
end;
{______________________________________________________________________________}
function TrmxFastXMLElems.GetEnumerator: TrmxFastXMLElemsEnumerator;
begin
  Result := TrmxFastXMLElemsEnumerator.Create(Self);
end;
{______________________________________________________________________________}
function TrmxFastXMLElems.GetItem(const Index: Integer): TrmxFastXMLElem;
begin
  if (FElems <> nil) and (Index < FElems.Count) then Begin
    Result := FElems[Index];
  end else
    Result := nil
end;
{______________________________________________________________________________}
procedure TrmxFastXMLElems.Notify(Const Value: TrmxFastXMLElem;Const Operation: TOperation);
begin
  case Operation of
    opRemove:Begin
      if Value.fParent = fParent then Begin
        FElems.Remove(Value);
        Value.FParent := nil;
        Value.FSimpleXML := nil;
      end end;
    opInsert:begin
      Value.FParent := Parent;
      Value.FSimpleXML := Parent.SimpleXML;
    end end;
end;
{______________________________________________________________________________}
function TrmxFastXMLElems.Remove(Const Value: TrmxFastXMLElem): Integer;
begin
  if FElems <> nil then Begin
    Result := FElems.IndexOf(Value);
    Notify(Value, opRemove);
  end else
    Result := -1
end;
{______________________________________________________________________________}
function TrmxFastXMLElems.IndexOf(const Value: TrmxFastXMLElem): Integer;
begin
  if FElems <> nil then begin
    Result := FElems.IndexOf(Value);
  end else
    Result := -1
end;
{______________________________________________________________________________}
function TrmxFastXMLElems.IndexOf(const aName: string): Integer;
var Item:TrmxFastXMLBaseItem;
    I:Integer;
begin
  if FElems <> nil then Begin
    for I := 0 to Pred(FElems.Count) do Begin
      Item:=FElems[i];
      if SameText(Item.FName,aName) then Begin
        Result:=i;
        exit;
    end end end;
  Result:=-1;
end;
{______________________________________________________________________________}
function TrmxFastXMLElems.ItemByName(const aName: string;Out n: TrmxFastXMLElem):Boolean;
var Item:TrmxFastXMLElem;
    I:Integer;
begin
  if FElems <> nil then Begin
    for I := 0 to Pred(FElems.Count) do Begin
      Item:=FElems[i];
      if SameText(Item.FName,aName) then Begin
        n:=FElems[i];
        Result:=True;
        exit;
    end end end;
  n:=nil;
  Result:=False;
end;
{______________________________________________________________________________}
procedure TrmxFastXMLElems.CreateElems;
begin
  if FElems = nil then begin
    FElems:= TObjectList<TrmxFastXMLElem>.Create(True);
    end;
end;
{______________________________________________________________________________}
function TrmxFastXMLElems.Add(const Name: string): TrmxFastXMLElemClassic;
begin
  Result := TrmxFastXMLElemClassic.Create(Name);
  AddChild(Result);
end;
{______________________________________________________________________________}
function TrmxFastXMLElems.Add(const Name, Value: string): TrmxFastXMLElemClassic;
begin
  Result := TrmxFastXMLElemClassic.Create(Name, Value);
  AddChild(Result);
end;
{______________________________________________________________________________}
function TrmxFastXMLElems.Add(const Name: string; const Value: Int64): TrmxFastXMLElemClassic;
begin
  Result := TrmxFastXMLElemClassic.Create(Name, IntToStr(Value));
  AddChild(Result);
end;
{______________________________________________________________________________}
function TrmxFastXMLElems.Add(Value: TrmxFastXMLElem): TrmxFastXMLElem;
begin
  if Value <> nil then
    AddChild(Value);
  Result := Value;
end;
{______________________________________________________________________________}
function TrmxFastXMLElems.Add(const Name: string; const Value: Boolean): TrmxFastXMLElemClassic;
begin
  Result := TrmxFastXMLElemClassic.Create(Name, BoolToStr(Value));
  AddChild(Result);
end;
{______________________________________________________________________________}
function TrmxFastXMLElems.Add(const Name: string; Value: TStream): TrmxFastXMLElemClassic;
var
  Stream: TStringStream;
  Buf: array [0..cBufferSize - 1] of Byte;
  St: string;
  I, Count: Integer;
begin
  Stream := TStringStream.Create('');
  try
    Buf[0] := 0;
    repeat
      Count := Value.Read(Buf, Length(Buf));
      St := '';
      for I := 0 to Count - 1 do
        St := St + IntToHex(Buf[I], 2);
      Stream.WriteString(St);
    until Count = 0;
    Result := TrmxFastXMLElemClassic.Create(Name, Stream.DataString);
    AddChild(Result);
  finally
    Stream.Free;
  end;
end;
{______________________________________________________________________________}
procedure TrmxFastXMLElems.AddChild(const Value: TrmxFastXMLElem);
begin
  CreateElems;

  // If there already is a container, notify it to remove the element
  if Assigned(Value.Parent) then
    Value.Parent.Items.Notify(Value, opRemove);

  FElems.Add(Value);

  Notify(Value, opInsert);
end;
{______________________________________________________________________________}
procedure TrmxFastXMLElems.AddChildFirst(const Value: TrmxFastXMLElem);
begin
  CreateElems;

  // If there already is a container, notify it to remove the element
  if Assigned(Value.Parent) then
    Value.Parent.Items.Notify(Value, opRemove);

  FElems.Insert(0, Value);

  Notify(Value, opInsert);
end;
{______________________________________________________________________________}
function TrmxFastXMLElems.AddFirst(const Name: string): TrmxFastXMLElemClassic;
begin
  Result := TrmxFastXMLElemClassic.Create(Name);
  AddChildFirst(Result);
end;
{______________________________________________________________________________}
function TrmxFastXMLElems.AddFirst(Value: TrmxFastXMLElem): TrmxFastXMLElem;
begin
  if Value <> nil then
    AddChildFirst(Value);
  Result := Value;
end;
{______________________________________________________________________________}
function TrmxFastXMLElems.AddComment(const Name,Value: string): TrmxFastXMLElemComment;
begin
  Result := TrmxFastXMLElemComment.Create(Name, Value);
  AddChild(Result);
end;
{______________________________________________________________________________}
function TrmxFastXMLElems.AddCData(const Name, Value: string): TrmxFastXMLElemCData;
begin
  Result := TrmxFastXMLElemCData.Create(Name, Value);
  AddChild(Result);
end;
{______________________________________________________________________________}
function TrmxFastXMLElems.AddText(const Name, Value: string): TrmxFastXMLElemText;
begin
  Result := TrmxFastXMLElemText.Create(Name, Value);
  AddChild(Result);
end;
{______________________________________________________________________________}
procedure TrmxFastXMLElems.Delete(const Index: Integer);
begin
  if (FElems<> nil) then Begin
    if (Index >= 0) and (Index < FElems.Count) then begin
      FElems.Delete(Index);
    end end;
end;
{______________________________________________________________________________}
procedure TrmxFastXMLElems.Delete(const aName: string);
var Item:TrmxFastXMLBaseItem;
    I:Integer;
begin
  if FElems <> nil then Begin
    for I := 0 to Pred(FElems.Count) do Begin
      Item:=FElems[i];
      if SameText(Item.FName,aName) then Begin
        FElems.Delete(I);
        exit;
    end end end;
end;
{______________________________________________________________________________}
function TrmxFastXMLElems.GetItemNamed(const aName: string): TrmxFastXMLElem;
begin
  if not ItemByName(aName,Result) then Begin
    if Assigned(fParent) and Assigned(fParent.SimpleXML) and (sxoAutoCreate in fParent.SimpleXML.Options) then Begin
      Result := Add(aName, EmptyStr);
    end else
      Result := nil
    end
end;
{______________________________________________________________________________}
function TrmxFastXMLElems.GetItemNamedDef(const aName: string;const DefaultVal: string): TrmxFastXMLElem;
begin
  if not ItemByName(aName,Result) then Begin
    if Assigned(fParent) and Assigned(fParent.SimpleXML) and (sxoAutoCreate in fParent.SimpleXML.Options) then Begin
      Result := Add(aName, DefaultVal);
    end else
      Result := nil
    end
end;
{______________________________________________________________________________}
function TrmxFastXMLElems.GetItemNamedAsStr(const aName: string ): String;
var Item:TrmxFastXMLElem;
begin
  if not ItemByName(aName,Item) then Begin
    if Assigned(fParent) and Assigned(fParent.SimpleXML) and (sxoAutoCreate in fParent.SimpleXML.Options) then Begin
      Item:=Add(aName, EmptyStr);
      Result := Item.Value
    end else
      Result := EmptyStr;
  end else
    Result := Item.Value
end;
{______________________________________________________________________________}
function TrmxFastXMLElems.GetItemNamedAsStrDef(const aName: string;const DefaultVal: string ): String;
var Item:TrmxFastXMLElem;
begin
  if not ItemByName(aName,Item) then Begin
    if Assigned(fParent) and Assigned(fParent.SimpleXML) and (sxoAutoCreate in fParent.SimpleXML.Options) then Begin
      Item:=Add(aName, DefaultVal);
      Result := Item.Value
    end else
      Result := EmptyStr;
  end else
    Result := Item.Value
end;
{______________________________________________________________________________}
function TrmxFastXMLElems.GetItemNamedAsInt(const aName: string):Integer;
var Item:TrmxFastXMLElem;
begin
  if not ItemByName(aName,Item) then Begin
    if Assigned(fParent) and Assigned(fParent.SimpleXML) and (sxoAutoCreate in fParent.SimpleXML.Options) then Begin
      Item:=Add(aName, EmptyStr);
      Result := Item.Value.ToInteger
    end else
      Result := 0;
  end else
    Result := Item.Value.ToInteger
end;
{______________________________________________________________________________}
function TrmxFastXMLElems.GetItemNamedAsIntDef(const aName: string;const DefaultVal: Integer = 0): Integer;
var Item:TrmxFastXMLElem;
begin
  if not ItemByName(aName,Item) then Begin
    if Assigned(fParent) and Assigned(fParent.SimpleXML) and (sxoAutoCreate in fParent.SimpleXML.Options) then Begin
      Item:=Add(aName, DefaultVal);
      Result := Item.Value.ToInteger
    end else
      Result := 0;
  end else
    Result := Item.Value.ToInteger
end;
{______________________________________________________________________________}
function TrmxFastXMLElems.GetItemNamedAsXMLFloat(const aName: string): Extended;
var Item:TrmxFastXMLElem;
    tot:Extended;
begin
  if not ItemByName(aName,Item) then Begin
    if Assigned(fParent) and Assigned(fParent.SimpleXML) and (sxoAutoCreate in fParent.SimpleXML.Options) then Begin
      Item:=Add(aName, EmptyStr);
      Result := 0;
    end else
      Result := 0;
  end else
  if XML2Float(Item.Value,tot) then
    Result := tot else
    Result := 0
end;
{______________________________________________________________________________}
function TrmxFastXMLElems.GetItemNamedAsXMLFloatDef(const aName: string;const DefaultVal: Extended = 0): Extended;
var Item:TrmxFastXMLElem;
    tot:Extended;
begin
  if not ItemByName(aName,Item) then Begin
    if Assigned(fParent) and Assigned(fParent.SimpleXML) and (sxoAutoCreate in fParent.SimpleXML.Options) then Begin
      Item:=Add(aName, Float2XML(DefaultVal));
      Result := DefaultVal;
    end else
      Result := 0;
  end else
  if XML2Float(Item.Value,tot) then
    Result := tot else
    Result := 0
end;
{______________________________________________________________________________}
function TrmxFastXMLElems.GetItemNamedAsXMLDate(const aName: string): TDateTime;
var Item:TrmxFastXMLElem;
    dte:TDateTime;
begin
  if not ItemByName(aName,Item) then Begin
    if Assigned(fParent) and Assigned(fParent.SimpleXML) and (sxoAutoCreate in fParent.SimpleXML.Options) then Begin
      Item:=Add(aName, EmptyStr);
      Result := 0;
    end else
      Result := 0;
  end else
  if XML2Date(Item.Value,dte) then
    Result := dte else
    Result := 0
end;
{______________________________________________________________________________}
function TrmxFastXMLElems.GetItemNamedAsXMLDateDef(const aName: string;const DefaultVal: TDateTime = 0): TDateTime;
var Item:TrmxFastXMLElem;
    dte:TDateTime;
begin
  if not ItemByName(aName,Item) then Begin
    if Assigned(fParent) and Assigned(fParent.SimpleXML) and (sxoAutoCreate in fParent.SimpleXML.Options) then Begin
      Item:=Add(aName, Date2XML(DefaultVal));
      Result := DefaultVal;
    end else
      Result := 0;
  end else
  if XML2Date(Item.Value,dte) then
    Result := dte else
    Result := 0
end;
{______________________________________________________________________________}
function TrmxFastXMLElems.GetItemNamedAsXMLTime(const aName: string): TDateTime;
var Item:TrmxFastXMLElem;
    dte:TDateTime;
begin
  if not ItemByName(aName,Item) then Begin
    if Assigned(fParent) and Assigned(fParent.SimpleXML) and (sxoAutoCreate in fParent.SimpleXML.Options) then Begin
      Item:=Add(aName, EmptyStr);
      Result := 0;
    end else
      Result := 0;
  end else
  if XML2Time(Item.Value,dte) then
    Result := dte else
    Result := 0
end;
{______________________________________________________________________________}
function TrmxFastXMLElems.GetItemNamedAsXMLTimeDef(const aName: string;const DefaultVal: TDateTime = 0): TDateTime;
var Item:TrmxFastXMLElem;
    dte:TDateTime;
begin
  if not ItemByName(aName,Item) then Begin
    if Assigned(fParent) and Assigned(fParent.SimpleXML) and (sxoAutoCreate in fParent.SimpleXML.Options) then Begin
      Item:=Add(aName, Time2XML(DefaultVal));
      Result := DefaultVal;
    end else
      Result := 0;
  end else
  if XML2Time(Item.Value,dte) then
    Result := dte else
    Result := 0
end;
{______________________________________________________________________________}
function TrmxFastXMLElems.GetItemNamedAsXMLDateTime(const aName: string): TDateTime;
var Item:TrmxFastXMLElem;
    dte:TDateTime;
begin
  if not ItemByName(aName,Item) then Begin
    if Assigned(fParent) and Assigned(fParent.SimpleXML) and (sxoAutoCreate in fParent.SimpleXML.Options) then Begin
      Item:=Add(aName, EmptyStr);
      Result := 0;
    end else
      Result := 0;
  end else
  if XML2DateTime(Item.Value,dte) then
    Result := dte else
    Result := 0
end;
{______________________________________________________________________________}
function TrmxFastXMLElems.GetItemNamedAsXMLDateTimeDef(const aName: string;const DefaultVal: TDateTime = 0): TDateTime;
var Item:TrmxFastXMLElem;
    dte:TDateTime;
begin
  if not ItemByName(aName,Item) then Begin
    if Assigned(fParent) and Assigned(fParent.SimpleXML) and (sxoAutoCreate in fParent.SimpleXML.Options) then Begin
      Item:=Add(aName, DateTime2XML(DefaultVal));
      Result := DefaultVal;
    end else
      Result := 0;
  end else
  if XML2DateTime(Item.Value,dte) then
    Result := dte else
    Result := 0
end;
{______________________________________________________________________________}
procedure TrmxFastXMLElems.InternalLoad;
type TReadStatus = (rsWaitingTag, rsReadingTagKind);
var lPos: TReadStatus;
  lElem: TrmxFastXMLElem;
  ContainsText, ContainsWhiteSpace, KeepWhiteSpace: Boolean;
  SimpleXML: TrmxFastXML;
  st:TStringBuilder;
  len,cnt:Integer;
  ust:String;
  c:Char;
begin
  // We read from a stream, thus replacing the existing items
  Clear;

  // Init State
  cnt  := 0;
  lElem := nil;
  lPos := rsWaitingTag;
  SimpleXML := Parent.SimpleXML;
  KeepWhiteSpace := (SimpleXML <> nil) and (sxoKeepWhitespace in SimpleXML.Options);
  ContainsText := False;
  ContainsWhiteSpace := False;

  // Pop into st
  st:=TStringBuilder.Create;
  try len:=Length(FParent.FSimpleXML.fDataStream);
      While FParent.FSimpleXML.fDataStreamPos<len do Begin
        Inc(cnt);
        c:=FParent.FSimpleXML.fDataStream.Chars[FParent.FSimpleXML.fDataStreamPos];
        Inc(FParent.FSimpleXML.fDataStreamPos);
        case lPos of
          rsWaitingTag:Begin
            //We are waiting for a tag and thus avoiding spaces
            if c='<' then begin
              lPos := rsReadingTagKind;
              st.Append(c);
            end else
            if c.IsWhiteSpace then Begin
              ContainsWhiteSpace := True
            end else
              ContainsText := True;
            end;
          rsReadingTagKind:Begin
            //We are trying to determine the kind of the tag
            Assert(lElem=nil);
            lElem := nil;
            case c of
              '/':Begin
                if (st.Length=1)and(st.Chars[0]='<') then begin
                    Dec(FParent.FSimpleXML.fDataStreamPos,cnt);
                    // We have reached an end tag. If whitespace was found while
                    // waiting for the end tag, and the user told us to keep it
                    // then we have to create a text element.
                    // But it must only be created if there are no other elements
                    // in the list. If we did not check this, we would create a
                    // text element for whitespace found between two adjacent end
                    // tags.
                    if (ContainsText) or (ContainsWhiteSpace and KeepWhiteSpace) then begin
                      CreateElems;
                      lElem := TrmxFastXMLElemText.Create;
                      Notify(lElem,opInsert);
                      lElem.InternalLoad;
                      FElems.Add(lElem);
                      end;
                    Break;
                  end else begin
                    Assert(lElem=nil);
                    lElem:=TrmxFastXMLElemClassic.Create;
                    lPos:=rsWaitingTag;
                    // "<name/"
                end end;
              ' ','>',':':Begin
                 //This should be a classic tag
                  // "<XXX " or "<XXX:" or "<XXX>
                  Assert(lElem=nil);
                  lElem:=TrmxFastXMLElemClassic.Create;
                  lPos:=rsWaitingTag;
                  st.Clear;
                  end;
              else Begin
                  if ContainsText or (ContainsWhiteSpace and KeepWhiteSpace) then begin
                    // inner text
                    lElem := TrmxFastXMLElemText.Create;
                    lPos := rsReadingTagKind;
                    ContainsText := False;
                    ContainsWhiteSpace := False;
                  end else begin
                    ust:=UpperCase(St.ToString);
                    if (not SameStr(ust,'<![CDATA')) or (not c.IsWhiteSpace) then Begin
                      St.Append(C);
                      ust:=UpperCase(St.ToString);
                      end;
                    if SameStr(ust,'<![CDATA[') then begin
                      lElem := TrmxFastXMLElemCData.Create;
                      lPos := rsWaitingTag;
                      st.Clear;
                    end else
                    if SameStr(ust,'<!--') then begin
                      lElem := TrmxFastXMLElemComment.Create;
                      lPos := rsWaitingTag;
                      st.Clear;
                    end else
                    if SameStr(ust,'<?') then begin
                      lElem := TrmxFastXMLElemProcessingInstruction.Create;
                      lPos := rsWaitingTag;
                      St.Clear;
              end end end end;
            if lElem <> nil then begin
              CreateElems;
              Notify(lElem, opInsert);
              Dec(FParent.FSimpleXML.fDataStreamPos,cnt);
              lElem.InternalLoad;
              FElems.Add(lElem);
              lElem := nil;
              st.Clear;
              cnt:=0;
      end end end end;
  finally
      st.Free
  End;
end;
{______________________________________________________________________________}
procedure TrmxFastXMLElems.SaveToStringStream(Const StringStream: TStringStream;const Level: string);
var I: Integer;
begin
  if FElems <> nil then Begin
    for I := 0 to FElems.Count - 1 do
      FElems[I].SaveToStringStream(StringStream, Level);
    end;
end;
{______________________________________________________________________________}
procedure TrmxFastXMLElems.Move(const CurIndex, NewIndex: Integer);
begin
  if FElems <> nil then
    FElems.Move(CurIndex, NewIndex);
end;
{______________________________________________________________________________}
procedure TrmxFastXMLElems.InsertChild(const Value: TrmxFastXMLElem; Index: Integer);
begin
  CreateElems;

  // If there already is a container, notify it to remove the element
  if Assigned(Value.Parent) then
    Value.Parent.Items.Notify(Value, opRemove);

  FElems.Insert(Index, Value);

  Notify(Value, opInsert);
end;
{______________________________________________________________________________}
function TrmxFastXMLElems.Insert(Value: TrmxFastXMLElem;Index: Integer): TrmxFastXMLElem;
begin
  if Value <> nil then
    InsertChild(Value, Index);
  Result := Value;
end;
{______________________________________________________________________________}
function TrmxFastXMLElems.Insert(const Name: string;Index: Integer): TrmxFastXMLElemClassic;
begin
  Result := TrmxFastXMLElemClassic.Create(Name);
  InsertChild(Result, Index);
end;
{______________________________________________________________________________}
procedure QuickSort(Elems: TrmxFastXMLElems; List: TObjectList<TrmxFastXMLElem>; L, R: Integer; AFunction: TrmxFastXMLElemCompare);
var I, J, M: Integer;
begin
  repeat
        I := L;
        J := R;
        M := (L + R) shr 1;
        repeat
              while AFunction(Elems, I, M) < 0 do
                Inc(I);
              while AFunction(Elems, J, M) > 0 do
                Dec(J);
              if I < J then begin
                List.Exchange(I, J);
                Inc(I);
                Dec(J);
              end else
              if I = J then begin
                Inc(I);
                Dec(J);
                end;
        until I > J;
        if L < J then
          QuickSort(Elems, List, L, J, AFunction);
        L := I;
  until I >= R;
end;
{______________________________________________________________________________}
function TrmxFastXMLElems.SimpleCompare(Elems: TrmxFastXMLElems; Index1,Index2: Integer): Integer;
begin
  Result := CompareText(Elems.Item[Index1].Name, Elems.Item[Index2].Name);
end;
{______________________________________________________________________________}
procedure TrmxFastXMLElems.Sort;
begin
  if (FElems <> nil)and(FElems.Count>0) then
    CustomSort(SimpleCompare);
end;
{______________________________________________________________________________}
procedure TrmxFastXMLElems.CustomSort(Const AFunction: TrmxFastXMLElemCompare);
begin
  if (FElems <> nil)and(FElems.Count>0) then
    QuickSort(Self, FElems, 0, FElems.Count - 1, AFunction);
end;
{______________________________________________________________________________}
{______________________________________________________________________________}
{______________________________________________________________________________}
constructor TrmxFastXMLPropsEnumerator.Create(AList: TrmxFastXMLProps);
begin
  inherited Create;
  FIndex := -1;
  FList := AList;
end;
{______________________________________________________________________________}
function TrmxFastXMLPropsEnumerator.GetCurrent: TrmxFastXMLProp;
begin
  Result := FList[FIndex];
end;
{______________________________________________________________________________}
function TrmxFastXMLPropsEnumerator.MoveNext: Boolean;
begin
  Result := FIndex < FList.Count - 1;
  if Result then
    Inc(FIndex);
end;
{______________________________________________________________________________}
{______________________________________________________________________________}
{______________________________________________________________________________}
constructor TrmxFastXMLProps.Create(AParent: TrmxFastXMLElem);
begin
  inherited Create;
  FParent := AParent;
end;
{______________________________________________________________________________}
destructor TrmxFastXMLProps.Destroy;
begin
  FParent := nil;
  Clear;
  FreeAndNil(FProperties);
  inherited Destroy;
end;
{______________________________________________________________________________}
procedure TrmxFastXMLProps.Error(const S: string);
begin
  raise EFastXMLError.Create(S);
end;
{______________________________________________________________________________}
procedure TrmxFastXMLProps.FmtError(const S: string;const Args: array of const);
begin
  Error(Format(S, Args));
end;
{______________________________________________________________________________}
function TrmxFastXMLProps.GetCount: Integer;
begin
  if FProperties <> nil then begin
    Result := FProperties.Count;
  end else
    Result := 0
end;
{______________________________________________________________________________}
procedure TrmxFastXMLProps.Clear;
var I: Integer;
begin
  if FProperties <> nil then begin
    for I := 0 to FProperties.Count - 1 do begin
      TrmxFastXMLProp(FProperties.Objects[I]).Free;
      FProperties.Objects[I] := nil;
      end;
    FProperties.Clear;
    end;
end;
{______________________________________________________________________________}
procedure TrmxFastXMLProps.Delete(const Name: string);
begin
  if FProperties <> nil then
    Delete(FProperties.IndexOf(Name));
end;
{______________________________________________________________________________}
procedure TrmxFastXMLProps.Delete(const Index: Integer);
begin
  if (FProperties <> nil) and (Index >= 0) and (Index < FProperties.Count) then begin
    TObject(FProperties.Objects[Index]).Free;
    FProperties.Delete(Index);
    end;
end;
{______________________________________________________________________________}
function TrmxFastXMLProps.Add(const Name, Value: string): TrmxFastXMLProp;
begin
  if FProperties = nil then
    FProperties := TStringList.Create;
  Result := TrmxFastXMLProp.Create(Parent, Name, Value);
  FProperties.AddObject(Name, Result);
end;
{______________________________________________________________________________}
function TrmxFastXMLProps.Add(const Name: string; const Value: Int64): TrmxFastXMLProp;
begin
  Result := Add(Name, IntToStr(Value));
end;
{______________________________________________________________________________}
function TrmxFastXMLProps.Add(const Name: string; const Value: Boolean): TrmxFastXMLProp;
begin
  Result := Add(Name, BoolToStr(Value));
end;
{______________________________________________________________________________}
function TrmxFastXMLProps.Insert(const Index: Integer; const Name, Value: string): TrmxFastXMLProp;
begin
  if FProperties = nil then
    FProperties := TStringList.Create;
  Result := TrmxFastXMLProp.Create(Parent, Name, Value);
  FProperties.InsertObject(Index, Name, Result);
end;
{______________________________________________________________________________}
function TrmxFastXMLProps.Insert(const Index: Integer; const Name: string; const Value: Int64): TrmxFastXMLProp;
begin
  Result := Insert(Index, Name, IntToStr(Value));
end;
{______________________________________________________________________________}
function TrmxFastXMLProps.Insert(const Index: Integer; const Name: string; const Value: Boolean): TrmxFastXMLProp;
begin
  Result := Insert(Index, Name, BoolToStr(Value));
end;
{______________________________________________________________________________}
function TrmxFastXMLProps.BoolValue(const Name: string; Default: Boolean): Boolean;
var Prop: TrmxFastXMLProp;
begin
  try
      Prop := GetItemNamedDefault(Name, BoolToStr(Default));
      if (Prop = nil) or (Prop.Value = '') then
        Result := Default else
        Result := Prop.BoolValue;
  except
      Result := Default;
  end;
end;
{______________________________________________________________________________}
procedure TrmxFastXMLProps.DoItemRename(Value: TrmxFastXMLProp; const Name: string);
var I: Integer;
begin
  if FProperties = nil then
    Exit;
  I := FProperties.IndexOfObject(Value);
  if I <> -1 then
    FProperties[I] := Name;
end;
{______________________________________________________________________________}
function TrmxFastXMLProps.XMLFloat(const Name: string;const Default: Extended): Extended;
var Prop: TrmxFastXMLProp;
begin
  Prop := GetItemNamedDefault(Name, FloatToStr(Default));
  if Prop = nil then Begin
    Result := Default
  end else
    Result := Prop.XMLFloat;
end;
{______________________________________________________________________________}
function TrmxFastXMLProps.GetEnumerator: TrmxFastXMLPropsEnumerator;
begin
  Result := TrmxFastXMLPropsEnumerator.Create(Self);
end;
{______________________________________________________________________________}
function TrmxFastXMLProps.GetItem(const Index: Integer): TrmxFastXMLProp;
begin
  if FProperties <> nil then
    Result := TrmxFastXMLProp(FProperties.Objects[Index])
  else
    Result := nil;
end;
{______________________________________________________________________________}
function TrmxFastXMLProps.IndexOf(const aName: string): Integer;
begin
  if FProperties <> nil then begin
    result:= FProperties.IndexOf(aName);
  end else
    Result:=-1;
end;
{______________________________________________________________________________}
function TrmxFastXMLProps.PropertyByName(const Name: string;Out p: TrmxFastXMLProp):Boolean;
Var idx:Integer;
begin
  if FProperties <> nil then begin
    idx:= FProperties.IndexOf(Name);
    if idx>=0 then Begin
      p:=TrmxFastXMLProp(FProperties.Objects[idx]);
      Result:=True;
    end else Begin
      p:=nil;
      Result:=False;
      End;
  end else Begin
    p:=nil;
    Result:=False;
    End;
end;
{______________________________________________________________________________}
function TrmxFastXMLProps.GetItemNamedDefault(const Name, Default: string): TrmxFastXMLProp;
var I: Integer;
begin
  if FProperties <> nil then begin
    I := FProperties.IndexOf(Name);
    if I <> -1 then Begin
      Result := TrmxFastXMLProp(FProperties.Objects[I])
    end else
    if Assigned(FParent) and Assigned(FParent.SimpleXML) and (sxoAutoCreate in FParent.SimpleXML.Options) then Begin
      Result := Add(Name, Default);
    end else
      Result := nil;
  end else
  if Assigned(FParent) and Assigned(FParent.SimpleXML) and (sxoAutoCreate in FParent.SimpleXML.Options) then begin
    Result := Add(Name, Default);
  end else
    Result := nil;
end;
{______________________________________________________________________________}
function TrmxFastXMLProps.GetItemNamed(const Name: string): TrmxFastXMLProp;
begin
  Result := GetItemNamedDefault(Name, '');
end;
{______________________________________________________________________________}
function TrmxFastXMLProps.GetSimpleXML: TrmxFastXML;
begin
  if FParent <> nil then
    Result := FParent.SimpleXML
  else
    Result := nil;
end;
{______________________________________________________________________________}
function TrmxFastXMLProps.IntValue(const Name: string; const Default: Int64): Int64;
var Prop: TrmxFastXMLProp;
begin
  Prop := GetItemNamedDefault(Name, IntToStr(Default));
  if Prop = nil then
    Result := Default
  else
    Result := Prop.IntValue;
end;
{______________________________________________________________________________}
procedure TrmxFastXMLProps.InternalLoad;
//<element Prop="foo" Prop='bar' foo:bar="beuh"/>
//Stop on / or ? or >
type TPosType = (
    ptWaiting,
    ptReadingName,
    ptStartingContent,
    ptReadingValue,
    ptSpaceBeforeEqual
    );
var lPos: TPosType;
  st:TStringBuilder;
  StName, StValue, StNameSpace:String;
  prop:TrmxFastXMLProp;
  c, lPropStart:char;
  len:Integer;
begin
  // We read from a stream, thus replacing the existing properties
  Clear;

  // Pop into st
  st:=TStringBuilder.Create;
  try
      lPropStart:=' ';
      lPos := ptWaiting;

      len:=Length(FParent.FSimpleXML.fDataStream);
      While FParent.FSimpleXML.fDataStreamPos<len do Begin
        c:=FParent.FSimpleXML.fDataStream.Chars[FParent.FSimpleXML.fDataStreamPos];
        case lPos of
          ptWaiting:begin
            //We are waiting for a property
            if C.IsWhiteSpace then Begin
              Inc(FParent.FSimpleXML.fDataStreamPos);
            end else
            if (CharInSet(c,['-','.','_']))or(C.GetUnicodeCategory in [TUnicodeCategory.ucLowercaseLetter, TUnicodeCategory.ucModifierLetter,TUnicodeCategory.ucOtherLetter, TUnicodeCategory.ucTitlecaseLetter,TUnicodeCategory.ucUppercaseLetter,TUnicodeCategory.ucDecimalNumber,TUnicodeCategory.ucDecimalNumber,TUnicodeCategory.ucLetterNumber]) then Begin
              Inc(FParent.FSimpleXML.fDataStreamPos);
              lPos := ptReadingName;
              st.Append(C);
            end else
            if (CharInSet(c,['/','>','?'])) then Begin
              // end of properties
              Break
            end else
              FmtError(RsEInvalidXMLElementUnexpectedCharacte, [C,FParent.FSimpleXML.fDataStreamPos]);
            end;
          ptReadingName:begin
            //We are reading a property name
            Inc(FParent.FSimpleXML.fDataStreamPos);
            if (CharInSet(c,['-','.','_']))or(C.GetUnicodeCategory in [TUnicodeCategory.ucLowercaseLetter, TUnicodeCategory.ucModifierLetter,TUnicodeCategory.ucOtherLetter, TUnicodeCategory.ucTitlecaseLetter,TUnicodeCategory.ucUppercaseLetter,TUnicodeCategory.ucDecimalNumber,TUnicodeCategory.ucDecimalNumber,TUnicodeCategory.ucLetterNumber]) then Begin
              st.Append(C);
            end else
            if C=':' then begin
              StNameSpace:=St.ToString;St.Clear;
            end else
            if C = '=' then Begin
              StName:=St.ToString;St.Clear;
              lPos := ptStartingContent
            end else
            if c.IsWhiteSpace then Begin
              lPos := ptSpaceBeforeEqual
            end else
              FmtError(RsEInvalidXMLElementUnexpectedCharacte, [C,FParent.FSimpleXML.fDataStreamPos]);
            end;
          ptStartingContent:Begin
            //We are going to start a property content
            Inc(FParent.FSimpleXML.fDataStreamPos);
            if c.IsWhiteSpace then Begin
              // ignore white space
            end else
            if (CharInSet(C,['''','"'])) then begin
              lPos := ptReadingValue;
              lPropStart:=C;
              St.Clear;
            end else
              FmtError(RsEInvalidXMLElementUnexpectedCharacte, [c,FParent.FSimpleXML.fDataStreamPos]);
            end;
          ptReadingValue:Begin
            //We are reading a property
            Inc(FParent.FSimpleXML.fDataStreamPos);
            if c=lPropStart then begin
              StValue := st.ToString;st.Clear;
              if GetSimpleXML <> nil then
                GetSimpleXML.DoDecodeValue(StValue);
              prop:=Self.Add(StName,StValue);
              prop.NameSpace:=StNameSpace;
              lPos := ptWaiting;
            end else
              St.Append(C);
            end;
          ptSpaceBeforeEqual:begin
            // We are reading the white space between a property name and the = sign
            Inc(FParent.FSimpleXML.fDataStreamPos);
            if c.IsWhiteSpace then Begin
              // more white space, stay in this state and ignore
            end else
            if C = '=' then Begin
              lPos := ptStartingContent
            end else
              FmtError(RsEInvalidXMLElementUnexpectedCharacte, [c,FParent.FSimpleXML.fDataStreamPos]);
            end;
          else Begin
            FmtError(RsEInvalidXMLElementUnexpectedCharacte, [c,FParent.FSimpleXML.fDataStreamPos]);
        end end end;
  finally
      St.Free;
  end;
end;
{______________________________________________________________________________}
procedure TrmxFastXMLProps.SaveToStringStream(Const StringStream: TStringStream);
var I: Integer;
begin
  if FProperties <> nil then begin
    for I := 0 to FProperties.Count - 1 do
      TrmxFastXMLProp(FProperties.Objects[I]).SaveToStringStream(StringStream);
    end;
end;
{______________________________________________________________________________}
function TrmxFastXMLProps.Value(const Name, Default: string): string;
var  Prop: TrmxFastXMLProp;
begin
  Result := '';
  Prop := GetItemNamedDefault(Name, Default);
  if Prop = nil then
    Result := Default
  else
    Result := Prop.Value;
end;

//=== { TrmxFastXMLProp } ==================================================

constructor TrmxFastXMLProp.Create(AParent: TrmxFastXMLElem; const AName, AValue: string);
begin
  inherited Create(AName, AValue);
  FParent := AParent;
end;

function TrmxFastXMLProp.GetSimpleXML: TrmxFastXML;
begin
  if FParent <> nil then
    Result := FParent.SimpleXML
  else
    Result := nil;
end;

procedure TrmxFastXMLProp.SaveToStringStream(Const StringStream: TStringStream);
var
  AEncoder: TrmxFastXML;
  Tmp: string;
begin
  AEncoder := GetSimpleXML;
  Tmp := Value;
  if AEncoder <> nil then
    AEncoder.DoEncodeValue(Tmp);
  if NameSpace <> '' then
    Tmp := Format(' %s:%s="%s"', [NameSpace, Name, Tmp])
  else
    Tmp := Format(' %s="%s"', [Name, tmp]);
  StringStream.WriteString(Tmp)
end;

procedure TrmxFastXMLProp.SetName(const Value: string);
begin
  if (Value <> Name) and (Value <> '') then
  begin
    if (Parent <> nil) and (Name <> '') then
      FParent.Properties.DoItemRename(Self, Value);
    inherited SetName(Value);
  end;
end;
{______________________________________________________________________________}
procedure TrmxFastXMLElemClassic.InternalLoad;
type TReadStatus = (rsWaitingOpeningTag, rsOpeningName, rsTypeOpeningTag, rsEndSingleTag,rsWaitingClosingTag1, rsWaitingClosingTag2, rsClosingName);
var lPos: TReadStatus;
  StName,StNameSpace:String;
  St : TStringBuilder;
  sValue: string;
  len:Integer;
  C: Char;
begin
  // <element Prop="foo" Prop='bar'/>
  // <element Prop="foo" Prop='bar'>foor<b>beuh</b>bar</element>
  // <xml:element Prop="foo" Prop='bar'>foor<b>beuh</b>bar</element>

  // Init State
  lPos := rsWaitingOpeningTag;

  // Pop into st
  st:=TStringBuilder.Create;
  try
     len:=Length(FSimpleXML.fDataStream);
      While FSimpleXML.fDataStreamPos<len do Begin
        c:=FSimpleXML.fDataStream.Chars[FSimpleXML.fDataStreamPos];
        Inc(FSimpleXML.fDataStreamPos);
        case lPos of
          rsWaitingOpeningTag:Begin
            // wait beginning of tag
            if C = '<' then Begin
              lPos := rsOpeningName; // read name
            end else
            if not c.IsWhiteSpace then
              FmtError(RsEInvalidXMLElementExpectedBeginningO, [c,FSimpleXML.fDataStreamPos]);
            end;
          rsOpeningName:Begin
            if (CharInSet(c,['_','-','.']))or(C.GetUnicodeCategory in [TUnicodeCategory.ucLowercaseLetter, TUnicodeCategory.ucModifierLetter,TUnicodeCategory.ucOtherLetter, TUnicodeCategory.ucTitlecaseLetter,TUnicodeCategory.ucUppercaseLetter,TUnicodeCategory.ucDecimalNumber,TUnicodeCategory.ucDecimalNumber,TUnicodeCategory.ucLetterNumber]) then Begin
              St.Append(c);
            end else
            if (C = ':') and (StNameSpace.Length = 0) then begin
              StNameSpace:=st.ToString;st.Clear;
            end else
            if (c.IsWhiteSpace) Then Begin
              if (St.Length=0) then Begin
                // whitespace after "<" (no name)
                FmtError(RsEInvalidXMLElementMalformedTagFoundn, [FSimpleXML.fDataStreamPos])
                end;
              StName:=St.ToString;St.Clear;
              Properties.InternalLoad;
              lPos := rsTypeOpeningTag;
            end else
            if C = '/' then Begin
              // single tag
              StName:=St.ToString;St.Clear;
              lPos := rsEndSingleTag
            end else
            if C = '>' then Begin
              // 2 tags
              StName := St.ToString;St.Clear;
              //Load elements
              Self.Items.InternalLoad;
              lPos := rsWaitingClosingTag1;
            end else Begin
              // other invalid characters
              FmtError(RsEInvalidXMLElementMalformedTagFoundn, [FSimpleXML.fDataStreamPos]);
            end end;
          rsTypeOpeningTag:Begin
            if C.IsWhiteSpace then Begin
              // nothing, spaces after name or properties
            end else
            if C = '/' then Begin
              // single tag
              lPos := rsEndSingleTag
            end else
            if C = '>' then begin
              // 2 tags >> Load elements
              Items.InternalLoad;
              lPos := rsWaitingClosingTag1;
            end else Begin
              FmtError(RsEInvalidXMLElementExpectedEndOfTagBu, [c,FSimpleXML.fDataStreamPos]);
            end end;
          rsEndSingleTag:Begin
            if C = '>' then Begin
              Break
            end else
              FmtError(RsEInvalidXMLElementExpectedEndOfTagBu, [c,FSimpleXML.fDataStreamPos]);
            end;
          rsWaitingClosingTag1:Begin
            if c.IsWhiteSpace then Begin
              // nothing, spaces before closing tag
            end else
            if c = '<' then Begin
              lPos := rsWaitingClosingTag2
            end else
              FmtError(RsEInvalidXMLElementExpectedEndOfTagBu, [c,FSimpleXML.fDataStreamPos]);
            end;
          rsWaitingClosingTag2:Begin
            if C = '/' then
              lPos := rsClosingName
            else
              FmtError(RsEInvalidXMLElementExpectedEndOfTagBu, [c,FSimpleXML.fDataStreamPos]);
            end;
          rsClosingName:Begin
            if (c.IsWhiteSpace) or (C = '>') then begin
              if StNameSpace.Length > 0 then begin
                if not SameText(StNameSpace+':'+StName,St.ToString) then
                  FmtError(RsEInvalidXMLElementErroneousEndOfTagE, [StName,St.ToString,FSimpleXML.fDataStreamPos]);
              end else
                if not SameText(StName, St.ToString) then
                  FmtError(RsEInvalidXMLElementErroneousEndOfTagE, [StName, St.ToString, FSimpleXML.fDataStreamPos]);
              //Set value if only one sub element
              //This might reduce speed, but this is for compatibility issues
              if (Items.Count = 1) and (Items[0] is TrmxFastXMLElemText) then begin
                sValue := fItems[0].Value;
                fItems.Clear;
                // free some memory
                FreeAndNil(FItems);
                end;
              Break;
            end else
            if (CharInSet(c,['_','-','.',':']))or(C.GetUnicodeCategory in [TUnicodeCategory.ucLowercaseLetter, TUnicodeCategory.ucModifierLetter,TUnicodeCategory.ucOtherLetter, TUnicodeCategory.ucTitlecaseLetter,TUnicodeCategory.ucUppercaseLetter,TUnicodeCategory.ucDecimalNumber,TUnicodeCategory.ucLetterNumber]) then Begin
              St.Append(c)
            end else
              // other invalid characters
              FmtError(RsEInvalidXMLElementMalformedTagFoundn, [FSimpleXML.fDataStreamPos]);
        end end end;

      Self.SetName(StName);
      if SimpleXML <> nil then
        SimpleXML.DoDecodeValue(sValue);
      Self.fValue := sValue;
      Self.FNameSpace := StNameSpace;

  finally
      st.Free;
  end;
end;
{______________________________________________________________________________}
procedure TrmxFastXMLElemClassic.SaveToStringStream(Const StringStream: TStringStream; const Level: string);
var St, AName, tmp: string;
    AutoIndent: Boolean;
    LevelAdd: string;
begin
  if(NameSpace <> '') then
    AName := Self.NameSpace + ':' + Self.Name else
    AName := Self.Name;

  if Self.Name <> '' then begin
    if SimpleXML <> nil then
       SimpleXML.DoEncodeValue(AName);
    St := Level + '<' + AName;
    StringStream.WriteString(St);
    if Assigned(FProps) then
      FProps.SaveToStringStream(StringStream);
    end;

  AutoIndent := (SimpleXML <> nil) and (sxoAutoIndent in SimpleXML.Options);

  if (ItemCount = 0) then begin
    tmp := Self.Value;
    if (Self.Name <> '') then begin
      if Self.Value = '' then begin
        if AutoIndent then
          St := '/>' + sLineBreak else
          St := '/>';
      end else begin
        if SimpleXML <> nil then
          SimpleXML.DoEncodeValue(tmp);
        if AutoIndent then
          St := '>' + tmp + '</' + AName + '>' + sLineBreak else
          St := '>' + tmp + '</' + AName + '>';
        end;
      StringStream.WriteString(St);
      end
  end else begin
    if (Name <> '') then begin
      if AutoIndent then
        St := '>' + sLineBreak else
        St := '>';
      StringStream.WriteString(St);
      end;
    if AutoIndent then begin
      LevelAdd := SimpleXML.IndentString;
      end;
    FItems.SaveToStringStream(StringStream, Level + LevelAdd);
    if Name <> '' then begin
      if AutoIndent then
        St := Level + '</' + AName + '>' + sLineBreak else
        St := Level + '</' + AName + '>';
      StringStream.WriteString(St);
    end end;
end;

//=== { TrmxFastXMLElemComment } ===========================================

procedure TrmxFastXMLElemComment.InternalLoad;
//<!-- declarations for <head> & <body> -->
const CS_START_COMMENT = '<!--';
      CS_STOP_COMMENT  = '    -->';
var lPos: Integer;
    St: TStringBuilder;
    len:Integer;
    lOk: Boolean;
    C: Char;
begin
  // Init State
  lPos := 1;
  lOk := False;

  // Pop into st
  st:=TStringBuilder.Create;
  try len:=Length(FSimpleXML.fDataStream);
      While FSimpleXML.fDataStreamPos<len do Begin
        c:=FSimpleXML.fDataStream.Chars[FSimpleXML.fDataStreamPos];
        Inc(FSimpleXML.fDataStreamPos);
        case lPos of
          1..4:Begin
            //<!--
            if C = CS_START_COMMENT[lPos] then Begin
              Inc(lPos)
            end else
            if not c.IsWhiteSpace then
              FmtError(RsEInvalidCommentExpectedsButFounds, [CS_START_COMMENT[lPos], C, FSimpleXML.fDataStreamPos]);
            end;
          5:Begin
            if C = CS_STOP_COMMENT[lPos] then Begin
              Inc(lPos)
            end else
              St.Append(c);
            end;
          6:Begin
            //-
            if C = CS_STOP_COMMENT[lPos] then Begin
              Inc(lPos)
            end else Begin
              St.Append('-');
              St.Append(c);
              Dec(lPos);
            end end;
          7:Begin
            //>
            if C = CS_STOP_COMMENT[lPos] then begin
              lOk := True;
              Break;
            end else Begin
              // -- is not authorized in comments
              FmtError(RsEInvalidCommentNotAllowedInsideComme, [FSimpleXML.fDataStreamPos]);
        end end end end;

      if not lOk then
        FmtError(RsEInvalidCommentUnexpectedEndOfData, [FSimpleXML.fDataStreamPos]);

      Self.Value := St.ToString;
      Self.Name  := '';
  finally
      st.Free
  End;
end;

procedure TrmxFastXMLElemComment.SaveToStringStream(Const StringStream: TStringStream; const Level: string);
var St: string;
begin
  St := Level + '<!--';
  StringStream.WriteString(St);
  if Self.Value <> '' then
    StringStream.WriteString(Self.Value);
  if (SimpleXML <> nil) and (sxoAutoIndent in SimpleXML.Options) then
    St := '-->' + sLineBreak else
    St := '-->';
  StringStream.WriteString(St);
end;

//=== { TrmxFastXMLElemCData } =============================================

procedure TrmxFastXMLElemCData.InternalLoad;
//<![CDATA[<greeting>Hello, world!</greeting>]]>
const CS_START_CDATA = '<![CDATA[';
      CS_STOP_CDATA  = '         ]]>';
var lPos: Integer;
  St: TStringBuilder;
  len:Integer;
  lOk: Boolean;
  C: Char;
begin
  // Init State
  lPos := 1;
  lOk  := False;

  // Pop into st
  st:=TStringBuilder.Create;
  try len:=Length(FSimpleXML.fDataStream);
      While FSimpleXML.fDataStreamPos < len do Begin
        c:=FSimpleXML.fDataStream.Chars[FSimpleXML.fDataStreamPos];
        Inc(FSimpleXML.fDataStreamPos);
        case lPos of
          1..9:Begin //<![CDATA[
            if C = CS_START_CDATA[lPos] then Begin
              Inc(lPos)
            end else
            if not c.IsWhiteSpace then
              FmtError(RsEInvalidCDATAExpectedsButFounds, [CS_START_CDATA[lPos], C, FSimpleXML.fDataStreamPos]);
            end;
          10:Begin
            // ]
            if C = CS_STOP_CDATA[lPos] then Begin
              Inc(lPos)
            end else Begin
              St.Append(c);
            end end;
          11:Begin
            // ]
            if C = CS_STOP_CDATA[lPos] then Begin
              Inc(lPos)
            end else begin
              St.Append(']').Append(c);
              Dec(lPos);
            end end;
          12:Begin
            //>
            if C = CS_STOP_CDATA[lPos] then begin
              lOk := True;
              Break;
            end else
            // ]]]
            if C = CS_STOP_CDATA[lPos-1] then Begin
              st.Append(']')
            end else begin
              st.Append(']]').Append(c);
              Dec(lPos, 2);
        end end end end;

      if not lOk then
        FmtError(RsEInvalidCDATAUnexpectedEndOfData, [FSimpleXML.fDataStreamPos]);

      Self.Value := St.ToString;
      Self.Name  := '';
  finally
      St.Free
  end;
end;

procedure TrmxFastXMLElemCData.SaveToStringStream(Const StringStream: TStringStream; const Level: string);
var St: string;
begin
  St := Level + '<![CDATA[';
  StringStream.WriteString(St);
  if Value <> '' then Begin
    StringStream.WriteString(Value);
    end;
  if (SimpleXML <> nil) and (sxoAutoIndent in SimpleXML.Options) then
    St := ']]>' + sLineBreak else
    St := ']]>';
  StringStream.WriteString(St);
end;

//=== { TrmxFastXMLElemText } ==============================================

procedure TrmxFastXMLElemText.InternalLoad;
var StValue,TrimValue:string;
    st: TStringBuilder;
    len:Integer;
    C: Char;
begin
  // Pop into st
  st:=TStringBuilder.Create;
  try len:=Length(FSimpleXML.fDataStream);
      While FSimpleXML.fDataStreamPos<len do Begin
        c:=FSimpleXML.fDataStream.Chars[FSimpleXML.fDataStreamPos];
        case C of
          '<':Begin
            //Quit text
            Break;
            end;
          else begin
            Inc(FSimpleXML.fDataStreamPos);
            st.Append(C);
        end end end;

      StValue:= st.ToString;
      if Assigned(SimpleXML) then begin
        SimpleXML.DoDecodeValue(StValue);
        TrimValue := StValue;
        if sxoTrimPrecedingTextWhitespace in SimpleXML.Options then
          TrimValue := TrimLeft(TrimValue);
        if sxoTrimFollowingTextWhitespace in SimpleXML.Options then
          TrimValue := TrimRight(TrimValue);
        if (TrimValue <> '') or (not (sxoKeepWhitespace in SimpleXML.Options)) then
          StValue := TrimValue;
        end;

      Self.Value := StValue;
      Self.Name  := '';
  finally
      st.Free
  end;
end;

procedure TrmxFastXMLElemText.SaveToStringStream(Const StringStream: TStringStream; const Level: string);
var St, tmp: string;
begin
  // should never be used
  if Value <> '' then begin
    tmp := Value;
    if SimpleXML <> nil then
      SimpleXML.DoEncodeValue(tmp);
    if (SimpleXML <> nil) and (sxoAutoIndent in SimpleXML.Options) then
      St := Level + tmp + sLineBreak else
      St := Level + tmp;
    StringStream.WriteString(St);
    end;
end;

//=== { TrmxFastXMLElemProcessingInstruction } =============================
procedure TrmxFastXMLElemProcessingInstruction.InternalLoad;
type TReadStatus = (rsWaitingOpeningTag, rsOpeningTag, rsOpeningName, rsEndTag1, rsEndTag2);
var lPos: TReadStatus;
  lName, lNameSpace : String;
  St: TStringBuilder;
  len:Integer;
  lOk: Boolean;
  C: Char;
begin
  // Init State
  lPos := rsWaitingOpeningTag;
  lOk  := False;

  // Pop into st
  st:=TStringBuilder.Create;
  try len:=Length(FSimpleXML.fDataStream);
      While FSimpleXML.fDataStreamPos<len do Begin
        c:=FSimpleXML.fDataStream.Chars[FSimpleXML.fDataStreamPos];
        Inc(FSimpleXML.fDataStreamPos);
        case lPos of
          rsWaitingOpeningTag:Begin
            // wait beginning of tag
            if C = '<' then Begin
              lPos := rsOpeningTag
            end else
            if not c.IsWhiteSpace then
              FmtError(RsEInvalidXMLElementExpectedBeginningO, [c,FSimpleXML.fDataStreamPos]);
            end;
          rsOpeningTag:Begin
            if C = '?' then Begin
              lPos := rsOpeningName // read name
            end else
              FmtError(RsEInvalidXMLElementMalformedTagFoundn, [FSimpleXML.fDataStreamPos]);
            end;
          rsOpeningName:Begin
            if (CharInSet(c,['-','.']))or(C.GetUnicodeCategory in [TUnicodeCategory.ucLowercaseLetter, TUnicodeCategory.ucModifierLetter,TUnicodeCategory.ucOtherLetter, TUnicodeCategory.ucTitlecaseLetter,TUnicodeCategory.ucUppercaseLetter,TUnicodeCategory.ucDecimalNumber,TUnicodeCategory.ucLetterNumber]) then Begin
              St.Append(c)
            end else
            if (C = ':') and (lNameSpace.Length = 0) then begin
              lNameSpace := St.ToString; St.Clear
            end else
            if (c.IsWhiteSpace) Then Begin
              if (St.Length = 0) then Begin
                // whitespace after "<" (no name)
                FmtError(RsEInvalidXMLElementMalformedTagFoundn, [FSimpleXML.fDataStreamPos])
                end;
              lName := St.ToString; St.Clear;
              Properties.InternalLoad;
              lPos := rsEndTag1;
            end else
            if C = '?' then begin
              lName := St.ToString;
              lPos := rsEndTag2;
            end else
              // other invalid characters
              FmtError(RsEInvalidXMLElementMalformedTagFoundn, [FSimpleXML.fDataStreamPos]);
            end;
          rsEndTag1:Begin
            if C = '?' then Begin
              lPos := rsEndTag2
            end else
            if (not c.IsWhiteSpace) then
              FmtError(RsEInvalidXMLElementExpectedEndOfTagBu, [c,FSimpleXML.fDataStreamPos]);
            end;
          rsEndTag2:Begin
            if C = '>' then begin
              lOk := True;
              Break;
            end else
              FmtError(RsEInvalidXMLElementExpectedEndOfTagBu, [c,FSimpleXML.fDataStreamPos]);
        end end end;

      if not lOk then
        FmtError(RsEInvalidCommentUnexpectedEndOfData, [FSimpleXML.fDataStreamPos]);

      Self.Name      := lName;
      Self.NameSpace := lNameSpace;
  finally
      st.Free
  end;
end;

procedure TrmxFastXMLElemProcessingInstruction.SaveToStringStream(Const StringStream: TStringStream; const Level: string);
var St: string;
begin
  St := Level + '<?';
  if NameSpace <> '' then
    St := St + NameSpace + ':' + Name else
    St := St + Name;
  StringStream.WriteString(St);
  if Assigned(FProps) then
    FProps.SaveToStringStream(StringStream);
  if (SimpleXML <> nil) and (sxoAutoIndent in SimpleXML.Options) then
    St := '?>' + sLineBreak else
    St := '?>';
  StringStream.WriteString(St);
end;

//=== { TrmxFastXMLElemHeader } ============================================

constructor TrmxFastXMLElemHeader.Create;
begin
  inherited Create;
  Self.Name := 'xml';
end;

function TrmxFastXMLElemHeader.GetEncoding: string;
var ASimpleXML: TrmxFastXML;
    DefaultEncoding:String;
begin
  ASimpleXML := SimpleXML;
  if Assigned(ASimpleXML) then begin
    if ASimpleXML.FEncoding<>nil then Begin
      case ASimpleXML.FEncoding.CodePage of
        CP_UTF7:DefaultEncoding:='UTF-7';
        else DefaultEncoding:='UTF-8';
        end;
    End else
      DefaultEncoding:='UTF-8';
  end else
    DefaultEncoding:='UTF-8';
  Result := Properties.Value('encoding', DefaultEncoding);
end;

function TrmxFastXMLElemHeader.GetStandalone: Boolean;
begin
  Result := Properties.Value('standalone') = 'yes';
end;

function TrmxFastXMLElemHeader.GetVersion: string;
begin
  Result := Properties.Value('version', '1.0');
end;

procedure TrmxFastXMLElemHeader.InternalLoad;
//<?xml version="1.0" encoding="iso-xyzxx" standalone="yes"?>
var EncodingProp: TrmxFastXMLProp;
    Encoding:Cardinal;
begin
  inherited InternalLoad;

  if Assigned(FProps) then
    EncodingProp := FProps.ItemNamed['encoding'] else
    EncodingProp := nil;

  Encoding := CP_UTF8;
  if Assigned(EncodingProp) and (EncodingProp.Value <> '') then Begin
    if SameText(EncodingProp.Value,'UTF-8') then
      Encoding := CP_UTF8 else
      Error(RsENoCharset);
    end;

  // Check current stringstream codepage
  if FSimpleXML.fDataStreamCodePage<>Encoding then
    Error(RsENoCharset);
end;

procedure TrmxFastXMLElemHeader.SaveToStringStream(
  Const StringStream: TStringStream; const Level: string);
begin
  SetVersion(GetVersion);
  SetEncoding(GetEncoding);
  SetStandalone(GetStandalone);

  inherited SaveToStringStream(StringStream, Level);
end;

procedure TrmxFastXMLElemHeader.SetEncoding(const Value: string);
var
  Prop: TrmxFastXMLProp;
begin
  Prop := Properties.ItemNamed['encoding'];
  if Assigned(Prop) then
    Prop.Value := Value
  else
    Properties.Add('encoding', Value);
end;

procedure TrmxFastXMLElemHeader.SetStandalone(const Value: Boolean);
var
  Prop: TrmxFastXMLProp;
const
  BooleanValues: array [Boolean] of string = ('no', 'yes');
begin
  Prop := Properties.ItemNamed['standalone'];
  if Assigned(Prop) then
    Prop.Value := BooleanValues[Value]
  else
    Properties.Add('standalone', BooleanValues[Value]);
end;

procedure TrmxFastXMLElemHeader.SetVersion(const Value: string);
var
  Prop: TrmxFastXMLProp;
begin
  Prop := Properties.ItemNamed['version'];
  if Assigned(Prop) then
    Prop.Value := Value
  else
    // Various XML parsers (including MSIE, Firefox) require the "version" to be the first
    Properties.Insert(0, 'version', Value);
end;

//=== { TrmxFastXMLElemDocType } ===========================================

procedure TrmxFastXMLElemDocType.InternalLoad;
{
<!DOCTYPE test [
<!ELEMENT test (#PCDATA) >
<!ENTITY % xx '&#37;zz;'>
<!ENTITY % zz '&#60;!ENTITY tricky "error-prone" >' >
%xx;
]>

<!DOCTYPE greeting SYSTEM "hello.dtd">
}
const CS_START_DOCTYPE = '<!DOCTYPE';
var lPos: Integer;
  lOk: Boolean;
  C, lC: Char;
  St: TStringBuilder;
  len:Integer;
begin
  // Init State
  lPos := 1;
  lOk := False;
  lC  := '>';

  // Pop into st
  st:=TStringBuilder.Create;
  try len:=Length(FSimpleXML.fDataStream);
      While FSimpleXML.fDataStreamPos < len do Begin
        c:=FSimpleXML.fDataStream.Chars[FSimpleXML.fDataStreamPos];
        Inc(FSimpleXML.fDataStreamPos);
        case lPos of
          1..9:Begin
            //<!DOCTYPE
            if C = CS_START_DOCTYPE[lPos] then Begin
              Inc(lPos)
            end else
            if (not c.IsWhiteSpace) then
              FmtError(RsEInvalidHeaderExpectedsButFounds, [CS_START_DOCTYPE[lPos],c,FSimpleXML.fDataStreamPos]);
            end;
          10:Begin
            //]> or >
            if lC = C then begin
              if lC = '>' then begin
                lOk := True;
                Break; //This is the end
              end else begin
                St.Append(c);
                lC:='>';
                end;
            end else begin
              st.Append(c);
              if C = '[' then
                lC:= ']';
        end end end end;

      if not lOk then
        FmtError(RsEInvalidCommentUnexpectedEndOfData, [FSimpleXML.fDataStreamPos]);

      Self.Name  := '';
      Self.Value := St.ToString.TrimLeft;

  finally
      st.Free
  end;
end;

procedure TrmxFastXMLElemDocType.SaveToStringStream(Const StringStream: TStringStream; const Level: string);
var St: string;
begin
  if (SimpleXML <> nil) and (sxoAutoIndent in SimpleXML.Options) then
    St := Level + '<!DOCTYPE ' + Value + '>' + sLineBreak else
    St := Level + '<!DOCTYPE ' + Value + '>';
  StringStream.WriteString(St)
end;

//=== { TrmxFastXMLElemsPrologEnumerator } =================================

constructor TrmxFastXMLElemsPrologEnumerator.Create(AList: TrmxFastXMLElemsProlog);
begin
  inherited Create;
  FIndex := -1;
  FList := AList;
end;

function TrmxFastXMLElemsPrologEnumerator.GetCurrent: TrmxFastXMLElem;
begin
  Result := FList[FIndex];
end;

function TrmxFastXMLElemsPrologEnumerator.MoveNext: Boolean;
begin
  Result := FIndex < FList.Count - 1;
  if Result then
    Inc(FIndex);
end;

//=== { TrmxFastXMLElemsProlog } ===========================================

constructor TrmxFastXMLElemsProlog.Create(ASimpleXML: TrmxFastXML);
begin
  inherited Create;
  FSimpleXML := ASimpleXML;
  FElems := TObjectList<TrmxFastXMLElem>.Create(True);
end;

destructor TrmxFastXMLElemsProlog.Destroy;
begin
  FElems.Clear;
  FreeAndNil(FElems);
  inherited Destroy;
end;

procedure TrmxFastXMLElemsProlog.Clear;
begin
  FElems.Clear;
end;

function TrmxFastXMLElemsProlog.GetCount: Integer;
begin
  Result := FElems.Count;
end;

function TrmxFastXMLElemsProlog.GetItem(const Index: Integer): TrmxFastXMLElem;
begin
  Result := FElems[Index];
end;
{______________________________________________________________________________}
procedure TrmxFastXMLElemsProlog.InternalLoad;
{<?xml version="1.0" encoding="UTF-8" ?>
<!-- Test -->
<!DOCTYPE greeting [
  <!ELEMENT greeting (#PCDATA)>
]>
<greeting>Hello, world!</greeting>

<?xml version="1.0"?> <!DOCTYPE greeting SYSTEM "hello.dtd"> <greeting>Hello, world!</greeting>
}
var
  lPos: Integer;
  St: TStringBuilder;
  lEnd: Boolean;
  lElem: TrmxFastXMLElem;
  len,Cnt:Integer;
  C: Char;
begin
  // Init State
  lPos := 0;
  Cnt  := 0;

  // Pop into st
  st:=TStringBuilder.Create;
  try len:=Length(FSimpleXML.fDataStream);
      While FSimpleXML.fDataStreamPos<len do Begin
        Inc(Cnt);
        c:=FSimpleXML.fDataStream.Chars[FSimpleXML.fDataStreamPos];
        Inc(FSimpleXML.fDataStreamPos);
        case lPos of
          0:begin
            //We are waiting for a tag and thus avoiding spaces and any BOM
            if (c.IsWhiteSpace) then Begin
                // still waiting
            end else
            if C = '<' then begin
              lPos := 1;
              St.Append(c)
            end else
              FmtError(RsEInvalidDocumentUnexpectedTextInFile,[FSimpleXML.fDataStreamPos]);
            end;
          1:Begin
            //We are trying to determine the kind of the tag
            lElem := nil;
            lEnd := False;
            if (not SameText(St.ToString, '<![CDATA')) or (not c.IsWhiteSpace) then
              St.Append(c);

            if SameText(St.ToString,'<![CDATA[') then Begin
              lEnd := True
            end else
            if SameText(St.ToString,'<!--') then begin
              lElem := TrmxFastXMLElemComment.Create(SimpleXML)
            end else
            if SameText(St.ToString, '<?xml-stylesheet') then begin
              lElem := TrmxFastXMLElemProcessingInstruction.Create(SimpleXML)
            end else
            if SameText(St.ToString, '<?xml ') then Begin
              lElem := TrmxFastXMLElemHeader.Create(SimpleXML)
            end else
            if SameText(St.ToString, '<!DOCTYPE') then begin
              lElem := TrmxFastXMLElemDocType.Create(SimpleXML)
            end else
            if SameText(St.ToString, '<?mso-application') then Begin
              lElem := TrmxFastXMLElemProcessingInstruction.Create(SimpleXML)
            end else
            if (St.Length > 3) and (St.Chars[1] = '?') and (St.Chars[Pred(St.Length)].IsWhiteSpace) then Begin
              lElem := TrmxFastXMLElemProcessingInstruction.Create(SimpleXML)
            end else
            if (St.Length > 1) and (Not CharInSet(St.Chars[1],['!','?'])) then Begin
              lEnd := True;
            End else Begin
              // ?
              end;

            if lEnd then Begin
              Dec(FSimpleXML.fDataStreamPos,Cnt);
              Break
            end else
            if lElem <> nil then begin
              FElems.Add(lElem);
              Dec(FSimpleXML.fDataStreamPos,Cnt);
              lElem.InternalLoad;
              St.Clear;
              lPos := 0;
              Cnt := 0;
      end end end end;
  finally
      st.Free
  end;
end;

procedure TrmxFastXMLElemsProlog.SaveToStringStream(Const StringStream: TStringStream);
var I: Integer;
begin
  Self.FindHeader;
  for I := 0 to Count - 1 do
    Item[I].SaveToStringStream(StringStream, '');
end;

procedure TrmxFastXMLElemsProlog.Error(const S: string);
begin
  raise EFastXMLError.Create(S);
end;

procedure TrmxFastXMLElemsProlog.FmtError(const S: string;const Args: array of const);
begin
  Error(Format(S, Args));
end;

procedure TrmxFastXML.SetIndentString(const Value: string);
Var c:Char;
begin
  // test if the new value is only made of spaces or tabs
  for c in Value do
    if not c.IsWhiteSpace then
      exit;

  FIndentString := Value;
end;

function TrmxFastXMLElemsProlog.GetEncoding: string;
var Elem: TrmxFastXMLElemHeader;
begin
  Elem := TrmxFastXMLElemHeader(FindHeader);
  if Elem <> nil then
    Result := Elem.Encoding else
    Result :='UTF-8';
end;

function TrmxFastXMLElemsProlog.GetEnumerator: TrmxFastXMLElemsPrologEnumerator;
begin
  Result := TrmxFastXMLElemsPrologEnumerator.Create(Self);
end;

function TrmxFastXMLElemsProlog.GetStandAlone: Boolean;
var Elem: TrmxFastXMLElemHeader;
begin
  Elem := TrmxFastXMLElemHeader(FindHeader);
  if Elem <> nil then
    Result := Elem.StandAlone else
    Result := False;
end;

function TrmxFastXMLElemsProlog.GetVersion: string;
var Elem: TrmxFastXMLElemHeader;
begin
  Elem := TrmxFastXMLElemHeader(FindHeader);
  if Elem <> nil then
    Result := Elem.Version else
    Result :='1.0';
end;

procedure TrmxFastXMLElemsProlog.SetEncoding(const Value: string);
var Elem: TrmxFastXMLElemHeader;
begin
  Elem := TrmxFastXMLElemHeader(FindHeader);
  if Elem <> nil then
    Elem.Encoding := Value else
    Error(RsENoHeader);
end;

procedure TrmxFastXMLElemsProlog.SetStandAlone(const Value: Boolean);
var Elem: TrmxFastXMLElemHeader;
begin
  Elem := TrmxFastXMLElemHeader(FindHeader);
  if Elem <> nil then
    Elem.StandAlone := Value else
    Error(RsENoHeader);
end;

procedure TrmxFastXMLElemsProlog.SetVersion(const Value: string);
var Elem: TrmxFastXMLElemHeader;
begin
  Elem := TrmxFastXMLElemHeader(FindHeader);
  if Elem <> nil then
    Elem.Version := Value else
    Error(RsENoHeader);
end;

function TrmxFastXMLElemsProlog.FindHeader: TrmxFastXMLElem;
var I: Integer;
begin
  for I := 0 to Count - 1 do Begin
    if Item[I] is TrmxFastXMLElemHeader then begin
      Result := Item[I];
      Exit;
    end end;
  // (p3) if we get here, an xml header was not found
  Result := TrmxFastXMLElemHeader.Create(SimpleXML);
  FElems.Add(Result);
end;

function TrmxFastXMLElemsProlog.AddStyleSheet(const AType, AHRef: string): TrmxFastXMLElemProcessingInstruction;
begin
  // make sure there is an xml header
  Self.FindHeader;
  Result := TrmxFastXMLElemProcessingInstruction.Create('xml-stylesheet');
  Result.Properties.Add('type',AType);
  Result.Properties.Add('href',AHRef);
  FElems.Add(Result);
end;

function TrmxFastXMLElemsProlog.AddMSOApplication(const AProgId : string): TrmxFastXMLElemProcessingInstruction;
begin
  // make sure there is an xml header
  Self.FindHeader;
  Result := TrmxFastXMLElemProcessingInstruction.Create('mso-application');
  Result.Properties.Add('progid',AProgId);
  FElems.Add(Result);
end;

function TrmxFastXMLElemsProlog.AddComment(const AValue: string): TrmxFastXMLElemComment;
begin
  // make sure there is an xml header
  Self.FindHeader;
  Result := TrmxFastXMLElemComment.Create('', AValue);
  FElems.Add(Result);
end;

function TrmxFastXMLElemsProlog.AddDocType(const AValue: string): TrmxFastXMLElemDocType;
begin
  // make sure there is an xml header
  Self.FindHeader;
  Result := TrmxFastXMLElemDocType.Create('', AValue);
  FElems.Add(Result);
end;

end.

