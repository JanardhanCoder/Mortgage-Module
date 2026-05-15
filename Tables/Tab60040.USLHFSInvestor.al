// table 60040 "GE LHFS Investor"
// {
//     DataClassification = CustomerContent;
//     Caption = 'LHFS Investor';

//     fields
//     {
//         field(1; "No."; Code[20]) { Caption = 'No.'; }
//         field(2; Name; Text[100]) { Caption = 'Name'; }
//         field(3; Active; Boolean) { Caption = 'Active'; InitValue = true; }
//         field(10; "Settlement Method"; Option)
//         {
//             Caption = 'Settlement Method';
//             OptionMembers = Wire,EFT,Cheque,Other;
//         }
//         field(11; "Bank Account No."; Code[20]) { Caption = 'Proceeds Bank Account'; TableRelation = "Bank Account"."No."; }
//         field(12; "Default Sale Type"; Enum "GE LHFS Sale Type") { Caption = 'Default Sale Type'; }
//         field(13; "Purchase Advice Format"; Option)
//         {
//             Caption = 'Purchase Advice Format';
//             OptionMembers = CSV,PDF,Email,Portal,Other;
//         }
//         field(14; "Remittance Contact"; Text[100]) { Caption = 'Remittance Contact'; }
//         field(15; "Email"; Text[100]) { Caption = 'Email'; }
//     }

//     keys
//     {
//         key(PK; "No.") { Clustered = true; }
//     }
// }