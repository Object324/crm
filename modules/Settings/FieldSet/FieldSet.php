<?php
/** edit: xll 2024/09/26 XUQIU20240813-12 日期、日期时间、时间字段格式化 */
class FieldSet
{
    static function getDateFormatList() {
        return [
            'date' => [
                [ 'value' => 'Y-m-d', 'label' => '年-月-日', ],
                [ 'value' => 'Y-m', 'label' => '年-月', ],
                [ 'value' => 'Y-Q', 'label' => '年-季度', ],
                [ 'value' => 'Y', 'label' => '年', ],
            ],
            'datetime' => [
                [ 'value' => 'Y-m-d H:i:s', 'label' => '年-月-日 时:分:秒', ],
                [ 'value' => 'Y-m-d H:i', 'label' => '年-月-日 时:分', ],
                [ 'value' => 'Y-m-d H', 'label' => '年-月-日 时', ],
                [ 'value' => 'Y-m-d h:i:s A', 'label' => '年-月-日 时:分:秒 AM/PM', ],
                [ 'value' => 'Y-m-d h:i A', 'label' => '年-月-日 时:分 AM/PM', ],
                [ 'value' => 'Y-m-d h A', 'label' => '年-月-日 时 AM/PM', ],
            ],
            'time' => [
                [ 'value' => 'H:i:s', 'label' => '时:分:秒', ],
                [ 'value' => 'H:i', 'label' => '时:分', ],
                [ 'value' => 'h:i:s A', 'label' => '时:分:秒 AM/PM', ],
                [ 'value' => 'h:i A', 'label' => '时:分 AM/PM', ],
            ],
        ];
    }

    static function getTimeFormatInfo() {
        $formatArr = self::getDateFormatList();
        $timeStr = '1600-01-01 23:59:59';
        foreach ($formatArr as $tmpType => &$list) {
            foreach ($list as &$info) {
                $info['example'] = DateOperation::format($info['value'], $timeStr);
            }
        }
        return [
            'options' => $formatArr,
            'tips' => [
                'date' => '年-月-日',
                'time' => '时-分-秒',
                'datetime' => '年-月-日 时-分-秒',
            ],
        ];
    }

    static function getTimeFormatInfoByType($bigType) {
        $formatInfo = self::getTimeFormatInfo();
        return [
            'options' => $formatInfo['options'][$bigType],
            'tips' => $formatInfo['tips'][$bigType],
        ];
    }
}