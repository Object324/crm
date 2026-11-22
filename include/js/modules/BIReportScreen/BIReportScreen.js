function BIReportScreenScope(projectData){
    var { id, scope, scopeid } = projectData;
    var module = 'BIReportScreen';
    getJsScript('include/js/ScopePopup/ScopePopup_Details.js',function () {
        var scopepopupobj = ScopePopup_Details.getInstance();
        var selectedtype = (scope === 'group') ? '1' : (scope === 'user') ? '2' : (scope === 'role') ? '3' : '0';
        scopepopupobj.allocateTemplate({ scope, scopeid }, 0, 0, scopeid, selectedtype, module);
        scopepopupobj.validate_url = function (){
            selectedtype = ld('#'+scopepopupobj.firstpop_id+'content input[name="radiotype"]:checked ').val();
            var new_scopeid = (selectedtype !== 0) ? cls_ScopePopup.return_obj.return_id : '',
                new_scope = (selectedtype === "1") ? 'group' : (selectedtype === "2") ? 'user' : (selectedtype === "3") ? 'role' : 'all',
                surl = 'index.php?module='+module+'&action='+module+'Ajax&file=ListView',
                params = '&funName=projectScoped&projectId='+id+'&scope='+new_scope+'&scopeid='+new_scopeid;
            ldAjax(surl, params, function(data){
                projectData.scope = new_scope;
                projectData.scopeid = new_scopeid;
                projectData.modifyTime = data.data.modifyTime;
                projectData.modifyName = data.data.modifyName;
                ld('#rptContentLoading').hide();
            });
        }
    })

}