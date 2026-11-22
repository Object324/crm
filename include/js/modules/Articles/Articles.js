//关联添加渠道码 - 渠道码特殊模块
function RelatedPopup_channelcode_add(record,surl){
	getJsScript('include/js/modules/ChannelCode/ChannelCode.js',function(){channelcode_add(record,surl);});
}