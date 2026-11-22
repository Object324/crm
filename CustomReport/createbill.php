<?php
$root_dir=dirname(dirname(__FILE__));//获取根目录
define("ROOT_DIR",$root_dir);
include($root_dir.'/includefile.php');

$dizhi=substr($_SERVER['PHP_SELF'],0,strpos($_SERVER['PHP_SELF'],'CustomReport'));

echo "<form style='display:none;' id='form1' name='form1' method='post' action='http://".$_SERVER['HTTP_HOST'].$dizhi."index.php?pageto_module=".$_REQUEST['module']."&pageto_action=index&pageto_create=yes&Create=true&frommodule=ReportAnalysis'>
              <input name='productdetail_products' type='hidden' value='".$_REQUEST['productid']."'/>
                <input name='page_addurl' type='hidden' value='&productdetail_products=".$_REQUEST['productid']."&frommodule=Customreport'/>
            </form>
            <script type='text/javascript'>function load_submit(){document.form1.submit()}load_submit();</script>";
exit();
			
?>





