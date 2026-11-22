<?php


class CardSettingsWX
{
    function __construct()
    {
    }
    
    public function getcardData(){
        global $adb,$root_directory;
        $image_path = "storage/CardSettings/CardInfo/";
        
        $result = $adb->pquery("select * from ld_card_info", array());
        $background = $adb->query_result($result, 0, 'background');
        $avatar = $adb->query_result($result, 0, 'avatar');
        //上传图片丢失或损坏时显示预置图片
        $avatar = $image_path.$avatar;
        $background = $image_path.$background;
        if(!file_exists($root_directory.$avatar)||!@getimagesize($root_directory.$avatar)){
            $avatar = 'themes/images/defaultuser.png';
        }
        if(!file_exists($root_directory.$background)||!@getimagesize($root_directory.$background)){
            $background = 'https://weixin-1255564871.cos.ap-shanghai.myqcloud.com/web_51mis/mob827/backgroung_card.jpg';
        }
        $data = array(
            "background" => $background,
            "avatar" => $avatar,
            "display_level" => $adb->query_result($result, 0, 'display_level'),//职称
            "display_company_name" => $adb->query_result($result, 0, 'display_company_name'),
            "display_phone_mobile" => $adb->query_result($result, 0, 'display_phone_mobile'),
            "display_email" => $adb->query_result($result, 0, 'display_email'),
            "display_company_phone" => $adb->query_result($result, 0, 'display_company_phone'),
            "display_company_address" => $adb->query_result($result, 0, 'display_company_address'),
        );

        return $data;
    }
    
    public function getaboutData()
    {
        global $adb,$root_directory;
        $image_path="storage/CardSettings/CompanyProfile/";
        crm_load_class_file('cls_CardInfoSettings',"modules/CardSettings");
        $cardinfoobj = new cls_CardInfoSettings();
        $organizationinfo = $cardinfoobj->getOrganizationInfo();
        $title = $organizationinfo['brief_title'];
        $brief = $organizationinfo['brief'];
        $image_main = $organizationinfo['image_main'];
        $video_cover= $organizationinfo['video_cover'];
        $video_link = $organizationinfo['video_link'];
        $data = array();
        $data['title'] = $title;
        $data['list'] = $brief;
        if(!empty($image_main))
        {
            $image_main = $image_path.$image_main;
            if(!file_exists($root_directory.$image_main)||!@getimagesize($root_directory.$image_main)){
                
            }
            else{
                $data['image_main'] = $image_main;
            }
        }
        if(!empty($video_link))
        {
            $data['video_link'] = $video_link;
            if(!empty($video_cover))
            {
                $video_cover = $image_path.$video_cover;
                if(!file_exists($root_directory.$video_cover)||!@getimagesize($root_directory.$video_cover)){
                    
                }
                else{
                    $data['video_cover'] = $video_cover;
                }
            }
        }
        
        return $data;
        
    }
    public function getmarketingData()
    {
        global $adb,$root_directory;
        $image_path="storage/CardSettings/Marketing/";
        crm_load_class_file('cls_MarketingSettings',"modules/CardSettings");
        $marketingobj = new cls_MarketingSettings();
        $marketinginfos = $marketingobj->getMarketingInfo();
        
        $data = array();
        foreach($marketinginfos as $marketinginfo)
        {
            $presence = $marketinginfo['presence'];
            if($presence != 'yes'){
                continue;
            }
            $btn_image = $marketinginfo['btn_image'];
            $imagepath = $root_directory.$image_path.$btn_image;
            $btn_name = $marketinginfo['btn_name'];
            if(empty($btn_image)||!file_exists($imagepath)||!@getimagesize($imagepath))
            {
                if ($btn_name == 'linkus'){
                    $btn_image ="http://www.71mis.cn/wx_images/cloud/contact.png";
                }
                else if($btn_name == 'shardchard'){
                    $btn_image = "http://www.71mis.cn/wx_images/cloud/share.png";
                }
                else if($btn_name == 'experience'){
                    $btn_image = "http://www.71mis.cn/wx_images/cloud/home_kefu_2021_8_31.png";
                }
                else if($btn_name == 'addwechat'){
                    $btn_image = "http://www.71mis.cn/wx_images/cloud/weixin.png";
                }
            }
            else{
                $btn_image = $image_path.$btn_image;
            }
            $btn_label = $marketinginfo['btn_label'];
            $link_url = $marketinginfo['link_url'];
            $maketdata = array(
                'label'=>$btn_label,
                'btn_name'=>$btn_name,
                'btn_image'=>$btn_image,
            );
            if($btn_name == 'experience'){
                $maketdata['link_url'] = $link_url;
            }
            $data[] = $maketdata;
        }
        return $data;
    }
    
    public function getTopicBlckDate()
    {
        global $adb;
        $image_path="storage/CardSettings/TopicBlockSettings/";
        crm_load_class_file('cls_TopicBlockSettings','modules\CardSettings');
        $topicblockobj = new cls_TopicBlockSettings();
        $topicblockinfos = $topicblockobj->getTopicLists();
        
        $topicdata = array();
        foreach($topicblockinfos as $key=>$topicblockinfo)
        {
            $topicid = $topicblockinfo['topicid'];
            $topicname = $topicblockinfo['topicname'];
            $titleinfo = $topicblockobj->getTopicTitleinfo($topicid);
            $blockinfos = $topicblockobj->getTopicBlockLists($topicid);
            $title = $titleinfo['titlename'];
            $minititle = $titleinfo['minititle'];
            if(empty($topicname)||empty($blockinfos)){
                continue;
            }
            $list = array();
            foreach($blockinfos as $key=>$blockinfo)
            {
                $name = $blockinfo['blockname'];
                $content = $blockinfo['blockcontent'];
                $image = $blockinfo['blockimageurl'];
                
                if($topicname == 'functionData')//产品功能点无content
                {
                    $list[] = array(
                            'name'=>$name,
                            'image'=>$image
                        );
                }
                else
                {
                    $list[] = array(
                            'name'=>$name,
                            'content'=>$content,
                            'image'=>$image
                    );
                }
            }
            $data= array(
                        'title'=>$title,
                        'minititle'=>$minititle,
                        'list'=>$list
                    );
            if($topicname == 'productData')
            {
                $producttype = array();
                $titleimagelist = $topicblockobj->getTopicTitleimagelists($topicid);
                foreach($titleimagelist as $titleimageinfo )
                {
                    $producttype[] = $image_path.$titleimageinfo['titleimagename'];
                }
                $data['producttype'] = $producttype;
            }
            $topicdata[$topicname] = $data;
            
        }
        return $topicdata;
    }
}
?>