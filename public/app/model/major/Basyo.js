Ext.define('Vmoss.model.major.Basyo', {
    extend:'Vmoss.lib.CModel',
    requires: ['Vmoss.model.major.Vmcolumn'],

    hasMany:{model:'Vmoss.model.major.Vmcolumn', name:'vmcolumns'},

    fields:[
        'id',
        'basyo_cd',
        'basyo_name',
        'customer_id',
        {name:'customer_name', persist:false},
        'vm_id',
        {name:'vm_cd', persist:false},
        'bumon_id',
        {name:'bumon_name', persist:false},
        'eigyotanto_id',
        {name:'eigyotanto_name', persist:false},
        'sagyotanto_id',
        {name:'sagyotanto_name', persist:false},
        'rireki_kaisi_dtm',
        'rireki_syuryo_dtm'
    ],

    proxy:{
        type:'rest',
        url:'/basyos'
    },

    fieldsExtend:[
        {field:'basyo_cd', label:'点位编号'},
        {field:'basyo_name', label:'点位名称'},
        {field:'customer_name', label:'客户', ref:'customer_id'},
        {field:'vm_cd', label:'自售机', ref:'vm_id'},
        {field:'bumon_name', label:'部门', ref:'bumon_id'},
        {field:'eigyotanto_name', label:'营业担当者', ref:'eigyotanto_id'},
        {field:'sagyotanto_name', label:'巡回担当者', ref:'sagyotanto_id'},
        {field:'rireki_kaisi_dtm', label:'履历开始时刻'},
        {field:'rireki_syuryo_dtm', label:'履历终了时刻'}
    ]
});