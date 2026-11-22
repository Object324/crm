<?php

class RelatedModule_QueryGenerator{
	
	static function getLeftJoin_Module($module,$relatedmodule){
		//相关信息
		if($module == 'Campaigns'  &&  isset($relatedmodule)){
			if($relatedmodule == 'Accounts'){
				$data[0]['table_inedx'] = 'ld_campaignaccountrel';
				$data[0]['table_leftjoin']= 'ld_campaignaccountrel on ld_campaignaccountrel.campaignid=ld_campaign.campaignid';
			}else{
				$data[0]['table_inedx'] = 'ld_campaigncontrel';
				$data[0]['table_leftjoin'] = 'ld_campaigncontrel on ld_campaigncontrel.campaignid=ld_campaign.campaignid';
			}
        }else if($module == 'Products' && isset($relatedmodule)){
			$relatedModule=cls_Instance::get_module_Instance( $relatedmodule);
			$data[0]['table_inedx'] = 'ld_seproductsrel';
			//0026241: CRM>客户：pc端相关信息中关联2个产品，手机端查看时相关信息中只显示了数量，没有显示产品
			$data[0]['table_leftjoin'] = 'ld_seproductsrel ON ld_products.productid = ld_seproductsrel.productid and ld_seproductsrel.setype='.'\''.$relatedmodule.'\'';
			$data[1]['table_inedx'] = $relatedModule->table_name;
			$data[1]['table_leftjoin'] = "".$relatedModule->table_name." ON ".$relatedModule->table_name.".".$relatedModule->table_index." = ld_seproductsrel.crmid";
		}else if($module == 'Accounts' &&  isset($relatedmodule) && $relatedmodule == 'Campaigns'){
			$data[0]['table_inedx'] = 'ld_campaignaccountrel';
			$data[0]['table_leftjoin'] = 'ld_campaignaccountrel on ld_campaignaccountrel.accountid=ld_account.accountid';
		}else if($module == 'Contacts' &&  isset($relatedmodule) && $relatedmodule == 'Campaigns'){
			$data[0]['table_inedx'] = 'ld_campaignaccountrel';
			$data[0]['table_leftjoin'] = 'ld_campaigncontrel on ld_campaigncontrel.contactid=ld_contactdetails.contactid';
		}else if($module == 'Contacts' &&  isset($relatedmodule) && $relatedmodule == 'Potentials'){
			$data[0]['table_inedx'] = 'ld_contpotentialrel';
			$data[0]['table_leftjoin'] = 'ld_contpotentialrel on ld_contpotentialrel.contactid = ld_contactdetails.contactid';
		}else if($module == 'Accounts' &&  isset($relatedmodule) && $relatedmodule == 'Potentials'){
			$data[0]['table_inedx'] = 'ld_accountpotentialrel';
			$data[0]['table_leftjoin'] = 'ld_accountpotentialrel ON ld_accountpotentialrel.accountid = ld_account.accountid';
		}else if($module == 'HelpDesk' &&  isset($relatedmodule) && ($relatedmodule == 'Products'||$relatedmodule == 'Project')){
			$data[0]['table_inedx'] = 'ld_crmentityrel';
			$data[0]['table_leftjoin'] = 'ld_crmentityrel  on ld_crmentityrel.relcrmid=ld_troubletickets.ticketid'; 
		}else if(($module == 'Accounts' || $module == 'Contacts' || $module == 'Potentials') &&  isset($relatedmodule) && $relatedmodule == 'Products'){
			$data[0]['table_inedx'] = 'ld_seproductsrel';
			$data[0]['table_leftjoin'] = 'ld_seproductsrel on ld_seproductsrel.crmid='.$baseTable.'.'.$baseTableIndex.'';

		}else if(isset($relatedmodule) && $relatedmodule == 'Products'&&($module == 'Quotes' || $module == 'SalesOrder'|| $module == 'PurchaseOrder')){
		  $relatefocus=CRMEntity::getInstance($module);
          $detailtable=$relatefocus->Detail_table;
			$data[0]['table_inedx'] = $relatefocus->Detail_table;
			$data[0]['table_leftjoin'] = $detailtable.'  on '. $detailtable.'.id='.$baseTable.'.'.$baseTableIndex.'';
		}
		return $data;
	}
}
?>