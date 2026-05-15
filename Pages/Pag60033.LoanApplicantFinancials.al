namespace MortgageForUS.MortgageForUS;

page 60033 "Loan Applicant Financials"
{
    ApplicationArea = All;
    Caption = 'Loan Applicant Financials';
    PageType = List;
    SourceTable = "Loan Applicant Financials";
    UsageCategory = Lists;
    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Application No."; Rec."Application No.")
                {
                    ToolTip = 'Specifies the value of the Application No. field.', Comment = '%';
                }
                field("Credit Score"; Rec."Credit Score")
                {
                    ToolTip = 'Specifies the value of the Credit Score field.', Comment = '%';
                }
                field("Employment Type"; Rec."Employment Type")
                {
                    ToolTip = 'Specifies the value of the Employment Type field.', Comment = '%';
                }
                field("Existing EMI"; Rec."Existing EMI")
                {
                    ToolTip = 'Specifies the value of the Existing EMI field.', Comment = '%';
                }
                field("Monthly Income"; Rec."Monthly Income")
                {
                    ToolTip = 'Specifies the value of the Monthly Income field.', Comment = '%';
                }
            }
        }
    }
}
