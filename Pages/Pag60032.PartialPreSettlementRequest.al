namespace MortgageForUS.MortgageForUS;
using Mortgage.Mortgage;

page 60032 "Partial Pre-Settlement Request"
{
    PageType = Card;
    SourceTable = "Partial Pre-Settlement Input1";
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Partial Amount"; PartialAmount)
                {
                    ApplicationArea = All;
                }
                field("Settlement Date"; SettlementDate)
                {
                    ApplicationArea = All;
                }
                field("Settlement Option"; SettlementOption)
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
            action("Submit")
            {
                Caption = 'Submit';
                trigger OnAction()
                begin
                    CurrPage.Close();
                end;
            }
        }
    }

    var
        PartialAmount: Decimal;
        SettlementDate: Date;
        SettlementOption: Enum "Pre-Settlement Option";
}

