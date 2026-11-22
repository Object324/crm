<?php
/*
edit:duan
time:2021-8-30
reason:购物车类文件，方便移动端和网页端使用
*/

class Shopcart{
    var $smownerid;
    var $max_cartdetail = 99;//每个用户的购物车上限
    var $cartdetail_num;
    var $vtlib_isModuleActive='no';//产品属性模块是否激活 yes no

    //产品信息字段
    var $product_field = array('imagename','productname','productproperty','productsheet','unit_price');
    //
    public $QuantityDecimal = 0;
    public $PriceDecimal=2;
    function __construct() {
        global $current_user;
        $this->smownerid = $current_user->id;

        //zxm 20241016 产品属性模块授权  不显示产品型号字段 显示属性字段
        if(vtlib_isModuleActive('ProductProperty')){
            $this->vtlib_isModuleActive='yes';
            $this->product_field = array('imagename','productname','productproperty','productsheet','unit_price');
        }else{
            $this->product_field = array('imagename','productname','productsheet','unit_price');
        }

        //设置小数位
        $system_deploy_49 = getSys_deploy(49);
        $this->QuantityDecimal = $system_deploy_49['deploy_value'];//数量小数位
        $system_deploy_93 = getSys_deploy(93);
        $this->PriceDecimal = $system_deploy_93['deploy_value'];//单价小数位
    }
    //添加购物车记录，不存在时新加记录，存在时数量加1
    //zxm @date:2024/10/16 @reason: 增加产品属性
    public function addtocart($productid,$productdetail_lineitem_id=0){
        global $adb;
        $smownerid = $this->smownerid;
        if($productdetail_lineitem_id==0){
            //如果没有传属性组合id 需要判断是否开启产品属性 如果开启产品属性需要去查询默认属性存储进去
            crm_load_class_file('ProductPropertyUtils','modules/Products');
            $defaultproperty_info = ProductPropertyUtils::getDefaultPropertyByProductid($productid);
            if(isset($defaultproperty_info[$productid])&&$defaultproperty_info[$productid]>0){
                $productdetail_lineitem_id = $defaultproperty_info[$productid];
            }
        }
        $select_sql = 'select * from ld_shopcartdetails where productid = ? and ifnull(productdetail_lineitem_id,0)=?  and smownerid = ?';
        $result = $adb->pquery($select_sql,array($productid,$productdetail_lineitem_id,$smownerid));
        $num_rows = $adb->num_rows($result);
        $createdtime = date('Y-m-d H:i:s');
        //判断购物车数量是否超过最大数量
        if(!$this->check_nums()){
            return -1;
        }
        if($num_rows>0){
            $quantity = $adb->query_result($result,0,'quantity')+1;
            $cartid = $adb->query_result($result,0,'cartid');
            $update_sql = 'update ld_shopcartdetails set quantity = ?,createdtime = ? where cartid = ?';
            $adb->pquery($update_sql,array($quantity,$createdtime,$cartid));
        }else{
            $insert_sql = 'insert into ld_shopcartdetails(productid,productdetail_lineitem_id,smownerid,createdtime) values(?,?,?,?)';
            $adb->pquery($insert_sql,array($productid,$productdetail_lineitem_id,$smownerid,$createdtime));
            $this->cartdetail_num ++;
        }
        return 1;
    }

