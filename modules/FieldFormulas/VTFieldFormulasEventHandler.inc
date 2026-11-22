<?php
/*+*******************************************************************************
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ******************************************************************************/
require 'include.inc';
class VTFieldFormulasEventHandler extends VTEventHandler{
	function handleEvent($name, $data){
		global $adb;
		$moduleName = $data->getModuleName();
		$mem = new VTModuleExpressionsManager($adb);
		$me = $mem->retrieve($moduleName);
		$me->update($data);
	}
}
?>