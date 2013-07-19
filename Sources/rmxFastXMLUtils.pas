unit rmxFastXMLUtils;

interface

uses
  System.Types, System.RTLConsts,
  System.SysUtils, System.DateUtils, System.Classes, System.Generics.Collections,
  Data.DB,
  rmxFastXML;

Type
  TrmxFastXMLHelper = Class Helper for TrmxFastXML
  public
    ///	<summary>
    ///	  Assign a Child Node if exist Value to a Dataset Field if exist
    ///	</summary>
    ///	<param name="aRootNode">
    ///	  Root node
    ///	</param>
    ///	<param name="aFieldName">
    ///	  Field name
    ///	</param>
    ///	<param name="aNodeName">
    ///	  Child node name (if empty use FieldName)
    ///	</param>
    ///	<remarks>
    ///	  If node does not exists or has empty value , then assign null
    ///	</remarks>
    procedure AssignNode2Field(Const aRootNode:TrmxFastXMLElem;Const aDataSet:TDataSet;Const aFieldName:String;Const aNodeName:String='');

    ///	<summary>
    ///	  Assign a Property (Attribut) if exist Value to a Dataset Field if exist
    ///	</summary>
    ///	<param name="aRootNode">
    ///	  Root Node containing Properties
    ///	</param>
    ///	<param name="aDataSet">
    ///	  Dataset
    ///	</param>
    ///	<param name="aFieldName">
    ///	  Field Name
    ///	</param>
    ///	<param name="aPropertyName">
    ///	  Property Name (if empty use FieldName)
    ///	</param>
    ///	<remarks>
    ///	  If property does not exists or has empty value , then assign null
    ///	</remarks>
    procedure AssignProperty2Field(Const aRootNode:TrmxFastXMLElem;Const aDataSet:TDataSet;Const aFieldName:String;Const aPropertyName:String='');overload;

    procedure AssignProperty2Field(Const aRootNode:TrmxFastXMLElem;Const aField:TField;Const aPropertyName:String);overload;inline;

    ///	<summary>
    ///	  Create dynamic fields from ...
    ///	</summary>
    procedure CreateFields(Const aMetadataNode:TrmxFastXMLElem;Const aDataSet:TDataSet);

    ///	<summary>
    ///	  Assign all Child not to Dataset
    ///	</summary>
    procedure AssignFields(Const aDataNode:TrmxFastXMLElem;Const aDataSet:TDataSet);

  end;

implementation

{______________________________________________________________________________}
{______________________________________________________________________________}
{______________________________________________________________________________}
procedure TrmxFastXMLHelper.AssignNode2Field(Const aRootNode:TrmxFastXMLElem;Const aDataSet:TDataSet;Const aFieldName:String;Const aNodeName:String='');
Var n:TrmxFastXMLElem;
    idx:Integer;
    f:TField;
Begin
  f:=aDataSet.FindField(aFieldName);
  if f<>nil then Begin
    if aNodeName=EmptyStr then
      idx:=aRootNode.Items.IndexOf(aFieldName) else
      idx:=aRootNode.Items.IndexOf(aNodeName);
    if idx>=0 then Begin
      n:=aRootNode.Items[idx];
      if n.Value<>EmptyStr then Begin
        case f.DataType of
          ftSmallint,ftInteger,ftWord,ftLargeint,ftLongWord,ftShortint,ftByte:Begin
            f.AsLargeInt:=n.IntValue
            end;
          ftFloat,ftCurrency,ftBCD,ftFMTBcd,ftExtended:Begin
            f.AsExtended:=n.XMLFloat
            end;
          ftDate:Begin
            f.AsDateTime:=n.XMLDate
            end;
          ftTime:Begin
            f.AsDateTime:=n.XMLTime
            end;
          ftDateTime,ftTimeStamp:Begin
            f.AsDateTime:=n.XMLDateTime
            end;
          ftString,ftWideString:Begin
            f.AsString:=n.Value.Substring(0,f.Size);
            end;
          else Begin
            f.AsString:=n.Value
          end end;
      end else Begin
        // Assign null
        f.Clear;
        end;
    End else Begin
      // Assign null
      f.Clear;
    end end;
