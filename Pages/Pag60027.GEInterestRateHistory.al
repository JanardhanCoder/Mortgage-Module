namespace MortgageForUS.MortgageForUS;

page 60027 "GE Interest Rate Lines"
{
    UsageCategory = Administration;
    SourceTable = "GE Interest Rate History";
    Caption = 'Interest Rate Lines';
    PageType = ListPart;
    ApplicationArea = All;

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
                field("Effective Date"; Rec."Effective Date")
                {
                    ApplicationArea = All;
                }
                field("Expired Date"; Rec."Expired Date") { ApplicationArea = all; }
                field("Interest Rate %"; Rec."Interest Rate %")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(NewRate)
            {
                Caption = 'New Rate';
                Image = New;
                ApplicationArea = All;

                trigger OnAction()
                begin
                    CurrPage.Editable(true);
                end;
            }
        }
    }
}

