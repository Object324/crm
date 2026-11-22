<?php
//lius 20231226 XUQIU1002064 【新业】客户下单后，业务员可在手机上自助下单，下单功能需要简单易操作（支持自动识别文字匹配下单）

//zkt 20231122 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb;
if(!isset($adb))
{
    exit();
}
$_REQUEST['diony']='yes';


$in_text = trim($_REQUEST['xinyePasteInfo']);
if (!empty($in_text)) {
    $data = $list = $entry = [];

    //1、单据头信息
    $SQL="SELECT
	a.field_lable,
	b.filed_value
FROM (
	SELECT
		a.seq,
		CASE
			WHEN a.seq=1 THEN '项目名称'
			WHEN a.seq=2 THEN '施工单位'
			WHEN a.seq=3 THEN '工程部位'
			WHEN a.seq=4 THEN '计划首车到达时间'
			WHEN a.seq=5 THEN '运输距离'
		
			WHEN a.seq=6 THEN '地址'
			WHEN a.seq=7 THEN '联系电话'
			WHEN a.seq=8 THEN '用料日期'
			WHEN a.seq=9 THEN '备注'
			WHEN a.seq=10 THEN '特殊要求'
		END AS field_lable
	FROM sequence a
	WHERE a.seq BETWEEN 1 AND 10
) a
LEFT JOIN (
	SELECT
		LEFT(mytext,LOCATE(':',mytext)-1) AS field_lable,
		RIGHT(mytext,CHAR_LENGTH(mytext)-LOCATE(':',mytext)) AS filed_value
	FROM (
		SELECT 
			b.seq,
			REPLACE(substring_index(substring_index(a.mytext,'\n', b.seq+1 ),'\n',- 1) ,'\n','') AS mytext
		FROM (SELECT REPLACE(?,'：',':') AS mytext) a
		LEFT JOIN sequence b ON b.seq <(length(a.mytext) - length( REPLACE(a.mytext,'\n',''))+1) 
		ORDER BY b.seq
	) a
	WHERE LEFT(mytext,LOCATE(':',mytext)-1) NOT IN ('砼标号','坍落度','计划方数')
) b ON a.field_lable=b.field_lable
ORDER BY a.seq;";

    $result = $adb->pquery($SQL,array($in_text));
    $rows=$adb->num_rows($result);//dump($rows);
    if($rows>0)
    {
        $field_mapping = array(
            '项目名称'=>"projectid",
            '施工单位'=>"account_id",//客户名称
            '工程部位'=>"cf_5401",//浇筑部位
            '计划首车到达时间'=>"cf_5403",
            '运输距离'=>"cf_5404",
            '地址'=>"cf_5400",
            '联系电话'=>"cf_5406",
            '用料日期'=>"cf_5408",
            '备注'=>"description",
            '特殊要求'=>"",
        );

        for($i=0;$i<$rows;$i++)
        {
            $field_lable=$adb->query_result($result,$i,"field_lable");
            $field_value=$adb->query_result($result,$i,"filed_value");
            $fieldname = $field_mapping[$field_lable];

            $tmp_list = array(
                "field_lable"=>$field_lable,
                "field_value"=>$field_value,
                "fieldname"=>$fieldname,
            );


            if($fieldname == "projectid" && !empty($field_value)){
                $sql_project = "select projectid from ld_project where projectname=? and deleted = 0 ORDER BY modifiedtime DESC LIMIT 1";
                $result_project = $adb->pquery($sql_project,array($field_value));

                $projectid = 0;
                if($adb->num_rows($result_project) > 0){
                    $projectid = $adb->query_result($result_project,0,0);
                }
                $tmp_list = array_merge($tmp_list,array("recordid"=>$projectid));

            }

            if($fieldname == "account_id" && !empty($field_value)){
                $sql_account = "SELECT accountid FROM ld_account WHERE accountname=? AND deleted = 0 ORDER BY modifiedtime DESC LIMIT 1";
                $result_account = $adb->pquery($sql_account,array($field_value));

                $account_id = 0;
                if($adb->num_rows($result_account) > 0){
                    $account_id = $adb->query_result($result_account,0,0);
                }
                $tmp_list = array_merge($tmp_list,array("recordid"=>$account_id));

            }

            $list[]=$tmp_list;
        }
    }
    $data['list']=$list;



//    -- 2、产品分录信息（产品可能有多个，按逗号分隔，有可能逗号个数不一致）
    $SQL = "SELECT
	a.seq+1 AS seq,
	a.filed_value AS productid,
	b.filed_value AS tanluodu,
	c.filed_value+0 AS quantity
FROM (
	SELECT
		b.seq,
		c.productid AS filed_value
	FROM (
		SELECT
			LEFT(mytext,LOCATE(':',mytext)-1) AS field_lable,
			RIGHT(mytext,CHAR_LENGTH(mytext)-LOCATE(':',mytext)) AS filed_value
		FROM (
			SELECT 
				b.seq,
				REPLACE(substring_index(substring_index(a.mytext,'\n', b.seq+1 ),'\n',- 1) ,'\n','') AS mytext
			FROM (SELECT REPLACE(?,'：',':') AS mytext) a
			LEFT JOIN sequence b ON b.seq <(length(a.mytext) - length( REPLACE(a.mytext,'\n',''))+1) 
			ORDER BY b.seq
		) a
		WHERE LEFT(mytext,LOCATE(':',mytext)-1)='砼标号'
	) a
	LEFT JOIN sequence b ON b.seq <(length(a.filed_value) - length( REPLACE(a.filed_value,',',''))+1) 
	LEFT JOIN ld_products c ON c.productname=substring_index(substring_index(a.filed_value,',', b.seq+1 ),',',- 1)
) a
LEFT JOIN (
	SELECT
		b.seq,
		substring_index(substring_index(a.filed_value,',', b.seq+1 ),',',- 1) AS filed_value
	FROM (
		SELECT
			LEFT(mytext,LOCATE(':',mytext)-1) AS field_lable,
			RIGHT(mytext,CHAR_LENGTH(mytext)-LOCATE(':',mytext)) AS filed_value
		FROM (
			SELECT 
				b.seq,
				REPLACE(substring_index(substring_index(a.mytext,'\n', b.seq+1 ),'\n',- 1) ,'\n','') AS mytext
			FROM (SELECT REPLACE(?,'：',':') AS mytext) a
			LEFT JOIN sequence b ON b.seq <(length(a.mytext) - length( REPLACE(a.mytext,'\n',''))+1) 
			ORDER BY b.seq
		) a
		WHERE LEFT(mytext,LOCATE(':',mytext)-1)='坍落度'
	) a
	LEFT JOIN sequence b ON b.seq <(length(a.filed_value) - length( REPLACE(a.filed_value,',',''))+1) 
) b ON b.seq=a.seq
LEFT JOIN (
	SELECT
		b.seq,
		substring_index(substring_index(a.filed_value,',', b.seq+1 ),',',- 1) AS filed_value
	FROM (
		SELECT
			LEFT(mytext,LOCATE(':',mytext)-1) AS field_lable,
			RIGHT(mytext,CHAR_LENGTH(mytext)-LOCATE(':',mytext)) AS filed_value
		FROM (
			SELECT 
				b.seq,
				REPLACE(substring_index(substring_index(a.mytext,'\n', b.seq+1 ),'\n',- 1) ,'\n','') AS mytext
			FROM (SELECT REPLACE(?,'：',':') AS mytext) a
			LEFT JOIN sequence b ON b.seq <(length(a.mytext) - length( REPLACE(a.mytext,'\n',''))+1) 
			ORDER BY b.seq
		) a
		WHERE LEFT(mytext,LOCATE(':',mytext)-1)='计划方数'
	) a
	LEFT JOIN sequence b ON b.seq <(length(a.filed_value) - length( REPLACE(a.filed_value,',',''))+1) 
) c ON c.seq=a.seq
WHERE a.filed_value>0
ORDER BY a.seq;";
    $result = $adb->pquery($SQL,array($in_text,$in_text,$in_text));
    $rows=$adb->num_rows($result);
    if($rows>0)
    {
        for($i=0;$i<$rows;$i++)
        {
            $seq=$adb->query_result($result,$i,"seq");
            $productid=$adb->query_result($result,$i,"productid");
            $tanluodu=(string)$adb->query_result($result,$i,"tanluodu");
            $quantity=(int)$adb->query_result($result,$i,"quantity");
            $entry[]=array(
                "seq"=>$seq,
                "productid"=>$productid,
                "tanluodu"=>$tanluodu,
                "quantity"=>$quantity,
            );
        }
    }
    $data['entry']=$entry;

    ConvertTojsonString(1,$data,"success");
}
ConvertTojsonString(-1,array(),"fail");



?>