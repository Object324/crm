<?php
/**
 * 无限分类树（支持子分类排序）
 * version：1.4
 * author：Veris
 * website：www.mostclan.com
 */
class ClassTree {
	
	/**
     * 功能:无限级分类
     * 参数:$data 类别查询结果集
     * 返回值:$arr 排序后的数组
     */
    static public function getCateTree($data) {
        $arr = ClassTree::cateSort($data);
        return $arr;
    }

    /**
     * 功能:无限级分类排序
     * 参数:$data 类别查询结果集
     * 返回值:$arr 递归查询排序后的数组
     */
    static function cateSort($data,$pid=0,$level=0) {
        static $arr = array();
        foreach($data as $k => $v) {
            if($v['parentid'] == $pid) {
                $arr[$k] = $v;
                $arr[$k]['level'] = $level + 1;
               ClassTree::cateSort($data,$v['id'],$level+1);
            }
        }
        return $arr;
    }
    /**
     * 分类排序（降序）
     */
    static public function sort($arr,$cols){
        //子分类排序
        foreach ($arr as $k => &$v) {
            if(!empty($v['sub'])){
                $v['sub']=self::sort($v['sub'],$cols);
            }
            $sort[$k]=$v[$cols];
        }
        if(isset($sort))
            array_multisort($sort,SORT_DESC,$arr);
        return $arr;
    }
    /**
     * 横向分类树
     */
    static public function hTree($arr,$pid=0){
        foreach($arr as $k => $v){
            if($v['parentid']==$pid){
                $data[$v['id']]=$v;
                $data[$v['id']]['sub']=self::hTree($arr,$v['id']);
            }
        }
        return isset($data)?$data:array();
    }
    /**
     * 纵向分类树
     */
    static public function vTree($arr,$pid=0){
        foreach($arr as $k => $v){
            if($v['parentid']==$pid){
                $data[$v['id']]=$v;
                $data+=self::vTree($arr,$v['id']);
            }
        }
        return isset($data)?$data:array();
    }
}