End;
{______________________________________________________________________________}
procedure TrmxFastXMLHelper.AssignProperty2Field(Const aRootNode:TrmxFastXMLElem;Const aDataSet:TDataSet;Const aFieldName:String;Const aPropertyName:String='');
Var p:TrmxFastXMLProp;
    idx:Integer;
    f:TField;
Begin
  f:=aDataSet.FindField(aFieldName);
  if f<>nil then Begin
    if aPropertyName=EmptyStr then
      idx:=aRootNode.Properties.IndexOf(aFieldName) else
      idx:=aRootNode.Properties.IndexOf(aPropertyName);
    if idx>=0 then Begin
      p:=aRootNode.Properties.Item[idx];
      if p.Value<>EmptyStr then Begin
        case f.DataType of
          ftSmallint,ftInteger,ftWord,ftLargeint,ftLongWord,ftShortint,ftByte:Begin
            f.AsLargeInt:=p.IntValue
            end;
          ftFloat,ftCurrency,ftBCD,ftFMTBcd,ftExtended:Begin
            f.AsExtended:=p.XMLFloat
            end;
          ftDate:Begin
            f.AsDateTime:=p.XMLDate
            end;
          ftTime:Begin
            f.AsDateTime:=p.XMLTime
            end;
          ftDateTime,ftTimeStamp:Begin
            f.AsDateTime:=p.XMLDateTime
            end;
          ftString,ftWideString:Begin
            f.AsString:=p.Value.Substring(0,f.Size);
            end;
          else Begin
            f.AsString:=p.Value
          end end;
      end else Begin
        // Assign null
        f.Clear;
        end;
    End else Begin
      // Assign null
      f.Clear;
    end end;
End;
{______________________________________________________________________________}
procedure TrmxFastXMLHelper.AssignProperty2Field(Const aRootNode:TrmxFastXMLElem;Const aField:TField;Const aPropertyName:String);
Var p:TrmxFastXMLProp;
    idx:Integer;
Begin
    idx:=aRootNode.Properties.IndexOf(aPropertyName);
    if idx>=0 then Begin
      p:=aRootNode.Properties.Item[idx];
      if p.Value<>EmptyStr then Begin
        case aField.DataType of
          ftSmallint,ftInteger,ftWord,ftLargeint,ftLongWord,ftShortint,ftByte:Begin
            aField.AsLargeInt:=p.IntValue
            end;
          ftFloat,ftCurrency,ftBCD,ftFMTBcd,ftExtended:Begin
            aField.AsExtended:=p.XMLFloat
            end;
          ftDate:Begin
            aField.AsDateTime:=p.XMLDate
            end;
          ftTime:Begin
            aField.AsDateTime:=p.XMLTime
            end;
          ftDateTime,ftTimeStamp:Begin
            aField.AsDateTime:=p.XMLDateTime
            end;
          ftString,ftWideString:Begin
            aField.AsString:=p.Value.Substring(0,aField.Size);
            end;
          else Begin
            aField.AsString:=p.Value
          end end;
      end else Begin
        // Assign null
        aField.Clear;
        end;
      end else Begin
        // Assign null
        aField.Clear;
        end;
End;
{______________________________________________________________________________}
procedure TrmxFastXMLHelper.CreateFields(Const aMetadataNode:TrmxFastXMLElem;Const aDataSet:TDataSet);
Var n:TrmxFastXMLElem;
    f:TFieldDef;
Begin
  Assert(aDataSet<>nil);
  Assert(aMetadataNode<>nil);

  aDataSet.FieldDefs.Clear;
  aDataSet.Fields.Clear;

  for n in aMetadataNode.Items do Begin
    f:=aDataSet.FieldDefs.AddFieldDef;
    f.Name     := n.Value;
    f.DataType := ftWideString;
    f.Size     := 50;
    end;
End;
{______________________________________________________________________________}
procedure TrmxFastXMLHelper.AssignFields(Const aDataNode:TrmxFastXMLElem;Const aDataSet:TDataSet);
Var n:TrmxFastXMLElem;
    f:TField;
Begin
  for n in aDataNode.Items do Begin
    f:=aDataSet.Fields[n.Name.Substring(1).ToInteger];
    f.AsString:=n.Value.Substring(0,f.Size);
    end;
End;


end.
