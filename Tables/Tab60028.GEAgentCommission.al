table 60028 "GE Agent Commission"
{
    DataClassification = CustomerContent;
    Caption = 'Agent Commission';

    fields
    {
        field(1; "Commission No."; Code[20])
        {
            Caption = 'Commission No.';
        }

        field(2; "Loan No."; Code[20])
        {
            Caption = 'Loan No.';
            TableRelation ="US Mortgage Agreement Header"."Loan No.";
        }

        field(3; "Agent Code"; Code[20])
        {
            Caption = 'Agent Code';
            TableRelation = "GE Mortgage Agent"."Agent Code";
        }

        field(4; "CRM Agent Contact No."; Code[20])
        {
            Caption = 'CRM Agent Contact';
            TableRelation = Contact."No.";
            Editable = false;
        }

        field(5; "Payee Contact No."; Code[20])
        {
            Caption = 'Payee Contact';
            TableRelation = Contact."No.";
            Editable = false;
        }

        field(6; "Agent Vendor No."; Code[20])
        {
            Caption = 'Agent Vendor';
            TableRelation = Vendor."No.";
            Editable = false;
        }

        field(7; "Agreement No."; Code[20])
        {
            Caption = 'Commission Agreement';
            TableRelation = "GE Agent Agreement Header"."No.";
            Editable = false;
        }

        field(8; "Commission Base Amount"; Decimal)
        {
            Caption = 'Base Amount';
        }

        field(9; "Commission Amount"; Decimal)
        {
            Caption = 'Commission Amount';
        }

        field(10; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }

        field(11; Status; Enum "GE Commission Status")
        {
            Caption = 'Status';
        }

        field(12; "Accrued"; Boolean)
        {
            Caption = 'Accrued';
            Editable = false;
        }

        field(13; "Paid"; Boolean)
        {
            Caption = 'Paid';
            Editable = false;
        }

        field(14; "G/L Entry No."; Integer)
        {
            Caption = 'Accrual G/L Entry';
            Editable = false;
        }

        field(15; "Vendor Ledger Entry No."; Integer)
        {
            Caption = 'Vendor Ledger Entry';
            Editable = false;
        }

        field(50; "Created By"; Code[50])
        {
            Editable = false;
        }

        field(51; "Created On"; DateTime)
        {
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Commission No.")
        {
            Clustered = true;
        }

        key(ByLoan; "Loan No.")
        {
        }

        key(ByAgent; "Agent Code")
        {
        }
    }

    trigger OnInsert()
    begin
        "Created By" := UserId;
        "Created On" := CurrentDateTime;
    end;
}

