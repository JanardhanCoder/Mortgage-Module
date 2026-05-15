namespace MortgageForUS.MortgageForUS;

page 60026 "GE Interest Rate Setup"
{
    PageType = List;
    ApplicationArea = All;
   // UsageCategory = Administration;
    SourceTable = "GE Interest Rate Setup";
    CardPageId = "GE Interest Rate Setup card";
    Caption = 'Interest Rate Setup';
    UsageCategory = Lists;
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Rate Code"; Rec."Rate Code")
                {
                    ApplicationArea = All;
                }

                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }

                field("Rate Type"; rec."Rate Type")
                {
                    ApplicationArea = All;
                }

                field("Revision Frequency"; Rec."Revision Frequency")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}

