<?php
/*********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 ** The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
*
 ********************************************************************************/
require_once('include/database/PearDatabase.php');

$customviews = Array(Array('viewname'=>'All',
			   'setdefault'=>'1','setmetrics'=>'0','status'=>'0','userid'=>'1',
			   'cvmodule'=>'Leads','stdfilterid'=>'','advfilterid'=>''),

		     Array('viewname'=>'Hot Leads',
			   'setdefault'=>'0','setmetrics'=>'1','status'=>'3','userid'=>'1',
			   'cvmodule'=>'Leads','stdfilterid'=>'','advfilterid'=>'0'),

		     Array('viewname'=>'This Month Leads',
			   'setdefault'=>'0','setmetrics'=>'0','status'=>'3','userid'=>'1',
			   'cvmodule'=>'Leads','stdfilterid'=>'0','advfilterid'=>''),

		     Array('viewname'=>'All',
                           'setdefault'=>'1','setmetrics'=>'0','status'=>'0','userid'=>'1',
                           'cvmodule'=>'Accounts','stdfilterid'=>'','advfilterid'=>''),

		     Array('viewname'=>'Prospect Accounts',
                           'setdefault'=>'0','setmetrics'=>'1','status'=>'3','userid'=>'1',
                           'cvmodule'=>'Accounts','stdfilterid'=>'','advfilterid'=>'1'),

		     Array('viewname'=>'New This Week',
                           'setdefault'=>'0','setmetrics'=>'0','status'=>'3','userid'=>'1',
                           'cvmodule'=>'Accounts','stdfilterid'=>'1','advfilterid'=>''),

		     Array('viewname'=>'All',
                           'setdefault'=>'1','setmetrics'=>'0','status'=>'0','userid'=>'1',
                           'cvmodule'=>'Contacts','stdfilterid'=>'','advfilterid'=>''),

		     Array('viewname'=>'Contacts Address',
                           'setdefault'=>'0','setmetrics'=>'0','status'=>'3','userid'=>'1',
                           'cvmodule'=>'Contacts','stdfilterid'=>'','advfilterid'=>''),

		     Array('viewname'=>'Todays Birthday',
                           'setdefault'=>'0','setmetrics'=>'0','status'=>'3','userid'=>'1',
                           'cvmodule'=>'Contacts','stdfilterid'=>'2','advfilterid'=>''),

		     Array('viewname'=>'All',
                           'setdefault'=>'1','setmetrics'=>'0','status'=>'0','userid'=>'1',
                           'cvmodule'=>'Potentials','stdfilterid'=>'','advfilterid'=>''),

		     Array('viewname'=>'Potentials Won',
                           'setdefault'=>'0','setmetrics'=>'1','status'=>'3','userid'=>'1',
                           'cvmodule'=>'Potentials','stdfilterid'=>'','advfilterid'=>'2'),

		     Array('viewname'=>'Prospecting',
                           'setdefault'=>'0','setmetrics'=>'0','status'=>'3','userid'=>'1',
                           'cvmodule'=>'Potentials','stdfilterid'=>'','advfilterid'=>'3'),

		     Array('viewname'=>'All',
                           'setdefault'=>'1','setmetrics'=>'0','status'=>'0','userid'=>'1',
                           'cvmodule'=>'HelpDesk','stdfilterid'=>'','advfilterid'=>''),

	             Array('viewname'=>'Open Tickets',
                           'setdefault'=>'0','setmetrics'=>'1','status'=>'3','userid'=>'1',
                           'cvmodule'=>'HelpDesk','stdfilterid'=>'','advfilterid'=>'4'),

		     Array('viewname'=>'High Prioriy Tickets',
                           'setdefault'=>'0','setmetrics'=>'0','status'=>'3','userid'=>'1',
                           'cvmodule'=>'HelpDesk','stdfilterid'=>'','advfilterid'=>'5'),

		     Array('viewname'=>'All',
                           'setdefault'=>'1','setmetrics'=>'0','status'=>'0','userid'=>'1',
                           'cvmodule'=>'Quotes','stdfilterid'=>'','advfilterid'=>''),

		     Array('viewname'=>'Open Quotes',
                           'setdefault'=>'0','setmetrics'=>'1','status'=>'3','userid'=>'1',
                           'cvmodule'=>'Quotes','stdfilterid'=>'','advfilterid'=>'6'),

		     Array('viewname'=>'Rejected Quotes',
                           'setdefault'=>'0','setmetrics'=>'0','status'=>'3','userid'=>'1',
                           'cvmodule'=>'Quotes','stdfilterid'=>'','advfilterid'=>'7'),

		    Array('viewname'=>'All',
                          'setdefault'=>'1','setmetrics'=>'0','status'=>'0','userid'=>'1',
                          'cvmodule'=>'Calendar','stdfilterid'=>'','advfilterid'=>''),

		    Array('viewname'=>'All',
                          'setdefault'=>'1','setmetrics'=>'0','status'=>'0','userid'=>'1',
                          'cvmodule'=>'Emails','stdfilterid'=>'','advfilterid'=>''),

		    Array('viewname'=>'All',
                          'setdefault'=>'1','setmetrics'=>'0','status'=>'0','userid'=>'1',
                          'cvmodule'=>'Invoice','stdfilterid'=>'','advfilterid'=>''),

		    Array('viewname'=>'All',
                          'setdefault'=>'1','setmetrics'=>'0','status'=>'0','userid'=>'1',
                          'cvmodule'=>'Documents','stdfilterid'=>'','advfilterid'=>''),

	            Array('viewname'=>'All',
                          'setdefault'=>'1','setmetrics'=>'0','status'=>'0','userid'=>'1',
                          'cvmodule'=>'PriceBooks','stdfilterid'=>'','advfilterid'=>''),

	            Array('viewname'=>'All',
                          'setdefault'=>'1','setmetrics'=>'0','status'=>'0','userid'=>'1',
                          'cvmodule'=>'Products','stdfilterid'=>'','advfilterid'=>''),

	            Array('viewname'=>'All',
                          'setdefault'=>'1','setmetrics'=>'0','status'=>'0','userid'=>'1',
                          'cvmodule'=>'PurchaseOrder','stdfilterid'=>'','advfilterid'=>''),

	            Array('viewname'=>'All',
                          'setdefault'=>'1','setmetrics'=>'0','status'=>'0','userid'=>'1',
                          'cvmodule'=>'SalesOrder','stdfilterid'=>'','advfilterid'=>''),

	            Array('viewname'=>'All',
                          'setdefault'=>'1','setmetrics'=>'0','status'=>'0','userid'=>'1',
                          'cvmodule'=>'Vendors','stdfilterid'=>'','advfilterid'=>''),

		    Array('viewname'=>'All',
                          'setdefault'=>'1','setmetrics'=>'0','status'=>'0','userid'=>'1',
                          'cvmodule'=>'Faq','stdfilterid'=>'','advfilterid'=>''),

		    Array('viewname'=>'All',
                          'setdefault'=>'1','setmetrics'=>'0','status'=>'0','userid'=>'1',
                          'cvmodule'=>'Campaigns','stdfilterid'=>'','advfilterid'=>''),

		    Array('viewname'=>'All',
                          'setdefault'=>'1','setmetrics'=>'0','status'=>'0','userid'=>'1',
			  'cvmodule'=>'Webmails','stdfilterid'=>'','advfilterid'=>''),

		    Array('viewname'=>'Drafted FAQ',
                          'setdefault'=>'0','setmetrics'=>'0','status'=>'3','userid'=>'1',
                          'cvmodule'=>'Faq','stdfilterid'=>'','advfilterid'=>'8'),

		    Array('viewname'=>'Published FAQ',
                          'setdefault'=>'0','setmetrics'=>'0','status'=>'3','userid'=>'1',
			  'cvmodule'=>'Faq','stdfilterid'=>'','advfilterid'=>'9'),

	            Array('viewname'=>'Open Purchase Orders',
                          'setdefault'=>'0','setmetrics'=>'0','status'=>'3','userid'=>'1',
                          'cvmodule'=>'PurchaseOrder','stdfilterid'=>'','advfilterid'=>'10'),

	            Array('viewname'=>'Received Purchase Orders',
                          'setdefault'=>'0','setmetrics'=>'0','status'=>'3','userid'=>'1',
                          'cvmodule'=>'PurchaseOrder','stdfilterid'=>'','advfilterid'=>'11'),

		    Array('viewname'=>'Open Invoices',
                          'setdefault'=>'0','setmetrics'=>'0','status'=>'3','userid'=>'1',
			  'cvmodule'=>'Invoice','stdfilterid'=>'','advfilterid'=>'12'),

		    Array('viewname'=>'Paid Invoices',
                          'setdefault'=>'0','setmetrics'=>'0','status'=>'3','userid'=>'1',
			  'cvmodule'=>'Invoice','stdfilterid'=>'','advfilterid'=>'13'),

	            Array('viewname'=>'Pending Sales Orders',
                          'setdefault'=>'0','setmetrics'=>'0','status'=>'3','userid'=>'1',
                          'cvmodule'=>'SalesOrder','stdfilterid'=>'','advfilterid'=>'14'),
		    );


