<?php
class LdMallProducts extends LdMall
{
    //根据sql获取商品列表
    public function getProductListBySql($sql,$sqlParam){
        $res = $this->adb->pquery($sql,$sqlParam);

        $list = [];
        $nums = $this->adb->num_rows($res);
        $corpurl = $this->corpurl;
        $defaultImage = $this->defaultProductImage;
        if($nums>0){
            for($i=0;$i<$nums;$i++){
                $list[$i]['price'] = $this->adb->query_result($res,$i,'unit_price');
                $tmprice=(float)$list[$i]['price'];
                $list[$i]['price'] = round($tmprice,2);//续租价格
                $list[$i]['price_arr'] = $this->formatPrice($tmprice);
                $list[$i]['originalprice'] = $this->adb->query_result($res,$i,'originalprice');//原价字段
                $tmporiginalprice=(float)$list[$i]['originalprice'];
                $list[$i]['originalprice'] =$tmporiginalprice<=0?"":round($tmporiginalprice,2);//原价为0则直接用价格字段的值
                $list[$i]['goodsstock'] = $this->adb->query_result($res,$i,'qtyinstock');
                $tmpgoodsstock=(float)$list[$i]['goodsstock'];

                $list[$i]['goodsstock'] = round($tmpgoodsstock,2);//库存
                $list[$i]['name'] = $this->adb->query_result($res,$i,'productname');//产品名称
				//$list[$i]['name'] = $this->adb->query_result($res,$i,'productname').' '.$this->adb->query_result($res,$i,$this->showProductNoField).' '.$this->adb->query_result($res,$i,'productsheet');
				$list[$i]['num'] = $this->adb->query_result($res,$i,$this->showProductNoField);//产品编号
                $list[$i]['sheet'] = $this->adb->query_result($res,$i,'productsheet');//规格型号

                $list[$i]['goodid'] = $this->adb->query_result($res,$i,'productid');
                $list[$i]['goodid'] = (int)$list[$i]['goodid'];
                $list[$i]['salescount'] = $this->adb->query_result($res,$i,'salescount');//销量
                $list[$i]['salescount'] = (string)(int)$list[$i]['salescount'] ;
                //查询所有附件
                $attachment_sql = "select a.attachmentcolumnname,b.storage_location,b.path,b.newfile_name,b.cloud_path from ld_seattachmentsrel a left join ld_attachments b on a.attachmentsid=b.attachmentsid where a.crmid=?";
                $attachment_res = $this->adb->pquery($attachment_sql,array($list[$i]['goodid']));
                $attachment_nums = $this->adb->num_rows($attachment_res);
                $list[$i]['image'] = $defaultImage;
                if($attachment_nums>0){
                    for($j=0;$j<$attachment_nums;$j++){
                        $temp_attachmentcolumnname = $this->adb->query_result($attachment_res,$j,'attachmentcolumnname');
                        $temp_storage_location = $this->adb->query_result($attachment_res,$j,'storage_location');
                        $temp_path = $this->adb->query_result($attachment_res,$j,'path');
                        $temp_newfile_name = $this->adb->query_result($attachment_res,$j,'newfile_name');
                        $temp_cloud_path = $this->adb->query_result($attachment_res,$j,'cloud_path');
                        //封面
                        if($temp_attachmentcolumnname=="imagename"){
                            if($temp_storage_location == "cos"){
                                $list[$i]['image'] = $temp_cloud_path;
                            }
                            if($temp_storage_location == "local"){
                                $list[$i]['image'] = $corpurl . $temp_path.$temp_newfile_name;
                            }
                        }
                    }
                }
            }
        }
        return $list;
    }
    /**
     * @return array
     * @throws Exception
     * 商品列表
     * 轮播图数据
     */
    public function ListView(){
        $keyWords = $_REQUEST['keyWords'];
        $sortName = $_REQUEST['sortName'];
        $where  = " where ld_products.deleted=0 ";
        $keyWords = trim($keyWords);
        $param_arr=[];
        if(!empty($keyWords)){
            //小程序商城，首页搜索商品增加搜索推荐和商品详情功能 apprecommendreason
            $where .= " and ( 
            ld_products.productname like ?
            or ld_productcf.productdetails like ? 
			or ld_products.".$this->showProductNoField." like ?
            or ld_products.apprecommendreason like ? ";
            $param_arr[]="%$keyWords%" ;
            $param_arr[]="%$keyWords%" ;
            $param_arr[]="%$keyWords%" ;
            $param_arr[]="%$keyWords%" ;
            if($this->tradeInfo['account']=='liankeshengwu'){
                $where .= " or ld_products.unit_price like ? ";
            }
            $param_arr[]="%$keyWords%" ;
            $where .= " ) ";
        }
        SqlSearchFilter($_REQUEST);

        //zxm 20230221 增加价格区间筛选
        $price_start = trim($_REQUEST['price_start']);
        $price_start = empty($price_start)?0:$price_start;
        $price_end = trim($_REQUEST['price_end']);
        if(!empty($price_start)){
            $where .= " and ld_products.unit_price>=?";
            $param_arr[]=$price_start;
        }
        if(!empty($price_start)){
            $where .= " and ld_products.unit_price<=?";
            $param_arr[]=$price_end;
        }
        //排序字段
        $orderby_sql = " order by ld_products.modifiedtime desc ";
        $orderByFieldName = $_REQUEST['orderByFieldName'];//库存qtyinstock  //价格unit_price
        $orderByType = $_REQUEST['orderByType'];
        if(!empty($orderByFieldName)){
            $orderByType = empty($orderByType)?'asc':$orderByType;
            $orderby_sql = " order by ld_products.$orderByFieldName $orderByType ";
        }
        $sortName = trim($sortName);//子分类
        if(!empty($sortName)&&$sortName!="首页"){
            $where .= " and (ifnull(ld_products.productcategory,'')='$sortName') ";
        }
        //上架的商品
        $where .= " and ld_shop_productproperty.productstatus='上架'";

        $page = $_REQUEST['page'];
        $page = empty($page)?0:$page;
        $limit = $_REQUEST['limit'];
        $limit = empty($limit)?20:$limit;
        $start = $page*$limit;
        $limit_sql = " limit $start,$limit ";
        $count_sql = "select 
                count(1) as nums
                from ld_products left join  ld_productcf on ld_products.productid=ld_productcf.productid 
                inner join ld_shop_productproperty on ld_shop_productproperty.productid=ld_products.productid
                $where";
        $count_res = $this->adb->pquery($count_sql,$param_arr);
        if($this->adb->num_rows($count_res)<=0)
        {
            $count_nums=0;
        }
        else
            $count_nums = $this->adb->query_result($count_res,0,'nums');
        $curpagenum = (int)$page;//当前页
        $totalrows = (int)$count_nums;//总数据条数
        $pagecount = ceil($count_nums/$limit);

        $havenextpage = "yes";
        if(($curpagenum+1)>=$pagecount){
            $havenextpage = "no";//是否还有下一页
        }
        //图片 商品名称 首日租金 续租租金 库存
        $this_month = date('Y-m',time());
        $tmp_param_arr=[];
        $sql_common = " select 
                ld_products.unit_price,ld_products.originalprice,ld_products.qtyinstock,ld_products.productname,
                ld_products.".$this->showProductNoField.",ld_products.productsheet,
                ifnull(ld_products.imagename,'') as imagename,ld_products.productid,
                ifnull(salesorder.quantity,0) as salescount
                from ld_products left join  ld_productcf on ld_products.productid=ld_productcf.productid 
                inner join ld_shop_productproperty on ld_shop_productproperty.productid=ld_products.productid
                left join (
                    select sum(ld_salesorderdetail.quantity)as quantity,ld_salesorderdetail.productid 
                    from ld_salesorderdetail 
                    left join ld_salesorder on ld_salesorder.salesorderid=ld_salesorderdetail.id
                    where ld_salesorder.deleted=0 
                    and ld_salesorder.createdtime like ?    group by ld_salesorderdetail.productid
                )salesorder on salesorder.productid=ld_products.productid";
        $sql = $sql_common.$where. $orderby_sql . $limit_sql;
        $tmp_param_arr[]="%$this_month%";

        $list = $this->getProductListBySql($sql,$tmp_param_arr);
        $appname = isset($this->configArr['appname'])&&!empty($this->configArr['appname'])?$this->configArr['appname']:self::LINGDANG;
        $res = [
            "list"=>$list,
            'curpagenum'=>$curpagenum,
            'totalrows'=>$totalrows,
            'pagecount'=>$pagecount,
            'havenextpage'=>$havenextpage,
            'sortName'=>$sortName,
            'pagename'=>$appname,
            'searchTitle'=>'搜索商品'
        ];
        //首页才需要banner和主题商品
        if($sortName=="首页"){
            $res['swiperData'] = $this->getSwiperData();
            $res['selectedProductData'] = $this->getHomepageTopicProducts();
        }
        $res['navbarTitle'] = $this->getSortList();
        return array(1,$res,'success');
    }

