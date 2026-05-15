table 60031 "GE Receipt Txn Header"
{
    DataClassification = CustomerContent;
    Caption = 'Loan Receipt Transaction';

    fields
    {
        field(1; "Txn No."; Code[30]) { Caption = 'Txn No.'; }
        field(2; "Loan No."; Code[20]) { TableRelation = "US Mortgage Agreement Header"."Loan No."; }
        field(3; "Posting Date"; Date) { }
        field(4; "Bank Account No."; Code[20]) { TableRelation = "Bank Account"."No."; }
        field(5; "External Reference"; Text[50]) { }
        field(6; "Total Amount"; Decimal) { }

        field(10; "Penalty Portion"; Decimal) { Editable = false; }
        field(11; "Interest Portion"; Decimal) { Editable = false; }
        field(12; "Principal Portion"; Decimal) { Editable = false; }
        field(13; "Escrow Portion"; Decimal) { Editable = false; }

        field(20; Status; Option)
        {
            Caption = 'Status';
            OptionMembers = Draft,Allocated,"GL Posted",Applied,Error;
        }
        field(21; "GL Document No."; Code[20]) { Editable = false; }
        field(22; "GL Posted At"; DateTime) { Editable = false; }
        field(23; "Applied At"; DateTime) { Editable = false; }
        field(24; "Last Error"; Text[250]) { Editable = false; }

        field(30; "Created At"; DateTime) { Editable = false; }
        field(31; "Created By"; Code[50]) { Editable = false; }
    }

    keys
    {
        key(PK; "Txn No.") { Clustered = true; }
        key(LoanRef; "Loan No.", "External Reference") { }
    }

    trigger OnInsert()
    begin
        "Created At" := CurrentDateTime();
        "Created By" := UserId;
        if Status = Status::Draft then;
    end;
}

