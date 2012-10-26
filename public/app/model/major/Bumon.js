Ext.define('Vmoss.model.major.Bumon', {
    extend:'Vmoss.lib.CModel',

    fields:[
        'id',
        'bumon_cd',
        'bumon_mei',
        'bumonlevel_id',
        {name:'kind', persist: false},
        'parent_id',
        {name:'parent', persist: false},
        'yubin_no',
        'tel_no',
        'fax_no',
        'jusyo'
    ],

    proxy:{
        type:'rest',
        url:'/bumons'
    },

    fieldsExtend:[
        {field:'bumon_cd', label:'部门编号'},
        {field:'bumon_mei', label:'部门名称'},
        {field:'kind', label:'部门类别', ref:'bumonlevel_id'},
        {field:'parent', label:'上级部门', ref:'parent_id'},
        {field:'yubin_no', label:'邮编'},
        {field:'tel_no', label:'电话'},
        {field:'fax_no', label:'传真'},
        {field:'jusyo', label:'地址'}
    ]
});