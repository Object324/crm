<?php
//ls 20230301  XUQIU1001143【百特】不良事件报告模块生成pdf和xml文件
header("Content-type: text/html; charset=utf-8");
global $adb,$current_user,$currentModule;
$_REQUEST['diony'] = 'yes';
$smarty = new lingdangCRM_Smarty();
$focus = CRMEntity::getInstance($currentModule);

$mode = $_REQUEST['operatetype'];
$record = $_REQUEST['record'];

/*$cf_5516 = $focus->column_fields['cf_5516'];//Name of Service Provider
$cf_5518 = $focus->column_fields['cf_5518'];//Name of Program
$cf_5520 = $focus->column_fields['cf_5520'];//Registration Number
$cf_5522 = $focus->column_fields['cf_5522'];//Date reported to Service Provider
$cf_5524 = $focus->column_fields['cf_5524'];//How did Provider receive communication
$cf_5526 = $focus->column_fields['cf_5526'];//Date transferred to Baxter Pharmacovigil
$cf_6544 = $focus->column_fields['cf_6544'];//Case Number assigned by Service Provider
$cf_5535 = $focus->column_fields['cf_5535'];//Reporter Name
$cf_5536 = $focus->column_fields['cf_5536'];//Title
$cf_5539 = $focus->column_fields['cf_5539'];//Reporter Type
$cf_6593 = $focus->column_fields['cf_6593'];//Fax
$cf_6594 = $focus->column_fields['cf_6594'];//Email
$cf_6595 = $focus->column_fields['cf_6595'];//Reporter`s Company
$cf_6596 = $focus->column_fields['cf_6596'];//Address
$cf_6597 = $focus->column_fields['cf_6597'];//City
$cf_6599 = $focus->column_fields['cf_6599'];//Zip Code
$cf_5554 = $focus->column_fields['cf_5554'];//Cause of Death(if know)
$cf_5559 = $focus->column_fields['cf_5559'];//Date of Death
$cf_5560 = $focus->column_fields['cf_5560'];//Was Autopsy Performed?
$cf_5561 = $focus->column_fields['cf_5561'];//Do you think the AE is related to product?
$cf_6601 = $focus->column_fields['cf_6601'];//Patient/Participant Involved?
$cf_5566 = $focus->column_fields['cf_5566'];//Name
$cf_6545 = $focus->column_fields['cf_6545'];//Initials
$cf_5570 = $focus->column_fields['cf_5570'];//Gender  TODO... 如果Gender（cf_5570）=‘Female’则为2否则为1
$cf_5572 = $focus->column_fields['cf_5572'];//Date Of Birth
$cf_6598 = $focus->column_fields['cf_6598'];//City
$cf_6602 = $focus->column_fields['cf_6602'];//State
$cf_6600 = $focus->column_fields['cf_6600'];//Zip Code
$cf_5580 = $focus->column_fields['cf_5580'];//Phone Number
$cf_5582 = $focus->column_fields['cf_5582'];//Physician Name
$cf_5584 = $focus->column_fields['cf_5584'];//Physician Phone Number
$cf_5586 = $focus->column_fields['cf_5586'];//Can Baxter GPV contact patient?
$cf_5588 = $focus->column_fields['cf_5588'];//Can Baxter GPV contact physician？
$cf_5590 = $focus->column_fields['cf_5590'];//Can Baxter GPV contact reporter?
$cf_5644 = $focus->column_fields['cf_5644'];//Adverse Event
$cf_5594 = $focus->column_fields['cf_5594'];//Event onset date
$cf_6603 = $focus->column_fields['cf_6603'];//Event ongoing?
$cf_6546 = $focus->column_fields['cf_6546'];//Event Resolved?
$cf_6604 = $focus->column_fields['cf_6604'];//If yes,on what date?
$cf_5602 = $focus->column_fields['cf_5602'];//Describe treatment provided for Event
$cf_5592 = $focus->column_fields['cf_5592'];//Event Description(verbatim)*/

