function MobileDetailInfo(){
    var that = this;
    this.init = function(){
        that.setEvent();
        ld("table#detailFieldsSelectBlockTable").find('[name=DragTransfer_tr]').remove();
        var tableobj = ld("table#detailFieldsSelectBlockTable");
        if(tableobj.find('tr:first').is(":visible")){
            var LeftObj = tableobj.find("#detailFieldList");
            var RightObj = tableobj.find("#selectedDetailFieldColumns");
            var Drag_Transfer = new DragTransfer();
            Drag_Transfer.SetDragTransfer(tableobj,LeftObj,RightObj,'reset','270');
        }
    }
    this.setEvent = function(){
        //分录明细显示样式--单选change事件
        ld('[name=mobiledetailinfoshowtype]').change(function (){
            var thisvalue = ld(this).val();
            if(thisvalue!='fold'&&thisvalue!='table'){
                ld('#detailFieldsSelectBlock').hide();
                ld('#detailFieldsSelectBlockTable').hide();
            }else{
                //获取字段列表
                var modulename = ld('#modulename').val();
                var url = 'index.php?module=Settings&action=SettingsAjax&file=MobileMainInfo&type=change_mobiledetailinfoshowtype&ajax=true&frommodule='+modulename+'&mobiledetailinfoshowtype='+thisvalue;
                ld.ajax(url)
                    .done(function(response){
                        ld('#detailFieldsSelectBlock').show();
                        ld("table#detailFieldsSelectBlockTable").show();
                        ld("table#detailFieldsSelectBlockTable").find('tr').hide();
                        response = JSON.parse(response);
                        var fieldAllInfoArr = response.result.fieldAllInfoArr;
                        var fieldSelectedArr = response.result.fieldSelectedArr;
                        var fieldAllInfoOptions = '';
                        var fieldSelecteOptions = '';
                        ld.each(fieldAllInfoArr,function(i,item){
                            fieldAllInfoOptions += '<option value="'+item.columnname+'">'+item.fieldlabel+'</option>';
                        });
                        ld.each(fieldSelectedArr,function(index,fieldinfo){
                            fieldSelecteOptions += '<option value="'+fieldinfo.columnname+'">'+fieldinfo.fieldlabel+'</option>';
                        });
                        ld('#detailFieldList').html(fieldAllInfoOptions);
                        ld('#selectedDetailFieldColumns').html(fieldSelecteOptions);
                        if(thisvalue=='fold' || thisvalue=='table'){
                            ld("table#detailFieldsSelectBlockTable").find('[name=DragTransfer_tr]').remove();
                            var tableobj = ld("table#detailFieldsSelectBlockTable");
                            var LeftObj = tableobj.find("#detailFieldList");
                            var RightObj = tableobj.find("#selectedDetailFieldColumns");
                            var Drag_Transfer = new DragTransfer();
                            Drag_Transfer.SetDragTransfer(tableobj,LeftObj,RightObj,'reset','270');
                        }
                    });
            }
            ld('#mobiledetailinfoshowtypeimg').attr('src',global_image_url+'themes/fieldicon/'+thisvalue+'.jpg?a=999');

        });
        ld('#saveDetailFieldInfo').click(function(){
            var mobiledetailinfoshowtype = ld(':radio[name="mobiledetailinfoshowtype"]:checked').val();
            var selectedFields = '';

            var selectedDetailFieldColumnsObj=getObj("selectedDetailFieldColumns");
            var length = selectedDetailFieldColumnsObj.options.length;
            for (var i=0;i<length;i++)
            {
                selectedFields += selectedDetailFieldColumnsObj.options[i].value+";";
            }
            //获取字段列表
            var modulename = ld('#modulename').val();
            var url = 'index.php?module=Settings&action=SettingsAjax&file=MobileMainInfo&type=save_mobiledetailinfofield&ajax=true&frommodule='+
                modulename+'&mobiledetailinfoshowtype='+mobiledetailinfoshowtype+'&selectedFields='+selectedFields;
            ld.ajax(url)
                .done(function(response){
                    var response = JSON.parse(response);
                    if(response.code == 1){
                        MessagePopup.TipOne_success(response.msg);
                    }
                    else{
                        MessagePopup.TipOne_warning(response.msg);
                    }
                });
        });
    }

}
var MobileDetailInfoObj = new MobileDetailInfo();