namespace MortgageForUS.MortgageForUS;
page 60028 "GE Interest Rate Setup card"
{
    PageType = Card;
    SourceTable = "GE Interest Rate Setup";
    Caption = 'Interest Rate Card';
    ApplicationArea = all;

    layout
    {
        area(content)
        {
            group(General)
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
            part(Lines; "GE Interest Rate Lines")
            {
                ApplicationArea = all;
                SubPageLink = "Rate Code" = field("Rate Code");
            }

        }
    }
}
