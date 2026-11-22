<?php
$root_dir=dirname(dirname(__FILE__));//获取根目录
define("ROOT_DIR",$root_dir);
include($root_dir.'/includefile.php');

$dizhi=substr($_SERVER['PHP_SELF'],0,strpos($_SERVER['PHP_SELF'],'CustomReport'));

$related_crmid = 0;
if(isset($_REQUEST['related_crmid'])){
	$related_crmid = $_REQUEST['related_crmid'];
}

//127.0.0.1/crm/CustomReport/createDetailModule.php?modulename=SalesOrder&productid=[{"productid":596,"sf6177":"5颗"}]&productid_str=596
echo "<form style='display:none;' id='form1' name='form1' method='post' action='http://".$_SERVER['HTTP_HOST'].$dizhi."index.php?pageto_module=".$_REQUEST['modulename']."&pageto_action=index&pageto_create=yes&Create=true&frommodule=Customreport'>
              <input name='productdetail_products' type='hidden' value='".$_REQUEST['productid']."'/>
                <input name='page_addurl' type='hidden' value='&productdetail_products=".$_REQUEST['productid']."&product_id=".$_REQUEST['productid_str']."&frommodule=Customreport&related_crmid=".$related_crmid."'/>
            </form>
            <script type='text/javascript'>function load_submit(){document.form1.submit()}load_submit();</script>";

exit();

?>