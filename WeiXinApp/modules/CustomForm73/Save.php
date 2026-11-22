<?php
$mobj = cls_Instance::get_moduleAction_Instance('CustomForm73','Save');
$mobj->setFieldInfoFromPost();//从wx_fieldinfo初始化字段信息
$mobj->common_save();
$mobj->ConvertTojsonStringInSave();
