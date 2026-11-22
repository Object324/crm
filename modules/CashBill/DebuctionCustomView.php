<?php

class DebuctionCustomView extends CustomView 
{
     /**
     * 重写父类高级查询方法
     * */
    public function  getAdvFilterByCvid($cvid) {
         return [];
    }
    /**
     * 获取高级查询条件
     **/
    function getAdvFilterByautoid() {
        return [];
         
    } 
    
}

?>