Ext.define('Vmoss.model.major.Basyo', {
    extend:'Vmoss.lib.CModel',
    requires: ['Vmoss.model.major.Vmcolumn'],

    hasMany:{model:'Vmoss.model.major.Vmcolumn', name:'vmcolumns'},

    fields:[
        'id',
        'basyoCd',
        'basyoName',
        'customerId',
        {name:'customerName', persist:false},
        'vmId',
        {name:'vmCd', persist:false},
        'bumonId',
        {name:'bumonName', persist:false},
        'eigyotantoId',
        {name:'eigyotantoName', persist:false},
        'sagyotantoId',
        {name:'sagyotantoName', persist:false},
        'rirekiKaisiDtm',
        'rirekiSyuryoDtm'
    ],

    proxy:{
        type:'rest',
        url:'/basyos'
    },

    fieldsExtend:[
        {field:'basyoCd', label:'点位编号'},
        {field:'basyoName', label:'点位名称'},
        {field:'customerName', label:'客户', ref:'customerId'},
        {field:'vmCd', label:'自售机', ref:'vmId'},
        {field:'bumonName', label:'部门', ref:'bumonId'},
        {field:'eigyotantoName', label:'营业担当者', ref:'eigyotantoId'},
        {field:'sagyotantoName', label:'巡回担当者', ref:'sagyotantoId'},
        {field:'rirekiKaisiDtm', label:'履历开始时刻'},
        {field:'rirekiSyuryoDtm', label:'履历终了时刻'}
    ]
});