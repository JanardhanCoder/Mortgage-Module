// page 60053 "GE LHFS Sales"
// {
//     PageType = List;
//     SourceTable = "GE LHFS Sale Header";
//     ApplicationArea = All;
//     UsageCategory = Lists;
//     Caption = 'LHFS Sales';

//     layout
//     {
//         area(content)
//         {
//             repeater(General)
//             {
//                 field("No."; Rec."No.") { }
//                 field("Investor No."; Rec."Investor No.") { }
//                 field("Trade Date"; Rec."Trade Date") { }
//                 field("Expected Settlement Date"; Rec."Expected Settlement Date") { }
//                 field(Status; Rec.Status) { }
//                 field("Sale Type"; Rec."Sale Type") { }
//                 field("Price %"; Rec."Price %") { }
//                 field("Net Proceeds"; Rec."Net Proceeds") { }
//             }
//         }
//     }
// }