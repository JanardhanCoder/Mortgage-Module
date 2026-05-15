table 60033 "GE Loan Arrangement Header"
{
    DataClassification = CustomerContent;
    Caption = 'Loan Arrangement';

    fields
    {
        field(1; "No."; Code[20]) { }
        field(2; "Loan No."; Code[20]) { TableRelation = "US Mortgage Agreement Header"."Loan No."; }
        field(3; "Arrangement Type"; Enum "GE Loan Arrangement Type") { }
        field(4; Status; Enum "GE Loan Arrangement Status") { }

        field(10; "Created Date"; Date) { Editable = false; }
        field(11; "Created By"; Code[50]) { Editable = false; }

        // Common
        field(20; "Effective Date"; Date) { }
        field(21; "Reason Code"; Code[20]) { Caption = 'Reason Code'; }
        field(22; Notes; Text[250]) { }

        // PTP
        field(30; "PTP Date"; Date) { }
        field(31; "PTP Amount"; Decimal) { }
        field(32; "PTP Follow-up Date"; Date) { }
        field(33; "PTP Outcome"; Option) { OptionMembers = " ",Kept,Broken,Partial; }

        // Waiver
        field(40; "Waive Penalty Amount"; Decimal) { }
        field(41; "Waive Fee Amount"; Decimal) { }
        field(42; "Waiver Posted"; Boolean) { Editable = false; }
        field(43; "Waiver Doc No."; Code[20]) { Editable = false; }

        // Restructure
        field(50; "Restructure Type"; Enum "GE Restructure Type")
        {
            trigger OnValidate()
            begin
                if "Arrangement Type" <> Enum::"GE Loan Arrangement Type"::Restructure then
                    Error('Restructure Type can only be set for Restructure arrangements.');
            end;
        }
        field(51; "New Interest Rate %"; Decimal) { DecimalPlaces = 0 : 6; }
        field(52; "New Tenor (Months)"; Integer) { }
        field(53; "Capitalise Amount"; Decimal) { }
        field(54; "Restructure Applied"; Boolean) { Editable = true; }
        field(55; "Old Maturity Date"; Date) { Editable = false; }
        field(56; "New Maturity Date"; Date) { Editable = false; }
        field(57; "New Interest Rate Code"; Code[20]) { TableRelation = "GE Interest Rate Setup"; }
    }


    keys
    {
        key(PK; "No.") { Clustered = true; }
        key(LoanIdx; "Loan No.", "Arrangement Type", Status) { }
    }

    trigger OnInsert()
    begin
        "Created Date" := Today;
        "Created By" := UserId;
        if Status = Status::Open then;
    end;
}