$cvcolumns = Array(Array('ld_leaddetails:lead_no:lead_no:Leads_Lead_No:V',
						 'ld_leaddetails:lastname:lastname:Leads_Last_Name:V',
                         'ld_leaddetails:firstname:firstname:Leads_First_Name:V',
                         'ld_leaddetails:company:company:Leads_Company:V',
			 'ld_leadaddress:phone:phone:Leads_Phone:V',
                         'ld_leadsubdetails:website:website:Leads_Website:V',
                         'ld_leaddetails:email:email:Leads_Email:E',
			 'ld_crmentity:smownerid:assigned_user_id:Leads_Assigned_To:V'),

	           Array('ld_leaddetails:firstname:firstname:Leads_First_Name:V',
                         'ld_leaddetails:lastname:lastname:Leads_Last_Name:V',
                         'ld_leaddetails:company:company:Leads_Company:V',
                         'ld_leaddetails:leadsource:leadsource:Leads_Lead_Source:V',
                         'ld_leadsubdetails:website:website:Leads_Website:V',
                         'ld_leaddetails:email:email:Leads_Email:E'),

		   Array('ld_leaddetails:firstname:firstname:Leads_First_Name:V',
                         'ld_leaddetails:lastname:lastname:Leads_Last_Name:V',
                         'ld_leaddetails:company:company:Leads_Company:V',
                         'ld_leaddetails:leadsource:leadsource:Leads_Lead_Source:V',
                         'ld_leadsubdetails:website:website:Leads_Website:V',
                         'ld_leaddetails:email:email:Leads_Email:E'),

		  		 Array('ld_account:account_no:account_no:Accounts_Account_No:V',
				 		'ld_account:accountname:accountname:Accounts_Account_Name:V',
                         'ld_accountbillads:bill_city:bill_city:Accounts_City:V',
                         'ld_account:website:website:Accounts_Website:V',
                         'ld_account:phone:phone:Accounts_Phone:V',
                         'ld_crmentity:smownerid:assigned_user_id:Accounts_Assigned_To:V'),

		   Array('ld_account:accountname:accountname:Accounts_Account_Name:V',
			 'ld_account:phone:phone:Accounts_Phone:V',
			 'ld_account:website:website:Accounts_Website:V',
			 'ld_account:rating:rating:Accounts_Rating:V',
			 'ld_crmentity:smownerid:assigned_user_id:Accounts_Assigned_To:V'),

		   Array('ld_account:accountname:accountname:Accounts_Account_Name:V',
                         'ld_account:phone:phone:Accounts_Phone:V',
                         'ld_account:website:website:Accounts_Website:V',
                         'ld_accountbillads:bill_city:bill_city:Accounts_City:V',
                         'ld_crmentity:smownerid:assigned_user_id:Accounts_Assigned_To:V'),

		   Array('ld_contactdetails:contact_no:contact_no:Contacts_Contact_Id:V',
		   			'ld_contactdetails:firstname:firstname:Contacts_First_Name:V',
                         'ld_contactdetails:lastname:lastname:Contacts_Last_Name:V',
                         'ld_contactdetails:title:title:Contacts_Title:V',
						 'ld_contactdetails:accountid:account_id:Contacts_Account_Name:I',
                         'ld_contactdetails:email:email:Contacts_Email:E',
                         'ld_contactdetails:phone:phone:Contacts_Office_Phone:V',
			 'ld_crmentity:smownerid:assigned_user_id:Contacts_Assigned_To:V'),

		   Array('ld_contactdetails:firstname:firstname:Contacts_First_Name:V',
                         'ld_contactdetails:lastname:lastname:Contacts_Last_Name:V',
                         'ld_contactaddress:mailingstreet:mailingstreet:Contacts_Mailing_Street:V',
                         'ld_contactaddress:mailingcity:mailingcity:Contacts_Mailing_City:V',
                         'ld_contactaddress:mailingstate:mailingstate:Contacts_Mailing_State:V',
			 'ld_contactaddress:mailingzip:mailingzip:Contacts_Mailing_Zip:V',
			 'ld_contactaddress:mailingcountry:mailingcountry:Contacts_Mailing_Country:V'),

		   Array('ld_contactdetails:firstname:firstname:Contacts_First_Name:V',
                 'ld_contactdetails:lastname:lastname:Contacts_Last_Name:V',
                 'ld_contactdetails:title:title:Contacts_Title:V',
                 'ld_contactdetails:accountid:account_id:Contacts_Account_Name:I',
                 'ld_contactdetails:email:email:Contacts_Email:E',
				 'ld_contactsubdetails:otherphone:otherphone:Contacts_Phone:V',
				 'ld_crmentity:smownerid:assigned_user_id:Contacts_Assigned_To:V'),

		   Array('ld_potential:potential_no:potential_no:Potentials_Potential_No:V',
 	   			 'ld_potential:potentialname:potentialname:Potentials_Potential_Name:V',
                 'ld_potential:related_to:related_to:Potentials_Related_To:V',
                 'ld_potential:sales_stage:sales_stage:Potentials_Sales_Stage:V',
                 'ld_potential:leadsource:leadsource:Potentials_Lead_Source:V',
                 'ld_potential:closingdate:closingdate:Potentials_Expected_Close_Date:D',
                 'ld_crmentity:smownerid:assigned_user_id:Potentials_Assigned_To:V'),

	       Array('ld_potential:potentialname:potentialname:Potentials_Potential_Name:V',
	             'ld_potential:related_to:related_to:Potentials_Related_To:V',
	             'ld_potential:amount:amount:Potentials_Amount:N',
	             'ld_potential:closingdate:closingdate:Potentials_Expected_Close_Date:D',
	             'ld_crmentity:smownerid:assigned_user_id:Potentials_Assigned_To:V'),

		   Array('ld_potential:potentialname:potentialname:Potentials_Potential_Name:V',
                 'ld_potential:related_to:related_to:Potentials_Related_To:V',
                 'ld_potential:amount:amount:Potentials_Amount:N',
                 'ld_potential:leadsource:leadsource:Potentials_Lead_Source:V',
                 'ld_potential:closingdate:closingdate:Potentials_Expected_Close_Date:D',
                 'ld_crmentity:smownerid:assigned_user_id:Potentials_Assigned_To:V'),

		   Array(//'ld_crmentity:crmid::HelpDesk_Ticket_ID:I',
		   				'ld_troubletickets:ticket_no:ticket_no:HelpDesk_Ticket_No:V',
			 'ld_troubletickets:title:ticket_title:HelpDesk_Title:V',
                         'ld_troubletickets:parent_id:parent_id:HelpDesk_Related_To:I',
                         'ld_troubletickets:status:ticketstatus:HelpDesk_Status:V',
                         'ld_troubletickets:priority:ticketpriorities:HelpDesk_Priority:V',
                         'ld_crmentity:smownerid:assigned_user_id:HelpDesk_Assigned_To:V'),

		   Array('ld_troubletickets:title:ticket_title:HelpDesk_Title:V',
                         'ld_troubletickets:parent_id:parent_id:HelpDesk_Related_To:I',
                         'ld_troubletickets:priority:ticketpriorities:HelpDesk_Priority:V',
                         'ld_troubletickets:product_id:product_id:HelpDesk_Product_Name:I',
                         'ld_crmentity:smownerid:assigned_user_id:HelpDesk_Assigned_To:V'),

		   Array('ld_troubletickets:title:ticket_title:HelpDesk_Title:V',
                         'ld_troubletickets:parent_id:parent_id:HelpDesk_Related_To:I',
                         'ld_troubletickets:status:ticketstatus:HelpDesk_Status:V',
                         'ld_troubletickets:product_id:product_id:HelpDesk_Product_Name:I',
                         'ld_crmentity:smownerid:assigned_user_id:HelpDesk_Assigned_To:V'),

		   Array('ld_quotes:quote_no:quote_no:Quotes_Quote_No:V',
			 'ld_quotes:subject:subject:Quotes_Subject:V',
                         'ld_quotes:quotestage:quotestage:Quotes_Quote_Stage:V',
                         'ld_quotes:potentialid:potential_id:Quotes_Potential_Name:I',
						 'ld_quotes:accountid:account_id:Quotes_Account_Name:I',
                         'ld_quotes:total:hdnGrandTotal:Quotes_Total:I',
			 'ld_crmentity:smownerid:assigned_user_id:Quotes_Assigned_To:V'),

		   Array('ld_quotes:subject:subject:Quotes_Subject:V',
                         'ld_quotes:quotestage:quotestage:Quotes_Quote_Stage:V',
                         'ld_quotes:potentialid:potential_id:Quotes_Potential_Name:I',
						'ld_quotes:accountid:account_id:Quotes_Account_Name:I',
                         'ld_quotes:validtill:validtill:Quotes_Valid_Till:D',
			 'ld_crmentity:smownerid:assigned_user_id:Quotes_Assigned_To:V'),

		   Array('ld_quotes:subject:subject:Quotes_Subject:V',
                         'ld_quotes:potentialid:potential_id:Quotes_Potential_Name:I',
						'ld_quotes:accountid:account_id:Quotes_Account_Name:I',
                         'ld_quotes:validtill:validtill:Quotes_Valid_Till:D',
                         'ld_crmentity:smownerid:assigned_user_id:Quotes_Assigned_To:V'),

		   Array('ld_activity:status:taskstatus:Calendar_Status:V',
                         'ld_activity:activitytype:activitytype:Calendar_Type:V',
                         'ld_activity:subject:subject:Calendar_Subject:V',
                         'ld_seactivityrel:crmid:parent_id:Calendar_Related_to:V',
                         'ld_activity:date_start:date_start:Calendar_Start_Date:D',
                         'ld_activity:due_date:due_date:Calendar_End_Date:D',
                         'ld_crmentity:smownerid:assigned_user_id:Calendar_Assigned_To:V'),

		   Array('ld_activity:subject:subject:Emails_Subject:V',
       			 'ld_emaildetails:to_email:saved_toid:Emails_To:V',
                 	 'ld_activity:date_start:date_start:Emails_Date_Sent:D'),

		   Array('ld_invoice:invoice_no:invoice_no:Invoice_Invoice_No:V',
                         'ld_invoice:subject:subject:Invoice_Subject:V',
                         'ld_invoice:salesorderid:salesorder_id:Invoice_Sales_Order:I',
                         'ld_invoice:invoicestatus:invoicestatus:Invoice_Status:V',
                         'ld_invoice:total:hdnGrandTotal:Invoice_Total:I',
                         'ld_crmentity:smownerid:assigned_user_id:Invoice_Assigned_To:V'),

		  Array('ld_notes:note_no:note_no:Notes_Note_No:V',
		  				'ld_notes:title:notes_title:Notes_Title:V',
                        'ld_notes:filename:filename:Notes_File:V',
                        'ld_crmentity:modifiedtime:modifiedtime:Notes_Modified_Time:DT',
		  				'ld_crmentity:smownerid:assigned_user_id:Notes_Assigned_To:V'),

		  Array('ld_pricebook:pricebook_no:pricebook_no:PriceBooks_PriceBook_No:V',
					  'ld_pricebook:bookname:bookname:PriceBooks_Price_Book_Name:V',
                        'ld_pricebook:active:active:PriceBooks_Active:V',
                        'ld_pricebook:currency_id:currency_id:PriceBooks_Currency:I'),

		  Array('ld_products:product_no:product_no:Products_Product_No:V',
		  		'ld_products:productname:productname:Products_Product_Name:V',
                        'ld_products:productcode:productcode:Products_Part_Number:V',
                        'ld_products:commissionrate:commissionrate:Products_Commission_Rate:V',
			'ld_products:qtyinstock:qtyinstock:Products_Quantity_In_Stock:V',
                        'ld_products:qty_per_unit:qty_per_unit:Products_Qty/Unit:V',
                        'ld_products:unit_price:unit_price:Products_Unit_Price:V'),

		  Array('ld_purchaseorder:purchaseorder_no:purchaseorder_no:PurchaseOrder_PurchaseOrder_No:V',
                        'ld_purchaseorder:subject:subject:PurchaseOrder_Subject:V',
                        'ld_purchaseorder:vendorid:vendor_id:PurchaseOrder_Vendor_Name:I',
                        'ld_purchaseorder:tracking_no:tracking_no:PurchaseOrder_Tracking_Number:V',
						'ld_purchaseorder:total:hdnGrandTotal:PurchaseOrder_Total:V',
                        'ld_crmentity:smownerid:assigned_user_id:PurchaseOrder_Assigned_To:V'),

	          Array('ld_salesorder:salesorder_no:salesorder_no:SalesOrder_SalesOrder_No:V',
                        'ld_salesorder:subject:subject:SalesOrder_Subject:V',
						'ld_salesorder:accountid:account_id:SalesOrder_Account_Name:I',
                        'ld_salesorder:quoteid:quote_id:SalesOrder_Quote_Name:I',
                        'ld_salesorder:total:hdnGrandTotal:SalesOrder_Total:V',
                        'ld_crmentity:smownerid:assigned_user_id:SalesOrder_Assigned_To:V'),

	          Array('ld_vendor:vendor_no:vendor_no:Vendors_Vendor_No:V',
			  'ld_vendor:vendorname:vendorname:Vendors_Vendor_Name:V',
			'ld_vendor:phone:phone:Vendors_Phone:V',
			'ld_vendor:email:email:Vendors_Email:E',
                        'ld_vendor:category:category:Vendors_Category:V'),




		 Array(//'ld_faq:id::Faq_FAQ_Id:I',
		 		'ld_faq:faq_no:faq_no:Faq_Faq_No:V',
		       'ld_faq:question:question:Faq_Question:V',
		       'ld_faq:category:faqcategories:Faq_Category:V',
		       'ld_faq:product_id:product_id:Faq_Product_Name:I',
		       'ld_crmentity:createdtime:createdtime:Faq_Created_Time:DT',
                       'ld_crmentity:modifiedtime:modifiedtime:Faq_Modified_Time:DT'),
		      //this sequence has to be maintained
		 Array('ld_campaign:campaign_no:campaign_no:Campaigns_Campaign_No:V',
		 		'ld_campaign:campaignname:campaignname:Campaigns_Campaign_Name:V',
		       'ld_campaign:campaigntype:campaigntype:Campaigns_Campaign_Type:N',
		       'ld_campaign:campaignstatus:campaignstatus:Campaigns_Campaign_Status:N',
		       'ld_campaign:expectedrevenue:expectedrevenue:Campaigns_Expected_Revenue:V',
		       'ld_campaign:closingdate:closingdate:Campaigns_Expected_Close_Date:D',
		       'ld_crmentity:smownerid:assigned_user_id:Campaigns_Assigned_To:V'),


		 Array('subject:subject:subject:Subject:V',
		       'from:fromname:fromname:From:N',
		       'to:tpname:toname:To:N',
		       'body:body:body:Body:V'),

		 Array ('ld_faq:question:question:Faq_Question:V',
		 	'ld_faq:status:faqstatus:Faq_Status:V',
			'ld_faq:product_id:product_id:Faq_Product_Name:I',
			'ld_faq:category:faqcategories:Faq_Category:V',
			'ld_crmentity:createdtime:createdtime:Faq_Created_Time:DT'),

		 Array( 'ld_faq:question:question:Faq_Question:V',
			 'ld_faq:answer:faq_answer:Faq_Answer:V',
			 'ld_faq:status:faqstatus:Faq_Status:V',
			 'ld_faq:product_id:product_id:Faq_Product_Name:I',
			 'ld_faq:category:faqcategories:Faq_Category:V',
			 'ld_crmentity:createdtime:createdtime:Faq_Created_Time:DT'),

		 Array(	 'ld_purchaseorder:subject:subject:PurchaseOrder_Subject:V',
			 'ld_purchaseorder:postatus:postatus:PurchaseOrder_Status:V',
			 'ld_purchaseorder:vendorid:vendor_id:PurchaseOrder_Vendor_Name:I',
			 'ld_crmentity:smownerid:assigned_user_id:PurchaseOrder_Assigned_To:V',
			 'ld_purchaseorder:duedate:duedate:PurchaseOrder_Due_Date:V'),

		 Array ('ld_purchaseorder:subject:subject:PurchaseOrder_Subject:V',
			 'ld_purchaseorder:vendorid:vendor_id:PurchaseOrder_Vendor_Name:I',
			 'ld_crmentity:smownerid:assigned_user_id:PurchaseOrder_Assigned_To:V',
			 'ld_purchaseorder:postatus:postatus:PurchaseOrder_Status:V',
			 'ld_purchaseorder:carrier:carrier:PurchaseOrder_Carrier:V',
			 'ld_poshipads:ship_street:ship_street:PurchaseOrder_Shipping_Address:V'),

		 Array(  'ld_invoice:invoice_no:invoice_no:Invoice_Invoice_No:V',
		 	 'ld_invoice:subject:subject:Invoice_Subject:V',
			 'ld_invoice:accountid:account_id:Invoice_Account_Name:I',
			 'ld_invoice:salesorderid:salesorder_id:Invoice_Sales_Order:I',
			 'ld_invoice:invoicestatus:invoicestatus:Invoice_Status:V',
			 'ld_crmentity:smownerid:assigned_user_id:Invoice_Assigned_To:V',
			 'ld_crmentity:createdtime:createdtime:Invoice_Created_Time:DT'),

		 Array(	 'ld_invoice:invoice_no:invoice_no:Invoice_Invoice_No:V',
			 'ld_invoice:subject:subject:Invoice_Subject:V',
			 'ld_invoice:accountid:account_id:Invoice_Account_Name:I',
			 'ld_invoice:salesorderid:salesorder_id:Invoice_Sales_Order:I',
			 'ld_invoice:invoicestatus:invoicestatus:Invoice_Status:V',
			 'ld_invoiceshipads:ship_street:ship_street:Invoice_Shipping_Address:V',
			 'ld_crmentity:smownerid:assigned_user_id:Invoice_Assigned_To:V'),

		 Array(	 'ld_salesorder:subject:subject:SalesOrder_Subject:V',
			 'ld_salesorder:accountid:account_id:SalesOrder_Account_Name:I',
			 'ld_salesorder:sostatus:sostatus:SalesOrder_Status:V',
			 'ld_crmentity:smownerid:assigned_user_id:SalesOrder_Assigned_To:V',
			 'ld_soshipads:ship_street:ship_street:SalesOrder_Shipping_Address:V',
			 'ld_salesorder:carrier:carrier:SalesOrder_Carrier:V'),

                  );



