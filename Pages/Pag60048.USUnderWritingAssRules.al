namespace MortgageForUS.MortgageForUS;

page 60048 "US UnderWriting Ass Rules"
{
    ApplicationArea = All;
    Caption = 'US UnderWriting Ass Rules';
    PageType = List;
    SourceTable = "US Underwriting Risk Rules";
    UsageCategory = Administration;
    AutoSplitKey = true;
    SourceTableView = sorting("Rule Type", "Product Type", "From Value");

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Line No"; Rec."Line No")
                {
                    ToolTip = 'Specifies the value of the Line No field.', Comment = '%';
                    Visible = false;
                }
                field("Product Type"; Rec."Product Type")
                {
                    ToolTip = 'Specifies the value of the Product Type field.', Comment = '%';
                    Visible = false;
                }
                field("Rule Type"; Rec."Rule Type")
                {
                    ToolTip = 'Specifies the value of the Rule Type field.', Comment = '%';
                }
                field("From Value"; Rec."From Value")
                {
                    ToolTip = 'Specifies the value of the From Value field.', Comment = '%';
                }
                field("To Value"; Rec."To Value")
                {
                    ToolTip = 'Specifies the value of the To Value field.', Comment = '%';
                }
                field("Risk Level"; Rec."Risk Level")
                {
                    ToolTip = 'Specifies the value of the Risk Level field.', Comment = '%';
                }
                field(Blocked; Rec.Blocked)
                {
                    ToolTip = 'Specifies the value of the Blocked field.', Comment = '%';
                }
            }
        }
    }
}
