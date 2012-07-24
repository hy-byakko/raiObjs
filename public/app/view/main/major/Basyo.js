Ext.define('Vmoss.view.main.major.Basyo', {
    extend:'Vmoss.view.main.Standard',

    instanceLabel: '点位',

    searchFeature:[
        {field:'basyoCd', vtype:'alphanum', xtype:'textfield', maxLength:4},
        {field:'basyoName', xtype:'textfield', maxLength:30},
        {
            field:'customerId',
            xtype:'ccombo',
            dispatch:'get_customer',

            forceSelection:true,
            selectOnFocus:true,
            editable:true
        }
    ],

    gridFeature:[
        'bumonCd',
        'bumonMei',
        'kind',
        'parent',
        'yubinNo',
        'telNo',
        'faxNo',
        'jusyo'
    ],

    benchFeature:[
        {field: 'bumonCd', allowBlank: false},
        {field: 'bumonMei', allowBlank: false},
        {
            field:'bumonlevelId',
            xtype:'ccombo',
            dispatch:'get_bumon_data',

            forceSelection:true,
            selectOnFocus:true,
            editable:true
        },
        {
            field:'parentId',
            xtype:'ccombo',
            dispatch:'get_parent_data',
            requestParams:[
                'id'
            ],

            forceSelection:true,
            selectOnFocus:true,
            editable:true
        },
        'yubinNo',
        'telNo',
        'faxNo',
        'jusyo'
    ]
});