    //获取购物车的产品数
    public function getShopCartNum(){
        global $adb;
        $select_sql = 'select 1 from ld_shopcartdetails where smownerid = ? group by productid';
        $result = $adb->pquery($select_sql,array($this->smownerid));
        return $adb->num_rows($result);
    }
    //批量添加购物车记录
    public function mass_addtocart($id_list,$selectlen){
        global $adb;
        //查找已存在的购物车记录
        if(!$this->check_nums()){
            return -1;
        }
        $smownerid = $this->smownerid;
        $id_liststr = implode(",",$id_list);
        $select_sql = "select * from ld_shopcartdetails where smownerid = ? and productid in ($id_liststr)";
        $result = $adb->pquery($select_sql,array($smownerid));
        $num_rows = $adb->num_rows($result);
        //如果加入新记录后的总数大于等于上限则返回提示信息        
        if($this->cartdetail_num + $selectlen - $num_rows > $this->max_cartdetail){ 
            return -1;
        }
        //如果没有传属性组合id 需要判断是否开启产品属性 如果开启产品属性需要去查询默认属性存储进去
        crm_load_class_file('ProductPropertyUtils','modules/Products');
        $defaultproperty_info = ProductPropertyUtils::getDefaultPropertyByProductid($id_liststr);


        $exist_cartdetail = array(); //已存在的产品记录 键索引是产品id_属性明细id
        if($num_rows>0){
            for($i=0;$i<$num_rows;$i++){
                $quantity = $adb->query_result($result,$i,'quantity')+1;
                $cartid = $adb->query_result($result,$i,'cartid');
                $productid =  $adb->query_result($result,$i,'productid');
                $tmpproductdetail_lineitem_id =  $adb->query_result($result,$i,'productdetail_lineitem_id');
                $tmpkey = $productid.'_'.$tmpproductdetail_lineitem_id;
                $exist_cartdetail[$tmpkey] = array('quantity'=>$quantity,'cartid'=>$cartid);
            }
        }

        //判断更新或插入操作
        foreach($id_list as $key => $id){
            $createdtime = date('Y-m-d H:i:s');
            //产品属性组合值
            $productdetail_lineitem_id = 0;
            if(isset($defaultproperty_info[$id])&&$defaultproperty_info[$id]>0){
                $productdetail_lineitem_id = $defaultproperty_info[$id];
            }
            $tmpkey2 = $id.'_'.$productdetail_lineitem_id;

            if(array_key_exists($tmpkey2,$exist_cartdetail)){
                $quantity = $exist_cartdetail[$id]['quantity'];
                $cartid = $exist_cartdetail[$id]['cartid'];

                $update_sql = 'update ld_shopcartdetails set productdetail_lineitem_id=?,quantity = ?,createdtime = ? where cartid = ?';
                $adb->pquery($update_sql,array($productdetail_lineitem_id,$quantity,$createdtime,$cartid));
            }else{
                $productid = $id;
                $insert_sql = 'insert into ld_shopcartdetails(productid,productdetail_lineitem_id,smownerid,createdtime) values(?,?,?,?)';
                $adb->pquery($insert_sql,array($productid,$productdetail_lineitem_id,$smownerid,$createdtime));
                $this->cartdetail_num++;
            }
        }
        return 1;
    }
    
