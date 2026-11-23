<?php
class PopInventory
{

    static function getListEntityByDetailid($listviewArr){
        $detail_arr = [];
        foreach ($listviewArr as $key => $info){
            $recordid = substrTd($key,1);  //单据ID
            $detailid = substrTd($key,2);  //分录ID
//            $productid =getInventoryProId($detailid,$currentModule);
            $detail_arr[$recordid][] = $detailid;
        }
        return $detail_arr;
    }

    static function createPopWithDetailhtml($LISTENTITY,$SELECT,$ROW_COUNT,$HEADERCOUNT,$LISTVAL,$listviewcontroller)
    {
        global $currentModule,$global_minversin;
       if(empty($LISTVAL))
       {
           $LISTVAL=0;
       }
       $withproductdetail=$_REQUEST['withproductdetail'];//原单是否带出明细，yes:带出
        $versioninfo= getVersionInfo();
        $pophtml=''; 
        if(sizeof($LISTENTITY)<=0)
        {
            $pophtml .= '<tr align="center">';
            $pophtml .= '<td colspan="'.$HEADERCOUNT.'" bgcolor="#fff" style="height:390px;">';
            $pophtml .= '<div class="warningTableContent" style="z-index:600;">';
			$pophtml.= "<div class='wtc_img'><img src='themes/icon2023/ld-no-records.png?v=".$global_minversin."'></div>";
			$pophtml.="<div class='wtc_content'>".getFixedLabel('NOTFOUNDANYRECORD')."</div>";
			$pophtml.="<div class='wtc_content'></div>";
            $pophtml .= '</div>';
            $pophtml .= '</td></tr>';
            return trim($pophtml);
        }
        $haveDetailField = $listviewcontroller->haveDetailField;//是否含有分录字段
        /*listview start*/
        $old_checkvalueid = 0;
        $i=0;
        $row_index=0;
        
        //多个分录时只显示一个选择按钮
        $showdetailbutton = 'yes';
        $popuptype = $_REQUEST['popuptype'];
        if(($popuptype=='MultiplePopup' || $popuptype == 'AccountsChart') && $currentModule=='Accounts'){
            $showdetailbutton = 'no';
        }
        $row_arr=[];
        $sequence=1;
        $detail_arr = self::getListEntityByDetailid($LISTENTITY);

        foreach($LISTENTITY as $entity_id=>$entity)
        {
           
            $redcordid = substrTd($entity_id,1);  //单据ID
            $entitytypeid = substrTd($entity_id,2);  //分录ID


            // ljj 20231122 BUG0075885 kfbcrm-采购询价单-新建-选择产品，弹出层中点击“产品套餐”，操作列显示错误
            $isfirst = true;//是否为第一单据的第一条
            if(array_key_exists($redcordid,$row_arr))
            {
                $isfirst = false;
                if (!$isfirst && $haveDetailField == 'no'){
                    continue;
                }
            }
            $row_arr[$redcordid]=$redcordid;

       
			if(empty($entitytypeid))
            {
                
            }
            else if($currentModule=='Accounts')
            {
                
            }
            else if(get_file_address($currentModule,"ProductDetails"))//038541: （kfbcrm）评论新建界面，相关对象切换【项目工时】源单类型选择单据时界面加载不出来
                 $productid =getInventoryProId($entitytypeid,$currentModule);//获取原单对的产品ID - 输出格式为:lineitem_id_productid\
            $row_td = getTableRowCell($redcordid,$LISTENTITY,$row_index);  //合并列

            if ($haveDetailField == 'no' && $withproductdetail == 'yes'){//无分录字段
                $tmp_entitytypeid = implode('#',$detail_arr[$redcordid]);
                $entity_id = str_replace($entitytypeid,$tmp_entitytypeid,$entity_id);
                $entitytypeid = $tmp_entitytypeid;
            }


            if ($redcordid != $old_checkvalueid){
                $i++;
            }
            if ($i%2 ==0) {
                $pophtml.='<tr class="lvtColDataBj" record="'.$redcordid.'" onmouseover="listOnMouseOver(ld(this))" onmouseout="listOnMouseOut(ld(this),\'On\')" id="row_'.$entity_id.'" >';
            }
            else{
                $pophtml.='<tr class="lvtColData" record="'.$redcordid.'" onmouseover="listOnMouseOver(ld(this))" onmouseout="listOnMouseOut(ld(this),\'on\')" id="row_'.$entity_id.'" >';
            }
          
            /*
			* url中带有select=enable参数的为模块相关信息内 多选模块
			*/
            //edit:duan 群发短信时选择客户单据失败
            $specail_module_arr = array('Accounts','ServiceCharge');

            if($row_td>1 && $haveDetailField != 'no'){
                $rowspan = 'rowspan="'.$row_td.'"';
            }else{
                $rowspan = '';
            }

            if($SELECT == 'enable')
            {
                /**
                 * 产品套餐窗口 选择产品不需要单选产品 所有合并checkbox
                 * @author chj 2014-12-01
                 **/ 
                if(($currentModule != 'Productbom'&&$withproductdetail=='yes')||in_array($currentModule,$specail_module_arr))
                {
                    if($showdetailbutton == 'no'){
                        if($old_checkvalueid != $redcordid){
                            $pophtml .='<td class="firstChild" '.$rowspan.' onclick="toggleSelectAll_parent_td(this)">';
                        }
                    }else{
                        $pophtml .='<td class="firstChild"  onclick="toggleSelectAll_parent_td(this)" shift="yes">';
                    }

                    if(get_file_address($currentModule,'ContactsDetails')||get_file_address($currentModule,'VendorsDetails'))
                    {
                        if($showdetailbutton == 'no'){
                            if($old_checkvalueid != $redcordid){
                                $pophtml .='<input type="checkbox" billinfo=\''.$redcordid.'\' name="selected_id" rowspan="2" value=\''.$entitytypeid.'\' onclick="toggleSelectAll(this.name,\'select_all\')"/>';
                            }
                        }else{
                            if($accountid != $redcordid)
                            {
                                //edit:can 20210316 45004: （https://61mis.com/kfbcrm/ [^]）测试部账号;销售管理>销售机会>单据详情页面>客户1>选择关联的客户；客户关联失败，未显示关联客户的数据
                                $pophtml .='<input type="checkbox" billinfo=\''.$redcordid.'\' name="selected_id" rowspan="2" value=\''.$entitytypeid.'\' onclick="toggleSelectAll(this.name,\'select_all\')"/>';
                            }
                        }
                    }
                    else
                    {


                        if($LISTVAL == 0||!get_file_address($_REQUEST['frommodule'],"ProductDetails"))//郎捷出入库选择
                        {
                            
                           
                           if($_REQUEST['frommodule']=='Commission'&&$versioninfo['account']=='langjie')
                           {
                            //edit:can 2020-09-16 42681: （http://jsjingmei.gnway.org/crm/ [^]）客户问题（麦莎），收款单模块>新建单据界面：选择源单合同订单“SO21173”，“业绩计算公式”字段没有引用过来（引用字段，引用对象“合同订单”，业绩计算公式）
                           
                                $pophtml .='<input type="checkbox" name="selected_id" value=\''.$entitytypeid.'\' billinfo=\''.$entity_id.'\' onclick="toggleSelectAll(this.name,\'select_all\')"/>';
                           }
                           else
                                $pophtml .='<input type="checkbox" name="selected_id" value=\''.$entitytypeid.'\' billinfo=\''.$redcordid.'\' onclick="toggleSelectAll(this.name,\'select_all\')"/>';
                        }
                        else
                        {

                            if ($haveDetailField == 'no' && $withproductdetail == 'yes'){
                                $productid = $tmp_entitytypeid;
                            }
                                $pophtml .='
                                <input type="checkbox" name="selected_id" value=\''.$productid.'\' billinfo=\''.$redcordid.'\'  onclick="toggleSelectAll(this.name,\'select_all\')"/>
								<input type="hidden" id="popup_product_'.$productid.'" vt_prod_arr="" />
                            ';
                            
                        }
                    }
                    if($showdetailbutton == 'no'){
                        if($old_checkvalueid != $redcordid){
                            $pophtml .='</td>';
                        }
                    }else{
                        $pophtml .='</td>';
                    }
                }
                else
                {
                    if($redcordid != $old_checkvalueid)
                    {
//
                            $pophtml .='
                        <td class="firstChild" '.$rowspan.' onclick="toggleSelectAll_parent_td(this)" shift="yes">
                            <input type="checkbox" name="selected_id" billinfo = "'.$redcordid.'"  value="'.$entitytypeid.'" onclick="toggleSelectAll(this.name,\'select_all\')"/>
                        </td>';
                    }
                }
            }

            if (isset($_REQUEST['setsequence']) && $_REQUEST['setsequence'] == 'yes' && $popuptype != 'AccountsChart'){
                if ($_REQUEST['frommodule'] == 'PaymentPlan' || $_REQUEST['frommodule'] == 'SendPayment'){
                    // ljj 20231208 BUG0076941 付款计划、收款计划选择销售订单界面，序号列序号显示错误（因为源单是单选，不存在只选择源单的部分产品明细的情况），应该根据整单显示序号
                    if ($isfirst){
                        $pophtml .='<td style="text-align: center" '.$rowspan.' name="sequence" index="'.$sequence.'">'.$sequence.'</td>';
                        $sequence++;
                    }
                }else{
                    $pophtml .='<td style="text-align: center" name="sequence" index="'.$sequence.'">'.$sequence.'</td>';
                    $sequence++;
                }

            }
            /*if($currentModule == 'Productbom')
            {
                $old_checkvalueid = $redcordid;
            }*/
            $old_checkvalueid = $redcordid;
            $row_index++;

            foreach($entity as $entity_id => $data)
            {
               
                if(istdRight($entity_id,$currentModule))
                    $tdalign = 'right';
                else
                    $tdalign = 'left';
                if((int)$entity_id <= $ROW_COUNT && $data != '&&' && $row_td > 1)
                {
                    $pophtml .='<td align="'.$tdalign.'" '.$rowspan.' valign="top" ispopupdoubleclick="yes">'.$data.'&nbsp;</td>';
                }
                elseif($currentModule == 'Productbom' && foreachArray($entity,$entity_id) == true && $data != '&&')
                {
                    // ljj 20231122 BUG0075885 kfbcrm-采购询价单-新建-选择产品，弹出层中点击“产品套餐”，操作列显示错误
                    //显示分录列，$bol == true且不是同一的第一条时，跳过
                    if ($entity_id >= $ROW_COUNT && !$isfirst){

                    }else{
                        $pophtml .='<td class="lastChild" '.$rowspan.' valign="top" align="'.$tdalign.'" ispopupdoubleclick="yes">'.$data.'&nbsp;</td>';
                    }
                }
                elseif((int)$entity_id >= $ROW_COUNT && $data != '&&' && $row_td > 1)
                {
                    $pophtml .='<td align="'.$tdalign.'" valign="top" ispopupdoubleclick="yes">'.$data.'&nbsp;</td>';
                }
                elseif($data == '&&')
                {}
                else
                {
                    $pophtml .='
                        <td align="'.$tdalign.'" valign="top" ispopupdoubleclick="yes">'.$data.'&nbsp;</td>';
                }
            }
            $pophtml .='</tr>';
            $accountid = $entitytypeid;
        }
       
        return trim($pophtml);
        /*listview end*/
    }
}
?>