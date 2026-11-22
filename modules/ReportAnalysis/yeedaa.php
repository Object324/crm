<?php
//lius 20231101 XUQIU1002078 艺搭环保科技物料清单报表开发--对应订单中的4个开发费
error_reporting(E_ALL^E_NOTICE^E_WARNING);
header("content-type:text/html;charset=utf-8");
global $adb;

$_REQUEST['diony'] = 'yes';
$smarty = new lingdangCRM_Smarty();
$mode = $_REQUEST['mode'];


if($mode == 'search' || $mode == 'export'){
    $campaignname = trim($_REQUEST['campaignname']);//展会名称
    $potentialname = trim($_REQUEST['potentialname']);//展台名称
    $zhanwei_no = trim($_REQUEST['zhanwei_no']);//展位号

    $where = '';
    if (!empty($campaignname)) {
        $where .= " and ld_campaign.campaignname like '%$campaignname%' ";
    }
    if (!empty($potentialname)) {
        $where .= " and ld_potential.potentialname like '%$potentialname%' ";
    }
    if (!empty($zhanwei_no)) {
        $where .= " and ld_potentialscf.cf_7441 like '%$zhanwei_no%' ";
    }


    $sql = "SELECT DISTINCT
	ld_potential.potentialid,
	ld_potential.potentialname,
	ld_potential.campaignid,
	ld_campaign.campaignname,
	ld_potential.sales_stage,
	ld_potentialscf.cf_7520 AS guan_no,
	ld_potentialscf.cf_7441 AS zhanwei_no,
	ld_potentialscf.cf_7496 AS height,
	ld_potentialscf.cf_7497 AS mianji,
	ld_potential.smownerid,

	ld_potentialsdetail.lineitem_id,
	ld_products.productid,
	CONCAT_WS(':',ld_products.productname,ld_products.productsheet) AS line_header,
	ld_products.productname AS products_productname,
	ld_products.productsheet AS products_productsheet,
	SUM(ld_potentialsdetail.quantity) AS products_quantity

FROM
	ld_potential
LEFT JOIN ld_potentialscf ON ld_potentialscf.potentialid = ld_potential.potentialid
LEFT JOIN ld_potentialsdetail ON ld_potentialsdetail.id = ld_potential.potentialid
LEFT JOIN ld_campaign ON ld_campaign.campaignid = ld_potential.campaignid
LEFT JOIN ld_products ON ld_products.productid = ld_potentialsdetail.productid
LEFT JOIN ld_productcf ON ld_products.productid = ld_productcf.productid

INNER JOIN (
	SELECT
		ld_potential.potentialid
	FROM
		ld_potential
	LEFT JOIN ld_potentialscf ON ld_potentialscf.potentialid = ld_potential.potentialid
	WHERE
		ld_potential.deleted = 0
	AND ld_potential.potentialid > 0
	GROUP BY
		ld_potential.potentialid
	ORDER BY
ld_potential.modifiedtime DESC,
		ld_potential.potentialid DESC
) AS temp ON temp.potentialid = ld_potential.potentialid
WHERE
	ld_potential.deleted = 0
AND ld_potential.potentialid > 0
-- AND ld_potential.sales_stage NOT LIKE '%归档%'
AND ld_campaign.campaignstatus NOT LIKE '%归档%'
$where
GROUP BY ld_potential.potentialid,ld_potentialsdetail.productid
ORDER BY
ld_potential.modifiedtime DESC,
	ld_potential.potentialid DESC,
	ld_potentialsdetail.lineitem_id
	";

    $result = $adb->query($sql);
    $num_rows = $adb->num_rows($result);
    $data = [];

    $line_header_arr = ["展会名称","展台名称","项目状态","馆号","展位号","面积","高度"];//列头数据集合
    $line_header_exist_arr = [];//列头已有的产品列头,只显示分录有的产品
    $productid_quantity_arr = [];//销售机会id/产品id/产品数量的关系

    if ($num_rows > 0 ) {
        //1、计算列头需要显示的产品信息  及对应销售机会分别产品的数量
        for($i = 0; $i<$num_rows; $i++) {
            $potentialid = $adb->query_result($result, $i, 'potentialid');
            $productid = $adb->query_result($result, $i, 'productid');
            $line_header = $adb->query_result($result, $i, 'line_header');

            if (!array_key_exists($productid, $line_header_exist_arr)) {
                $line_header_exist_arr[$productid] = $line_header;
                if ($mode == 'export') {
                    $line_header_arr[] = $line_header;
                }else{
                    $line_header_arr[] = '<a target="_blank" class="card-link" class="ld_list_href_name tip-items-list" lasturl="" fieldname="productname" module="Products" record="'.$productid.'" href="index.php?pageto_module=Products&pageto_action=index&pageto_record='.$productid.'" doubleclick="yes"  title="'.$line_header.'">'.$line_header.'</a>';
                }

            }

            //计算每一个销售机会的分录产品对应的数量
            $productid_quantity_arr[$potentialid][$productid]['products_quantity'] = number_format($adb->query_result($result, $i, 'products_quantity'),2);
        }


        //2、再次循环，将上述1中列头的每一个产品去匹配当前销售机会分录的产品  有的话赋值数量，没有就没有
        for($i = 0; $i<$num_rows; $i++) {
            $tmp_arr = [];

            $productid = $adb->query_result($result, $i, 'productid');
            $campaignid = $adb->query_result($result, $i, 'campaignid');
            $campaignname = $adb->query_result($result, $i, 'campaignname');//展会名称
            $potentialid = $adb->query_result($result, $i, 'potentialid');
            $potentialname = $adb->query_result($result, $i, 'potentialname');//展台名称


            //分录有多行，后面行不用赋值了。
            if (isset($data[$potentialid])) {
                continue;
            }

            $potentialname_link = '';
            if ($potentialid > 0) {
                if ($mode == 'export') {
                    $potentialname_link = $potentialname;
                }else
                $potentialname_link = '<a target="_blank" class="card-link" fieldname="potentialname" module="Potentials" record="'.$potentialid.'" href="index.php?pageto_module=Potentials&pageto_action=index&pageto_record='.$potentialid.'" title="'.$potentialname.'">'.$potentialname.'</a>';
            }
            $campaignname_link = '';
            if ($campaignid > 0) {
                if ($mode == 'export') {
                    $campaignname_link = $campaignname;
                }else
                $campaignname_link = '<a target="_blank" class="card-link" title="'.$campaignname.'" fieldname="campaignid" module="Potentials" referencemodule="Campaigns" referencerecord="'.$campaignid.'" record="'.$potentialid.'" lasturl="" href="index.php?pageto_module=Campaigns&pageto_action=index&pageto_record='.$campaignid.'" >'.$campaignname.'</a>';
            }


            $tmp_arr =  array(
                $campaignname_link,
                $potentialname_link,
                $adb->query_result($result, $i, 'sales_stage'),
                $adb->query_result($result, $i, 'guan_no'),
                $adb->query_result($result, $i, 'zhanwei_no'),
                $adb->query_result($result, $i, 'mianji'),
                $adb->query_result($result, $i, 'height'),
            );
//dump($line_header_exist_arr);
            //列头匹配   方便前端取值
            foreach ($line_header_exist_arr as $tmp_productid=>$tmp_line_header){
                array_push($tmp_arr,isset($productid_quantity_arr[$potentialid][$tmp_productid])?$productid_quantity_arr[$potentialid][$tmp_productid]['products_quantity']:'');

            }

            $data[$potentialid] = $tmp_arr;//多个分录需要potentialid作为键去重

        }

        $data = array_values($data);//重置索引,否则会按照potentialid升序显示  而且，js的计算长度length  不这么写返回undefined

    }


    $arr['line_header'] = $line_header_arr;
    $arr['list'] = $data;


    //导出
    if($mode == 'export'){
        include(globalStatic::$root_directory.'PHPExcel/PHPExcel.php');
        $objPHPExcel = new PHPExcel();
        $objPHPExcel->setActiveSheetIndex(0);
        $activesheet=$objPHPExcel->getActiveSheet();
        // 设置表头
        $column = 'A';
        foreach ($line_header_arr as $heading) {
            $activesheet->setCellValue($column . '1', $heading);
            $column++;
        }

        // 将查询结果写入 Excel
        $row = 2;
        foreach ($data as $line) {
            $column = 'A';
            foreach ($line as $value) {
                $activesheet->setCellValue($column . $row, $value);
                $column++;
            }
            $row++;
        }

//        $objWriter = PHPExcel_IOFactory::createWriter($objPHPExcel, 'Excel5');
        $objWriter = PHPExcel_IOFactory::createWriter($objPHPExcel, 'Excel2007');

        //下载文件
        $file_name = "展会产品信息.xlsx";
        $file_path = "storage/".$file_name;
        $objWriter->save($file_path);

        $file = fopen($file_path,"r");
        Header("Content-type: application/octet-stream");
        Header("Accept-Ranges: bytes");
        Header("Accept-Length: ".filesize($file_path));
        Header("Content-Disposition: attachment; filename=\"$file_name\"");
        ob_clean();
        ob_flush();
        echo fread($file, filesize($file_path));
        fclose($file);

        //或者使用 readfile  但是必须配合ob_clean
//        readfile($file_path);
        exit;
    }else
        ConvertTojsonString(1,$arr,"success");
}


$smarty->display('ReportAnalysis/yaadee.tpl');
exit;


?>