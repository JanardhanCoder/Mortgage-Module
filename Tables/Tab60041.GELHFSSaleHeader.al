// table 60041 "GE LHFS Sale Header"
// {
//     DataClassification = CustomerContent;
//     Caption = 'LHFS Sale Header';

//     fields
//     {
//         field(1; "No."; Code[20]) { Caption = 'No.'; }
//         field(2; "Investor No."; Code[20]) { Caption = 'Investor No.'; TableRelation = "GE LHFS Investor"."No."; }
//         field(3; "Trade Date"; Date) { Caption = 'Trade Date'; }
//         field(4; "Expected Settlement Date"; Date) { Caption = 'Expected Settlement Date'; }
//         field(5; "Settlement Date"; Date) { Caption = 'Settlement Date'; }
//         field(6; Status; Enum "GE LHFS Sale Status") { Caption = 'Status'; }
//         field(7; "Sale Type"; Enum "GE LHFS Sale Type") { Caption = 'Sale Type'; }

//         field(10; Currency; Code[10]) { Caption = 'Currency'; TableRelation = Currency.Code; }
//         field(11; "Price %"; Decimal) { Caption = 'Price %'; DecimalPlaces = 0 : 5; }
//         field(12; "SRP/Premium"; Decimal) { Caption = 'SRP / Premium'; }
//         field(13; "Fees/Adjustments"; Decimal) { Caption = 'Fees / Adjustments'; }
//         field(14; "Net Proceeds"; Decimal) { Caption = 'Net Proceeds'; Editable = false; }
//         field(15; "Proceeds Bank Account"; Code[20]) { Caption = 'Proceeds Bank Account'; TableRelation = "Bank Account"."No."; }

//         field(20; "Settlement Ref"; Text[50]) { Caption = 'Settlement Ref'; }
//         field(21; "GL Document No."; Code[20]) { Caption = 'GL Document No.'; Editable = false; }

//         field(30; "Created By"; Code[50]) { Editable = false; }
//         field(31; "Created At"; DateTime) { Editable = false; }
//     }

//     keys
//     {
//         key(PK; "No.") { Clustered = true; }
//     }

//     trigger OnInsert()
//     begin
//         "Created By" := UserId;
//         "Created At" := CurrentDateTime();
//         if Status = Status::Pipeline then;
//     end;
// }