$cvstdfilters = Array(Array('columnname'=>'ld_crmentity:modifiedtime:modifiedtime:Leads_Modified_Time',
                            'datefilter'=>'thismonth',
                            'startdate'=>'2005-06-01',
                            'enddate'=>'2005-06-30'),

		      Array('columnname'=>'ld_crmentity:createdtime:createdtime:Accounts_Created_Time',
                            'datefilter'=>'thisweek',
                            'startdate'=>'2005-06-19',
                            'enddate'=>'2005-06-25'),

		      Array('columnname'=>'ld_contactsubdetails:birthday:birthday:Contacts_Birthdate',
                            'datefilter'=>'today',
                            'startdate'=>'2005-06-25',
                            'enddate'=>'2005-06-25')
                     );

$cvadvfilters = Array(
                	Array(
               			 Array('columnname'=>'ld_leaddetails:leadstatus:leadstatus:Leads_Lead_Status:V',
		                      'comparator'=>'e',
        		              'value'=>'Hot'
                     			)
                     	 ),
		      		Array(
                          Array('columnname'=>'ld_account:account_type:accounttype:Accounts_Type:V',
                                'comparator'=>'e',
                                 'value'=>'Prospect'
                                 )
                           ),
				     Array(
                            Array('columnname'=>'ld_potential:sales_stage:sales_stage:Potentials_Sales_Stage:V',
                                  'comparator'=>'e',
                                  'value'=>'Closed Won'
                                 )
                           ),
				     Array(
                            Array('columnname'=>'ld_potential:sales_stage:sales_stage:Potentials_Sales_Stage:V',
                                  'comparator'=>'e',
                                  'value'=>'Prospecting'
                                 )
                           ),
				     Array(
                            Array('columnname'=>'ld_troubletickets:status:ticketstatus:HelpDesk_Status:V',
                                  'comparator'=>'n',
                                  'value'=>'Closed'
                                 )
                           ),
				     Array(
                            Array('columnname'=>'ld_troubletickets:priority:ticketpriorities:HelpDesk_Priority:V',
                                  'comparator'=>'e',
                                  'value'=>'High'
                                 )
                           ),
				     Array(
	                        Array('columnname'=>'ld_quotes:quotestage:quotestage:Quotes_Quote_Stage:V',
                                  'comparator'=>'n',
                                  'value'=>'Accepted'
                                 ),
						    Array('columnname'=>'ld_quotes:quotestage:quotestage:Quotes_Quote_Stage:V',
                                  'comparator'=>'n',
                                  'value'=>'Rejected'
                                 )
                           ),
				     Array(
                            Array('columnname'=>'ld_quotes:quotestage:quotestage:Quotes_Quote_Stage:V',
                                  'comparator'=>'e',
                                  'value'=>'Rejected'
                                 )
			 ),

			Array(
                          Array('columnname'=>'ld_faq:status:faqstatus:Faq_Status:V',
                                'comparator'=>'e',
                                 'value'=>'Draft'
                                 )
			 ),

			Array(
                          Array('columnname'=>'ld_faq:status:faqstatus:Faq_Status:V',
                                'comparator'=>'e',
                                 'value'=>'Published'
                                 )
			 ),

			Array(
                          Array('columnname'=>'ld_purchaseorder:postatus:postatus:PurchaseOrder_Status:V',
                                'comparator'=>'e',
                                 'value'=>'Created, Approved, Delivered'
                                 )
			 ),

			Array(
                          Array('columnname'=>'ld_purchaseorder:postatus:postatus:PurchaseOrder_Status:V',
                                'comparator'=>'e',
                                 'value'=>'Received Shipment'
                                 )
			 ),

			Array(
                          Array('columnname'=>'ld_invoice:invoicestatus:invoicestatus:Invoice_Status:V',
                                'comparator'=>'e',
                                 'value'=>'Created, Approved, Sent'
                                 )
			 ),

			Array(
                          Array('columnname'=>'ld_invoice:invoicestatus:invoicestatus:Invoice_Status:V',
                                'comparator'=>'e',
                                 'value'=>'Paid'
                                 )
			 ),

			Array(
                          Array('columnname'=>'ld_salesorder:sostatus:sostatus:SalesOrder_Status:V',
                                'comparator'=>'e',
                                 'value'=>'Created, Approved'
                                 )
			 )

                     );

