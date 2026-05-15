namespace MortgageForUS.MortgageForUS;

page 60046 "EMI LINES"
{
    ApplicationArea = All;
    Caption = 'EMI LINES';
    PageType = ListPart;
    SourceTable = "EMI Line Table";
    AutoSplitKey = true;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Application No."; Rec."Application No.")
                {
                    ToolTip = 'Specifies the value of the Application No. field.', Comment = '%';
                    Editable = false;
                }
                field("Loan Type"; Rec."Loan Type")
                {
                    ToolTip = 'Specifies the value of the Loan Type field.', Comment = '%';
                }
                field("Loan Amount"; Rec."Loan Amount")
                {
                    ToolTip = 'Specifies the value of the Loan Amount field.', Comment = '%';
                }
            }
        }
    }
}
