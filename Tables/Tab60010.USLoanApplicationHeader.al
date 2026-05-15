table 60010 "US Loan Application Header"
{
    DataClassification = CustomerContent;
    Caption = 'Loan Application';
    fields
    {
        field(1; "No."; Code[20])
        {
            trigger OnValidate()
            begin
                if "No." <> xRec."No." then begin
                    Setup.Get();
                    NoSeriesMgt.TestManual(GetNoSeriesCode);
                    "No. Series" := '';
                end;
            end;
        }
        field(2; "Application Date"; Date) { }
        field(3; "Source Type"; Enum "US Application Source") { }
        field(4; "Borrower Customer No."; Code[20]) { TableRelation = Customer."No."; }
        field(5; "Agent Contact No."; Code[20]) { TableRelation = Contact."No." where("Contact Business Relation" = const(Vendor)); }
        field(10; "Relationship Manager"; Code[50])
        {
            Caption = 'Relationship Manager (User Id)';
            TableRelation = Employee;
        }
        field(11; "Product Code"; Code[20]) { TableRelation = "US Mortgage Product".Code; }
        field(12; "Borrower Contact No."; Code[20])
        {
            TableRelation = Contact."No." where("Contact Business Relation" = const(Customer));
            trigger OnValidate()
            var
                Contact: Record Contact;
                BusRet: Record "Contact Business Relation";
            begin
                Contact.SetRange("No.", "Borrower Contact No.");

                if Contact.FindFirst() then begin
                    BusRet.SetRange("Contact No.", "Borrower Contact No.");
                    if BusRet.FindFirst() then
                        "Borrower Customer No." := BusRet."No."
                    else
                        "Borrower Customer No." := '';
                end;
            end;
        }
        field(20; "Requested Amount"; Decimal) { }
        field(21; "Requested Tenor (Months)"; Integer) { }
        field(22; "Rate Preference"; Option) { OptionMembers = Fixed,Variable; }
        field(23; "Proposed Rate %"; Decimal) { DecimalPlaces = 0 : 5; }
        field(24; Purpose; Option) { OptionMembers = Purchase,Refinance,"Equity Release",Construction,Other; }
        field(25; "Purpose Description"; Text[100]) { }
        field(26; "Purchase Price"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(27; "Down Payment"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(28; "Proposed EMI"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(29; "Propety"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(30; Type; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(31; Status; Enum "US Application Status") { }
        field(32; Decision; Option) { OptionMembers = " ",Approved,Rejected,Conditional; }
        field(33; "Approved Amount"; Decimal) { }
        field(34; "Approved Tenor (Months)"; Integer) { }
        field(35; "Approved Rate %"; Decimal) { DecimalPlaces = 0 : 5; }
        field(36; "Offer Expiry Date"; Date) { }

        field(40; "Created Commitment No."; Code[20]) { }
        field(41; "Created Loan No."; Code[20]) { }

        field(51; "Rate Code"; Code[20])
        {
            TableRelation = "GE Interest Rate Setup"."Rate Code";

            trigger OnValidate()
            var
                rate: Record "GE Interest Rate History";
            begin
                if "Rate Code" <> '' then begin
                    rate.SetRange("Rate Code", "Rate Code");
                    if rate.FindSet() then
                        repeat
                            if (rate."Effective Date" <= Today) and (rate."Expired Date" >= Today) then
                                "Proposed Rate %" := rate."Interest Rate %";
                        until rate.Next() = 0;
                end
                else
                    "Proposed Rate %" := 0;

                if "Proposed Rate %" > 0 then
                    CalcEMI();
            end;
        }
        field(52; "Spread %"; Decimal)
        {
            Caption = 'Spread %';
        }
        field(53; "Current Interest %"; Decimal)
        {
            Editable = false;
        }
        field(90; "Created At"; DateTime) { Editable = false; }
        field(91; "Created By"; Code[50]) { Editable = false; }
        field(92; "No. Series"; Code[20])
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "No.") { Clustered = true; }
    }

    var
        Setup: Record "US Mortgage Posting Setup";
        NoSeriesMgt: Codeunit "No. Series";

    procedure GetNoseriesCode(): Code[20]
    var
        myInt: Integer;
    begin
        Setup.Get('SETUP');
        Setup.TestField("Application No. Series");
        exit(Setup."Application No. Series");
    end;

    procedure InitNo()
    var
        myInt: Integer;
    begin
        if "No." = '' then begin
            if NoSeriesMgt.AreRelated(GetNoSeriesCode(), xRec."No. Series") then
                "No. Series" := xRec."No. Series"
            else
                "No. Series" := GetNoSeriesCode();
            "No." := NoSeriesMgt.GetNextNo("No. Series");
        end;
    end;

    procedure AssistEdit(OldAG: Record "US Loan Application Header"): Boolean
    begin
        if NoSeriesMgt.LookupRelatedNoSeries(GetNoSeriesCode(), OldAG."No. Series", "No. Series") then begin
            "No." := NoSeriesMgt.GetNextNo("No. Series");
            exit(true);
        end;
    end;


    trigger OnInsert()
    begin
        "Created At" := CurrentDateTime();
        "Created By" := UserId;
        if "Application Date" = 0D then
            "Application Date" := Today;

        ValidateAgentBySource();
    end;

    trigger OnModify()
    begin
        ValidateAgentBySource();
    end;

    local procedure ValidateAgentBySource()
    begin
        if "Source Type" = "Source Type"::Direct then
            if "Agent Contact No." <> '' then
                Error('Agent Contact must be blank when Source Type is Direct.');
    end;

    procedure CalcEMI()
    var
        P: Decimal;
        r: Decimal;
        n: Integer;
        PowerValue: Decimal;
    begin
        // Validation
        if (Rec."Requested Amount" <= 0) or (Rec."Proposed Rate %" <= 0) or (Rec."Requested Tenor (Months)" <= 0) then begin
            "Proposed EMI" := 0;
            exit;
        end;

        P := "Requested Amount";
        n := "Requested Tenor (Months)";
        r := ("Proposed Rate %" / 12) / 100; // Monthly rate

        PowerValue := Power(1 + r, n);

        "Proposed EMI" :=
            Round(
                (P * r * PowerValue) / (PowerValue - 1),
                0.01,
                '='
            );
    end;

}

