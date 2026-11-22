<?php

class cls_workreportshow
{

    public $workreprottype = array(
        'weibo' => 'BLOG',//getFixedLabel('BLOG')
        'dayreport' => 'JOURNAL',
        'weekreport' => 'WEEKPLAN',
        'monthreport' => 'MONTHPLAN',
        'cocmd' => 'TASK'
    );
     //获取所有的工作汇报
    public function getAllWorkReportType()
    {
        global $adb;
        $sql="select * from ld_workreport_showset  where belongtype ='blog' order by sequence asc ";
        $result=$adb->pquery($sql,array());
        $rows=$adb->num_rows($result);
        for($i=0;$i<$rows;$i++)
        {
            $reportshow=$adb->query_result($result,$i,'presence');
            $type=$adb->query_result($result,$i,'type');
            $arr[]=array('reportshow'=>$reportshow,'type'=>$type);
        }
        return $arr;
    }
   
    public function getWorkReportShow()
    {
        global $adb;
        $allworkreport=$this->getAllWorkReportType();
        foreach($allworkreport as $index=>$content)
        {
            if($content['reportshow']=='yes')
                $tmp[]=$content;
        }
        return $tmp;
    }

    //@edit:liushuai,2020-07-28,reason:ID1000926/工作汇报设置弹出层界面优化，增加“类别设置”和“文字描述设置”区块标签，文字描述可修改
    public function saveWorkReportText()
    {
        global $current_user,$adb;
        $fieldlabel=$_REQUEST['fieldlabel'];
        $labelbol=$_REQUEST['labelbol'];
        $_REQUEST['diony']='diony';
        $languageType= getLanguageType($current_user);//en  zh

        $update="update ld_desk set fieldlabel=? where labelbol=? and Labeltype='fixedstr' and languagetype=?";
        $adb->pquery($update,array($fieldlabel,$labelbol,$languageType));
        if(function_exists("opcache_invalidate")){
            opcache_invalidate(globalStatic::$root_directory.'include/language/zh.php',true);
            opcache_invalidate(globalStatic::$root_directory.'include/language/en.php',true);
        }
            
        setFixedLable($current_user);//重新生成语言包
        $arr['fieldlabel'] = $fieldlabel;
        ConvertTojsonString(1,$arr,'success');
    }


    public function saveWorkReportTypeAndShow($datainfo){
        global $current_user, $adb;
        $workreprottype = $this->workreprottype;
        if (!empty($datainfo)){
            foreach ($datainfo as $type => $info){
                $zh_fieldlabel = $info['zh_fieldlabel'];
                $en_fieldlabel = $info['en_fieldlabel'];
                $presence = $info['presence'];
                $labelbol = $workreprottype[$type];
                //启用
                $presence_sql="update ld_workreport_showset set presence=? where type=? and belongtype='blog'";
                $adb->pquery($presence_sql,array($presence,$type));
                //翻译
                $fieldlabel_sql = "update ld_desk set fieldlabel=? where labelbol=? and languagetype=?";
                $adb->pquery($fieldlabel_sql, array($zh_fieldlabel, $labelbol, 'zh'));
                $adb->pquery($fieldlabel_sql, array($en_fieldlabel, $labelbol, 'en'));
            }
            //翻译处理
            if (function_exists("opcache_invalidate")) {
                opcache_invalidate(globalStatic::$root_directory . 'include/language/zh.php', true);
                opcache_invalidate(globalStatic::$root_directory . 'include/language/en.php', true);
            }
            setFixedLable($current_user);//重新生成语言包
        }
        $arr['select_option'] = $this->getSelectOption();
        ConvertTojsonString(1,$arr,'success');

    }

    //获取工作汇报模版设置 下拉框内容
    public function getSelectOption(){
        global $adb;
        $workreprottype = $this->workreprottype;
        $type_arr = array('dayreport'=>'day','weekreport'=>'week','monthreport'=>'month','weibo'=>'weibo','cocmd'=>'cocmd');
        $select_sql = 'select type from ld_workreport_showset where presence = ? and belongtype=?';
        $select_result = $adb->pquery($select_sql,array('yes','blog'));
        $num_row = $adb->num_rows($select_result);
        if ($num_row>0){
            for ($i=0;$i<$num_row;$i++){
                $type = $adb->query_result($select_result,$i,'type');
                $arr[$type_arr[$type]]=getFixedLabel($workreprottype[$type]);
            }
            return $arr;
        }else{
            return '';
        }
    }


}

?>