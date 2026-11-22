<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Tujt 2015-06-02
 */
class AttachmentLogic extends BaseLogic {

    private $thisRowAttachmentInfo; //当前行的附件信息包括 名称路径等等

    public function getListBasicBtn() {
        parent::getListBasicBtn();//调用父类方法
        unset($this->list_buttons['mass_edit']);
        unset($this->list_buttons['Import']);
        //unset($this->list_buttons['Settings']);
    }
    /**
     * 附件模块，更多下拉菜单中只有导出即可
     * @author Tujt 2015-06-02
     */
    public function getListMoreBtn() {
        parent::getListMoreBtn();//调用父类方法
        unset($this->list_buttons['More']['list']['mass_edit']);
        unset($this->list_buttons['More']['list']['Import']);

    }

    /**
     * 获取详情页更多按钮下拉列表对象
     * @author Tujt 2015-06-04
     */
    public function getDetailMoreBtn() {
        parent::getDetailMoreBtn();
        //附件模块，不允许复制，也不需要设置页面
        unset($this->detail_buttons['More']['list']['Copy']);
    }
    /**
     * 关联创建
     * @author Tujt 2015-06-24
     */
    public function setQuickCreateColumn($parent_module,$parent_id) {
        //添加引用单据
        parent::setQuickCreateColumn($parent_module,$parent_id);
        $this->controller->column_fields['reltab'] = $parent_module;
        $this->controller->column_fields['related_to'] = $parent_id;
    }
    public function setQuickCreateColumnValues($curmodule,$recordid,$curcolumn='') {//相关创建附件，选择源单信息未带出
        //添加引用单据
        parent::setQuickCreateColumnValues($curmodule,$recordid);
        if(!empty($recordid)){
            $reltab = getSalesEntityType($recordid);
        }else{
            $reltab = $curmodule;
        }
        $this->controller->column_fields['reltab'] = $reltab;
        $this->controller->column_fields['related_to'] = $recordid;
    }
    public function getallListViewLink() {
        $btn =parent::getallListViewLink();
        global $adb,$current_user;
        $btn['download']['label'] = getFixedLabel('DOWNLOAD');
        $btn['preview']['label'] = getFixedLabel('PREVIEW');
        return $btn;
    }
    /**
     * 初始化列表按钮结果集
     * @author Tujt 2015-06-26
     */
    public function setListViewLink($result,$record,$start,$idx) {
        global $adb,$current_user;
        $module = $this->controller->module_name;
        $id = $adb->query_result($result,$idx,'id');
        //$record = $record . ','.$id;
        // @edit:dong @date:2020/08/03 @reason: bug0042251 获取当前行的附件信息
        $this->setThisRowAttachmentInfo($id,$record);
        $attachmentInfo=$this->thisRowAttachmentInfo;
        //edit: xll 2024/07/16 XUQIU20240628-14 附件字段增加下载预览权限的单据条件控制
        $focus = CRMEntity::getInstance($module);
        $fieldInfo = $focus->fieldobj->getFieldInfoobjBykey('columnname','filename');
        $fieldInfo->setFileAllowed($module,$record);
        $fileAllowed = $fieldInfo->getFileAllowed($record);

        parent::setListViewLink($result,$record,$start,$idx);
        unset($this->listview_link['download']);
        unset($this->listview_link['preview']);
        if(IsDownLoadProfile($record,$module)=='yes' && $fileAllowed['Download'] === 'yes'){
            $btn = array();
            $btn['download']['label'] = getFixedLabel('DOWNLOAD');
            $btn['download']['permit'] = 'yes';
            $btn['download']['click'] = 'DownLoad('.$id.','.$record.')';
        }
        if(IsPreviewProfile($record,$module)=='yes' && $fileAllowed['Preview'] === 'yes'){
            $btn['preview']['label'] = getFixedLabel('PREVIEW');
            $btn['preview']['permit'] = 'yes';
            // @edit:dong @date:2020/08/03 @reason: 附件管理模块列表预览 bug：0042251
            if(checkFileNameIsImg($attachmentInfo['filename'])) {
//                @edit:liushuai,2021-04-08,reason:【ID1001517】附件增加下载和预览次数及操作日志(附件模块序时簿预览图片)
                $btn['preview']['click'] = "previewImage(ld(this).parent()[0]);ld(this).next('img').click();savePreviewlog({$record},{$id},'Attachment','');";
            }elseif(checkFileNameIsVideo($attachmentInfo['filename'])){
                $btn['preview']['click'] = "preview_video({$record});savePreviewlog({$record},{$id},'Attachment','');";
            }else{
                $btn['preview']['click'] = 'open_Attachment(\''.$record.'\',\''.$id.'\',\'Attachment\',\''.$attachmentInfo['filename'].'\')';
            }
        }
        if(!empty($this->listview_link['delete']) && $this->listview_link['delete']['permit'] == 'yes'){
            $this->listview_link['delete']['result']['detail_id'] = $id;
        }
        $this->listview_link = f_array_insert($this->listview_link,$btn,-1);
    }


