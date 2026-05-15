namespace MortgageForUS.MortgageForUS;

page 60024 "US Mortgage Doc Types"
{
    PageType = List;
    SourceTable = "US Mortgage Doc Type";
    ApplicationArea = All;
    UsageCategory = Lists;  
    Caption = 'Mortgage Document Types';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = All;
                }

                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }

                field("Mandatory Stage"; Rec."Mandatory Stage")
                {
                    ApplicationArea = All;
                }

                field("Expiry Required"; Rec."Expiry Required")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}


