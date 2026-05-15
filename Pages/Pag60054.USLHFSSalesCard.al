// page 60054 "GE LHFS Sale Card"
// {
//     PageType = Card;
//     SourceTable = "GE LHFS Sale Header";
//     ApplicationArea = All;
//     Caption = 'LHFS Sale Card';

//     layout
//     {
//         area(content)
//         {
//             group(General)
//             {
//                 field("No."; Rec."No.") { }
//                 field("Investor No."; Rec."Investor No.") { }
//                 field("Trade Date"; Rec."Trade Date") { }
//                 field("Expected Settlement Date"; Rec."Expected Settlement Date") { }
//                 field("Settlement Date"; Rec."Settlement Date") { }
//                 field(Status; Rec.Status) { }
//                 field("Sale Type"; Rec."Sale Type") { }
//                 field(Currency; Rec.Currency) { }
//                 field("Price %"; Rec."Price %") { }
//                 field("SRP/Premium"; Rec."SRP/Premium") { }
//                 field("Fees/Adjustments"; Rec."Fees/Adjustments") { }
//                 field("Net Proceeds"; Rec."Net Proceeds") { Editable = false; }
//                 field("Proceeds Bank Account"; Rec."Proceeds Bank Account") { }
//                 field("Settlement Ref"; Rec."Settlement Ref") { }
//                 field("GL Document No."; Rec."GL Document No.") { Editable = false; }
//             }

//             part(Lines; "GE LHFS Sale Lines")
//             {
//                 SubPageLink = "Sale No." = field("No.");
//             }
//         }
//     }

//     actions
//     {
//         area(Processing)
//         {
//             action(SettleSale)
//             {
//                 Caption = 'Settle Sale';
//                 ApplicationArea = All;
//                 Image = Post;

//                 trigger OnAction()
//                 var
//                     CU: Codeunit "GE LHFS Sale Post";
//                 begin
//                     CU.PostSettlement(Rec."No.");
//                     CurrPage.Update();
//                 end;
//             }
//         }
//     }
// }