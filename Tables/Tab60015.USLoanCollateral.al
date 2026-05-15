table 60015 "USLoan Collateral"
{
    DataClassification = CustomerContent;
    Caption = 'Loan Collateral';

    fields
    {
        field(1; "Loan No."; Code[20]) { TableRelation = "US Mortgage Agreement Header"."Loan No."; }
        field(2; "Line No."; Integer) { }
        field(3; "Collateral No."; Code[20]) { TableRelation = "US Collateral Register"."Collateral No."; }
        field(4; "Lien Position"; Enum "GE Lien Position") { }
        field(10; "Registration Ref."; Text[50]) { }
        field(11; "Registered Date"; Date) { }
        field(12; Notes; Text[250]) { }
    }

    keys { key(PK; "Loan No.", "Line No.") { Clustered = true; } }
}
