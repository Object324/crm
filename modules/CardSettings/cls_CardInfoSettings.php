<?php

class cls_CardInfoSettings
{
    function __construct()
    {
    }

    public function getCardInfo(){
        global $adb;
        $result = $adb->pquery("select * from ld_card_info", array());
        $data = array(
            "background" => $adb->query_result($result, 0, 'background'),
            "avatar" => $adb->query_result($result, 0, 'avatar'),
            "display_level" => $adb->query_result($result, 0, 'display_level'),//职称
            "display_company_name" => $adb->query_result($result, 0, 'display_company_name'),
            "display_phone_mobile" => $adb->query_result($result, 0, 'display_phone_mobile'),
            "display_email" => $adb->query_result($result, 0, 'display_email'),
            "display_company_phone" => $adb->query_result($result, 0, 'display_company_phone'),
            "display_company_address" => $adb->query_result($result, 0, 'display_company_address'),
        );

        return $data;
    }

    public function getOrganizationInfo(){
        global $adb;
        //主表信息 查询【公司简介标题brief_title】【主图链接image_main】【视频链接video_link】【视频封面video_cover】
        $sql = "select * from ld_organizationdetails";
        $result = $adb->pquery($sql, array());

        $organization_id = $adb->query_result($result, 0, 'organization_id');
        $data = array(
            "organization_id" => $organization_id,
            "organizationname" => $adb->query_result($result, 0, 'organizationname'),
            "address" => $adb->query_result($result, 0, 'address'),
            "city" => $adb->query_result($result, 0, 'city'),
            "state" => $adb->query_result($result, 0, 'state'),
            "country" => $adb->query_result($result, 0, 'country'),
            "phone" => $adb->query_result($result, 0, 'phone'),

            
            "brief_title" => $adb->query_result($result, 0, 'brief_title'),
            "image_main" => $adb->query_result($result, 0, 'image_main'),
            "video_cover" => $adb->query_result($result, 0, 'video_cover'),
            "video_link" => $adb->query_result($result, 0, 'video_link'),
            "brief" => $adb->query_result($result, 0, 'brief'),
        );

        return $data;
    }





}

?>