Ext.define('Vmoss.model.major.Bumon', {
    extend:'Vmoss.lib.CModel',

    fields:[
        'id',
        {name:'cd', type:'string'},
        {name:'name', type:'string'},
        {name:'kindId', type:'string'},
        {name:'kind', type:'string'},
        {name:'parent', type:'string'},
        {name:'yubinNo', type:'string'},
        {name:'telNo', type:'string'},
        {name:'faxNo', type:'string'},
        {name:'jusyo', type:'string'}
    ],

    proxy:{
        type:'rest',
        url:'/bumons'
    },

    fieldsExtend:[
        {field:'cd', label:'部门编号'},
        {field:'name', label:'部门名称'},
        {field:'kind', label:'部门类别', ref:'kindID'},
        {field:'parent', label:'上级部门'},
        {field:'yubinNo', label:'邮编'},
        {field:'telNo', label:'电话'},
        {field:'faxNo', label:'传真'},
        {field:'jusyo', label:'地址'}
    ]
});