table 60037 IncomeLines
{
    Caption = 'IncomeLines';
    DataClassification = ToBeClassified;
    fields
    {
        field(1; "Assessment No."; Code[20])
        {
            Caption = 'Assesement No.';
            TableRelation = "Underwriting Assessment";
        }
        field(2; "Application No."; Code[20])
        {
            Caption = 'Application No.';
            TableRelation = "US Loan Application Header";
        }
        field(3; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(4; "Type"; Option)
        {
            Caption = 'Type';
            OptionMembers = " ",Salary,Business,Other;
        }
        field(5; Amount; Decimal)
        {
            Caption = 'Amount';

            trigger OnValidate()
            var
                myInt: Integer;
            begin
                UnderwritingMgt.TotalMonthlyIncome(Rec);
            end;
        }
    }
    keys
    {
        key(PK; "Assessment No.", "Line No.")
        {
            Clustered = true;
        }
    }
    var
        UnderwritingMgt: Codeunit "Underwriting Risk Engine";

    trigger OnInsert()
    var
        myInt: Integer;
    begin
        // if "Line No." = 0 then begin
        //     "Line No." := "Line No." + 10000;
        // end;
        //UnderwritingMgt.TotalMonthlyIncome(Rec);
    end;

    // trigger OnModify()
    // var
    //     UnderwritingMgt: Codeunit "Underwriting Risk Engine";
    // begin
    //     UnderwritingMgt.TotalMonthlyIncome(Rec);
    // end;

    trigger OnDelete()
    var
        UnderwritingMgt: Codeunit "Underwriting Risk Engine";
    begin
        UnderwritingMgt.UpdateIncome(Rec);
    end;
}

