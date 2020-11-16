TAG = 'SELECT * FROM cohorts WHERE tag = \'{}\''
REGISTER_TYPE = 'SELECT * FROM cohorts WHERE register_act_type = \'{}\''
ACTION_TYPE = 'SELECT * FROM cohorts WHERE first_act_type =\'{}\''

TAG_REGISTER_TYPE = 'SELECT * FROM cohorts WHERE tag = \'{}\' AND register_act_type = \'{}\''
TAG_ACTION_TYPE = 'SELECT \
	subject, \
	register, \
	first_act, \
	register_act_type, \
	register_act_month, \
	diff, \
	tag, \
	CASE \
	    WHEN first_act_type != \'{}\' THEN NULL \
	    ELSE first_act_type \
	END AS first_act_type \
FROM \
	(Select * from cohorts where tag = \'{}\') as tmp'

REGISTER_TYPE_ACTION_TYPE = 'SELECT \
	subject, \
	register, \
	first_act, \
	register_act_type, \
	register_act_month, \
	diff, \
	tag, \
	CASE \
	    WHEN first_act_type != \'{}\' THEN NULL \
	    ELSE first_act_type \
	END AS first_act_type \
FROM \
	(Select * from cohorts where register_act_type = \'{}\') as tmp'

TAG_REGISTER_TYPE_ACTION_TYPE = 'SELECT \
	subject, \
	register, \
	first_act, \
	register_act_type, \
	register_act_month, \
	diff, \
	tag, \
	CASE \
	    WHEN first_act_type != \'{}\' THEN NULL \
	    ELSE first_act_type \
	END AS first_act_type \
FROM \
	(Select * from cohorts where tag = \'{}\' and register_act_type = \'{}\') as tmp'

ACTIONS = {
    'stake': 'cosmos-sdk/MsgDelegate',
    'transfer': 'cosmos-sdk/MsgSend',
    'cyberlink': 'cyber/Link',
    'withdraw': 'cosmos-sdk/MsgWithdrawDelegationReward'
}