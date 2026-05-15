table 60012 "US Loan App Document Line"
{
    DataClassification = CustomerContent;
    Caption = 'Application Document Line';
    //  DrillDownPageId = "US App Document Subpage";
    //LookupPageId="US App Document Subpage";

    fields
    {
        field(1; "Application No."; Code[20]) { TableRelation = "US Loan Application Header"."No."; }
        field(2; "Line No."; Integer) { }
        field(3; "Doc Type Code"; Code[20]) { TableRelation = "US Mortgage Doc Type".Code; }
        field(4; "File Type"; Option)
        {
            Caption = 'File Type';
            OptionCaption = ' ,Image,PDF,Cad,Word,Excel,PowerPoint,Email,XML,Other';
            OptionMembers = " ",Image,PDF,Cad,Word,Excel,PowerPoint,Email,XML,Other;
        }
        field(5; "File Extension"; Text[250])
        {
            Caption = 'File Extension';

            trigger OnValidate()
            begin
                case LowerCase("File Extension") of
                    'jpg', 'jpeg', 'bmp', 'png', 'tiff', 'tif', 'gif':
                        "File Type" := "File Type"::Image;
                    'pdf':
                        "File Type" := "File Type"::PDF;
                    'cad':
                        "File Type" := "File Type"::Cad;
                    'docx', 'doc':
                        "File Type" := "File Type"::Word;
                    'xlsx', 'xls':
                        "File Type" := "File Type"::Excel;
                    'pptx', 'ppt':
                        "File Type" := "File Type"::PowerPoint;
                    'msg':
                        "File Type" := "File Type"::Email;
                    'xml':
                        "File Type" := "File Type"::XML;
                    else
                        "File Type" := "File Type"::Other;
                end;
            end;
        }
        field(6; "File Name"; Text[250])
        {
            Caption = 'Attachment';
            NotBlank = true;
            Editable = true;

            trigger OnValidate()
            var
                DocumentAttachmentMgmt: Codeunit "Document Attachment Mgmt";
            begin
                if "File Name" = '' then
                    Error(EmptyFileNameErr);
            end;
        }
        field(7; "Document Reference ID"; Media)
        {
            Caption = 'Document Reference ID';
        }
        field(10; Received; Boolean) { }
        field(11; Verified; Boolean) { }
        field(12; "Document Date"; Date) { }
        field(13; "Expiry Date"; Date) { }
        field(14; "File Link"; Text[250]) { }
        field(15; Remarks; Text[250]) { }

    }

    keys
    {
        key(PK; "Application No.", "Line No.")
        {
            Clustered = true;
        }
    }
    var
        NoDocumentAttachedErr: Label 'Please attach a document first.';
        EmptyFileNameErr: Label 'Please choose a file to attach.';
        NoContentErr: Label 'The selected file has no content. Please choose another file.';
        FileManagement: Codeunit "File Management";
        IncomingFileName: Text;
        DuplicateErr: Label 'This file is already attached to the document. Please choose another file.';

    trigger OnInsert()
    var
        myInt: Integer;
    begin
        if IncomingFileName <> '' then begin
            Validate("File Extension", FileManagement.GetExtension(IncomingFileName));
            Validate("File Name", CopyStr(FileManagement.GetFileNameWithoutExtension(IncomingFileName), 1, MaxStrLen("File Name")));
        end;
    end;

    procedure SaveAttachment(RecRef: RecordRef; FileName: Text; TempBlob: Codeunit "Temp Blob")
    var
        DocStream: InStream;
    begin
        //OnBeforeSaveAttachment(Rec, RecRef, FileName, TempBlob);

        if FileName = '' then
            Error(EmptyFileNameErr);
        // Validate file/media is not empty
        if not TempBlob.HasValue then
            Error(NoContentErr);

        TempBlob.CreateInStream(DocStream);
        InsertAttachment(DocStream, RecRef, FileName);
    end;

    procedure Export(ShowFileDialog: Boolean): Text
    var
        TempBlob: Codeunit "Temp Blob";
        FileManagement: Codeunit "File Management";
        DocumentStream: OutStream;
        FullFileName: Text;
    begin
        // Ensure document has value in DB
        if not "Document Reference ID".HasValue then
            exit;

        //OnBeforeExportAttachment(Rec);
        FullFileName := "File Name" + '.' + "File Extension";
        TempBlob.CreateOutStream(DocumentStream);
        "Document Reference ID".ExportStream(DocumentStream);
        exit(FileManagement.BLOBExport(TempBlob, FullFileName, ShowFileDialog));
    end;

    local procedure InsertAttachment(DocStream: InStream; RecRef: RecordRef; FileName: Text)
    begin
        IncomingFileName := FileName;

        Validate("File Extension", FileManagement.GetExtension(IncomingFileName));
        Validate("File Name", CopyStr(FileManagement.GetFileNameWithoutExtension(IncomingFileName), 1, MaxStrLen("File Name")));

        // IMPORTSTREAM(stream,description, mime-type,filename)
        // description and mime-type are set empty and will be automatically set by platform code from the stream
        "Document Reference ID".ImportStream(DocStream, '');
        if not "Document Reference ID".HasValue then
            Error(NoDocumentAttachedErr);

        //InitFieldsFromRecRef(RecRef);

        //OnBeforeInsertAttachment(Rec, RecRef);
        Modify(true);
    end;
}

