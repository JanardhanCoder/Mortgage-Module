table 60016 "US Mortgage Schedule Line"
{
    DataClassification = CustomerContent;
    Caption = 'Mortgage Schedule Line';
    fields
    {
        field(1; "Loan No."; Code[20]) { TableRelation = "US Mortgage Agreement Header"."Loan No."; }
        field(2; "Line No."; Integer) { }
        field(3; "Due Date"; Date) { }
        field(4; Description; Text[100]) { }

        field(10; "Opening Principal"; Decimal) { }
        field(11; "EMI Amount"; Decimal) { }
        field(12; "Principal Amount"; Decimal) { }
        field(13; "Interest Amount"; Decimal) { }
        field(14; "Escrow Amount"; Decimal) { }
        field(15; "Fee Amount"; Decimal) { }
        field(16; "Closing Principal"; Decimal) { }

        field(20; Status; Enum "GE Schedule Status") { }
        field(21; "Paid Date"; Date) { }
        field(22; "Paid Total Amount"; Decimal) { }
        field(23; "Paid Principal"; Decimal) { }
        field(24; "Paid Interest"; Decimal) { }
        field(25; "Paid Escrow"; Decimal) { }


        field(30; "External Ref."; Text[50]) { }
        field(31; "Interest Rate %"; Decimal) { }
        field(32; closed; Boolean) { Editable = false; }
        field(33; "Penalty Amount"; Decimal) { }
        field(35; "Paid Penalty"; Decimal) { }
        field(34; "Penalty Calculated Date"; Date) { Editable = false; }
        field(36; "Cancelled Date"; Date) { }
        field(37; "Cancelled By"; Text[100]) { }
        field(38; "Schedule Type"; Option)
        {
            OptionMembers = Normal,PrincipalMoratorium,InterestMoratorium,FullMoratorium;
        }
        field(39; "Amount Paying"; Decimal)
        {
            DataClassification = CustomerContent;
        }
    }

    keys { key(PK; "Loan No.", "Line No.") { Clustered = true; } }

    procedure RemainingInterest(): Decimal
    begin
        exit("Interest Amount" - "Paid Interest");
    end;

    procedure RemainingPrincipal(): Decimal
    begin
        exit("Principal Amount" - "Paid Principal");
    end;

    procedure RemainingEscrow(): Decimal
    begin
        exit("Escrow Amount" - "Paid Escrow");
    end;

    procedure RemainingPenalty(): Decimal
    begin
        exit("Penalty Amount" - "Paid Penalty");
    end;

}

