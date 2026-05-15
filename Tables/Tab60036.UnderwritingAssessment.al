table 60036 "Underwriting Assessment"
{
    DataClassification = CustomerContent;
    fields
    {
        field(1; "Assessment No."; Code[20])
        {
            trigger OnValidate()
            begin
                if "Assessment No." <> xRec."Assessment No." then begin
                    Setup.Get();
                    NoSeriesMgt.TestManual(GetNoSeriesCode);
                    "No. Series" := '';
                end;
            end;

        }
        field(2; "Application No."; Code[20])
        {
            TableRelation = "US Loan Application Header";
            trigger OnValidate()
            var
                app: Record "US Loan Application Header";
                UW: Record "Underwriting Assessment";
            begin
                if "Application No." <> '' then begin
                    app.SetRange("No.", "Application No.");
                    if app.FindFirst() then begin
                        "Property Price" := app."Purchase Price";
                        "Down Payment" := app."Down Payment";
                        "Requested Loan Amount" := app."Requested Amount";
                        "Proposed EMI" := app."Proposed EMI";
                    end;
                    UW.SetRange("Application No.", "Application No.");
                    UW.SetCurrentKey("Assessment Date");
                    UW.SetAscending("Assessment Date", true);
                    if UW.FindLast() then begin
                        if "Assessment No." <> UW."Assessment No." then
                            "Assessment Version" := UW."Assessment Version" + 1;
                    end;
                end;
            end;
        }
        field(3; "Assessment Date"; Date) { }
        field(4; "Assessment Time"; Time) { }

        field(5; "Assessment Type"; Enum "Assessment Type") { }
        field(6; "Assessment Version"; Integer) { }

        field(7; "Underwriter User ID"; Code[50])
        {
            TableRelation = Employee;
        }
        field(8; "Monthly Income"; Decimal) { }
        field(9; "Total Monthly EMIs"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(10; "Property Price"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(11; "Market Value"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(12; "Down Payment"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(13; "Requested Loan Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(14; "Proposed EMI"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(15; "DTI %"; Decimal) { }
        field(16; "FOIR %"; Decimal) { }
        field(17; "Credit Score"; Integer) { }
        field(18; "LTV %"; Decimal) { }

        // Risk Snapshot
        field(20; "Income Risk"; Enum "Risk Level") { }
        field(21; "Credit Risk"; Enum "Risk Level") { }
        field(22; "FOIR Risk"; Enum "Risk Level") { }
        field(23; "Collateral Risk"; Enum "Risk Level") { }
        field(24; "Overall Risk"; Enum "Risk Level") { }

        field(30; "Decision"; Option)
        {
            OptionMembers = " ",Approved,Rejected,Conditional;
        }
        field(31; "Decision Comment"; Text[250]) { }

        field(40; "Is Final Assessment"; Boolean) { }
        field(41; "No. Series"; Code[20])
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Assessment No.") { Clustered = true; }
        //key(AppKey; "Application No.", "Assessment Date") { }
    }
    var
        Setup: Record "US Mortgage Posting Setup";
        NoSeriesMgt: Codeunit "No. Series";
        NoSeriesCode: Code[20];

    trigger OnInsert()
    var
        myInt: Integer;
    begin
        InitNo();
        "Assessment Date" := Today();
    end;

    procedure GetNoSeriesCode(): Code[20]
    var
        myInt: Integer;
    begin
        Setup.Get('SETUP');
        Setup.TestField("Assessment No.");
        NoSeriesCode := Setup."Assessment No.";
        exit(NoSeriesCode);
    end;

    procedure InitNo()
    var
        myInt: Integer;
    begin
        if "Assessment No." = '' then begin
            Setup.Get('SETUP');
            Setup.TestField("Assessment No.");
            if NoSeriesMgt.AreRelated(GetNoSeriesCode(), xRec."No. Series") then
                "No. Series" := xRec."No. Series"
            else
                "No. Series" := GetNoSeriesCode();
            "Assessment No." := NoSeriesMgt.GetNextNo("No. Series");
        end;
    end;

    procedure AssistEdit(OldUW: Record "Underwriting Assessment"): Boolean
    begin
        Setup.Get('SETUP');
        Setup.TestField("Assessment No.");
        if NoSeriesMgt.LookupRelatedNoSeries(GetNoSeriesCode(), OldUW."No. Series", "No. Series") then begin
            Rec."Assessment No." := NoSeriesMgt.GetNextNo(Rec."No. Series");
            exit(true);
        end;
    end;
}
