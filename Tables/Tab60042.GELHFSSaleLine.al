// table 60042 "GE LHFS Sale Line"
// {
//     DataClassification = CustomerContent;
//     Caption = 'LHFS Sale Line';

//     fields
//     {
//         field(1; "Sale No."; Code[20]) { Caption = 'Sale No.'; TableRelation = "GE LHFS Sale Header"."No."; }
//         field(2; "Line No."; Integer) { Caption = 'Line No.'; }
//         field(3; "Loan No."; Code[20])
//         {
//             Caption = 'Loan No.';
//             TableRelation = "US Mortgage Agreement Header"."Loan No.";
//             trigger OnValidate()
//             begin
//                 CalcValues();
//             end;
//         }

//         field(10; "Principal Outstanding"; Decimal) { Caption = 'Principal Outstanding'; }
//         field(11; "Accrued Interest Sold"; Decimal) { Caption = 'Accrued Interest Sold'; }
//         field(12; "Price %"; Decimal) { Caption = 'Price %'; DecimalPlaces = 0 : 5; }
//         field(13; "Sale Amount"; Decimal) { Caption = 'Sale Amount'; Editable = false; }
//         field(14; "SRP/Premium"; Decimal) { Caption = 'SRP / Premium'; }
//         field(15; "Fees/Adjustments"; Decimal) { Caption = 'Fees / Adjustments'; }
//         field(16; "Net Proceeds"; Decimal) { Caption = 'Net Proceeds'; Editable = false; }
//         field(17; "Gain/Loss"; Decimal) { Caption = 'Gain / Loss'; Editable = false; }

//         field(20; "Servicing Retained"; Boolean) { Caption = 'Servicing Retained'; }
//         field(21; "Delivery Package Status"; Option)
//         {
//             Caption = 'Delivery Package Status';
//             OptionMembers = Pending,Complete,"Missing Docs";
//         }
//         field(22; "Investor Ref"; Text[50]) { Caption = 'Investor Ref'; }
//     }

//     keys
//     {
//         key(PK; "Sale No.", "Line No.") { Clustered = true; }
//     }


//     trigger OnModify()
//     begin
//         CalcValues();
//     end;

//     local procedure CalcValues()
//     begin
//         "Sale Amount" := Round(("Principal Outstanding" * "Price %" / 100) + "Accrued Interest Sold", 0.01);
//         "Net Proceeds" := Round("Sale Amount" + "SRP/Premium" - "Fees/Adjustments", 0.01);
//         "Gain/Loss" := Round("Net Proceeds" - ("Principal Outstanding" + "Accrued Interest Sold"), 0.01);
//     end;
// }