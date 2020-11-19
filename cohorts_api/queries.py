ACTIONS = {
    'stake': 'cosmos-sdk/MsgDelegate',
    'transfer': 'cosmos-sdk/MsgSend',
    'cyberlink': 'cyber/Link',
    'withdraw': 'cosmos-sdk/MsgWithdrawDelegationReward',
    'tweet': 'first_tweet',
    'follow': 'first_follow',
    'avatar': 'first_avatar',
    '5_follows': 'first_5_folls',
    '25_follows': 'first_25_folls',
    '10_cyberlinks': 'first_10_links',
    '100_cyberlinks': 'first_100_links'
}

TAG = 'SELECT * FROM cohorts WHERE tag = \'{}\''
REGISTER_TYPE = 'SELECT * FROM cohorts WHERE register_act_type = \'{}\''
ACTION_TYPE = 'SELECT \
    subject, \
	register, \
	first_act, \
	register_act_type, \
	register_act_month, \
	diff, \
	tag, \
	CASE \
	    WHEN first_act_type !=\'{}\' THEN NULL \
	    ELSE first_act_type \
	END AS first_act_type \
FROM \
    cohorts'

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

ACTION_TYPE_2 = 'SELECT \
    cohorts.subject, \
    register, \
    tmp.first_act_type, \
    register_act_month, \
    CASE \
        WHEN tmp.first_act_type IS NULL THEN -1 \
        ELSE FLOOR((tmp.first_act_type - register)/30) \
        END AS diff \
FROM \
    cohorts \
LEFT JOIN ( \
    SELECT \
        subject, \
         accs_by_act.{} AS first_act_type \
    FROM \
        accs_by_act \
) tmp \
ON ( \
    cohorts.subject = tmp.subject \
)'

REGISTER_TYPE_ACTION_TYPE_2 = 'SELECT \
    cohorts.subject, \
    register, \
    tmp.first_act_type, \
    register_act_month, \
    CASE \
        WHEN tmp.first_act_type IS NULL THEN -1 \
        ELSE FLOOR((tmp.first_act_type - register)/30) \
        END AS diff \
FROM \
    cohorts \
LEFT JOIN ( \
    SELECT \
        subject, \
        accs_by_act.{} AS first_act_type \
    FROM \
        accs_by_act \
) tmp \
ON ( \
    cohorts.subject = tmp.subject \
)\
WHERE \
    register_act_type = \'{}\''

TAG_ACTION_TYPE_2 = 'SELECT \
    cohorts.subject, \
    register, \
    tmp.first_act_type, \
    register_act_month, \
    CASE \
        WHEN tmp.first_act_type IS NULL THEN -1 \
        ELSE FLOOR((tmp.first_act_type - register)/30) \
        END AS diff \
FROM \
    cohorts \
LEFT JOIN ( \
    SELECT \
        subject, \
        accs_by_act.{} AS first_act_type \
    FROM \
        accs_by_act \
) tmp \
ON ( \
    cohorts.subject = tmp.subject \
)\
WHERE \
    tag = \'{}\''

TAG_REGISTER_TYPE_ACTION_TYPE_2 = 'SELECT \
    cohorts.subject, \
    register, \
    tmp.first_act_type, \
    register_act_month, \
    CASE \
        WHEN tmp.first_act_type IS NULL THEN -1 \
        ELSE FLOOR((tmp.first_act_type - register)/30) \
        END AS diff \
FROM \
    cohorts \
LEFT JOIN ( \
    SELECT \
        subject, \
        accs_by_act.{} AS first_act_type \
    FROM \
        accs_by_act \
) tmp \
ON ( \
    cohorts.subject = tmp.subject \
)\
WHERE \
    tag = \'{}\' AND register_act_type = \'{}\''