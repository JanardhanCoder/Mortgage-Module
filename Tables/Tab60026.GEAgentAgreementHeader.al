table 60026 "GE Agent Agreement Header"
{
    DataClassification = CustomerContent;
    Caption = 'Agent Commission Agreement';

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'Agreement No.';
        }

        field(2; "Agent Vendor No."; Code[20])
        {
            Caption = 'Agent Vendor No.';
            TableRelation = Vendor;
        }

        field(3; "Agent Contact No."; Code[20])
        {
            Caption = 'Agent Contact No.';
            TableRelation = Contact;
        }

        field(4; "Effective From Date"; Date)
        {
            Caption = 'Effective From';
        }

        field(5; "Effective To Date"; Date)
        {
            Caption = 'Effective To';
        }

        field(6; Status; Enum "GE Agreement Status")
        {
            Caption = 'Status';
        }

        field(7; "Commission Basis"; Enum "GE Commission Basis")
        {
            Caption = 'Commission Basis';
            // Loan Amount / Disbursed Amount
        }

        field(8; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;
        }

        field(9; "Created DateTime"; DateTime)
        {
            Editable = false;
        }

        field(10; "Created By"; Code[50])
        {
            Editable = false;
        }
    }

    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        "Created DateTime" := CurrentDateTime;
        "Created By" := UserId;
    end;
}

