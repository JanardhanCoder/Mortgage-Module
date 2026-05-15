// page 60055 "GE LHFS Sale Lines"
// {
//     PageType = ListPart;
//     SourceTable = "GE LHFS Sale Line";
//     ApplicationArea = All;
//     Caption = 'LHFS Sale Lines';

//     layout
//     {
//         area(content)
//         {
//             repeater(Lines)
//             {
//                 field("Loan No."; Rec."Loan No.") { }
//                 field("Principal Outstanding"; Rec."Principal Outstanding") { }
//                 field("Accrued Interest Sold"; Rec."Accrued Interest Sold") { }
//                 field("Price %"; Rec."Price %") { }
//                 field("Sale Amount"; Rec."Sale Amount") { Editable = false; }
//                 field("SRP/Premium"; Rec."SRP/Premium") { }
//                 field("Fees/Adjustments"; Rec."Fees/Adjustments") { }
//                 field("Net Proceeds"; Rec."Net Proceeds") { Editable = false; }
//                 field("Gain/Loss"; Rec."Gain/Loss") { Editable = false; }
//                 field("Servicing Retained"; Rec."Servicing Retained") { }
//                 field("Delivery Package Status"; Rec."Delivery Package Status") { }
//                 field("Investor Ref"; Rec."Investor Ref") { }
//             }
//         }
//     }
// }