    //判断购物车是否已满（99）
    public function check_nums(){
        global $adb;
        $select_sql = "select * from ld_shopcartdetails inner join ld_products on ld_shopcartdetails.productid =  ld_products.productid
                        where ld_shopcartdetails.smownerid = ? and ld_products.deleted = 0";
        $result = $adb->pquery($select_sql,array($this->smownerid));
        $num_rows = $adb->num_rows($result);
        $this->cartdetail_num = $num_rows;
        if($num_rows >= $this->max_cartdetail){//如果总数大于等于上限则返回提示信息
            return false;
        }else{
            return true;
        }
    }
    //购物车数量修改
    public function quantity_change($cartid,$quantity){
        global $adb;
        $update_sql = 'update ld_shopcartdetails set quantity = ?  where cartid = ?';
        $adb->pquery($update_sql,array($quantity,$cartid));
    }
    //产品属性修改的保存
    public function saveCartProductProperty($cartid,$productid,$productdetail_lineitem_id){
        global $adb;
        //不做合并

        $update_sql = 'update ld_shopcartdetails set productdetail_lineitem_id = ?  where cartid = ?';
        $adb->pquery($update_sql,array($productdetail_lineitem_id,$cartid));
    }
    //获取产品相关字段翻译
    public function get_fieldlabel($focus){
        global $current_user;
        $languageType = getLanguageType($current_user);

        foreach($this->product_field as $key => $value){
            //zxm 增加产品属性列
            if($value=='productproperty'){
                $filedlabels[$value] = getTranstab('ProductProperty');
            }else{
                $fieldinfo = $focus->fieldobj->FieldInfoListByKeyValue('columnname',$value);
                if($languageType=='zh'){
                    $filedlabels[$value] = $fieldinfo['fieldlabel'];
                }else{
                    $filedlabels[$value] = $fieldinfo['en_fieldlabel'];
                }
            }
        }

        return $filedlabels;
    }
    //购物车列表页显示
    public function ListView_shopcart($focus){
        global $adb;
        $version = getVersionInfo();
        $focus = CRMEntity::getInstance('Products');
        crm_load_function_file('getInventoryCurrencyInfo','include/utils','InventoryUtils');
        $fileds = $this->product_field;
        $fileds_str = "";
        $PriceDecimal = $this->PriceDecimal;
        $QuantityDecimal = $this->QuantityDecimal;
        foreach($fileds as $value){
            //zxm @date:2024/10/16 @reason: 产品属性数据不从购物车表查询
            if($value!='productproperty')
                $fileds_str .= ",".$focus->table_name.".".$value;
        }
        //zxm @date:2024/10/16 @reason: 产品属性模块激活 需要查询购物车保存的产品属性明细ID
        $fileds_str.=',ld_shopcartdetails.productdetail_lineitem_id';
        $fileds_str.=',ld_products.property_status';//判断这个产品是否开启产品属性

        $sql = "SELECT  ld_shopcartdetails.quantity ,ld_shopcartdetails.cartid ,ld_shopcartdetails.createdtime ,ld_shopcartdetails.productid
        $fileds_str  
        FROM ld_shopcartdetails 
            INNER JOIN ld_products ON ld_products.productid = ld_shopcartdetails.productid
        where ld_shopcartdetails.smownerid = ? 
          and ld_products.deleted = 0 
        order by ld_shopcartdetails.createdtime desc,ld_shopcartdetails.cartid desc";
        $result = $adb->pquery($sql,array($this->smownerid));
        $num_rows = $adb->num_rows($result);

        $listview_entries = array();
        //zxm @date:2024/10/16 @reason:产品属性明细ID 数组
        $productdetail_lineitem_id_arr = [];
        if($num_rows>0){
            for($i=0;$i<$num_rows;$i++){
                //购物车信息
                $cartid = $adb->query_result($result,$i,'cartid');
                $quantity = $adb->query_result($result,$i,'quantity');
                $createdtime = $adb->query_result($result,$i,'createdtime');
                $property_status = $adb->query_result($result,$i,'property_status');
                //zxm @date:2024/10/16 @reason:产品属性明细ID 数组
                $productdetail_lineitem_id =  $adb->query_result($result,$i,'productdetail_lineitem_id');
                if($productdetail_lineitem_id>0)
                    $productdetail_lineitem_id_arr[$cartid] = $productdetail_lineitem_id;
                //产品字段
                $productname = $adb->query_result($result,$i,'productname');
                //呼博士特殊控制
                if($version['account'] == 'huboshi'){
                    $productsheet = '';
                }
                else{
                    $productsheet = $adb->query_result($result,$i,'productsheet');
                }
                //这个价格应该获取产品属性分录的值
                $unit_price = $adb->query_result($result,$i,'unit_price');

                $price = number_format((float)$unit_price,$PriceDecimal,".","");
                //币种符号
                $productid = $adb->query_result($result,$i,'productid');
                //zxm @date:2024/10/17 @reason: 产品属性模块未开启 则直接在这里计算价格
                if($this->vtlib_isModuleActive=='no') {
                    //价格策略
                    $unit_price = $focus->getShopProPrice($productid,$unit_price,$quantity);//放到后面计算
                }
                $inventory_cur_info = getInventoryCurrencyInfo('Products',$productid);
                $currency_symbol = $inventory_cur_info['currency_symbol'];
                $currency_id = $inventory_cur_info['currency_id '];
                //取小数位，计算总金额
                $quantity = number_format((float)$quantity,$QuantityDecimal,".","");
                $unit_price = number_format((float)$unit_price,$PriceDecimal,".","");
                $total_price = number_format($quantity*$unit_price,$PriceDecimal,".","");
                //产品图片
                $imagepath = $this->get_image($productid);
                $listview_entries[$cartid] = array(
                    'cartid'=>$cartid,
                    'productid'=>$productid,
                    'quantity'=>$quantity,
                    'createdtime'=>$createdtime,
                    'productname'=>$productname,
                    'productsheet'=>$productsheet,
                    'property_status'=>$property_status,
                    'productproperty'=>array(),
                    'productpropertystr'=>'',
                    'productdetail_lineitem_id'=>$productdetail_lineitem_id,
                    'propertydetail_lineitem_id_combin'=>'',
                    'unit_price'=>$unit_price,
                    'price'=>$price,
                    'total_price'=>$total_price,
                    'currency_id'=>$currency_id,
                    'currency_symbol'=>$currency_symbol,
                    'select'=>'no',
                    'imagepath'=>$imagepath
                );
            }
            //zxm @date:2024/10/17 @reason: 产品属性模块开启 则直接在这里计算价格 产品属性值 总价格等信息
            if($this->vtlib_isModuleActive=='yes'){
                crm_load_class_file('ProductPropertyUtils','modules/Products');
                $productdetail_lineitem_id_str = implode(',',array_values($productdetail_lineitem_id_arr));
                $productproperty_info = ProductPropertyUtils::getPropertyInfoByProductDetailId($productdetail_lineitem_id_str);
                foreach($listview_entries as $tmpcartid=>$cartinfo){
                    $tmpproductdetail_lineitem_id = $cartinfo['productdetail_lineitem_id'];
                    if($cartinfo['property_status']==1&&isset($productproperty_info[$tmpproductdetail_lineitem_id])&&$productproperty_info[$tmpproductdetail_lineitem_id]>0) {
                        $tmpproductproperty_arr = [];
                        if(isset($productproperty_info[$tmpproductdetail_lineitem_id]['productdetail_lineitem_id_value']))
                            $tmpproductproperty_arr = $productproperty_info[$tmpproductdetail_lineitem_id]['productdetail_lineitem_id_value'];

                        $listview_entries[$tmpcartid]['productproperty'] = $tmpproductproperty_arr;
                        $listview_entries[$tmpcartid]['productpropertystr'] = implode('<br>',$tmpproductproperty_arr);
                        $listview_entries[$tmpcartid]['productproperty_short'] = implode(';',$productproperty_info[$tmpproductdetail_lineitem_id]['productdetail_lineitem_id_value_s']);

                        $unit_price_tmp = $productproperty_info[$tmpproductdetail_lineitem_id]['line_unit_price'];//取按属性设置的价格
                        $quantity = $listview_entries[$tmpcartid]['quantity'];
                        $unit_price = (float)$unit_price_tmp;
                        //$unit_price = $focus->getShopProPrice($listview_entries[$tmpcartid]['productid'],$unit_price_tmp, $quantity);//价格策略
                        //--价格政策//应该在getShopProPrice方法中去处理吧?--todo--

                        $unit_price = number_format($unit_price,$PriceDecimal,".","");;
                        $total_price = number_format($quantity*$unit_price,$PriceDecimal,".","");
                        $listview_entries[$tmpcartid]['unit_price'] =$unit_price;
                        $listview_entries[$tmpcartid]['total_price'] =$total_price;
                        $listview_entries[$tmpcartid]['propertydetail_lineitem_id_combin'] =$productproperty_info[$tmpproductdetail_lineitem_id]['propertydetail_lineitem_id_combin'];
                    }
                }
            }
        }
        return $listview_entries;
    }
    //获取产品图片路径
    public function get_image($productid){
        global $currentModule,$adb,$weixin_user;
        $focus = CRMEntity::getInstance($currentModule);
        $focus->id = $productid;
        $module = $focus->module_name;
        $maintablename = $focus->table_name;
        $maintable_index = $focus->table_index;
        $query = "select ld_attachments.path,ld_attachments.newfile_name,ld_attachments.storage_location,ld_attachments.cloud_path
             from $maintablename left join ld_seattachmentsrel on ld_seattachmentsrel.crmid=$maintablename.$maintable_index 
             inner join ld_attachments on ld_attachments.attachmentsid=ld_seattachmentsrel.attachmentsid 
             inner join ld_crmentity on ld_crmentity.crmid = ld_attachments.attachmentsid 
             where ld_crmentity.setype=? and $maintable_index=? order by ld_attachments.attachmentsid asc" ;
        $img_result = $adb->pquery($query,array($module . ' image',$focus->id));
        $num_rows = $adb->num_rows($img_result);
        if($num_rows>0){
            $storage_location = $adb->query_result($img_result,0,'storage_location');
            if($storage_location =='cos'){
                $img_path = $adb->query_result($img_result,0,'cloud_path');
            }else{
                $path = $adb->query_result($img_result,0,'path');
                $filename = $adb->query_result($img_result,0,'newfile_name');
                $img_path = $path.$filename;
            }
            return $img_path;
        }else{
            if(empty($weixin_user)){
                return "";
            }else{
                return "themes/images/noshopimg.jpg";
            }
        }
    }
    //删除一条记录
    public function deletecart($cartid){
        global $adb;
        $delete_sql = "delete from ld_shopcartdetails where cartid = ?";
        $adb->pquery($delete_sql,array($cartid));
    }
    //通过产品id或购物车明细id批量删除记录
    public function mass_deletecart($productid_str,$cartid_str){
        global $adb;
        $delete_sql = "delete from ld_shopcartdetails where smownerid = ?";
        if($productid_str != ""){
            $delete_sql .= " and productid in (".$productid_str.")";
            $adb->pquery($delete_sql,array($this->smownerid));
        }
        if($cartid_str != ""){
            $delete_sql .= " and cartid in (".$cartid_str.")";
            $adb->pquery($delete_sql,array($this->smownerid));
        }
    }
    
