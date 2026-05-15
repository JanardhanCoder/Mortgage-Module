// namespace MortgageForUS.MortgageForUS;

// page 60038 "GE Mortgage Agent Card"
// {
//     PageType = Card;
//     SourceTable = "GE Mortgage Agent";
//     Caption = 'Mortgage Agent';
//     ApplicationArea = All;
//     //UsageCategory = Administration;

//     layout
//     {
//         area(content)
//         {
//             group(General)
//             {
//                 field("Agent Code"; Rec."Agent Code")
//                 {
//                     ApplicationArea = All;
//                 }
//                 // field(Name; Rec.Name)
//                 // {
//                 //     ApplicationArea = All;
//                 // }
//                 // field(Status; Rec.Status)
//                 // {
//                 //     ApplicationArea = All;
//                 // }
//             }

//             group("CRM Information")
//             {
//                 Caption = 'CRM / Loan Sourcing';
//                 field("CRM Agent Contact No."; Rec."CRM Agent Contact No.")
//                 {
//                     ApplicationArea = All;
//                     ToolTip = 'Agent contact linked to borrower / loan application.';
//                 }
                
//             }

//             group("Payment Information")
//             {
//                 Caption = 'Commission Payment';

//                 field("Payee Contact No."; Rec."Payee Contact No.")
//                 {
//                     ApplicationArea = All;
//                     ToolTip = 'Payee contact for commission payment.';
//                 }
//                 field("Vendor No."; Rec."Agent Vendor No.")
//                 {
//                     ApplicationArea = All;
//                     ToolTip = 'Vendor used for AP payment of agent commission.';
//                 }
//             }
//         }
//     }

//     actions
//     {
//         area(processing)
//         {
//             action(ViewAgreements)
//             {
//                 Caption = 'Agent Agreements';
//                 Image = ContractPayment;
//                 RunObject = Page "GE Agent Agreement List";
//                 RunPageLink = "No."= field("Agent Code");
//             }

//             action(ViewCommissions)
//             {
//                 Caption = 'Agent Commissions';
//                 Image = Ledger;
//                RunObject = Page "GE Agent Agreement List";
//                RunPageLink = "No." = field("Agent Code");
//             }
//         }
//     }
// }

