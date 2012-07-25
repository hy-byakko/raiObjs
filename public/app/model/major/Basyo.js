Ext.define('Vmoss.model.major.Basyo', {
    extend:'Vmoss.lib.CModel',

    fields:[
        'id',
        {name:'basyoCd', type:'string'},
        {name:'basyoName', type:'string'},
        {name:'customerId', type:'string'},
        {name:'customerName', type:'string'},
        {name:'vmId', type:'string'},
        {name:'vmName', type:'string'},
        {name:'kind', type:'string', persist: false},
        {name:'parentId', type:'string'},
        {name:'parent', type:'string', persist: false},
        {name:'yubinNo', type:'string'},
        {name:'telNo', type:'string'},
        {name:'faxNo', type:'string'},
        {name:'jusyo', type:'string'}
    ],

    proxy:{
        type:'rest',
        url:'/basyos'
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