<?php

$root_dir=dirname( dirname(dirname(__FILE__)));
require_once($root_dir."/config.inc.php");
global $arrCustomForm_arr;
/*for($i=1;$i<=100;$i++)
{
    if($i<10)
    {
        $arrCustomForm_arr[]='CustomForm0'.$i;
    }
    else
    $arrCustomForm_arr[]='CustomForm'.$i;
    
}*/

compilefile($root_directory);

function compilefile($date)
{   global $arrCustomForm_arr;
    if(!is_array($arrCustomForm_arr))
        $arrCustomForm_arr=[];
    $temp=scandir($date);
    $i=1;
        foreach($temp as $v){
                $a=$date.'/'.$v;
                if($v=='SassCompileCode.php')
                    continue;
                
                if($v=='jiangjing_getOverDue_Date.php')
                    continue;
                if($v=='SMSSendSalesOrderGroup.php')
                    continue;
                if($v=='SaveApproveLog1.php')
                continue;
                if($v=='PEAR.php')
                    continue;
                if($v=="SessionInfo.php")
                    continue;
                 if($v=="globalStatic.php")
                    continue;
                 if($v=='PearDatabase.php')
                    continue;
                
                 if($v=='adodb'||$v=='autoload'||$v=='crmcommon'||$v=='cache'||$v=='CallCenter'
                 ||$v=='expansion'||$v=='electronicsignature'||$v=='vtlib'||$v=='weixinnmp'
                 ||$v=='uploaddify'||$v=='360safe'||$v=='chinamap'||$v=='Articles'||$v=='EmailListtmp'
                 ||$v=='XlsImportNew'||$v=='WeChatUser'||$v=='XlsImport'||$v=='ganttView'||$v=='FusionCharts'
                 ||$v=="js"||$v=='mail'||$v=='mpdf'||$v=='taobao'||$v=='ueditor'||$v=='Workflow'||$v=='weixinMsg'||$v=='fpdf'
                 ||$v=='antlr'||$v=='PHPMailer'||$v=='TrackPosition'||$v=='events'||$v=='trade')
                    continue;
                 
                 if($v=='MarketSpread'||$v=='Prdtnums'||$v=='Rate'||$v=='smplugin'||$v=='marketplateform'
                 ||$v=='360safe'||$v=='barcode'||$v=='ckeditor'||$v=='db_backup'||$v=='prototype-1.4.0'||$v=='scriptaculous'
                 ||$v=='jodconverter'||$v=='Navigation'||$v=='RecycleBin'||$v=='SmsPhrases'||$v=='SmsPhrases'||$v=='Announcements'
                 ||$v=='LineHelp'||$v=='CallButler'||$v=='System'||$v=='CashDeposit'||$v=='PublicAnnouncement'
                 ||$v=='PromotionSetting'||$v=='Questionnaire'||$v=='Tooltip'||$v=='ShopSettings'||$v=='CardSettings'
                 ||$v=='ChinaMap'||$v=='DividendOrder'||$v=='SocialPromotion')
                 {
                    continue;
                 }
                if($v=='vendor'||$v=='tencentcloud'||$v=='templatePrintFile'||$v=='storage'||$v=='js'||$v=='app'
                ||$v=='My97DatePicker'||$v=='themes'||$v=='templates_c'||$v=='templates'||$v=='marketplateform'||$v=='PHPExcel'||$v=='recordData'
                ||$v=='autoload'||$v=="Image" ||$v=='guiji'||$v=='dataCache'||$v=='crmapi'||$v=='sql'||$v=='MassSMS'
                ||$v=='nusoap'||$v=='php_writeexcel'||$v=='PutCash'||$v=='LessionPlan'||$v=='FieldFormulas'
                ||$v=='soap'||$v=='sqlparser'||$v=='shoppro'||$v=='minipro'||$v=='user_privileges'||$v=='Emails'
                ||$v=='log4php'||$v=='log4php.debug'||$v=='SMSNotifier'||$v=='language'||$v=='FundNet'||$v=='FundReward'
                ||$v=='FundRewardCommission'||$v=='Mcommission'||$v=='Management'||$v=='MailManager'
                ||$v=='html2pdf'||$v=='Webmails'||$v=='Assets'||$v=='kcfinder'||$v=='thirdparty'
                ||$v=='com_lingdang_workflow'||$v=='WSAPP'||$v=='Yahoo'||$v=='Webforms'||$v=='uploads'||$v=='TimeSheet'
               ||$v=='Reminds'||$v=='ChannelCode'||$v=='Checks'||$v=='BankBranch'||$v=='CommunicationLog'
                ||$v=='Comprehensivereport'||$v=='ModTracker'
                ||$v=='Portal'||$v=='ConfigEditor'||$v=='PBXManager'||$v=='Reports'||$v=='ReportLog'
                ||$v=='InventoryAccount'||$v=='InventoryLedger'||$v=='InventoryQuery'||$v=='lingdangBackup'
              
                ||$v=='Integration'||$v=='Ambassador'||$v=='wechatpay'||$v=='wxaddressbook')
                continue;
       
          if(is_dir($a)){//如果是文件夹则执行
              
                   if($v=='.' || $v=='..'){//判断是否为系统隐藏的文件.和..  如果是则跳过否则就继续往下走，防止无限循环再这里。
                       continue;
                   }
                 if(in_array($v,$arrCustomForm_arr))
                 {
                    
                     continue;
                 }
                 compilefile($a);//因为是文件夹所以再次调用自己这个函数，把这个文件夹下的文件遍历出来
               }else{
                 if(stripos($a,'.php')!==false)
                 {
                    try{
                          @opcache_compile_file($a);
                    }
                    catch(exception $ex)
                    {
                        
                    }
                    finally{
                    }
                  
                 }
                     
               }
              
       
    
    }
}





?>