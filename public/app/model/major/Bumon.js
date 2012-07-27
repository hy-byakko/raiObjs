Ext.define('Vmoss.model.major.Bumon', {
    extend:'Vmoss.lib.CModel',

    fields:[
        'id',
        'bumonCd',
        'bumonMei',
        'bumonlevelId',
        {name:'kind', persist: false},
        'parentId',
        {name:'parent', persist: false},
        'yubinNo',
        'telNo',
        'faxNo',
        'jusyo'
    ],

    proxy:{
        type:'rest',
        url:'/bumons'
    },

    fieldsExtend:[
        {field:'bumonCd', label:'部门编号'},
        {field:'bumonMei', label:'部门名称'},
        {field:'kind', label:'部门类别', ref:'bumonlevelId'},
        {field:'parent', label:'上级部门', ref:'parentId'},
        {field:'yubinNo', label:'邮编'},
        {field:'telNo', label:'电话'},
        {field:'faxNo', label:'传真'},
        {field:'jusyo', label:'地址'}
    ]
});