    //判断购物车相关按钮是否启用
    public function shopcart_button(){
        //东贸-隐藏购物车相关按钮;以及系统参数增加购物车启用控制
        $versioninfo=getVersionInfo();
        if($versioninfo['account'] == 'dongmao'||getSys_deploy(485)['deploy_value'] == 'no'){
            return array();
        }
        
        $modulename_arr = array('SalesOrder','ServiceContracts');
        foreach($modulename_arr as $key=>$value){
            if(vtlib_isModuleActive($value)){
                $module_presence = 'yes';
                if(isPermitted($value,'Create')=='yes'){
                    $permit_arr[] = $value;
                    $module_trans_arr[] = getTranstab($value);
                }
            }
        }
        if(sizeof($permit_arr)<1){
            return array();
        }else{
            return array('permit'=>$permit_arr,'trans'=>$module_trans_arr);
        }
    }

    //获取产品详情
    public function getProductDetail($productid){
        global $adb;
        $data = [];
        $dataModule = 'Products';
        $version = getVersionInfo();
        $focus = CRMEntity::getInstance($dataModule);
        $focus->id = $productid;
        $focus->retrieve_entity_info($productid, $dataModule);

        $query = 'select productname,product_no,usageunit,productsheet,description,unit_price,
        productdetails,qtyinstock,apprecommendreason 
        from ld_products 
        LEFT JOIN ld_productcf on ld_products.productid = ld_productcf.productid 
        where ld_products.productid = ?';
        $result = $adb->pquery($query,array($productid));

        if($adb->num_rows($result) >= 1){
            $images = $focus->getImageUrl($productid,'more');
            //呼博士特殊控制
            if($version['account'] == 'huboshi'){
                $price = '';
                $price_arr = explode('.',sprintf('%.2f','0.00'));
            }
            else{
                $price = $adb->query_result($result,0,'unit_price');
                $price_arr = explode('.',sprintf('%.2f',$price));
            }
            $apprecommendreason = $adb->query_result($result,0,'apprecommendreason');
            $apprecommendreason = str_replace("\r\n","<br>",$apprecommendreason);
            $apprecommendreason = str_replace("\n","<br>",$apprecommendreason);
            $fieldobj = Field::getInstance('Products', $adb);
            $modulefields = $fieldobj->getModuleFields();
            $data = array(
                'productname' => $adb->query_result($result,0,'productname'),
                'product_no' => $adb->query_result($result,0,'product_no'),
                'usageunit' => $adb->query_result($result,0,'usageunit'),
                'productsheet' => $adb->query_result($result,0,'productsheet'),
                'description' => $adb->query_result($result,0,'description'),
                'price' => $price,
                'price_arr' => array($price_arr[0].'.',$price_arr[1]),
                'productdetails' => htmlspecialchars_decode($adb->query_result($result,0,'productdetails')),
                'apprecommendreason' => $apprecommendreason,
                'images' => $images
            );
            $field = $modulefields['qtyinstock'];
            if(!empty($field)){
                $data['qtyinstock'] = '库存：'.sprintf('%.2f',$adb->query_result($result,0,'qtyinstock'));
            }
            $ProductPropertyList =  $this->getProductPropertyList($focus,$data);
            if(!empty($ProductPropertyList))
                $data['ProductPropertyList'] = $ProductPropertyList;
        }
        return $data;
    }
    //zxm @date:2024/10/29 @reason: 产品开启产品属性时候  属性信息
    public function getProductPropertyList($focus,&$data){
        //属性状态开启 且产品属性字段有值
        if(isset($focus->column_fields['property_status'])
            &&$focus->column_fields['property_status']==1
            &&isset($focus->column_fields['propertyids'])
            &&!empty($focus->column_fields['propertyids'])){
            $params_arr['focus'] = $focus;
            $params_arr['productid'] = $focus->id;
            //关联选择单据 选产品属性的值
            $params_arr['productpropertyid'] = $focus->column_fields['propertyids'];


            crm_load_class_file('ProductPropertyUtils','modules/Products');
            $ProductPropertyUtilsObj = new ProductPropertyUtils($params_arr);
            $blockData = $ProductPropertyUtilsObj->getProductPropertyBlock();
            //分录附件信息
            $detailfilejsondata = getAllDetailFile_imageInfo($focus->id, 'Products');
            //detailfilejsondata明细图片--可能还需要加工
            $images_detail = [];
            if(!empty($detailfilejsondata)){
                foreach($detailfilejsondata as $linedata){
                    foreach($linedata['line_img'] as $tmpimginfo){
                        $images_detail[] = ['lineitem_id'=>$tmpimginfo['lineitem_id'],'filepath'=>$tmpimginfo['filepath_noEncrpt']];
                    }
                }

            }
            $data['imagesdetail'] = $images_detail;

            //处理属性组合
            $defaultLine = [];
            foreach ($blockData['fieldValueList'] as $index => $propertyGroupInfo) {
                if($index==0||$propertyGroupInfo['setdefault'] === '1') {
                    $defaultLine = $propertyGroupInfo;
                }
            }
            $defaultid_arr = explode('|##|',$defaultLine['propertydetail_lineitem_id_combin']);
            $data['fieldValueList'] = $blockData['fieldValueList'];

            //处理属性
            $propertyArr = [];
            foreach ($blockData['productproperty_arr'] as $index => $propertyInfo) {
                $details = [];
                foreach ($propertyInfo['details'] as $index2 => $item) {
                    $details[] = [
                        'lineitem_id' => $item['lineitem_id'],
                        'selected' => (in_array($item['lineitem_id'],$defaultid_arr))?'yes':'no',
                        'label' => $item['property_value_name'],
                    ];
                }
                $propertyArr[] = [
                    'id' => $propertyInfo['productpropertyid'],
                    'label' => $propertyInfo['productproperty_name'],
                    'details' => $details,
                ];
            }
            $defaultprice = $defaultLine['line_unit_price'];
            $data['productproperty_arr'] = $propertyArr;//选择的属性单据信息
            $data['price'] = $defaultprice;
            $defaultprice_arr = explode('.',$defaultprice);
            $data['price_arr'] = array($defaultprice_arr[0].'.',$defaultprice_arr[1]);

        }
    }

	//根据购物车的ID获取产品
	public function getProductForShopCart($cartid){
		global $adb;
		$query = "select productid from ld_shopcartdetails where cartid = ? limit 1";
		$result = $adb->pquery($query,array($cartid));
		if($adb->num_rows($result) >= 1){
			return $adb->query_result($result,0,0);
		}
		return 0;
	}
}
?>