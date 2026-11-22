<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Tujt 2015-05-28
 */
class ChannelCodeLogic extends BaseLogic {
    public function getListButtomName(){
		return 145;
	}
    public function getallListViewLink() {
        $btn =parent::getallListViewLink();
        if(vtlib_isModuleActive('ContactRecords')){
            $btn['followup']['label'] = getFixedLabel('DOWNLOAD').getFixedLabel('channelcode');;//跟进
        }
        return $btn;
    }
	public function setListViewLink($result,$record,$start,$idx) {
		parent::setListViewLink($result,$record,$start,$idx);
		global $current_user,$adb;
		$btn = array();
		$this->listview_link['edit']['click'] = "detail_channelcode_edit(event,$record)";
		//跟进
		$btn['followup']['label'] = getFixedLabel('DOWNLOAD').getFixedLabel('channelcode');
		$btn['followup']['permit'] = 'yes';
		$query = "select qr_code from ld_channelcode where id = ?";
		$result = $adb->pquery($query,array($record));
		$qr_code = $adb->query_result($result,0,0);
		$btn['followup']['click'] = 'channelcode_uploadimg(\''.$qr_code.'\')';
		$this->listview_link = f_array_insert($this->listview_link,$btn,-1);
        if(!vtlib_isModuleActive('ContactRecords')){
            unset($this->listview_link['followup']);
        }
	}
}
?>