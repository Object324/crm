<?php

crm_load_class_file('Products','modules/Products');
class WeiXin_Products extends Products
{
    //editor:gyq_166 reason:钉钉模块图片上传,代码优化   2020/1/6 14:26
    function save_module($module)
    {
        //Inserting into product_taxrel table
        //$_REQUEST['create_view']App产品保存
        if($_REQUEST['ajxaction'] != 'DETAILVIEW' && $_REQUEST['action'] != 'MassEditSave' && $_REQUEST['action'] != 'ProcessDuplicates' && $_REQUEST['create_view']='create_view')
        {
            $this->insertTaxInformation('ld_producttaxrel', 'Products');
            $this->insertPriceInformation('ld_productcurrencyrel', 'Products');
        }

        // Update unit price value in ld_productcurrencyrel
        $this->updateUnitPrice();
        //Inserting into attachments
        //0027186: （微信端）产品新建：选择一张照片，保存，明细里显示了2张
        //$this->insertIntoAttachment($this->id,'Products');

        /**
         * 判断产品更多信息新增产品时，添加两个产品的关联
         * @reason 0008464 产品更多信息新增产品未关联
         * @author Tujt 2014-05-04
         */
        if($this->mode == '' && $_REQUEST['return_module'] == 'Products' && $_REQUEST['product_id'] > 0){
            $insert = 'insert into ld_seproductsrel(crmid,productid,setype) values('.$this->id.','.$_REQUEST['product_id'].',"Products") ';
            $this->db->query($insert);
            //echo 'create product rel';echo '<br><br>';die;
        }
        $_REQUEST['return_mdoule']="Products";
        $_REQUEST['return_id']=$this->id;


        /**********判断基金行业并且是凯银数据库时，同步产品 begin************/
        /**
         * edit:diony
         * time:2014-12-05
         * 凯银同步产品，只有当产品类别为基金时，才会同步，凯银产品类别字段为cf_1387
         */
        if(get_versiontrade()=='fund' && get_versionaccount()=='kylin')
        {
            //echo '我进来了';
            //echo '<br>';
            if($this->column_fields['cf_1387'] == '基金')
            {
                include('include/trade/fund/kylin.php');
                project_kylin::products_add($this);
            }
        }
        //exit();
        /**********判断基金行业并且是凯银数据库时，同步产品 end************/
    }

}
?>