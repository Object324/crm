function LangJieLocalAssign()
{
    //郎捷 配送任务单
    
    List_CheckBox_Ids.getIds(module);
    var select_options = List_CheckBox_Ids.ids;
    var  idstring = select_options;
    count = List_CheckBox_Ids.num_rows;
   // if (parseInt(count) > parseInt(getMaxMassOperationLimit())) {
        //alert_str = getThreeVarJsPop('YOUSELECTMAXMASSOPERATIONLIMIT', parseInt(count), getMaxMassOperationLimit(), '');
    //}
    var paramsobj=new CreatePagePopup.params();
    CreatePagePopup.showpage('CustomForm28',"&langjielocalassingids="+idstring,paramsobj);
    
}