/*$cf_6544 = $focus->column_fields['cf_6544'];//不良事件编号字段为Case Number assigned by Service Provider
$cf_5526 = $focus->column_fields['cf_5526'];//取不良事件登记表对象上的Date transferred to Baxter Pharmacovigil（cf_5526）字段
$cf_5522 = $focus->column_fields['cf_5522'];//取记录上的Date reported to Service Provider（PMO_Date_reported_to_Service_Provider_en__c）字段
$cf_5539 = $focus->column_fields['cf_5539'];//记录Reporter Type（cf_5539）字段值为‘Physician’或者‘Healthcare Professional’为1，Reporter Type字段值为‘Pharmacist’为2，Reporter Type字段值为‘Other Health Professional’为3，Reporter Type字段值为‘Lawyer’为4，Reporter Type字段值为‘Consumer or other non health professional’或者 ‘Other(relative)’或者‘Consumer(patient)’或者‘Baxter Representative’为5，


$cf_6545 = $focus->column_fields['cf_6545'];//记录上的Initials（cf_6545）字段值
$cf_6427 = $focus->column_fields['cf_6427'];//记录上的Age（cf_6427）字段
$cf_5570 = $focus->column_fields['cf_5570'];//如果Gender（cf_5570）=‘Female’则为2否则为1
$cf_5644 = $focus->column_fields['cf_5644'];//记录的Adverse Event（cf_5644）字段值
$cf_5593 = $focus->column_fields['cf_5593'];///事件初发日期（cf_5593）字段值；reactionstartdate*/
//reactionstartdate 如果事件初发日期（cf_5593）为null则为空

/*$cf_5570 = $focus->column_fields['cf_5572'];//Date Of Birth
$cf_5570 = $focus->column_fields['cf_6598'];//City
$cf_5570 = $focus->column_fields['cf_6602'];//State
$cf_5570 = $focus->column_fields['cf_6600'];//Zip Code
$cf_5570 = $focus->column_fields['cf_5580'];//Phone Number
$cf_5570 = $focus->column_fields['cf_5582'];//Physician Name
$cf_5570 = $focus->column_fields['cf_5584'];//Physician Phone Number
$cf_5570 = $focus->column_fields['cf_5586'];//Can Baxter GPV contact patient?
$cf_5570 = $focus->column_fields['cf_5588'];//Can Baxter GPV contact physician?
$cf_5570 = $focus->column_fields['cf_5590'];//Can Baxter GPV contact reporter?

$cf_5570 = $focus->column_fields['cf_5644'];//Adverse Event
$cf_5570 = $focus->column_fields['cf_5594'];//Event onset date
$cf_5570 = $focus->column_fields['cf_6603'];//Event ongoing?
$cf_5570 = $focus->column_fields['cf_6546'];//Event Resolved?
$cf_5570 = $focus->column_fields['cf_6604'];//If yes,on what date?
$cf_5570 = $focus->column_fields['cf_5602'];//Describe treatment provided for Event
$cf_5570 = $focus->column_fields['cf_5592'];//Event Description(verbatim)*/

require globalStatic::$root_directory.'include/AWS.php';
$aws = new AWS();

$arr=array();

