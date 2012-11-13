Ext.define('Vmoss.model.major.User', {
    requires: ['Vmoss.model.major.Department'],
    extend:'Vmoss.lib.CModel',

    associations:[
        { type:'belongsTo', model:'Vmoss.model.major.Department', foreignKey:'bumon_id'}
    ],

    fields:[
        'id',
        'user_cd',
        'password',
        'user_name',
        'bumon_id',
        'department_name',
        'syokumu_id',
        'sex',
        'birth_dtm',
        'nyusya_dtm',
        'tel_no',
        'email'
    ],

    proxy:{
        type:'rest',
        url:'/objects/clients'
    },

    fieldsExtend:[
        {field:'user_cd', label:'用户编号'},
        {field:'user_name', label:'用户名'},
        {field:'bumon_id', label:'部门名'},
        {field:'department_name', label:'部门名'},
        {field:'syokumu_id', label:'职位'},
        {field:'sex', label:'性别'},
        {field:'birth_dtm', label:'生日'},
        {field:'nyusya_dtm', label:'入职时间'},
        {field:'tel_no', label:'电话'},
        {field:'email', label:'Email'}
    ]
});