foreach($customviews as $key=>$customview)
{
	$queryid = insertCustomView($customview['viewname'],$customview['setdefault'],$customview['setmetrics'],$customview['cvmodule'],$customview['status'],$customview['userid']);
	insertCvColumns($queryid,$cvcolumns[$key]);

	if(isset($cvstdfilters[$customview['stdfilterid']]))
	{
		$i = $customview['stdfilterid'];
		insertCvStdFilter($queryid,$cvstdfilters[$i]['columnname'],$cvstdfilters[$i]['datefilter'],$cvstdfilters[$i]['startdate'],$cvstdfilters[$i]['enddate']);
	}
	if(isset($cvadvfilters[$customview['advfilterid']]))
	{
		insertCvAdvFilter($queryid,$cvadvfilters[$customview['advfilterid']]);
	}
}

	/** to store the details of the customview in lingdang_customview table
	  * @param $viewname :: Type String
	  * @param $setdefault :: Type Integer
	  * @param $setmetrics :: Type Integer
	  * @param $cvmodule :: Type String
	  * @returns  $customviewid of the stored custom view :: Type integer
	 */
function insertCustomView($viewname,$setdefault,$setmetrics,$cvmodule,$status,$userid)
{
	global $adb;

	$genCVid = $adb->getUniqueID("ld_customview");

	if($genCVid != "")
	{

		$customviewsql = "insert into ld_customview(cvid,viewname,setdefault,setmetrics,entitytype,status,userid) values(?,?,?,?,?,?,?)";
		$customviewparams = array($genCVid, $viewname, $setdefault, $setmetrics, $cvmodule, $status, $userid);
		$customviewresult = $adb->pquery($customviewsql, $customviewparams);
	}
	return $genCVid;
}

	/** to store the custom view columns of the customview in ld_cvcolumnlist table
	  * @param $cvid :: Type Integer
	  * @param $columnlist :: Type Array of columnlists
	 */
