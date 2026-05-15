table 60032 "GE Receipt Txn Alloc Line"
{
    DataClassification = CustomerContent;
    Caption = 'Receipt Transaction Allocation Line';

    fields
    {
        field(1; "Txn No."; Code[30]) { TableRelation = "GE Receipt Txn Header"."Txn No."; }
        field(2; "Line No."; Integer) { }
        field(3; "Loan No."; Code[20]) { }
        field(4; "Schedule Line No."; Integer) { } // matches "GE Mortgage Schedule Line"."Line No."
        field(5; "Due Date"; Date) { }

        field(10; "Penalty Amount"; Decimal) { }
        field(11; "Interest Amount"; Decimal) { }
        field(12; "Principal Amount"; Decimal) { }
        field(13; "Escrow Amount"; Decimal) { }

        field(20; Applied; Boolean) { Editable = false; }
        field(21; "Applied At"; DateTime) { Editable = false; }
        field(22; "Is Prepayment"; Boolean) { }
        field(23; "Prepayment Amount"; Decimal) { }
    }

    keys
    {
        key(PK; "Txn No.", "Line No.") { Clustered = true; }
        key(LoanSchedule; "Loan No.", "Schedule Line No.") { }
    }
}

