<?php
crm_load_class_file('HomeBoardNew_40','modules/Home/HomeBoardNew');
class  HomeBoardNew_101 extends  HomeBoardNew_40
{
    public $viewStyle;
    public $SalesGoalDefaultLabel = 'TargetCompletionRate_SalesGoal';
    public function get_stuff_content_html($stuffinfo)
    {
        $stuff_content_html = parent::get_stuff_content_html($stuffinfo);
        return $stuff_content_html;
    }
}
?>