function insertCvColumns($CVid,$columnslist)
{
	global $adb;
	if($CVid != "")
	{
		for($i=0;$i<count($columnslist);$i++)
		{
			$columnsql = "insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(?,?,?)";
			$columnparams = array($CVid, $i, $columnslist[$i]);
			$columnresult = $adb->pquery($columnsql, $columnparams);
		}
	}
}

	/** to store the custom view stdfilter of the customview in lingdang_cvstdfilter table
	  * @param $cvid :: Type Integer
	  * @param $filtercolumn($tablename:$columnname:$fieldname:$fieldlabel) :: Type String
	  * @param $filtercriteria(filter name) :: Type String
	  * @param $startdate :: Type String
	  * @param $enddate :: Type String
	  * returns nothing
	 */
function insertCvStdFilter($CVid,$filtercolumn,$filtercriteria,$startdate,$enddate)
{
	global $adb;
	if($CVid != "")
	{
		$stdfiltersql = "insert into ld_cvstdfilter(cvid,columnname,stdfilter,startdate,enddate) values (?,?,?,?,?)";
		$stdfilterparams = array($CVid, $filtercolumn, $filtercriteria, $startdate, $enddate);
		$stdfilterresult = $adb->pquery($stdfiltersql, $stdfilterparams);
	}
}

	/** to store the custom view advfilter of the customview in ld_cvadvfilter table
	  * @param $cvid :: Type Integer
	  * @param $filters :: Type Array('columnname'=>$tablename:$columnname:$fieldname:$fieldlabel,'comparator'=>$comparator,'value'=>$value)
	  * returns nothing
	 */

function insertCvAdvFilter($CVid,$filters)
{
	global $adb;
	if($CVid != "")
	{
		$columnIndexArray = array();
		foreach($filters as $i=>$filter)
		{
			$advfiltersql = "insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,value) values (?,?,?,?,?)";
			$advfilterparams = array($CVid, $i, $filter['columnname'], $filter['comparator'], $filter['value']);
			$advfilterresult = $adb->pquery($advfiltersql, $advfilterparams);
		}
		$conditionExpression = implode(' and ', $columnIndexArray);
		$adb->pquery('INSERT INTO ld_cvadvfilter_grouping VALUES(?,?,?,?)', array(1, $CVid, '', $conditionExpression));
	}
}
?>