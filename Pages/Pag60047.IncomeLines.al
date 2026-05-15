namespace MortgageForUS.MortgageForUS;
page 60047 IncomeLines
{
    ApplicationArea = All;
    Caption = 'IncomeLines';
    PageType = ListPart;
    SourceTable = IncomeLines;
    AutoSplitKey = true;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Application No."; Rec."Application No.")
                {
                    Visible = false;
                    ToolTip = 'Specifies the value of the Application No. field.', Comment = '%';
                }
                field("Assessment No."; Rec."Assessment No.")
                {
                    ToolTip = 'Specifies the value of the Assesement No. field.', Comment = '%';
                    Editable = false;
                }
                field("Line No."; Rec."Line No.")
                {
                    Editable = false;
                    Visible = false;
                }
                field("Type"; Rec."Type")
                {
                    ToolTip = 'Specifies the value of the Type field.', Comment = '%';
                }
                field(Amount; Rec.Amount)
                {
                    ToolTip = 'Specifies the value of the Amount field.', Comment = '%';
                    // trigger OnValidate()
                    // var
                    //     UnderwritingMgt: Codeunit "Underwriting Risk Engine";
                    // begin
                    //     UnderwritingMgt.TotalMonthlyIncome(Rec);
                    // end;
                }
            }
        }
    }

    // trigger OnModifyRecord(): Boolean
    // var
    //     UnderwritingMgt: Codeunit "Underwriting Risk Engine";
    // begin
    //     UnderwritingMgt.TotalMonthlyIncome(Rec);
    // end;

    // trigger OnInsertRecord(BooleanRec: Boolean): Boolean
    // var
    //     UnderwritingMgt: Codeunit "Underwriting Risk Engine";
    // begin
    //     UnderwritingMgt.TotalMonthlyIncome(Rec);
    // end;
}
