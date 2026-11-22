<?php

/**
 * Created by PhpStorm.
 * User: gyq_27
 * Date: 2017/4/6 0006
 * Time: 下午 1:59
 */
crm_load_class_file('cls_ProductDetailUitype_PageRecordValueMC','appCommon/include/ProductDetailsHtml');
class cls_QuotesChange_PageRecordValueWX extends cls_ProductDetailUitype_PageRecordValueMC
{
    public $change_type;
    
    public function __construct($module, $pagemode, $record, $frommodule, $actionname){
		parent::__construct($module, $pagemode, $record, $frommodule, $actionname);
        if($pagemode=='module_create'||$pagemode=='create'){
            if(empty($_REQUEST['change_type'])){
    			$this->change_type = 'add';
    		}else{
    			$this->change_type = $_REQUEST['change_type'];
    		}
        }else{
            $focus = CRMEntity::getInstance($module);
            $focus->retrieve_entity_info($record,$module);
            if(!empty($focus->column_fields['change_type'])){
                if($focus->column_fields['change_type']=='更换'){
                    $this->change_type = 'replace';
                }elseif($focus->column_fields['change_type']=='修改'){
                    $this->change_type = 'edit';
                }else{
                    $this->change_type = 'add';
                }
            }
        }
        $this->entrytype='quoteschange';
		
	}
    
    public function getDetailHeader(){
        $headerInfo = parent::getDetailHeader();
        if($this->change_type=='replace'){
            //if($this->pagemode=='module_create'){//创建变更，pro_id->pro_name
            foreach($headerInfo as $key=>$header){
                if($header['columnname']=='pro_id'){
                    $headerInfo[$key]['columnname'] = 'pro_name';
                }
                if($header['columnname']=='prosheet'){
                    $headerInfo[$key]['columnname'] = 'prosheet_name';
                }
            }
            $this->headerInfo = $headerInfo;
            //}
            //editor:gyq_134 reason:报价变更单新建修改  2019/7/26 16:23 
        }elseif ($this->change_type=='edit'){
            //修改操作，仅保留产品名称（变更后）字段
            foreach($headerInfo as $header){
                if($header['columnname']=='pro_id') continue;
                if($header['columnname']=='prosheet') continue;
                if($header['columnname']=='productsheet'){
                    $header['fieldlabel'] = getFixedLabel('Specifications');
                }
                $newheader[] = $header;
            }
            $this->headerInfo = $newheader;
        }else{
            //追加操作，去除产品名称（变更前）字段
            foreach($headerInfo as $header){
                if($header['columnname']=='pro_id') continue;
                if($header['columnname']=='prosheet') continue;
                if($header['newline']==1) continue;
                if($header['columnname']=='productname'){
                    //$header['fieldlabel'] = getFixedLabel('PRODUCTNAME');
                }
                if($header['columnname']=='productsheet'){
                    $header['fieldlabel'] = getFixedLabel('Specifications');
                }
                $newheader[] = $header;
            }
            $this->headerInfo = $newheader;
            //说明：$this->headerInfo是变更后的列头信息，$headerInfo是变更前的列头，调用获取小计的方法getSubTotal_Value需要获取变更前的头部
        }
        return $headerInfo;
    }
    
    public function getValues(){
        $orignValues = parent::getValues();
        if($this->pagemode=='module_create'||$this->pagemode=='create'){
            if($this->change_type=='add') {
                $orignValues['value'] = array();
            }elseif ($this->change_type=='replace'){
                //变更操作，productname产品名称（变更后）字段置空
                foreach($orignValues['value'] as $key=>$val){
                    $orignValues['value'][$key]['productname']['value'] = '';
                    $orignValues['value'][$key]['productname']['hiddenvalue'] = '';
                }
            }
        }
        return $orignValues;
    }
    
    public function getLineItemIds(){
        parent::getLineItemIds();
        $data = $this->focus->getInventoryProducts_info($this->record);
		foreach($data as $infos){
			$lineitem_id[] = $infos['lineitem_id'];
		}
		$this->fromFocus->lineitemIds = implode(',',$lineitem_id);
    }
    
}