if($mode=='create')
{
    if(empty($_REQUEST['record'])){
        ConvertTojsonString(-1,$_REQUEST,"缺少单据ID");
    }else{
        $focus->id = $record;
        $focus->retrieve_entity_info($record, $currentModule);
    }
//cf_5512：服务商名称；cf_5514：研究项目名称；cf_5515：注册编号；cf_5517：服务提供商最初接到报告的日期；cf_5519：服务提供商以何种方式接到报告；cf_5521：转发给百特药物警戒部门的日期；customform25_no：服务提供商分配的病例编号；cf_5529：报告人姓名；cf_5532：称呼；cf_5534：报告人类型；cf_6578：传真；cf_6579：电子邮件；cf_6580：报告人所在公司；cf_6581：地址；cf_6582：城市；cf_6584：邮编；cf_5552：死因（如果知道）；cf_5554：死亡日期；cf_5556：是否进行尸检？；cf_5558：您认为该AE是否与产品有关；cf_6585：是否涉及患者/参与者？；cf_5565：姓名；cf_6586：姓名首字母；cf_5569：性别；cf_5571：出生日期；cf_6583：城市；cf_6588：省；cf_6589：邮编；cf_5579：电话号码；cf_5581：医生姓名；cf_5583：医生电话号码；cf_5585：Baxter GPV能否联系患者？；cf_5587：Baxter GPV联系医生？；cf_5589：Baxter GPV能否联系报告人？；cf_6424：不良事件；cf_5593：事件初发日期；cf_6590：事件仍在继续；cf_6591：事件已恢复；cf_6592：如果是，哪一天？；cf_5601：描述针对不良事件采取的治疗，如果有的话；cf_5591：事件描述；


    //定义好文件上传路径、名称
    $customform25_no = $focus->column_fields['customform25_no'];
    $pss_number = $focus->column_fields['cf_5525'];
//pms/pv/单号/年月日/时间戳/服务提供商分配的病例编号.pdf
//$aws_path = globalStatic::$root_directory."pms/pv/".$customform25_no."/".date("Ymd")."/";
    $aws_path = "pms/pv/".$customform25_no."/".date("Ymd")."/";
    $time = time();
    $aws_path = $aws_path.$time."/";
//    mkdir($aws_path, 0777, true); //不保存在本地，无需创建文件夹，当时是本地测试用的
    $xml_file_name = $customform25_no.".xml";
    $xml_file_path = $aws_path.$xml_file_name;

    if (!empty($pss_number)) {
        $pdf_file_name = $pss_number."_initial_source_document_CNEN.pdf";
    }else{
        $pdf_file_name = $customform25_no."-PDF.pdf";
    }
    $pdf_file_path = $aws_path.$pdf_file_name;


//    一、创建PDF
    // 创建 mPDF 对象
    require_once (globalStatic::$root_directory.'include/mpdf/8.0/autoload.php');
    error_reporting(E_ALL^E_NOTICE^E_WARNING);
    ini_set("display_errors", 0);//上线时应设为 0
    $mpdf_config = [
        'mode' => 'zh-CN',
        // "allowCJKoverflow" => true,
        "autoScriptToLang" => true,
        // "allow_charset_conversion" => false,
        "autoLangToFont" => true,
    ];
    $mpdf = new \Mpdf\Mpdf($mpdf_config);

    $pdffile_path = globalStatic::$root_directory.'baxter/PDFTemplate.html';
    // 加载 示例HTML 文件
    if (file_exists($pdffile_path) && is_readable($pdffile_path) && (filesize($pdffile_path) > 0)) {
        $html = file_get_contents($pdffile_path);
    }else{
        ConvertTojsonString(-1,$arr,'请检查生成pdf的示例文件/baxter/PDFTemplate.html');
    }

    // 创建 DOMDocument 对象
    $dom = new DOMDocument();
    $dom->loadHTML($html);
    // 将 HTML 转换为 PDF
    //第一种 设置值的方式
//    $dom->getElementById('name')->nodeValue='John Doe';//span等text()标签
    //第二种
//    $dom->getElementById('img1')->setAttribute('src', 'https://example.com/avatar.jpg');//img标签
//    $dom->getElementById('email')->setAttribute('value', 'johndoe@example.com');//input标签
    //第三种
    /*$xpath = new DOMXPath($dom);
    $my_address = $xpath->query('//span[@name="address"]')->item(0)->nodeValue='123 Main St, Anytown USA';*/


    //将数据库中的空日期替换掉(0000-00-00)
    $focus->column_fields['cf_5526'] = str_replace('0000-00-00', '', $focus->column_fields['cf_5526']);
    $focus->column_fields['cf_5522'] = str_replace('0000-00-00', '', $focus->column_fields['cf_5522']);
    $focus->column_fields['cf_5593'] = str_replace('0000-00-00', '', $focus->column_fields['cf_5593']);
    $focus->column_fields['cf_5600'] = str_replace('0000-00-00', '', $focus->column_fields['cf_5600']);
    //20230407 BUG0064341
    $focus->column_fields['cf_5559'] = str_replace('0000-00-00', '', $focus->column_fields['cf_5559']);
    $focus->column_fields['cf_5594'] = str_replace('0000-00-00', '', $focus->column_fields['cf_5594']);
    $focus->column_fields['cf_5599'] = str_replace('0000-00-00', '', $focus->column_fields['cf_5599']);
    $focus->column_fields['cf_5571'] = str_replace('0000-00-00', '', $focus->column_fields['cf_5571']);
    $focus->column_fields['cf_5572'] = str_replace('0000-00-00', '', $focus->column_fields['cf_5572']);
    $focus->column_fields['cf_5517'] = str_replace('0000-00-00', '', $focus->column_fields['cf_5517']);
    $focus->column_fields['cf_5522'] = str_replace('0000-00-00', '', $focus->column_fields['cf_5522']);
    $focus->column_fields['cf_5521'] = str_replace('0000-00-00', '', $focus->column_fields['cf_5521']);
    $focus->column_fields['cf_5526'] = str_replace('0000-00-00', '', $focus->column_fields['cf_5526']);
    $focus->column_fields['cf_5554'] = str_replace('0000-00-00', '', $focus->column_fields['cf_5554']);

    //中文版 单据头字段
    $Pending_main_arr_zh = array('cf_5512','cf_5514','cf_5515','cf_5517','cf_5519','cf_5521','customform25_no','cf_5529','cf_5532','cf_5534','cf_5552','cf_5556','cf_5558','cf_5565','cf_5569','cf_5571','cf_6426','cf_5579','cf_5581','cf_5583','cf_5585','cf_5587','cf_5589','cf_6772','cf_6424','cf_5593','cf_5601','cf_5591','cf_5599','cf_6428','cf_5554');
    foreach ($Pending_main_arr_zh as $columnname){
        $dom->getElementById($columnname)->nodeValue=isset($focus->column_fields[$columnname])?$focus->column_fields[$columnname]:'';
    }

    //英文版 单据头字段
    $Pending_main_arr_en = array('cf_5516','cf_5518','cf_5520','cf_5522','cf_5524','cf_5526','cf_6544','cf_5535','cf_5536','cf_5539','cf_6847','cf_5554','cf_5559','cf_5560','cf_5561','cf_5566','cf_5570','cf_5572','cf_6427','cf_5580','cf_5582','cf_5584','cf_5586','cf_5588','cf_5590','cf_6429','cf_5600','cf_5644','cf_5594','cf_5602','cf_5592','cf_5557');
    foreach ($Pending_main_arr_en as $columnname){
        $dom->getElementById($columnname)->nodeValue=isset($focus->column_fields[$columnname])?$focus->column_fields[$columnname]:'';
    }

    //TODO 分录
//sf439：产品名称；sf440：怀疑药物适应症；sf446：是否为Baxter产品；sf445：剂量；sf441：给药途径；sf444：用药频率；sf442：给药日期；sf458：批号；sf443：国家药品编码；
//sf447：Product Name；sf452：Suspect Drug Indication；sf459：Baxter Product；sf449：Dose；sf451：Route；sf450：Frequency；sf448：Date of administration；sf453：Lot#(s)；sf454：NDC#(s)；
    $Pending_detail_arr_zh = array('sf439','sf440','sf446','sf445','sf441','sf444','sf442','sf458','sf443');
    $Pending_detail_arr_en = array('sf447','sf452','sf459','sf449','sf451','sf450','sf448','sf453','sf454');
    $query = "select ld_customform25detail.lineitem_id,ld_customform25detailscf.sf439,ld_customform25detailscf.sf440,ld_customform25detailscf.sf446,ld_customform25detailscf.sf445,ld_customform25detailscf.sf441,ld_customform25detailscf.sf444,IF(ld_customform25detailscf.sf442='0000-00-00', '', ld_customform25detailscf.sf442) AS sf442,ld_customform25detailscf.sf458,ld_customform25detailscf.sf443,
 ld_customform25detailscf.sf447,ld_customform25detailscf.sf452,ld_customform25detailscf.sf459,ld_customform25detailscf.sf449,ld_customform25detailscf.sf451,ld_customform25detailscf.sf450,IF(ld_customform25detailscf.sf448='0000-00-00', '', ld_customform25detailscf.sf448) AS sf448,ld_customform25detailscf.sf453,ld_customform25detailscf.sf454
FROM ld_customform25 left join ld_customform25detail on ld_customform25detail.id = ld_customform25.customform25id left join ld_customform25detailscf on ld_customform25detailscf.lineitem_id = ld_customform25detail.lineitem_id WHERE ld_customform25detail.id=?";//1760388
    $result = $adb->pquery($query, array($focus->id));
    $num_rows = $adb->num_rows($result);
    $newTbody_zh = $newTbody_en = '';
    if ($num_rows > 0) {
        for($i=0;$i<$num_rows;$i++){
            $newTbody_zh.='<tr>';
            $newTbody_en.='<tr>';
            foreach ($Pending_detail_arr_zh as $columnname) {
                if($columnname == 'sf446') continue;
                $newTbody_zh.='
        <td valign="center" colspan="1" rowspan="1" style="word-break: break-all; border-width: 1px; border-style: solid; border-color: rgb(238, 236, 225);" width="87">
            <span style="white-space: normal; background-color: rgb(255, 255, 255); font-family: arial, helvetica, sans-serif; font-size: 10px; color: rgb(0, 0, 0);" name="'.$columnname.'" id="'.$columnname.'">'.$adb->query_result($result,$i,$columnname).'</span>
        </td>';
            }
            foreach ($Pending_detail_arr_en as $columnname) {
                if($columnname == 'sf459') continue;
                $newTbody_en.='
        <td valign="center" colspan="1" rowspan="1" style="word-break: break-all; border-width: 1px; border-style: solid; border-color: rgb(238, 236, 225);" width="87">
            <span style="white-space: normal; background-color: rgb(255, 255, 255); font-family: arial, helvetica, sans-serif; font-size: 10px; color: rgb(0, 0, 0);" name="'.$columnname.'" id="'.$columnname.'">'.$adb->query_result($result,$i,$columnname).'</span>
        </td>';
            }
            $newTbody_zh.='</tr>';
            $newTbody_en.='</tr>';
        }
    }

    // 创建DOMXPath对象
    $xpath = new DOMXPath($dom);
    // 查找tbody元素
    $tbody_zh = $xpath->query("//tbody[@id='entry_tbody_container_zh']")->item(0);
//    $tbody_zh = $dom->getElementById('entry_tbody_container_zh');
//    $newTbody_zh = "<tr><td>New Row</td></tr>";
    $fragment = $dom->createDocumentFragment();//创建空片段
    $fragment->appendXML($newTbody_zh);//解析成html
    $tbody_zh->nodeValue = "";// 将tbody的HTML内容替换为新的HTML
    $tbody_zh->appendChild($fragment);

//    $tbody_en = $xpath->query("//tbody[@id='entry_tbody_container_en']")->item(0);
    $tbody_en = $dom->getElementById('entry_tbody_container_en');
    $fragment = $dom->createDocumentFragment();
    $fragment->appendXML($newTbody_en);
    $tbody_en->nodeValue = "";
    $tbody_en->appendChild($fragment);
//dump($dom->saveHTML());

    $mpdf->WriteHTML($dom->saveHTML());


    // 输出 PDF 文件
    $cloud_path = $aws->uploadFile($pdf_file_path,$mpdf->Output('', 'S'));//S表示作为字符串输出

    if (!empty($cloud_path)) {
        $adb->pquery('INSERT INTO ld_baxterfilelog(title,file_name,file_type,file_path,cloud_path,crmid,creator) VALUES(?,?,?,?,?,?,?);',array(pathinfo($pdf_file_name, PATHINFO_FILENAME),$pdf_file_name,'pdf',$aws_path,$cloud_path,$focus->id,$current_user->id));
    } else {
        ConvertTojsonString(-1,array($cloud_path),"Aws S3,上传pdf文件失败！");
    }

    // 使用 mPDF 内置的 HTML 解析器解析 HTML 内容
//    $mpdf->WriteHTML($dom->saveHTML());

//    $mpdf->Output($pdf_file_path, 'F');//F：将 PDF 文件保存到指定路径下的文件中;D：将 PDF 文件作为下载，即提示用户下载 PDF 文件;I：在浏览器中打开 PDF 文件，用于在 Web 界面中显示 PDF。


//    二、创建XML
    $xmlfile_path = globalStatic::$root_directory.'baxter/XMLTemplate.xml';
    // 加载 示例HTML 文件
    if (file_exists($xmlfile_path) && is_readable($xmlfile_path) && (filesize($xmlfile_path) > 0)) {
        $xml = file_get_contents($xmlfile_path);
    }else{
        ConvertTojsonString(-1,array(),'请检查生成xml的示例文件/baxter/XMLTemplate.xml');
    }

    $cf_6544 = isset($focus->column_fields['cf_6544'])?$focus->column_fields['cf_6544']:'';//不良事件编号字段为 Case Number assigned by Service Provider
    $safetyreportid = strlen($cf_6544)>3?"CN-JiaLiang-PSP".substr($focus->column_fields['cf_6544'], 3):'';//CN-JiaLiang-{!CasNumber}  //CasNumber为Case Number assigned by Service Provider（cf_6544）字段值去掉前三位

    $receivedate = '';
    $cf_5528 = isset($focus->column_fields['cf_5528'])?$focus->column_fields['cf_5528']:'';//IsFollowUp
    $cf_5525 = isset($focus->column_fields['cf_5522'])?$focus->column_fields['cf_5522']:'';
    $cf_5526 = !empty($focus->column_fields['cf_5526'])?date("Ymd", strtotime($focus->column_fields['cf_5526'])):''; // 取不良事件登记表对象上的Date transferred to Baxter Pharmacovigil（cf_5526）字段
    $cf_5522 = !empty($focus->column_fields['cf_5522'])?date("Ymd", strtotime($focus->column_fields['cf_5522'])):''; // 取记录上的Date reported to Service Provider（PMO_Date_reported_to_Service_Provider_en__c）字段,(服务提供商最初接到报告的日期)
    $cf_5531 = !empty($focus->column_fields['cf_5531'])?$focus->column_fields['cf_5531']:'';
    $cf_5533 = !empty($focus->column_fields['cf_5533'])?$focus->column_fields['cf_5533']:'';

    $cf_5539 = isset($focus->column_fields['cf_5539'])?$focus->column_fields['cf_5539']:'';// 记录Reporter Type（cf_5539）字段值为‘Physician’或者‘Healthcare Professional’为1，Reporter Type字段值为‘Pharmacist’为2，Reporter Type字段值为‘Other Health Professional’为3，Reporter Type字段值为‘Lawyer’为4，Reporter Type字段值为‘Consumer or other non health professional’或者 ‘Other(relative)’或者‘Consumer(patient)’或者‘Baxter Representative’为5，-->
    $cf_6545 = isset($focus->column_fields['cf_6545'])?$focus->column_fields['cf_6545']:''; // 记录上的Initials（cf_6545）字段值
    $cf_6427 = isset($focus->column_fields['cf_6427'])?$focus->column_fields['cf_6427']:''; // 记录上的Age（cf_6427）字段
    $cf_5570 = $focus->column_fields['cf_5570'];// 如果Gender（cf_5570）=‘Female’则为2否则为1 Male
    $cf_5570 = ($cf_5570 == "Female") ? '2' : '1';//Male
    $cf_5644 = isset($focus->column_fields['cf_5644'])?$focus->column_fields['cf_5644']:''; // 记录的Adverse Event（cf_5644）字段值
    $cf_5593 = !empty($focus->column_fields['cf_5593'])?date("Ymd", strtotime($focus->column_fields['cf_5593'])):''; // 事件初发日期（cf_5593）字段值
    $reactionstartdateformat = empty($cf_5593)?'':'102';

    /*$cf_6546 = $focus->column_fields['cf_6546']; // Event Resolved?（cf_6546）=yes则为1，Event Resolved?=no则为3，其他则为6
    $cf_6546 = ($cf_6546 == 'yes') ? 1 : (($cf_6546 == 'no') ? 3 : 6);*/
    $cf_6429 = strtolower($focus->column_fields['cf_6429']);//20230327 BUG0063602  取值改变
    $tmp_cf_6429 = ($cf_6429 == 'recovered') ? 1 : (($cf_6429 == "recovering") ? 2 : (($cf_6429 == "not recovered") ? 3 : (($cf_6429 == "recovered with sequela") ? 4 : (($cf_6429 == 'fatal') ? 5 : (($cf_6429 == 'unknown') ? 6 : '' )))));

    //相同reaction标签的判断
    $cf_6547 = isset($focus->column_fields['cf_6547'])?$focus->column_fields['cf_6547']:'';//Adverse Event2（cf_6547）不为空，为空则没有
    $cf_6548 = isset($focus->column_fields['cf_6548'])?$focus->column_fields['cf_6548']:'';//Adverse Event3（cf_6548）不为空，为空则没有

    //summary  cf_5592
    $cf_5592 = isset($focus->column_fields['cf_5592'])?$focus->column_fields['cf_5592']:''; // 记录上的Event Description(verbatim)（cf_5592）字段的值


    //开始给xml标签赋值
    $xml = str_replace('{!cf_6544}', $cf_6544, $xml);//不良事件编号字段为Case Number assigned by Service Provider
    $xml = str_replace('{!messagedateformat}', date("YmdHis"), $xml);//生成xml的时间
    $xml = str_replace('{!safetyreportid}', $safetyreportid, $xml);
    $xml = str_replace('{!cf_5526}', $cf_5526, $xml);
    /*if ($cf_5528 == '1') {
        $receivedate = $cf_5522;
    }else{
        $tmp_sql = "SELECT cf_5522 FROM ld_customform25 LEFT JOIN ld_customform25scf ON ld_customform25scf.customform25id = ld_customform25.customform25id
WHERE ld_customform25.deleted = 0 AND cf_5525 = ? and cf_6715 = 'PSR收集不良事件' ORDER BY modifiedtime DESC LIMIT 1";
        $tmp_result= $adb->pquery($tmp_sql, array($cf_5525));//{当前页面PSS Number的值}
        if ($adb->num_rows($tmp_result) > 0) {
            $receivedate = $adb->query_result($tmp_result,0,'cf_5522');
        }
    }*/
    $xml = str_replace('{!receivedate}', $cf_5522, $xml);//20230317 需求变更,不再根据cf_5528取值

    $xml = str_replace('{!cf_5522}', $cf_5522, $xml);//取记录上的Date reported to Service Provider（cf_5522）字段
    $xml = str_replace('{!cf_5531}', $cf_5531, $xml);
    $xml = str_replace('{!cf_5533}', $cf_5533, $xml);
    $tmp_cf_5539 = (in_array($cf_5539,array('Physician','Healthcare Professional'))) ? 1 : (($cf_5539 == "Pharmacist") ? 2 : (($cf_5539 == "Other Health Professional") ? 3 : (($cf_5539 == "Lawyer") ? 4 : (in_array($cf_5539,array('Consumer or other non health professional','Other(relative)','Consumer(patient)','Baxter Representative')) ? 5 : 0 ))));
    $xml = str_replace('{!cf_5539}', $tmp_cf_5539, $xml);

    $xml = str_replace('{!cf_6545}', $cf_6545, $xml);
    $xml = str_replace('{!cf_6427}', $cf_6427, $xml);

    $tmp_patientonsetageunit = ($cf_6427 == "") ? "" : "801";// Age（cf_6427）
    $xml = str_replace('{!patientonsetageunit}', $tmp_patientonsetageunit, $xml);

    $xml = str_replace('{!cf_5570}', $cf_5570, $xml);
    $xml = str_replace('{!cf_5644}', $cf_5644, $xml);
    $xml = str_replace('{!reactionstartdateformat}', $reactionstartdateformat, $xml);
    $xml = str_replace('{!reactionstartdate}', $cf_5593, $xml);
    $xml = str_replace('{!cf_6429}', $tmp_cf_6429, $xml);


    //相同标签部分
    //Adverse Event2（cf_6547）不为空，为空则没有
    if ($cf_6547 == '') {
        $xml = str_replace('{!reaction2}', '', $xml);
    }else{
        $tmp_reaction2 = '<reaction><primarysourcereaction lang="en">'.$cf_6547.'</primarysourcereaction><reactionstartdateformat>'.$reactionstartdateformat.'</reactionstartdateformat><reactionstartdate>'.$cf_5593.'</reactionstartdate><reactionoutcome>'.$tmp_cf_6429.'</reactionoutcome></reaction>';
        $xml = str_replace('{!reaction2}', $tmp_reaction2, $xml);
    }
    //Adverse Event3（cf_6548）不为空，为空则没有
    if ($cf_6548 == '') {
        $xml = str_replace('{!reaction3}', '', $xml);
    }else{
        $tmp_reaction3 = '<reaction><primarysourcereaction lang="en">'.$cf_6548.'</primarysourcereaction><reactionstartdateformat>'.$reactionstartdateformat.'</reactionstartdateformat><reactionstartdate>'.$cf_5593.'</reactionstartdate><reactionoutcome>'.$tmp_cf_6429.'</reactionoutcome></reaction>';
        $xml = str_replace('{!reaction3}', $tmp_reaction3, $xml);
    }

    //Drug
    $drugEntry = '';
    if ($num_rows > 0) {
        for($i=0;$i<$num_rows;$i++){
            $sf447 = $adb->query_result($result,$i,'sf447');
            $sf453 = $adb->query_result($result,$i,'sf453');
            //20230331 BUG0063955 取值变更
            $sf451 = strtolower($adb->query_result($result,$i,'sf451'));
            $sf451 = ($sf451 == 'intraperitoneal') ? '033' : (($sf451 == "intravenous (not otherwise specified)") ? '042' : (($sf451 == "subcutaneous") ? '058' : (($sf451 == "unknown") ? '065' : '')));
            $sf448 = $adb->query_result($result,$i,'sf448');
            $sf448 = str_replace('0000-00-00', '', $sf448);
            $sf448 = !empty($sf448)?date("Ymd", strtotime($sf448)):'';
            $sf443 = $adb->query_result($result,$i,'sf443');
            $sf446 = $adb->query_result($result,$i,'sf446');

            $drugEntry .= "<drug><drugcharacterization>1</drugcharacterization><medicinalproduct>".$sf447."</medicinalproduct><drugbatchnumb>".$sf453."</drugbatchnumb><drugadministrationroute>".$sf451."</drugadministrationroute><drugstartdateformat>102</drugstartdateformat><drugstartdate>".$sf448."</drugstartdate><drugreactionrelatedness><drugreactionasses>".$sf443."</drugreactionasses><drugassessmentsource>".$sf446."</drugassessmentsource></drugreactionrelatedness></drug>";

        }
        $xml = str_replace('{!drug}', $drugEntry, $xml);

    }
    $xml = str_replace('{!cf_5592}', $cf_5592, $xml);

//    file_put_contents(globalStatic::$root_directory.'baxter/test.xml',$xml);

    $cloud_path = $aws->uploadFile($xml_file_path,$xml);


    if (!empty($cloud_path)) {
        $adb->pquery('INSERT INTO ld_baxterfilelog(title,file_name,file_type,file_path,cloud_path,crmid,creator) VALUES(?,?,?,?,?,?,?);',array(pathinfo($xml_file_name, PATHINFO_FILENAME),$xml_file_name,'xml',$aws_path,$cloud_path,$focus->id,$current_user->id));
    } else {
        ConvertTojsonString(-1,array($cloud_path),"Aws S3,上传xml文件失败！");
    }


    /*$xml->safetyreport->patient->summary = $cf_5592;*/
//    file_put_contents(globalStatic::$root_directory.'baxter/'.$rand.'_create.xml',$doc->saveXML());
//    $doc->save(globalStatic::$root_directory.'baxter/'.$rand.'_create.xml');

    ConvertTojsonString(1,$arr,'success');
}
elseif($mode=='download'){//查看下载相应的文件
    $fileid = $_REQUEST['fileid'];
    if(empty($fileid)) exit('缺少参数fileid');
    $sql = "select * from ld_baxterfilelog where fileid = ?";
    $result = $adb->pquery($sql,array($fileid));
    if($adb->num_rows($result) > 0){
        $title = $adb->query_result($result,0,'title');
        $file_name = $adb->query_result($result,0,'file_name');
        $file_path = $adb->query_result($result,0,'file_path');
        $s3FilePath = $file_path.$file_name;
        @ob_clean();
        @ob_start();
        $response = $aws->outputFile($s3FilePath,$title);

        if (!empty($response['Body'])) {
            header('Content-Type: application/octet-stream');
            header('Content-Disposition: attachment; filename="' . $file_name . '"');
            echo $response['Body'];
            @ob_end_flush();
            exit;
        }else{
            exit("暂时无法下载查看");
        }
    }else{
        exit("未找到相关记录，文件可能已删除");
    }

    /*//模拟下载
    $fileName = 'PSP5178561099150-XML.xml';
    $localFilePath = 'baxter/pms/pv/PSP5178561099150/20230227/1677490715/' . $fileName;
    header('Content-Type: application/octet-stream');
    header('Content-Disposition: attachment; filename="' . $fileName . '"');
    header('Content-Length: ' . filesize($localFilePath));
    readfile($localFilePath);
    exit;*/
}
elseif($mode=='delete'){//删除相应的文件
    $fileid = $_REQUEST['fileid'];
    if(empty($fileid)) ConvertTojsonString(-1,$_REQUEST,"删除失败，缺少参数fileid");
    $sql = "select * from ld_baxterfilelog where fileid = ?";
    $result = $adb->pquery($sql,array($fileid));
    if($adb->num_rows($result) > 0){
        $file_name = $adb->query_result($result,0,'file_name');
        $file_path = $adb->query_result($result,0,'file_path');
        $s3FilePath = $file_path.$file_name;
        //删除aws上的文件
        $aws->deleteFile($s3FilePath);
        //删除数据库记录
        $adb->pquery("delete from ld_baxterfilelog where fileid = ?",array($fileid));
        ConvertTojsonString(1,$_REQUEST,"success");
    }else{
        ConvertTojsonString(-1,$_REQUEST,"文件已删除");
    }
}

ConvertTojsonString(-1,$_REQUEST,"fail");
?>