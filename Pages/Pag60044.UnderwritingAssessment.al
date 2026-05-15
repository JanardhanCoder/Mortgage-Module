namespace MortgageForUS.MortgageForUS;

page 60044 "Underwriting Assessment"
{
    ApplicationArea = All;
    Caption = 'Underwriting Assessment';
    PageType = List;
    SourceTable = "Underwriting Assessment";
    UsageCategory = Lists;
    CardPageId = "Underwriting Assessment Card";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Assessment No."; Rec."Assessment No.")
                {
                    ToolTip = 'Specifies the value of the Assessment No. field.', Comment = '%';
                }
                field("Assessment Date"; Rec."Assessment Date")
                {
                    ToolTip = 'Specifies the value of the Assessment Date field.', Comment = '%';
                }
                field("Assessment Type"; Rec."Assessment Type")
                {
                    ToolTip = 'Specifies the value of the Assessment Type field.', Comment = '%';
                }
                field("Application No."; Rec."Application No.")
                {
                    ToolTip = 'Specifies the value of the Application No. field.', Comment = '%';
                }
                field("Credit Score"; Rec."Credit Score")
                {
                    ToolTip = 'Specifies the value of the Credit Score field.', Comment = '%';
                }
                field("Monthly Income"; Rec."Monthly Income")
                {
                    ToolTip = 'Specifies the value of the Monthly Income field.', Comment = '%';
                }
            }
        }
    }
}
