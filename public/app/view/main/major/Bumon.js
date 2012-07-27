Ext.define('Vmoss.view.main.major.Bumon', {
    extend:'Vmoss.view.main.Standard',

    instanceLabel: '部门',

    searchFeature:[
        {field:'bumonCd', vtype:'alphanum', xtype:'textfield', maxLength:4},
        {field:'bumonMei', xtype:'textfield', maxLength:30},
        {
            field:'bumonlevelId',
            xtype:'ccombo',
            dispatch:'get_bumon_data',

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
            dispatch:'get_bumon_data'
        },
        {
            field:'parentId',
            xtype:'ccombo',
            dispatch:'get_parent_data',
            requestParams:[
                'id'
            ]
        },
        'yubinNo',
        'telNo',
        'faxNo',
        'jusyo'
    ]
});