<?php
/*
{*修改编码格式:统一编码：UTF-8*}
*/ 
/** YOUR LICENSE TEXT HERE **/
class RecycleBinHandler extends VTEventHandler {

	function handleEvent($eventName, $data) {

		if($eventName == 'lingdang.entity.beforesave') {
			// Entity is about to be saved, take required action
		}

		if($eventName == 'lingdang.entity.aftersave') {
			// Entity has been saved, take next action
		}
	}
}

?>