    /**
     * @return array|string[][]
     * @throws Exception
     * 从数据库获取轮播图数据 zxm 2021-11-11
     */
    public function getSwiperData(){
        $sql = "select linktype,linkid,status,file_path,newfile_name from ld_shop_carousels where `status`='yes' order by carouselseq asc limit 5";
        $res = $this->adb->pquery($sql);
        $nums = $this->adb->num_rows($res);
        $swiperList = [];
        if($nums>0){
            for ($i=0;$i<$nums;$i++){
                $linktype = $this->adb->query_result($res,$i,'linktype');
                $linkid = $this->adb->query_result($res,$i,'linkid');
                $file_path = $this->adb->query_result($res,$i,'file_path');
                $newfile_name = $this->adb->query_result($res,$i,'newfile_name');
                $listvalue = '首页';//默认首页
                if($linktype=='Carousel_ProductCategoryList'){
                    $selectSql = "select listvalue from ld_picklist_values where id=?";
                    $selectRes = $this->adb->pquery($selectSql,array($linkid));
                    $selectNums = $this->adb->num_rows($selectRes);
                    if($selectNums>0){
                        $listvalue = $this->adb->query_result($selectRes,0,0);
                    }
                }
                $swiperList[$i]['img'] = $this->corpurl.$file_path.$newfile_name;
                $swiperList[$i]['img'] = $swiperList[$i]['img'].'?a='.rand(0,9999);
                $swiperList[$i]['goodid'] = $linkid;
                $swiperList[$i]['sortName'] = $listvalue;
                $swiperList[$i]['linktype'] = $linktype;
            }
        }
        return $swiperList;
    }

