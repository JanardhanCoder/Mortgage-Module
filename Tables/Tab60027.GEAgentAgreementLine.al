table 60027 "GE Agent Agreement Line"
{
    DataClassification = CustomerContent;
    Caption = 'Agent Agreement Line';

    fields
    {
        field(1; "Agreement No."; Code[20])
        {
            TableRelation = "GE Agent Agreement Header";
        }

        field(2; "Line No."; Integer)
        {
        }

        field(3; "Commission Type"; Enum "GE Commission Type")
        {
            Caption = 'Commission Type';
            // Percentage / Fixed Amount
        }

        field(4; "From Loan Amount"; Decimal)
        {
            Caption = 'From Loan Amount';
        }

        field(5; "To Loan Amount"; Decimal)
        {
            Caption = 'To Loan Amount';
        }

        field(6; "Commission %"; Decimal)
        {
            Caption = 'Commission %';
        }

        field(7; "Commission Amount"; Decimal)
        {
            Caption = 'Commission Amount';
        }

        field(8; "Minimum Commission"; Decimal)
        {
            Caption = 'Minimum Commission';
        }

        field(9; "Maximum Commission"; Decimal)
        {
            Caption = 'Maximum Commission';
        }
    }

    keys
    {
        key(PK; "Agreement No.", "Line No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    var
    begin
        Rec."Line No." := xRec."Line No." + 10000;
    end;
}

