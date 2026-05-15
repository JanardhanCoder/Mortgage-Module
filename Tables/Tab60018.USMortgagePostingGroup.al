table 60018 "US Mortgage Posting Group"
{
    DataClassification = CustomerContent;
    Caption = 'Mortgage Posting Group';

    fields
    {
        field(1; Code; Code[20]) { Caption = 'Code'; }
        field(2; Description; Text[100]) { }

        field(10; "Loan Principal Receivable"; Code[20]) { TableRelation = "G/L Account"."No."; }
        field(11; "Interest Receivable"; Code[20]) { TableRelation = "G/L Account"."No."; }
        field(12; "Interest Income"; Code[20]) { TableRelation = "G/L Account"."No."; }
        field(13; "Escrow Liability"; Code[20]) { TableRelation = "G/L Account"."No."; }
        field(14; "Deferred Fee Liability"; Code[20]) { TableRelation = "G/L Account"."No."; }
        field(15; "Fee Income"; Code[20]) { TableRelation = "G/L Account"."No."; }
        field(16; "Penalty Income"; Code[20]) { TableRelation = "G/L Account"."No."; }
        field(17; "Write-off Account"; Code[20]) { TableRelation = "G/L Account"."No."; }
        field(18; "Rounding Account"; Code[20]) { TableRelation = "G/L Account"."No."; }
        field(19; "Penalty Waiver GL"; Code[20]) { TableRelation = "G/L Account"."No."; }
        field(20; "Agent Vendor Posting Group"; Code[20]) { TableRelation = "G/L Account"."No."; }
        // field(21; "Default Agent Vendor Gen. Bus. Posting Group"; Code[20]) { TableRelation = "G/L Account"."No."; }

        // field(22; "Default Agent Vendor Gen. Bus. Posting Group"; Code[20]) { TableRelation = "G/L Account"."No."; }       
    }

    keys
    {
        key(PK; Code) { Clustered = true; }
    }
}
