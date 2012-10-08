Ext.define('Vmoss.view.main.major.Basyo', {
    extend:'Vmoss.view.main.Standard',

    instanceLabel:'点位',

    searchFeature:[
        {field:'basyoCd', vtype:'alphanum', xtype:'textfield', maxLength:4},
        {field:'basyoName', xtype:'textfield', maxLength:30},
        {
            field:'customerId',
            xtype:'ccombo',
            dispatch:'get_customer'
        },
        {
            field:'vmId',
            xtype:'ccombo',
            dispatch:'get_vm'
        },
        {
            field:'bumonId',
            xtype:'ccombo',
            dispatch:'get_bumon'
        },
        {
            field:'eigyotantoId',
            xtype:'ccombo',
            dispatch:'get_eigyotanto'
        },
        {
            field:'sagyotantoId',
            xtype:'ccombo',
            dispatch:'get_sagyotanto'
        },
        {
            field:'rirekiDtm',
            xtype:'datefield',
            label:'作业日',
            format:'Y/m/d',
            value:Ext.Date.format(new Date(), 'Y/m/d'),
            listeners:{
                change:function(){
                    console.log(arguments);
                }
            }
        }
    ],

    gridFeature:[
        'customerName',
        'basyoCd',
        'basyoName',
        'rirekiKaisiDtm',
        'rirekiSyuryoDtm',
        {field:'bumonName', label:'管辖部门'},
        'eigyotantoName',
        'vmCd',
        'sagyotantoName'
    ],

    benchFeature:[
        {field:'basyoCd', vtype:'alphanum', xtype:'textfield', maxLength:4},
        {field:'basyoName', xtype:'textfield', maxLength:30},
        {
            field:'customerId',
            xtype:'ccombo',
            dispatch:'get_customer'
        },
        {
            field:'vmId',
            xtype:'ccombo',
            dispatch:'get_vm'
        },
        {
            field:'bumonId',
            xtype:'ccombo',
            dispatch:'get_bumon'
        },
        {
            field:'eigyotantoId',
            xtype:'ccombo',
            dispatch:'get_eigyotanto'
        },
        {
            field:'sagyotantoId',
            xtype:'ccombo',
            dispatch:'get_sagyotanto'
        }
    ]
});