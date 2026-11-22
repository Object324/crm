{*<!--

/*********************************************************************************
** The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
*
 ********************************************************************************/

-->*}

{*<!-- module header -->*}

<script src="include/jquery/jquery.min.js" type="text/javascript"></script>
<script src="uploaddify/jquery.uploadify.min.js" type="text/javascript"></script>
<link rel="stylesheet" type="text/css" href="uploaddify/uploadify.css">

<input type="hidden" value="{$PARENTID}" id="myatt_id" name="att_record" />
<input type="hidden" value="{$PARENTMODULE}" id="myatt_moduel" name="myatt_moduel" />
<input type="hidden" value="{$TYPE}" name="att_type" />
<input type="hidden" value="{$PATH}" name="att_path" />
{if $PARENTID eq ''}
    <tr>
        
            <td class="dvtCellLabel" width="20%" align="right">{$ARRFIELDLABEL.related_to}</td>
            <td colspan="3" class="dvtCellInfo">
        
            <select id="related_to_type" name="related_to_type" style="width:80px;">
                <option value='Accounts'>{"Accounts"|@getTranstab}</option>
                <option value='Contacts'>{"Contacts"|@getTranstab}</option>
                <option value='Potentials'>{"Potentials"|@getTranstab}</option>
                <option value='Project'>{"Project"|@getTranstab}</option>
                <option value='HelpDesk'>{"HelpDesk"|@getTranstab}</option>
                <option value='SalesOrder'>{"SalesOrder"|@getTranstab}</option>
                <option value='Quotes'>{"Quotes"|@getTranstab}</option>
                <option value='Invoice'>{"Invoice"|@getTranstab}</option>
            </select>
         
            
            <input id="related_to_name" name="related_to_name" readonly="" style="border:1px solid #bababa;" value="" type="text">
            <a class="icon-homeimg icon-select" href="javascript:;"  title="选择" onclick="selectRelatedTo('related_to_type' ,'related_to','Attachment','')"></a>
            <input class="icon-homeimg icon-clear inpb-reset" type="button"  title="清除"  onclick="this.form.related_to.value=''; this.form.related_to_name.value=''; return false;"/>&nbsp;
         	<input id="related_to" name="related_to" value="" type="hidden">
             </td>
    </tr>
 {else}
    <input id="related_to" name="related_to" value="{$PARENTID}" type="hidden">   
    <input id="related_to_type" name="related_to_type" value="{$PARENTMODULE}" type="hidden">      
       	  
            
{/if}	

<tr style="height:25px">
<td class="dvtCellLabel" width="20%" align="right">{$ARRFIELDLABEL.filename}</td>
<td class="dvtCellInfo" width="30%" align="left">
    <input id="file_name" class="detailedViewTextBox" type="text" onblur="this.className='detailedViewTextBox'" onfocus="this.className='commonDetailedTextBox gwidth70 bgcolordh'" value="" tabindex="" readonly="true" name="file_name" fieldonly="0">
</td>
<td class="dvtCellLabel" width="20%" align="right">{$ARRFIELDLABEL.isenabled}</td>
<td class="dvtCellInfo" width="30%" align="left">
    <select id="att_isenabled" name="att_isenabled">
        <option id="att_isenabled_on">{'BETOVIEWABLE'|@getFixedLabel}</option>
        <option id="att_isenabled_off">{'BETOVIEWABLEPRIVATE'|@getFixedLabel}</option>
    </select>
</td>
</tr>
<tr>
    <td class="dvtCellLabel" width="20%" align="right">{'FILE'|@getFixedLabel}</td>
    <td class="dvtCellInfo" width="30%" align="left" colspan="3">
        <form>
    		<div id="queue"></div><!--这个div，用来显示文件上传队列,通过queueID关联-->
    		<input id="file_upload" name="file_upload" type="file" multiple="true" style="display:block">
            <!--<input type="hidden" name="file_name" id="file_name">-->
    		<input type="hidden" name="file_type" id="file_type">
    		<input type="hidden" name="file_size" id="file_size">
            <input type="hidden" name="newfiel_name" id="newfiel_name">
            <input type="hidden" name="file_path" id="file_path">
    	<!--</form>-->
    </td>
    
</tr>
<tr>
<td class="dvtCellLabel" width="20%" align="right">{$ARRFIELDLABEL.description}</td>
<td class="dvtCellInfo" width="80%" colspan="3" align="left">
    <textarea id="att_description" name="att_description" class="detailedViewTextBox"></textarea>
</td>
</tr> 
<!--
*新增操作，条件附件上传插件 UPLOADIFY
*by andy 20131227
-->
<script type="text/javascript">
    {literal}
	 var myatt_id=0;
     var myatt_moduel='';
     
	$(function() {
	  
		$('#file_upload').uploadify({
			//uploadify.swf文件的路径。如果可能的话，这个路径应该是相对于根以避免出现问题，但也将接受相对于当前脚本的路径。
			//默认为uploadify.swf
			'swf'      : 'uploaddify/uploadify.swf',
			//服务端处理脚本,
			'uploader' : 'uploaddify/uploadify.php',
			'buttonText':arrJsPopLabel['BROWSETHEFILE'],//按扭的文字
			'height' : 20,//按扭高度
    		'width' :60 ,//按扭宽度
			'onDialogClose':function(){ 
			        
                },
		
    		'buttonClass':'mybutton',
			'removeTimeout':0,

			'progressData':'percentage',

			'queueID'  : 'queue',

		
			'queueSizeLimit':10,
			'uploadLimit':1,
			'successTimeout' : 5,

			//上传成功回调函数
    		'onUploadSuccess' : function(file, data, response) {
                var strs= new Array(); //定义一数组
                strs=data.split("?"); //字符分割
                var file_path=document.getElementById("file_path").value=strs[0];
                var newfiel_name=document.getElementById("newfiel_name").value=strs[1];
		    },
            
		    //上传完成
		    //会先调用onUploadSuccess然后才调用onUploadComplete
		    'onUploadComplete' : function(file) {
	             var file_name=file.name;
				var file_type=file.type;
				var file_size=file.size;
				var file_name_value1=document.getElementById("file_name").value=file_name;
				var file_name_value2=document.getElementById("file_type").value=file_type;
				var file_name_value3=document.getElementById("file_size").value=file_size;
	        },
            
          
            //从对话框回选择了文件
            //对不起，目前只支持单文件上传,'+ file_name_value1+ ' 已经上传成功! 
		    'onSelectError' : function() {
	          
               var file_name_value1=document.getElementById("file_name").value
               alert(arrJsPopLabel['ONLYSINGLEFILEUPLOAD']+ file_name_value1+ arrJsPopLabel['HASUPLOADSUCCESS']);
               
	        },

	      

	        //上传进度
	        'onUploadProgress' : function(file, bytesUploaded, bytesTotal, totalBytesUploaded, totalBytesTotal) {
	            $('#progress').html(totalBytesUploaded + ' bytes uploaded of ' + totalBytesTotal + ' bytes.');
	        },
        
	        //开始上传
	        'onUploadStart' : function(file) {
	           myatt_id=document.getElementById("related_to").value;
               var str={'myatt_id':myatt_id,'myatt_moduel':document.EditView.related_to_type.value };
                $('#file_upload').uploadify('settings','method','post');
	            $('#file_upload').uploadify('settings','formData',str);
	        } 



		});
	});
    {/literal}
</script>                               