table 60006 "US Mortgage Posting Setup"
{
    DataClassification = CustomerContent;
    Caption = 'US Mortgage Setup';

    fields
    {
        field(1; "Primary Key"; Code[10]) { Caption = 'Primary Key'; }
        field(10; "Gen. Jnl. Template"; Code[10]) { TableRelation = "Gen. Journal Template".Name; }
        field(11; "Gen. Jnl. Batch"; Code[10]) { TableRelation = "Gen. Journal Batch".Name where("Journal Template Name" = field("Gen. Jnl. Template")); }

        field(20; "Accrual Jnl. Template"; Code[10]) { TableRelation = "Gen. Journal Template".Name; }
        field(21; "Accrual Jnl. Batch"; Code[10]) { TableRelation = "Gen. Journal Batch".Name where("Journal Template Name" = field("Accrual Jnl. Template")); }

        field(30; "Application No. Series"; Code[20]) { TableRelation = "No. Series".Code; }
        field(31; "Commitment No. Series"; Code[20]) { TableRelation = "No. Series".Code; }
        field(32; "Loan No. Series"; Code[20]) { TableRelation = "No. Series".Code; }

        field(40; "Default Bank Account No."; Code[20]) { TableRelation = "Bank Account"."No."; }

        field(50; "Shortcut Dim. 1 Code"; Code[20]) { TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1)); }
        field(51; "Shortcut Dim. 2 Code"; Code[20]) { TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2)); }
        field(52; "Lender Pays Agent Commission"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(53; "Mortgage Type"; Enum "US Mortgage Type")
        {
            DataClassification = ToBeClassified;
        }
        // field(52; "Loan Principal Receivable"; Code[20]) { TableRelation = "G/L Account"."No."; }
        // field(53; "Interest Receivable"; Code[20]) { TableRelation = "G/L Account"."No."; }
        // field(54; "Interest Income"; Code[20]) { TableRelation = "G/L Account"."No."; }
        // field(55; "Escrow Liability"; Code[20]) { TableRelation = "G/L Account"."No."; }
        // field(56; "Deferred Fee Liability"; Code[20]) { TableRelation = "G/L Account"."No."; }
        // field(57; "Fee Income"; Code[20]) { TableRelation = "G/L Account"."No."; }
        // field(58; "Penalty Income"; Code[20]) { TableRelation = "G/L Account"."No."; }
        field(54; "LTV Calulation by"; Option)
        {
            OptionMembers = " ","By Market Value","By Purchase Value";
        }
        field(55; "Assessment No."; Code[20])
        {
            TableRelation = "No. Series";
            DataClassification = CustomerContent;
        }
        field(56; "Penalty Method"; Option)
        {
            OptionMembers = None,"Flat","Rate Per Day";
        }
        field(57; "Penalty"; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(58; "Penalty Percent/Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(59; "LHFS Account"; Code[20]) { TableRelation = "G/L Account"; }
        field(60; "Gain/Loss Account"; Code[20]) { TableRelation = "G/L Account"; }
    }

    keys { key(PK; "Primary Key") { Clustered = true; } }

    trigger OnInsert()
    begin
        if "Primary Key" = '' then
            "Primary Key" := 'SETUP';
    end;
}