    public function getHomepageTopicProducts(){
        $sql = "select topic_name,topicid from ld_shop_homepagetopic where deleted=0 and presence='yes' order by `sequence` asc";
        $res = $this->adb->pquery($sql);
        $nums = $this->adb->num_rows($res);
        $defaultImage = $this->defaultProductImage;
        $HomepageTopicProducts = array();
        if($nums>0) {
            for ($i = 0; $i < $nums; $i++) {
                $topic_name = $this->adb->query_result($res,$i,'topic_name');
                $topicid = $this->adb->query_result($res,$i,'topicid');

                $child_sql = "select 
                ld_products.unit_price,ld_products.originalprice,ld_products.qtyinstock,ld_products.productname,ifnull(ld_products.imagename,'') as imagename,ld_products.productid
                from ld_shop_homepagetopic_products left join ld_products on ld_shop_homepagetopic_products.productid=ld_products.productid
                left join  ld_productcf on ld_products.productid=ld_productcf.productid  
                inner join ld_shop_productproperty on ld_shop_productproperty.productid=ld_products.productid
                where ld_shop_homepagetopic_products.topicid=? and ld_products.deleted=0    
                and ld_shop_productproperty.productstatus='上架'
                order by ld_shop_homepagetopic_products.sequence asc ";
                $child_res = $this->adb->pquery($child_sql,array($topicid));
                $child_nums = $this->adb->num_rows($child_res);
                $temp_list = array();
                if($child_nums>0) {
                    for($j=0;$j<$child_nums;$j++){
                        $temp_list[$j]['price'] = $this->adb->query_result($child_res,$j,'unit_price');
                        $temp_list[$j]['price'] = round($temp_list[$j]['price'],2);//续租价格
                        $temp_list[$j]['price_arr'] = $this->formatPrice($temp_list[$j]['price']);
                        $temp_list[$j]['originalprice'] = $this->adb->query_result($res,$j,'originalprice');//原价字段
                        $temp_list[$j]['originalprice'] = $temp_list[$j]['originalprice']<=0?"":round($temp_list[$j]['originalprice'],2);//原价为0则直接用价格字段的值
                        $temp_list[$j]['goodsstock'] = $this->adb->query_result($child_res,$j,'qtyinstock');
                        $temp_list[$j]['goodsstock'] = round($temp_list[$j]['goodsstock'],2);//库存
                        $temp_list[$j]['name'] = $this->adb->query_result($child_res,$j,'productname');//产品名称

                        $temp_list[$j]['goodid'] = $this->adb->query_result($child_res,$j,'productid');
                        $temp_list[$j]['goodid'] = (int)$temp_list[$j]['goodid'];
                        //查询所有附件
                        $attachment_sql = "select a.attachmentcolumnname,b.storage_location,b.path,b.newfile_name,b.cloud_path from ld_seattachmentsrel a left join ld_attachments b on a.attachmentsid=b.attachmentsid where a.crmid=?";
                        $attachment_res = $this->adb->pquery($attachment_sql,array($temp_list[$j]['goodid']));
                        $attachment_nums = $this->adb->num_rows($attachment_res);
                        $temp_list[$j]['image'] = $defaultImage;
                        if($attachment_nums>0){
                            for($k=0;$k<$attachment_nums;$k++){
                                $temp_attachmentcolumnname = $this->adb->query_result($attachment_res,$k,'attachmentcolumnname');
                                $temp_storage_location = $this->adb->query_result($attachment_res,$k,'storage_location');
                                $temp_path = $this->adb->query_result($attachment_res,$k,'path');
                                $temp_newfile_name = $this->adb->query_result($attachment_res,$k,'newfile_name');
                                $temp_cloud_path = $this->adb->query_result($attachment_res,$k,'cloud_path');
                                //封面
                                if($temp_attachmentcolumnname=="imagename"){
                                    if($temp_storage_location == "cos"){
                                        $temp_list[$j]['image'] = $temp_cloud_path;
                                    }
                                    if($temp_storage_location == "local"){
                                        $temp_list[$j]['image'] = $this->corpurl . $temp_path.$temp_newfile_name;
                                    }
                                }
                            }
                        }
                    }
                }
                if(!empty($temp_list)){
                    $HomepageTopicProducts[$i]['name'] = $topic_name;
                    $HomepageTopicProducts[$i]['list'] = $temp_list;
                }
            }
        }
        return array_values($HomepageTopicProducts);
    }
    /**
     * @return array
     * @throws Exception
     * 详情页
     */
    public function DetailView(){
        $productid = $_REQUEST['productid'];
        //productcategory总分类
        $this_month = date('Y-m',time());
        $sql = " select 
                ld_products.productcategory as sortName,
                ld_products.unit_price,
                ld_products.originalprice,
                ld_products.appsharetitle,
                ld_products.appshareimage,
                ld_products.apprecommendreason,
                ld_products.qtyinstock,
                ld_products.productname,
				ld_products.".$this->showProductNoField.",
				ld_products.productsheet,
                ifnull(ld_products.imagename,'') as imagename,
                ld_products.productid,
                ifnull(ld_productcf.productdetails,'')as productdetails,
                ifnull(salesorder.quantity,'')as salescount
                from ld_products 
                left join  ld_productcf on ld_products.productid=ld_productcf.productid
                left join (
                    select sum(ld_salesorderdetail.quantity)as quantity,ld_salesorderdetail.productid 
                    from ld_salesorderdetail 
                    left join ld_salesorder on ld_salesorder.salesorderid=ld_salesorderdetail.id
                    where ld_salesorder.deleted=0 and ld_salesorderdetail.productid=?
                    and ld_salesorder.createdtime like ?
                    group by ld_salesorderdetail.productid
                )salesorder on salesorder.productid=ld_products.productid 
                where ld_products.deleted=0 and ld_products.productid=?";
        $monthvar="%$this_month%";

        $res = $this->adb->pquery($sql,array($monthvar,$productid,$productid));
        $product = [];
        $nums = $this->adb->num_rows($res);
        $corpurl = $this->corpurl;
        $defaultImage = $this->defaultProductImage;
        if($nums>0){
            $product['sortName'] =  $this->adb->query_result($res,0,'sortName');
            $product['price'] = $this->adb->query_result($res,0,'unit_price');
            $product['price'] = round($product['price'],2);//续租价格
            $product['price_arr'] = $this->formatPrice($product['price']);
            $product['originalprice'] = $this->adb->query_result($res,0,'originalprice');//原价字段
            $product['originalprice'] = $product['originalprice']<=0?"":round($product['originalprice'],2);//原价为0则直接用价格字段的值
            $product['goodsstock'] = $this->adb->query_result($res,0,'qtyinstock');
            $product['goodsstock'] = round($product['goodsstock'],2);//库存数量
            $product['name'] = $this->adb->query_result($res,0,'productname').' '.$this->adb->query_result($res,0,$this->showProductNoField).' '.$this->adb->query_result($res,0,'productsheet');
			$product['num'] = $this->adb->query_result($res,0,$this->showProductNoField);//产品编号
            $product['sheet'] = $this->adb->query_result($res,0,'productsheet');//规格型号
            $product['image'] = $this->adb->query_result($res,0,'imagename');
            $product['salescount'] = $this->adb->query_result($res,0,'salescount');
            $product['salescount'] = (string)(int)$product['salescount'] ;
            $product['image'] = empty($list['image'])?$defaultImage:$list['image'];//商品封面图
            $appsharetitle = $this->adb->query_result($res,0,'appsharetitle');
            $product['apprecommendreason'] = $this->adb->query_result($res,0,'apprecommendreason');
            $product['apprecommendreason'] = empty($product['apprecommendreason'])?"":$product['apprecommendreason'];
            $product['apprecommendreason'] = str_replace("\r\n","<br>",$product['apprecommendreason']);
            $product['apprecommendreason'] = str_replace("\n","<br>",$product['apprecommendreason']);
            $product['shareTitle'] = empty($appsharetitle)?$product['name']:$appsharetitle;//分享名称--暂时用产品名称
            $product['shareTitle'] = htmlspecialchars_decode($product['shareTitle']);
            $product['goodid'] = $this->adb->query_result($res,0,'productid');
            $product['goodid'] = (int)$product['goodid'];
            $product['productdetails'] = $this->adb->query_result($res,0,'productdetails');
            $product['productdetails'] = str_replace('storage/ueditor/php',$corpurl."storage/ueditor/php",$product['productdetails']);
            $product['productdetails'] = htmlspecialchars_decode($product['productdetails']);
            //查询所有附件
            $attachment_sql = "select a.attachmentcolumnname,b.storage_location,b.path,b.newfile_name,b.cloud_path from ld_seattachmentsrel a left join ld_attachments b on a.attachmentsid=b.attachmentsid where a.crmid=?";
            $attachment_res = $this->adb->pquery($attachment_sql,array($productid));
            $attachment_nums = $this->adb->num_rows($attachment_res);
            $product['image'] = $defaultImage;

            $product['shareImageUrl'] = $defaultImage;//分享图 --暂时使用产品图的第一张
            if($attachment_nums>0){
                for($j=0;$j<$attachment_nums;$j++){
                    $temp_attachmentcolumnname = $this->adb->query_result($attachment_res,$j,'attachmentcolumnname');
                    $temp_storage_location = $this->adb->query_result($attachment_res,$j,'storage_location');
                    $temp_path = $this->adb->query_result($attachment_res,$j,'path');
                    $temp_newfile_name = $this->adb->query_result($attachment_res,$j,'newfile_name');
                    $temp_cloud_path = $this->adb->query_result($attachment_res,$j,'cloud_path');
                    //封面 第一张图
                    if($temp_attachmentcolumnname=="imagename"){
                        if($temp_storage_location == "cos"){
                            if($j==0) {
                                //封面 第一个图
                                $product['image'] = $temp_cloud_path;
                            }
                            //banner 所有的图
                            $product['imageBanner'][] = $temp_cloud_path;
                        }
                        if($temp_storage_location == "local"){
                            if($j==0) {
                                //封面 第一个图
                                $product['image'] = $corpurl . $temp_path . $temp_newfile_name;
                            }
                            //banner 所有的图
                            $product['imageBanner'][] =  $corpurl . $temp_path.$temp_newfile_name;

                        }
                    }
                    $product['shareImageUrl'] = $product['image'];
                    //分享图
                    if($temp_attachmentcolumnname=="appshareimage"){
                        if($temp_storage_location == "cos"){
                            //第一个图
                            $product['shareImageUrl'] = $temp_cloud_path;
                        }
                        if($temp_storage_location == "local"){
                            //第一个图
                            $product['shareImageUrl'] = $corpurl . $temp_path . $temp_newfile_name;
                        }
                    }
                }
            }else{
                $product['imageBanner'] = [$product['image'],$product['image'],$product['image']];
            }

            //地址信息
            /**$address = [
                'lastname'=>'名字',
                'mobile'=>'18852154632',
                'address'=>'上海市浦东新区张杨路100号18号601',
            ];**/
            $address = $this->getAddress();
            return array(1,[
                'list'=>$product,
                'pagename'=>$product['name'],
                'addressList'=>$address
            ],'success');
        }else{
            return array(-1,[],'产品不存在或已删除');
        }
    }
    public function getAddress(){
        $accountid = $_REQUEST['accountid'];
        if($accountid<=0||empty($accountid)){
            return array();
        }
        $contact_sql = " select 
 contactid,
 lastname,
 ifnull(mobile,'') as mobile,
 ifnull(mailingcountry,'') as mailingcountry,
 ifnull(mailingstate,'') as mailingstate,
 ifnull(mailingcity,'') as mailingcity,
 ifnull(mailingarea,'') as mailingarea,
 ifnull(mailingstreet,'') as mailingstreet,
 reference 
 from ld_contactdetails where accountid=?  and deleted=0 and ifnull(mailingstreet,'') !='' order by reference desc limit 0,1";
        $contact_res = $this->adb->pquery($contact_sql,array($accountid));
        $contact_nums = $this->adb->num_rows($contact_res);
        $address = [];
        if($contact_nums>0){
            $address['contactid'] = $this->adb->query_result($contact_res,0,'contactid');
            $address['lastname'] = $this->adb->query_result($contact_res,0,'lastname');
            $address['mobile'] = $this->adb->query_result($contact_res,0,'mobile');
            $address['mailingcountry'] = $this->adb->query_result($contact_res,0,'mailingcountry');
            $address['mailingstate'] = $this->adb->query_result($contact_res,0,'mailingstate');
            $address['mailingcity'] = $this->adb->query_result($contact_res,0,'mailingcity');
            $address['mailingarea'] = $this->adb->query_result($contact_res,0,'mailingarea');
            $address['mailingstreet'] = $this->adb->query_result($contact_res,0,'mailingstreet');
            $address['reference'] = $this->adb->query_result($contact_res,0,'reference');
            $address['isDefault'] = $address['reference']==1?'yes':'no';//是否默认
            $address['wholeAddress'] = $address['mailingstate'].' '.$address['mailingcity'].' '.$address['mailingarea'].' '.$address['mailingstreet'];
            $address['wholeAddress'] = trim($address['wholeAddress'],' ');
        }
        return $address;
    }
    /**
     * @return string[]
     * 商品分类列表
     */
    public function getSortList(){
        $sort = ['首页'];
        $sql = 'select keyid,entityid,entityname,display,sequence,type from ld_shop_othersettings where type = "productcategory" and display = "show" order by sequence asc';
        $res = $this->adb->pquery($sql);
        $nums = $this->adb->num_rows($res);
        if($nums>0){
            for($i=0;$i<$nums;$i++){
                $sort[] = $this->adb->query_result($res,$i,'entityname');
            }
        }
        else{
            $sql = 'select b.listvalue from ld_picklist_set a left join ld_picklist_values b on a.listid=b.listid where a.listname="productcategory" and  a.relatetable="ld_field" order by sequence asc ';
            $res = $this->adb->pquery($sql);
            $nums = $this->adb->num_rows($res);
            if($nums>0){
                for($i=0;$i<$nums;$i++){
                    $sort[] = $this->adb->query_result($res,$i,'listvalue');
                }
            }
        }
        return $sort;
    }

