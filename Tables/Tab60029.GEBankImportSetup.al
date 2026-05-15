table 60029 "GE Bank Import Setup"
{
    DataClassification = CustomerContent;
    Caption = 'Bank Import Setup';

    fields
    {
        field(1; "Primary Key"; Code[10]) { Caption = 'PK'; }
        field(2; "Default Bank Account No."; Code[20]) { TableRelation = "Bank Account"."No."; }
        field(3; "Default Posting Date Rule"; Option)
        {
            Caption = 'Posting Date Rule';
            OptionMembers = ValueDate,BookingDate,Today;
        }

        // Matching priority
        field(10; "Match Priority 1"; Option) { OptionMembers = ExternalRef,LoanNo,IBAN,FreeText; }
        field(11; "Match Priority 2"; Option) { OptionMembers = ExternalRef,LoanNo,IBAN,FreeText," "; }
        field(12; "Match Priority 3"; Option) { OptionMembers = ExternalRef,LoanNo,IBAN,FreeText," "; }

        // Regex-like simple parsing patterns (BC AL doesn't do full regex easily; use simple markers)
        field(20; "Loan No Prefix"; Text[10]) { Caption = 'Loan No Prefix (e.g., LN:)'; }
        field(21; "External Ref Prefix"; Text[10]) { Caption = 'External Ref Prefix (e.g., UTR:)'; }

        // Controls
        field(30; "Auto-Post After Import"; Boolean) { }
        field(31; "Skip Non-Receipts"; Boolean) { Caption = 'Skip Negative Amounts'; }
        field(32; "Min Amount"; Decimal) { }
        field(33; "Max Amount"; Decimal) { }
    }

    keys { key(PK; "Primary Key") { Clustered = true; } }

    trigger OnInsert()
    begin
        if "Primary Key" = '' then
            "Primary Key" := 'SETUP';
    end;
}