    public function getListViewLink($result,$recordId,$start,$idx) {
        $record = $this->getRecordInfo($recordId);

        $this->setListViewLink($result,$record,$start,$idx);
        $this->resetListViewLink();//按钮排序,并修改按钮显示状态
        $actionLinkInfo = '&nbsp;';
        if(!empty($this->listview_link)){
            foreach($this->listview_link as $key=>$link){
                if('yes' != $link['permit']) continue;
                //相关信息relatedid
                $relatedid = (isset($_REQUEST['relatedid'])?$_REQUEST['relatedid']:'');
                $tag = (isset($link['tag'])?$link['tag']:'');
                $type = (isset($link['type'])?$link['type']:'');
                $r_m = (isset($link['result']['module'])?$link['result']['module']:'');
                $r_a = (isset($link['result']['action'])?$link['result']['action']:'');
                $r_r = (isset($link['result']['record'])?$link['result']['record']:'');
                $attach_id = (isset($link['result']['detail_id'])?$link['result']['detail_id']:'');
                $strhtml= sprintf('<a class="Anu3_a" href="javascript:void(0);" 
							onclick="'.$link['click'].';"relatedid="'.$relatedid.'" tag="'.$tag.'" type="'.$type.'" r_m="'.$r_m.'" r_a="'.$r_a.'" r_r="'.$r_r.'" attach_id="'.$attach_id.'" style="white-space:nowrap;">
							'.$link['label'].'</a>',$record);

                $actionLinkInfo.=$strhtml;
                $this->list_buttom_name[$record][]= trim($link['label']);
                $this->list_button_html[$record][$key]=$strhtml;
            }
            // @edit:dong @date:2020/08/03 @reason: 附件管理模块列表预览 bug：0042251
            $attachmentInfo =$this->thisRowAttachmentInfo;
            if($attachmentInfo['filename'] != '' && checkFileNameIsImg($attachmentInfo['filename'])){
                $imgFilePath ='';
                //edit:can 2020-10-19 42926: (www.xiaoshou360.com/KH/lantecp/index.php)销售-销售订单(蓝太客环保客户问题)；单据LSHP20-327，打开单据详情后，横栏附件管理模块，点击附件管理中的图片预览，加载不出图片；新上传的附件图片可以预览。
                //说明	(www.xiaoshou360.com/KH/lantecp/index.php)销售-销售订单(蓝太客环保客户问题)；单据LSHP20-327，打开单据详情后，横栏附件管理模块，点击附件管理中的图片预览，加载不出图片；新上传的附件图片可以预览。doc文件和pdf格式文件都可以预览。
                if($attachmentInfo['storage_location'] == 'cos'){
                    $imgFilePath=$attachmentInfo['cloud_path'];
                    
                }else{
                    $imgFilePath =$attachmentInfo['path'].$attachmentInfo['newfile_name'];
                }
                $actionLinkInfo .= '<img src="'.$imgFilePath.'" style="display: none">';
            }
            //视频预览
            elseif ($attachmentInfo['filename'] != '' && checkFileNameIsVideo($attachmentInfo['filename'])){
                $filePath ='';
                if($attachmentInfo['storage_location'] == 'cos'){
                    $filePath=$attachmentInfo['cloud_path'];

                }else{
                    $filePath =$attachmentInfo['path'].$attachmentInfo['newfile_name'];
                }
                $actionLinkInfo .= '<video id="video_'.$record.'" style="display: none;">
                                        <source src="'.$filePath.'" type="video/mp4">
                                        <source src="'.$filePath.'" type="video/webm">
                                        <source src="'.$filePath.'" type="video/ogg">
                                        nonsupport video
                                    </video>';
            }

            $actionLinkInfo.=$this->getListRelateCreateButtons($record);

        }


        $record_html_btn[$record]=$actionLinkInfo;

        return $actionLinkInfo;
    }

    /**
     * @edit:dong
     * @data:2020/08/03
     * @reason:获取当前行的附件信息
     * @description:
     */
    public function setThisRowAttachmentInfo($id,$record)
    {
        if(!empty($id)){
            $query = 'select ld_attachmentsforbillsdetails.filename,ld_attachmentsforbills.isenabled,ld_attachmentsforbills.creator,ld_attachmentsforbillsdetails.newfile_name,ld_attachmentsforbillsdetails.path,ld_attachmentsforbillsdetails.storage_location,ld_attachmentsforbillsdetails.cloud_path from ld_attachmentsforbillsdetails 
				LEFT JOIN ld_attachmentsforbills on ld_attachmentsforbills.attachmentsid = ld_attachmentsforbillsdetails.attachmentsid 
				where id = ? and ld_attachmentsforbillsdetails.attachmentsid = ?';
            $result = $this->db->pquery($query,array($id,$record));
            $info['filename'] =  $this->db->query_result($result,0,0);
            $info['isenabled'] =  $this->db->query_result($result,0,1);
            $info['creator'] =  $this->db->query_result($result,0,2);
            $info['newfile_name'] =  $this->db->query_result($result,0,3);
            $info['path'] =  $this->db->query_result($result,0,4);
            $info['storage_location'] =  $this->db->query_result($result,0,5);
            $info['cloud_path'] =  $this->db->query_result($result,0,6);
            $this->thisRowAttachmentInfo =$info;
        }
    }
}
?>