    /**
     * 加入购物车
     * 判断商品ID 起始日期是否一致  一致则只加减数量（编辑）  不一致则加单据
     */
    public function addCart(){
        $productid = $_REQUEST['productid'];//产品ID
        $quantity = $_REQUEST['quantity'];//产品数量
        $quantity = empty($quantity)?1:$quantity;
        $accountid = $_REQUEST['accountid'];//客户ID
        $wxuserid = $_REQUEST['wxuserid'];//微信用户ID
        $product_sql = "select smownerid from ld_products where productid=? and deleted=0";
        $product_res = $this->adb->pquery($product_sql,array($productid));
        $product_nums = $this->adb->num_rows($product_res);
        if($product_nums<0){
            return array(-1,[],'产品不存在或已删除！');
        }
        $smownerid = $this->adb->query_result($product_res,0,'smownerid');
        //判断商品ID 起始日期是否一致  一致则只加减数量（编辑）  不一致则加单据
        $cart_sql = "select * from ld_shopcartdetails where productid=? and relatedmodule=? and relatedid=? limit 0,1";
        $cart_res = $this->adb->pquery($cart_sql,array($productid,'WeChatUser',$wxuserid));
        $cart_nums = $this->adb->num_rows($cart_res);
        if($cart_nums>0){
            $cartid = $this->adb->query_result($product_res,0,'cartid');
            $cur_quantity = $this->adb->query_result($product_res,0,'quantity');
            $quantity = $cur_quantity+$quantity;
            $update_sql = " update ld_shopcartdetails set quantity=? where cartid=?";
            $update_res = $this->adb->pquery($update_sql,array($quantity,$cartid));
        }else{
            $insert_sql = " insert into ld_shopcartdetails (productid,quantity,smownerid,createdtime,relatedmodule,relatedid) values (?,?,?,?,?,?)";
            $insert_res = $this->adb->pquery($insert_sql,array($productid,$quantity,$smownerid,date('Y-m-d H:i:s'),'WeChatUser',$wxuserid));
        }
        return array(1,[],'success');
    }
    /**
     * 购物车列表
     */
    public function cartList(){
        $accountid = $_REQUEST['accountid'];
        $wxuserid = $_REQUEST['wxuserid'];
        $page = $_REQUEST['page'];
        $page = empty($page)?1:$page;
        $limit = $_REQUEST['limit'];
        $limit = empty($limit)?20:$limit;
        $start = ($page-1)*$limit;
        $limit_sql = " limit $start,$limit ";
        $count_sql = "select 
                count(1) as nums
                from ld_shopcartdetails
                left join ld_products on ld_shopcartdetails.productid=ld_products.productid
                left join ld_productcf on ld_products.productid=ld_productcf.productid
                where relatedmodule='WeChatUser' and relatedid=?";
        $count_res = $this->adb->pquery($count_sql,array($wxuserid));
        $count_nums = $this->adb->query_result($count_res,0,'nums');
        $curpagenum = (int)$page;//当前页
        $totalrows = (int)$count_nums;//总数据条数
        $pagecount = ceil($count_nums/$limit);

        $havenextpage = "yes";
        if($curpagenum>=$pagecount){
            $havenextpage = "no";//是否还有下一页
        }
        $list = $this->getCartListData($wxuserid,$limit_sql,'',$total,'no');
        return array(1,[
            "list"=>$list,
            'curpagenum'=>$curpagenum,
            'totalrows'=>$totalrows,
            'pagecount'=>$pagecount,
            'pagename'=>'购物车',
            'havenextpage'=>$havenextpage
        ],'success');
    }
    /**
     * 从购物车删除
     * 批量删除
     */
    public function delCart(){
        $cartid = $_REQUEST['cartid'];//购物车ID
        $cartid = trim($cartid,',');
        $delete_sql = " delete from ld_shopcartdetails where cartid in ($cartid)";
        $delete_res = $this->adb->pquery($delete_sql,array());
        return array(1,[],'success');
    }
    /**
    编辑购物车
     */
    public function editCart(){
        $cartid = $_REQUEST['cartid'];//购物车ID
        $quantity = $_REQUEST['quantity'];//产品数量
        //改变起止日期的时候 判断这个起止日期是否有相同商品  如果有 则删除该商品
        //$select_sql = " select * from ld_shopcartdetails where ";
        $update_sql = " update ld_shopcartdetails set quantity=? where cartid=?";
        $update_res = $this->adb->pquery($update_sql,array($quantity,$cartid));
        return array(1,[],'success');
    }
    public function getCartListData($wxuserid,$limit='',$extroWhere='',&$total=0,$isPreview='no'){
        $select_sql = "select 
        ld_shopcartdetails.cartid,
        ld_products.productcategory as sortName,
        ld_shopcartdetails.productid,
        ld_shopcartdetails.quantity,
        ld_products.unit_price as price,
        ld_products.originalprice,
        ld_products.qtyinstock as goodsstock,
        ld_products.productname as productname,
        ld_products.".$this->showProductNoField.",
        ld_products.productsheet,
        ifnull(ld_products.imagename,'') as image, ld_products.deleted
        from ld_shopcartdetails
        left join ld_products on ld_shopcartdetails.productid=ld_products.productid
        left join ld_productcf on ld_products.productid=ld_productcf.productid
        where relatedmodule='WeChatUser'  and ld_products.deleted=0 and relatedid=? $extroWhere $limit";
        $select_res = $this->adb->pquery($select_sql,array($wxuserid));
        $select_nums = $this->adb->num_rows($select_res);
        $list = [];
        $corpurl = $this->corpurl;
        $defaultImage = $this->defaultProductImage;
        if($select_nums>0){
            for($i=0;$i<$select_nums;$i++){
                $cartid = $this->adb->query_result($select_res,$i,'cartid');
                $cartid = (int)$cartid;
                $list[$cartid]['cartid'] =  $cartid;
                $list[$cartid]['sortName'] =  $this->adb->query_result($select_res,$i,'sortName');

                $list[$cartid]['deleted'] = $this->adb->query_result($select_res,$i,'deleted');
                $list[$cartid]['isDeleted'] = $list[$cartid]['deleted']==0?"no":"yes";//是否被删除 yes是
                $list[$cartid]['price'] = $this->adb->query_result($select_res,$i,'price');
                $list[$cartid]['price'] = round($list[$cartid]['price'],2);//续租价格
                $list[$cartid]['price_arr'] = $this->formatPrice($list[$cartid]['price']);
                $list[$cartid]['originalprice'] = $this->adb->query_result($select_res,$i,'originalprice');//原价字段
                $list[$cartid]['originalprice'] = $list[$cartid]['originalprice']<=0?"":round($list[$cartid]['originalprice'],2);//原价为0则直接用价格字段的值
                $list[$cartid]['goodsstock'] = $this->adb->query_result($select_res,$i,'goodsstock');
                $list[$cartid]['goodsstock'] = round($list[$cartid]['goodsstock'],2);//库存
                $list[$cartid]['name'] = $this->adb->query_result($select_res,$i,'productname');//产品名称
                $list[$cartid]['num'] = $this->adb->query_result($select_res,$i,$this->showProductNoField);
                $list[$cartid]['sheet'] = $this->adb->query_result($select_res,$i,'productsheet');
                $list[$cartid]['goodid'] = $this->adb->query_result($select_res,$i,'productid');
                $list[$cartid]['goodid'] = (int)$list[$cartid]['goodid'];
                $list[$cartid]['buynum'] = $this->adb->query_result($select_res,$i,'quantity');
                $list[$cartid]['buynum'] = (int)$list[$cartid]['buynum'];
                $list[$cartid]['checked'] = false;
                $list[$cartid]['subtotal'] = $list[$cartid]['price']*$list[$cartid]['buynum'];
                $list[$cartid]['subtotal_arr'] = $this->formatPrice($list[$cartid]['subtotal']);
                $total += $list[$cartid]['subtotal'];
                //查询所有附件
                $attachment_sql = "select a.attachmentcolumnname,b.storage_location,b.path,b.newfile_name,b.cloud_path from ld_seattachmentsrel a left join ld_attachments b on a.attachmentsid=b.attachmentsid where a.crmid=?";
                $attachment_res = $this->adb->pquery($attachment_sql,array($list[$cartid]['goodid']));
                $attachment_nums = $this->adb->num_rows($attachment_res);
                $list[$cartid]['image'] = $defaultImage;
                if($attachment_nums>0){
                    for($j=0;$j<$attachment_nums;$j++){
                        $temp_attachmentcolumnname = $this->adb->query_result($attachment_res,$j,'attachmentcolumnname');
                        $temp_storage_location = $this->adb->query_result($attachment_res,$j,'storage_location');
                        $temp_path = $this->adb->query_result($attachment_res,$j,'path');
                        $temp_newfile_name = $this->adb->query_result($attachment_res,$j,'newfile_name');
                        $temp_cloud_path = $this->adb->query_result($attachment_res,$j,'cloud_path');
                        //封面
                        if($temp_attachmentcolumnname=="imagename"){
                            if($temp_storage_location == "cos"){
                                $list[$cartid]['image'] = $temp_cloud_path;
                            }
                            if($temp_storage_location == "local"){
                                $list[$cartid]['image'] = $corpurl . $temp_path.$temp_newfile_name;
                            }
                        }
                    }
                }
            }
        }
        return $list;
    }
    /**
     * 结算页
     */
    public function previewOrder(){
        //结算类型 购物车结算cart  直接结算direct
        $type = $_REQUEST['previewOrderType'];
        $type = empty($type)?'cart':$type;

        if($this->showAtt=='yes') {
            initUserPrivileges(1);
            //小程序商城 获取字段信息
            $_REQUEST['action'] = 'CreateView';
            $_REQUEST['fromldmall'] = 'yes';
            crm_load_class_file('cls_Instance', 'WeiXinApp/WeiXin_common');
            crm_load_class_file('cls_DetailViewWX', 'WeiXinApp/detail');
            $DetailViewWXobj = new cls_DetailViewWX('SalesOrder');
            $createview_fieldsinfo = $DetailViewWXobj->common_getInfo();
            $createview_fieldlist = [];
            foreach ($createview_fieldsinfo as $mallblockindex => $mallblockinfo) {
                foreach ($mallblockinfo['fieldinfo'] as $mallvalue) {
                    if ($mallvalue['fieldname'] == 'filename') {
                        $createview_fieldlist[$mallblockindex]['blocklabel'] = $mallblockinfo['blocklabel'];
                        $createview_fieldlist[$mallblockindex]['display_status'] = $mallblockinfo['blocklabel'];
                        $createview_fieldlist[$mallblockindex]['fieldinfo'][] = $mallvalue;
                    }
                }
            }
            $createview_fieldlist = array_values($createview_fieldlist);
        }

        if($type=="direct"){
            $total = 0;
            $corpurl = $this->corpurl;
            $defaultImage = $this->defaultProductImage;
            $productid = $_REQUEST['productid'];
            $quantity = $_REQUEST['quantity'];
            //直接结算  productid,quantity,lease_start,lease_end
            $select_sql = "select 
        ld_products.productcategory as sortName,
        ld_products.unit_price as price,
        ld_products.originalprice,
        ld_products.qtyinstock as goodsstock,
        ld_products.productname as productname,
        ld_products.".$this->showProductNoField.",
        ld_products.productsheet,
        ifnull(ld_products.imagename,'') as image
        from ld_products 
        left join ld_productcf on ld_products.productid=ld_productcf.productid
        where ld_products.productid=?";
            $select_res = $this->adb->pquery($select_sql,array($productid));
            $select_nums = $this->adb->num_rows($select_res);
            $product = [];
            if($select_nums>0){
                $product['sortName'] = $this->adb->query_result($select_res,0,'sortName');
                $product['price'] = $this->adb->query_result($select_res,0,'price');
                $product['price'] = round($product['price'],2);//续租价格
                $product['price_arr'] = $this->formatPrice($product['price']);
                $product['originalprice'] = $this->adb->query_result($select_res,0,'originalprice');//原价字段
                $product['originalprice'] = $product['originalprice']<=0?"":round($product['originalprice'],2);//原价为0则直接用价格字段的值

                $product['goodsstock'] = $this->adb->query_result($select_res,0,'goodsstock');
                $product['goodsstock'] = round($product['goodsstock'],2);//库存
                $product['name'] = $this->adb->query_result($select_res,0,'productname');//产品名称
                $product['num'] = $this->adb->query_result($select_res,0,$this->showProductNoField);
                $product['sheet'] = $this->adb->query_result($select_res,0,'productsheet');
                $product['goodid'] = $productid;
                $product['buynum'] = $quantity;
                $product['checked'] = false;
                $product['subtotal'] = $product['price']*$product['buynum'];
                $product['subtotal_arr'] = $this->formatPrice($product['subtotal']);
                $total += $product['subtotal'];
                //查询所有附件
                $attachment_sql = "select a.attachmentcolumnname,b.storage_location,b.path,b.newfile_name,b.cloud_path from ld_seattachmentsrel a left join ld_attachments b on a.attachmentsid=b.attachmentsid where a.crmid=?";
                $attachment_res = $this->adb->pquery($attachment_sql,array($product['goodid']));
                $attachment_nums = $this->adb->num_rows($attachment_res);
                $product['image'] = $defaultImage;
                if($attachment_nums>0){
                    for($j=0;$j<$attachment_nums;$j++){
                        $temp_attachmentcolumnname = $this->adb->query_result($attachment_res,$j,'attachmentcolumnname');
                        $temp_storage_location = $this->adb->query_result($attachment_res,$j,'storage_location');
                        $temp_path = $this->adb->query_result($attachment_res,$j,'path');
                        $temp_newfile_name = $this->adb->query_result($attachment_res,$j,'newfile_name');
                        $temp_cloud_path = $this->adb->query_result($attachment_res,$j,'cloud_path');
                        //封面
                        if($temp_attachmentcolumnname=="imagename"){
                            if($temp_storage_location == "cos"){
                                $product['image'] = $temp_cloud_path;
                            }
                            if($temp_storage_location == "local"){
                                $product['image'] = $corpurl . $temp_path.$temp_newfile_name;
                            }
                        }
                    }
                }
                $list[0] = $product;
            }else{
                return array(-1,[],'产品不存在或已删除！');
            }
        }else{
            //勾选的购物车数据信息
            $cartid = $_REQUEST['cartid'];//1,2,3
            $cartid = trim($cartid);
            $accountid = $_REQUEST['accountid'];//203
            $wxuserid = $_REQUEST['wxuserid'];//203
            //购物车结算的键是cartid
            $list = $this->getCartListData($wxuserid,''," and cartid in ($cartid) ",$total,'yes');
            if(empty($list)){
                return array(-1,[],'购物车已被清理或商品已被下架！');
            }
            $list = array_values($list);
        }

        //首要联系人的地址信息
        $addressList = $this->getAddress();
        //查询公司余额
        $accountInfo = $this->getAccountInfo($_REQUEST['open_id']);
        $balance_amount = empty($accountInfo['balance_amount'])?0:$accountInfo['balance_amount'];

        $resultArr = [
            "list"=>$list,
            "createview_fieldlist"=>$createview_fieldlist,
            'addressList'=>$addressList,
            'total'=>$total,
            'total_arr'=>$this->formatPrice($total),
            'previewOrderType'=>$type,
            'pagename'=>'订单结算',
            'balanceAmount'=>$balance_amount,//余额支付的余额
            'balanceAmountShow'=>$accountInfo['balanceAmountShow']//余额支付的余额--用来显示的
        ];
        if($this->showAtt=='yes') {
            $resultArr['createview_fieldlist'] = $createview_fieldlist;
        }
        return array(1,$resultArr,'success');
    }
}