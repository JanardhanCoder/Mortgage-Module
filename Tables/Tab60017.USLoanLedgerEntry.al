table 60017 "US Loan Ledger Entry"
{
    DataClassification = CustomerContent;
    Caption = 'Loan Ledger Entry';

    fields
    {
        field(1; "Entry No."; Integer) { AutoIncrement = true; }
        field(2; "Loan No."; Code[20]) { TableRelation = "US Mortgage Agreement Header"."Loan No."; }
        field(3; "Posting Date"; Date) { }
        field(4; "Entry Type"; Enum "GE Loan Entry Type") { }
        field(5; Amount; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Amount Principal"; Decimal) { }
        field(11; "Amount Interest"; Decimal) { }
        field(12; "Amount Escrow"; Decimal) { }
        field(13; "Amount Fee"; Decimal) { }

        field(20; "Bank Account No."; Code[20]) { }
        field(21; "External Reference"; Text[50]) { }
        field(22; "Document No."; Code[20]) { }
        field(23; Posted; Boolean) { Editable = false; }
        field(24; "Posted By"; Code[50]) { Editable = false; }
        field(25; "Posted At"; DateTime) { Editable = false; }

        field(30; "Shortcut Dim. 1 Code"; Code[20]) { TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1)); }
        field(31; "Shortcut Dim. 2 Code"; Code[20]) { TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2)); }
        field(32; "Dimension Set ID"; Integer) { }
        field(40; "Schedule Line No."; Integer) { }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
        key(LoanDate; "Loan No.", "Posting Date") { }
    }
}

