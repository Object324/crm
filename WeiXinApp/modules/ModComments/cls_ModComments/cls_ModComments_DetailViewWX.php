<?php

/**
 * Created by PhpStorm.
 * User: Administrator
 * Date: 2016/11/16 0016
 * Time: 下午 5:02
 */
crm_load_class_file('cls_DetailViewWX', 'WeiXinApp/detail');
class cls_ModComments_DetailViewWX extends cls_DetailViewWX
{
    public function set_CreateView()
    {
        //zkt 20230327 BUG0063247  移动端“评论”模块新建界面字段与PC端不一样 
        //评论模块默认主题类型为 评论
        if(!isset($_REQUEST['topictype'])){
            $_REQUEST['topictype']='comments';
        }
        parent::set_CreateView();
    }

}