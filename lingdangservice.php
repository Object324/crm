<?php
/*+*******************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ********************************************************************************/
 
if(isset($_REQUEST['service']))
{
	if($_REQUEST['service'] == "outlook")
	{
		include("soap/lingdangolservice.php");
	}
	elseif($_REQUEST['service'] == "customerportal")
	{
		include("soap/customerportal.php");
	}
	elseif($_REQUEST['service'] == "webforms")
	{
		include("soap/webforms.php");
	}
	elseif($_REQUEST['service'] == "firefox")
	{
		include("soap/firefoxtoolbar.php");
	}
	elseif($_REQUEST['service'] == "wordplugin")
	{
		include("soap/wordplugin.php");
	}
	elseif($_REQUEST['service'] == "thunderbird")
	{
		include("soap/thunderbirdplugin.php");
	}
	else
	{
		echo "No Service Configured for ". strip_tags($_REQUEST[service]);
	}
}
else
{
	echo "<h1>lingdangCRM Soap Services</h1>";
	echo "<li>lingdangCRM Outlook Plugin EndPoint URL -- Click <a href='lingdangservice.php?service=outlook'>here</a></li>";
	echo "<li>lingdangCRM Word Plugin EndPoint URL -- Click <a href='lingdangservice.php?service=wordplugin'>here</a></li>";
	echo "<li>lingdangCRM ThunderBird Extenstion EndPoint URL -- Click <a href='lingdangservice.php?service=thunderbird'>here</a></li>";
	echo "<li>lingdangCRM Customer Portal EndPoint URL -- Click <a href='lingdangservice.php?service=customerportal'>here</a></li>";
	echo "<li>lingdangCRM WebForm EndPoint URL -- Click <a href='lingdangservice.php?service=webforms'>here</a></li>";
	echo "<li>lingdangCRM FireFox Extension EndPoint URL -- Click <a href='lingdangservice.php?service=firefox'>here</a></li>";
}


?>